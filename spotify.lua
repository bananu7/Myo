scriptId = 'com.bajtek.test.test'

unlocked = false
unlockedSince = 0
poses = {
    fist = false,
    thumbToPinky = false,
    fingersSpread = false
}
referenceRoll = 0
activeApp = ""

function extendUnlock() 
    unlockedSince = myo.getTimeMilliseconds()
end

function play()
    myo.keyboard("space", "press")
end

function volumeUp()
    myo.keyboard("up_arrow", "down", "control")
end
function volumeDown()
    myo.keyboard("down_arrow", "down", "control")
end 
function nextSong()
    myo.keyboard("right_control", "down")
    myo.keyboard("right_arrow", "press")
    myo.keyboard("right_control", "up")
end
function prevSong()
    myo.keyboard("right_control", "down")
    myo.keyboard("left_arrow", "press")
    myo.keyboard("right_control", "up")
end

function onForegroundWindowChange(app, title)
    --myo.debug("onForegroundWindowChange: " .. app .. ", " .. title)
    for token in string.gmatch(title, "%S+") do
        activeApp = token
        break
    end
    --myo.debug(activeApp)

    return true
end

function onPoseEdge(pose, edge)
--    myo.debug("onPoseEdge: " .. pose .. ", " .. edge)
    if edge == "on" then 
        poses[pose] = true
    else
        poses[pose] = false
    end

    if edge == "on" and activeApp == "Spotify" then
        if pose == "thumbToPinky" then
            onThumbToPinky()    
        end
        if pose == "fingersSpread" then
            onFingersSpread()
        end
        if pose == "fist" then
            onFist()
        elseif pose == "waveOut" then
            onWaveOut()
        elseif pose == "waveIn" then
            onWaveIn()
        end
    end
end
 
function onPeriodic()
    local unlockTime = 1500
    local now = myo.getTimeMilliseconds()

    -- process automatick lock
    if unlocked then
        if now - unlockedSince > unlockTime then
            unlocked = false
           -- myo.vibrate("short")
        end
    end

    currentRoll = myo.getRoll()

    -- process rotation
    if unlocked and poses["fist"] then
        extendUnlock()
        local roll = currentRoll - referenceRoll
        if roll > 0.3 then
            volumeUp()
        elseif roll < -0.3 then
            volumeDown()
        end
    end
    if not poses[fist] then
        myo.keyboard("up_arrow", "up", "control")
        myo.keyboard("down_arrow", "up", "control")
    end
end

function onThumbToPinky()
    if not unlocked then
        unlocked = true
        unlockedSince = myo.getTimeMilliseconds()
        myo.vibrate("short")
    else
        extendUnlock()
    end
end

function onFingersSpread()
    if unlocked then
        myo.vibrate("short") 
        play()
        --extendUnlock()
        unlocked = false
    end
end

function onFist()
    referenceRoll = myo.getRoll()
end

function onWaveOut()
    if unlocked then
        nextSong()
        extendUnlock()
    end
end

function onWaveIn()
    if unlocked then
        prevSong()
        extendUnlock()
    end
end

