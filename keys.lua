local gears = require("gears")
local awful = require("awful")
local xrandr = require("xrandr")

local M = {}

-- Default modkey.
modkey = "Mod4"

local move_client_keybinds = {}
for i = 1, 5 do
    move_client_keybinds = gears.table.join(
        move_client_keybinds,
        awful.key({ modkey, }, i,
            function()
                local screen = awful.screen.focused()
                local tag = screen.tags[i]
                if tag then
                    tag:view_only()
                end
            end,
            { description = "view tag", group = "tag" }
        ),
        awful.key({ modkey, "Shift" }, i,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                        tag:view_only()
                    end
                end
            end,
            { description = "view tag", group = "tag" }
        ),
        awful.key({ modkey, "Control" }, i,
            function()
                if client.focus then
                    local tag = client.focus.screen.tags[i]
                    if tag then
                        client.focus:move_to_tag(tag)
                    end
                end
            end,
            { description = "view tag", group = "tag" }
        )
    )
end

local image_commands = {
    "feh --bg-max /home/hrvoje/.config/awesome/wallpapers/exarch.webp",
    "feh --bg-max /home/hrvoje/.config/awesome/wallpapers/W.jpeg",
    "feh --bg-max /home/hrvoje/.config/awesome/wallpapers/ni.jpg",
    "feh --bg-max /home/hrvoje/.config/awesome/wallpapers/lon.jpg",
    "feh --bg-max /home/hrvoje/.config/awesome/wallpapers/guc.jpg",
    "feh --bg-max /home/hrvoje/.config/awesome/wallpapers/orig.jpg",
    "feh --bg-max /home/hrvoje/.config/awesome/wallpapers/nov.jpeg",
}
local image_index = 1

--- @param step integer|nil
--- @return string|nil
local function next_image(step)
    local step_by = step or 1
    image_index = image_index + step_by
    local img = image_commands[image_index]
    if img == nil then
        image_index = (function () if step_by > 0 then return 1 else return #image_commands end end)()
        img = image_commands[image_index]
    end

    return img
end

local function home_image()
    image_index = 1
    return image_commands[image_index]
end

-- {{{ Key bindings
M.globalkeys = gears.table.join(
    move_client_keybinds,
    -- Quit
    awful.key({ modkey, "Shift", "Control" }, "q", awesome.quit, { description = "quit awesome", group = "awesome" }),
    -- Quit app
    awful.key({ modkey, }, "q", function()
            if client.focus == nil then return end
            client.focus:kill()
        end,
        { description = "close", group = "client" }),

    awful.key({ modkey }, "r",
        function()
            local c = awful.client.restore()
            -- Focus restored client
            if c then
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "restore minimized", group = "client" }),

    -- Reload config
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "reload awesome", group = "awesome" }),

    -- Moving between windows
    awful.key({ modkey, }, "j", function() awful.client.focus.byidx(1) end,
        { description = "focus next by index", group = "client" }),
    awful.key({ modkey, }, "k", function() awful.client.focus.byidx(-1) end,
        { description = "focus previous by index", group = "client" }),

    -- Window resize
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "increase master width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "decrease master width factor", group = "layout" }),

    -- Swap window
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "swap with next client by index", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "swap with previous client by index", group = "client" }),

    -- Layouts
    awful.key({ modkey, "Shift" }, "n", function() awful.layout.inc(1) end,
        { description = "Next layout", group = "layout" }),
    awful.key({ modkey, "Shift" }, "p", function() awful.layout.inc(-1) end,
        { description = "Prev layout", group = "layout" }),

    -- Tabs
    awful.key({ modkey, }, "n", function() awful.tag.viewidx(1) end,
        { description = "Next tab", group = "tab" }),
    awful.key({ modkey, }, "p", function() awful.tag.viewidx(-1) end,
        { description = "Prev tab", group = "tab" }),

    -- Xrandr
    awful.key({ modkey, "Shift" }, "p", function() xrandr.xrandr() end,
        { description = "Prev tab", group = "tab" }),

    -- Alt tab
    -- awful.key({ modkey, }, "Tab", function() awful.client.history.previous() end,
    --     { description = "Prev tab", group = "tab" }),

    -- Open programs
    awful.key({ modkey, }, "t", function() awful.spawn(terminal) end,
        { description = "Open terminal", group = "client" }),
    awful.key({ modkey, }, "Return", function() awful.spawn(terminal) end,
        { description = "Open terminal", group = "client" }),
    awful.key({ modkey, }, "b", function() awful.spawn("x-www-browser") end,
        { description = "Open browser", group = "client" }),
    awful.key({ modkey, }, "i", function() mymainmenu:show() end,
        { description = "Show main menu", group = "awesome" }),
    awful.key({ modkey, }, "d", function() awful.spawn("discord") end,
        { description = "Start discord", group = "client" }),
    awful.key({ modkey, }, "s", function() awful.spawn("spotify") end,
        { description = "Start spotify", group = "client" }),

    -- Media keys
    awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl play-pause") end,
        { description = "Play/Pause", group = "media" }),
    awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl next") end,
        { description = "Next", group = "media" }),
    awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl previous") end,
        { description = "Prev", group = "media" }),

    -- Run
    awful.key({ modkey }, "a", function() awful.spawn("rofi -show drun -show-icons") end,
        { description = "Spawn rofi", group = "Run" }),
    awful.key({ modkey }, "w", function() awful.spawn("rofi -show window -show-icons") end,
        { description = "Spawn rofi", group = "Run" }),
    awful.key({}, "Print", function() awful.spawn("flameshot gui") end,
        { description = "Print screen", group = "Run" }),

    -- Background
    awful.key({ modkey, "Control" }, "n", function()
            local command = next_image()
            awful.spawn(command)
        end,
        { description = "Next image", group = "Background" }),
    awful.key({ modkey, "Control" }, "p", function()
            local command = next_image(-1)
            awful.spawn(command)
        end,
        { description = "Previous image", group = "Background" }),

    awful.key({ modkey, "Control" }, "h", function()
            awful.spawn(home_image())
        end,
        { description = "First image", group = "Background" })
)

M.clientkeys = gears.table.join(
    awful.key({ modkey, }, "m",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "minimize", group = "client" }),

    -- Toggle fullscreen
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            c:raise()
        end,
        { description = "toggle fullscreen", group = "client" }),

    -- Toggle floating on window
    awful.key({ modkey, }, "space", function(c)
            c.floating = not c.floating
            c.ontop = c.floating
        end,
        { description = "toggle floating", group = "client" })

)

M.clientbuttons = gears.table.join(
-- Mouse left button
    awful.button({}, 1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end
    ),
    -- Mouse middle button
    awful.button({}, 2,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end
    ),
    -- Mouse right button
    awful.button({}, 3,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
        end
    ),

    -- Move window
    awful.button({ modkey }, 1,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.move(c)
        end
    ),

    -- Resize window
    awful.button({ modkey }, 3,
        function(c)
            c:emit_signal("request::activate", "mouse_click", { raise = true })
            awful.mouse.client.resize(c)
        end
    )
)

return M
