package.path = package.path .. ";.luamodules/share/lua/5.2/luaunit.lua"
luaunit = require('luaunit')
os.exit(luaunit.LuaUnit.run())

