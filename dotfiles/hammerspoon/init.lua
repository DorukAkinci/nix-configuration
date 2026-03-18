function reloadConfig(files)
    doReload = false
    for _, file in pairs(files) do
        if file:sub(-4) == ".lua" then
            doReload = true
        end
    end
    if doReload then
        appWatcher:stop()
        hs.reload()
    end
end
myWatcher = hs.pathwatcher.new(os.getenv("HOME") .. "/.hammerspoon/", reloadConfig):start()
hs.alert.show("Config loaded")

function applicationWatcher(appName, eventType, appObject)
    if (eventType == hs.application.watcher.activated) then
        if (appName == "Finder") then
            -- Bring all Finder windows forward when one gets activated
            appObject:selectMenuItem({"Window", "Bring All to Front"})
        end
    end
end
appWatcher = hs.application.watcher.new(applicationWatcher)
appWatcher:start()
hs.alert.show("AppWatcher started")

require "windowmanager"
-- require "audioswitcher"
-- require "clipboard"

-- Remap ISO § key (keycode 10) to ` / ~ (keycode 50)
-- Fixes built-in ISO keyboard producing §/± instead of `/~ with US layout
isoTildeRemap = hs.eventtap.new({hs.eventtap.event.types.keyDown, hs.eventtap.event.types.keyUp}, function(event)
    if event:getKeyCode() == 10 then
        event:setKeyCode(50)
        return false
    end
    return false
end)
isoTildeRemap:start()
