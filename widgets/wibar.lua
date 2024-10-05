local awful = require("awful")
local wibox = require("wibox")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local widget_padding = 20
local wibar_height = 24

-- Widget imports
local mytaglist = require("widgets.taglist")
local mysystray = require("widgets.systray")
-- local mybattery = require("widgets.battery")
local mynetwork = require("widgets.network")
local mymemory = require("widgets.memory")
-- local mycpu = require("widgets.cpu")
local mytextclock = require("widgets.textclock")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
-- local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")

local mylogoutmenu = logout_menu_widget()
-- local mybatterywidget = batteryarc_widget()

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")

-- Activated widgets
local right_widgets = {
    mysystray,
    spotify_widget(),
    mymemory,
    cpu_widget({color = "#ffffff"}),
    mynetwork,
    mytextclock,
    -- mybatterywidget,
    mylogoutmenu,
}

local wibar = {}

function wibar.get(s)
    local mywibox = awful.wibar({
        position = "top",
        screen = s,
        height = dpi(wibar_height)
    })

    local taglist = mytaglist.get(s)

    -- TODO modular left widgets
    local left = {
        layout = wibox.layout.fixed.horizontal,
        taglist
    }

    local right = {
        layout = wibox.layout.fixed.horizontal,
    }

    for _, v in ipairs(right_widgets) do
        right[#right + 1] = ({
            v,
            left = widget_padding,
            right = widget_padding,
            widget = wibox.container.margin
        })
    end

    -- Add widgets to the wibox
    mywibox:setup {
        layout = wibox.layout.align.horizontal,
        { -- Left widgets
            left,
            -- left = 20,
            right = 10,
            widget = wibox.container.margin
        },
        { -- Middle widgets
            layout = wibox.layout.align.horizontal,
        },
        { -- Right widgets
            right,
            right = 10,
            widget = wibox.container.margin
        }
    }

    return mywibox
end

return wibar
