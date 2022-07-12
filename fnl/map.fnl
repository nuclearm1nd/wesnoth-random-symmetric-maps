(macro set-methods [t ...]
  (let [result []]
    (each [_ m (ipairs [...])]
      (table.insert result
        `(tset ,t ,(tostring m) (partial ,m ,t))))
    `(do ,(table.unpack result))))

(lambda hget [hexes [x y]]
  (. (. hexes y) x))

(lambda hset [hexes [x y] value]
  (tset (. hexes y) x value))

(lambda neighbors [{: width : height : on-map?} [x y]]
  (let [result []
        add (lambda [crd]
              (when (on-map? crd)
                (table.insert result crd)))]
    (add [x (- y 1)])
    (add [x (+ y 1)])

    (if (= (% x 2) 0)
      (do
        (add [(+ x 1) y])
        (add [(+ x 1) (+ y 1)])
        (add [(- x 1) (+ y 1)])
        (add [(- x 1) y]))
      (do
        (add [(+ x 1) (- y 1)])
        (add [(+ x 1) y])
        (add [(- x 1) y])
        (add [(- x 1) (- y 1)])))
    result))

(lambda on-map? [{: width : height} [x y]]
  (and (> y 0)
       (> x 0)
       (< y (+ height 1))
       (< x (+ width 1))))

(lambda to-string [{: width : height : hexes : on-map?} codes]
  (var result "")
  (let [add (lambda [val]
              (set result (.. result val)))
        get-code (lambda [crd]
                   (if (on-map? crd)
                     (. codes (hget hexes crd))
                     (. codes :off-map)))]
    (for [y 0 (+ height 1) 1]
      (for [x 0 (+ width 1) 1]
        (add (get-code [x y]))
        (when (< x (+ width 1))
          (add ", ")))
      (add "\n"))
    result))

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
      (set-methods map
        on-map?
        neighbors
        half-coords
        symmetric-crd
        random-keep-crd
        to-string)
      map)))

{: hget
 : hset
 : neighbors
 : on-map?
 : generate-empty-map}

