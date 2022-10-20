(import-macros {: <<- : in} "../macro/macros")

(local {: filter
        : first
        : couples
        } (wesnoth.require :util))

(local {: difference
        : union
        : distance
        : zone
        : connecting-line
        : midpoint
        : coll-neighbors
        } (wesnoth.require :coord))

(local {: hget
        : hset
        : generate-empty-map
        } (wesnoth.require :map))

(local {: codes
        : random-hex-gen
        : random-landscape-weights
        : water-features-weights
        : coast-features-weights
        : mirror-hex
        } (wesnoth.require :codes))

(lambda draw-random [t]
  (. t (math.random (length t))))

(lambda symmetric-hex [{: hexes : symmetric-crd &as map} crd]
  (hset hexes
        (symmetric-crd crd)
        (->> crd
             (hget hexes)
             mirror-hex)))

(lambda symmetrize-map [{: hexes : some-hexes &as map}]
  (each [_ crd (ipairs (some-hexes :half?))]
    (symmetric-hex map crd))
  map)

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

(lambda gen-half [{: hexes : some-hexes &as map}]
  (let [random-hex (random-hex-gen random-landscape-weights)]
    (each [_ crd (ipairs (->> (some-hexes :half?)
                              (filter #(= :flat (hget hexes $)))))]
      (hset hexes crd (random-hex)))
  map))

(lambda place-villages [{: hexes : some-hexes : map-neighbors &as map}]
  (var available-hexes (->> (some-hexes :inner?)
                            (filter #(= :flat (hget hexes $)))))
  (for [i 1 8 1]
    (let [crd (draw-random available-hexes)
          occupied (zone crd 2)]
      (table.insert occupied crd)
      (hset hexes crd :village)
      (set available-hexes (difference available-hexes occupied))))
  map)

(lambda place-keep [{: hexes : some-hexes : map-neighbors &as map}]
  (let [keep-crd (draw-random (some-hexes :for-keep?))
        nhbrs (map-neighbors keep-crd)]
    (each [_ crd (ipairs nhbrs)]
      (hset hexes crd :encampment))
    (hset hexes keep-crd :keep1)
    map))

(lambda pave-road-search
  [{: hexes
    : some-hexes
    : map-neighbors
    : half?
    &as map}
   constraint
   initial-crd
   destination-crd]
  (var finished false)
  (var crd initial-crd)
  (var exclude-list [crd])
  (<<-
    (while (not finished))
    (let [hex (hget hexes crd)])
    (if (= :cobbles hex)
      (set finished true))
    (do
      (when (constraint hex)
        (hset hexes crd :cobbles)))
    (let [dist (distance crd destination-crd)])
    (if (<= dist 1)
      (set finished true))
    (let [nhbrs (difference
                  (->> (map-neighbors crd)
                       (filter half?))
                  exclude-list)
          rndt []])
    (if (= 0 (length nhbrs))
      (set finished true))
    (do
      (each [_ new-crd (ipairs nhbrs)]
        (let [new-dist (distance new-crd destination-crd)
              cnt (if (< new-dist dist) 16
                      (= new-dist dist) 4
                      1)]
          (for [i 1 cnt 1]
            (table.insert rndt new-crd))))
      (set crd (draw-random rndt))
      (set exclude-list (union exclude-list nhbrs)))))

(lambda pave-roads [{: hexes : some-hexes : symmetric-crd &as map}]
  (let [keep-crd (->> (some-hexes :for-keep?)
                      (first #(= :keep1 (hget hexes $))))
        road-origin1 (->> (some-hexes :road-origin?)
                          draw-random)
        road-origin2 (symmetric-crd road-origin1)]
    (pave-road-search map #(~= :encampment $) road-origin1 keep-crd)
    (pave-road-search map #(= :flat $) road-origin2 keep-crd)
    map))

(lambda create-water [{: hexes : some-hexes : symmetric-crd : map-neighbors &as map}]
  (let [paint-ford (partial paint-midpoint-displacement
                            map-neighbors
                            hexes
                            #(= :flat $)
                            :ford)
        keep-crd (->> (some-hexes :for-keep?)
                      (first #(= :keep1 (hget hexes $))))
        water-origin1 (->> (some-hexes :road-origin?)
                           draw-random)
        water-origin2 (symmetric-crd water-origin1)
        water-origin3 (draw-random (some-hexes :inner?))]
    (paint-ford keep-crd water-origin1)
    (paint-ford keep-crd water-origin2)
    (paint-ford water-origin3 water-origin2)
    (paint-ford water-origin3 water-origin1)
    (paint-ford water-origin3 keep-crd)
    map))

(lambda create-water-features [{: hexes : some-hexes &as map}]
  (let [random-hex (random-hex-gen water-features-weights)]
    (each [_ crd (ipairs (->> (some-hexes :half?)
                              (filter #(= :ford (hget hexes $)))))]
      (hset hexes crd (random-hex)))
    map))

(lambda create-coast-features [{: hexes : some-hexes &as map}]
  (let [random-hex (random-hex-gen coast-features-weights)]
    (each [_ crd
             (ipairs (->> (some-hexes :half?)
                          (filter #(in (hget hexes $)
                                       :ford :shallow-water :coastal-reef))
                          coll-neighbors
                          (filter #(= :flat (hget hexes $)))))]
      (let [hex (random-hex)]
        (if (~= :skip hex)
          (hset hexes crd hex))))
    map))

(lambda map-to-string [{: to-string} codes]
  (to-string codes))

(lambda generate []
  (->
    (generate-empty-map)
    place-keep
    create-water
    create-water-features
    create-coast-features
    pave-roads
    place-villages
    gen-half
    symmetrize-map
    (map-to-string codes)))

{: generate}

