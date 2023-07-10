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
     :line-origin
       (connecting-line [2 0] [10 0])
     :line-end
       (filter on-map?
         (connecting-line [1 12] [7 15]))
     :symmetric-line-end
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

(lambda gen-lines [{: hexes : half? : on-map?
                    : line-origin : line-end : symmetric-line-end
                    &as map}]
  (let [map-neighbors #(filter (f-and [half? on-map?])
                               (neighbors $1 $2))
        origin (draw-random line-origin)
        end (draw-random line-end)
        sym-origin (symmetric origin)
        sym-end (draw-random symmetric-line-end)]
    (paint-midpoint-displacement
      origin
      end
      {: map-neighbors
       :f #(hset hexes $ {:road 1})
       :?iterations 4})
    (paint-midpoint-displacement
      sym-origin
      sym-end
      {: map-neighbors
       :f #(hset hexes $ {:road 2})
       :?iterations 2}))
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
  (->
    (gen-shape)
    (gen-patch {:min-size 2
                :max-size 6
                :spacing 2
                :f (fn [hexes crd idx]
                     (hset hexes crd {:difficult idx}))})
    gen-lines
    choose-tiles
    symmetrize-map
    to-csv))

{: generate}

