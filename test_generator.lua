package.path = package.path .. ";.luamodules/share/lua/5.2/luaunit.lua"
lu = require('luaunit')
utils = require('utils')

function testStub()
    lu.assertEquals(0, 0)
end

function testUnity()
    lu.assertEquals(utils:unity(), 1)
end

os.exit(lu.LuaUnit:run())

