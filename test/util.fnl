(fn test [name ...]
  `(global ,(->>
              (. name 1)
              (.. "test")
              sym)
     (fn []
       ,(table.unpack [...]))))

(fn to-test-pairs [test-fn ...]
  (var tmp nil)
  (let [result []]
    (each [i m (ipairs [...])]
      (if (= 1 (% i 2))
          (set tmp `(,test-fn ,m))
          (do
            (table.insert tmp m)
            (table.insert result tmp))))
    `(do ,(table.unpack result))))

{: test
 : to-test-pairs}

