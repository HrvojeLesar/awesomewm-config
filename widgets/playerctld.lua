local awful = require("awful")
local wibox = require("wibox")
local watch = require("awful.widget.watch")

local playerctld_widget = wibox.widget({
    widget = wibox.widget.textbox
})

local NEXT_PLAYER = "playerctld shift"
local PREVIOUS_PLAYER = "playerctld unshift"
local LIST_PLAYERS = "playerctl -l"

local function update_widget_text(widget, stdout, _, _, _)
    local end_of_line_idx = string.find(stdout, "\n")
    if end_of_line_idx == string.len(stdout) or stdout == nil then
        widget.markup = ""
        widget:set_visible(false)
    else
        local markup = string.sub(stdout, 1, end_of_line_idx)
        local dot_idx = string.find(markup, ".", 1, true)
        if dot_idx  then
            markup = string.sub(stdout, 1, dot_idx - 1)
        end
        widget.markup = markup
        widget:set_visible(true)
    end
end

playerctld_widget:connect_signal("button::press", function(_, _, _, button)
    if button == 1 then
        awful.spawn.easy_async(NEXT_PLAYER, function(_, _, _, _) end)
        awful.spawn.easy_async(LIST_PLAYERS,
            function(stdout, _, _, _) update_widget_text(playerctld_widget, stdout, _, _, _) end)
    end
    if button == 3 then
        awful.spawn.easy_async(PREVIOUS_PLAYER, function(_, _, _, _) end)
        awful.spawn.easy_async(LIST_PLAYERS,
            function(stdout, _, _, _) update_widget_text(playerctld_widget, stdout, _, _, _) end)
    end
end)

watch(LIST_PLAYERS, 1, update_widget_text, playerctld_widget)

return playerctld_widget
