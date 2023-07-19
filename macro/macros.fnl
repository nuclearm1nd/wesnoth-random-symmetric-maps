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

(lambda partition [size items]
  (var part nil)
  (let [result []]
    (each [i v (ipairs items)]
      (if (= 1 (% i size))
        (set part [v])
        (table.insert part v))
      (if (= 0 (% i size))
        (table.insert result part)))
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

(fn code-traverse [f]
  (fn recur [exprn]
    (if (not (list? exprn))
      (f exprn)
      (->> exprn
        (mapv recur)
        table.unpack
        list))))

(fn as-> [name init ...]
  (var cur-gensym (gensym))
  (let [result [cur-gensym init]
        swapper (code-traverse #(if (= $ name) cur-gensym $))]
    (each [_ expr (ipairs [...])]
      (let [new-gensym (gensym)]
        (table.insert result new-gensym)
        (table.insert result (swapper expr))
        (set cur-gensym new-gensym)))
    `(let ,result ,cur-gensym)))

(fn array-> [name init ...]
  (var cur-gensym (gensym))
  (let [lets [cur-gensym init]
        array [cur-gensym]
        swapper (code-traverse #(if (= $ name) cur-gensym $))]
    (each [_ expr (ipairs [...])]
      (let [new-gensym (gensym)]
        (table.insert lets new-gensym)
        (table.insert lets (swapper expr))
        (table.insert array new-gensym)
        (set cur-gensym new-gensym)))
    `(let ,lets ,array)))

(fn cond-> [name init ...]
  (assert (-> [...] length (% 2) (= 0))
          "Even number of forms expected")
  (var cur-gensym (gensym))
  (let [lets [cur-gensym init]
        swapper (code-traverse #(if (= $ name) cur-gensym $))]
    (each [_ [cond expr] (ipairs (partition 2 [...]))]
      (let [new-gensym (gensym)]
        (table.insert lets new-gensym)
        (table.insert lets `(if ,(swapper cond)
                                ,(swapper expr)
                                ,cur-gensym))
        (set cur-gensym new-gensym)))
    `(let ,lets ,cur-gensym)))

(fn groupwise [size inner outer ...]
  (let [result []]
    (each [_ group (ipairs (partition size [...]))]
      (table.insert result `(,inner ,(table.unpack group))))
    `(,outer
       ,(table.unpack result))))

(local pairwise
  (partial groupwise 2))

(fn early [cond res]
  (let [g (gensym)]
    `(when ,cond
       (let [,g ,res]
         (lua ,(.. "return " (tostring g)))))))

(fn if-not [cond A B]
  `(if ,cond ,B ,A))

{: if=
 : in
 : set-methods
 : <<-
 : as->
 : array->
 : cond->
 : groupwise
 : pairwise
 : early
 : if-not
 }

