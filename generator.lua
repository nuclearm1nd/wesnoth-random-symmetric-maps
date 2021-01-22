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
                if(math.random() > 0.95)
                then
                    file:write("Gg^Vh")
                else
                    file:write("Gg")
                end
            end

            if (j < width + 1) then
                file:write(", ")
            end
        end

        file:write("\n")
    end

    file:close()
end

map = { width = 20, height = 15, name = "test" }
write_to_file(map)

