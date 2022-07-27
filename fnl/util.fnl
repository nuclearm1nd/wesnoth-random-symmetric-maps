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

(lambda any? [func arr]
  (var result false)
  (var i 1)
  (while (and (not result)
              (<= i (length arr)))
    (set result (func (. arr i)))
    (set i (+ 1 i)))
  result)

(lambda first [func arr]
  (var result nil)
  (var i 1)
  (while (and (not result)
              (<= i (length arr)))
    (let [item (. arr i)]
      (when (func item)
        (set result item))
      (set i (+ 1 i))))
  result)

{: filter
 : mapv
 : partition
 : f-or
 : f-and
 : any?
 : first
 }

