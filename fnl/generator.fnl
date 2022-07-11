(local req (or wesnoth.require require))
(local {: hget
        : hset
        : generate-empty-map} (req :map))
(local {: codes
        : random-hex-gen
        : random-landscape-weights
        : mirror-hex} (req :codes))

(lambda symmetric-hex [{: hexes : symmetric-crd &as map} crd]
  (hset hexes
        (symmetric-crd crd)
        (->> crd
             (hget hexes)
             mirror-hex)))

(lambda symmetrize-map [{: hexes : half-coords &as map}]
  (each [_ crd (half-coords)]
    (symmetric-hex map crd))
  map)

(lambda gen-half [{: hexes : half-coords &as map}]
  (let [random-hex (random-hex-gen random-landscape-weights)]
    (each [_ crd (half-coords)]
      (hset hexes crd (random-hex)))
  map))

(lambda place-keep [{: random-keep-crd : hexes : neighbors &as map}]
  (let [keep-crd (random-keep-crd)
        nhbrs (neighbors keep-crd)]
    (each [_ crd (ipairs nhbrs)]
      (hset hexes crd :encampment))
    (hset hexes keep-crd :keep1)
    map))

(lambda generate-map-string []
  (let [{: map-to-string &as map} (generate-empty-map)]
    (->
      map
      gen-half
      place-keep
      symmetrize-map
      (map-to-string codes))))

{:generate generate-map-string}

