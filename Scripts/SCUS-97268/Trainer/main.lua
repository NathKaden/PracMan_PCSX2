require 'TrainerWindow'
print("main.lua executed")
Log = function(msg)
    local f = io.open("C:\\temp\\pracman.log", "a")
    f:write(os.date("%H:%M:%S") .. " - [Lua] " .. msg .. "\n")
    f:close()
end
Log("main.lua executeee")

function OnLoad()
    local trainer = TrainerWindow()
    trainer:Show()
end

function OnTick()

end

function OnUnload()

end

