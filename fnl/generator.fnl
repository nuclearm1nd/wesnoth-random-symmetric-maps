(import-macros {: <<- : in : as->} "../macro/macros")

(local {: filter
        : first
        : couples
        : round
        : f-and
        : mapv
        } (wesnoth.require :util))

(local {: difference
        : union
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
        (->> crd
             (hget hexes)
             mirror-hex)))

(lambda symmetrize-map [{: hexes : half? &as map}]
  (each [_ crd (ipairs (some-crds half? hexes))]
    (symmetric-hex hexes crd))
  map)

(lambda to-csv [{: hexes}]
  (to-wesnoth-map-csv hexes codes))

(lambda midpoint-displacement
  [map-neighbors
   initial-crd
   destination-crd]
  (var points [initial-crd destination-crd])
  (for [i 1 3 1]
    (let [acc [(. points 1)]
          add #(table.insert acc $)]
      (each [_ [crd1 crd2] (ipairs (couples points))]
        (let [mid (midpoint crd1 crd2)
              displaced
                (difference
                  (map-neighbors mid (- 5 i))
                  (connecting-line crd1 crd2))]
          (assert
            (< 0 (length displaced))
            "No suitable candidate for displaced point")
          (add (draw-random displaced))
          (add crd2)))
      (set points acc)))
  points)

(lambda paint-straight
  [hexes code constraint crd1 crd2]
  (each [_ crd (ipairs (connecting-line crd1 crd2))]
    (when (constraint (hget hexes crd))
      (hset hexes crd code))))

(lambda paint-midpoint-displacement
  [map-neighbors
   hexes
   constraint
   code
   initial-crd
   destination-crd]
  (each [_ [crd1 crd2]
           (->> (midpoint-displacement map-neighbors initial-crd destination-crd)
                couples
                ipairs)]
    (paint-straight hexes code constraint crd1 crd2)))

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
          (hset hexes [q r] {:tile :flat}))))
    {: hexes
     : half?
     : on-map?}))

(lambda seed-mounts [{: hexes : half? &as map}]
  (var crds (some-crds half? hexes))
  (while (< 0 (length crds))
    (let [crd (draw-random crds)
          around (zone crd 4)
          excluded
           (union around
             (mapv symmetric around))]
      (hset hexes crd {:tile :mountain})
      (set crds (difference crds excluded))))
  map)

(lambda patch-borders [{: hexes : half? &as map}]
  (each [_ crd
         (ipairs
           (filter #(= :flat (-> (hget hexes $) (?. :tile)))
             (difference
               (all-crds hexes)
               (as-> hs hexes
                     (some-crds
                       #(~= :flat (-> (hget hexes $) (?. :tile)))
                       hs)
                     (coll-neighbors hs 2)))))]
    (hset hexes crd {:tile :shallow-water}))
  map)

(lambda generate []
  (->
    (gen-shape)
    seed-mounts
    symmetrize-map
    patch-borders
    to-csv))

{: generate}

