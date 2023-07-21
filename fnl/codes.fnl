(local codes
  {;;; Special
   :off-map "_off^_usr"

   ;;; First position
   ;; Flat
   :grass "Gg"
   :semi-dry-grass "Gs"
   :dry-grass "Gd"
   :leaf-litter "Gll"
   :dark-dirt "Rb"
   :dirt "Re"
   :dry-dirt "Rd"
   :beach-sand "Ds"
   :desert-sand "Dd"
   :snow "Aa"

   ;; Road
   ; Cobbles
   :cobbles "Rr"
   :gray-cobbles "Rrc"
   :overgrown-cobbles "Rp"
   :icy-cobbles "Rra"
   ; Stone
   :stone-floor "Irs"
   :ancient-stone "Ias"
   :royal-rug "Icr"
   :dark-flagstone "Urb"
   ; Wood
   :wooden-floor "Iwr"
   :old-wooden-floor "Ior"
   :wooden-floor-rug "Icn"

   ;; Hill
   :hill "Hh"
   :dry-hill "Hhd"
   :sand-hill "Hd"
   :snowy-hill "Ha"
   :mountain "Mm"
   :dry-mountain "Md"
   :desert-mountain "Mdd"
   :snowy-mountain "Ms"
   :volcano "Mv"

   ;; Water
   :ford "Wwf"
   :shallow-water "Ww"
   :deep-water "Wo"
   :coastal-reef "Wwr"
   :swamp "Ss"
   :mud "Sm"
   :ice "Ai"

   :gray-shallow-water "Wwg"
   :gray-deep-water "Wog"
   :gray-coastal-reef "Wwrg"

   :tropical-deep-water "Wot"
   :tropical-shallow-water "Wwt"
   :tropical-coastal-reef "Wwrt"

   ;; Castle
   :encampment "Ce"
   :orcish-castle "Co"
   :human-castle "Ch"
   :elven-castle "Cv"
   :dwarven-castle "Cf"
   :troll-encampment "Cte"
   :aquatic-encampment "Cme"
   :aquatic-castle "Cm"
   :desert-castle "Cd"

   :snowy-encampment "Cea"
   :snowy-orcish-castle "Coa"
   :snowy-human-castle "Cha"
   :snowy-elven-castle "Cva"
   :snowy-dwarven-castle "Cfa"

   :ruined-encampment "Cer"
   :ruined-human-castle "Chr"
   :ruined-elven-castle "Cvr"
   :ruined-dwarven-castle "Cfr"
   :ruined-desert-castle "Cdr"

   :sunken-ruined-human-castle "Chw"
   :swamp-ruined-human-castle "Chs"
   :dwarven-underground-castle "Cud"

   ;; Keep
   :encampment-keep "Ke"
   :tall-encampment-keep "Ket"
   :orcish-keep "Ko"
   :human-keep "Kh"
   :elven-keep "Kv"
   :dwarven-keep "Kf"
   :troll-keep "Kte"
   :aquatic-encampment-keep "Kme"
   :aquatic-keep "Km"
   :desert-keep "Kd"

   :snowy-encampment-keep "Kea"
   :snowy-orcish-keep "Koa"
   :snowy-human-keep "Kha"
   :snowy-elven-keep "Kva"
   :snowy-dwarven-keep "Kfa"

   :ruined-encampment-keep "Ker"
   :ruined-human-keep "Khr"
   :ruined-elven-keep "Kvr"
   :ruined-dwarven-keep "Kfr"
   :ruined-desert-keep "Kdr"

   :sunken-ruined-human-keep "Khw"
   :swamp-ruined-human-keep "Khs"
   :dwarven-underground-keep "Kud"

   ;; Cave
   :cave "Uu"
   :earthy-cave "Uue"
   :cave-path "Ur"
   :cave-rug "Urc"
   :cave-rock "Uh"
   :earthy-cave-rock "Uhe"
   :cave-road "Urb"
   :mycelium "Tb"

   ;; Impassable
   :cave-wall "Xu"
   :earthy-cave-wall "Xue"
   :mine-wall "Xuc"
   :straight-mine-wall "Xom"
   :stone-wall "Xos"
   :clean-stone-wall "Xos"
   :green-stone-wall "Xof"
   :white-wall "Xoi"
   :ancient-stone-wall "Xoa"
   :catacombs-wall "Xot"
   :chasm "Qxu"
   :earthy-chasm "Qxe"
   :ethereal-abyss "Qxua"
   :lava-chasm "Qxu"
   :lava "Qlf"

   ;;; Second position
   ;; Village
   :cottage "Vh"
   :snowy-cottage "Vha"
   :ruined-cottage "Vhr"
   :elven-village "Ve"
   :snowy-elven-village "Vea"
   :orcish-village "Vo"
   :snowy-orcish-village "Voa"
   :human-city "Vhc"
   :snowy-human-city "Vhca"
   :ruined-human-city "Vhcr"
   :merfolk-village "Vm"
   :swamp-village "Vhs"
   :stone-village "Vhh"
   :snowy-stone-village "Vhha"
   :ruined-stone-village "Vhhr"
   :dwarven-village "Vud"
   :cave-village "Vu"
   :adobe-village "Vda"
   :ruined-adobe-village "Vdr"
   :desert-tent "Vdt"
   :tent "Vct"
   :tropical-village "Vht"
   :drake-village "Vd"
   :hut "Vc"
   :snowy-hut "Vca"
   :cabin "Vl"
   :snowy-cabin "Vla"
   :igloo "Vaa"

   ;; Forest
   :pine-forest "Fp"
   :snowy-pine-forest "Fpa"
   :forest "Fds"
   :fall-forest "Fdf"
   :winter-forest "Fdw"
   :snowy-forest "Fda"
   :mixed-forest "Fms"
   :fall-mixed-forest "Fmf"
   :winter-mixed-forest "Fmw"
   :snowy-mixed-forest "Fma"
   :great-tree "Fet"
   :snowy-great-tree "Feta"
   :dead-great-tree "Fetd"
   :dead-oak-tree "Feth"
   :tropical-forest "Ft"
   :rainforest "Ftr"
   :palm-forest "Ftd"
   :dense-palm-forest "Ftp"
   :savanna-forest "Fts"

   ;; Beauty
   :water-lilies "Ewl"
   :flowering-water-lilies "Ewf"
   :desert-plants "Edp"
   :desert-boneless-plants "Edpp"
   :mixed-flowers "Efm"
   :sand-drifts "Esd"
   :farmland "Gvs"
   :small-stones "Es"
   :snowbits "Esa"
   :small-mushrooms "Em"
   :mushroom-farm "Emf"
   :windmill "Wm"
   :trash "Edt"
   :remains "Edb"

   ;; Other
   :fungus "Tf"
   :impassable-mountain "Xm"
   :oasis "Do"
   :rubble "Dr"
   :desert-crater "Dc"
   :beam-of-light "li"
   :lit-fungus "Tfi"
   :impassable-overlay "Xo"
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

