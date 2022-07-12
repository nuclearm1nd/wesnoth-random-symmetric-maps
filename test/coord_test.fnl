(global wesnoth
  {:require (lambda [str]
              (require (.. "../fnl/" str)))})

(local {: union
        : difference} (require :../fnl/coord))

(set package.path (.. package.path ";.luamodules/share/lua/5.4/luaunit.lua"))
(local lu (require :luaunit))

(global testSets
  (fn []
    (lu.assertEquals
      (union [] [])
      [])

    (lu.assertEquals
      (difference [] [])
      [])

    (lu.assertItemsEquals
      (union [[1 1] [1 2]]
             [[1 2] [2 1]])
      [[1 1] [2 1] [1 2]])

    (lu.assertItemsEquals
      (difference
        [[1 1] [1 2]]
        [[1 2] [2 1]])
      [[1 1]])
    ))

(os.exit (lu.LuaUnit.run))

