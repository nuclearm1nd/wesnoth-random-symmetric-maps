(global wesnoth
  {:require (lambda [str]
              (require (.. "../fnl/" str)))})

(local {: neighbors : on-map?} (require :../fnl/map))

(set package.path (.. package.path ";.luamodules/share/lua/5.4/luaunit.lua"))
(local lu (require :luaunit))

(global testNeighbors
  (fn []
    (let [map {:height 5 :width 5}]
      (tset map :on-map?
        (lambda [[x y]]
          (and (> y 0)
               (> x 0)
               (<= y 5)
               (<= x 5))))

      (lu.assertItemsEquals
        (neighbors map [2 2])
        [[2 1] [2 3] [3 2] [3 3] [1 3] [1 2]])

      (lu.assertItemsEquals
        (neighbors map [3 3])
        [[3 2] [3 4] [4 2] [4 3] [2 3] [2 2]])

      (lu.assertItemsEquals
        (neighbors map [1 1])
        [[1 2] [2 1]])

      (lu.assertItemsEquals
        (neighbors map [5 5])
        [[5 4] [4 5] [4 4]])

      (lu.assertItemsEquals
        (neighbors map [4 1])
        [[4 2] [5 1] [5 2] [3 2] [3 1]]))))

(os.exit (lu.LuaUnit.run))

