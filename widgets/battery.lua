local wibox = require("wibox")
local beautiful = require("beautiful")
require("status.battery")

local battery = wibox.widget {
    widget = wibox.widget.textbox
}

awesome.connect_signal("status::battery", function(capacity, charging)
    battery.font = beautiful.font
    local markup = capacity .. "%"

    battery.markup = markup
end)

return battery
