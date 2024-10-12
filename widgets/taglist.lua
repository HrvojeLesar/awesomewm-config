local gears = require("gears")
local awful = require("awful")
local wibox = require("wibox")
local beautiful = require("beautiful")
local xresources = require("beautiful.xresources")
local dpi = xresources.apply_dpi

local taglist = {}

local taglist_padding = 22

local taglist_buttons = gears.table.join(
    awful.button({}, 1, function(t) t:view_only() end),
    awful.button({ modkey }, 1, function(t)
        if client.focus then
            client.focus:move_to_tag(t)
        end
    end),
    awful.button({}, 3, awful.tag.viewtoggle),
    awful.button({ modkey }, 3, function(t)
        if client.focus then
            client.focus:toggle_tag(t)
        end
    end),
    awful.button({}, 4, function(t) awful.tag.viewnext(t.screen) end),
    awful.button({}, 5, function(t) awful.tag.viewprev(t.screen) end)
)

local function get_minimized_clients_count(tag)
    local clients = tag:clients()

    local minimized_client_count = 0
    for _, client in ipairs(clients) do
        if client.minimized then
            minimized_client_count = minimized_client_count + 1
        end
    end

    return minimized_client_count
end

local function create_callback(widget, tag, _, _)
    local counter = widget:get_children_by_id('minimized_counter')[1]

    local minimized_client_count = get_minimized_clients_count(tag)

    if minimized_client_count == 0 then
        widget:get_children_by_id('layout_container')[1].spacing = 0
        counter.visible = false
        return
    end

    widget:get_children_by_id('layout_container')[1].spacing = 10
    widget:get_children_by_id('minimized_counter_text')[1].text = tostring(minimized_client_count)
    counter.visible = true
end

function taglist.get(s)
    local widget = awful.widget.taglist({
        screen          = s,
        filter          = awful.widget.taglist.filter.all,
        widget_template = {
            {
                {
                    {
                        {
                            id = 'text_role',
                            widget = wibox.widget.textbox
                        },
                        left = dpi(taglist_padding),
                        right = dpi(taglist_padding),
                        widget = wibox.container.background
                    },
                    {
                        {
                            {
                                id = "minimized_counter_text",
                                widget = wibox.widget.textbox,
                                text = "",
                                font = beautiful.font,
                            },
                            margins = 8,
                            widget  = wibox.container.margin,
                        },
                        id      = "minimized_counter",
                        bg      = beautiful.bg_normal,
                        shape   = gears.shape.circle,
                        widget  = wibox.container.background,
                        visible = false,
                    },
                    id = "layout_container",
                    layout = wibox.layout.fixed.horizontal,
                },
                left = dpi(taglist_padding),
                right = dpi(taglist_padding),
                widget = wibox.container.margin
            },
            id = 'background_role',
            widget = wibox.container.background,
            create_callback = create_callback,
            update_callback = create_callback
        },
        buttons         = taglist_buttons
    })

    return widget
end

return taglist
