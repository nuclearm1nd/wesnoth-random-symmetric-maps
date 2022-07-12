(local codes
  {:village "Gg^Vh"
   :forest "Gg^Fds"
   :flat "Gg"
   :hill "Hh"
   :mountain "Mm"
   :ford "Wwf"
   :shallow-water "Ww"
   :sand "Ds"
   :fungus "Uu^Tf"
   :swamp "Ss"
   :encampment "Ce"
   :keep1 "1 Ke"
   :keep2 "2 Ke"
   :off-map "_off^_usr"})

(local random-landscape-weights
  {:flat 120
   :forest 25
   :hill 10
   :mountain 5
   :ford 10
   :shallow-water 5
   :village 6
   :sand 2
   :fungus 1
   :swamp 1})

(lambda random-hex-gen [weights]
  (var total 0)
  (var gap-table {})
  (each [k v (pairs weights)]
    (for [i 1 v]
      (table.insert gap-table k))
    (set total (+ total v)))
  (lambda []
    (. gap-table (math.random total))))

(lambda mirror-hex [hex]
  (if (= :keep1 hex)
      :keep2
      hex))

{: codes
 : random-hex-gen
 : random-landscape-weights
 : mirror-hex}
