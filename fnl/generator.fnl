(local {: filter
        : first
        } (wesnoth.require :util))

(local {: difference
        : union
        : distance
        : zone
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

(macro <<- [...]
  (let [items []]
    (each [_ v (ipairs [...])]
      (table.insert items 1 v))
    `(->> ,(table.unpack items))))

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
                              (filter #(= :flat (hget hexes $1)))))]
      (hset hexes crd (random-hex)))
  map))

(lambda place-villages [{: hexes : some-hexes : map-neighbors &as map}]
  (var available-hexes (->> (some-hexes :inner?)
                            (filter #(= :flat (hget hexes $1)))))
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

(lambda pave-road
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

(lambda pave-roads [{: hexes : some-hexes : symmetric-crd &as map}]
  (let [keep-crd (->> (some-hexes :half?)
                      (first #(= :keep1 (hget hexes $1))))
        road-origin1 (->> (some-hexes :road-origin?)
                          draw-random)
        road-origin2 (symmetric-crd road-origin1)]
    (pave-road map keep-crd road-origin1)
    (pave-road map keep-crd road-origin2)
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

