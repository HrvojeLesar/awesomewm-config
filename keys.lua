local gears = require("gears")
local awful = require("awful")
local xrandr = require("xrandr")
local wallpapers = require("wallpapers.wallpapers")
local naughty = require("naughty")

local M = {}

local function change_opacity(client, step)
    local opacity_to_set = client.opacity + step
    if opacity_to_set >= 1.0 then
        opacity_to_set = 1.0
    elseif opacity_to_set <= 0.0 then
        opacity_to_set = 0.0
    end

    client.opacity = opacity_to_set
end

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
            { description = "Focus tag", group = "tag" }
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
            { description = "Move client and focus tag", group = "tag" }
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
            { description = "Send client to tag", group = "tag" }
        )
    )
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
                c.ontop = c.floating
                c:emit_signal(
                    "request::activate", "key.unminimize", { raise = true }
                )
            end
        end,
        { description = "Restore minimized client", group = "client" }),

    -- Reload config
    awful.key({ modkey, "Control" }, "r", awesome.restart,
        { description = "Reload awesome", group = "awesome" }),

    -- Moving between windows
    awful.key({ modkey, }, "j", function() awful.client.focus.byidx(1) end,
        { description = "Focus next client by index", group = "client" }),
    awful.key({ modkey, }, "k", function() awful.client.focus.byidx(-1) end,
        { description = "Focus previous client by index", group = "client" }),

    -- Window resize
    awful.key({ modkey, }, "l", function() awful.tag.incmwfact(0.05) end,
        { description = "Increase master client width factor", group = "layout" }),
    awful.key({ modkey, }, "h", function() awful.tag.incmwfact(-0.05) end,
        { description = "Decrease master client width factor", group = "layout" }),

    -- Swap window
    awful.key({ modkey, "Shift" }, "j", function() awful.client.swap.byidx(1) end,
        { description = "Swap with next client", group = "client" }),
    awful.key({ modkey, "Shift" }, "k", function() awful.client.swap.byidx(-1) end,
        { description = "Swap with previous client", group = "client" }),

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
    awful.key({ modkey, "Shift", "Control" }, "p", function() xrandr.xrandr() end,
        { description = "Next screen positions setup", group = "xrandr" }),
    awful.key({ modkey, "Shift", "Control", "Mod1" }, "i", function() awful.spawn("/home/hrvoje/run_i.sh") end,
        { description = "Next screen positions setup script", group = "xrandr" }),

    -- Alt tab
    awful.key({ modkey, }, "Tab", function()
            awesome.emit_signal("bling::window_switcher::turn_on")
        end,
        { description = "Window switcher", group = "bling" }),
    awful.key({ "Mod1", }, "Tab", function()
            awesome.emit_signal("bling::window_switcher::turn_on")
        end,
        { description = "Window switcher", group = "bling" }),

    awful.key({ modkey, "Shift" }, "t", function()
            local screen = mouse.screen
            local bar = mytopbar[screen]
            if bar == nil then
                return
            end

            bar.visible = not bar.visible
        end,
        { description = "Toggle topbar", group = "topbar" }),

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
    awful.key({ modkey, "Shift" }, "b", function() awful.spawn("x-www-browser --incognito") end,
        { description = "Open browser", group = "client" }),

    -- Media keys
    awful.key({}, "XF86AudioPlay", function() awful.spawn("playerctl --player playerctld play-pause") end,
        { description = "Play/Pause", group = "media" }),
    awful.key({}, "XF86AudioNext", function() awful.spawn("playerctl --player playerctld next") end,
        { description = "Next", group = "media" }),
    awful.key({}, "XF86AudioPrev", function() awful.spawn("playerctl --player playerctld previous") end,
        { description = "Prev", group = "media" }),
    awful.key({}, "XF86AudioMute", function() awful.spawn("amixer sset Master 1+ toggle") end,
        { description = "Prev", group = "media" }),

    -- Run
    awful.key({ modkey }, "a", function() awful.spawn("rofi -show drun -show-icons") end,
        { description = "Spawn rofi", group = "run" }),
    awful.key({ modkey }, "w", function() awful.spawn("rofi -show window -show-icons") end,
        { description = "Spawn rofi", group = "run" }),
    awful.key({}, "Print", function() awful.spawn("flameshot gui") end,
        { description = "Print screen", group = "run" }),

    -- Background
    awful.key({ modkey, "Control" }, "n", function()
            local command = wallpapers:next_wallpaper()
            awful.spawn(command)
        end,
        { description = "Next image", group = "background" }),
    awful.key({ modkey, "Control" }, "p", function()
            local command = wallpapers:next_wallpaper(-1)
            awful.spawn(command)
        end,
        { description = "Previous image", group = "background" }),

    awful.key({ modkey, "Control" }, "h", function()
            awful.spawn(wallpapers:home_image())
        end,
        { description = "First image", group = "background" })
)

M.clientkeys = gears.table.join(
    awful.key({ modkey, }, "m",
        function(c)
            if c.maximized or c.maximized_horizontal or c.maximized_vertical then
                c.maximized = false
                c.maximized_horizontal = false
                c.maximized_vertical = false
            else
                c.maximized = true
                c.maximized_horizontal = true
                c.maximized_vertical = true
            end
        end,
        { description = "Toggle maximization", group = "client" }),
    awful.key({ modkey, }, "x",
        function(c)
            -- The client currently has the input focus, so it cannot be
            -- minimized, since minimized clients can't have the focus.
            c.minimized = true
        end,
        { description = "Minimize", group = "client" }),

    -- Toggle fullscreen
    awful.key({ modkey, }, "f",
        function(c)
            c.fullscreen = not c.fullscreen
            if c.fullscreen == false then
                c.ontop = c.floating
            end
            c:raise()
        end,
        { description = "Toggle fullscreen", group = "client" }),

    -- Toggle floating on window
    awful.key({ modkey, }, "space", function(c)
            c.floating = not c.floating
            c.ontop = c.floating
        end,
        { description = "Toggle floating", group = "client" }),

    -- Opacity
    awful.key({ modkey, }, ",", function(c)
            change_opacity(c, 0.05)
        end,
        { description = "Opacity up", group = "client" }),

    awful.key({ modkey, }, ".", function(c)
            change_opacity(c, -0.05)
        end,
        { description = "Opacity down", group = "client" }),

    awful.key({ modkey, }, "-", function(c)
            if c.opacity == 1.0 then
                c.opacity = 0.65
            elseif c.opacity ~= 1.0 then
                c.opacity = 1.0
            end
        end,
        { description = "Opacity toggle", group = "client" }),

    awful.key({ modkey, }, "o", function(c)
            c.sticky = not c.sticky
        end,
        { description = "Sticky toggle", group = "client" })
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
