(local {: neighbors : off-map?} (require :../fnl/map))

(set package.path (.. package.path ";.luamodules/share/lua/5.4/luaunit.lua"))
(local lu (require :luaunit))

(global testNeighbors
  (fn []
    (let [map {:height 5 :width 5}]
      (tset map :off-map? (partial off-map? map))

      (lu.assertEquals
        (neighbors map [2 2])
        [[2 1] [2 3] [3 2] [3 3] [1 3] [1 2]])

      (lu.assertEquals
        (neighbors map [3 3])
        [[3 2] [3 4] [4 2] [4 3] [2 3] [2 2]])

      (lu.assertEquals
        (neighbors map [1 1])
        [[1 2] [2 1]])

      (lu.assertEquals
        (neighbors map [5 5])
        [[5 4] [4 5] [4 4]])

      (lu.assertEquals
        (neighbors map [4 1])
        [[4 2] [5 1] [5 2] [3 2] [3 1]]))))

(os.exit (lu.LuaUnit.run))

