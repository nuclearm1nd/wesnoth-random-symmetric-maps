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

(lambda generate-shape []
  (let [width 28
        height 16
        on-map?
          (lambda [[x y]]
            (and (> y 0)
                 (> x 0)
                 (<= y height)
                 (<= x width)))
        hexes {}]
    (for [y 1 height 1]
      (tset hexes y {})
      (for [x 1 width 1]
        (hset hexes [x y]
              (if (on-map? [x y]) :flat :off-map))))
    {: width
     : height
     : on-map?
     : hexes
     :half?
       (lambda [[x y]]
         (and (> x 0)
              (> y 0)
              (<= y height)
              (<= x (/ width 2))))
     :inner?
       (lambda [[x y]]
         (and (> x 2)
              (> y 2)
              (<= y (- height 2))
              (<= x (-> width (/ 2) (- 4)))))
     :for-keep?
       (lambda [[x y]]
         (and (> x 2)
              (> y 2)
              (<= y (- height 2))
              (<= x (/ width 4))))}))

(lambda neighbors [{: on-map?} [x y]]
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

(lambda some-hexes [{: width : height &as map} key]
  (let [result {}
        criterium (. map key)]
    (for [y 1 height 1]
      (for [x 1 (/ width 2) 1]
        (when (criterium [x y])
          (table.insert result [x y]))))
    result))

(lambda symmetric-crd [{: width : height} [x y]]
  [(-> width  (+ 1) (- x))
   (-> height (+ 1) (- y))])

(lambda generate-empty-map []
  (let [map (generate-shape)]
    (set-methods map
      neighbors
      some-hexes
      symmetric-crd
      to-string)
    map))

{: hget
 : hset
 : neighbors
 : generate-empty-map}

