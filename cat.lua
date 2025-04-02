local cat = {}

function cat.load()
    cat.image = love.graphics.newImage("cat.png")
    cat.image:setFilter("nearest", "nearest") -- For pixel crispness

    -- Frame size (based on your image layout)
    cat.frameWidth = 32
    cat.frameHeight = 32

    -- Quad definitions
    cat.frames = {
        love.graphics.newQuad(0, 0, 32, 32, cat.image:getDimensions()),
        love.graphics.newQuad(32, 0, 32, 32, cat.image:getDimensions()),
        love.graphics.newQuad(0, 32, 32, 32, cat.image:getDimensions())
    }

    -- Animation timing
    cat.currentFrame = 1
    cat.timer = 0
    cat.frameDuration = 0.2 -- seconds per frame

    -- Scale + Offset for 16x16 tile size
    cat.scale = 16 / 32
    cat.ox = 16
    cat.oy = 16
end

function cat.update(dt)
    cat.timer = cat.timer + dt
    if cat.timer >= cat.frameDuration then
        cat.timer = cat.timer - cat.frameDuration
        cat.currentFrame = cat.currentFrame % #cat.frames + 1
    end
end

function cat.draw(x, y)
    love.graphics.draw(cat.image, cat.frames[cat.currentFrame], x, y, 0, cat.scale, cat.scale, cat.ox, cat.oy)
end

return cat
