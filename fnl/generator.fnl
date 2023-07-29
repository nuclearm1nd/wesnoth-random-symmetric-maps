(import-macros
  {: <<-
   : in
   : as->
   : if=
   : if-not
   : inc!
   } "../macro/macros")

(local
  {: filter
   : remove-at-idx
   : first
   : couples
   : round
   : f-and
   : mapv
   : mapv-indexed
   : reduce
   : merge!
   : draw-random
   } (wesnoth.require :util))

(local
  {: difference
   : union
   : union!
   : distance
   : zone
   : belt
   : connecting-line
   : midpoint
   : neighbors
   : coll-neighbors
   : symmetric
   : line-area
   : to-set
   : to-array
   } (wesnoth.require :coord))

(local
  {: hget
   : hset
   : hmerge
   : all-crds
   : some-crds
   : to-wesnoth-map-csv
   } (wesnoth.require :map))

(local
  {: gen-shape
   } (wesnoth.require :shape))

(local
  {: get-chooser
   } (wesnoth.require :theme))

(lambda symmetrize-map [{: hexes : half? &as map}]
  (each [_ crd (ipairs (some-crds half? hexes))]
    (let [hex (hget hexes crd)
          {: player} hex
          sym (symmetric crd)]
      (hmerge hexes sym hex)
      (when player
        (hmerge hexes sym {:player 2}))))
  map)

(lambda to-csv [{: hexes}]
  (to-wesnoth-map-csv hexes))

(lambda set-helpers [{: hexes : half? : on-map? &as map}]
  (merge! map
    {:map-coll-nhbrs
       #(filter (f-and [half? on-map?])
                (coll-neighbors $1 $2))
     :set-tile
       #(hmerge hexes $1 {:tile $2})
     :hex
       #(hget hexes $1)
    })
  map)

(lambda midpoint-displacement
  [initial-crd
   destination-crd
   {: map-neighbors
    : ?iterations
    : ?distance-func}]
  (var points [initial-crd destination-crd])
  (let [iter (or ?iterations 3)
        df (or ?distance-func #(- 5 $))]
    (for [i 1 iter 1]
      (let [acc [(. points 1)]
            add #(table.insert acc $)]
        (each [_ [crd1 crd2] (ipairs (couples points))]
          (let [mid (midpoint crd1 crd2)
                displaced
                  (difference
                    (map-neighbors mid (df i))
                    (connecting-line crd1 crd2))]
            (assert
              (< 0 (length displaced))
              "No suitable candidate for displaced point")
            (add (draw-random displaced))
            (add crd2)))
        (set points acc))))
  points)

(lambda path-straight
  [crd1 crd2 f ?constraint]
  (let [constraint (or ?constraint #true)]
    (each [_ crd (ipairs (connecting-line crd1 crd2))]
     (when (constraint crd)
       (f crd)))))

(lambda path-midpoint-displacement
  [initial-crd
   destination-crd
   {: map-neighbors
    : f
    : ?constraint
    : ?iterations
    : ?distance-func}]
  (each [_ [crd1 crd2]
           (->> (midpoint-displacement initial-crd destination-crd
                                       {: map-neighbors : ?iterations : ?distance-func})
                couples
                ipairs)]
    (path-straight crd1 crd2 f ?constraint)))

(lambda path-seek
  [origin
   end
   {: map-neighbors
    : f
    : ?constraint}]
  (var finished false)
  (var current origin)
  (let [visited {}
        constraint (or ?constraint #true)
        weighted-random
          (fn [dist nhbrs]
            (let [rndt []]
              (each [_ new-crd (ipairs nhbrs)]
                (let [new-dist (distance new-crd end)
                      cnt (if (< new-dist dist) 16
                              (= new-dist dist) 4
                              1)]
                  (for [i 1 cnt 1]
                    (table.insert rndt new-crd))))
              (draw-random rndt)))
          stack []
          push #(table.insert stack $)
          pop #(table.remove stack)]
    (while (not finished)
      (union! visited [current])
      (let [dist (distance current end)]
        (if (= 0 dist)
          (do
            (push current)
            (set finished true))
          (let [nhbrs (difference
                        (filter constraint (map-neighbors current 1))
                        visited)]
            (if (= 0 (length nhbrs))
              (if (= 0 (length stack))
                (set finished true)
                (set current (pop)))
              (do
                (push current)
                (set current (weighted-random dist nhbrs))))))))
    (each [_ crd (ipairs stack)]
      (f crd))))

(lambda gen-patch [{: hexes : half? : on-map? : map-coll-nhbrs &as map}
                   {: min-size : max-size : spacing : f : ?exclude}]
  (var patch-idx 1)
  (let [exclude (if-not ?exclude #false
                  (partial ?exclude map))
        taken (->> (some-crds half? hexes)
                   (filter exclude)
                   to-set)]
    (var free (difference
                (some-crds half? hexes)
                taken))
    (while (< 0 (length free))
      (let [to-take (math.min (length free)
                              (math.random min-size max-size))
            start (draw-random free)
            cluster [start]]
        (for [i 1 (- to-take 1)]
          (let [available
                  (difference
                    (map-coll-nhbrs cluster)
                    taken)
                new (draw-random available)]
            (table.insert cluster new)))
        (each [_ crd (ipairs cluster)]
          (f hexes crd patch-idx))
        (inc! patch-idx)
        (let [new-taken (union cluster
                          (coll-neighbors cluster spacing)
                          (coll-neighbors
                            (mapv symmetric cluster)
                            spacing))]
          (union! taken new-taken)
          (set free (difference free new-taken))))))
  map)

(lambda gen-path [{: hexes : half? : on-map? &as map}
                  {: algorithm : origin-f : end-f : f
                   : ?iterations : ?distance-func : ?constraint}]
  (let [origin (origin-f map)
        end (end-f map)]
    (when (and origin end)
      (let [map-neighbors
              #(filter (f-and [half? on-map?])
                       (neighbors $1 $2))
            inner-f (partial f hexes)
            constraint
              (if-not ?constraint #true
                (partial ?constraint map))
            path-f (if= algorithm
                     :seek path-seek
                     :midpoint-displacement path-midpoint-displacement
                     (error (.. "unknown path algorithm " algorithm)))]
        (path-f
          origin
          end
          {: map-neighbors
           :f inner-f
           :?constraint constraint
           : ?iterations
           : ?distance-func}))))
  map)

(lambda place-keep [{: hexes : half? : size : map-coll-nhbrs
                     : dist-from-border : dist-from-centerline &as map}
                    {: ?keepsize-f : ?impassable-gap : ?border-distance
                     : ?centerline-distance-f : ?difficult-gap}]
  (let [keepsize-f (or ?keepsize-f #(+ 1 $))
        centerline-distance-f (or ?centerline-distance-f #(* $ 2))
        impassable-gap (or ?impassable-gap 2)
        difficult-gap (or ?difficult-gap 1)
        border-distance (or ?border-distance 2)
        constraint (f-and [#(< border-distance (dist-from-border $))
                           #(< (centerline-distance-f size) (dist-from-centerline $))])
        eligible
          (->> (some-crds half? hexes)
               (filter constraint))
        keep (draw-random eligible)]
    (hmerge hexes keep {:keep 1 :player 1})
    (let [cluster [keep]]
      (for [i 1 (keepsize-f size)]
        (let [available
                (filter constraint
                  (map-coll-nhbrs cluster))
              new (draw-random available)]
          (table.insert cluster new)
          (hmerge hexes new {:castle 1})))
      (each [_ crd (ipairs (map-coll-nhbrs cluster impassable-gap))]
        (hmerge hexes crd {:no-impassable true}))
      (each [_ crd (ipairs (map-coll-nhbrs cluster difficult-gap))]
        (hmerge hexes crd {:no-difficult true}))))
  map)

(lambda estimate-distance-from-keep [{: hexes : half? : map-coll-nhbrs : hex &as map}]
  (var i 0)
  (let [start-location (first
                         #(?. (hget hexes $) :player)
                         (some-crds half? hexes))
        visited (to-set [start-location])
        distances {0 [start-location]}
        add (lambda [dist crd]
              (let [coll (?. distances dist)]
                (if coll
                  (table.insert coll crd)
                  (tset distances dist [crd]))))
        loop-cond
          (fn []
            (var cond false)
            (each [k _ (pairs distances) &until cond]
             (set cond (>= k i)))
            cond)
        join-distances
          (lambda [arr]
            (let [result (to-set [])]
              (each [_ idx (ipairs arr)]
                (when (?. distances idx)
                  (union! result (. distances idx))))
              (to-array result)))]
    (while (loop-cond)
      (when (?. distances i)
        (let [items (-> (. distances i)
                        map-coll-nhbrs
                        (difference visited))]
          (each [_ crd (ipairs items)]
            (let [{: impassable : water : difficult} (hex crd)]
              (when (not impassable)
                (if difficult
                  (add (+ 2 i) crd)
                  (add (+ 1 i) crd)))))
          (union! visited items)))
      (inc! i))
    (tset map :est-dists distances)
    (tset map :join-distances join-distances))
  map)

(lambda place-forward-keeps [{: hexes : map-coll-nhbrs : hex : join-distances
                              : dist-from-border : dist-from-centerline &as map}]
  (var forward-keep-eligible
    (->> (join-distances [8 9 10 13 14 15])
         (filter #(< 3 (dist-from-border $)))
         (filter #(< 4 (dist-from-centerline $)))))
  (var keep-idx 2)
  (while (-> forward-keep-eligible length (> 0))
    (let [keep (draw-random forward-keep-eligible)
          cluster [keep]]
      (hmerge hexes keep {:keep keep-idx})
      (for [i 1 2]
        (let [available
                (filter #(let [{: impassable} (hex $)] (not impassable))
                  (map-coll-nhbrs cluster))]
          (when (-> available length (> 0))
            (let [new (draw-random available)]
              (table.insert cluster new)
              (hmerge hexes new {:castle keep-idx})
              (set forward-keep-eligible (difference forward-keep-eligible (zone keep 10)))))))
      (inc! keep-idx)))
  map)

(lambda place-villages [{: hexes : half? : hex : map-coll-nhbrs : join-distances
                         : dist-from-border : dist-from-centerline &as map}]
  (let [half-map (some-crds half? hexes)
        castles (filter #(let [{: castle : keep} (hex $)] (or castle keep)) half-map)
        castle-neighbors (map-coll-nhbrs castles 2)]
    (var village-eligible
      (as-> h (join-distances [3 4 5 6 7 8 9 10 11 12 13 14 15])
            (filter #(< 2 (dist-from-border $)) h)
            (filter #(< 4 (dist-from-centerline $)) h)
            (filter #(let [{: impassable} (hex $)] (not impassable)) h)
            (difference h castle-neighbors)))
    (var village-idx 1)
    (while (-> village-eligible length (> 0))
      (let [village-crd (draw-random village-eligible)]
        (hmerge hexes village-crd {:village village-idx})
        (set village-eligible (difference village-eligible (zone village-crd 3)))
        (inc! village-idx))))
  map)

(lambda choose-tiles [{: hexes : hex : half? : set-tile &as map}]
  (let [chooser (get-chooser)]
    (each [_ crd (ipairs (some-crds half? hexes))]
      (->> crd hex chooser (set-tile crd))))
  map)

(lambda generate []
  (var saved-crd [0 0])
  (let [size 5
        draw-n-save #(let [result (draw-random $)]
                       (set saved-crd result)
                       result)
        impassable-constraint
          (fn [{: hexes} crd]
            (-> (hget hexes crd)
                (?. :impassable)
                (= nil)))
        edge-picker
          (lambda [rnd-f key]
            (lambda [map]
              (let [suitable
                      (filter #(impassable-constraint map $)
                              (. map key))]
                (rnd-f suitable))))]
    (->
      (gen-shape size)
      set-helpers
      (place-keep
        {:?keepsize-f #(+ 1 $)
         :?impassable-gap 3
         :?border-distance 2})
      (gen-patch {:min-size 2
                  :max-size (+ 1 size)
                  :spacing 4
                  :f (fn [hexes crd idx]
                       (hmerge hexes crd {:impassable idx}))
                  :?exclude
                    (fn [{: hexes : dist-from-border} crd]
                      (let [{: keep : castle : no-impassable} (hget hexes crd)]
                        (or keep castle no-impassable
                            (>= 2 (dist-from-border crd)))))})
      (gen-path {:algorithm :midpoint-displacement
                 :origin-f
                   (edge-picker draw-n-save :path-origin)
                 :end-f
                   (edge-picker draw-random :lower-path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:water 1}))})
      (gen-path {:algorithm :midpoint-displacement
                 :origin-f
                   #(symmetric saved-crd)
                 :end-f
                   (edge-picker draw-random :upper-path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:water 2}))})
      (gen-path {:algorithm :seek
                 :origin-f
                   (edge-picker draw-n-save :path-origin)
                 :end-f
                   (edge-picker draw-random :lower-path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:road 1}))
                 :?constraint impassable-constraint})
      (gen-path {:algorithm :seek
                 :origin-f
                   #(symmetric saved-crd)
                 :end-f
                   (edge-picker draw-random :upper-path-end)
                 :f (fn [hexes crd]
                      (hmerge hexes crd {:road 2}))
                 :?constraint impassable-constraint})
      (gen-patch {:min-size 1
                  :max-size size
                  :spacing 2
                  :f (fn [hexes crd idx]
                       (hmerge hexes crd {:difficult idx}))
                  :?exclude
                    (fn [{: hexes} crd]
                      (let [{: impassable : road : no-difficult} (hget hexes crd)]
                        (or impassable road no-difficult)))})
      estimate-distance-from-keep
      place-forward-keeps
      place-villages
      choose-tiles
      symmetrize-map
      to-csv)))

{: generate}

