file = io.open("test.map", "w+")

width = 6
height = 6

for i = 0, height + 1, 1 do
    for j = 0, width + 1, 1 do
        
        if(    i == 0
            or j == 0
            or i == height + 1
            or j == width + 1)
        then
            file:write("_off^_usr")
        else
            file:write("Gg")
        end

        if (j < height + 1) then
            file:write(", ")
        end
    end

    file:write("\n")
end

file:close()
