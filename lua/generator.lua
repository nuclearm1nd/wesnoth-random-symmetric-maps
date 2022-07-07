local utils

if wesnoth.require then
  utils = wesnoth.require('utils')
else
  utils = require('utils')
end

local generator = {}

function generate_map()
    width = 32
    height = 16
    map = { width = width, height = height }
    codes = {}

    for i = 1, height do
        codes[i] = {}

        for j = 1, width / 2 do
            rnd = math.random()

            if (rnd > 0.975) then
                codes[i][j] = "Gs^Vh"
            elseif (rnd > 0.75) then
                codes[i][j] = "Gs^Fds"
            elseif (rnd > 0.5) then
                codes[i][j] = "Gs"
            else
                codes[i][j] = "Gg"
            end
        end
    end

    x = math.floor(math.random(2, width / 4 ))
    y = math.floor(math.random(2, height / 2))
    neighbors = utils.neighbors(x, y, map)
    i1 = 0

    while(neighbors[i1] ~= nil) do
        x1 = neighbors[i1][0]
        y1 = neighbors[i1][1]
        codes[y1][x1] = "Ce"
        i1 = i1 + 1
    end

    for i = 0, height - 1 do
        for j = 0, width / 2 - 1 do
            codes[height - i][width - j] = codes[i + 1][j + 1]
        end
    end

    codes[y][x] = "1 Ke"
    codes[height - y + 1][width - x + 1] = "2 Ke"

    map["codes"] = codes
    return map
end

function map_to_string(map)
    result = ""

    width = map["width"]
    height = map["height"]

    for i = 0, height + 1, 1 do
        for j = 0, width + 1, 1 do

            if(    i == 0
                or j == 0
                or i == height + 1
                or j == width + 1)
            then
                result = result .. "_off^_usr"
            else
                result = result .. map["codes"][i][j]
            end

            if (j < width + 1) then
                result = result .. ", "
            end
        end

        result = result .. "\n"
    end

    return result
end

function generator.generate_map_string()
  return map_to_string(generate_map())
end

return generator

--function write_to_file(map_string)
--    file = io.open("test.map", "w+")
--    file:write(map_string)
--    file:close()
--end

-- write_to_file(map_to_string(generate_map()))

