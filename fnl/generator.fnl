(local {: neighbors}
  (if wesnoth.require
    (wesnoth.require :util)
    (require :util)))

(fn generate-map []
  (let [width 32
        height 16
        map {: width : height}
        codes {}]
    (for [i 1 height 1]
      (tset codes i {})
      (for [j 1 (/ width 2) 1]
        (let [rnd (math.random)]
          (if (> rnd 0.975) (tset (. codes i) j "Gs^Vh")
              (> rnd 0.75)  (tset (. codes i) j "Gs^Fds")
              (> rnd 0.5)   (tset (. codes i) j "Gs")
              (tset (. codes i) j "Gg")))))
    (let [x (math.floor (math.random 2 (/ width 4)))
          y (math.floor (math.random 2 (/ height 2)))
          neighbors (neighbors [x y] map)]
      (each [_ [x1 y1] (pairs neighbors)]
        (tset (. codes y1) x1 "Ce"))
      (for [i 0 (- height 1) 1]
        (for [j 0 (- (/ width 2) 1) 1]
          (tset (. codes (- height i)) (- width j)
                (. (. codes (+ i 1)) (+ j 1)))))
      (tset (. codes y) x "1 Ke")
      (tset (. codes (+ (- height y) 1))
            (+ (- width x) 1) "2 Ke")
      (tset map :codes codes)
      map)))

(fn map-to-string [{: width : height &as map}]
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
                      (. (. (. map :codes) i) j))))
      (when (< j (+ width 1))
        (set result (.. result ", "))))
    (set result (.. result "\n")))
  result)

(fn generate-map-string []
  (map-to-string (generate-map)))

{:generate generate-map-string}

