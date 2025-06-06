--Trophy Style APS Script by Stevey666
--Version 1.0
local success, errorMsg = pcall(function()

--[[-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
                                                                ##### SCRIPT CONFIGURATION #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]
local TrophyConfig = {
    enabled = true,              --Enable/disable Trophy APS (true/false)
    selfExplosionSize = 1,       --Explosion size near vehicle, mimicking trophy location (default: 1)
	explosionOffsetDistance = 2, --Launcher offset from vehicle center (default: 2 meters)
    weaponExplosionSize = 20,    --Explosion size to destroy weapon (default: 20)
    detectRange = 200,           --Detection range in meters (default: 20) when in detection range speed up the location checks of the weapon
    interceptRange = 30,         --Interception range in meters (default: 30) you can reduce this to 20 to make it more realistic but script will struggle tracking fast missiles i.e vikhr_m, it might even struggle at 30
    frontRightRounds = 4,        --Initial front-right launcher rounds (default: 4)
    backLeftRounds = 4,          --Initial back-left launcher rounds (default: 4)
    failureChance = 0.05,     --Failure chance for interception (0.0 to 1.0 0% to 100%, default: 0.05 for 5%)
	trackingspeed = "distance and (distance <= 100 and 0.02 or (distance <= 200 and 0.05 or (distance <= 1000 and 0.1 or 1))) or 1", --Tracking interval expression
		--This checks the weapons location/distance from the trophy unit - over 1000m check every 1 second, under 1000 every 0.1 seconds, under 200 meter 0.05 seconds, under 100m 0.02 seconds
    debugmode = false             --Debug mode enabled
}
--[[-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]

--Unit types eligible for Trophy APS
local AllUnitType = {
    --["M-1 Abrams"] = true,    --Example unit, uncomment to enable Trophy APS for all M1A2 Abrams units as opposed to only name searching.  You can add units too.
}

--Weapons to be tracked by script and max range to be tracked from
local trophyWeapons = {
    --For weapon types: typeName:gsub("^weapons%.missiles%.", ""):gsub("^weapons%.nurs%.", ""), other types not supported in code currently. shells were too fast.
    ["AGM_114K"] = { range = 8000 }, --Hellfire missile
    ["AGM_114"] = { range = 8000 }, --Hellfire 
	["vikhr_m"] = { range = 10000 }, --Vikhr ATGM
    ["Vikhr_9M127_1"] = { range = 10000 }, --Vikhr ATGM 
    ["AT_6"] = { range = 5000 }, --Shturm ATGM
    ["Ataka_9M120"] = { range = 6000 }, --Ataka ATGM
    ["Ataka_9M120F"] = { range = 6000 }, --Ataka ATGM
    ["P_9M117"] = { range = 5000 }, --AT-10 Stabber
    ["9M133"] = { range = 5500 }, --Kornet ATGM
    ["9M120"] = { range = 6000 }, --Ataka ATGM
    ["HOT3"] = { range = 4300 }, --HOT-3 ATGM
    ["PG_16V"] = { range = 800 }, --RPG-16 HEAT
    ["HYDRA_70_M151"] = { range = 8000 }, --Hydra 70 M151 HE
    ["HYDRA_70_M282"] = { range = 8000 }, --Hydra 70 M282 Multi-Purpose Penetrator
    ["HYDRA_70_MK5"] = { range = 8000 }, --Hydra 70 Mk5 HEAT
    ["S_8KOM"] = { range = 4000 }, --S-8KOM HEAT rocket
    ["S_5M"] = { range = 3000 }, --S-5M HE rocket
    ["S_24B"] = { range = 4000 }, --S-24B HE rocket
    ["C_25"] = { range = 3000 }, --S-25-OFM rocket
    ["3BK18M"] = { range = 4000 }, --125mm HEAT round
    ["M456"] = { range = 3000 }, --105mm HEAT round
    ["HYDRA_70M15"] = { range = 4000 },
    ["HYDRA_70_MK1"] = { range = 4000 },
    ["HYDRA_70_MK5"] = { range = 4000 },
    ["HYDRA_70_M151"] = { range = 4000 },
    ["HYDRA_70_M151_M433"] = { range = 4000 },
    ["HYDRA_70_M229"] = { range = 8000 }, --Hydra 70 M229
    ["FFAR Mk1 HE"] = { range = 8000 }, --FFAR Mk1 HE
    ["FFAR Mk5 HEAT"] = { range = 8000 }, --FFAR Mk5 HEAT
    ["HVAR"] = { range = 8000 }, --HVAR rocket
    ["Zuni_127"] = { range = 8000 }, --Zuni 127mm rocket
    ["ARAKM70BHE"] = { range = 8000 }, --ARAK M70B HE
    ["ARAKM70BAP"] = { range = 8000 }, --ARAK M70B AP
    ["SNEB_TYPE251_F1B"] = { range = 4000 }, --SNEB Type 251
    ["SNEB_TYPE252_F1B"] = { range = 4000 }, --SNEB Type 252
    ["SNEB_TYPE253_F1B"] = { range = 4000 }, --SNEB Type 253
    ["SNEB_TYPE256_F1B"] = { range = 4000 }, --SNEB Type 256
    ["SNEB_TYPE257_F1B"] = { range = 4000 }, --SNEB Type 257
    ["SNEB_TYPE251_F4B"] = { range = 4000 }, --SNEB Type 251 F4B
    ["SNEB_TYPE252_F4B"] = { range = 4000 }, --SNEB Type 252 F4B
    ["SNEB_TYPE253_F4B"] = { range = 4000 }, --SNEB Type 253 F4B
    ["SNEB_TYPE256_F4B"] = { range = 4000 }, --SNEB Type 256 F4B
    ["SNEB_TYPE257_F4B"] = { range = 4000 }, --SNEB Type 257 F4B
    ["SNEB_TYPE251_H1"] = { range = 4000 }, --SNEB Type 251 H1
    ["SNEB_TYPE252_H1"] = { range = 4000 }, --SNEB Type 252 H1
    ["SNEB_TYPE253_H1"] = { range = 4000 }, --SNEB Type 253 H1
    ["SNEB_TYPE256_H1"] = { range = 4000 }, --SNEB Type 256 H1
    ["SNEB_TYPE257_H1"] = { range = 4000 }, --SNEB Type 257 H1
    ["MATRA_F4_SNEBT251"] = { range = 4000 }, --Matra SNEB Type 251
    ["MATRA_F4_SNEBT253"] = { range = 4000 }, --Matra SNEB Type 253
    ["MATRA_F4_SNEBT256"] = { range = 4000 }, --Matra SNEB Type 256
    ["MATRA_F1_SNEBT253"] = { range = 4000 }, --Matra SNEB Type 253 F1
    ["MATRA_F1_SNEBT256"] = { range = 4000 }, --Matra SNEB Type 256 F1
    ["TELSON8_SNEBT251"] = { range = 4000 }, --Telson 8 SNEB Type 251
    ["TELSON8_SNEBT253"] = { range = 4000 }, --Telson 8 SNEB Type 253
    ["TELSON8_SNEBT256"] = { range = 4000 }, --Telson 8 SNEB Type 256
    ["TELSON8_SNEBT257"] = { range = 4000 }, --Telson 8 SNEB Type 257
    ["ARF8M3API"] = { range = 4000 }, --ARF-8/M3 API rocket
    ["UG_90MM"] = { range = 4000 }, --UG 90mm rocket
    ["S-24A"] = { range = 4000 },
    ["S-25OF"] = { range = 4000 },
    ["S-25OFM"] = { range = 4000 },
    ["S-25O"] = { range = 4000 },
    ["S-25-O"] = { range = 4000 },
    ["S_25L"] = { range = 4000 },
    ["S-5M"] = { range = 4000 },
    ["C_5"] = { range = 4000 },
    ["C5"] = { range = 4000 },
    ["C_8"] = { range = 4000 },
    ["C_8OFP2"] = { range = 4000 },
    ["C_13"] = { range = 4000 },
    ["C_24"] = { range = 4000 },
    ["C_25"] = { range = 4000 },
}

--Ammo tracking table: { unitId = { FR = count, BL = count } }
local trophyAmmo = {}

local debugCounter = 0
local function debugTrophy(str)
    if TrophyConfig.debugmode then
        debugCounter = debugCounter + 1
        local uniqueStr = str .. " [" .. timer.getTime() .. " - " .. debugCounter .. "]"
        --trigger.action.outText(uniqueStr, 5) --uncomment to show messages ingame too
        env.info("[TrophyAPS] " .. uniqueStr)
    end
end

debugTrophy("Script execution started")

debugTrophy("Weapon list defined")


--Preprocess trophyWeapons keys to lowercase for faster lookup
local trophyWeaponsLookup = {}
for wpnName, data in pairs(trophyWeapons) do
    trophyWeaponsLookup[string.lower(wpnName)] = data
end

--Function to check if a weapon is in the Trophy APS target list
local function isTrophyWeapon(weaponName)
    debugTrophy("Checking weapon: " .. tostring(weaponName))
    if not weaponName then
        debugTrophy("Weapon name is nil")
        return false
    end
    local weaponNameLower = string.lower(weaponName)
    if trophyWeaponsLookup[weaponNameLower] then
        debugTrophy("Weapon " .. weaponNameLower .. " is a Trophy target")
        return true
    end
    debugTrophy("Weapon " .. weaponNameLower .. " is not a Trophy target")
    return false
end

--Function to find TrophyAPS vehicles within weapon's max range
local function findTrophyVehicles(weaponPos, weaponName)
    debugTrophy("Finding TrophyAPS vehicles for " .. tostring(weaponName))
    if not weaponPos then
        debugTrophy("Weapon position is nil")
        return {}
    end
    local trophyUnits = {}
    local unitIds = {} --Track unique unit IDs
    local searchRadius = trophyWeapons[weaponName] and trophyWeapons[weaponName].range or 16093 --Default to 10 miles if no range
    debugTrophy("Search radius: " .. searchRadius .. " meters")
    local function searchUnit(unit)
        if unit then
            local success, errorMsg = pcall(function()
                if unit:isExist() and unit:getLife() > 1 then
                    local unitType = unit:getTypeName()
                    local unitName = unit:getName()
                    if AllUnitType[unitType] or string.find(unitName, "TrophyAPS") then
                        local unitId = unit:getID()
                        --Check ammo status
                        if not trophyAmmo[unitId] then
                            trophyAmmo[unitId] = { FR = TrophyConfig.frontRightRounds, BL = TrophyConfig.backLeftRounds }
                        end
                        if trophyAmmo[unitId].FR + trophyAmmo[unitId].BL > 0 then
                            if not unitIds[unitId] then
                                local unitPos = unit:getPosition().p
                                if unitPos then
                                    local distance = math.sqrt((unitPos.x - weaponPos.x)^2 + (unitPos.z - weaponPos.z)^2)
                                    if distance <= searchRadius then
                                        table.insert(trophyUnits, unit)
                                        unitIds[unitId] = true
                                        debugTrophy("Found unit " .. unitName .. " (ID: " .. unitId .. ", Type: " .. unitType .. ") with FR: " .. trophyAmmo[unitId].FR .. ", BL: " .. trophyAmmo[unitId].BL)
                                    end
                                else
                                    debugTrophy("Failed to get position for unit " .. unitName)
                                end
                            end
                        else
                            debugTrophy("Unit " .. unitName .. " (ID: " .. unitId .. ") has no remaining Trophy rounds")
                        end
                    end
                end
            end)
            if not success then
                debugTrophy("Error processing unit: " .. tostring(errorMsg))
            end
        end
    end
    local volume = { id = world.VolumeType.SPHERE, params = { point = { x = weaponPos.x, y = weaponPos.y, z = weaponPos.z }, radius = searchRadius } }
    local success, errorMsg = pcall(function()
        world.searchObjects(Object.Category.UNIT, volume, searchUnit)
    end)
    if not success then
        debugTrophy("Error in world.searchObjects: " .. tostring(errorMsg))
    end
    debugTrophy("Found " .. #trophyUnits .. " TrophyAPS vehicles within " .. searchRadius .. " meters")
    return trophyUnits
end

--Function to check if weapon is heading toward a unit
local function isWeaponHeadingToward(weapon, unit, callback)
    local sampleCount = 3
    local sampleInterval = 0.05
    local initialDelay = 0.05
    local samples = {}
    
    local function collectSample(count)
        if count > sampleCount then
            --Process samples
            local success, result = pcall(function()
                if #samples < 2 then
                    debugTrophy("Insufficient samples collected: " .. #samples)
                    callback(false)
                    return
                end
                
                --Calculate displacement between first and last sample
                local firstPos = samples[1].pos
                local lastPos = samples[#samples].pos
                local dispX = lastPos.x - firstPos.x
                local dispZ = lastPos.z - firstPos.z
                local magDisp = math.sqrt(dispX^2 + dispZ^2)
                debugTrophy("Displacement: dx=" .. dispX .. ", dz=" .. dispZ .. ", mag=" .. magDisp)
                
                --Try velocity if displacement is too small
                local avgVelX, avgVelZ = 0, 0
                local validVel = false
                if magDisp < 0.1 then
                    for _, sample in ipairs(samples) do
                        local magVel = math.sqrt(sample.vel.x^2 + sample.vel.z^2)
                        if magVel >= 1 then
                            avgVelX = avgVelX + sample.vel.x / magVel
                            avgVelZ = avgVelZ + sample.vel.z / magVel
                            validVel = true
                        end
                    end
                    magDisp = math.sqrt(avgVelX^2 + avgVelZ^2)
                    if validVel and magDisp >= 0.0001 then
                        dispX = avgVelX / magDisp
                        dispZ = avgVelZ / magDisp
                        debugTrophy("Using average velocity: x=" .. dispX .. ", z=" .. dispZ)
                    else
                        debugTrophy("No valid displacement or velocity")
                        callback(false)
                        return
                    end
                else
                    dispX = dispX / magDisp
                    dispZ = dispZ / magDisp
                    debugTrophy("Normalized displacement: x=" .. dispX .. ", z=" .. dispZ)
                end
                
                --Vector from last weapon position to unit
                local unitPos = unit:getPosition().p
                local toUnitX = unitPos.x - lastPos.x
                local toUnitZ = unitPos.z - lastPos.z
                local magToUnit = math.sqrt(toUnitX^2 + toUnitZ^2)
                if magToUnit < 0.0001 then
                    debugTrophy("Weapon too close to unit, magToUnit is zero")
                    callback(false)
                    return
                end
                toUnitX = toUnitX / magToUnit
                toUnitZ = toUnitZ / magToUnit
                debugTrophy("To-unit vector: x=" .. toUnitX .. ", z=" .. toUnitZ)
                
                --Dot product to check alignment
                local dot = toUnitX * dispX + toUnitZ * dispZ
                local angle = math.acos(math.max(-1, math.min(1, dot))) * 180 / math.pi
                debugTrophy("Trajectory dot product: " .. dot .. ", angle: " .. angle .. " degrees")
                --Consider heading toward if within 45 degrees
                local isHeading = dot > 0.707 --cos(45 degrees)
                debugTrophy("Heading toward: " .. tostring(isHeading))
                callback(isHeading)
            end)
            if not success then
                debugTrophy("Error processing samples: " .. tostring(result))
                callback(false)
            end
            return
        end
        
        local success, errorMsg = pcall(function()
            if weapon:isExist() then
                local pos = weapon:getPosition().p
                local vel = weapon:getVelocity()
                table.insert(samples, { pos = pos, vel = vel })
                debugTrophy("Sample " .. count .. ": pos x=" .. math.floor(pos.x) .. ", z=" .. math.floor(pos.z) .. ", vel x=" .. vel.x .. ", z=" .. vel.z)
                timer.scheduleFunction(function()
                    collectSample(count + 1)
                end, {}, timer.getTime() + sampleInterval)
            else
                debugTrophy("Weapon no longer exists during sampling")
                callback(false)
            end
        end)
        if not success then
            debugTrophy("Error collecting sample " .. count .. ": " .. tostring(errorMsg))
            callback(false)
        end
    end
    
    debugTrophy("Scheduling trajectory sampling for weapon near " .. unit:getName() .. " with 0.1-second delay")
    timer.scheduleFunction(function()
        if weapon:isExist() then
            collectSample(1)
        else
            debugTrophy("Weapon no longer exists before sampling")
            callback(false)
        end
    end, {}, timer.getTime() + initialDelay)
end

--Function to track weapon and check for nearby TrophyAPS vehicles
local function trackWeapon(weapon, weaponName, initTime, targetUnit)
    if not TrophyConfig.enabled then
        debugTrophy("Trophy APS disabled, skipping tracking for " .. tostring(weaponName))
        return
    end
    if not weapon then
        debugTrophy("Weapon " .. tostring(weaponName) .. " is nil, stopping tracking")
        return
    end
    local success, errorMsg = pcall(function()
        if not weapon:isExist() then
            debugTrophy("Weapon " .. tostring(weaponName) .. " no longer exists, stopping tracking")
            return
        end

        local weaponPos
        local posSuccess, posError = pcall(function()
            weaponPos = weapon:getPosition().p
        end)
        if not posSuccess or not weaponPos then
            debugTrophy("Failed to get position for weapon " .. tostring(weaponName) .. ": " .. tostring(posError))
            return
        end

        debugTrophy("Tracking weapon: " .. tostring(weaponName) .. " at x=" .. math.floor(weaponPos.x) .. ", z=" .. math.floor(weaponPos.z))

        if targetUnit:isExist() and targetUnit:getLife() > 1 then
            local unitPos
            local unitSuccess, unitErrorMsg = pcall(function()
                unitPos = targetUnit:getPosition().p
            end)
            if not unitSuccess or not unitPos then
                debugTrophy("Failed to get position for unit " .. targetUnit:getName() .. ": " .. tostring(unitErrorMsg))
                return
            end
            local distance
            if unitPos and weaponPos then
                distance = math.sqrt((unitPos.x - weaponPos.x)^2 + (unitPos.y - weaponPos.y)^2 + (unitPos.z - weaponPos.z)^2)
                debugTrophy("Weapon " .. tostring(weaponName) .. " distance to TrophyAPS vehicle " .. targetUnit:getName() .. ": " .. math.floor(distance) .. " meters")
            else
                debugTrophy("Failed to calculate distance for weapon " .. tostring(weaponName) .. " to unit " .. targetUnit:getName())
                return
            end
            if distance <= TrophyConfig.detectRange then --Within detection range
                if distance <= TrophyConfig.interceptRange then --Within interception range
                    local unitId = targetUnit:getID()
                    if not trophyAmmo[unitId] then
                        trophyAmmo[unitId] = { FR = TrophyConfig.frontRightRounds, BL = TrophyConfig.backLeftRounds }
                    end
                    debugTrophy("Interception triggered for " .. tostring(weaponName) .. " near " .. targetUnit:getName())
                    --Get vehicle orientation (heading) at interception time
                    local unitOrientationSuccess, unitOrientation = pcall(function()
                        return targetUnit:getPosition().x
                    end)
                    if not unitOrientationSuccess then
                        debugTrophy("Error getting unit orientation: " .. tostring(unitOrientation))
                        return
                    end
                    local headingX, headingZ = unitOrientation.x, unitOrientation.z
                    local headingMag = math.sqrt(headingX^2 + headingZ^2)
                    if headingMag == 0 then
                        debugTrophy("Invalid unit heading for " .. targetUnit:getName())
                        return
                    end
                    headingX, headingZ = headingX / headingMag, headingZ / headingMag
                    debugTrophy("Tank heading: x=" .. headingX .. ", z=" .. headingZ)
                    --Calculate threat direction (weapon to vehicle)
                    local threatX = weaponPos.x - unitPos.x
                    local threatZ = weaponPos.z - unitPos.z
                    local magThreat = math.sqrt(threatX^2 + threatZ^2)
                    if magThreat == 0 then
                        debugTrophy("Invalid threat vector magnitude")
                        return
                    end
                    threatX, threatZ = threatX / magThreat, threatZ / magThreat
                    debugTrophy("Threat direction: x=" .. threatX .. ", z=" .. threatZ)
                    --Compute relative angle using atan2 for correct quadrant
                    local angle = math.atan2(threatZ, threatX) - math.atan2(headingZ, headingX)
                    angle = angle * 180 / math.pi
                    if angle < 0 then angle = angle + 360 end
                    debugTrophy("Threat angle: " .. angle .. " degrees (relative to vehicle heading)")
                    --Select launcher based on angle (270-360 and 0-90: front-right, 90-270: back-left)
                    local offsetDistance = TrophyConfig.explosionOffsetDistance
                    local explosionX, explosionZ
                    local launcher
                    --Rotate offsets based on tank heading
                    local rightX, rightZ = -headingZ, headingX --Perpendicular to heading (right vector)
                    if (angle >= 270 and angle <= 360) or (angle >= 0 and angle < 90) then
                        --Front-right launcher (forward + right)
                        explosionX = unitPos.x + headingX * offsetDistance + rightX * offsetDistance
                        explosionZ = unitPos.z + headingZ * offsetDistance + rightZ * offsetDistance
                        launcher = "FR"
                        if trophyAmmo[unitId].FR > 0 then
                            trophyAmmo[unitId].FR = trophyAmmo[unitId].FR - 1
                            debugTrophy("Using front-right launcher for " .. tostring(weaponName) .. ", unit " .. unitId .. " FR rounds left: " .. trophyAmmo[unitId].FR)
                        else
                            debugTrophy("No front-right rounds left for unit " .. targetUnit:getName())
                            return
                        end
                    else
                        --Back-left launcher (backward + left)
                        explosionX = unitPos.x - headingX * offsetDistance - rightX * offsetDistance
                        explosionZ = unitPos.z - headingZ * offsetDistance - rightZ * offsetDistance
                        launcher = "BL"
                        if trophyAmmo[unitId].BL > 0 then
                            trophyAmmo[unitId].BL = trophyAmmo[unitId].BL - 1
                            debugTrophy("Using back-left launcher for " .. tostring(weaponName) .. ", unit " .. unitId .. " BL rounds left: " .. trophyAmmo[unitId].BL)
                        else
                            debugTrophy("No back-left rounds left for unit " .. targetUnit:getName())
                            return
                        end
                    end
                    debugTrophy("Explosion position: x=" .. explosionX .. ", z=" .. explosionZ)
                    if math.random() >= TrophyConfig.failureChance then
                        --Explosion 1.6 meters above ground
                        local groundHeight = land.getHeight({x = explosionX, y = explosionZ})
                        local explosionY = groundHeight + (groundHeight + 1.6 < 1.6 and 1.6 or 1.6)
                        local explosionSuccess, explosionError = pcall(function()
                            trigger.action.explosion({ x = explosionX, y = explosionY, z = explosionZ }, TrophyConfig.selfExplosionSize)
                        end)
                        if not explosionSuccess then
                            debugTrophy("Error triggering interception explosion: " .. tostring(explosionError))
                        else
                            --Check unit health after Trophy explosion
                            local healthSuccess, unitHealth = pcall(function()
                                return targetUnit:getLife()
                            end)
                            if healthSuccess and unitHealth then
                                debugTrophy("Unit " .. targetUnit:getName() .. " health after " .. launcher .. " firing: " .. unitHealth)
                            else
                                debugTrophy("Failed to get health for unit " .. targetUnit:getName() .. ": " .. tostring(unitHealth))
                            end
                        end
                        --Immediate weapon destruction
                        local destroySuccess, destroyError = pcall(function()
                            if weapon and weapon:isExist() then
                                local wpnPos = weapon:getPosition().p
                                debugTrophy("Destroying weapon: " .. tostring(weaponName))
                                local groundHeight = land.getHeight({x = wpnPos.x, y = wpnPos.z})
                                local explosionY = wpnPos.y < groundHeight + 1.6 and groundHeight + 1.6 or wpnPos.y
                                trigger.action.explosion({ x = wpnPos.x, y = explosionY, z = wpnPos.z }, TrophyConfig.weaponExplosionSize)
                            else
                                debugTrophy("Weapon " .. tostring(weaponName) .. " no longer exists for destruction")
                            end
                        end)
                        if not destroySuccess then
                            debugTrophy("Error destroying weapon: " .. tostring(destroyError))
                        end
                    else
                        debugTrophy("Interception missed for " .. tostring(weaponName))
                        return --Skip destruction, allow threat to continue
                    end
                    --Continue tracking for other units
                end
            end

            --Continue tracking with fast (0.1s) at under 1000m or slow at more than 1000m (1s) interval based on distance. Even faster at 200m or less
            local trackInterval = distance and (distance <= 200 and 0.05 or (distance <= 1000 and 0.1 or 1)) or 1
            debugTrophy("Scheduling next track for " .. tostring(weaponName) .. " in " .. trackInterval .. " seconds")
            timer.scheduleFunction(function(args)
                local wpn, wpnName, unit = args[1], args[2], args[3]
                if not wpn then
                    debugTrophy("Scheduled weapon " .. tostring(wpnName) .. " is nil, stopping tracking")
                    return
                end
                local success, errorMsg = pcall(function()
                    trackWeapon(wpn, wpnName, initTime, unit)
                end)
                if not success then
                    debugTrophy("Error in scheduled tracking for " .. tostring(wpnName) .. ": " .. tostring(errorMsg))
                end
            end, {weapon, weaponName, targetUnit}, timer.getTime() + trackInterval)
        else
            debugTrophy("Target unit " .. targetUnit:getName() .. " no longer exists or is dead, stopping tracking")
            return
        end
    end)
    if not success then
        debugTrophy("Error tracking weapon " .. tostring(weaponName) .. ": " .. tostring(errorMsg))
    end
end

--Event handler for weapon firing
local trophyHandler = {}
function trophyHandler:onEvent(event)
    debugTrophy("Event received: " .. tostring(event.id))
    local success, errorMsg = pcall(function()
        if event.id == world.event.S_EVENT_SHOT then
            local weapon = event.weapon
            if weapon and weapon:isExist() then
                local weaponDesc = weapon:getDesc()
                local displayName = weaponDesc.displayName or "None"
                local typeName = weaponDesc.typeName or "None"
                --Check if typeName starts with weapons.missiles. or weapons.nurs.
                if typeName:match("^weapons%.missiles%.") or typeName:match("^weapons%.nurs%.") then
                local weaponName = typeName:gsub("^weapons%.missiles%.", ""):gsub("^weapons%.nurs%.", "")
                local isMatch = isTrophyWeapon(weaponName)
                debugTrophy("Weapon fired: " .. tostring(weaponName) .. " (Matches Trophy list: " .. (isMatch and "Yes" or "No") .. ") | DisplayName: " .. tostring(displayName) .. " | TypeName: " .. tostring(typeName))
                if isMatch and TrophyConfig.enabled then
                    debugTrophy("Trophy weapon detected: " .. tostring(weaponName))
                    local weaponPos
                    local success, errorMsg = pcall(function()
                        weaponPos = weapon:getPosition().p
                    end)
                    if not success or not weaponPos then
                        debugTrophy("Failed to get initial position for weapon " .. tostring(weaponName) .. ": " .. tostring(errorMsg))
                        return
                    end
                    local trophyUnits = findTrophyVehicles(weaponPos, weaponName)
                    if #trophyUnits > 0 then
                        local trackedUnits = 0
                        local processedUnits = 0
                        for _, unit in pairs(trophyUnits) do
                            isWeaponHeadingToward(weapon, unit, function(isHeading)
                                processedUnits = processedUnits + 1
                                if isHeading then
                                    debugTrophy("Weapon " .. tostring(weaponName) .. " heading toward " .. unit:getName() .. ", starting tracking")
                                    trackWeapon(weapon, weaponName, timer.getTime(), unit)
                                    trackedUnits = trackedUnits + 1
                                else
                                    debugTrophy("Weapon " .. tostring(weaponName) .. " not heading toward " .. unit:getName() .. ", skipping tracking")
                                end
                                --Log tracking summary after all units are checked
                                if processedUnits == #trophyUnits then
                                    debugTrophy("Tracking " .. tostring(weaponName) .. " against " .. trackedUnits .. " of " .. #trophyUnits .. " TrophyAPS vehicles in range")
                                end
                            end)
                        end
                    else
                        debugTrophy("No TrophyAPS vehicles within range for " .. tostring(weaponName))
                    end
                end
            else
                    debugTrophy("Weapon typeName " .. tostring(typeName) .. " does not match missiles or nurs, skipping")
                end
            else
                debugTrophy("Weapon is nil or does not exist")
            end
        end
    end)
    if not success then
        debugTrophy("Error in event handler: " .. tostring(errorMsg))
    end
end

debugTrophy("Event handler defined")

--Register event handler
local success, errorMsg = pcall(function()
    world.addEventHandler(trophyHandler)
end)
if not success then
    debugTrophy("Failed to register event handler: " .. tostring(errorMsg))
else
    debugTrophy("Event handler registered")
end

debugTrophy("Trophy APS Script Loaded")

end) --End of main pcall

if not success then
    debugTrophy("Script failed to load: " .. tostring(errorMsg))
end
