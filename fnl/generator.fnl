(local {: difference} (wesnoth.require :coord))

(local {: hget
        : hset
        : generate-empty-map} (wesnoth.require :map))

(local {: codes
        : random-hex-gen
        : random-landscape-weights
        : mirror-hex} (wesnoth.require :codes))

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
    (each [_ crd (ipairs (some-hexes :half?))]
      (hset hexes crd (random-hex)))
  map))

(lambda place-villages [{: hexes : some-hexes : map-neighbors &as map}]
  (var available-hexes (some-hexes :inner?))
  (for [i 1 5 1]
    (let [crd (draw-random available-hexes)
          occupied (map-neighbors crd)]
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

(lambda map-to-string [{: to-string} codes]
  (to-string codes))

(lambda generate []
  (->
    (generate-empty-map)
    gen-half
    place-villages
    place-keep
    symmetrize-map
    (map-to-string codes)))

{: generate}

