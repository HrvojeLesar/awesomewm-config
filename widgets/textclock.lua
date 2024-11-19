local wibox = require("wibox")

local textclock = wibox.widget({
    format = "%a %d %b %H:%M:%S",
    widget = wibox.widget.textclock,
    refresh = 1
})

local calendar_widget = require("awesome-wm-widgets.calendar-widget.calendar")

local cw = calendar_widget({
    placement = "top_right",
    auto_hide = true,
})

textclock:connect_signal("button::press",
    function(_, _, _, button)
        if button == 1 then
            cw.toggle()
        end
    end
)

return textclock
