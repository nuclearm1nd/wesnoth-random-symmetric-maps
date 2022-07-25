(import-macros {: test
                : to-test-pairs} "../test/util")

(global wesnoth
  {:require (lambda [str]
              (require (.. "../fnl/" str)))})

(local {: union
        : difference
        : to-axial
        : to-oddq
        : symmetric
        : to-new-origin
        : distance
        : neighbors
        : zone
        : line-distance
        : line-constraint
        : check-factory
        } (require :../fnl/coord))

(set package.path (.. package.path ";.luamodules/share/lua/5.4/luaunit.lua"))
(local lu (require :luaunit))

(test Sets
  (to-test-pairs lu.assertItemsEquals

    (union [] [])
    []

    (difference [] [])
    []

    (union [[1 1] [1 2]]
           [[1 2] [2 1]])
    [[1 1] [2 1] [1 2]]

    (difference
      [[1 1] [1 2]]
      [[1 2] [2 1]])
    [[1 1]]

  ))

(test Conversion
  (to-test-pairs lu.assertEquals

    (to-axial [0 0])
    [0 0]

    (to-oddq [0 0])
    [0 0]

    (to-axial [1 1])
    [1 1]

    (to-oddq [1 1])
    [1 1]

    (to-axial [2 1])
    [2 2]

    (to-oddq [2 2])
    [2 1]

    (to-axial [3 1])
    [3 2]

    (to-oddq [3 2])
    [3 1]

    (to-axial [10 5])
    [10 10]

    (to-oddq [10 10])
    [10 5]

    (to-axial [4 4])
    [4 6]

    (to-oddq [4 6])
    [4 4]

    (to-axial [8 3])
    [8 7]

    (to-oddq [8 7])
    [8 3]

    (to-axial [4 2] [4 2])
    [0 0]

    (to-oddq [-4 -4] [-4 -4])
    [0 0]

    (to-axial [8 7] [4 2])
    [4 7]

    (to-oddq [4 7] [-4 -4])
    [8 7]

    (to-axial [2 3] [4 2])
    [-2 0]

    (to-oddq [-2 0] [-4 -4])
    [2 3]

  ))

(test OriginShift
  (to-test-pairs lu.assertEquals

    (to-new-origin [2 0] [3 2])
    [-1 -2]

    (to-new-origin [4 4] [3 2])
    [1 2]

    (to-new-origin [0 0] [3 2])
    [-3 -2]

  ))

(test Symmetric
  (to-test-pairs lu.assertEquals

    (symmetric [-2 -3])
    [2 3]

    (symmetric [2 0] [3 2])
    [4 4]

    (symmetric [4 1] [3 2])
    [2 3]

    (symmetric [0 -1] [0.5 0.5])
    [1 2]

    (symmetric [-1 -2] [0.5 0.5])
    [2 3]

  ))

(test Distance
  (to-test-pairs lu.assertEquals

    (distance [0 0] [0 0])
    0

    (distance [2 5] [2 5])
    0

    (distance [2 3] [3 0])
    4

    (distance [-1 1] [1 -1])
    4

    (distance [1 2] [2 1])
    2
  ))

(test Neighbors
  (to-test-pairs lu.assertItemsEquals

    (neighbors [1 2] 0)
    []

    (zone [1 2] 0)
    [[1 2]]

    (neighbors [1 2])
    [[0 1] [1 1] [0 2] [2 2] [1 3] [2 3]]

    (zone [1 2])
    [[1 2] [0 1] [1 1] [0 2] [2 2] [1 3] [2 3]]

    (neighbors [1 2] 2)
    [[-1 0]
     [-1 1]
     [-1 2]
     [0 0]
     [0 1]
     [0 2]
     [0 3]
     [1 0]
     [1 1]
     [1 3]
     [1 4]
     [2 1]
     [2 2]
     [2 3]
     [2 4]
     [3 2]
     [3 3]
     [3 4]]

    (zone [1 2] 2)
    [[1 2]
     [-1 0]
     [-1 1]
     [-1 2]
     [0 0]
     [0 1]
     [0 2]
     [0 3]
     [1 0]
     [1 1]
     [1 3]
     [1 4]
     [2 1]
     [2 2]
     [2 3]
     [2 4]
     [3 2]
     [3 3]
     [3 4]]
))

(test LineDistance
  (to-test-pairs lu.assertEquals

    (line-distance [:horizontal 0] [0 0])
    0

    (line-distance [:horizontal 0] [2 1])
    0

    (line-distance [:horizontal 0] [4 2])
    0

    (line-distance [:horizontal 0] [3 2])
    1

    (line-distance [:horizontal 1] [1 1])
    0

    (line-distance [:horizontal 1] [-1 0])
    0

    (line-distance [:horizontal 1] [-3 -1])
    0

    (line-distance [:horizontal 1] [0 0])
    -1

    (line-distance [:horizontal 1] [0 3])
    3

    (line-distance [:- 1] [1 3])
    2

    (line-distance [:- -3] [2 4])
    5

    (line-distance [:- 4] [-1 -2])
    -4

    (line-distance [:- 3] [4 2])
    -2

    (line-distance [:- 2] [4 2])
    -1

    (line-distance [:- -5] [4 5])
    6

    (line-distance [:vertical 0] [0 0])
    0

    (line-distance [:| 0] [0 5])
    0

    (line-distance [:| 0] [3 5])
    3

    (line-distance [:| 0] [-3 -2])
    -3

    (line-distance [:incline-right 0] [0 0])
    0

    (line-distance [:/ 0] [3 1])
    1

    (line-distance [:/ 0] [-2 1])
    1

    (line-distance [:/ 0] [-2 -3])
    -3

    (line-distance [:/ -2] [3 4])
    6

    (line-distance [:/ -2] [3 -4])
    -2

    (line-distance [:incline-left 0] [0 0])
    0

    (line-distance [:incline-left 0] [-2 0])
    -2

    (line-distance [:\ 2] [4 1])
    1

  ))

(test LineConstraint
  (let [constraint (line-constraint [:- -1] :below)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      true

      (constraint [1 0])
      false

      (constraint [5 3])
      true

      (constraint [5 2])
      false))

  (let [constraint (line-constraint [:| -1] :right)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      true

      (constraint [1 0])
      true

      (constraint [-2 3])
      false

      (constraint [-1 -5])
      false))

  (let [constraint (line-constraint [:/ 1] :below)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      false

      (constraint [1 0])
      false

      (constraint [-2 3])
      true

      (constraint [-4 1])
      false))

  (let [constraint (line-constraint [:/ 1] :right)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      false

      (constraint [1 0])
      false

      (constraint [-2 3])
      true

      (constraint [-4 1])
      false))

  (let [constraint (line-constraint [:\ 1] :right)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      false

      (constraint [4 2])
      true

      (constraint [4 3])
      false))

  (let [constraint (line-constraint [:\ 1] :below)]
    (to-test-pairs lu.assertEquals
      (constraint [0 0])
      true

      (constraint [4 2])
      false

      (constraint [4 3])
      false

      (constraint [4 4])
      true
      ))

  (lu.assertError #(line-constraint [:- 0] :right))
  (lu.assertError #(line-constraint [:horizontal 0] :left))

  (lu.assertError #(line-constraint [:vertical 0] :below))
  (lu.assertError #(line-constraint [:| 0] :above))
  )

(test AreaContraint
  (let [constraint
          (check-factory
            [(line-constraint [:-  0] :+)
             (line-constraint [:- 11] :-)
             (line-constraint [:|  0] :+)
             (line-constraint [:|  6] :-)])]
    (to-test-pairs lu.assertEquals
      (constraint [1 1])
      true

      (constraint [5 3])
      true

      (constraint [5 7])
      true

      (constraint [1 5])
      true

      (constraint [0 1])
      false

      (constraint [6 3])
      false

      (constraint [5 8])
      false

      (constraint [1 6])
      false)))

(os.exit (lu.LuaUnit.run))

