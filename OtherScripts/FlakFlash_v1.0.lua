--Flak Flash Script v1.0 by Stevey666
--Isolated tracking and explosion for specified AAA flak shells
--Designed for use at night to add flashes from the flak explosions
--Based on https://github.com/stephenpostlethwaite/DCSSplashDamageScript/blob/master/Splash_Damage_3.4.2_Standard_With_Ground_Ordnance.lua

local script_enable = 1 --enable(1)/disable(0) script 
local logging_enabled = false --Toggle logging on/off
local refreshRate = 0.1 --the lower the more accurate the tracking, but the higher the performance cost

local explosive_power = 0.0000001 --Set explosive value for all flak shells. 0.0000001 for flashes only, 20 for a good sized explosion
--local explosive_power = 20 --Set explosive value for all flak shells. 0.0000001 for flashes only, 20 for a good sized explosion
----

--Weapon Explosive Table (AAA flak shells with timed fuzes)
local FlakShells = {
    ["weapons.shells.Bofors_40mm_HE"] = { explosive = explosive_power}, --WWII Bofors 40mm AAA, timed fuzes
    ["weapons.shells.Flak18_Sprgr_39"] = { explosive = explosive_power}, --WWII German 88mm Flak 18, timed fuzes
    ["weapons.shells.Flak41_Sprgr_39"] = { explosive = explosive_power}, --WWII German 88mm Flak 41, timed fuzes
    ["weapons.shells.KS19_100HE"] = { explosive = explosive_power}, --Modern Soviet 100mm AAA, timed fuzes
    ["weapons.shells.QF94_AA_HE"] = { explosive = explosive_power}, --WWII British 94mm AAA, timed fuzes
    ["weapons.shells.ship_Bofors_40mm_HE"] = { explosive = explosive_power}, --WWII Naval Bofors 40mm AAA, timed fuzes
    ["weapons.shells.Sprgr_34_L70"] = { explosive = explosive_power}, --WWII German 88mm Flak 36/37, timed fuzes
    ["weapons.shells.Sprgr_38"] = { explosive = explosive_power}, --WWII German 88mm Flak 38, timed fuzes
    ["weapons.shells.Sprgr_39"] = { explosive = explosive_power}, --WWII German 88mm Flak 18/36/37, timed fuzes
    ["weapons.shells.Sprgr_43_L71"] = { explosive = explosive_power}, --WWII German 88mm Flak 43, timed fuzes
    ["weapons.shells.53-UOR-281U"] = { explosive = explosive_power}, --HE shell from S-60 57mm AAA
}

----[ [ ##### HELPER/UTILITY FUNCTIONS ##### ] ]----

local shell_counter = 0 --Unique identifier for shells

local function logMsg(str)
    if logging_enabled then
        debugCounter = (debugCounter or 0) + 1
        local uniqueStr = "Flak: " .. str .. " [" .. timer.getTime() .. " - " .. debugCounter .. "]"
        trigger.action.outText(uniqueStr, 5)
        env.info(uniqueStr)
    end
end

local function vec3Mag(speedVec)
    return math.sqrt(speedVec.x^2 + speedVec.y^2 + speedVec.z^2)
end

local function lookahead(speedVec)
    local speed = vec3Mag(speedVec)
    return speed * refreshRate * 1.5
end

----[ [ ##### End of HELPER/UTILITY FUNCTIONS ##### ] ]----

WpnHandler = {}
tracked_weapons = {}

function track_wpns()
    for wpn_id_, wpnData in pairs(tracked_weapons) do
        if wpnData.wpn:isExist() then
            wpnData.pos = wpnData.wpn:getPosition().p
            wpnData.dir = wpnData.wpn:getPosition().x
            wpnData.speed = wpnData.wpn:getVelocity()
        else
            local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed)) or wpnData.pos --Fallback to last position
            local expl = FlakShells[wpnData.name]
            if expl then
                local explPower = expl.explosive
                trigger.action.explosion(ip, explPower)
                logMsg("Explosion for " .. wpnData.name .. " at X:" .. ip.x .. " Y:" .. ip.y .. " Z:" .. ip.z .. " Power: " .. explPower)
            else
                logMsg("Failed to process explosion for " .. wpnData.name)
            end
            tracked_weapons[wpn_id_] = nil
        end
    end
    if script_enable == 1 then
        timer.scheduleFunction(track_wpns, nil, timer.getTime() + refreshRate)
    end
end

function WpnHandler:onEvent(event)
    if script_enable ~= 1 or event.id ~= world.event.S_EVENT_SHOT then
        return
    end
    local wpn = event.weapon
    if wpn and wpn:isExist() then
        local wpn_name = wpn:getTypeName()
        if FlakShells[wpn_name] then
            shell_counter = shell_counter + 1
            local unique_id = wpn_name .. "_" .. shell_counter --Unique ID for each shell
            tracked_weapons[unique_id] = {
                wpn = wpn,
                name = wpn_name,
                pos = wpn:getPosition().p,
                dir = wpn:getPosition().x,
                speed = wpn:getVelocity()
            }
            logMsg("Tracking flak: " .. wpn_name .. " ID: " .. unique_id)
        end
    end
end

if script_enable == 1 then
    world.addEventHandler(WpnHandler)
    timer.scheduleFunction(track_wpns, nil, timer.getTime() + refreshRate)
    logMsg("Flak Flash Script v 1.0 Enabled")

end

