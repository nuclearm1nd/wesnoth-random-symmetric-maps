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
            {:cave-wall 2
             :mine-wall 1
             :ancient-stone-wall 1})
        difficult-water-chooser
          (random-hex-gen
            {:shallow-water 1
             :swamp 2
             :coastal-reef 1
             :swamp-mushroom 2})
        easy-water-chooser
          (random-hex-gen
            {:ford 3
             :swamp 2
             :coastal-reef 1})
        difficult-terrain-chooser
          (random-hex-gen
            {:cave-floor 3
             :cave-rock 2
             :cave-mushroom 1
             :cave-forest 3
             :dry-hill 3
             :dry-hill-forest 1})
        flat-terrain-chooser
          (random-hex-gen
            {:cave-path 1
             :regular-dirt 2
             :dry-dirt 2})]
    (lambda [hex]
      (let [{: impassable : water : road : village
             : difficult : keep : castle} hex]
        (if
          keep
            :human-ruined-keep
          castle
            (if water
              :sunken-human-ruined-castle
              :human-ruined-castle)
          impassable
            (if water
              :deep-water
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
                  :merfolk-village
                  (draw-random [:swamp-village :ford-merfolk-village]))
              road
                :ancient-stone-human-city
              difficult
                (draw-random [:cave-village :dry-hill-stone-village])
              :dry-cottage)
          (and road water)
            :ford
          road
            :ancient-stone
          water
            (if difficult
              (difficult-water-chooser)
              (easy-water-chooser))
          (if difficult
            (difficult-terrain-chooser)
            (flat-terrain-chooser)))))))

{: get-chooser
 }

