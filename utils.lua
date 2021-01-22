local utils = {}

function utils.point(x, y)
    res = {}
    res[0] = x
    res[1] = y
    return res
end

function utils.neighbors(x, y, map)
    height = map["height"]
    width = map["width"]
    result = {}
    i = 0

    if (y - 1 > 0) then
        result[i] = utils.point(x, y - 1)
        i = i + 1
    end

    if (x + 1 <= width) then
        if (x % 2 == 0) then
            result[i] = utils.point(x + 1, y)
            i = i + 1

            if (y + 1 <= height) then
                result[i] = utils.point(x + 1, y + 1)
                i = i + 1
            end
        else
            if(y - 1 > 0) then
                result[i] = utils.point(x + 1, y - 1)
                i = i + 1
            end

            result[i] = utils.point(x + 1, y)
            i = i + 1
        end
    end

    if (y + 1 <= height) then
        result[i] = utils.point(x, y + 1)
        i = i + 1
    end

    if (x - 1 > 0) then
        if (x % 2 == 0) then
            if (y + 1 <= height) then
                result[i] = utils.point(x - 1, y + 1)
                i = i + 1
            end
           
            result[i] = utils.point(x - 1, y)
            i = i + 1
        else
            result[i] = utils.point(x - 1, y)
            i = i + 1

            if (y - 1 > 0) then
                result[i] = utils.point(x - 1, y - 1)
                i = i + 1
            end
        end
    end

    return result
end

return utils
