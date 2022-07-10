(lambda neighbors [[x y] {: width : height}]
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

{: neighbors}

