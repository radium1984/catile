-- catile (WIP) - A simple tile-based game engine using LÖVE2D
-- Kim Alexander Schulz

local sti = require("libs.sti")
local cat = require("cat")
local screen = require("window")

-- Constants
local TILE_SIZE = 16
local ZOOM = 5
local CAMERA_LERP = 0.1
local PLAYER_SPEED = 100
local hoverAlpha = 1
local hoverTimer = 0

-- Globals
local map
local mouseHeld = false
local player = { x = 100, y = 100, w = 10, h = 10 }
local camX, camY = 0, 0

-- Dialogue system
local showDialogue = false
local dialogueText = "Nice, a carrot! This one's big and fluffy."
local displayedText = ""
local textTimer = 0
local textSpeed = 0.05
local dialogueImage = nil -- loaded in love.load()

function love.load()
    love.window.setMode(screen.window_width, screen.window_height, { resizable = true, highdpi = true })
    map = sti("map.lua")
    cat.load()
    player.x = 18 * TILE_SIZE
    player.y = 18 * TILE_SIZE
    dialogueImage = love.graphics.newImage("catbig.png")
end

function love.update(dt)
    if not showDialogue then
        local moveX, moveY = 0, 0
        if love.keyboard.isDown("w") then moveY = moveY - 1 end
        if love.keyboard.isDown("s") then moveY = moveY + 1 end
        if love.keyboard.isDown("a") then moveX = moveX - 1 end
        if love.keyboard.isDown("d") then moveX = moveX + 1 end

        local len = math.sqrt(moveX^2 + moveY^2)
        if len > 0 then
            moveX, moveY = moveX / len, moveY / len
            local nextX = player.x + moveX * PLAYER_SPEED * dt
            local nextY = player.y + moveY * PLAYER_SPEED * dt
            if not isColliding(nextX, nextY) then
                player.x = nextX
                player.y = nextY
            end
        elseif mouseHeld then
            local mx, my = love.mouse.getPosition()
            local worldX = (mx / ZOOM) + camX
            local worldY = (my / ZOOM) + camY
            local dx = worldX - player.x
            local dy = worldY - player.y
            local dist = math.sqrt(dx * dx + dy * dy)
            if dist > 2 then
                dx = dx / dist
                dy = dy / dist
                local nextX = player.x + dx * PLAYER_SPEED * dt
                local nextY = player.y + dy * PLAYER_SPEED * dt
                if not isColliding(nextX, nextY) then
                    player.x = nextX
                    player.y = nextY
                end
            end
        end
    end

    -- Camera
    local screenW = love.graphics.getWidth()
    local screenH = love.graphics.getHeight()
    local targetCamX = player.x + player.w / 2 - (screenW / (2 * ZOOM))
    local targetCamY = player.y + player.h / 2 - (screenH / (2 * ZOOM))
    camX = camX + (targetCamX - camX) * CAMERA_LERP
    camY = camY + (targetCamY - camY) * CAMERA_LERP

    camX = math.max(0, math.min(camX, map.width * TILE_SIZE - screenW / ZOOM))
    camY = math.max(0, math.min(camY, map.height * TILE_SIZE - screenH / ZOOM))

    cat.update(dt)
    map:update(dt)

    hoverTimer = hoverTimer + dt * 3.5
    hoverAlpha = 0.5 + 0.5 * math.sin(hoverTimer)

    -- Typewriter logic
    if showDialogue and #displayedText < #dialogueText then
        textTimer = textTimer + dt
        if textTimer >= textSpeed then
            textTimer = textTimer - textSpeed
            displayedText = dialogueText:sub(1, #displayedText + 1)
        end
    end
end

function love.draw()
    love.graphics.push()
    love.graphics.scale(ZOOM, ZOOM)
    love.graphics.translate(-camX, -camY)

    -- Draw map
    for _, layer in ipairs(map.layers) do
        if layer.type == "tilelayer" and layer.visible then
            map:drawLayer(layer)
        end
    end

    -- Draw player
    cat.draw(player.x, player.y)

    -- Draw hover box
    local mx, my = love.mouse.getPosition()
    local worldX = (mx / ZOOM) + camX
    local worldY = (my / ZOOM) + camY
    local tileX = math.floor(worldX / TILE_SIZE)
    local tileY = math.floor(worldY / TILE_SIZE)
    love.graphics.setColor(1, 1, 1, hoverAlpha)
    love.graphics.rectangle("line", tileX * TILE_SIZE + 0.5, tileY * TILE_SIZE + 0.5, TILE_SIZE - 1, TILE_SIZE - 1)
    love.graphics.setColor(1, 1, 1, 1)

    love.graphics.pop()

    -- UI debug info
    love.graphics.print("Mouse at Tile: " .. tileX .. ", " .. tileY, 10, 10)
    love.graphics.print("Player at: " .. math.floor(player.x / TILE_SIZE) .. ", " .. math.floor(player.y / TILE_SIZE), 10, 30)

    -- Trigger dialogue
    local px = math.floor(player.x / TILE_SIZE)
    local py = math.floor(player.y / TILE_SIZE)
    if love.keyboard.isDown("e") and not showDialogue then
        if px == 18 and py == 15 then
            showDialogue = true
            displayedText = ""
            textTimer = 0
        end
    end

    -- Draw dialogue box
    if showDialogue then
        local boxY = love.graphics.getHeight() - 150
        love.graphics.setColor(0, 0, 0, 0.8)
        love.graphics.rectangle("fill", 50, boxY, love.graphics.getWidth() - 100, 100, 10)
        love.graphics.setColor(1, 1, 1, 1)
        love.graphics.draw(dialogueImage, 60, boxY + 10, 0, 64 / dialogueImage:getWidth(), 64 / dialogueImage:getHeight())
        love.graphics.printf(displayedText, 150, boxY + 20, love.graphics.getWidth() - 200)
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        mouseHeld = true
        if showDialogue then
            showDialogue = false
        end
    end
end

function love.mousereleased(x, y, button)
    if button == 1 then
        mouseHeld = false
    end
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
end

function isColliding(x, y)
    local centerX = x + player.w / 2
    local centerY = y + player.h / 2
    local tileX = math.floor(centerX / TILE_SIZE)
    local tileY = math.floor(centerY / TILE_SIZE)

    local function tileExists(layerName)
        local layer = map.layers[layerName]
        if not layer or layer.type ~= "tilelayer" then return false end
        local row = layer.data[tileY + 1]
        if not row then return false end
        local tile = row[tileX + 1]
        return tile and tile.id ~= nil
    end

    return tileExists("base") or tileExists("collision")
end
