(local {: neighbors}
  (if wesnoth.require
    (wesnoth.require :util)
    (require :util)))

(fn all-coords [{: width : height}]
  (let [result {}]
    (for [i 1 height 1]
      (for [j 1 width 1]
        (table.insert result [j i])))
    (ipairs result)))

(fn half-coords [{: width : height}]
  (let [result {}]
    (for [i 1 height 1]
      (for [j 1 (/ width 2) 1]
        (table.insert result [j i])))
    (ipairs result)))

(fn hset [hexes [x y] value]
  (tset (. hexes y) x value))

(fn gen-size-shape []
  (let [width 28
        height 16
        hexes {}]
    (for [i 1 height 1]
      (tset hexes i {})
      (for [j 1 width 1]
        (tset (. hexes i) j "Gg")))
  {:width  width
   :height height
   :hexes  hexes}))

(fn gen-half [{: hexes &as map}]
  (each [_ crd (half-coords map)]
    (let [rnd (math.random)]
      (if (> rnd 0.975) (hset hexes crd "Gs^Vh")
          (> rnd 0.75)  (hset hexes crd "Gs^Fds")
          (> rnd 0.5)   (hset hexes crd "Gs")
                        (hset hexes crd "Gg"))))
  map)

(fn generate-map [{: width : height : hexes &as map}]
  (let [x (math.floor (math.random 2 (/ width 4)))
        y (math.floor (math.random 2 (/ height 2)))
        nhbrs (neighbors [x y] map)]
    (each [_ crd (ipairs nhbrs)]
      (hset hexes crd "Ce"))
    (for [i 0 (- height 1) 1]
      (for [j 0 (- (/ width 2) 1) 1]
        (tset (. hexes (- height i)) (- width j)
              (. (. hexes (+ i 1)) (+ j 1)))))
    (tset (. hexes y) x "1 Ke")
    (tset (. hexes (+ (- height y) 1))
          (+ (- width x) 1) "2 Ke")
    map))

(fn map-to-string [{: width : height : hexes}]
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

(fn generate-map-string []
  (->
    (gen-size-shape)
    gen-half
    generate-map
    map-to-string))

{:generate generate-map-string}

