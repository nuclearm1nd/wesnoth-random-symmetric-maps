(import-macros {: <<- : in : as->} "../macro/macros")

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
        } (wesnoth.require :coord))

(local {: hget
        : hset
        : all-crds
        : some-crds
        : to-wesnoth-map-csv
        } (wesnoth.require :map))

(local {: codes
        : random-hex-gen
        : random-landscape-weights
        : water-features-weights
        : coast-features-weights
        : difficult-terrain-weights
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

(lambda paint-straight
  [crd1 crd2 f ?constraint]
  (let [constraint (or ?constraint #true)]
    (each [_ crd (ipairs (connecting-line crd1 crd2))]
     (when (constraint crd)
       (f crd)))))

(lambda paint-midpoint-displacement
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
    (paint-straight crd1 crd2 f ?constraint)))

(lambda gen-shape []
  (let
    [half?
      (lambda [[q r]]
        (or (<= 0 q)
            (<= 1 r)))
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
     :map-neighbors
       #(filter (f-and [half? on-map?])
                (neighbors $1 $2))
     :path-origin
       (connecting-line [2 0] [10 0])
     :path-end
       (filter on-map?
         (connecting-line [1 12] [7 15]))
     :symmetric-path-end
       (connecting-line [15 4] [15 15])}))

(lambda gen-patch [{: hexes : half? : on-map? &as map}
                   {: min-size : max-size : spacing : f}]
  (var free (some-crds half? hexes))
  (var patch-idx 1)
  (let [taken {}]
    (while (< 0 (length free))
      (let [to-take (math.min (length free)
                              (math.random min-size max-size))
            start (draw-random free)
            cluster [start]]
        (for [i 1 (- to-take 1)]
          (let [available
                  (as-> c cluster
                        (coll-neighbors c)
                        (filter on-map? c)
                        (difference c taken))
                new (draw-random available)]
            (table.insert cluster new)))
        (each [_ crd (ipairs cluster)]
          (f hexes crd patch-idx))
        (set patch-idx (+ 1 patch-idx))
        (let [new-taken (union cluster
                          (coll-neighbors cluster spacing))]
          (union! taken new-taken)
          (set free (difference free new-taken))))))
  map)

(lambda gen-path [{: hexes : map-neighbors &as map}
                  {: origin-f : end-f : f
                   : ?iterations : ?distance-func : ?constraint}]
  (paint-midpoint-displacement
    (origin-f map)
    (end-f map)
    {: map-neighbors
     :f (partial f hexes)
     : ?iterations
     : ?distance-func
     : ?constraint})
  map)

(lambda choose-tiles [{: hexes : half? &as map}]
  (let [get #(?. (hget hexes $1) $2)]
    (each [_ crd (ipairs (some-crds half? hexes))]
      (if
        (get crd :road)
          (hset hexes crd {:tile :cave-path})
        (get crd :difficult)
          (hset hexes crd {:tile :cave-wall})
        (hset hexes crd {:tile :cave-floor}))))
  map)

(lambda generate []
  (var saved-crd [0 0])
  (let [draw-n-save #(let [result (draw-random $)]
                       (set saved-crd result)
                       result)]
    (->
      (gen-shape)
      (gen-patch {:min-size 2
                  :max-size 6
                  :spacing 2
                  :f (fn [hexes crd idx]
                       (hset hexes crd {:difficult idx}))})
      (gen-path {:origin-f #(draw-n-save (. $ :path-origin))
                 :end-f #(draw-random (. $ :path-end))
                 :f (fn [hexes crd]
                      (hset hexes crd {:road 1}))})
      (gen-path {:origin-f #(symmetric saved-crd)
                 :end-f #(draw-random (. $ :symmetric-path-end))
                 :f (fn [hexes crd]
                      (hset hexes crd {:road 2}))})
      choose-tiles
      symmetrize-map
      to-csv)))

{: generate}

