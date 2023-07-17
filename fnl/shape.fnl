(local {: filter
        } (wesnoth.require :util))

(local {: connecting-line
        : line-area
        } (wesnoth.require :coord))

(local {: hget
        : hset
        : all-crds
        : some-crds
        } (wesnoth.require :map))

(lambda gen-shape []
  (let
    [half?
      (lambda [[q r]]
        (or (<= 1 r)
            (and (= 0 r) (<= 0 q))))
     on-map?
       (line-area
         [:below :- -24
          :above :-  24
          :right :| -20
          :left  :|  20
          :below :/ -20
          :above :/  20
          :below :\  16
          :above :\ -16
          ])
     hexes []]
    (for [q -32 32 1]
      (for [r -32 32 1]
        (when (on-map? [q r])
          (hset hexes [q r] {}))))
    {: hexes
     : half?
     : on-map?
     :path-origin
       (connecting-line [2 0] [10 0])
     :path-end
       (filter on-map?
         (connecting-line [1 12] [7 15]))
     :symmetric-path-end
       (connecting-line [15 4] [15 15])}))

{: gen-shape}

