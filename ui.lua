return function()
    local M = {}

    local items = {
        {name = "Files", app = "apps/files.lua"},
        {name = "Notes", app = "apps/notes.lua"},
        {name = "Settings", app = "apps/settings.lua"},
        {name = "Games", app = "apps/games.lua"},
        {name = "Shell", app = "shell"},
        {name = "Lock", app = "__lock"},
        {name = "Reboot", app = "__reboot"},
        {name = "Shutdown", app = "__shutdown"}
    }

    local function center(y, text, tc, bg)
        local w, h = term.getSize()
        if bg then term.setBackgroundColor(bg) end
        if tc then term.setTextColor(tc) end
        term.setCursorPos(math.floor((w - #text) / 2) + 1, y)
        write(text)
    end

    local function fill(x, y, w, h, bg, ch, tc)
        term.setBackgroundColor(bg)
        if tc then term.setTextColor(tc) end
        for yy = y, y + h - 1 do
            term.setCursorPos(x, yy)
            write(string.rep(ch or " ", w))
        end
    end

    local function drawButton(x, y, w, h, text, bg, tc)
        fill(x, y, w, h, bg, " ", tc)
        term.setCursorPos(x + math.floor((w - #text) / 2), y + math.floor(h / 2))
        write(text)
    end

    local function topbar(config)
        local w, h = term.getSize()
        fill(1, 1, w, 1, config.theme.top, " ", colors.white)
        term.setCursorPos(2, 1)
        write("Chemodan OS v2")
        local tm = textutils.formatTime(os.time(), true)
        term.setCursorPos(w - #tm - 1, 1)
        write(tm)
    end

    local function getGrid()
        return {
            {x = 3,  y = 4,  w = 14, h = 3},
            {x = 20, y = 4,  w = 14, h = 3},
            {x = 3,  y = 8,  w = 14, h = 3},
            {x = 20, y = 8,  w = 14, h = 3},
            {x = 3,  y = 12, w = 14, h = 3},
            {x = 20, y = 12, w = 14, h = 3},
            {x = 3,  y = 16, w = 14, h = 3},
            {x = 20, y = 16, w = 14, h = 3}
        }
    end

    local function drawDesktop(config, selected)
        local w, h = term.getSize()
        term.setBackgroundColor(config.theme.bg)
        term.clear()

        topbar(config)

        term.setBackgroundColor(config.theme.bg)
        term.setTextColor(config.theme.text)
        term.setCursorPos(3, 2)
        write("PC: " .. config.computerName)

        local grid = getGrid()

        for i, item in ipairs(items) do
            local g = grid[i]
            local bg = config.theme.window
            local tc = colors.black

            if i == selected then
                bg = config.theme.accent
                tc = colors.white
            end

            drawButton(g.x, g.y, g.w, g.h, item.name, bg, tc)
        end

        term.setBackgroundColor(colors.black)
        term.setTextColor(colors.white)
        term.setCursorPos(1, h)
        term.clearLine()
        term.setCursorPos(2, h)
        write("Arrows/Enter or Mouse")
    end

    local function runItem(config, item)
        if item.app == "__lock" then
            return "lock"
        elseif item.app == "__reboot" then
            os.reboot()
        elseif item.app == "__shutdown" then
            os.shutdown()
        elseif item.app == "shell" then
            term.setBackgroundColor(colors.black)
            term.setTextColor(colors.white)
            term.clear()
            term.setCursorPos(1,1)
            shell.run("shell")
        else
            shell.run(item.app)
        end
    end

    function M.splash(config)
        local w, h = term.getSize()
        term.setBackgroundColor(config.theme.bg)
        term.clear()
        center(math.floor(h / 2) - 1, "CHEMODAN OS", colors.white, config.theme.bg)
        center(math.floor(h / 2), "v2", colors.yellow, config.theme.bg)
        center(math.floor(h / 2) + 2, "Loading...", config.theme.text, config.theme.bg)
        sleep(1)
    end

    function M.desktop(config)
        local selected = 1

        while true do
            drawDesktop(config, selected)
            local e, a, b, c = os.pullEvent()

            if e == "key" then
                if a == keys.left then
                    selected = selected - 1
                    if selected < 1 then selected = #items end
                elseif a == keys.right then
                    selected = selected + 1
                    if selected > #items then selected = 1 end
                elseif a == keys.up then
                    selected = selected - 2
                    if selected < 1 then selected = #items + selected end
                elseif a == keys.down then
                    selected = selected + 2
                    if selected > #items then selected = selected - #items end
                elseif a == keys.enter then
                    local result = runItem(config, items[selected])
                    if result == "lock" then
                        return
                    end
                end

            elseif e == "mouse_click" then
                local btn, mx, my = a, b, c
                local grid = getGrid()

                for i, g in ipairs(grid) do
                    if mx >= g.x and mx <= g.x + g.w - 1 and my >= g.y and my <= g.y + g.h - 1 then
                        selected = i
                        drawDesktop(config, selected)
                        sleep(0.08)
                        local result = runItem(config, items[selected])
                        if result == "lock" then
                            return
                        end
                    end
                end
            end
        end
    end

    return M
end()
