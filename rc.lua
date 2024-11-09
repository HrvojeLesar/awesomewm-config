-- Standard awesome library
local gears = require("gears")
local awful = require("awful")
local hotkeys_popup = require("awful.hotkeys_popup")
require("awful.autofocus")

-- Widget and layout library
local wibox = require("wibox")

-- Theme handling library
local beautiful = require("beautiful")

-- {{{ Variable definitions
-- Themes define colours, icons, font and wallpapers.
local theme_path = string.format("%s/.config/awesome/themes/%s/theme.lua", os.getenv("HOME"), "default")
beautiful.init(theme_path)

local bling = require("bling")
bling.widget.window_switcher.enable({
    type = "thumbnail", -- set to anything other than "thumbnail" to disable client previews

    -- keybindings (the examples provided are also the default if kept unset)
    hide_window_switcher_key = "Escape",                      -- The key on which to close the popup
    minimize_key = "n",                                       -- The key on which to minimize the selected client
    unminimize_key = "N",                                     -- The key on which to unminimize all clients
    kill_client_key = "q",                                    -- The key on which to close the selected client
    cycle_key = "Tab",                                        -- The key on which to cycle through all clients
    previous_key = "Left",                                    -- The key on which to select the previous client
    next_key = "Right",                                       -- The key on which to select the next client
    vim_previous_key = "j",                                   -- Alternative key on which to select the previous client
    vim_next_key = "k",                                       -- Alternative key on which to select the next client

    cycleClientsByIdx = awful.client.focus.byidx,             -- The function to cycle the clients
    filterClients = awful.widget.tasklist.filter.currenttags, -- The function to filter the viewed clients
})

-- Notification library
local naughty = require("naughty")
local menubar = require("menubar")

local wibar = require("widgets.wibar")
local json = require("util.json")
local keys = require("keys")

local wallpapers = require("wallpapers.wallpapers")

-- {{{ Error handling
-- Check if awesome encountered an error during startup and fell back to
-- another config (This code will only ever execute for the fallback config)
if awesome.startup_errors then
    naughty.notify({
        preset = naughty.config.presets.critical,
        title = "Oops, there were errors during startup!",
        text = awesome.startup_errors
    })
end

-- Handle runtime errors after startup
do
    local in_error = false
    awesome.connect_signal("debug::error", function(err)
        -- Make sure we don't go into an endless error loop
        if in_error then return end
        in_error = true

        naughty.notify({
            preset = naughty.config.presets.critical,
            title = "Oops, an error happened!",
            text = tostring(err)
        })
        in_error = false
    end)
end
-- }}}


-- This is used later as the default terminal and editor to run.
terminal = "x-terminal-emulator"
editor = os.getenv("EDITOR") or "nvim"
editor_cmd = terminal .. " -e " .. editor

-- Layouts.
awful.layout.layouts = {
    awful.layout.suit.tile.right,
    awful.layout.suit.tile.left,
}

-- }}}

-- {{{ Menu
-- Create a launcher widget and a main menu
local myawesomemenu = {
    { "hotkeys",     function() hotkeys_popup.show_help(nil, awful.screen.focused()) end },
    { "manual",      terminal .. " -e man awesome" },
    { "edit config", editor_cmd .. " " .. awesome.conffile },
    { "restart",     awesome.restart },
    { "quit",        function() awesome.quit() end },
}

mymainmenu = awful.menu({
    items = { { "awesome", myawesomemenu, beautiful.awesome_icon },
        { "open terminal", terminal }
    }
})

local mylauncher = awful.widget.launcher({
    image = beautiful.awesome_icon,
    menu = mymainmenu
})

local menu_awesome = { "awesome", myawesomemenu, beautiful.awesome_icon }
local menu_terminal = { "open terminal", terminal }

-- Menubar configuration
menubar.utils.terminal = terminal -- Set the terminal for applications that require it
-- }}}

-- Keyboard map indicator and switcher
local mykeyboardlayout = awful.widget.keyboardlayout()

-- Re-set wallpaper when a screen's geometry changes (e.g. different resolution)
screen.connect_signal("property::geometry", function(s)
    wallpapers:set_wallpaper(nil, s)
end)

mytopbar = {}
awful.screen.connect_for_each_screen(function(s)
    -- Wallpaper
    wallpapers:set_wallpaper(nil, s)

    -- Each screen has its own tag table.
    awful.tag({ "1", "2", "3", "4", "5" }, s, awful.layout.layouts[1])

    mytopbar[s] = wibar.get(s)
end)

-- {{{ Mouse bindings
root.buttons(gears.table.join(
    awful.button({}, 3, function() mymainmenu:toggle() end),
    awful.button({}, 4, awful.tag.viewnext),
    awful.button({}, 5, awful.tag.viewprev)
))
-- }}}

root.keys(keys.globalkeys)
awful.rules.rules = require("rules")

-- {{{ Signals
-- Signal function to execute when a new client appears.
client.connect_signal("manage", function(c)
    -- Set the windows at the slave,
    -- i.e. put it at the end of others instead of setting it master.
    -- if not awesome.startup then awful.client.setslave(c) end

    if awesome.startup
        and not c.size_hints.user_position
        and not c.size_hints.program_position then
        -- Prevent clients from being unreachable after screen count changes.
        awful.placement.no_offscreen(c)
    end
end)

local function update_titlebars(c)
    local file = io.open(string.format("%s/.config/awesome/client_colors.json", os.getenv("HOME")), "rb")
    local client_color = {}

    if file ~= nil then
        client_color = json.decode(file:read("*all"))[c.class] or
            { focus = "#3c3c3c", normal = "#303030", focus_top = "#3c3c3c", normal_top = "#303030" }
        file:close()
    end

    if c.floating then
        client_color["focus_top"] = "#01949a"
        client_color["normal_top"] = "#004369"
        client_color["focus"] = "#01949a"
        client_color["normal"] = "#004369"
    end

    if c.maximized then
        client_color["focus_top"] = "#f7bec0"
        client_color["normal_top"] = "#e9eae0"
        client_color["focus"] = "#f7bec0"
        client_color["normal"] = "#e9eae0"
    end

    if c.sticky then
        client_color["focus_top"] = "#db1f48"
        client_color["normal_top"] = "#e5ddc8"
        client_color["focus"] = "#db1f48"
        client_color["normal"] = "#e5ddc8"
    end

    awful.titlebar(c, {
        position = "top",
        size = 2,
        bg_focus = client_color["focus_top"],
        bg_normal = client_color["normal_top"],
    }):setup {
        layout = wibox.layout.align.horizontal
    }

    for _, v in ipairs({ "right", "bottom", "left" }) do
        awful.titlebar(c, {
            position = v,
            size = beautiful.inner_border_width,
            bg_focus = client_color["focus"],
            bg_normal = client_color["normal"],
        }):setup({
            layout = wibox.layout.align.horizontal
        })
    end
end

-- Add a titlebar if titlebars_enabled is set to true in the rules.
client.connect_signal("request::titlebars", function(c)
    update_titlebars(c)
end)

client.connect_signal("property::sticky", function(c)
    update_titlebars(c)
end)

client.connect_signal("property::floating", function(c)
    update_titlebars(c)
end)


-- -- Enable sloppy focus, so that focus follows mouse.
-- client.connect_signal("mouse::enter", function(c)
--     c:emit_signal("request::activate", "mouse_enter", { raise = false })
-- end)

client.connect_signal("focus", function(c)
    c.border_color = beautiful.border_focus
    if not c.fullscreen then
        c.ontop = c.floating
    end
    c:raise()
end)

client.connect_signal("unfocus", function(c) c.border_color = beautiful.border_normal end)
-- }}}

-- Autostart
wallpapers:set_wallpaper()
-- awful.spawn.with_shell("feh --bg-max ~/.config/awesome/wallpapers/exarch.webp")
-- awful.spawn.with_shell("feh --bg-max ~/.config/awesome/wallpapers/W.jpeg")
awful.spawn.with_shell("xset r rate 225 33")
awful.spawn.with_shell("numlockx on")
awful.spawn.with_shell("diodon")
awful.spawn.with_shell("picom")
-- awful.spawn.with_shell("sxhkd")

gears.timer {
    timeout = 30,
    autostart = true,
    callback = function() collectgarbage() end
}

client.connect_signal("property::minimized", function(c)
    if c.instance == nil then
        return
    end
    if string.find(c.instance, "War Thunder") then
        c.minimized = false
    end
end)
