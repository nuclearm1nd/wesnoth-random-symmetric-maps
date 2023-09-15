(local
  {: draw-random
   } (wesnoth.require :util))

(local
  {: random-hex-gen
   } (wesnoth.require :codes))

(lambda tracked-chooser [chooser]
  (let [tracked-tbl {}]
    (lambda [index]
      (let [tile (?. tracked-tbl index)]
        (if tile
          tile
          (let [new-tile (chooser)]
            (tset tracked-tbl index new-tile)
            new-tile))))))

(lambda get-chooser []
  (let [impassable-tbl {}
        impassable-tracked-chooser
          (tracked-chooser
            (random-hex-gen
              {[:cave-wall] 2
               [:mine-wall] 1
               [:ancient-stone-wall] 1
               [:green-stone-wall] 1}))
        road-tracked-chooser
          (tracked-chooser
            (random-hex-gen
              {[:ancient-stone] 2
               [:cobbles] 1
               [:overgrown-cobbles] 1}))
        difficult-water-chooser
          (random-hex-gen
            {[:shallow-water] 1
             [:swamp] 3
             [:coastal-reef] 3
             [:swamp :fungus] 1})
        easy-water-chooser
          (random-hex-gen
            {[:ford] 5
             [:swamp] 1
             [:coastal-reef] 1})
        difficult-terrain-chooser
          (random-hex-gen
            {[:dirt :fungus] 2
             [:dry-dirt :fungus] 2
             [:dirt :winter-forest] 2
             [:leaf-litter :winter-forest] 2
             [:dry-dirt :winter-forest] 2
             [:leaf-litter :fall-forest] 2
             [:dry-hill] 4
             [:dry-hill :winter-forest] 1
             [:dry-hill :pine-forest] 2
             [:dry-hill :fall-mixed-forest] 1
             [:dry-mountain] 3})
        flat-terrain-chooser
          (random-hex-gen
            {[:cave-path] 1
             [:dirt] 3
             [:dry-dirt] 3
             [:leaf-litter] 2})]
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
              (impassable-tracked-chooser impassable))
          village
            (if
              water
                (if difficult
                  [:shallow-water :merfolk-village]
                  (draw-random [[:swamp :swamp-village]
                                [:ford :merfolk-village]]))
              road
                [:ancient-stone :human-city]
              difficult
                [:dry-hill :stone-village]
              (draw-random [[:dirt :cottage]
                            [:dry-dirt :ruined-cottage]
                            [:dry-dirt :tent]
                            [:leaf-litter :cabin]]))
          (and road water)
            [:ford]
          road
            (road-tracked-chooser road)
          water
            (if difficult
              (difficult-water-chooser)
              (easy-water-chooser))
          (if difficult
            (difficult-terrain-chooser)
            (flat-terrain-chooser)))))))

{: get-chooser
 }

