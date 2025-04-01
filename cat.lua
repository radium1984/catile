local cat = {}

function cat.load()
    local rawImage = love.graphics.newImage("cat.png")
    local imageData = love.image.newImageData("cat.png")

    -- Crop transparent space
    local minX, minY = imageData:getWidth(), imageData:getHeight()
    local maxX, maxY = 0, 0

    imageData:mapPixel(function(x, y, r, g, b, a)
        if a > 0 then
            if x < minX then minX = x end
            if y < minY then minY = y end
            if x > maxX then maxX = x end
            if y > maxY then maxY = y end
        end
        return r, g, b, a
    end)

    local trimmedW = maxX - minX + 1
    local trimmedH = maxY - minY + 1
    local trimmedData = love.image.newImageData(trimmedW, trimmedH)
    trimmedData:paste(imageData, 0, 0, minX, minY, trimmedW, trimmedH)

    cat.image = love.graphics.newImage(trimmedData)

    -- Scale it to fit inside 16x16
    cat.scale = 16 / math.max(trimmedW, trimmedH)
    cat.ox = trimmedW / 2
    cat.oy = trimmedH / 2
end

function cat.draw(x, y)
    love.graphics.draw(cat.image, x + 8, y + 8, 0, cat.scale, cat.scale, cat.ox, cat.oy)
end

return cat
