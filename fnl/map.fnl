(local {: filter} (wesnoth.require :util))

(local {: check-factory
        : line-constraint
        : line-distance-constraint
        : neighbors
        : symmetric
        : to-axial
        : to-oddq} (wesnoth.require :coord))

(macro set-methods [t ...]
  (let [result []]
    (each [_ m (ipairs [...])]
      (table.insert result
        `(tset ,t ,(tostring m) (partial ,m ,t))))
    `(do ,(table.unpack result))))

(lambda hget [hexes [x y]]
  (?. (?. hexes y) x))

(lambda hset [hexes [x y] value]
  (tset (. hexes y) x value))

(lambda generate-shape []
  (let [qmax 34
        rmax 34
        on-map?
          (check-factory
            [(line-constraint [:horizontal  0] :below)
             (line-constraint [:horizontal 33] :above)
             (line-constraint [:vertical    0] :right)
             (line-constraint [:vertical   33] :left)])
        hexes {}]
    (for [r 0 rmax 1]
      (tset hexes r {})
      (for [q 0 qmax 1]
        (hset hexes [q r]
              (if (on-map? [q r]) :flat :off-map))))
    {: qmax
     : rmax
     : on-map?
     : hexes
     :half?
       (check-factory
         [(line-constraint [:horizontal  0] :below)
          (line-constraint [:horizontal 33] :above)
          (line-constraint [:vertical    0] :right)
          (line-constraint [:vertical   17] :left)])
     :inner?
       (check-factory
         [(line-constraint [:horizontal  4] :below)
          (line-constraint [:horizontal 29] :above)
          (line-constraint [:vertical    2] :right)
          (line-constraint [:vertical   13] :left)])
     :for-keep?
       (check-factory
         [(line-constraint [:horizontal  6] :below)
          (line-constraint [:horizontal 27] :above)
          (line-constraint [:vertical    3] :right)
          (line-constraint [:vertical    8] :left)])}))

(lambda map-neighbors [{: on-map?} crd ?dist]
  (let [dist (or ?dist 1)]
    (->> (neighbors crd dist)
         (filter on-map?))))

(lambda some-hexes [{: qmax : rmax &as map} key]
  (let [result {}
        criterium (. map key)]
    (for [r 0 rmax 1]
      (for [q 0 qmax 1]
        (when (criterium [q r])
          (table.insert result [q r]))))
    result))

(lambda symmetric-crd [_ crd]
  (symmetric crd [16.5 16.5]))

(lambda oddq-bounds [map]
  (var xmin 1)
  (var xmax 0)
  (var ymin 1)
  (var ymax 0)
  (each [_ v (pairs (some-hexes map :on-map?))]
    (let [[x y] (to-oddq v)]
      (if (< x xmin) (set xmin x))
      (if (> x xmax) (set xmax x))
      (if (< y ymin) (set ymin y))
      (if (> y ymax) (set ymax y))))
  [(- xmin 1)
   (+ xmax 1)
   (- ymin 1)
   (+ ymax 1)])

(lambda to-string [{: hexes : on-map? &as map} codes]
  (var result "")
  (let [[xmin xmax ymin ymax] (oddq-bounds map)
        add (lambda [val]
              (set result (.. result val)))
        get-code (lambda [crd]
                   (let [cd (hget hexes crd)]
                     (if (and cd (on-map? crd))
                       (. codes cd)
                       (. codes :off-map))))]
    (for [y ymin ymax 1]
      (for [x xmin xmax 1]
        (-> [x y] to-axial get-code add)
        (when (< x xmax)
          (add ", ")))
      (add "\n"))
    result))

(lambda generate-empty-map []
  (let [map (generate-shape)]
    (set-methods map
      map-neighbors
      some-hexes
      symmetric-crd
      to-string)
    map))

{: hget
 : hset
 : map-neighbors
 : generate-empty-map
 : oddq-bounds}

