(local {: neighbors}
  (if wesnoth.require
    (wesnoth.require :util)
    (require :util)))

(lambda all-coords [{: width : height}]
  (let [result {}]
    (for [y 1 height 1]
      (for [x 1 width 1]
        (table.insert result [x y])))
    (ipairs result)))

(lambda half-coords [{: width : height}]
  (let [result {}]
    (for [y 1 height 1]
      (for [x 1 (/ width 2) 1]
        (table.insert result [x y])))
    (ipairs result)))

(lambda hget [hexes [x y]]
  (. (. hexes y) x))

(lambda hset [hexes [x y] value]
  (tset (. hexes y) x value))

(lambda symmetric [[x y] {: width : height}]
  [(-> width  (+ 1) (- x))
   (-> height (+ 1) (- y))])

(lambda sym-hex [{: hexes &as map} crd]
  (hset hexes
        (symmetric crd map)
        (hget hexes crd)))

(lambda sym-map [{: hexes &as map}]
  (each [_ crd (half-coords map)]
    (sym-hex map crd)))

(lambda gen-size-shape []
  (let [width 28
        height 16
        hexes {}]
    (for [y 1 height 1]
      (tset hexes y {})
      (for [x 1 width 1]
        (tset (. hexes y) x "Gg")))
  {:width  width
   :height height
   :hexes  hexes}))

(lambda gen-half [{: hexes &as map}]
  (each [_ crd (half-coords map)]
    (let [rnd (math.random)]
      (if (> rnd 0.975) (hset hexes crd "Gs^Vh")
          (> rnd 0.75)  (hset hexes crd "Gs^Fds")
          (> rnd 0.5)   (hset hexes crd "Gs")
                        (hset hexes crd "Gg"))))
  map)

(lambda generate-map [{: width : height : hexes &as map}]
  (let [keep [(math.floor (math.random 2 (/ width 4)))
              (math.floor (math.random 2 (/ height 2)))]
        nhbrs (neighbors keep map)]
    (each [_ crd (ipairs nhbrs)]
      (hset hexes crd "Ce"))
    (sym-map map)
    (hset hexes keep "1 Ke")
    (hset hexes (symmetric keep map) "2 Ke")
    map))

(lambda map-to-string [{: width : height : hexes}]
  (var result "")
  (for [i 0 (+ height 1) 1]
    (for [j 0 (+ width 1) 1]
      (if (or (or (or (= i 0)
                      (= j 0))
                  (= i (+ height 1)))
              (= j (+ width 1)))
          (set result (.. result "_off^_usr"))
          (set result
                  (.. result
                      (. (. hexes i) j))))
      (when (< j (+ width 1))
        (set result (.. result ", "))))
    (set result (.. result "\n")))
  result)

(lambda generate-map-string []
  (->
    (gen-size-shape)
    gen-half
    generate-map
    map-to-string))

{:generate generate-map-string}

