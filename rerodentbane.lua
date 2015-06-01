-- {{{ rodentbane reborn
--
-- Library that implement mouse-less mouse navigation
--
-- @author Alex Zaslavsky
-- based on original rodentbane by Lucas de Vries
--
-- @copyright 2015
--
-- Licensed under WTFPL
--
-- }}}

-- {{{ Requires
local awful = require("awful")
local beautiful = require("beautiful")
local naughty = require("naughty")
local wibox = require("wibox")
-- }}}

-- {{{ Grab environment
local ipairs = ipairs
local pairs = pairs
local type = type
local tonumber = tonumber
local tostring = tostring
local unpack = unpack
local math = math
local table = table
local awful = awful
local os = os
local io = io
local string = string
-- }}}

-- {{{ CAPI
local capi = {
    root = root,
    awesome = awesome,
    screen = screen,
    client = client,
    mouse = mouse,
    button = button,
    titlebar = titlebar,
    widget = widget,
    hooks = hooks,
    keygrabber = keygrabber,
    widget = widget,
}
-- }}}

local rerodentbane = {}
-- {{{ Utilities for controlling the cursor
    -- {{{ local data
local bindings = {}
local history = {}
local current = nil
local wiboxes = nil
    -- }}}
-- }}}

-- {{{ Debug func
local function debuginfo( message )

    mm = message

    if not message then
        mm = "false"
    end

    nid = naughty.notify({ text = tostring(mm), timeout = 10 })
end
-- }}}

-- {{{ Clean wiboxes
local function clean()
    -- Hide all wiboxes
    for border, box in pairs(wiboxes) do
        box.visible = false
        box.screen = nil
    end
end
-- }}}

-- {{{ Stop the navigation sequence without doing anything.
local function stop()
    -- Stop the keygrabber
    capi.keygrabber.stop()
    clean()
end
-- }}}

-- {{{ Crete the wiboxes to display init()
local function init()
    -- Wiboxes table
    wiboxes = {}

    -- Borders
    local borders = {"horiz1", "vert1", "horiz2", "vert2", "left", "right", "top", "bottom"}

    -- Create wibox for each border
    for i, border in ipairs(borders) do
        wiboxes[border] = wibox({
            bg = beautiful.rodentbane_bg or beautiful.border_focus or "#C50B0B",
            ontop = true,
        })
    end
end
-- }}}

-- {{{ Draw the guidelines on screen using wiboxes.
-- @param area The area of the screen to draw on, defaults to current area.
local function draw(area)
    -- Default to current area
    local ar = area or current
    -- Get numbers
    local rwidth = beautiful.rodentbane_width or 1

    -- Stop if the area is too small
    if ar.width < rwidth*4 or ar.height < rwidth*4 then
        stop()
        return false
    end

    -- Put the wiboxes on the correct screen
    for border, box in pairs(wiboxes) do
        box.screen = ar.screen
    end

    clean()

    -- {{{ Layout
    -- {{{ Horizontal border top
    wiboxes.horiz1:geometry({
        x = ar.x+rwidth,
        y = ar.y+math.floor(ar.height/3),
        height = rwidth,
        width = ar.width-(rwidth*3),
    })
    -- }}}

    -- {{{ Horizontal border bottom
    wiboxes.horiz2:geometry({
        x = ar.x+rwidth,
        y = (ar.y+math.floor(ar.height/3*2)),
        height = rwidth,
        width = ar.width-(rwidth*3),
    })
    -- }}}

    -- {{{ Vertical border left
    wiboxes.vert1:geometry({
        x = ar.x+math.floor(ar.width/3),
        y = ar.y+rwidth,
        width = rwidth,
        height = ar.height-(rwidth*3),
    })
    -- }}}

    -- {{{ Vertical border right
    wiboxes.vert2:geometry({
        x = ar.x+math.floor(ar.width/3*2),
        y = ar.y+rwidth,
        width = rwidth,
        height = ar.height-(rwidth*3),
    })
    -- }}}

    -- {{{ Left border
    wiboxes.left:geometry({
        x = ar.x,
        y = ar.y,
        width = rwidth,
        height = ar.height,
    })
    -- }}}

    -- {{{ Right border
    wiboxes.right:geometry({
        x = ar.x+ar.width-rwidth,
        y = ar.y,
        width = rwidth,
        height = ar.height,
    })
    -- }}}

    -- {{{ Top border
    wiboxes.top:geometry({
        x = ar.x,
        y = ar.y,
        height = rwidth,
        width = ar.width,
    })
    -- }}}

    -- {{{ Bottom border
    wiboxes.bottom:geometry({
        x = ar.x,
        y = ar.y+ar.height-rwidth,
        height = rwidth,
        width = ar.width,
    })
    -- }}}
    -- }}}
    for k, v in pairs(wiboxes) do v.visible = true end
end
-- }}}

-- {{{ Cut the navigation area into a direction.
-- @param dir Direction to cut to {"tl", "tm", "tr", "ml", "mm", "mr", "bl", "bm", "br"}.
local function cut(dir)
    -- Store previous area
    table.insert(history, 1, awful.util.table.join(current))

    if dir == "tl" then
        ;
    elseif dir == "tm" then
        current.x = current.x + math.floor(current.width/3)
    elseif dir == "tr" then
        current.x = current.x + (math.floor(current.width/3 * 2))
    elseif dir == "ml" then
        current.y = current.y + math.floor(current.height/3)
    elseif dir == "mm" then
        current.y = current.y + math.floor(current.height/3)
        current.x = current.x + math.floor(current.width/3)
    elseif dir == "mr" then
        current.y = current.y + math.floor(current.height/3)
        current.x = current.x + (math.floor(current.width/3 * 2))
    elseif dir == "bl" then
        current.y = current.y + (math.floor(current.height/3 * 2))
    elseif dir == "bm" then
        current.y = current.y + (math.floor(current.height/3 * 2))
        current.x = current.x + (math.floor(current.width/3))
    elseif dir == "br" then
        current.y = current.y + (math.floor(current.height/3 * 2))
        current.x = current.x + (math.floor(current.width/3))
    end
    current.height = math.floor(current.height/3)
    current.width = math.floor(current.width/3)

    -- Redraw the box
    draw()
end
-- }}}

-- {{{ Move the navigation area in a direction.
-- @param dir Direction to move to {"up", "right", "down", "left"}.
-- @param ratio Ratio of movement, multiplied by the size of the current area,
-- defaults to 0.5 (ie. half the area size.
local function move(dir, ratio)
    -- Store previous area
    table.insert(history, 1, awful.util.table.join(current))

    -- Default to ratio 0.5
    local rt = ratio or 0.5

    -- Move to a direction
    if dir == "up" then
        current.y = current.y-math.floor(current.height*rt)
    elseif dir == "down" then
        current.y = current.y+math.floor(current.height*rt)
    elseif dir == "left" then
        current.x = current.x-math.floor(current.width*rt)
    elseif dir == "right" then
        current.x = current.x+math.floor(current.width*rt)
    end

    -- Redraw the box
    draw()
end
-- }}}

--{{{ Bind a key in rodentbane mode.
-- @param modkeys Modifier key combination to bind to.
-- @param key Main key to bind to.
-- @param func Function to bind the keys to.
local function bind(modkeys, key, func)
    -- Create binding
    local bind = {modkeys, key, func}

    -- Add to bindings table
    table.insert(bindings, bind)
end
-- }}}

-- {{{ Check if two tables have the same values.
-- @param t1 First table to check.
-- @param t2 Second table to check.
-- @return True if the tables are equivalent, false otherwise.
local function table_equals(t1, t2)
    -- Check first table
    for i, item in ipairs(t1) do
        if item ~= "Mod2" and
           awful.util.table.hasitem(t2, item) == nil then
            -- An unequal item was found
            return false
        end
    end

    -- Check second table
    for i, item in ipairs(t2) do
        if item ~= "Mod2" and
           awful.util.table.hasitem(t1, item) == nil then
            -- An unequal item was found
            return false
        end
    end

    -- All items were equal
    return true
end
-- }}}

-- {{{ Warp the mouse to the center of the navigation area
local function warp()
    capi.mouse.coords({
        x = current.x+(current.width/2),
        y = current.y+(current.height/2),
    })
end
-- }}}

-- {{{ Click with a button
-- @param button Button number to click with, defaults to left (1)
local function click(button)
    -- Default to left click
    local b = button or 1

    -- TODO: Figure out a way to use fake_input for clicks
    --capi.root.fake_input("button_press", button)
    --capi.root.fake_input("button_release", button)

    -- Use xdotool when available, otherwise try xte
    command = "xdotool click "..b.." &> /dev/null"
      .." || xte 'mouseclick "..b.."' &> /dev/null"
      .." || echo 'W: rodentbane: either xdotool or xte"
      .." is required to emulate mouse clicks, neither was found.'"

    awful.util.spawn_with_shell(command)
end
-- }}}

--{{{ Undo a change to the area
local function undo()
    -- Restore area
    if #history > 0 then
        current = history[1]
        table.remove(history, 1)

        draw()
    end
end
-- }}}

--{{{ Convenience function to bind to default keys.
local function binddefault()
    -- Cut with hjkl
    bind({}, "u", {cut, "tl"})
    bind({}, "i", {cut, "tm"})
    bind({}, "o", {cut, "tr"})
    bind({}, "j", {cut, "ml"})
    bind({}, "k", {cut, "mm"})
    bind({}, "l", {cut, "mr"})
    bind({}, "m", {cut, "bl"})
    bind({}, ",", {cut, "bm"})
    bind({}, ".", {cut, "br"})

    -- Move with Shift+hjkl
    bind({"Shift"}, "h", {move, "left"})
    bind({"Shift"}, "j", {move, "down"})
    bind({"Shift"}, "k", {move, "up"})
    bind({"Shift"}, "l", {move, "right"})

    -- Undo with p
    bind({}, "p", undo)

    -- Left click with space
    bind({}, "Space", function ()
        warp()
        click()
        stop()
    end)

    -- Double Left click with ctrl+space
    bind({"Control"}, "Space", function ()
        warp()
        click()
        click()
        stop()
    end)

    -- Middle click with shift+space
    bind({"Shift"}, "Space", function ()
        warp()
        click(2)
        stop()
    end)

    -- Right click with alt+space
    bind({"Mod1"}, "Space", function ()
        warp()
        click(3)
        stop()
    end)

    -- Only warp with return
    bind({}, "Return", function ()
        warp()
    end)
end
-- }}}

-- {{{ Callback function for the keygrabber.
-- @param modkeys Modkeys that were pressed.
-- @param key Main key that was pressed.
-- @param evtype Pressed or released event.
local function keyevent(modkeys, key, evtype)
    -- Ignore release events and modifier keys
    if evtype == "release"
       or key == "Shift_L"
       or key == "Shift_R"
       or key == "Control_L"
       or key == "Control_R"
       or key == "Super_L"
       or key == "Super_R"
       or key == "Hyper_L"
       or key == "Hyper_R"
       or key == "Alt_L"
       or key == "Alt_R"
       or key == "Meta_L"
       or key == "Meta_R"
    then
        return true
    end

    -- Special cases for printable characters
    -- HACK: Maybe we need a keygrabber that gives keycodes ?
    if key == " " then
        key = "Space"
    end

    -- Figure out what to call
    for ind, bind in ipairs(bindings) do
        if bind[2]:lower() == key:lower()
           and table_equals(bind[1], modkeys)
        then
            -- Call the function
            if type(bind[3]) == "table" then
                -- Allow for easy passing of arguments
                local func = bind[3][1]
                local args = {}

                -- Add the rest of the arguments
                for i, arg in ipairs(bind[3]) do
                    if i > 1 then
                        table.insert(args, arg)
                    end
                end

                -- Call function with args
                func(unpack(args))
            else
                -- Call function directly
                bind[3]()
            end

            -- A bind was found, continue grabbing
            return true
        end
    end

    -- No key was found, stop grabbing
    stop()
    return false
end
-- }}}

-- {{{ Start the navigation sequence.
-- @param screen Screen to start navigation on, defaults to current screen.
-- @param recall Whether the previous area should be recalled (defaults to
-- false).
function rerodentbane.start(screen, recall)
    -- Default to current screen
    local scr = screen or capi.mouse.screen

    -- Initialise if not already done
    if wiboxes == nil then
        -- Add default bindings if we have none ourselves
        if #bindings == 0 then
            binddefault()
        end

        -- Create the wiboxes
        init()
    end

    -- Empty current area if needed
    if not recall then
        -- Start with a complete area
        current = capi.screen[scr].workarea

        -- Empty history
        history = {}
    end

    -- Move to the right screen
    current.screen = scr

    -- Draw the box
    draw()

    -- Start the keygrabber
    capi.keygrabber.run(keyevent)

end
-- }}}


setmetatable(rerodentbane, { __call = function(_, ...) return rerodentbane.start(...) end })
return rerodentbane
-- vim: set ts=4 sw=4 tw=0 et foldmethod=marker foldmarker={{{,}}} :
