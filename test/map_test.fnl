(import-macros {: test
                : to-test-pairs} "../test/util")

(global wesnoth
  {:require (lambda [str]
              (require (.. "../fnl/" str)))})

(local {: mapv} (require :../fnl/util))

(local {: to-axial
        : to-oddq
        : check-factory
        : line-constraint} (require :../fnl/coord))

(local {: map-neighbors
        : generate-empty-map
        : oddq-bounds} (require :../fnl/map))

(set package.path (.. package.path ";.luamodules/share/lua/5.4/luaunit.lua"))
(local lu (require :luaunit))

(test Neighbors
  (let [map
          {:on-map?
            (check-factory
              [(line-constraint [:horizontal 0] :below)
               (line-constraint [:horizontal 11] :above)
               (line-constraint [:vertical 0] :right)
               (line-constraint [:vertical 6] :left)])}
        test-fn
          (lambda [crd result]
            (lu.assertItemsEquals
              (mapv to-oddq
                    (map-neighbors map (to-axial crd)))
            result))]

    (test-fn
      [2 2]
      [[2 1] [2 3] [3 2] [3 3] [1 3] [1 2]])

    (test-fn
      [3 3]
      [[3 2] [3 4] [4 2] [4 3] [2 3] [2 2]])

    (test-fn
      [1 1]
      [[1 2] [2 1]])

    (test-fn
      [5 5]
      [[5 4] [4 5] [4 4]])

    (test-fn
      [4 1]
      [[4 2] [5 1] [5 2] [3 2] [3 1]])
    ))

;;(test Bounds
;;  (lu.assertEquals
;;    (oddq-bounds (generate-empty-map))
;;    [0 33 0 17]))

(os.exit (lu.LuaUnit.run))

