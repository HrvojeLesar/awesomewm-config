local wibox = require("wibox")

local textclock = {
    format = "%a %d %b %H:%M:%S",
    widget = wibox.widget.textclock,
    refresh = 1
}

return textclock
