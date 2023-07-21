(local
  {: draw-random
   } (wesnoth.require :util))

(local
  {: random-hex-gen
   } (wesnoth.require :codes))

(lambda get-chooser []
  (let [impassable-tbl {}
        impassable-chooser
          (random-hex-gen
            {[:cave-wall] 2
             [:mine-wall] 1
             [:ancient-stone-wall] 1})
        difficult-water-chooser
          (random-hex-gen
            {[:shallow-water] 1
             [:swamp] 2
             [:coastal-reef] 1
             [:swamp :fungus] 2})
        easy-water-chooser
          (random-hex-gen
            {[:ford] 3
             [:swamp] 2
             [:coastal-reef] 1})
        difficult-terrain-chooser
          (random-hex-gen
            {[:cave] 3
             [:cave-rock] 2
             [:cave :fungus] 1
             [:dirt :fungus] 1
             [:dry-dirt :fungus] 1
             [:cave :winter-forest] 1
             [:dirt :winter-forest] 1
             [:dry-dirt :winter-forest] 1
             [:leaf-litter :fall-forest] 1
             [:dry-hill] 3
             [:dry-hill :winter-forest] 1
             [:dry-hill :pine-forest] 1
             [:dry-hill :fall-mixed-forest] 1})
        flat-terrain-chooser
          (random-hex-gen
            {[:cave-path] 1
             [:dirt] 2
             [:dry-dirt] 2
             [:leaf-litter] 1})]
    (lambda [hex]
      (let [{: impassable : water : road : village
             : difficult : keep : castle} hex]
        (if
          keep
            [:ruined-human-keep]
          castle
            (if water
              [:sunken-ruined-human-castle]
              [:ruined-human-castle])
          impassable
            (if water
              [:deep-water]
              (let [tile (?. impassable-tbl impassable)]
                (if tile
                  tile
                  (let [new-tile (impassable-chooser)]
                    (tset impassable-tbl impassable new-tile)
                    new-tile))))
          village
            (if
              water
                (if difficult
                  [:deep-water :merfolk-village]
                  (draw-random [[:swamp :swamp-village]
                                [:ford :merfolk-village]]))
              road
                [:ancient-stone :human-city]
              difficult
                (draw-random [[:cave :cave-village]
                              [:dry-hill :stone-village]])
              [:dry-dirt :cottage])
          (and road water)
            [:ford]
          road
            [:ancient-stone]
          water
            (if difficult
              (difficult-water-chooser)
              (easy-water-chooser))
          (if difficult
            (difficult-terrain-chooser)
            (flat-terrain-chooser)))))))

{: get-chooser
 }

