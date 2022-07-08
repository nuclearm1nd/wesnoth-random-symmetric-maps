(local util (require :../fnl/util))

(set package.path (.. package.path ";.luamodules/share/lua/5.4/luaunit.lua"))
(local lu (require :luaunit))

(global testCenterEven
  (fn []
    (let [map {:height 5 :width 5}]
      (lu.assertEquals
        (util.neighbors [2 2] map)
        [[2 1] [3 2] [3 3] [2 3] [1 3] [1 2]])

      (lu.assertEquals
        (util.neighbors [3 3] map)
        [[3 2] [4 2] [4 3] [3 4] [2 3] [2 2]])

      (lu.assertEquals
        (util.neighbors [1 1] map)
        [[2 1] [1 2]])

      (lu.assertEquals
        (util.neighbors [5 5] map)
        [[5 4] [4 5] [4 4]])

      (lu.assertEquals
        (util.neighbors [4 1] map)
        [[5 1] [5 2] [4 2] [3 2] [3 1]]))))

(os.exit (lu.LuaUnit.run))

