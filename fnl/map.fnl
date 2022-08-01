(import-macros {: set-methods} "../macro/macros")

(local {: filter
        : f-or
        } (wesnoth.require :util))

(local {: line-constraint
        : line-distance-constraint
        : line-segment-constraint
        : neighbors
        : symmetric
        : to-axial
        : to-oddq
        : line-area
        : line-area-border
        } (wesnoth.require :coord))

(lambda hget [hexes [x y]]
  (-> hexes (?. y) (?. x)))

(lambda hset [hexes [x y] value]
  (tset (. hexes y) x value))

(lambda hmod [hexes crd func]
  (->> (hget hexes crd)
       func
       (hset hexes crd)))

(lambda generate-shape []
  (let
    [qmax 38
     rmax 38
     on-map
       [:below :- -6
        :above :- (+ 6 rmax)
        :right :| 0
        :left  :| qmax
        :below :/ 0
        :above :/ rmax
        :below :\ (// qmax 2)
        :above :\ (- (// rmax 2))]
     on-map? (line-area on-map)
     hexes []]
    (for [r 0 rmax 1]
      (tset hexes r [])
      (for [q 0 qmax 1]
        (hset hexes [q r]
              (if (on-map? [q r]) :flat :off-map))))
    {: qmax
     : rmax
     : on-map?
     : hexes
     :half?
       (f-or
         [(line-area
            [:below :- -6
             :right :| 0
             :below :/ 0
             :above :/ (// rmax 2)
             :below :\ (// qmax 2)])
          (line-segment-constraint
            [:/ (// rmax 2)]
            (fn [[q _]] (and (> q 0)
                             (<= q (/ qmax 2)))))])
     :road-origin?
       (line-segment-constraint
            [:/ (// rmax 2)]
            (fn [[q _]] (and (> q 5)
                             (<= q (-> qmax (/ 2) (- 3))))))
     :inner?
       (line-area
         [:below :- -4
          :right :| 2
          :below :/ 2
          :above :/ (-> rmax (// 2) (- 4))
          :below :\ (-> qmax (// 2) (- 2))])
     :for-keep?
       (line-area
         [:below :- -2
          :right :| 4
          :below :/ 4
          :above :/ (// rmax 4)
          :below :\ (-> qmax (// 2) (- 4))])
     :on-border? (line-area-border on-map)}))

(lambda map-neighbors [{: on-map?} crd ?dist]
  (let [dist (or ?dist 1)]
    (->> (neighbors crd dist)
         (filter on-map?))))

(lambda some-hexes [{: qmax : rmax &as map} key]
  (let [result []
        criterium (. map key)]
    (for [r 0 rmax 1]
      (for [q 0 qmax 1]
        (when (criterium [q r])
          (table.insert result [q r]))))
    result))

(lambda symmetric-crd [{: qmax : rmax} crd]
  (symmetric crd [(/ qmax 2) (/ rmax 2)]))

(lambda oddq-bounds [map]
  (let [crds (some-hexes map :on-border?)
        [x0 y0] (. crds 1)]
    (var xmin x0)
    (var xmax x0)
    (var ymin y0)
    (var ymax y0)
    (each [_ v (pairs crds)]
      (let [[x y] (to-oddq v)]
        (if (< x xmin) (set xmin x))
        (if (> x xmax) (set xmax x))
        (if (< y ymin) (set ymin y))
        (if (> y ymax) (set ymax y))))
    [xmin xmax ymin ymax]))

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
 : hmod
 : map-neighbors
 : generate-empty-map
 : oddq-bounds
 }

