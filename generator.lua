function write_to_file(map)
    file = io.open(map["name"] .. ".map", "w+")

    width = map["width"]
    height = map["height"]

    for i = 0, height + 1, 1 do
        for j = 0, width + 1, 1 do
            
            if(    i == 0
                or j == 0
                or i == height + 1
                or j == width + 1)
            then
                file:write("_off^_usr")
            else
                file:write(map["codes"][i][j])
            end

            if (j < width + 1) then
                file:write(", ")
            end
        end

        file:write("\n")
    end

    file:close()
end

function generate_map()
    width = 32
    height = 16
    map = { width = width, height = height, name = "test" }
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

    for i = 0, height - 1 do
        for j = 0, width / 2 - 1 do
            codes[height - i][width - j] = codes[i + 1][j + 1]
        end
    end

    map["codes"] = codes
    return map
end

write_to_file(generate_map())

