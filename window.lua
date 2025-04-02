-- screen_size.lua

local M = {}

local display = 1
local desktopWidth, desktopHeight = love.window.getDesktopDimensions(display)

M.full_width = desktopWidth
M.full_height = desktopHeight

M.window_width = desktopWidth * 0.9
M.window_height = desktopHeight * 0.9

return M
