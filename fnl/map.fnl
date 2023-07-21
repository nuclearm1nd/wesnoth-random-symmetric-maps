(import-macros {: <<- : if-not} "../macro/macros")

(local {: merge!
        : mapv
        } (wesnoth.require :util))

(local {: to-axial
        : to-oddq
        } (wesnoth.require :coord))

(local {: codes
        } (wesnoth.require :codes))

(lambda hget [hexes [q r]]
  (-> hexes (?. r) (?. q)))

(lambda hset [hexes [q r] value]
  (when (not (?. hexes r))
    (tset hexes r []))
  (tset (. hexes r) q value))

(lambda hmod [hexes crd func]
  (->> (hget hexes crd)
       func
       (hset hexes crd)))

(lambda hmerge [hexes crd tbl]
  (let [hex (hget hexes crd)]
    (if hex
      (merge! hex tbl)
      (hset hexes crd (merge! {} tbl)))))

(lambda some-crds [criterium hexes]
  (let [result []]
    (each [r row (pairs hexes)]
      (each [q _ (pairs row)]
        (let [crd [q r]]
          (when (criterium crd)
                (table.insert result crd)))))
    result))

(local all-crds
  (partial some-crds #true))

(lambda oddq-bounds [hexes]
  (var xmin 0)
  (var xmax 0)
  (var ymin 0)
  (var ymax 0)
  (each [_ v (ipairs (all-crds hexes))]
    (let [[x y] (to-oddq v)]
      (if (< x xmin) (set xmin x))
      (if (> x xmax) (set xmax x))
      (if (< y ymin) (set ymin y))
      (if (> y ymax) (set ymax y))))
  [(if (-> xmin (% 2) (= 0))
     xmin
     (- xmin 1))
   (if (-> xmax (% 2) (= 0))
     xmax
     (+ xmax 1))
   (- ymin 1)
   (+ ymax 1)])

(lambda tile-to-code [tile]
  (if-not tile (. codes :off-map)
    (table.concat
      (mapv #(. codes $) tile)
      "^")))

(lambda to-wesnoth-map-csv [hexes]
  (var result "")
  (let [[xmin xmax ymin ymax] (oddq-bounds hexes)
        off-map (. codes :off-map)
        add (lambda [val]
              (set result (.. result val)))
        get-code
          (lambda [crd]
            (<<-
              (let [hex (hget hexes crd)])
              (if-not hex off-map)
              (let [{: tile : player} hex])
              (if-not tile off-map)
              (let [code (tile-to-code tile)])
              (if-not player code)
              (.. player " " code)))]
    (for [y ymin ymax 1]
      (for [x xmin xmax 1]
        (-> [x y] to-axial get-code add)
        (when (< x xmax)
          (add ", ")))
      (add "\n"))
    result))

{: hget
 : hset
 : hmod
 : hmerge
 : all-crds
 : some-crds
 : oddq-bounds
 : to-wesnoth-map-csv
 }

