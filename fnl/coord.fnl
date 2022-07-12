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

{: union
 : difference}

