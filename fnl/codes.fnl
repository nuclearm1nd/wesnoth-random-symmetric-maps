(local codes
  {:village "Gg^Vh"
   :forest "Gg^Fds"
   :grass "Gg"
   :hill "Hh"
   :hill-forest "Hh^Fp"
   :dry-hill "Hhd"
   :dry-hill-forest "Hhd^Fdw"
   :mountain "Mm"
   :impassable-mountain "Mm^Xm"
   :ford "Wwf"
   :shallow-water "Ww"
   :deep-water "Wo"
   :coastal-reef "Wwr"
   :sand "Ds"
   :fungus "Gg^Tf"
   :hill-fungus "Hh^Tf"
   :swamp "Ss"
   :swamp-mushroom "Ss^Tf"
   :mud "Sm"
   :encampment "Ce"
   :keep1 "1 Ke"
   :keep2 "2 Ke"
   :off-map "_off^_usr"
   :cobbles "Rp"
   :cave-wall "Xu"
   :mine-wall "Xuc"
   :ancient-stone-wall "Xoa"
   :cave-floor "Uu"
   :cave-path "Ur"
   :cave-rock "Uh"
   :cave-road "Urb"
   :cave-mushroom "Uu^Tf"
   :cave-forest "Ur^Fdw"
   :chasm "Qxu"
   :ancient-stone "Ias"
   :regular-dirt "Re"
   :dry-dirt "Rd"})

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
 : mirror-hex
 }

