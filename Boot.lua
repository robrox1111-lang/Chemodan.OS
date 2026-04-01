local config = dofile("system/config.lua")
local login = dofile("system/login.lua")
local ui = dofile("system/ui.lua")

term.setBackgroundColor(config.theme.bg)
term.setTextColor(config.theme.text)
term.clear()
term.setCursorPos(1,1)

ui.splash(config)

while true do
    if login.run(config) then
        ui.desktop(config)
    else
        sleep(0.1)
    end
end
