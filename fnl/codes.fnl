(local codes
  {:village "Gg^Vh"
   :forest "Gg^Fds"
   :flat "Gg"
   :hill "Hh"
   :hill-forest "Hh^Fp"
   :mountain "Mm"
   :impassable-mountain "Mm^Xm"
   :ford "Wwf"
   :shallow-water "Ww"
   :coastal-reef "Wwr"
   :sand "Ds"
   :fungus "Gg^Tf"
   :hill-fungus "Hh^Tf"
   :swamp "Ss"
   :mud "Sm"
   :encampment "Ce"
   :keep1 "1 Ke"
   :keep2 "2 Ke"
   :off-map "_off^_usr"
   :cobbles "Rp"})

(local random-landscape-weights
  {:flat 120
   :forest 25
   :hill 10
   :hill-forest 10
   :mountain 5
   ;:sand 2
   :fungus 1
   :hill-fungus 1
   })

(local water-features-weights
  {:ford 120
   :shallow-water 20
   :coastal-reef 5})

(local coast-features-weights
  {:skip 120
   :mud 5
   :swamp 5
   :sand 5})

(lambda random-hex-gen [weights]
  (var gap-table [])
  (each [k v (pairs weights)]
    (for [i 1 v]
      (table.insert gap-table k)))
  (lambda []
    (. gap-table (math.random (length gap-table)))))

(lambda mirror-hex [hex]
  (if (= :keep1 hex)
      :keep2
      hex))

{: codes
 : random-hex-gen
 : random-landscape-weights
 : water-features-weights
 : coast-features-weights
 : mirror-hex}

