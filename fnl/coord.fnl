(local {: mapv
        : partition
        : f-and
        } (wesnoth.require :util))

(macro if= [v ...]
  (let [result []]
    (each [i m (ipairs [...])]
      (if (= 1 (% i 2))
          (table.insert result `(= ,v ,m))
          (table.insert result m)))
    `(if ,(table.unpack result))))

(macro or= [v ...]
  (let [result []]
    (each [_ m (ipairs [...])]
      (table.insert result `(= ,v ,m)))
    `(or ,(table.unpack result))))

(lambda sign [x]
  (if (= 0 x) 0
      (> 0 x) -1
      1))

(local coord-meta
  {"__eq" (fn [[x1 y1] [x2 y2]]
            (and (= x1 x2)
                 (= y1 y2)))})

(lambda to-set [coord-array]
  (let [result {}]
    (each [_ [x y] (ipairs coord-array)]
      (tset result (string.pack "jj" x y) true))
    result))

(lambda to-array [coord-set]
  (let [result []]
    (each [k _ (pairs coord-set)]
      (let [(x y) (string.unpack "jj" k)]
        (table.insert result [x y])))
    result))

(lambda union [arr1 arr2]
  (let [set1 (to-set arr1)
        set2 (to-set arr2)]
    (each [k _ (pairs set2)]
      (tset set1 k true))
    (to-array set1)))

(lambda difference [arr1 arr2]
  (let [set1 (to-set arr1)
        set2 (to-set arr2)]
    (each [k _ (pairs set2)]
      (tset set1 k nil))
    (to-array set1)))

(lambda to-axial [[x y] ?origin]
  (let [[x0 y0] (or ?origin [0 0])
        q (- x x0)]
    [q (-> y (- y0) (+ (// q 2)))]))

(lambda to-oddq [[q r] ?origin]
  (let [[q0 r0] (or ?origin [0 0])
        x (- q q0)]
    [x (- r r0 (// x 2))]))

(lambda to-new-origin [[q r] [qo ro]]
  [(- q qo)
   (- r ro)])

(lambda symmetric [[q r] ?origin]
  (if (not ?origin)
      [(- q) (- r)]
      (let [[qo ro] ?origin]
        (-> [q r]
            (to-new-origin [qo ro])
            symmetric
            (to-new-origin [(- qo) (- ro)])))))

(lambda distance [[q0 r0] ?crd1]
  (let [[q1 r1] (or ?crd1 [0 0])
        q (- q0 q1)
        r (- r0 r1)]
    (// (+ (math.abs q)
           (math.abs r)
           (math.abs (- q r)))
        2)))

(lambda point-zone-factory [criterium [q r] ?distance]
  (let [dist (or ?distance 1)
        result []
        add (lambda [crd] (table.insert result crd))]
   (for [dq (- dist) dist 1]
     (for [dr (- dist) dist 1]
       (let [crd [(+ q dq) (+ r dr)]
             dst (distance crd [q r])]
         (when (criterium dist dst)
           (add crd)))))
    result))

(local neighbors
  (partial point-zone-factory
    (lambda [max-dist dist]
      (and (> dist 0)
           (<= dist max-dist)))))

(local zone
  (partial point-zone-factory
    (lambda [max-dist dist]
      (<= dist max-dist))))

(lambda line-distance [[line-type constant] [q r]]
  (if
    (or= line-type :horizontal :-)
      (let [x (- (* 2 r) q constant)]
        (* (sign x)
           (-> (math.abs x) (+ 1) (// 2))))

    (or= line-type :vertical :|)
      (- q constant)

    (or= line-type :incline-right :/)
      (- r constant)

    (or= line-type :incline-left :\)
      (- q r constant)))

(lambda line-distance-constraint [line-def dist-fn]
  (lambda [crd]
    (dist-fn (line-distance line-def crd))))

(lambda line-constraint [[line-type constant] direction ?inclusive]
  (let [inclusive (or false ?inclusive)
        gt0 (if inclusive #(>= $1 0) #(> $1 0))
        lt0 (if inclusive #(<= $1 0) #(< $1 0))
        gen (partial line-distance-constraint [line-type constant])
        err #(error
               (string.format "invalid line-type/distance combo %s %s"
                              line-type
                              direction))]
    (if= direction
         :on (gen #(= $1 0))
         :+ (gen gt0)
         :- (gen lt0)
         :below (if (or= line-type :incline-left :\)
                      (gen lt0)
                    (or= line-type :incline-right :/ :horizontal :-)
                      (gen gt0)
                    (err))
         :above (if (or= line-type :\ :incline-left)
                      (gen gt0)
                    (or= line-type :incline-right :/ :horizontal :-)
                      (gen lt0)
                    (err))
         :right (if (or= line-type :vertical :|
                                   :incline-left :\
                                   :incline-right :/)
                      (gen gt0)
                      (err))
         :left  (if (or= line-type :vertical :|
                                   :incline-left :\
                                   :incline-right :/)
                      (gen lt0)
                      (err)))))

(lambda line-area [line-defs ?inclusive]
  (->> line-defs
       (partition 3)
       (mapv
         (lambda [[directon line-type constant]]
           (line-constraint [line-type constant] directon ?inclusive)))
       f-and))

(lambda line-area-border [line-defs]
  (let [including (line-area line-defs true)
        excluding (line-area line-defs false)]
    (lambda [crd]
      (and (including crd)
           (not (excluding crd))))))

{: union
 : difference
 : to-oddq
 : to-axial
 : to-new-origin
 : symmetric
 : distance
 : neighbors
 : zone
 : line-distance
 : line-distance-constraint
 : line-constraint
 : line-area
 : line-area-border
}

