package.path = package.path .. ";.luamodules/share/lua/5.4/luaunit.lua"
lu = require('luaunit')
utils = require('../lua/utils')

function testPoint()
    point = utils.point(1, 2)
    lu.assertEquals(point[0], 1)
    lu.assertEquals(point[1], 2)
end

function testNeighborsCenterEven()
    map = { height = 5, width = 5 }
    neighbors = utils.neighbors(2, 2, map)

    lu.assertEquals(neighbors[0][0], 2)
    lu.assertEquals(neighbors[0][1], 1)

    lu.assertEquals(neighbors[1][0], 3)
    lu.assertEquals(neighbors[1][1], 2)

    lu.assertEquals(neighbors[2][0], 3)
    lu.assertEquals(neighbors[2][1], 3)

    lu.assertEquals(neighbors[3][0], 2)
    lu.assertEquals(neighbors[3][1], 3)

    lu.assertEquals(neighbors[4][0], 1)
    lu.assertEquals(neighbors[4][1], 3)

    lu.assertEquals(neighbors[5][0], 1)
    lu.assertEquals(neighbors[5][1], 2)

    lu.assertEquals(neighbors[6], nil)
end

function testNeighborsCenterOdd()
    map = { height = 5, width = 5 }
    neighbors = utils.neighbors(3, 3, map)

    lu.assertEquals(neighbors[0][0], 3)
    lu.assertEquals(neighbors[0][1], 2)

    lu.assertEquals(neighbors[1][0], 4)
    lu.assertEquals(neighbors[1][1], 2)

    lu.assertEquals(neighbors[2][0], 4)
    lu.assertEquals(neighbors[2][1], 3)

    lu.assertEquals(neighbors[3][0], 3)
    lu.assertEquals(neighbors[3][1], 4)

    lu.assertEquals(neighbors[4][0], 2)
    lu.assertEquals(neighbors[4][1], 3)

    lu.assertEquals(neighbors[5][0], 2)
    lu.assertEquals(neighbors[5][1], 2)

    lu.assertEquals(neighbors[6], nil)
end

function testNeighborsTopLeft()
    map = { height = 5, width = 5 }
    neighbors = utils.neighbors(1, 1, map)

    lu.assertEquals(neighbors[0][0], 2)
    lu.assertEquals(neighbors[0][1], 1)

    lu.assertEquals(neighbors[1][0], 1)
    lu.assertEquals(neighbors[1][1], 2)

    lu.assertEquals(neighbors[2], nil)
end

function testNeighborsBottomRight()
    map = { height = 5, width = 5 }
    neighbors = utils.neighbors(5, 5, map)

    lu.assertEquals(neighbors[0][0], 5)
    lu.assertEquals(neighbors[0][1], 4)

    lu.assertEquals(neighbors[1][0], 4)
    lu.assertEquals(neighbors[1][1], 5)

    lu.assertEquals(neighbors[2][0], 4)
    lu.assertEquals(neighbors[2][1], 4)

    lu.assertEquals(neighbors[3], nil)
end

function testNeighborsTopCenter()
    map = { height = 5, width = 5 }
    neighbors = utils.neighbors(4, 1, map)

    lu.assertEquals(neighbors[0][0], 5)
    lu.assertEquals(neighbors[0][1], 1)

    lu.assertEquals(neighbors[1][0], 5)
    lu.assertEquals(neighbors[1][1], 2)

    lu.assertEquals(neighbors[2][0], 4)
    lu.assertEquals(neighbors[2][1], 2)

    lu.assertEquals(neighbors[3][0], 3)
    lu.assertEquals(neighbors[3][1], 2)

    lu.assertEquals(neighbors[4][0], 3)
    lu.assertEquals(neighbors[4][1], 1)

    lu.assertEquals(neighbors[5], nil)
end

os.exit(lu.LuaUnit:run())

