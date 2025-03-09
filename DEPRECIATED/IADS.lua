local SAMRangeLookupTable = { -- Ranges at which SAM sites are considered close enough to activate in m
    ["Kub 1S91 str"] = 52000,
    ["S-300PS 40B6M tr"] =  100000,
    ["Osa 9A33 ln"] = 25000,
    ["snr s-125 tr"] = 60000,
    ["SNR_75V"] = 65000,
    ["Dog Ear radar"] = 26000,
    ["SA-11 Buk LN 9A310M1"] = 43000,
    ["Hawk tr"] = 60000,
    ["Tor 9A331"] = 50000,
    ["rapier_fsa_blindfire_radar"] = 6000,
    ["Patriot STR"] = 100000,
    ["Roland ADS"] = 10000,
    ["HQ-7_STR_SP"] = 12500,
	["RPC_5N62V"] = 120000,
}
local IADSEnable = true -- If true IADS script is active
local IADSRadioDetection = false -- 1 = radio detection of ARM launch on, 0 = radio detection of ARM launch off
local IADSEWRARMDetection = true -- 1 = EWR detection of ARMs on, 0 = EWR detection of ARMs off
local IADSSAMARMDetection = true -- 1 = SAM detectionf of ARMs on, 0 = SAM detection of ARMs off
local EWRAssociationRange = 80000 --Range of an EWR in which SAMs are controlled
local IADSARMHideRangeRadio = 120000 --Range within which ARM launches are detected via radio
local IADSARMHidePctage = 20 -- %age chance of radio detection of ARM launch causing SAM shutdown
local EWRARMShutdownChance = 25 -- %age chance EWR detection of ARM causing SAM shutdown
local SAMARMShutdownChance = 75-- %age chance SAM detection of ARM causings SAM shuttown
local trackMemory = 20 -- Track persistance time after last detection
local controlledSAMNoAmmo = true -- Have controlled SAMs stay off if no ammo remaining.
local uncontrolledSAMNoAmmo = false -- Have uncontrolled SAMs stay off if no ammo remaining
local SAMSites = {}
local EWRSites = {}
local toHide = {}
local AWACSAircraft = {}
local TrackFiles = {
  ["SAM"] = {},
  ["EWR"] = {},
  ["AWACS"] = {},
}

IADSHandler = {}

local function  tablelength(T)
  if T == nil then
    return 0
  end
  local count = 0
  for _, item in pairs(T) do
    if item~=nil then
      count = count + 1
    end
  end
  return count
end

local function getDistance(point1, point2)
	local dX = point1.x - point2.x
	local dZ = point1.z - point2.z
	return math.sqrt(dX*dX + dZ*dZ)
end

local function getDistance3D(point1, point2)
	local dX = point1.x - point2.x
	local dY = point1.y - point2.y
	local dZ = point1.z - point2.z
	return math.sqrt(dX*dX + dZ*dZ + dY*dY)
end

local function rangeOfSAM(gp)
  local maxRange = 0
  for _, unit in pairs(gp:getUnits()) do
    if unit:hasAttribute("SAM TR") and SAMRangeLookupTable[unit:getTypeName()] then
      local samRange  = SAMRangeLookupTable[unit:getTypeName()]
      if maxRange < samRange then
        maxRange = samRange
      end
    end
  end
  return maxRange
end

local function getSamByName(name)
	return SAMSites[name]
end

local function disableSAM(site)
 if site.Enabled then
    local inRange = false
    if site.TrackFiles then
      for _, track in pairs(site.TrackFiles) do
        if track.Position and getDistance(site.Location, track.Position) < (site.EngageRange * 1.15) then
          inRange = true
        end
      end
    end
    if inRange ~= true then
      site.SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,1)
      site.Enabled = false
    end
  end
end

local function hideSAM(site)
    if site.SAMGroup:isExist() then
      site.SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,1)
      site.Enabled = false
    end
  return nil
end

local function ammoCheck(site)
  for _, unt in pairs(site.SAMGroup:getUnits()) do
    local ammo = unt:getAmmo()
    if ammo then
      for j=1, #ammo do
        if ammo[j].count > 0 and ammo[j].desc.guidance == 3 or ammo[j].desc.guidance == 4 then
          return true
        end
      end
    end
  end
end

local function enableSAM(site)
  if (not site.Hidden) and (not site.Enabled) then
  local hasAmmo = ammoCheck(site)
    if tablelength(site.ControlledBy) > 0 then
      if (controlledSAMNoAmmo and (not hasAmmo)) then
      else
        site.SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,2)
        site.Enabled = true
      end
    else
      if uncontrolledSAMNoAmmo and not hasAmmo  then
      else
        site.SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,2)
        site.Enabled = true
      end
    end
  end
end

local function associateSAMS()
  for _, EWR in pairs(EWRSites) do
    EWR.SAMsControlled = {}
    for _, SAM in pairs(SAMSites) do
      if SAM.SAMGroup:getCoalition() == EWR.EWRGroup:getCoalition() and getDistance3D(SAM.Location, EWR.Location) < EWRAssociationRange then
        EWR.SAMsControlled[SAM.Name] = SAM
        SAM.ControlledBy[EWR.Name] = EWR
      end
    end
  end
end

local function magnumHide(site)
  if site.Type == "Tor 9A331" then
  elseif not site.Hidden then
    local randomTime = math.random(15,35)
    toHide[site.Name] = randomTime
    site.HiddenTime = math.random(65,100)+randomTime
    site.Hidden = true
  end
end

local function prevDetected(Sys, ARM)
  for _, prev in pairs(Sys.ARMDetected) do
    if prev:isExist() then
      if ARM:getName() == prev:getName() then
        return true
      end
    else
      prev = nil
    end
  end
end

local function addTrackFile(site, targets)
  if targets.object:isExist() then
    local trackName = targets.object.id_
    site.trackFiles[trackName] = {}
    site.trackFiles[trackName]["Name"] = trackName
    site.trackFiles[trackName]["Object"] = targets.object
    site.trackFiles[trackName]["LastDetected"] = timer.getAbsTime()
    if targets.distance then
      site.trackFiles[trackName]["Position"] = targets.object:getPoint()
      site.trackFiles[trackName]["Velocity"] = targets.object:getVelocity()
    end
    if targets.type then
      site.trackFiles[trackName]["Category"] = targets.object:getCategory()
      site.trackFiles[trackName]["Type"] = targets.object:getTypeName()
    end
    if site.Datalink then
      site.trackFiles[trackName]["Datalink"] = true
    end
  end
end

local function EWRTrackFileBuild()
  for _, EWR in pairs(EWRSites) do
    local detections = EWR.EWRGroup:getController():getDetectedTargets(Controller.Detection.RADAR)
    for j, targets in pairs(detections) do
      if targets.object and targets.object:isExist() and targets.object:inAir() then
        local trackName = targets.object.id_
        addTrackFile(EWR, targets)
        TrackFiles["EWR"][trackName] = EWR.trackFiles[trackName]
        if targets.object:getCategory() == 2 and targets.object:getDesc().guidance == 5 and IADSEWRARMDetection and not prevDetected(EWR, targets.object) then
          EWR.ARMDetected[targets.object:getName()] = targets.object
          for _, SAM in pairs(EWR.SAMsControlled) do
            if math.random(1,100) < EWRARMShutdownChance then
              magnumHide(SAM)
            end
          end
        end
      end
    end
  end
  return timer.getTime() + 2
end

local function SAMTrackFileBuild()
  for _, SAM in pairs(SAMSites) do
    local detections = SAM.SAMGroup:getController():getDetectedTargets(Controller.Detection.RADAR)
    for _, targets in pairs(detections) do
      if targets.object and targets.object:isExist() and targets.object:inAir() then
        local trackName = targets.object.id_
        addTrackFile(SAM, targets)
        TrackFiles["SAM"][trackName] = SAM.trackFiles[trackName]
        if targets.object:getCategory() == 2 and targets.object:getDesc().guidance == 5 and IADSSAMARMDetection and not prevDetected(SAM, targets.object) then
          SAM.ARMDetected[targets.object:getName()] = targets.object
          if math.random(1,100) < SAMARMShutdownChance then
            magnumHide(SAM)
          end
        end
      end
    end
  end
  return timer.getTime() + 2
end

local function AWACSTrackFileBuild()
  for _, AWACS in pairs(AWACSAircraft) do
    local detections = AWACS.AWACSGroup:getController():getDetectedTargets(Controller.Detection.RADAR)
    for _, targets in pairs(detections) do
      if targets.object and targets.object:isExist() and targets.object:inAir() then
        local trackName = targets.object.id_
        addTrackFile(AWACS, targets)
        TrackFiles["AWACS"][trackName] = AWACS.trackFiles[trackName]
      end
    end
  end
  return timer.getTime() + 2
end

local function EWRSAMOnRequest()
  for _, SAM in pairs(SAMSites) do
    if(tablelength(SAM.ControlledBy) > 0) then
      local viableTarget = false
      for _, EWR in pairs(SAM.ControlledBy) do
        for _, target in pairs(EWR.trackFiles) do
          if target.Position and getDistance(SAM.Location, target.Position) < SAM.EngageRange then
            viableTarget = true
          end
        end
      end
      if viableTarget then
        enableSAM(SAM)
      else
        disableSAM(SAM)
      end
    end
  end
  return timer.getTime() + 2
end

local function SAMCheckHidden()
  for _, SAM in pairs(SAMSites) do
    if SAM.Hidden then
      SAM.HiddenTime = SAM.HiddenTime - 2
      if SAM.HiddenTime < 1 then
        SAM.Hidden = false
      end
    end
  end
  for site, time in pairs(toHide) do
    if time < 0 then
      hideSAM(getSamByName(site))
      toHide[site] = nil
    else
      toHide[site] = time - 2
    end
  end
  return timer.getTime() + 2
end

local function BlinkSAM()
  for _, SAM in pairs(SAMSites) do
    if tablelength(SAM.ControlledBy) < 1 then
      if SAM.BlinkTimer < 1  and (not SAM.Hidden) then
        if SAM.Enabled then
          disableSAM(SAM)
          SAM.BlinkTimer = math.random(30,60)
        else
          enableSAM(SAM)
          SAM.BlinkTimer = math.random(30,60)
        end
      else
      SAM.BlinkTimer = SAM.BlinkTimer - 2
      end
    end
  end
  return timer.getTime() + 2
end

local function checkGroupRole(gp)
  local isEWR = false
  local isSAM = false
  local isAWACS = false
  local hasDL = false
  local samType
  local numSAMRadars = 0
  local numTrackRadars = 0
  local numEWRRadars = 0
  if gp:getCategory() == 2 then
      for _, unt in pairs(gp:getUnits()) do
        if unt:hasAttribute("EWR") then
        isEWR = true
        numEWRRadars = numEWRRadars + 1
      elseif unt:hasAttribute("SAM TR") then
        isSAM = true
        samType = unt:getTypeName()
        numSAMRadars = numSAMRadars + 1
      end
      if unt:hasAttribute("Datalink") then
        hasDL = true
      end
    end
    if isEWR then
      EWRSites[gp:getName()] = {
          ["Name"] = gp:getName(),
          ["EWRGroup"] = gp,
          ["SAMsControlled"] = {},
          ["Location"] = gp:getUnit(1):getPoint(),
          ["numEWRRadars"] = numEWRRadars,
          ["ARMDetected"] = {},
          ["Datalink"] = hasDL,
          ["trackFiles"] = {},
      }
      return gp:getName()
    elseif isSAM and rangeOfSAM(gp) then
      SAMSites[gp:getName()] = {
          ["Name"] = gp:getName(),
          ["SAMGroup"] = gp,
          ["Type"] = samType,
          ["Location"] = gp:getUnit(1):getPoint(),
          ["numSAMRadars"] = numSAMRadars,
          ["EngageRange"] = rangeOfSAM(gp),
          ["ControlledBy"] = {},
          ["Enabled"] = true,
          ["Hidden"] = false,
          ["BlinkTimer"] = 0,
          ["ARMDetected"] = {},
          ["Datalink"] = hasDL,
          ["trackFiles"] = {},
      }
      return gp:getName()
    end
  elseif gp:getCategory() == 0 then
    local numAWACS = 0
    for _, unt in pairs(gp:getUnits()) do
      if unt:hasAttribute("AWACS") then
        isAWACS = true
        numAWACS = numAWACS+1
      end
      if unt:hasAttribute("Datalink") then
        hasDL = true
      end
    end
    if isAWACS then
      AWACSAircraft[gp:getName()] = {
        ["Name"] = gp:getName(),
        ["AWACSGroup"] = gp,
        ["numAWACS"] = numAWACS,
        ["Datalink"] = hasDL,
        ["trackFiles"] = {},
       }
    return gp:getName()
    end
  end
end

local function onDeath(event)
  if event.initiator:getCategory() == Object.Category.UNIT and event.initiator:getGroup() then
    local eventUnit = event.initiator
    local eventGroup = event.initiator:getGroup()
    for _, SAM in pairs(SAMSites) do
      if eventGroup:getName() == SAM.Name then
        if eventUnit:hasAttribute("SAM TR") then
          SAM.numSAMRadars = SAM.numSAMRadars - 1
        end
        if SAM.numSAMRadars < 1 then
          for _, EWR in pairs(EWRSites) do
            for _, SAMControlled in pairs(EWR.SAMsControlled) do
              if SAMControlled.Name == SAM.Name then
                EWR.SAMsControlled[SAM.Name] = nil
              end
            end
          end
          SAMSites[SAM.Name] = nil
        end
      end
    end
    for _, EWR in pairs(EWRSites) do
      if eventGroup:getName() == EWR.Name then
        if eventUnit:hasAttribute("EWR") then
          EWR.numEWRRadars = EWR.numEWRRadars - 1
          if EWR.numEWRRadars < 1 then
            for _, SAM in pairs(SAMSites) do
              for _, controllingEWR in pairs(SAM.ControlledBy) do
                if controllingEWR.Name == EWR.Name then
                  SAM.ControlledBy[EWR.Name] = nil
                end
              end
            end
            EWRSites[EWR.Name] = nil
          end
        end
      end
      for _, AWACS in pairs(AWACSAircraft) do
        if eventGroup:getName() == EWR.Name then
          if eventUnit:hasAttribute("AWACS") then
            AWACS.numAWACS = AWACS.numAWACS - 1
            if AWACS.numAWACS < 1 then
              AWACSAircraft[AWACS.Name] = nil
            end
          end
        end
      end
    end
  end
end

local function onShot(event)
  if IADSRadioDetection then
    if event.weapon then
      local ordnance = event.weapon
      local WeaponPoint = ordnance:getPoint()
      local WeaponDesc = ordnance:getDesc()
      local init = event.initiator
      if WeaponDesc.guidance == 5 then
        for _, SAM in pairs(SAMSites) do
          if math.random(1,100) < IADSARMHidePctage and getDistance(SAM.Location, WeaponPoint) < IADSARMHideRangeRadio then
            magnumHide(SAM)
          end
        end
      end
    end
  end
end

local function onBirth(event)
  if event.initiator:getCategory() ~= Object.Category.Unit then
    return
  end
  local gp = event.initiator:getGroup()
  checkGroupRole(gp)
  associateSAMS()
  --TO DO: make a fcn for each EWR and SAM individually for here
end

local function disableAllSAMs()
  for _, SAM in pairs(SAMSites) do
    SAM.SAMGroup:getController():setOption(AI.Option.Ground.id.ALARM_STATE,1)
    SAM.Enabled = false
  end
  return nil
end

local function populateLists()
  for _, gp in pairs(coalition.getGroups(1)) do
    checkGroupRole(gp)
  end
  associateSAMS()
  return nil
end

local function monitorTracks()

  for _, EWR in pairs(EWRSites) do
    for _, track in pairs(EWR.trackFiles) do
      if ((timer.getAbsTime() - track.LastDetected) > trackMemory or (not track.Object:isExist()) or (not track.Object:inAir())) then
        EWR.trackFiles[track.Name] = nil
        TrackFiles.EWR[track.Name] = nil
      end
    end
  end
  for _, SAM in pairs(SAMSites) do
    for _, track in pairs(SAM.trackFiles) do
      if ((timer.getAbsTime() - track.LastDetected) > trackMemory or (not track.Object:isExist()) or (not track.Object:inAir())) then
        SAM.trackFiles[track.Name] = nil
        TrackFiles.SAM[track.Name] = nil
      end
    end
  end
  for _, AWACS in pairs(AWACSAircraft) do
    for _, track in pairs(AWACS.trackFiles) do
      if ((timer.getAbsTime() - track.LastDetected) > trackMemory or (not track.Object:isExist()) or (not track.Object:inAir())) then
      AWACS.trackFiles[track.Name] = nil
        TrackFiles.AWACS[track.Name] = nil
      end
    end
  end
  return timer.getTime() + 2
end

local function protectedCall(...)
  local status, retval = pcall(...)
  if not status then
    env.warning("IADS script error... gracefully caught! " .. retval)
  end
end

function IADSHandler:onEvent(event)
  if event.id == world.event.S_EVENT_DEAD then
    protectedCall(onDeath, event)
  elseif event.id == world.event.S_EVENT_SHOT then
    protectedCall(onShot, event)
  elseif event.id == world.event.S_EVENT_BIRTH then
    protectedCall(onBirth, event)
  end
end

if(IADSEnable) then
  env.info("ENABLING IADS SCRIPT")
  world.addEventHandler(IADSHandler)
  timer.scheduleFunction(function()
      protectedCall(populateLists)
      return
    end,
    {},
    timer.getTime()+5
  )

  timer.scheduleFunction(function()
      protectedCall(EWRTrackFileBuild)
      return timer.getTime()+2
    end,
    {},
    timer.getTime()+10
  )

  timer.scheduleFunction(function()
      protectedCall(SAMTrackFileBuild)
      return timer.getTime()+2
    end,
     {},
     timer.getTime()+11
   )
    timer.scheduleFunction(function()
      protectedCall(monitorTracks)
      return timer.getTime()+2
    end,
     {},
     timer.getTime()+13
   )
     timer.scheduleFunction(function()
      protectedCall(SAMCheckHidden)
      return timer.getTime()+2
    end,
     {},
     timer.getTime()+14
   )
     timer.scheduleFunction(function()
      protectedCall(BlinkSAM)
      return timer.getTime()+2
    end,
     {},
     timer.getTime()+15
   )
     timer.scheduleFunction(function()
      protectedCall(EWRSAMOnRequest)
      return timer.getTime()+2
    end,
     {},
     timer.getTime()+16
   )
     timer.scheduleFunction(function()
      protectedCall(disableAllSAMs)
      return
    end,
     {},
     timer.getTime()+17
   )
  --   timer.scheduleFunction(function()
  --      protectedCall(AWACSTrackFileBuild)
  --      return timer.getTime()+2
  --    end,
  --    {},
  --     timer.getTime()+12
  --   )
end
