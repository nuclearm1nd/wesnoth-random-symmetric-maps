(local codes
  {
   ;;; Special
   :off-map "_off^_usr"

   ;;; First position
   ;; Flat
   :grass "Gg"
   :dry-grass "Gd"
   :dirt "Re"
   :dry-dirt "Rd"
   :sand "Ds"

   ;; Road
   :cobbles "Rp"
   :ancient-stone "Ias"

   ;; Hill
   :hill "Hh"
   :dry-hill "Hhd"
   :mountain "Mm"

   ;; Water
   :ford "Wwf"
   :shallow-water "Ww"
   :deep-water "Wo"
   :coastal-reef "Wwr"
   :swamp "Ss"
   :mud "Sm"

   ;; Castle
   :encampment "Ce"
   :human-ruined-castle "Chr"
   :sunken-human-ruined-castle "Chw"
   :swamp-human-ruined-castle "Chs"

   ;; Keep
   :encampment-keep "Ke"
   :human-ruined-keep "Khr"
   :sunken-human-ruined-keep "Khw"
   :swamp-human-ruined-keep "Khs"

   ;; Cave
   :cave "Uu"
   :cave-path "Ur"
   :cave-rock "Uh"
   :cave-road "Urb"

   ;; Impassable
   :cave-wall "Xu"
   :mine-wall "Xuc"
   :ancient-stone-wall "Xoa"
   :chasm "Qxu"

   ;;; Second position
   ;; Village
   :cottage "Vh"
   :human-city "Vhc"
   :merfolk-village "Vm"
   :swamp-village "Vhs"
   :stone-village "Vhh"
   :dwarven-village "Vud"
   :cave-village "Vu"

   ;; Forest
   :forest "Fds"
   :pine-forest "Fp"
   :fall-forest "Fdf"
   :winter-forest "Fdw"

   ;; Other
   :fungus "Tf"
   :impassable-mountain "Xm"
   })

(lambda random-hex-gen [weights]
  (var acc 0)
  (var weight-tbl [])
  (each [tile prob (pairs weights)]
    (set acc (+ prob acc))
    (table.insert weight-tbl [acc tile]))
  (lambda []
    (var result nil)
    (let [rnd (math.random acc)]
      (each [_ [idx tile] (ipairs weight-tbl) &until result]
        (if (<= rnd idx)
          (set result tile))))
    result))

{: codes
 : random-hex-gen
 }

