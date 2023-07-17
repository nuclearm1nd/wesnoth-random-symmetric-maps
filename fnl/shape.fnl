(local {: filter
        : f-and
        } (wesnoth.require :util))

(local {: connecting-line
        : line-area
        : line-area-border
        : line-constraint
        : line-collection-distance
        : line-distance
        } (wesnoth.require :coord))

(local {: hget
        : hset
        : all-crds
        : some-crds
        } (wesnoth.require :map))

(lambda gen-shape [size]
  (let
    [half?
      (lambda [[q r]]
        (or (<= 1 r)
            (and (= 0 r) (<= 0 q))))
     border-lines
       [:below :- (-> size (+ 1) (* 4) -)
        :above :- (-> size (+ 1) (* 4))
        :right :| (-> size (* 4) -)
        :left  :| (-> size (* 4))
        :below :/ (-> size (* 4) -)
        :above :/ (-> size (* 4))
        :below :\ (-> size (- 1) (* 4))
        :above :\ (-> size (- 1) (* 4) -)
        ]
     on-map? (line-area border-lines false)
     hexes []
     bounds (* size 6)]
    (for [q (- bounds) bounds 1]
      (for [r (- bounds) bounds 1]
        (when (on-map? [q r])
          (hset hexes [q r] {}))))
    (let
      [all-hexes (all-crds hexes)
       dist-from-border (line-collection-distance border-lines)
       dist-from-centerline #(math.abs (line-distance [:/ 0] $))
       border-hexes
         (filter
           (f-and [half?
                   #(>= 1 (dist-from-border $))])
           all-hexes)]
      {: size
       : hexes
       : half?
       : on-map?
       : dist-from-border
       : dist-from-centerline
       :path-origin
         (connecting-line [2 0] [(-> size (- 1) (* 4) (- 2)) 0])
       :lower-path-end
         (filter
           (line-constraint [:\ 0] :below)
           border-hexes)
       :upper-path-end
         (filter
           (line-constraint [:\ 0] :above)
           border-hexes)
      })))

{: gen-shape}

