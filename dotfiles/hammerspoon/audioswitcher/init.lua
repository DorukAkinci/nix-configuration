local audiochoices = {}

for i,v in ipairs(hs.audiodevice.allOutputDevices()) do
    table.insert(audiochoices, {text = v:name(), idx=i})
end

local audioChooser = hs.chooser.new(function(choice)
if not choice then hs.alert.show("Nothing chosen"); return end
    local idx = choice["idx"]
    local name = choice["text"]
    -- print selected device idx and its text to the console
    print("Selected audio device: " .. idx .. " " .. name)
    dev = hs.audiodevice.allOutputDevices()[idx]
    if not dev:setDefaultOutputDevice() then
        hs.alert.show("Unable to enable audio output device " .. name)
        else
        hs.alert.show("Audio output device is now: " .. name)
    end
end)

audioChooser:choices(audiochoices)
hs.hotkey.bind({"ctrl", "cmd"}, "A", function() audioChooser:show() end)