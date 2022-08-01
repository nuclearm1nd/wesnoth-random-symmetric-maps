(import-macros {: <<-} "../macro/macros")

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
        } (wesnoth.require :coord))

(local {: hget
        : hset
        : generate-empty-map
        } (wesnoth.require :map))

(local {: codes
        : random-hex-gen
        : random-landscape-weights
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
   destination-crd
   initial-crd]
  (var finished false)
  (var crd initial-crd)
  (var exclude-list [crd])
  (<<-
    (while (not finished))
    (let [hex (hget hexes crd)])
    (if (= :cobbles hex)
      (set finished true))
    (do
      (when (= :flat hex)
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

(lambda pave-road-straight
  [{: hexes &as map}
   destination-crd
   initial-crd]
  (each [_ crd (ipairs (connecting-line initial-crd destination-crd))]
    (when (= :flat (hget hexes crd))
      (hset hexes crd :cobbles))))

(lambda pave-road-midpoint-displacement
  [{: hexes
    : map-neighbors
    : half?
    &as map}
   destination-crd
   initial-crd]
  (var points [initial-crd destination-crd])
  (for [i 1 3 1]
    (let [acc [(. points 1)]
          add #(table.insert acc $)]
      (each [_ [crd1 crd2] (ipairs (couples points))]
        (let [mid (midpoint crd1 crd2)
              displaced
                (draw-random
                  (difference
                    (filter half?
                            (map-neighbors mid (- 5 i)))
                    (connecting-line crd1 crd2)))]
          (add displaced)
          (add crd2)))
      (set points acc)))
  (each [_ [crd1 crd2] (ipairs (couples points))]
    (pave-road-straight map crd1 crd2)))

(lambda pave-roads [{: hexes : some-hexes : symmetric-crd &as map}]
  (let [keep-crd (->> (some-hexes :half?)
                      (first #(= :keep1 (hget hexes $))))
        road-origin1 (->> (some-hexes :road-origin?)
                          draw-random)
        road-origin2 (symmetric-crd road-origin1)]
    (pave-road-midpoint-displacement map keep-crd road-origin2)
    (pave-road-search map keep-crd road-origin1)
    map))

(lambda map-to-string [{: to-string} codes]
  (to-string codes))

(lambda generate []
  (->
    (generate-empty-map)
    place-keep
    pave-roads
    place-villages
    gen-half
    symmetrize-map
    (map-to-string codes)))

{: generate}

