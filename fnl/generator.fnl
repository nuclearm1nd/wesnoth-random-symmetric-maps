(local {: neighbors}
  (if wesnoth.require
    (wesnoth.require :util)
    (require :util)))

(local codes
  {:village "Gg^Vh"
   :forest "Gg^Fds"
   :flat "Gg"
   :hill "Hh"
   :mountain "Mm"
   :ford "Wwf"
   :shallow-water "Ww"
   :sand "Ds"
   :fungus "Uu^Tf"
   :swamp "Ss"
   :encampment "Ce"
   :keep1 "1 Ke"
   :keep2 "2 Ke"})

(local random-landscape-weights
  {:flat 120
   :forest 25
   :hill 10
   :mountain 5
   :ford 10
   :shallow-water 5
   :village 6
   :sand 2
   :fungus 1
   :swamp 1})

(lambda random-hex-gen [weights]
  (var total 0)
  (var gap-table {})
  (each [k v (pairs weights)]
    (for [i 1 v]
      (table.insert gap-table k))
    (set total (+ total v)))
  (lambda []
    (. gap-table (math.random total))))

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

(lambda off-map? [[x y] {: width : height}]
  (or (or (or (= y 0)
              (= x 0))
          (= y (+ height 1)))
      (= x (+ width 1))))

(lambda hget [hexes [x y]]
  (. (. hexes y) x))

(lambda hset [hexes [x y] value]
  (tset (. hexes y) x value))

(lambda symmetric [[x y] {: width : height}]
  [(-> width  (+ 1) (- x))
   (-> height (+ 1) (- y))])

(lambda sym-hex [{: hexes &as map} crd]
  (let [hex (hget hexes crd)
        sym (if (= :keep1 hex)
                :keep2
                hex)]
    (hset hexes
          (symmetric crd map)
          sym)))

(lambda symmetrize-map [{: hexes &as map}]
  (each [_ crd (half-coords map)]
    (sym-hex map crd))
  map)

(lambda gen-size-shape []
  (let [width 28
        height 16
        hexes {}]
    (for [y 1 height 1]
      (tset hexes y {})
      (for [x 1 width 1]
        (tset (. hexes y) x :grass)))
  {:width  width
   :height height
   :hexes  hexes}))

(lambda gen-half [{: hexes &as map}]
  (let [random-hex (random-hex-gen random-landscape-weights)]
    (each [_ crd (half-coords map)]
      (hset hexes crd (random-hex)))
  map))

(lambda place-keep [{: width : height : hexes &as map}]
  (let [keep [(math.floor (math.random 2 (/ width 4)))
              (math.floor (math.random 2 (/ height 2)))]
        nhbrs (neighbors keep map)]
    (each [_ crd (ipairs nhbrs)]
      (hset hexes crd :encampment))
    (hset hexes keep :keep1)
    map))

(lambda map-to-string [{: width : height : hexes &as map}]
  (var result "")
  (for [y 0 (+ height 1) 1]
    (for [x 0 (+ width 1) 1]
      (if (off-map? [x y] map)
          (set result (.. result "_off^_usr"))
          (set result
            (.. result
                (. codes (hget hexes [x y])))))
      (when (< x (+ width 1))
        (set result (.. result ", "))))
    (set result (.. result "\n")))
  result)

(lambda generate-map-string []
  (->
    (gen-size-shape)
    gen-half
    place-keep
    symmetrize-map
    map-to-string))

{:generate generate-map-string}

