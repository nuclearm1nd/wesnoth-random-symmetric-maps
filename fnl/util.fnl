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

{: filter
 : mapv}

