(lambda filter [func arr]
  (icollect [_ v (ipairs arr)]
    (if (func v)
      v)))

(lambda remove-at-idx [idx arr]
  (icollect [i v (ipairs arr)]
    (if (~= i idx)
      v)))

(lambda mapv [func arr]
  (icollect [_ v (ipairs arr)]
    (func v)))

(lambda mapv-indexed [func arr]
  (icollect [i v (ipairs arr)]
    (func i v)))

(lambda reduce [init f coll]
  (var result init)
  (each [_ v (ipairs coll)]
    (set result (f result v)))
  result)

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

(lambda reverse [arr]
  (let [result []]
    (each [_ v (ipairs arr)]
      (table.insert result 1 v))
  result))

(lambda round [x]
  (let [fl (math.floor x)
        cl (math.ceil x)]
    (if (< (math.abs (- x fl))
           (math.abs (- x cl)))
      fl
      cl)))

(lambda couples [arr]
  (assert (<= 2 (length arr)))
  (var i 1)
  (let [result []
        get #(. arr $)
        add #(table.insert result $)]
    (while (<= (+ 1 i) (length arr))
      (add [(get i) (get (+ 1 i))])
      (set i (+ 1 i)))
    result))

(lambda negate [f]
  (lambda [...]
    (not (f ...))))

(lambda keys [tbl]
  (icollect [key _ (pairs tbl)]
    key))

(lambda every [f arr]
  (accumulate [result true
               _ v (ipairs arr)
               &until (not result)]
    (and result (f v))))

(lambda every-key [f tbl]
  (accumulate [result true
               k _ (pairs tbl)
               &until (not result)]
    (and result (f k))))

(lambda merge! [t1 t2]
  (each [k v (pairs t2)]
    (tset t1 k v))
  t1)

(lambda draw-random [t]
  (. t (math.random (length t))))

(lambda div [x y]
  (-> x
      (- (math.fmod x y))
      (/ y)))

{: filter
 : remove-at-idx
 : mapv
 : mapv-indexed
 : reduce
 : partition
 : f-or
 : f-and
 : any?
 : first
 : reverse
 : round
 : couples
 : negate
 : keys
 : every
 : every-key
 : merge!
 : draw-random
 : div
 }

