(lambda filter [func arr]
  (let [result []]
    (each [_ v (ipairs arr)]
      (if (func v)
        (table.insert result v)))
    result))

(lambda mapv [func arr]
  (let [result []]
    (each [_ v (ipairs arr)]
      (table.insert result (func v)))
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

(lambda f-or [fns]
  (lambda [...]
    (var i 1)
    (var flag false)
    (while (and (not flag)
                (<= i (length fns)))
      (set flag ((. fns i) ...))
      (set i (+ 1 i)))
    flag))

(lambda f-and [fns]
  (lambda [...]
    (var i 1)
    (var flag true)
    (while (and flag (<= i (length fns)))
      (set flag ((. fns i) ...))
      (set i (+ 1 i)))
    flag))

{: filter
 : mapv
 : partition
 : f-or
 : f-and}

