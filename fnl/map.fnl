(lambda neighbors [{: width : height} [x y]]
  (let [result []
        add (lambda [crd]
              (table.insert result crd))]
    (when (> (- y 1) 0)
      (add [x (- y 1)]))

    (when (<= (+ x 1) width)
      (if (= (% x 2) 0)
        (do
          (add [(+ x 1) y])
          (when (<= (+ y 1) height)
            (add [(+ x 1) (+ y 1)])))
        (do
          (when (> (- y 1) 0)
            (add [(+ x 1) (- y 1)]))
          (add [(+ x 1) y]))))

    (when (<= (+ y 1) height)
      (add [x (+ y 1)]))

    (when (> (- x 1) 0)
      (if (= (% x 2) 0)
        (do
          (when (<= (+ y 1) height)
            (add [(- x 1) (+ y 1)]))
          (add [(- x 1) y]))
        (do
          (add [(- x 1) y])
          (when (> (- y 1) 0)
            (add [(- x 1) (- y 1)])))))
    result))

(lambda hget [hexes [x y]]
  (. (. hexes y) x))

(lambda hset [hexes [x y] value]
  (tset (. hexes y) x value))

(lambda off-map? [{: width : height} [x y]]
  (or (= y 0)
      (= x 0)
      (= y (+ height 1))
      (= x (+ width 1))))

(lambda map-to-string [{: width : height : hexes &as map} codes]
  (var result "")
  (for [y 0 (+ height 1) 1]
    (for [x 0 (+ width 1) 1]
      (if (off-map? map [x y])
          (set result (.. result (. codes :off-map)))
          (set result
            (.. result
                (. codes (hget hexes [x y])))))
      (when (< x (+ width 1))
        (set result (.. result ", "))))
    (set result (.. result "\n")))
  result)

(lambda half-coords [{: width : height}]
  (let [result {}]
    (for [y 1 height 1]
      (for [x 1 (/ width 2) 1]
        (table.insert result [x y])))
    (ipairs result)))

(lambda symmetric-crd [{: width : height} [x y]]
  [(-> width  (+ 1) (- x))
   (-> height (+ 1) (- y))])

(lambda random-keep-crd [{: width : height}]
  [(math.floor (math.random 2 (/ width 4)))
   (math.floor (math.random 2 (/ height 2)))])

(lambda generate-empty-map []
  (let [width 28
        height 16
        hexes {}]
    (for [y 1 height 1]
      (tset hexes y {})
      (for [x 1 width 1]
        (tset (. hexes y) x :flat)))
    (let [map {:width  width
               :height height
               :hexes  hexes}]
      (tset map :neighbors (partial neighbors map))
      (tset map :half-coords (partial half-coords map))
      (tset map :symmetric-crd (partial symmetric-crd map))
      (tset map :random-keep-crd (partial random-keep-crd map))
      (tset map :map-to-string map-to-string)
      map)))

{: hget
 : hset
 : neighbors
 : generate-empty-map}

