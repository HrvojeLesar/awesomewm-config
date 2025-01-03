local awful = require("awful")
local beautiful = require("beautiful")
local keys = require("keys")
local naughty = require("naughty")

local M = {}

local function discord_screen()
    for s in screen do
        if s.index == 2 then
            return 2
        end
    end

    return 1
end

M = {
    -- All clients will match this rule.
    {
        rule = {},
        properties = {
            border_width = beautiful.border_width,
            border_color = beautiful.border_normal,
            focus = awful.client.focus.filter,
            raise = true,
            keys = keys.clientkeys,
            buttons = keys.clientbuttons,
            screen = awful.screen.preferred,
            placement = awful.placement.no_overlap + awful.placement.no_offscreen,
        }
    },
    {
        rule = { instance = "discord" },
        properties = {
            tag = "3",
            screen = discord_screen()
        }
    },
    {
        rule = { instance = "spotify" },
        properties = { tag = "2" }
    },
    {
        rule = { instance = "steam" },
        properties = { tag = "3" }
    },
    {
        rule_any = {
            name = {
                "Friends List",
                "Special Offers",
            }
        },
        properties = {
            tag = "3",
            ontop = true,
            floating = true,
        }
    },

    -- Floating clients.
    -- {
    --     rule_any = {
    --         instance = {
    --             "DTA",   -- Firefox addon DownThemAll.
    --             "copyq", -- Includes session name in class.
    --             "pinentry",
    --         },
    --         class = {
    --             "Arandr",
    --             "Blueman-manager",
    --             "Gpick",
    --             "Kruler",
    --             "MessageWin",  -- kalarm.
    --             "Sxiv",
    --             "Tor Browser", -- Needs a fixed window size to avoid fingerprinting by screen size.
    --             "Wpa_gui",
    --             "veromix",
    --             "xtightvncviewer"
    --         },
    --
    --         -- Note that the name property shown in xprop might be set slightly after creation of the client
    --         -- and the name shown there might not match defined rules here.
    --         name = {
    --             "Event Tester", -- xev.
    --         },
    --         role = {
    --             "AlarmWindow",   -- Thunderbird's calendar.
    --             "ConfigManager", -- Thunderbird's about:config.
    --             "pop-up",        -- e.g. Google Chrome's (detached) Developer Tools.
    --         }
    --     },
    --     properties = { floating = true, placement = awful.placement.centered }
    -- },

    -- Add titlebars to normal clients and dialogs
    {
        rule_any = {
            type = {
                "normal",
                "dialog"
            }
        },
        properties = { titlebars_enabled = true }
    },
}

return M
