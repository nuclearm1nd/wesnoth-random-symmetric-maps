(import-macros {: <<- : in : as-> : if=} "../macro/macros")

(local {: filter
        : remove-at-idx
        : first
        : couples
        : round
        : f-and
        : mapv
        : mapv-indexed
        : reduce
        } (wesnoth.require :util))

(local {: difference
        : union
        : union!
        : distance
        : zone
        : belt
        : connecting-line
        : midpoint
        : neighbors
        : coll-neighbors
        : symmetric
        : line-area
        : to-set
        } (wesnoth.require :coord))

(local {: hget
        : hset
        : hmerge
        : all-crds
        : some-crds
        : to-wesnoth-map-csv
        } (wesnoth.require :map))

(local {: codes
        : random-hex-gen
        : mirror-hex
        } (wesnoth.require :codes))

(lambda draw-random [t]
  (. t (math.random (length t))))

(lambda symmetric-hex [hexes crd]
  (hset hexes
        (symmetric crd)
        (hget hexes crd)))

(lambda symmetrize-map [{: hexes : half? &as map}]
  (each [_ crd (ipairs (some-crds half? hexes))]
    (symmetric-hex hexes crd))
  map)

(lambda to-csv [{: hexes}]
  (to-wesnoth-map-csv hexes codes))

(lambda midpoint-displacement
  [initial-crd
   destination-crd
   {: map-neighbors
    : ?iterations
    : ?distance-func}]
  (var points [initial-crd destination-crd])
  (let [iter (or ?iterations 3)
        df (or ?distance-func #(- 5 $))]
    (for [i 1 iter 1]
      (let [acc [(. points 1)]
            add #(table.insert acc $)]
        (each [_ [crd1 crd2] (ipairs (couples points))]
          (let [mid (midpoint crd1 crd2)
                displaced
                  (difference
                    (map-neighbors mid (df i))
                    (connecting-line crd1 crd2))]
            (assert
              (< 0 (length displaced))
              "No suitable candidate for displaced point")
            (add (draw-random displaced))
            (add crd2)))
        (set points acc))))
  points)

(lambda path-straight
  [crd1 crd2 f ?constraint]
  (let [constraint (or ?constraint #true)]
    (each [_ crd (ipairs (connecting-line crd1 crd2))]
     (when (constraint crd)
       (f crd)))))

(lambda path-midpoint-displacement
  [initial-crd
   destination-crd
   {: map-neighbors
    : f
    : ?constraint
    : ?iterations
    : ?distance-func}]
  (each [_ [crd1 crd2]
           (->> (midpoint-displacement initial-crd destination-crd
                                       {: map-neighbors : ?iterations : ?distance-func})
                couples
                ipairs)]
    (path-straight crd1 crd2 f ?constraint)))

(lambda path-seek
  [origin
   end
   {: map-neighbors
    : f
    : ?constraint}]
  (var finished false)
  (var current origin)
  (let [visited {}
        constraint (or ?constraint #true)
        weighted-random
          (fn [dist nhbrs]
            (let [rndt []]
              (each [_ new-crd (ipairs nhbrs)]
                (let [new-dist (distance new-crd end)
                      cnt (if (< new-dist dist) 16
                              (= new-dist dist) 4
                              1)]
                  (for [i 1 cnt 1]
                    (table.insert rndt new-crd))))
              (draw-random rndt)))
          stack []
          push #(table.insert stack $)
          pop #(table.remove stack)]
    (while (not finished)
      (union! visited [current])
      (let [dist (distance current end)]
        (if (= 0 dist)
          (do
            (push current)
            (set finished true))
          (let [nhbrs (difference
                        (filter constraint (map-neighbors current 1))
                        visited)]
            (if (= 0 (length nhbrs))
              (if (= 0 (length stack))
                (set finished true)
                (set current (pop)))
              (do
                (push current)
                (set current (weighted-random dist nhbrs))))))))
    (each [_ crd (ipairs stack)]
      (f crd))))

(lambda gen-shape []
  (let
    [half?
      (lambda [[q r]]
        (or (<= 1 r)
            (and (= 0 r) (<= 0 q))))
     on-map?
       (line-area
         [:below :- -24
          :above :-  24
          :right :| -16
          :left  :|  16
          :below :/ -16
          :above :/  16
          :below :\  12
          :above :\ -12])
     hexes []]
    (for [q -32 32 1]
      (for [r -32 32 1]
        (when (on-map? [q r])
          (hset hexes [q r] {}))))
    {: hexes
     : half?
     : on-map?
     :path-origin
       (connecting-line [2 0] [10 0])
     :path-end
       (filter on-map?
         (connecting-line [1 12] [7 15]))
     :symmetric-path-end
       (connecting-line [15 4] [15 15])}))

(lambda gen-patch [{: hexes : half? : on-map? &as map}
                   {: min-size : max-size : spacing : f : ?exclude}]
  (var patch-idx 1)
  (let [exclude (if ?exclude
                  (partial ?exclude hexes)
                  #false)
        taken (->> (some-crds half? hexes)
                   (filter exclude)
                   to-set)
        map-coll-nhbrs
          #(filter (f-and [half? on-map?])
                   (coll-neighbors $1 $2))]
    (var free (difference
                (some-crds half? hexes)
                taken))
    (while (< 0 (length free))
      (let [to-take (math.min (length free)
                              (math.random min-size max-size))
            start (draw-random free)
            cluster [start]]
        (for [i 1 (- to-take 1)]
          (let [available
                  (difference
                    (map-coll-nhbrs cluster)
                    taken)
                new (draw-random available)]
            (table.insert cluster new)))
        (each [_ crd (ipairs cluster)]
          (f hexes crd patch-idx))
        (set patch-idx (+ 1 patch-idx))
        (let [new-taken (union cluster
                          (coll-neighbors cluster spacing)
                          (coll-neighbors
                            (mapv symmetric cluster)
                            spacing))]
          (union! taken new-taken)
          (set free (difference free new-taken))))))
  map)

(lambda gen-path [{: hexes : half? : on-map? &as map}
                  {: algorithm : origin-f : end-f : f
                   : ?iterations : ?distance-func : ?constraint}]
  (let [origin (origin-f map)
        end (end-f map)]
    (when (and origin end)
      (let [map-neighbors
              #(filter (f-and [half? on-map?])
                       (neighbors $1 $2))
            inner-f (partial f hexes)
            constraint
              (if ?constraint
                (partial ?constraint hexes)
                #true)
            path-f (if= algorithm
                     :seek path-seek
                     :midpoint-displacement path-midpoint-displacement
                     (error (.. "unknown path algorithm " algorithm)))]
        (path-f
          origin
          end
          {: map-neighbors
           :f inner-f
           :?constraint constraint
           : ?iterations
           : ?distance-func}))))
  map)

(lambda choose-tiles [{: hexes : half? &as map}]
  (let [hex #(hget hexes $1)
        set-tile #(hset hexes $1 {:tile $2})
        impassable-tbl {}
        impassable-chooser
          (random-hex-gen {:cave-wall 2
                           :mine-wall 1
                           :ancient-stone-wall 1})
        difficult-water-chooser
          (random-hex-gen {:shallow-water 1
                           :swamp 2
                           :coastal-reef 1
                           :swamp-mushroom 2})
        easy-water-chooser
          (random-hex-gen {:ford 3
                           :swamp 2
                           :coastal-reef 1})
        difficult-terrain-chooser
          (random-hex-gen {:cave-floor 3
                           :cave-rock 2
                           :cave-mushroom 1
                           :cave-forest 3
                           :dry-hill 3
                           :dry-hill-forest 1})
        flat-terrain-chooser
          (random-hex-gen {:cave-path 1 :regular-dirt 2 :dry-dirt 2})]
    (each [_ crd (ipairs (some-crds half? hexes))]
      (let [{: impassable : water : road : difficult} (hex crd)]
        (if
          impassable
            (if water
              (set-tile crd :deep-water)
              (let [tile (?. impassable-tbl impassable)]
                (if tile
                  (set-tile crd tile)
                  (let [new-tile (impassable-chooser)]
                    (set-tile crd new-tile)
                    (tset impassable-tbl impassable new-tile)))))
          (and road water)
            (set-tile crd :ford)
          road
            (set-tile crd :ancient-stone)
          water
            (if difficult
              (set-tile crd (difficult-water-chooser))
              (set-tile crd (easy-water-chooser)))
          (if difficult
            (set-tile crd (difficult-terrain-chooser))
            (set-tile crd (flat-terrain-chooser)))))))
  map)

(lambda generate []
  (var saved-crd [0 0])
  (let [draw-n-save #(let [result (draw-random $)]
                       (set saved-crd result)
                       result)
        impassable-constraint
          (fn [hexes crd]
            (-> (hget hexes crd)
                (?. :impassable)
                (= nil)))
        edge-picker
          (lambda [rnd-f key]
            (lambda [{: hexes &as map}]
              (let [suitable
                      (filter #(impassable-constraint hexes $)
                              (. map key))]
                (rnd-f suitable))))]
    (->
      (gen-shape)
      (gen-patch {:min-size 3
                  :max-size 7
                  :spacing 4
                  :f (fn [hexes crd idx]
                       (hmerge hexes crd {:impassable idx}))})
      (gen-path {:algorithm :midpoint-displacement
                 :origin-f
                   (edge-picker draw-n-save :path-origin)
                 :end-f
                   (edge-picker draw-random :path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:water 1}))})
      (gen-path {:algorithm :midpoint-displacement
                 :origin-f
                   #(symmetric saved-crd)
                 :end-f
                   (edge-picker draw-random :symmetric-path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:water 2}))})
      (gen-path {:algorithm :seek
                 :origin-f
                   (edge-picker draw-n-save :path-origin)
                 :end-f
                   (edge-picker draw-random :path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:road 1}))
                 :?constraint impassable-constraint})
      (gen-path {:algorithm :seek
                 :origin-f
                   #(symmetric saved-crd)
                 :end-f
                   (edge-picker draw-random :symmetric-path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:road 2}))
                 :?constraint impassable-constraint})
      (gen-patch {:min-size 1
                  :max-size 4
                  :spacing 2
                  :f (fn [hexes crd idx]
                       (hmerge hexes crd {:difficult idx}))
                  :?exclude
                    (fn [hexes crd]
                      (let [hex (hget hexes crd)
                            impassable (?. hex :impassable)
                            road (?. hex :road)]
                        (or impassable road)))})
      choose-tiles
      symmetrize-map
      to-csv)))

{: generate}

