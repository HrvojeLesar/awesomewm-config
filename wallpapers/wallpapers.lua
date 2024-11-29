local awful = require("awful")
local gears = require("gears")

local M = {}

M.image_index = {}
M.wallpapers = {
    "/home/hrvoje/.config/awesome/wallpapers/exarch.png",
}

--- @generic T
--- @param value integer
--- @param screenObj ?T
function M:set_image_index(value, screenObj)
    local screen = screenObj or mouse.screen
    self.image_index[tostring(screen)] = value
end

function M:get_image_index()
    local screen = mouse.screen
    local idx = self.image_index[tostring(screen)]
    if idx == nil then
        self:set_image_index(1)
    end

    return self.image_index[tostring(screen)]
end

--- @generic T
--- @param image ?string
--- @param screenObj ?T
function M:set_wallpaper(image, screenObj)
    local screen = screenObj or mouse.screen
    if image == nil then
        self:set_image_index(1, screen)
    end
    local img = image or self.image_index[screen] or self.wallpapers[1]
    if img:sub(1, #"feh") == "feh" then
        for k, _ in pairs(self.image_index) do
            self.image_index[k] = 1
        end
        awful.spawn(img)
    else
        gears.wallpaper.fit(img, screen)
    end
end

function M:home_image()
    self:set_wallpaper()
end

--- @param step integer|nil
function M:next_wallpaper(step)
    local step_by = step or 1
    self:set_image_index(self:get_image_index() + step_by)
    local img = self.wallpapers[self:get_image_index()]
    if img == nil then
        self:set_image_index((function() if step_by > 0 then return 1 else return #self.wallpapers end end)())
        img = self.wallpapers[self:get_image_index()]
    end

    self:set_wallpaper(img)
end

return M
