(lambda mapv [func arr]
  (let [result []]
    (each [_ v (ipairs arr)]
      (table.insert result (func v)))
    result))

(lambda reverse [arr]
  (let [result []]
    (each [_ v (ipairs arr)]
      (table.insert result 1 v))
  result))

(fn if= [v ...]
  `(let [v# ,v]
     (if
       ,(let [result []
              add #(table.insert result $)]
          (each [i m (ipairs [...])]
            (if (= 1 (% i 2))
                (add `(= v# ,m))
                (add m)))
          (table.unpack result)))))

(fn in [v ...]
  `(let [val# ,v]
     (or
       ,(table.unpack
         (mapv (fn [x] `(= val# ,x)) [...])))))

(fn set-methods [t ...]
  (let [result []]
    (each [_ m (ipairs [...])]
      (table.insert result
        `(tset ,t ,(tostring m) (partial ,m ,t))))
    `(do ,(table.unpack result))))

(fn <<- [...]
  `(->> ,(table.unpack (reverse [...]))))

{: if=
 : in
 : set-methods
 : <<-
}

