local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi
local lain = require("lain")

local widget_padding = 20
local wibar_height = 24

-- Widget imports
local mytaglist = require("widgets.taglist")
local mysystray = require("widgets.systray")
-- local mybattery = require("widgets.battery")
local mymemory = require("widgets.memory")
-- local mycpu = require("widgets.cpu")
local mytextclock = require("widgets.textclock")
local myplayerctdl = require("widgets.playerctld")
local logout_menu_widget = require("awesome-wm-widgets.logout-menu-widget.logout-menu")
-- local batteryarc_widget = require("awesome-wm-widgets.batteryarc-widget.batteryarc")

local mylogoutmenu = logout_menu_widget()
-- local mybatterywidget = batteryarc_widget()

local cpu_widget = require("awesome-wm-widgets.cpu-widget.cpu-widget")
local spotify_widget = require("awesome-wm-widgets.spotify-widget.spotify")

local function layoutbox(s)
    local mylayoutbox = awful.widget.layoutbox(s)
    mylayoutbox:buttons(awful.util.table.join(
        awful.button({}, 1, function() awful.layout.inc(1) end),
        awful.button({}, 3, function() awful.layout.inc(-1) end)))

    return mylayoutbox
end

local layoutbox_widget = "layoutbox"

local volume_widget = require('awesome-wm-widgets.volume-widget.volume')
local myvolumewidget = volume_widget(
    {
        widget_type = "arc",
        mute_color = beautiful.bg_urgent,
    })

local network_widget = lain.widget.net({
    settings = function()
        widget:set_markup(net_now.received .. " ↓↑ " .. net_now.sent)
    end
})

-- Activated widgets
local right_widgets = {
    mysystray,
    myplayerctdl,
    spotify_widget(),
    mymemory,
    network_widget,
    cpu_widget({ color = "#ffffff" }),
    myvolumewidget,
    -- layoutbox_widget,
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

    local left = {
        layout = wibox.layout.fixed.horizontal,
        taglist
    }

    local right = {
        layout = wibox.layout.fixed.horizontal,
    }

    for _, v in ipairs(right_widgets) do
        if v == "layoutbox" then
            v = layoutbox(s)
        end
        right[#right + 1] = ({
            v,
            left = widget_padding,
            right = widget_padding,
            widget = wibox.container.margin
        })
    end

    -- Add widgets to the wibox
    mywibox:setup({
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
    })

    return mywibox
end

return wibar
