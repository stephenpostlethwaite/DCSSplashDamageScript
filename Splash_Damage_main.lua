--[[-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=
                                                                Latest Changes                                       
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-	  

    x x 2025 - 3.4

		(Stevey666) 
		
	  - Added in optional kill feed feature, this will try to display kills from DCS engine and kills from the additional explosions by checking pre/post scans of the explosion area
			    --SPLASH KILL FEED WORKS IN MP ONLY (you can host your local SP mission as MP for now)
	  - Added in Lekas Foothold Integration to allow splash kills to count towards the points, killfeed is required to be enabled for this
	  - Added AGM_45B to expl table
	  - Reworked tracking for Giant Explosion, Cookoffs
	  - Mission Maker Friendly Options
			-
			
	  - New Feature: IED.  If a unit is called IEDTarget(*) it will 
	  
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-	  
                                                                Full Changelog at the bottom of the script
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-	  	  


-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-
                                                                ##### SCRIPT CONFIGURATION #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]
splash_damage_options = {
    ---------------------------------------------------------------------- Debug and Messages ----------------------------------------------------------------
    ["game_messages"] = false, --enable some messages on screen
    ["debug"] = false,  --enable debugging messages 
    ["weapon_missing_message"] = false, --false disables messages alerting you to weapons missing from the explTable
    ["track_pre_explosion_debug"] = false, --Toggle to enable/disable pre-explosion tracking debugging
    ["track_groundunitordnance_debug"] = false, --Enable detailed debug messages for ground unit ordnance tracking
    ["napalm_unitdamage_debug"] = false, --Enable detailed debug messages for napalm unit damage tracking
    ["damage_model_game_messages"] = false, --ground unit movement and weapons disabled notification
    ["killfeed_debug"] = false, --Enable detailed debug messages for killfeed
    ["events_debug"] = false, --enable debugging for event handling
	
    ---------------------------------------------------------------------- Radio -----------------------------------------------------------------------------
    ["enable_radio_menu"] = false, --enables the in-game radio menu for modifying settings
    

    ---------------------------------------------------------------------- Basic Splash Settings -------------------------------------------------------------
    ["static_damage_boost"] = 2000, --apply extra damage to Unit.Category.STRUCTUREs with wave explosions
    ["wave_explosions"] = true, --secondary explosions on top of game objects, radiating outward from the impact point and scaled based on size of object and distance from weapon impact point
    ["larger_explosions"] = true, --secondary explosions on top of weapon impact points, dictated by the values in the explTable
    ["damage_model"] = true, --allow blast wave to affect ground unit movement and weapons
    ["blast_search_radius"] = 90, --this is the max size of any blast wave radius, since we will only find objects within this zone.  Only used if dynamic is not enabled
    ["use_dynamic_blast_radius"] = true,   --if true, blast radius is calculated from explosion power; if false, blast_search_radius (90) is used
    ["dynamic_blast_radius_modifier"] = 2,  --multiplier for the blast radius
    ["blast_stun"] = false, --not implemented
    ["overall_scaling"] = 1,    --overall scaling for explosive power

    ---------------------------------------------------------------------- Units -----------------------------------------------------------------------------
    ["unit_disabled_health"] = 30, --if health is below this value after our explosions, disable its movement 
    ["unit_cant_fire_health"] = 40, --if health is below this value after our explosions, set ROE to HOLD to simulate damage weapon systems
    ["infantry_cant_fire_health"] = 60,  --if health is below this value after our explosions, set ROE to HOLD to simulate severe injury
	

    ---------------------------------------------------------------------- Rockets ---------------------------------------------------------------------------
    ["rocket_multiplier"] = 1.3, --multiplied by the explTable value for rockets

    ---------------------------------------------------------------------- Shaped Charge ---------------------------------------------------------------------    
    ["apply_shaped_charge_effects"] = true, --apply reduction in blastwave etc for shaped charge munitions
    ["shaped_charge_multiplier"] = 0.2,  --multiplier that reduces blast radius and explosion power for shaped charge munitions.
    

    ---------------------------------------------------------------------- Cascading -------------------------------------------------------------------------  
    ["cascade_scaling"] = 2,    --multiplier for secondary (cascade) blast damage, 1 damage fades out too soon, 2 or 3 damage seems a good balance
    ["cascade_damage_threshold"] = 0.1, --if the calculated blast damage doesn't exceed this value, there will be no secondary explosion damage on the unit. If this value is too small, the appearance of explosions far outside of an expected radius looks incorrect.
    ["cascade_explode_threshold"] = 60,   --only trigger cascade explosion if the unit's current health is <= this percent of its maximum, setting can help blow nearby jeeps but not tanks
    ["always_cascade_explode"] = false, --switch if you want everything to explode like with the original script
    
    ---------------------------------------------------------------------- Cargo Cook Off/Fuel Explosion  ----------------------------------------------------
    --track_pre_explosion/enable_cargo_effects should both be the same value--
    
    ["track_pre_explosion"] = true, --Toggle to enable/disable pre-explosion tracking
    ["enable_cargo_effects"] = true, --Toggle for enabling/disabling cargo explosions and cook-offs  
    ["cargo_damage_threshold"] = 60, --Health % below which cargo explodes (0 = destroyed only)
    ["debris_effects"] = true, --Enable debris from cargo cook-offs
    ["debris_power"] = 1, --Power of each debris explosion
    ["debris_count_min"] = 6, --Minimum debris pieces per cook-off
    ["debris_count_max"] = 12, --Maximum debris pieces per cook-off
    ["debris_max_distance"] = 10, --Max distance debris can travel (meters), the min distance from the vehicle will be 10% of this
	
    ["cookoff_flares_enabled"] = false, --Enable/disable flare effects for cook-offs
    ["cookoff_flare_color"] = 2, 
    ["cookoff_flare_count_modifier"] = 1, --Multiplier for flare count (e.g., 1x, 2x cookOffCount from the vehicle table)
    ["cookoff_flare_offset"] = 1, --Max offset distance for flares in meters (horizontal)


    ---------------------------------------------------------------------- Ordnance Protection  --------------------------------------------------------------	
    ["ordnance_protection"] = true, --Toggle ordinance protection features
    ["ordnance_protection_radius"] = 10, --Distance in meters to protect nearby bombs
    ["detect_ordnance_destruction"] = true, --Toggle detection of ordnance destroyed by large explosions
    ["snap_to_ground_if_destroyed_by_large_explosion"] = true, --If the ordnance protection fails or is disabled we can snap larger_explosions to the ground (if enabled - power as set in weapon list) - so an explosion still does hit the ground
    ["max_snapped_height"] = 80, --max height it will snap to ground from
    ["recent_large_explosion_snap"] = true, --enable looking for a recent large_explosion generated by the script
    ["recent_large_explosion_range"] = 100, --range its looking for in meters for a recent large_explosion generated by the script
    ["recent_large_explosion_time"] = 4, --in seconds how long ago there was a recent large_explosion generated by the script


    ---------------------------------------------------------------------- Cluster Bombs ---------------------------------------------------------------------
    ["cluster_enabled"] = false,
    ["cluster_base_length"] = 150,           --Base forward spread (meters)
    ["cluster_base_width"] = 200,            --Base lateral spread (meters)
    ["cluster_max_length"] = 300,            --Max forward spread (meters)
    ["cluster_max_width"] = 400,             --Max lateral spread (meters)
    ["cluster_min_length"] = 100,            --Min forward spread
    ["cluster_min_width"] = 150,             --Min lateral spread
    ["cluster_bomblet_reductionmodifier"] = true, --Use equation to reduce number of bomblets (to make it look better)
    ["cluster_bomblet_damage_modifier"] = 1,  --Adjustable global modifier for bomblet explosive power
	

    ---------------------------------------------------------------------- Giant Explosions ------------------------------------------------------------------
    	--Remember, any target you want to blow up needs to be named "GiantExplosionTarget(X)"  (X) being any value/name etc
    ["giant_explosion_enabled"] = true,  --Toggle to enable/disable Giant Explosion
    ["giant_explosion_power"] = 6000,    --Power in kg of TNT (default 8 tons)
    ["giant_explosion_scale"] = 1,     --Size scale factor (default 1)
    ["giant_explosion_duration"] = 3.0,  --Total duration in seconds (default 3s)
    ["giant_explosion_count"] = 250,      --Number of explosions (default 250)
    ["giant_explosion_target_static"] = true, --Toggle to true for static targets (store position once), false for dynamic (update every second)
    ["giant_explosion_poll_rate"] = 1,    --Polling rate in seconds for flag checks (default 1s)
    ["giantexplosion_ondamage"] = true,   --Trigger explosion when unit is damaged
    ["giantexplosion_ondeath"] = true,    --Trigger explosion when unit is destroyed
    ["giantexplosion_testmode"] = true,  --Enable test mode with separate array for radio commands	
    

    ---------------------------------------------------------------------- Ground/Ship Ordnance  -------------------------------------------------------------
    ["track_groundunitordnance"] = false, --Enable tracking of ground unit ordnance (shells)
    ["groundunitordnance_damage_modifier"] = 1.0, --Multiplier for ground unit ordnance explosive power
    ["groundunitordnance_blastwave_modifier"] = 4.0, --Additional multiplier for blast wave intensity of ground unit ordnance
    ["groundunitordnance_maxtrackedcount"] = 100, --Maximum number of ground ordnance shells tracked at once to prevent overload
    ["scan_50m_for_groundordnance"] = true, --If true, uses a 50m scan radius for ground ordnance instead of dynamic blast radius
	
	
    ---------------------------------------------------------------------- Smoke and Cookoff For All Vehicles  -----------------------------------------------
    ["smokeandcookoffeffectallvehicles"] = false, --Enable effects for all ground vehicles not in cargoUnits vehicle table
    ["allunits_enable_smoke"] = false, -- Enable /disable smoke effects
    ["allunits_enable_cookoff"] = false, -- Enable /disable cookoffs
    ["allunits_explode_power"] = 50, --Initial power of vehicle exploding
    ["allunits_default_flame_size"] = 6, --Default smoke size (called flame here in the code, but it'll be smoke) 5 = small smoke, 6 = medium smoke, 7 = large smoke,  8 = huge smoke 
    ["allunits_default_flame_duration"] = 60, --Default smoke (called flame here in the code, but it's smoke) duration in seconds for non-cargoUnits vehicles
    ["allunits_cookoff_count"] = 4, --number of cookoff explosions to schedule
    ["allunits_cookoff_duration"] = 30, --max time window of cookoffs (will be scheduled randomly between 0 seconds and this figure)
    ["allunits_cookoff_power"] = 10, --power of the cookoff explosions
    ["allunits_cookoff_powerrandom"] = 50, --percentage higher or lower of the cookoff power figure


    ---------------------------------------------------------------------- Napalm  ---------------------------------------------------------------------------
    ["napalm_mk77_enabled"] = true, --Enable napalm effects for MK77mod0-WPN and MK77mod1-WPN
    ["napalmoverride_enabled"] = false, --If true, enables napalm effects for weapons in napalm_override_weapons
    ["napalm_override_weapons"] = "Mk_82,SAMP125LD", --Comma-separated list of weapons to override as napalm when overrides enabled, i.e Mk_82,SAMP125LD.  Do not pick CBUs
 
    ["napalm_spread_points"] = 4, --Number of points of explosion per each bomb (aka spawns of dummy fuel tank), so 1 bomb can have 4 fireballs as such.  The MK77 0 is bigger and will do a % more by default (i.e 5 instead of 4)
    ["napalm_spread_spacing"] = 25, --Distance m between the points
    ["napalm_phosphor_enabled"] = true, --If true, enables phosphor flare effects for napalm weapons
    ["napalm_phosphor_multiplier"] = 0.5, --Multiplier for number of phosphor flares that shoot out, there is a level of randomisation in the code already
    ["napalm_addflame"] = true, --Enable flame effects at napalm spawn points
    ["napalm_addflame_size"] = 3, --Flame size (1-8, 4 = huge smoke and  fire)
    ["napalm_addflame_duration"] = 180, --Flame duration in seconds napalm_destroy_delay
    ["napalm_flame_delay"] = 0.01, --Delay in seconds before flame effect
    ["napalm_explode_delay"] = 0.01, --Delay in seconds before putting an exlode on the ground to blow up the spawned fuel tank, original script had this as 0.1
    ["napalm_destroy_delay"] = 0.02, --Delay in seconds before it destroys the fuel tank object, original script had this as 0.12
	
    ["napalm_doublewide_enabled"] = false, --Toggle for double-wide napalm (two points per spread point, ~28m width)
    ["napalm_doublewide_spread"] = 15, --Meters either side of bomb vector either side to spawn a fuel tank
	
    ["napalm_unitdamage_enable"] = true, --Enable/disable napalm unit damage
    ["napalm_unitdamage_scandistance"] = 70, --Scan radius in meters
    ["napalm_unitdamage_startdelay"] = 0.1, --Seconds between Napalm exploding and explosion occurring (can be 0 for no delay)
    ["napalm_unitdamage_spreaddelay"] = 0, --If startdelay is greater than 0, explosions are ordered by distance with this gap between each unit
	
    ---------------------------------------------------------------------- Kill Feed  ------------------------------------------------------------------------
    ["killfeed_enable"] = false, --Enable killfeed logging and messaging
    ["killfeed_game_messages"] = false, --Show killfeed SPLASH KILL FEED WORKS IN MP ONLY (you can host your local SP mission as MP for now)
    ["killfeed_game_message_duration"] = 15, --Duration in seconds for game messages (killfeed and SplashKillFeed) - note the message will be delayed to let DCS catch up as per next option
    ["killfeed_splashdelay"] = 8, --Duration in seconds delay to allow dcs to see that units are dead before saying the splash damage got them instead of the the players weapon
    ["killfeed_lekas_foothold_integration"] = false, --Enable Lekas Foothold integration
    ["killfeed_lekas_contribution_delay"] = 240, -- Delay in seconds before processing splash kills into Lekas contributions (default 240 seconds/4mins)
}

local script_enable = 1
refreshRate = 0.1
----[[ ##### End of SCRIPT CONFIGURATION ##### ]]----

--Helper function: Trim whitespace.
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end
 
cargoUnits = {

--[[
flamesize:

 1 = small smoke and fire
 2 = medium smoke and fire
 3 = large smoke and fire
 4 = huge smoke and fire
 5 = small smoke
 6 = medium smoke 
 7 = large smoke
 8 = huge smoke 
]]--	

    --1) M92 R11 Volvo driveable (Fuel Truck Tanker)
    ["r11_volvo_drivable"] = { 
        cargoExplosion = true,
        cargoExplosionMult = 2.0,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --2) Refueler ATMZ-5
    ["ATMZ-5"] = {
        cargoExplosion = true,
        cargoExplosionMult = 2.0,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --3) Refueler ATZ-10
    ["ATZ-10"] = {
        cargoExplosion = true,
        cargoExplosionMult = 2,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --4) Refueler ATZ-5 
    ["ATZ-5"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1.8,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --5) Refueler M978 HEMTT (Fuel truck tanker)
    ["M978 HEMTT Tanker"] = {
        cargoExplosion = true,
        cargoExplosionMult = 2.0,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 0,
        cookOffPower = 0,
        cookOffDuration = 0,
        cookOffRandomTiming = false,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 3,
        flameDuration = 5,
    },

    --##### AMMO CARRIERS #####
    ["GAZ-66"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 4,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },
--#Technically this is both ammo and fuel looking at the model
--#Called Ural-4320 in game, but in code its Ural-375
    ["Ural-375"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 4,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 1,
        flameDuration = 30,
    },

    ["ZIL-135"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },
	
	--#Ammo Boxes etc
	
	--#Long ammo box
	
	    ["Cargo06"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },

		--#ammo boxes
	
	    ["Cargo03"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 10,
        cargoCookOff = true,
        cookOffCount = 10,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 0,
        isTanker = false,
        flameSize = 1,
        flameDuration = 30,
    },
	
		--FuelBarrels
	
	    ["Cargo05"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 2,
        flameDuration = 30,
    },
	
		--APFC fuel
	
	    ["APFC fuel"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 2,
        flameDuration = 30,
    },
	
		--Oil Barrel
	
	    ["Oil Barrel"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = false,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 10,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = true,
        flameSize = 1,
        flameDuration = 20,
    },
	
	
		--FARP Ammo Dump Coating
	
	    ["FARP Ammo Dump Coating"] = {
        cargoExplosion = true,
        cargoExplosionMult = 1,
		cargoExplosionPower = 50,
        cargoCookOff = true,
        cookOffCount = 5,
        cookOffPower = 1,
        cookOffDuration = 20,
        cookOffRandomTiming = true,
        cookOffPowerRandom = 50,
        isTanker = false,
        flameSize = 1,
        flameDuration = 20,
    },
}
--[[


-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-
                                                                Weapon Explosive Table             
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]
explTable = {
    --*** WWII BOMBS ***
    ["British_GP_250LB_Bomb_Mk1"] = { explosive = 100, shaped_charge = false },
    ["British_GP_250LB_Bomb_Mk4"] = { explosive = 100, shaped_charge = false },
    ["British_GP_250LB_Bomb_Mk5"] = { explosive = 100, shaped_charge = false },
    ["British_GP_500LB_Bomb_Mk1"] = { explosive = 213, shaped_charge = false },
    ["British_GP_500LB_Bomb_Mk4"] = { explosive = 213, shaped_charge = false },
    ["British_GP_500LB_Bomb_Mk4_Short"] = { explosive = 213, shaped_charge = false },
    ["British_GP_500LB_Bomb_Mk5"] = { explosive = 213, shaped_charge = false },
    ["British_MC_250LB_Bomb_Mk1"] = { explosive = 100, shaped_charge = false },
    ["British_MC_250LB_Bomb_Mk2"] = { explosive = 100, shaped_charge = false },
    ["British_MC_500LB_Bomb_Mk1_Short"] = { explosive = 213, shaped_charge = false },
    ["British_MC_500LB_Bomb_Mk2"] = { explosive = 213, shaped_charge = false },
    ["British_SAP_250LB_Bomb_Mk5"] = { explosive = 100, shaped_charge = false },
    ["British_SAP_500LB_Bomb_Mk5"] = { explosive = 213, shaped_charge = false },
    ["British_AP_25LBNo1_3INCHNo1"] = { explosive = 4, shaped_charge = false },
    ["British_HE_60LBSAPNo2_3INCHNo1"] = { explosive = 4, shaped_charge = false },
    ["British_HE_60LBFNo1_3INCHNo1"] = { explosive = 4, shaped_charge = false },
  
    ["SC_50"] = { explosive = 20, shaped_charge = false },
    ["ER_4_SC50"] = { explosive = 20, shaped_charge = false },
    ["SC_250_T1_L2"] = { explosive = 100, shaped_charge = false },
    ["SC_501_SC250"] = { explosive = 100, shaped_charge = false },
    ["Schloss500XIIC1_SC_250_T3_J"] = { explosive = 100, shaped_charge = false },
    ["SC_501_SC500"] = { explosive = 213, shaped_charge = false },
    ["SC_500_L2"] = { explosive = 213, shaped_charge = false },
    ["SD_250_Stg"] = { explosive = 100, shaped_charge = false },
    ["SD_500_A"] = { explosive = 213, shaped_charge = false },
  
    --*** WWII CBU ***
    ["AB_250_2_SD_2"] = { explosive = 100, shaped_charge = false },
    ["AB_250_2_SD_10A"] = { explosive = 100, shaped_charge = false },
    ["AB_500_1_SD_10A"] = { explosive = 213, shaped_charge = false },
  
    --*** WWII ROCKETS ***
    ["3xM8_ROCKETS_IN_TUBES"] = { explosive = 4, shaped_charge = false },
    ["WGr21"] = { explosive = 4, shaped_charge = false },
  
    --*** UNGUIDED BOMBS (UGB) ***
    ["M_117"] = { explosive = 201, shaped_charge = false },
    ["AN_M30A1"] = { explosive = 45, shaped_charge = false },
    ["AN_M57"] = { explosive = 100, shaped_charge = false },
    ["AN_M64"] = { explosive = 121, shaped_charge = false },
    ["AN_M65"] = { explosive = 400, shaped_charge = false },
    ["AN_M66"] = { explosive = 800, shaped_charge = false },
    ["AN-M66A2"] = { explosive = 536, shaped_charge = false },
    ["AN-M81"] = { explosive = 100, shaped_charge = false },
    ["AN-M88"] = { explosive = 100, shaped_charge = false },
  
    ["Mk_81"] = { explosive = 60, shaped_charge = false },
    ["MK-81SE"] = { explosive = 60, shaped_charge = false },
    ["Mk_82"] = { explosive = 100, shaped_charge = false },
    ["MK_82AIR"] = { explosive = 100, shaped_charge = false },
    ["MK_82SNAKEYE"] = { explosive = 100, shaped_charge = false },
    ["Mk_83"] = { explosive = 274, shaped_charge = false },
    ["Mk_84"] = { explosive = 582, shaped_charge = false },
  
    ["HEBOMB"] = { explosive = 40, shaped_charge = false },
    ["HEBOMBD"] = { explosive = 40, shaped_charge = false },
  
    ["SAMP125LD"] = { explosive = 60, shaped_charge = false },
    ["SAMP250LD"] = { explosive = 118, shaped_charge = false },
    ["SAMP250HD"] = { explosive = 118, shaped_charge = false },
    ["SAMP400LD"] = { explosive = 274, shaped_charge = false },
    ["SAMP400HD"] = { explosive = 274, shaped_charge = false },
  
    ["BR_250"] = { explosive = 100, shaped_charge = false },
    ["BR_500"] = { explosive = 100, shaped_charge = false },
  
    ["FAB_100"] = { explosive = 45, shaped_charge = false },
    ["FAB_250"] = { explosive = 118, shaped_charge = false },
    ["FAB_250M54TU"] = { explosive = 118, shaped_charge = false },
    ["FAB-250-M62"] = { explosive = 118, shaped_charge = false },
    ["FAB_500"] = { explosive = 213, shaped_charge = false },
    ["FAB_1500"] = { explosive = 675, shaped_charge = false },
  
    --*** UNGUIDED BOMBS WITH PENETRATOR / ANTI-RUNWAY ***
    ["Durandal"] = { explosive = 64, shaped_charge = false },
    ["BLU107B_DURANDAL"] = { explosive = 64, shaped_charge = false },
    ["BAP_100"] = { explosive = 32, shaped_charge = false },
    ["BAP-100"] = { explosive = 32, shaped_charge = false },
    ["BAT-120"] = { explosive = 32, shaped_charge = false },
    ["TYPE-200A"] = { explosive = 107, shaped_charge = false },
    ["BetAB_500"] = { explosive = 98, shaped_charge = false },
    ["BetAB_500ShP"] = { explosive = 107, shaped_charge = false },
    
    --*** GUIDED BOMBS (GBU) ***
    ["GBU_10"] = { explosive = 582, shaped_charge = false },
    ["GBU_12"] = { explosive = 100, shaped_charge = false },
    ["GBU_16"] = { explosive = 274, shaped_charge = false },
    ["GBU_24"] = { explosive = 582, shaped_charge = false },
    ["KAB_1500Kr"] = { explosive = 675, shaped_charge = false },
    ["KAB_500Kr"] = { explosive = 213, shaped_charge = false },
    ["KAB_500"] = { explosive = 213, shaped_charge = false },
  
    --*** CLUSTER BOMBS (CBU) ***
	--I don't have most of these so can't test them with debug on
    ["MK77mod0-WPN"] = { explosive = 0, shaped_charge = false, cluster = false, submunition_count = 132, submunition_explosive = 0.1, submunition_name = "BLU_1B" }, --napalm skyhawk, have set to cluster (false) for napalm purposes
    ["MK77mod1-WPN"] = { explosive = 0, shaped_charge = false, cluster = false, submunition_count = 132, submunition_explosive = 0.1, submunition_name = "BLU_1B" }, --napalm skyhawk, have set to cluster (false) for napalm purposes
    ["CBU_99"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 247, submunition_explosive = 2, submunition_name = "Mk 118" }, --Mk 20 Rockeye variant, confirmed 247 Mk 118 bomblets
    ["ROCKEYE"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 247, submunition_explosive = 2, submunition_name = "Mk 118" }, --Mk 20 Rockeye, confirmed 247 Mk 118 bomblets
    ["BLU_3B_GROUP"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 19, submunition_explosive = 0.2, submunition_name = "BLU_3B" }, --Not in datamine, possibly custom or outdated; submunition name guessed
    ["CBU_87"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 202, submunition_explosive = 0.5, submunition_name = "BLU_97B" }, --Confirmed 202 BLU-97/B bomblets
    ["CBU_103"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 202, submunition_explosive = 0.5, submunition_name = "BLU_97B" }, --WCMD variant of CBU-87, confirmed 202 BLU-97/B bomblets
    ["CBU_97"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 10, submunition_explosive = 15, submunition_name = "BLU_108" }, --Confirmed 10 BLU-108 submunitions, each with 4 skeets
    ["CBU_105"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 10, submunition_explosive = 15, submunition_name = "BLU_108" }, --WCMD variant of CBU-97, confirmed 10 BLU-108 submunitions
    ["BELOUGA"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 151, submunition_explosive = 0.3, submunition_name = "grenade_AC" }, --Confirmed 151 grenade_AC bomblets (French BLG-66)
    ["BLG66_BELOUGA"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 151, submunition_explosive = 0.3, submunition_name = "grenade_AC" }, --Alias for BELOUGA, confirmed 151 grenade_AC bomblets
    ["BL_755"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 147, submunition_explosive = 0.4, submunition_name = "BL_755_bomblet" }, --Confirmed 147 bomblets, submunition name from your table
    ["RBK_250"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 60, submunition_explosive = 0.5, submunition_name = "PTAB_25M" }, --Confirmed 60 PTAB-2.5M anti-tank bomblets
    ["RBK_250_275_AO_1SCH"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 150, submunition_explosive = 0.2, submunition_name = "AO_1SCh" }, --Confirmed 150 AO-1SCh fragmentation bomblets
    ["RBK_500"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 108, submunition_explosive = 0.5, submunition_name = "PTAB_10_5" }, --Confirmed 108 PTAB-10-5 anti-tank bomblets
    ["RBK_500U"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 352, submunition_explosive = 0.2, submunition_name = "OAB_25RT" }, --Confirmed 352 OAB-2.5RT fragmentation bomblets
    ["RBK_500AO"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 108, submunition_explosive = 0.5, submunition_name = "AO_25RT" }, --Confirmed 108 AO-2.5RT fragmentation bomblets
    ["RBK_500U_OAB_2_5RT"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 352, submunition_explosive = 0.2, submunition_name = "OAB_25RT" }, --Confirmed 352 OAB-2.5RT fragmentation bomblets
    ["RBK_500_255_PTO_1M"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 126, submunition_explosive = 0.5, submunition_name = "PTO_1M" },
    ["RBK_500_255_ShO"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 565, submunition_explosive = 0.1, submunition_name = "ShO" },  
    --*** INS/GPS BOMBS (JDAM) ***
    ["GBU_31"] = { explosive = 582, shaped_charge = false },
    ["GBU_31_V_3B"] = { explosive = 582, shaped_charge = false },
    ["GBU_31_V_2B"] = { explosive = 582, shaped_charge = false },
    ["GBU_31_V_4B"] = { explosive = 582, shaped_charge = false },
    ["GBU_32_V_2B"] = { explosive = 202, shaped_charge = false },
    ["GBU_38"] = { explosive = 100, shaped_charge = false },
    ["GBU_54_V_1B"] = { explosive = 100, shaped_charge = false },
  
    --*** GLIDE BOMBS (JSOW) ***
    ["AGM_154A"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 145, submunition_explosive = 2, submunition_name = "BLU-97/B" }, --JSOW-A, confirmed 145 BLU-97 bomblets from datamine
    ["AGM_154C"] = { explosive = 305, shaped_charge = false },
    ["AGM_154"] = { explosive = 305, shaped_charge = false },
    ["BK90_MJ1"] = { explosive = 0, shaped_charge = false },
    ["BK90_MJ1_MJ2"] = { explosive = 0, shaped_charge = false },
    ["BK90_MJ2"] = { explosive = 0, shaped_charge = false },
  
    ["LS-6-100"] = { explosive = 45, shaped_charge = false },
    ["LS-6-250"] = { explosive = 100, shaped_charge = false },
    ["LS-6-500"] = { explosive = 274, shaped_charge = false },
    ["GB-6"] = { explosive = 0, shaped_charge = false },
    ["GB-6-HE"] = { explosive = 0, shaped_charge = false },
    ["GB-6-SFW"] = { explosive = 0, shaped_charge = false },
    ["X_65"] = { explosive = 100, shaped_charge = false },
  
    --*** AIR GROUND MISSILE (AGM) ***
    ["AGM_62"] = { explosive = 400, shaped_charge = false },
    ["AGM_65D"] = { explosive = 38, shaped_charge = true },
    ["AGM_65E"] = { explosive = 80, shaped_charge = true },
    ["AGM_65F"] = { explosive = 80, shaped_charge = true },
    ["AGM_65G"] = { explosive = 80, shaped_charge = true },
    ["AGM_65H"] = { explosive = 38, shaped_charge = true },
    ["AGM_65K"] = { explosive = 80, shaped_charge = true },
    ["AGM_65L"] = { explosive = 80, shaped_charge = true },
    ["AGM_123"] = { explosive = 274, shaped_charge = false },
    ["AGM_130"] = { explosive = 582, shaped_charge = false },
    ["AGM_119"] = { explosive = 176, shaped_charge = false },
    ["AGM_114"] = { explosive = 10, shaped_charge = true },
    ["AGM_114K"] = { explosive = 10, shaped_charge = true },
  
    ["Rb 05A"] = { explosive = 217, shaped_charge = false },
    ["RB75"] = { explosive = 38, shaped_charge = false },
    ["RB75A"] = { explosive = 38, shaped_charge = false },
    ["RB75B"] = { explosive = 38, shaped_charge = false },
    ["RB75T"] = { explosive = 80, shaped_charge = false },
    ["HOT3_MBDA"] = { explosive = 15, shaped_charge = false },
    ["C-701T"] = { explosive = 38, shaped_charge = false },
    ["C-701IR"] = { explosive = 38, shaped_charge = false },
  
    ["Vikhr_M"] = { explosive = 11, shaped_charge = false },
    ["Vikhr_9M127_1"] = { explosive = 11, shaped_charge = false },
    ["AT_6"] = { explosive = 11, shaped_charge = false },
    ["Ataka_9M120"] = { explosive = 11, shaped_charge = false },
    ["Ataka_9M120F"] = { explosive = 11, shaped_charge = false },
    ["P_9M117"] = { explosive = 0, shaped_charge = false },
    
    ["KH-66_Grom"] = { explosive = 108, shaped_charge = false },
    ["X_23"] = { explosive = 111, shaped_charge = false },
    ["X_23L"] = { explosive = 111, shaped_charge = false },
    ["X_28"] = { explosive = 160, shaped_charge = false },
    ["X_25ML"] = { explosive = 89, shaped_charge = false },
    ["X_25MR"] = { explosive = 140, shaped_charge = false },
    ["X_29L"] = { explosive = 320, shaped_charge = false },
    ["X_29T"] = { explosive = 320, shaped_charge = false },
    ["X_29TE"] = { explosive = 320, shaped_charge = false },
	
    ["AKD-10"] = { explosive = 10, shaped_charge = false }, --drone
	
    --*** ANTI-RADAR MISSILE (ARM) ***
    ["AGM_88C"] = { explosive = 69, shaped_charge = false },
    ["AGM_88"] = { explosive = 69, shaped_charge = false },
    ["AGM_122"] = { explosive = 12, shaped_charge = false },
    ["LD-10"] = { explosive = 75, shaped_charge = false },
    ["AGM_45A"] = { explosive = 66, shaped_charge = false },
	["AGM_45B"] = { explosive = 66, shaped_charge = false },
    ["X_58"] = { explosive = 149, shaped_charge = false },
    ["X_25MP"] = { explosive = 90, shaped_charge = false },
    ["X_31P"]    = { explosive = 90,  shaped_charge = false },
  
    --*** ANTI-SHIP MISSILE (ASh) ***
    ["AGM_84D"] = { explosive = 488, shaped_charge = false },
    ["Rb 15F"] = { explosive = 500, shaped_charge = false },
    ["C-802AK"] = { explosive = 500, shaped_charge = false },
    ["X_31A"]    = { explosive = 89,  shaped_charge = false }, --KH-31A ASh
    ["X_22"]    = { explosive = 1200,  shaped_charge = false }, --Ash 1ton RDX = 1600KG TNT
    ["X_35"]    = { explosive = 145,  shaped_charge = true }, --ASh 145KG
	
    --*** CRUISE MISSILE ***
    ["CM-802AKG"] = { explosive = 240, shaped_charge = false },
    ["AGM_84E"] = { explosive = 360, shaped_charge = false },
    ["AGM_84H"] = { explosive = 380, shaped_charge = false },
    ["X_59M"] = { explosive = 340, shaped_charge = false },
    ["X_65"] = { explosive = 545, shaped_charge = false },
  
    --*** ROCKETS ***
    ["HYDRA_70M15"] = { explosive = 5, shaped_charge = false },
    ["HYDRA_70_MK1"] = { explosive = 5, shaped_charge = false },
    ["HYDRA_70_MK5"] = { explosive = 8, shaped_charge = false },
    ["HYDRA_70_M151"] = { explosive = 5, shaped_charge = false },
    ["HYDRA_70_M151_M433"] = { explosive = 5, shaped_charge = false },
    ["HYDRA_70_M229"] = { explosive = 10, shaped_charge = false },
    ["FFAR Mk1 HE"] = { explosive = 5, shaped_charge = false },
    ["FFAR Mk5 HEAT"] = { explosive = 8, shaped_charge = false },
    ["HVAR"] = { explosive = 5, shaped_charge = false },
    ["Zuni_127"] = { explosive = 8, shaped_charge = false },
    ["ARAKM70BHE"] = { explosive = 5, shaped_charge = false },
    ["ARAKM70BAP"] = { explosive = 8, shaped_charge = false },
    ["SNEB_TYPE251_F1B"] = { explosive = 4, shaped_charge = false },
    ["SNEB_TYPE252_F1B"] = { explosive = 4, shaped_charge = false },
    ["SNEB_TYPE253_F1B"] = { explosive = 5, shaped_charge = false },
    ["SNEB_TYPE256_F1B"] = { explosive = 6, shaped_charge = false },
    ["SNEB_TYPE257_F1B"] = { explosive = 8, shaped_charge = false },
    ["SNEB_TYPE251_F4B"] = { explosive = 4, shaped_charge = false },
    ["SNEB_TYPE252_F4B"] = { explosive = 4, shaped_charge = false },
    ["SNEB_TYPE253_F4B"] = { explosive = 5, shaped_charge = false },
    ["SNEB_TYPE256_F4B"] = { explosive = 6, shaped_charge = false },
    ["SNEB_TYPE257_F4B"] = { explosive = 8, shaped_charge = false },
    ["SNEB_TYPE251_H1"] = { explosive = 4, shaped_charge = false },
    ["SNEB_TYPE252_H1"] = { explosive = 4, shaped_charge = false },
    ["SNEB_TYPE253_H1"] = { explosive = 5, shaped_charge = false },
    ["SNEB_TYPE256_H1"] = { explosive = 6, shaped_charge = false },
    ["SNEB_TYPE257_H1"] = { explosive = 8, shaped_charge = false },
    ["MATRA_F4_SNEBT251"] = { explosive = 8, shaped_charge = false },
    ["MATRA_F4_SNEBT253"] = { explosive = 8, shaped_charge = false },
    ["MATRA_F4_SNEBT256"] = { explosive = 8, shaped_charge = false },
    ["MATRA_F1_SNEBT253"] = { explosive = 8, shaped_charge = false },
    ["MATRA_F1_SNEBT256"] = { explosive = 8, shaped_charge = false },
    ["TELSON8_SNEBT251"] = { explosive = 4, shaped_charge = false },
    ["TELSON8_SNEBT253"] = { explosive = 8, shaped_charge = false },
    ["TELSON8_SNEBT256"] = { explosive = 4, shaped_charge = false },
    ["TELSON8_SNEBT257"] = { explosive = 6, shaped_charge = false },
    ["ARF8M3API"] = { explosive = 8, shaped_charge = false },
    ["UG_90MM"] = { explosive = 8, shaped_charge = false },
    ["S-24A"] = { explosive = 24, shaped_charge = false },
    ["S-25OF"] = { explosive = 194, shaped_charge = false },
    ["S-25OFM"] = { explosive = 150, shaped_charge = false },
    ["S-25O"] = { explosive = 150, shaped_charge = false },
    ["S-25-O"] = { explosive = 150, shaped_charge = false },
    ["S_25L"] = { explosive = 190, shaped_charge = false },
    ["S-5M"] = { explosive = 3, shaped_charge = false },
    ["C_5"] = { explosive = 8, shaped_charge = false },
    ["C5"] = { explosive = 5, shaped_charge = false },
    ["C_8"] = { explosive = 5, shaped_charge = false },
    ["C_8OFP2"] = { explosive = 5, shaped_charge = false },
    ["C_13"] = { explosive = 21, shaped_charge = false },
    ["C_24"] = { explosive = 123, shaped_charge = false },
    ["C_25"] = { explosive = 151, shaped_charge = false },
  
    --*** LASER ROCKETS ***
    ["AGR_20"] = { explosive = 8, shaped_charge = false },
    ["AGR_20A"] = { explosive = 8, shaped_charge = false },
    ["AGR_20_M282"] = { explosive = 8, shaped_charge = false },
    ["Hydra_70_M282_MPP"] = { explosive = 5, shaped_charge = true },
    ["BRM-1_90MM"] = { explosive = 8, shaped_charge = false },

    --*** JF17 weapons changes as per Kurdes ***
    ["C_701T"] = { explosive = 38, shaped_charge = false },
    ["C_701IR"] = { explosive = 38, shaped_charge = false },
    ["LS_6_100"] = { explosive = 45, shaped_charge = false },
    ["LS_6"] = { explosive = 100, shaped_charge = false },
    ["LS_6_500"] = { explosive = 274, shaped_charge = false },
	
    --==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
	                        --*** Vehicle/Ship based ***--	
    --==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--==--
    
	--*** Rocketry ***
    ["9M22U"] = { explosive = 25, shaped_charge = false, groundordnance = true }, --122mm HE rocket, BM-21 Grad (~20-30 kg TNT equiv)
    ["GRAD_9M22U"] = { explosive = 25, shaped_charge = false, groundordnance = true }, --122mm HE rocket, BM-21 Grad (~20-30 kg TNT equiv)
       -- ["M26"] = { explosive = 0, shaped_charge = false, groundordnance = true}, --227mm cluster rocket, M270 MLRS (adjusted for cluster)
    ["M26"] = { explosive = 0, shaped_charge = false, cluster = true, submunition_count = 644, submunition_explosive = 0.1, submunition_name = "M77", groundordnance = true }, --227mm cluster rocket, M270 MLRS (adjusted for cluster)
    ["SCUD_RAKETA"] = { explosive = 985, shaped_charge = false, groundordnance = true },
    ["SMERCH_9M55F"] = { explosive = 46, shaped_charge = false, groundordnance = true }, --220mm HE rocket, (~25-45 kg TNT equiv)
	
	["TOW2"] = { explosive = 6.5, shaped_charge = true, groundordnance = true },  --ATGM
	
	--*** Shells ***
	["weapons.shells.M_105mm_HE"] = { explosive = 12, shaped_charge = false, groundordnance = true }, --105mm HE shell, M119/M102 (~10-15 kg TNT equiv)
	["weapons.shells.M_155mm_HE"] = { explosive = 60, shaped_charge = false, groundordnance = true }, --155mm HE shell, M777/M109 (~50-70 kg TNT equiv)
	["weapons.shells.2A60_120"] = { explosive = 18, shaped_charge = false, groundordnance = true }, --120mm HE shell, 2B11 mortar (~15-20 kg TNT equiv)
	["weapons.shells.2A18_122"] = { explosive = 22, shaped_charge = false, groundordnance = true }, --122mm HE shell, D-30 (~20-25 kg TNT equiv)
	["weapons.shells.2A33_152"] = { explosive = 50, shaped_charge = false, groundordnance = true }, --152mm HE shell, SAU Akatsia (~40-60 kg TNT equiv)
	["weapons.shells.PLZ_155_HE"] = { explosive = 60, shaped_charge = false, groundordnance = true }, --155mm HE shell, PLZ05 (~50-70 kg TNT equiv)
	["weapons.shells.M185_155"] = { explosive = 60, shaped_charge = false, groundordnance = true }, --155mm HE shell, M109 (~50-70 kg TNT equiv)
	["weapons.shells.2A64_152"] = { explosive = 50, shaped_charge = false, groundordnance = true }, --152mm HE shell, SAU Msta (~40-60 kg TNT equiv) 
	
	["weapons.shells.2A46M_125_HE"] = { explosive = 5, shaped_charge = false, groundordnance = true }, --125mm HE shell, T-90 (~5-6 kg TNT equiv)
	["weapons.shells.HESH_105"] = { explosive = 6, shaped_charge = false, groundordnance = true }, --105mm HESH shell, M1128 Stryker (~4-6 kg TNT equiv)
	
	---*** Naval ***
	["weapons.missiles.AGM_84S"] = { explosive = 225, shaped_charge = false, groundordnance = true }, --Harpoon missile, Ticonderoga (~200-250 kg TNT equiv)
	["weapons.missiles.P_500"] = { explosive = 500, shaped_charge = false, groundordnance = true }, --P-500 Bazalt missile, Moscow (~450-550 kg TNT equiv)	
	
	["weapons.shells.AK176_76"] = { explosive = 1, shaped_charge = false, groundordnance = true }, --76mm HE shell, AK-176 (~0.7-1 kg TNT equiv)
	["weapons.shells.A222_130"] = { explosive = 5, shaped_charge = false, groundordnance = true }, --130mm HE shell, A-222 Bereg (~4-5 kg TNT equiv)
	["weapons.shells.53-UBR-281U"] = { explosive = 5, shaped_charge = false, groundordnance = true }, --130mm HE shell, SM-2-1 (~4-5 kg TNT equiv)
	["weapons.shells.PJ87_100_PFHE"] = { explosive = 3, shaped_charge = false, groundordnance = true }, --100mm HE-PF shell, Type 052B (~2.4-3.4 kg TNT equiv)
	["weapons.shells.AK100_100"] = { explosive = 3, shaped_charge = false, groundordnance = true }, --100mm HE shell, AK-100 (~2.5-3.5 kg TNT equiv) AK-100 100mm (e.g., on Project 1135 Krivak-class)
	["weapons.shells.AK130_130"] = { explosive = 5, shaped_charge = false, groundordnance = true }, --130mm HE shell, AK-130 (~4-5 kg TNT equiv) AK-130 130mm (e.g., on Project 956 Sovremenny-class)
	["weapons.shells.2A70_100"] = { explosive = 3, shaped_charge = false, groundordnance = true }, --100mm HE shell, 2A70 (~3-3.5 kg TNT equiv) 2A70 100mm (e.g., on Project 775 Ropucha-class)
	["weapons.shells.OTO_76"] = { explosive = 1, shaped_charge = false, groundordnance = true }, --76mm HE shell, OTO Melara (~0.8-1.1 kg TNT equiv) OTO Melara 76mm (e.g., on NATO frigates like Oliver Hazard Perry-class)
	["weapons.shells.MK45_127"] = { explosive = 5, shaped_charge = false, groundordnance = true }, --127mm HE shell, Mark 45 (~4.8-5.6 kg TNT equiv) Mark 45 127mm (e.g., on Arleigh Burke-class destroyers)
	["weapons.shells.PJ26_76_PFHE"] = { explosive = 1, shaped_charge = false, groundordnance = true }, --76mm HE-PF shell, PJ-26 (~0.8-1.1 kg TNT equiv)
	["weapons.shells.53-UOR-281U"] = { explosive = 5, shaped_charge = false, groundordnance = true }, --130mm HE shell, SM-2-1 (~4-5 kg TNT equiv)
	["weapons.shells.MK75_76"] = { explosive = 1, shaped_charge = false, groundordnance = true }, --76mm HE shell, Mk 75 (~0.8-1.1 kg TNT equiv)
	
	--*** Bismark Mod Weapon ***
    ["weapons.shells.Breda_37_HE"] = { explosive = 70, shaped_charge = false, groundordnance = true }, --380mm HE shell, 38 cm SK C/34 (~60-75 kg TNT equiv)
	--*** Bismark Mod Weapons ***
	["weapons.shells.380mm_HE"] = { explosive = 70, shaped_charge = false, groundordnance = true }, --380mm HE shell, 38 cm SK C/34 (~60-75 kg TNT equiv)
	["weapons.shells.SK_C_33_105_HE"] = { explosive = 15, shaped_charge = false, groundordnance = true }, --105mm HE shell, SK C/33 (~12-16 kg TNT equiv)
	
	
	
	
}

napalm_unitcat_tabl = {
    ["Infantry"] = { maxDamageDistance = 50, explosionPower = 0.5 }, 
    ["Tank"] = { maxDamageDistance = 30, explosionPower = 5 }, 
    ["Artillery"] = { maxDamageDistance = 40, explosionPower = 5 }, 
    ["Armored Vehicle"] = { maxDamageDistance = 35, explosionPower = 5 }, 
    ["Anti-Air"] = { maxDamageDistance = 35, explosionPower = 5 }, 
    ["Helicopter"] = { maxDamageDistance = 45, explosionPower = 5 }, 
    ["Airplane"] = { maxDamageDistance = 40, explosionPower = 5 },
    ["Structure"] = { maxDamageDistance = 60, explosionPower = 60 }
}

local effectSmokeId = 1

----[[ ##### HELPER/UTILITY FUNCTIONS ##### ]]----

--Global tables
local processedUnitIds = {}
local killfeedTable = {}
local splashKillfeedTable = {}
local splashKillfeedTemp = {}
local LogEventProcessedUnitTable = {}

--Function to safely get data with pcall
local function safeGet(func, default)
    local success, result = pcall(func)
    return success and result or default
end

--Function to clear processed unit IDs after a delay
function clearProcessedUnitIds(unitId)
    if processedUnitIds[unitId] then
        processedUnitIds[unitId] = nil
        if splash_damage_options.napalm_unitdamage_debug then
            env.info("scanUnitsForNapalm: Cleared unit ID " .. unitId .. " from processedUnitIds")
        end
    end
end

local function debugMsg(str)
    if splash_damage_options.debug == true then
        debugCounter = (debugCounter or 0) + 1
        local uniqueStr = str .. " [" .. timer.getTime() .. " - " .. debugCounter .. "]"
        trigger.action.outText(uniqueStr, 5)
        env.info("DEBUG: " .. uniqueStr)
    end
end

function napalm_phosphor(vec3)
    local baseFlareCount = math.random(0, 8) -- Wider range for variation
    local randomFactor = math.random(0.1, 1) -- Random scaling per call
    local scaledFlareCount = math.max(1, math.floor(baseFlareCount * splash_damage_options.napalm_phosphor_multiplier * randomFactor))
    for i = 1, scaledFlareCount do
        local randomAzimuth = math.random(0, 359) -- Random angle for scatter
        local offsetX = math.random(-15, 15) -- Position offset (meters)
        local offsetZ = math.random(-15, 15)
        local flarePos = { x = vec3.x + offsetX, y = vec3.y, z = vec3.z + offsetZ }
        trigger.action.signalFlare(flarePos, 2, randomAzimuth)
    end
    if splash_damage_options.debug then
        debugMsg("Triggered " .. scaledFlareCount .. " napalm phosphor flares at X: " .. string.format("%.0f", vec3.x) .. ", Z: " .. string.format("%.0f", vec3.z))
    end
end

--getSpreadPoints function
local function getSpreadPoints(impactPoint, velocity, numPoints, spacing)
    local points = {}
    local mag = math.sqrt(velocity.x^2 + velocity.z^2)
    if mag == 0 then
        table.insert(points, {x = impactPoint.x, y = land.getHeight({x = impactPoint.x, y = impactPoint.z}), z = impactPoint.z})
        return points
    end
    local dir = {x = velocity.x / mag, z = velocity.z / mag}
    local perpDir = {x = -dir.z, z = dir.x} --Perpendicular to velocity direction
    local prevHeight = land.getHeight({x = impactPoint.x, y = impactPoint.z})
    for i = 1, numPoints do
        local offset = (i - 1) * spacing
        if splash_damage_options.napalm_doublewide_enabled then
            --Double-wide: two points with ±15m lateral offset
            local point1 = {
                x = impactPoint.x + dir.x * offset + perpDir.x * splash_damage_options.napalm_doublewide_spread,
                z = impactPoint.z + dir.z * offset + perpDir.z * splash_damage_options.napalm_doublewide_spread
            }
            local terrainHeight1 = land.getHeight({x = point1.x, y = point1.z})
            local heightDiff1 = terrainHeight1 - prevHeight
            point1.y = prevHeight + math.max(math.min(heightDiff1, 30), -30)
            table.insert(points, point1)
            local point2 = {
                x = impactPoint.x + dir.x * offset - perpDir.x * splash_damage_options.napalm_doublewide_spread,
                z = impactPoint.z + dir.z * offset - perpDir.z * splash_damage_options.napalm_doublewide_spread
            }
            local terrainHeight2 = land.getHeight({x = point2.x, y = point2.z})
            local heightDiff2 = terrainHeight2 - prevHeight
            point2.y = prevHeight + math.max(math.min(heightDiff2, 30), -30)
            table.insert(points, point2)
            prevHeight = (terrainHeight1 + terrainHeight2) / 2
        else
            --Single point, linear spread
            local point = {
                x = impactPoint.x + dir.x * offset,
                z = impactPoint.z + dir.z * offset
            }
            local terrainHeight = land.getHeight({x = point.x, y = point.z})
            local heightDiff = terrainHeight - prevHeight
            point.y = prevHeight + math.max(math.min(heightDiff, 30), -30)
            table.insert(points, point)
            prevHeight = terrainHeight
        end
    end
    return points
end


function V3Mag(speedVec)
    local mag = speedVec.x*speedVec.x + speedVec.y*speedVec.y+speedVec.z*speedVec.z
    mag = math.sqrt(mag)
    return mag
end
  
function Vhead(speedVec)
    local speed = V3Mag(speedVec)
    local dist = speed * refreshRate * 1.5 
    return dist
end

function explodeNapalm(vec3)
    local explosionPos = {
        x = vec3.x,
        y = vec3.y + 1.6, --Add 1.6m to the ground height
        z = vec3.z
    }
    trigger.action.explosion(explosionPos, 10)
end
 
-- Helper function to calculate 2D distance
local function getDistance(point1, point2)
    local dX = math.abs(point1.x - point2.x)
    local dZ = math.abs(point1.z - point2.z)
    return math.sqrt(dX * dX + dZ * dZ)
end

--Scan for units around the napalm explosions and apply damage if required
function scanUnitsForNapalm(posX, posY, posZ)
    if not splash_damage_options.napalm_unitdamage_enable then 
        if splash_damage_options.napalm_unitdamage_debug then
            env.info("scanUnitsForNapalm: Napalm unit damage disabled, skipping scan")
        end
        return 
    end
    
    if splash_damage_options.napalm_unitdamage_debug then
        env.info("scanUnitsForNapalm: Starting scan at (X: " .. posX .. ", Y: " .. posY .. ", Z: " .. posZ .. ") with radius " .. splash_damage_options.napalm_unitdamage_scandistance)
    end
    
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = {x = posX, y = posY, z = posZ},
            radius = splash_damage_options.napalm_unitdamage_scandistance
        }
    }
    
    local foundUnits = {}
    local status, err = pcall(function()
        -- Scan for units
        world.searchObjects(Object.Category.UNIT, volS, function(foundObject)
            local success, result = pcall(function()
                if foundObject:isExist() and foundObject:getCategory() == Object.Category.UNIT then
                    local unitType = foundObject:getTypeName() or "Unknown"
                    -- Exclude Fuel tank
                    if unitType ~= "Fuel tank" then
                        local unitPos = foundObject:getPoint()
                        local distance = getDistance({x = posX, y = posY, z = posZ}, unitPos)
                        if distance <= splash_damage_options.napalm_unitdamage_scandistance then
                            local category = "Unknown"
                            local desc = foundObject:getDesc()
                            if desc and foundObject:hasAttribute("Infantry") then
                                category = "Infantry"
                            elseif desc and foundObject:hasAttribute("Tanks") then
                                category = "Tank"
                            elseif desc and foundObject:hasAttribute("Artillery") then
                                category = "Artillery"
                            elseif desc and foundObject:hasAttribute("Armored vehicles") then
                                category = "Armored Vehicle"
                            elseif desc and foundObject:hasAttribute("AA") then
                                category = "Anti-Air"
                            elseif desc and foundObject:hasAttribute("Helicopters") then
                                category = "Helicopter"
                            elseif desc and foundObject:hasAttribute("Planes") then
                                category = "Airplane"
                            end
                            table.insert(foundUnits, {
                                unit = foundObject,
                                id = foundObject:getID(),
                                type = unitType,
                                distance = distance,
                                category = category,
                                position = unitPos
                            })
                        end
                    end
                end
            end)
            if not success and splash_damage_options.napalm_unitdamage_debug then
                env.info("scanUnitsForNapalm: Error processing unit ID " .. (foundObject:getID() or "unknown") .. ": " .. tostring(result))
            end
            return true
        end)
        -- Scan for static objects
        world.searchObjects(Object.Category.STATIC, volS, function(foundObject)
            local success, result = pcall(function()
                if foundObject:isExist() and foundObject:getCategory() == Object.Category.STATIC then
                    local unitType = foundObject:getTypeName() or "Unknown"
                    -- Exclude Fuel tank
                    if unitType ~= "Fuel tank" then
                        local unitPos = foundObject:getPoint()
                        local distance = getDistance({x = posX, y = posY, z = posZ}, unitPos)
                        if distance <= splash_damage_options.napalm_unitdamage_scandistance then
                            table.insert(foundUnits, {
                                unit = foundObject,
                                id = foundObject:getID(),
                                type = unitType,
                                distance = distance,
                                category = "Structure",
                                position = unitPos
                            })
                        end
                    end
                end
            end)
            if not success and splash_damage_options.napalm_unitdamage_debug then
                env.info("scanUnitsForNapalm: Error processing static object ID " .. (foundObject:getID() or "unknown") .. ": " .. tostring(result))
            end
            return true
        end)
    end)
    
    if not status and splash_damage_options.napalm_unitdamage_debug then
        env.info("scanUnitsForNapalm: Error during scan: " .. tostring(err))
        return
    end
    
    table.sort(foundUnits, function(a, b) return a.distance < b.distance end)
    
    if splash_damage_options.napalm_unitdamage_debug then
        env.info("scanUnitsForNapalm: Scan completed, found " .. #foundUnits .. " objects within " .. splash_damage_options.napalm_unitdamage_scandistance .. " meters at position (X: " .. posX .. ", Y: " .. posY .. ", Z: " .. posZ .. ")")
        -- Log all found objects
        for _, unitData in ipairs(foundUnits) do
            env.info("scanUnitsForNapalm: Found object ID " .. tostring(unitData.id) .. " of type: " .. unitData.type .. ", Category: " .. unitData.category .. ", Distance: " .. string.format("%.2f", unitData.distance) .. " meters, Position: (X: " .. string.format("%.2f", unitData.position.x) .. ", Y: " .. string.format("%.2f", unitData.position.y) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ")")
        end
    end
    
    if #foundUnits > 0 then
        local processedPositions = {} -- Track processed coordinates for this scan
        local explosionIndex = 0
        for _, unitData in ipairs(foundUnits) do
            if napalm_unitcat_tabl[unitData.category] and unitData.distance <= napalm_unitcat_tabl[unitData.category].maxDamageDistance then
                -- Check if unit ID has already been processed
                if not processedUnitIds[unitData.id] then
                    -- Check for duplicate position (within 1 meter)
                    local posKey = string.format("%.0f_%.0f_%.0f", unitData.position.x, unitData.position.y, unitData.position.z)
                    if not processedPositions[posKey] then
                        -- Check if unit is still alive (for units) or exists (for statics)
                        local isAlive = unitData.unit:isExist() and (unitData.category == "Structure" or unitData.unit:getLife() > 0)
                        if isAlive then
                            processedPositions[posKey] = true
                            processedUnitIds[unitData.id] = true
                            local power = napalm_unitcat_tabl[unitData.category].explosionPower
                            -- Calculate delay
                            local delay = splash_damage_options.napalm_unitdamage_startdelay
                            if splash_damage_options.napalm_unitdamage_startdelay > 0 then
                                delay = delay + (explosionIndex * splash_damage_options.napalm_unitdamage_spreaddelay)
                                explosionIndex = explosionIndex + 1
                            end
                            -- Adjust position for infantry to reduce ground interaction
                            local explosionPos = unitData.position
                            if unitData.category == "Infantry" then
                                explosionPos = {
                                    x = unitData.position.x,
                                    y = land.getHeight({x = unitData.position.x, y = unitData.position.z}) + 1.6,
                                    z = unitData.position.z
                                }
                            end
                            if splash_damage_options.napalm_unitdamage_debug then
                                env.info("scanUnitsForNapalm: Scheduling explosion on unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", explosionPos.x) .. ", Z: " .. string.format("%.2f", explosionPos.z) .. ") with power " .. power .. " after " .. string.format("%.2f", delay) .. "s")
                            end
                            timer.scheduleFunction(function(params)
                                trigger.action.explosion(params.position, params.power)
                            end, {position = explosionPos, power = power}, timer.getTime() + delay)
                            -- Schedule cleanup for this unit ID 20 seconds after its explosion
                            timer.scheduleFunction(clearProcessedUnitIds, unitData.id, timer.getTime() + delay + 20)
                        elseif splash_damage_options.napalm_unitdamage_debug then
                            env.info("scanUnitsForNapalm: Skipped explosion for unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", unitData.position.x) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ") because unit is not alive (isExist: " .. tostring(unitData.unit:isExist()) .. ", life: " .. (unitData.category == "Structure" and "N/A" or tostring(unitData.unit:getLife())) .. ")")
                        end
                    elseif splash_damage_options.napalm_unitdamage_debug then
                        env.info("scanUnitsForNapalm: Skipped explosion for unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", unitData.position.x) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ") due to duplicate position")
                    end
                elseif splash_damage_options.napalm_unitdamage_debug then
                    env.info("scanUnitsForNapalm: Skipped explosion for unit ID " .. tostring(unitData.id) .. " (" .. unitData.type .. ") at (X: " .. string.format("%.2f", unitData.position.x) .. ", Z: " .. string.format("%.2f", unitData.position.z) .. ") due to already processed unit ID")
                end
            end
        end
    else
        if splash_damage_options.napalm_unitdamage_debug then
            env.info("scanUnitsForNapalm: No objects found in scan area")
        end
    end
end


 
function removeNapalm(staticName) 
    StaticObject.getByName(staticName):destroy()
end



local function tableHasKey(table, key)
    return table[key] ~= nil
end

  
local function gameMsg(str)
    if splash_damage_options.game_messages == true then
        trigger.action.outText(str, 5)
    end
end
  
local function getDistance(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1 - x2)
    local dZ = math.abs(z1 - z2)
    local distance = math.sqrt(dX * dX + dZ * dZ)
    return distance
end
  
local function getDistance3D(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1 - x2)
    local dY = math.abs(y1 - y2)
    local dZ = math.abs(z1 - z2)
    local distance = math.sqrt(dX * dX + dZ * dZ + dY * dY)
    return distance
end
  
local function vec3Mag(speedVec)
    return math.sqrt(speedVec.x^2 + speedVec.y^2 + speedVec.z^2)
end
  
local function lookahead(speedVec)
    local speed = vec3Mag(speedVec)
    local dist = speed * refreshRate * 1.5 
    return dist
end

function napalmOnImpact(impactPoint, velocity, weaponName)
    if not (splash_damage_options.napalmoverride_enabled or (splash_damage_options.napalm_mk77_enabled and (weaponName == "MK77mod0-WPN" or weaponName == "MK77mod1-WPN"))) then return end
    --For MK77 cluster munitions, snap impact point to ground
    local finalImpactPoint = impactPoint
    if splash_damage_options.napalm_mk77_enabled and (weaponName == "MK77mod0-WPN" or weaponName == "MK77mod1-WPN") then
        local groundHeight = land.getHeight({x = impactPoint.x, y = impactPoint.z})
                    finalImpactPoint = {
            x = impactPoint.x,
            y = groundHeight,
            z = impactPoint.z
                    }
                    if splash_damage_options.debug then
            debugMsg("Snapped MK77 " .. weaponName .. " impact to ground at X: " .. string.format("%.0f", finalImpactPoint.x) .. ", Z: " .. string.format("%.0f", finalImpactPoint.z))
        end
    else
        --For non-MK77, skip if more than 50m above ground
        local groundHeight = land.getHeight({x = impactPoint.x, y = impactPoint.z})
        if impactPoint.y - groundHeight > 50 then return end --Skip if more than 50m above ground
    end

    --Adjust spread points for MK77mod0-WPN (30% more)
    local spreadPointsCount = splash_damage_options.napalm_spread_points
    if weaponName == "MK77mod0-WPN" then
        spreadPointsCount = math.floor(spreadPointsCount * 1.3 + 0.5) --30% more, rounded
    end

    --Use horizontal velocity for MK77, full velocity for others
    local spreadVelocity = velocity
    if weaponName == "MK77mod0-WPN" or weaponName == "MK77mod1-WPN" then
        spreadVelocity = {x = velocity.x, z = velocity.z}
    end
    local spreadPoints = getSpreadPoints(finalImpactPoint, spreadVelocity, spreadPointsCount, splash_damage_options.napalm_spread_spacing)
    if splash_damage_options.debug then
        debugMsg("Generated " .. #spreadPoints .. " spread points for " .. weaponName .. " (expected " .. (splash_damage_options.napalm_doublewide_enabled and spreadPointsCount * 2 or spreadPointsCount) .. ")")
        for i, point in ipairs(spreadPoints) do
            debugMsg("Point " .. i .. ": X: " .. string.format("%.0f", point.x) .. ", Y: " .. string.format("%.0f", point.y) .. ", Z: " .. string.format("%.0f", point.z))
        end
    end
    local flamePositions = {} -- Track flame coordinates to avoid duplicates
    local function spawnAndExplode(pairIndex)
        if pairIndex > spreadPointsCount then return end
        local pointsToProcess = {}
        if splash_damage_options.napalm_doublewide_enabled then
            -- Process two points (pair) at indices 2*pairIndex-1 and 2*pairIndex
            local idx1 = 2 * pairIndex - 1
            local idx2 = 2 * pairIndex
            if idx1 <= #spreadPoints then
                table.insert(pointsToProcess, spreadPoints[idx1])
            end
            if idx2 <= #spreadPoints then
                table.insert(pointsToProcess, spreadPoints[idx2])
            end
        else
            -- Process single point at pairIndex
            if pairIndex <= #spreadPoints then
                table.insert(pointsToProcess, spreadPoints[pairIndex])
            end
        end
        for _, point in ipairs(pointsToProcess) do
        local napalmName = "napalmImpact" .. napalmCounter
        local currentCounter = napalmCounter
        napalmCounter = napalmCounter + 1
        local owngroupID = math.random(9999, 99999)
        local cvnunitID = math.random(9999, 99999)
        local _dataFuel = {
            ["groupId"] = owngroupID,
            ["category"] = "Fortifications",
            ["shape_name"] = "toplivo-bak",
            ["type"] = "Fuel tank",
            ["unitId"] = cvnunitID,
            ["rate"] = 100,
            ["y"] = point.z,
            ["x"] = point.x,
            ["name"] = napalmName,
            ["heading"] = 0,
            ["dead"] = false,
            ["hidden"] = true,
        }
        if splash_damage_options.debug then
            local staticCount = 0
            for _, coalitionId in pairs(coalition.side) do
                local statics = coalition.getStaticObjects(coalitionId)
                staticCount = staticCount + #statics
            end
            debugMsg("Spawning napalm object '" .. napalmName .. "' (Counter: " .. currentCounter .. ") at X: " .. string.format("%.0f", point.x) .. ", Y: " .. string.format("%.0f", point.y) .. ", Z: " .. string.format("%.0f", point.z) .. " (Active static objects: " .. staticCount .. ")")
        end
        local status, result = pcall(function()
            return coalition.addStaticObject(coalition.side.BLUE, _dataFuel)
        end)
        local spawnSuccess = status and result and StaticObject.getByName(napalmName) and StaticObject.getByName(napalmName):isExist()
            if not spawnSuccess then
                if splash_damage_options.debug then
                    debugMsg("Failed to spawn napalm object '" .. napalmName .. "' at X: " .. string.format("%.0f", point.x) .. ", Y: " .. string.format("%.0f", point.y) .. ", Z: " .. string.format("%.0f", point.z) .. ": " .. (status and "Object not found or does not exist" or tostring(result)))
                end
                --Fallback: Trigger explosion without static object
                --timer.scheduleFunction(explodeNapalm, point, timer.getTime() + splash_damage_options.napalm_explode_delay)
            else
                timer.scheduleFunction(explodeNapalm, point, timer.getTime() + splash_damage_options.napalm_explode_delay)
        timer.scheduleFunction(function(name)
            if splash_damage_options.debug then
                debugMsg("Destroying napalm object '" .. name .. "' at X: " .. string.format("%.0f", point.x) .. ", Z: " .. string.format("%.0f", point.z))
            end
            removeNapalm(name)
        end, napalmName, timer.getTime() + splash_damage_options.napalm_destroy_delay)
            end
            if splash_damage_options.napalm_phosphor_enabled then
            timer.scheduleFunction(napalm_phosphor, point, timer.getTime() + splash_damage_options.napalm_explode_delay)
            local status, err = pcall(function()
                scanUnitsForNapalm(point.x, point.y, point.z)
            end)
            if not status then
                env.info("napalmOnImpact: Error during unit scan for point (X: " .. point.x .. ", Y: " .. point.y .. ", Z: " .. point.z .. "): " .. tostring(err))
            end
        end
        --Add flame effect if enabled
        if splash_damage_options.napalm_addflame then
            local flameSize = splash_damage_options.napalm_addflame_size
            local flameDuration = splash_damage_options.napalm_addflame_duration
            local flameDensity = 1.0
            local effectId = effectSmokeId
            effectSmokeId = effectSmokeId + 1
            local isDuplicate = false
            for _, pos in pairs(flamePositions) do
                if getDistance3D(point, pos) < 3 then
                    isDuplicate = true
                    if splash_damage_options.debug then
                        debugMsg("Skipping duplicate flame for napalm object '" .. napalmName .. "' near X: " .. string.format("%.0f", pos.x) .. ", Z: " .. string.format("%.0f", pos.z))
                    end
                    break
                end
            end
            if not isDuplicate then
                if splash_damage_options.debug then
                    debugMsg("Adding flame effect for napalm object '" .. napalmName .. "' at X: " .. string.format("%.0f", point.x) .. ", Z: " .. string.format("%.0f", point.z) .. " (Size: " .. flameSize .. ", Duration: " .. flameDuration .. "s, ID: " .. effectId .. ")")
                end
                timer.scheduleFunction(function(params)
                    local terrainHeight = land.getHeight({x = params[1].x, y = params[1].z})
                    local adjustedCoords = {x = params[1].x, y = terrainHeight + 2, z = params[1].z}
                    trigger.action.effectSmokeBig(adjustedCoords, params[2], params[3], params[4])
                end, {point, flameSize, flameDensity, effectId}, timer.getTime() + splash_damage_options.napalm_flame_delay)
                timer.scheduleFunction(function(id)
                    if splash_damage_options.debug then
                        debugMsg("Stopping flame effect for napalm object (ID: " .. id .. ")")
                    end
                    trigger.action.effectSmokeStop(id)
                end, effectId, timer.getTime() + splash_damage_options.napalm_flame_delay + flameDuration)
                table.insert(flamePositions, point)
            end
        end
        end
        timer.scheduleFunction(spawnAndExplode, pairIndex + 1, timer.getTime() + 0.2)
    end
    spawnAndExplode(1)
end

 
 
 
 
 
--Cluster-specific helper functions from Rockeye script
local function normalizeVector(vec)
    local mag = math.sqrt(vec.x^2 + vec.z^2)
    if mag > 0 then
        return { x = vec.x / mag, z = vec.z / mag }
    else
        return { x = 1, z = 0 }
    end
end
local function calculate_drop_angle(velocity)
    local horizontal_speed = math.sqrt((velocity.x or 0)^2 + (velocity.z or 0)^2)
    local vertical_speed = math.abs(velocity.y or 0)
    if horizontal_speed == 0 then return 90 end
    local angle_rad = math.atan(vertical_speed / horizontal_speed)
    return math.deg(angle_rad)
end
local function calculate_dispersion(velocity, burst_altitude)
    local velocity_magnitude = math.sqrt((velocity.x or 0)^2 + (velocity.z or 0)^2)
    local drop_angle = calculate_drop_angle(velocity)
    local length = splash_damage_options.cluster_base_length * (1 + velocity_magnitude / 200)
    local width = splash_damage_options.cluster_base_width * (1 + burst_altitude / 6000)
    local length_jitter = length * (0.85 + math.random() * 0.3)
    local width_jitter = width * (0.85 + math.random() * 0.3)
    return math.max(splash_damage_options.cluster_min_length, math.min(splash_damage_options.cluster_max_length, length_jitter)),
           math.max(splash_damage_options.cluster_min_width, math.min(splash_damage_options.cluster_max_width, width_jitter))
end

local function protectedCall(...)
    local status, retval = pcall(...)
    if not status then
        env.warning("Splash damage script error... gracefully caught! " .. retval, true)
    end
end

--[[
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-=-
    ##### End of HELPER/UTILITY FUNCTIONS #####     ##### End of HELPER/UTILITY FUNCTIONS #####     ##### End of HELPER/UTILITY FUNCTIONS #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]
giantExplosionTargets = {}
giantExplosionTestTargets = {}
cargoEffectsQueue = {}
WpnHandler = {}
tracked_target_position = nil --Store the last known position of TargetUnit for giant explosion
tracked_weapons = {}
local processedUnitsGlobal = {}
napalmCounter = 1
napalmCounter = 1

function scanGiantExplosionTargets()
local function processObject(obj)
        if obj:isExist() then
            local name = obj:getName()
            if string.find(name, "GiantExplosionTarget") then
                local pos = obj:getPoint()
                local targetData = {
                    name = name,
                    obj = obj,
                    pos = pos,
                    static = splash_damage_options.giant_explosion_target_static,
                    initialHealth = obj:getLife() or 0
                }
                table.insert(giantExplosionTargets, targetData)
                if splash_damage_options.giantexplosion_testmode then
                    table.insert(giantExplosionTestTargets, {name = name, pos = pos})
                end
                debugMsg("Found GiantExplosion unit: " .. name .. " at X:" .. pos.x .. " Y:" .. pos.y .. " Z:" .. pos.z)
            end
        end
    end
    --Iterate over all coalitions
    for coa = 0, 2 do
        --Process units
        local groups = coalition.getGroups(coa)
        if groups then
            for _, group in pairs(groups) do
                local units = group:getUnits()
                if units then
                    for _, unit in pairs(units) do
                        processObject(unit)
                    end
                end
            end
        end
        --Process static objects
        local statics = coalition.getStaticObjects(coa)
        if statics then
            for _, static in pairs(statics) do
                processObject(static)
            end
        end
    end
    debugMsg("Total GiantExplosion units found: " .. #giantExplosionTargets)
    if #giantExplosionTargets > 0 then
        timer.scheduleFunction(checkGiantExplosionUnits, {}, timer.getTime() + splash_damage_options.giant_explosion_poll_rate)
    end
end

function updateGiantExplosionPositions()
    for _, target in ipairs(giantExplosionTargets) do
        if target.obj:isExist() then
            target.pos = target.obj:getPoint()
        end
    end
    return timer.getTime() + 1.0
end

function checkGiantExplosionUnits()
    if not splash_damage_options.giant_explosion_enabled then
        debugMsg("Giant Explosion is disabled in options.")
        return
    end

    local targetsToRemove = {}
    for i, target in ipairs(giantExplosionTargets) do
        local triggerExplosion = false
        local currentPos = target.pos

        if target.obj:isExist() then
            if not target.static then
                currentPos = target.obj:getPoint()
                target.pos = currentPos
            end
            if splash_damage_options.giantexplosion_ondamage then
                local currentHealth = target.obj:getLife() or 0
                if currentHealth < target.initialHealth then
                    triggerExplosion = true
                    debugMsg("Triggering explosion for " .. target.name .. " due to damage (Health: " .. currentHealth .. "/" .. target.initialHealth .. ")")
                end
            end
        else
            if splash_damage_options.giantexplosion_ondeath then
                triggerExplosion = true
                debugMsg("Triggering explosion for " .. target.name .. " due to destruction")
            end
        end

        if triggerExplosion then
            triggerGiantExplosion({
                pos = currentPos,
                power = splash_damage_options.giant_explosion_power,
                scale = splash_damage_options.giant_explosion_scale,
                duration = splash_damage_options.giant_explosion_duration,
                count = splash_damage_options.giant_explosion_count
            })
            table.insert(targetsToRemove, i)
        end
    end

    --Remove triggered targets in reverse order to avoid index issues
    for i = #targetsToRemove, 1, -1 do
        table.remove(giantExplosionTargets, targetsToRemove[i])
        debugMsg("Removed " .. targetsToRemove[i] .. " from giantExplosionTargets. Remaining: " .. #giantExplosionTargets)
    end

    --Continue scheduling checks if there are still targets
    if #giantExplosionTargets > 0 then
        return timer.getTime() + splash_damage_options.giant_explosion_poll_rate
    else
        debugMsg("No GiantExplosion units remaining. Disabling periodic checks.")
    end
end


--Giant Explosion Function
function triggerGiantExplosion(params)
    if not splash_damage_options.giant_explosion_enabled then
        debugMsg("Giant Explosion is disabled in options.")
        return
    end

    local initialPos = params.pos or {x = 0, y = 0, z = 0}
    local explosionPower = params.power or splash_damage_options.giant_explosion_power
    local sizeScale = params.scale or splash_damage_options.giant_explosion_scale
    local totalDuration = params.duration or splash_damage_options.giant_explosion_duration
    local explosionCount = params.count or splash_damage_options.giant_explosion_count

    if not initialPos.x or not initialPos.y or not initialPos.z then
        gameMsg("Error: Invalid position for giant explosion!")
        debugMsg("No valid initial position set for giant explosion!")
        return
    end

    debugMsg("Triggering giant fireball at X: " .. initialPos.x .. ", Y: " .. initialPos.y .. ", Z: " .. initialPos.z)

    local function scheduleExplosion(pos, delay)
        if not pos or not pos.x or not pos.y or not pos.z then
            debugMsg("Error: Invalid position for explosion - pos: " .. tostring(pos))
            return
        end
        timer.scheduleFunction(function(p)
            if p and p.x and p.y and p.z then
                trigger.action.explosion(p, explosionPower)
            end
        end, pos, timer.getTime() + delay)
    end

    --Pre-explosion scan for cargo units
    local scanRadius = 1500 * sizeScale --1500m base radius, scaled by sizeScale
    local preExplosionTargets = {}
    if splash_damage_options.enable_cargo_effects then
        local volS = {
            id = world.VolumeType.SPHERE,
            params = { point = initialPos, radius = scanRadius }
        }
        local ifFound = function(foundObject)
            if foundObject:isExist() then
                local category = foundObject:getCategory()
                if (category == Object.Category.UNIT and foundObject:getDesc().category == Unit.Category.GROUND_UNIT) or
                   category == Object.Category.STATIC then
                    table.insert(preExplosionTargets, {
                        name = foundObject:getTypeName(),
                        health = foundObject:getLife() or 0,
                        position = foundObject:getPoint(),
                        maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0,
                        unit = foundObject
                    })
                end
            end
            return true
        end
        world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, ifFound)
        debugMsg("Pre-explosion scan for Giant Explosion: " .. #preExplosionTargets .. " targets found within " .. scanRadius .. "m")
    end
    --Trigger the explosion
    local maxRadius = 200 * sizeScale
    local maxHeight = 500 * sizeScale
    local adjustedExplosionCount = math.floor(explosionCount * (sizeScale ^ 2.5))
    local stepTime = totalDuration / adjustedExplosionCount
    local variance = 0.25 --Fixed at 25%

    for i = 1, adjustedExplosionCount do
        local progress = i / adjustedExplosionCount
        local currentRadius = maxRadius * progress
        local r = currentRadius * (0.9 + math.random() * 0.1)
        local theta = math.random() * 2 * math.pi
        local phi = math.acos(math.random())

        local offsetX = r * math.sin(phi) * math.cos(theta)
        local offsetZ = r * math.sin(phi) * math.sin(theta)
        local offsetY = r * math.cos(phi)

        offsetX = offsetX * (1 + (math.random() - 0.5) * variance)
        offsetZ = offsetZ * (1 + (math.random() - 0.5) * variance)
        offsetY = offsetY * (1 + (math.random() - 0.5) * variance * 0.5)

        local blastPos = {
            x = initialPos.x + offsetX,
            y = land.getHeight({x = initialPos.x, y = initialPos.z}) + offsetY,
            z = initialPos.z + offsetZ
        }
        if blastPos.y < land.getHeight({x = blastPos.x, y = blastPos.z}) then
            blastPos.y = land.getHeight({x = blastPos.x, y = blastPos.z})
        end

        local delay = (i - 1) * stepTime + (math.random() - 0.5) * stepTime * variance
        scheduleExplosion(blastPos, delay)
    end

    gameMsg("Expanding giant fireball over " .. totalDuration .. "s (scale " .. sizeScale .. ")!")

    --Post-explosion scan and cargo cook-off queuing
    if splash_damage_options.enable_cargo_effects then
        timer.scheduleFunction(function(args)
            local centerPos = args[1]
            local radius = args[2]
            local preTargets = args[3]

            local postExplosionTargets = {}
            local volS = {
                id = world.VolumeType.SPHERE,
                params = { point = centerPos, radius = radius }
            }
            local ifFound = function(foundObject)
                if foundObject:isExist() then
                    local category = foundObject:getCategory()
                    if (category == Object.Category.UNIT and foundObject:getDesc().category == Unit.Category.GROUND_UNIT) or
                       category == Object.Category.STATIC then
                        table.insert(postExplosionTargets, {
                            name = foundObject:getTypeName(),
                            health = foundObject:getLife() or 0,
                            position = foundObject:getPoint(),
                            maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0
                        })
                    end
                end
                return true
            end
            world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, ifFound)
            debugMsg("Post-explosion scan for Giant Explosion: " .. #postExplosionTargets .. " targets found within " .. radius .. "m")

            --Compare pre- and post-explosion targets
            for _, preTarget in ipairs(preTargets) do
                local found = false
                local postHealth = 0
                for _, postTarget in ipairs(postExplosionTargets) do
                    if preTarget.name == postTarget.name and getDistance(preTarget.position, postTarget.position) < 1 then
                        found = true
                        postHealth = postTarget.health
                        break
                    end
                end

                local cargoData = cargoUnits[preTarget.name]
                if cargoData and (not found or postHealth <= 0) then
                    local distance = getDistance(initialPos, preTarget.position)
                    if distance <= radius then
                        local cargoPower = cargoData.cargoExplosionPower or explosionPower
                        table.insert(cargoEffectsQueue, {
                            name = preTarget.name,
                            distance = distance,
                            coords = preTarget.position,
                            power = cargoPower,
                            explosion = cargoData.cargoExplosion,
                            cookOff = cargoData.cargoCookOff,
                            cookOffCount = cargoData.cookOffCount,
                            cookOffPower = cargoData.cookOffPower,
                            cookOffDuration = cargoData.cookOffDuration,
                            cookOffRandomTiming = cargoData.cookOffRandomTiming,
                            cookOffPowerRandom = cargoData.cookOffPowerRandom,
                            isTanker = cargoData.isTanker,
                            flameSize = cargoData.flameSize,
                            flameDuration = cargoData.flameDuration
                        })
                        debugMsg("Queued cargo effect for " .. preTarget.name .. " destroyed by Giant Explosion at " .. string.format("%.1f", distance) .. "m")
                    end
                end
            end

            --Process queued cargo effects with prioritized flames
            if #cargoEffectsQueue > 0 then
                local flameIndex = 0 --Separate index for flames
                local otherIndex = 0 --Index for explosions, cook-offs, debris
                local processedCargoUnits = {}
                local flamePositions = {}
                for _, effect in ipairs(cargoEffectsQueue) do
                    local unitKey = effect.name .. "_" .. effect.coords.x .. "_" .. effect.coords.z
                    if not processedUnitsGlobal[unitKey] and not processedCargoUnits[unitKey] then
                        --Handle tanker flames first with minimal delay
                        if effect.isTanker and effect.explosion then
                            debugMsg("Triggering cargo explosion for tanker " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m with power " .. effect.power .. " scheduled at " .. flameIndex .. "s")
                            timer.scheduleFunction(function(params)
                                debugMsg("Executing cargo explosion at X: " .. string.format("%.0f", params[1].x) .. ", Y: " .. string.format("%.0f", params[1].y) .. ", Z: " .. string.format("%.0f", params[1].z) .. " with power " .. params[2])
                                trigger.action.explosion(params[1], params[2])
                            end, {effect.coords, effect.power}, timer.getTime() + flameIndex + 0.1)

                            local flameSize = effect.flameSize or 3
                            local flameDuration = effect.flameDuration
                            local flameDensity = 1.0
                            local effectId = effectSmokeId
                            effectSmokeId = effectSmokeId + 1
                            local isDuplicate = false
                            for _, pos in pairs(flamePositions) do
                                if getDistance3D(effect.coords, pos) < 3 then
                                    isDuplicate = true
                                    debugMsg("Skipping duplicate flame for " .. effect.name .. " near X: " .. string.format("%.0f", pos.x) .. ", Y: " .. string.format("%.0f", pos.y) .. ", Z: " .. string.format("%.0f", pos.z))
                                    break
                                end
                            end
                            if not isDuplicate then
                                debugMsg("Adding flame effect for tanker " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m (Size: " .. flameSize .. ", Duration: " .. flameDuration .. "s, ID: " .. effectId .. ") scheduled at " .. flameIndex .. "s")
                                timer.scheduleFunction(function(params)
                                    local terrainHeight = land.getHeight({x = params[1].x, y = params[1].z})
                                    local adjustedCoords = {x = params[1].x, y = terrainHeight + 2, z = params[1].z}
                                    debugMsg("Spawning flame effect at X: " .. string.format("%.0f", adjustedCoords.x) .. ", Y: " .. string.format("%.0f", adjustedCoords.y) .. ", Z: " .. string.format("%.0f", adjustedCoords.z))
                                    trigger.action.explosion(adjustedCoords, 10) --Small trigger explosion
                                    trigger.action.effectSmokeBig(adjustedCoords, params[2], params[3], params[4])
                                end, {effect.coords, flameSize, flameDensity, effectId}, timer.getTime() + flameIndex + 0.2)
                                timer.scheduleFunction(function(id)
                                    debugMsg("Stopping flame effect for " .. effect.name .. " (ID: " .. id .. ")")
                                    trigger.action.effectSmokeStop(id)
                                end, effectId, timer.getTime() + flameIndex + flameDuration + 0.2)
                                table.insert(flamePositions, effect.coords)
                            end
                            flameIndex = flameIndex + 0.5 --Fast spacing for flames (0.5s)
                        end
                        --Handle non-tanker explosions, cook-offs, and debris
                        if not effect.isTanker or (effect.explosion and not effect.isTanker) then
                            if effect.explosion then
                                debugMsg("Triggering cargo explosion for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m with power " .. effect.power .. " scheduled at " .. otherIndex .. "s")
                                timer.scheduleFunction(function(params)
                                    debugMsg("Executing cargo explosion at X: " .. string.format("%.0f", params[1].x) .. ", Y: " .. string.format("%.0f", params[1].y) .. ", Z: " .. string.format("%.0f", params[1].z) .. " with power " .. params[2])
                                    trigger.action.explosion(params[1], params[2])
                                end, {effect.coords, effect.power}, timer.getTime() + otherIndex + 0.1)
                            end
                            if effect.cookOff and effect.cookOffCount > 0 then
                                debugMsg("Scheduling " .. effect.cookOffCount .. " cook-off explosions for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m over " .. effect.cookOffDuration .. "s starting at " .. otherIndex .. "s")
                                for i = 1, effect.cookOffCount do
                                    local delay = effect.cookOffRandomTiming and math.random() * effect.cookOffDuration or (i - 1) * (effect.cookOffDuration / effect.cookOffCount)
                                    local basePower = effect.cookOffPower
                                    local powerVariation = effect.cookOffPowerRandom / 100
                                    local cookOffPower = effect.cookOffPowerRandom == 0 and basePower or basePower * (1 + powerVariation * (math.random() * 2 - 1))
                                    debugMsg("Cook-off #" .. i .. " for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m scheduled at " .. string.format("%.3f", delay) .. "s with power " .. string.format("%.2f", cookOffPower))
                                    timer.scheduleFunction(function(params)
                                        debugMsg("Executing cook-off at X: " .. string.format("%.0f", params[1].x) .. ", Y: " .. string.format("%.0f", params[1].y) .. ", Z: " .. string.format("%.0f", params[1].z) .. " with power " .. params[2])
                                        trigger.action.explosion(params[1], params[2])
                                    end, {effect.coords, cookOffPower}, timer.getTime() + otherIndex + delay)
                                end
                                if splash_damage_options.debris_effects then
                                    local debrisCount = math.random(splash_damage_options.debris_count_min, splash_damage_options.debris_count_max)
                                    for j = 1, debrisCount do
                                        local theta = math.random() * 2 * math.pi
                                        local phi = math.acos(math.random() * 2 - 1)
                                        local minDist = splash_damage_options.debris_max_distance * 0.1
                                        local maxDist = splash_damage_options.debris_max_distance
                                        local r = math.random() * (maxDist - minDist) + minDist
                                        local debrisX = effect.coords.x + r * math.sin(phi) * math.cos(theta)
                                        local debrisZ = effect.coords.z + r * math.sin(phi) * math.sin(theta)
                                        local terrainY = land.getHeight({x = debrisX, y = debrisZ})
                                        local debrisY = terrainY + math.random() * maxDist
                                        local debrisPos = {x = debrisX, y = debrisY, z = debrisZ}
                                        local debrisPower = splash_damage_options.debris_power
                                        local debrisDelay = (j - 1) * (effect.cookOffDuration / debrisCount)
                                        timer.scheduleFunction(function(debrisArgs)
                                            debugMsg("Debris explosion at X: " .. string.format("%.0f", debrisArgs[1].x) .. ", Y: " .. string.format("%.0f", debrisArgs[1].y) .. ", Z: " .. string.format("%.0f", debrisArgs[1].z) .. " with power " .. debrisArgs[2])
                                            trigger.action.explosion(debrisArgs[1], debrisArgs[2])
                                        end, {debrisPos, debrisPower}, timer.getTime() + otherIndex + debrisDelay)
                                    end
                                end
                            end
                            otherIndex = otherIndex + 1 --Slower spacing for non-flame effects (1s)
                        end
                        processedCargoUnits[unitKey] = true
                        processedUnitsGlobal[unitKey] = true
                    end
                end
                cargoEffectsQueue = {} --Clear the queue after processing
            end
        end, {initialPos, scanRadius, preExplosionTargets}, timer.getTime() + totalDuration + 1.0)
    end
end



function getWeaponExplosive(name)
    local weaponData = explTable[name]
    if weaponData then
        return weaponData.explosive, weaponData.shaped_charge
    else
        return 0, false
    end
end
  
function track_wpns_cluster_scan(args)
    local parentPos = args[1]
    local parentDir = args[2]
    local parentName = args[3]
    local subName = args[4]
    local subCount = args[5]
    local subPower = args[6]
    local parentVel = args[7]
    local attempt = args[8] or 1
    local maxAttempts = 3
    local scanVol = {
        id = world.VolumeType.SPHERE,
        params = { point = parentPos, radius = 400 }
    }
    local bombletsFound = {}
    local allWeaponsFound = {}
    --General scan for all weapons
    world.searchObjects(Object.Category.WEAPON, scanVol, function(wpn)
        if wpn:isExist() then
            local wpnId = wpn.id_
            local wpnType = wpn:getTypeName()
            local wpnPos = wpn:getPosition().p
            table.insert(allWeaponsFound, { id = wpnId, type = wpnType, x = wpnPos.x, y = wpnPos.y, z = wpnPos.z })
            if wpnType == subName and not tracked_weapons[wpnId] then
                tracked_weapons[wpnId] = {
                    wpn = wpn,
                    pos = wpnPos,
                    speed = wpn:getVelocity(),
                    name = wpnType,
                    parent = parentName,
                    parentVelocity = parentVel
                }
                table.insert(bombletsFound, wpnId)
                debugMsg("Detected expected submunition '" .. wpnType .. "' from '" .. parentName .. "' at X: " .. string.format("%.0f", wpnPos.x) .. ", Y: " .. string.format("%.0f", wpnPos.y) .. ", Z: " .. string.format("%.0f", wpnPos.z) .. " (Attempt " .. attempt .. ")")
            end
        end
        return true
    end)
    --Log results
    debugMsg("Scanned for submunition '" .. subName .. "' bomblets from '" .. parentName .. "': " .. #bombletsFound .. " found (Attempt " .. attempt .. ")")
    if #allWeaponsFound > 0 then
        local msg = "General scan for '" .. parentName .. "': " .. #allWeaponsFound .. " bomblets released, expected " .. subCount .. " '" .. subName .. "'"
        local typeMismatch = false
        for _, wpn in ipairs(allWeaponsFound) do
            if wpn.type ~= subName then
                typeMismatch = true
                break
            end
        end
        if typeMismatch then
            msg = msg .. " - Mismatch detected! Actual bomblets: "
            for _, wpn in ipairs(allWeaponsFound) do
                msg = msg .. "'" .. wpn.type .. "' (X: " .. string.format("%.0f", wpn.x) .. ", Y: " .. string.format("%.0f", wpn.y) .. ", Z: " .. string.format("%.0f", wpn.z) .. ") "
            end
            msg = msg .. "Script may need changing."
        end
        debugMsg(msg)
    elseif #bombletsFound == 0 and #allWeaponsFound == 0 then
        debugMsg("No bomblets of any type detected for '" .. parentName .. "' (Attempt " .. attempt .. ")")
    end
    --Retry if no expected submunitions found
    if #bombletsFound == 0 and attempt < maxAttempts then
        debugMsg("No expected submunition '" .. subName .. "' found on attempt " .. attempt .. ", retrying in 0.5s")
        timer.scheduleFunction(track_wpns_cluster_scan, {parentPos, parentDir, parentName, subName, subCount, subPower, parentVel, attempt + 1}, timer.getTime() + 0.5)
    elseif #bombletsFound == 0 and attempt == maxAttempts then
        debugMsg("No submunition '" .. subName .. "' spawned by DCS for '" .. parentName .. "' after " .. maxAttempts .. " attempts - skipping additional explosions")
    end
end

----[[ ##### Updated track_wpns() Function ##### ]]----
local recentExplosions = {}


--function to schedule flares for cook-offs
function scheduleCookOffFlares(coords, cookOffCount, cookOffDuration, flareColor)
    local flareCount = math.floor(cookOffCount * splash_damage_options.cookoff_flare_count_modifier)
    if flareCount < 1 then return end --Skip if no flares
    debugMsg("Scheduling " .. flareCount .. " flares for cook-off at X: " .. string.format("%.0f", coords.x) .. ", Z: " .. string.format("%.0f", coords.z) .. " over " .. cookOffDuration .. "s")
    for i = 1, flareCount do
        local delay = math.random() * cookOffDuration --Random time within cook-off duration
        local terrainHeight = land.getHeight({x = coords.x, y = coords.z})
        local offset = {
            x = coords.x + math.random(-splash_damage_options.cookoff_flare_offset, splash_damage_options.cookoff_flare_offset),
            y = terrainHeight, --Start at ground level
            z = coords.z + math.random(-splash_damage_options.cookoff_flare_offset, splash_damage_options.cookoff_flare_offset)
        }
        local azimuth = math.random(1, 360) --Random direction
        timer.scheduleFunction(function(params)
            debugMsg("Spawning flare #" .. params[1] .. " at X: " .. string.format("%.0f", params[2].x) .. ", Y: " .. string.format("%.0f", params[2].y) .. ", Z: " .. string.format("%.0f", params[2].z) .. " with color " .. params[3])
            trigger.action.signalFlare(params[2], params[3], params[4])
        end, {i, offset, flareColor, azimuth}, timer.getTime() + delay)
    end
end


function track_wpns()
    local weaponsToRemove = {} --Delay removal to ensure all weapons are checked
    for wpn_id_, wpnData in pairs(tracked_weapons) do   
        local status, err = pcall(function()
        if wpnData.wpn:isExist() then
            --Update position, direction, speed
            wpnData.pos = wpnData.wpn:getPosition().p
            wpnData.dir = wpnData.wpn:getPosition().x
            wpnData.speed = wpnData.wpn:getVelocity()
                --[[
				
		
            --Tick-by-tick tracking from weapon's actual position
	local tickVol = {
    id = world.VolumeType.SPHERE,
    params = {
                    point = wpnData.pos, --Real weapon position
                    radius = 150 --150m radius
    }
}
local tickTargets = {}
world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, tickVol, function(obj)
    if obj:isExist() then
        table.insert(tickTargets, {
            name = obj:getTypeName(),
                        distance = getDistance3D(wpnData.pos, obj:getPoint()), --3D distance
            position = obj:getPoint(),
            health = obj:getLife() or 0
        })
                end
                return true
            end)
            debugMsg("Tick Track for " .. wpnData.name .. " at X: " .. string.format("%.0f", wpnData.pos.x) .. ", Y: " .. string.format("%.0f", wpnData.pos.y) .. ", Z: " .. string.format("%.0f", wpnData.pos.z) .. " - " .. #tickTargets .. " targets")
            for i, target in ipairs(tickTargets) do
                debugMsg("Tick Target #" .. i .. ": " .. target.name .. " at X: " .. string.format("%.0f", target.position.x) .. ", Y: " .. string.format("%.0f", target.position.y) .. ", Z: " .. string.format("%.0f", target.position.z) .. ", Dist: " .. string.format("%.1f", target.distance) .. "m, Health: " .. target.health)
            end
   
				
				]]--

            --Scan potential blast zone in the last frame before impact
            if splash_damage_options.track_pre_explosion then
                local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed))
                local predictedImpact = ip or wpnData.pos

                local base_explosive, isShapedCharge = getWeaponExplosive(wpnData.name)
                base_explosive = base_explosive * splash_damage_options.overall_scaling
                if splash_damage_options.rocket_multiplier and wpnData.cat == Weapon.Category.ROCKET then
                    base_explosive = base_explosive * splash_damage_options.rocket_multiplier
                end
                    if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance then
                        base_explosive = base_explosive * splash_damage_options.groundunitordnance_damage_modifier
                    --Log modifier only once per weapon
                    --if splash_damage_options.track_groundunitordnance_debug and not wpnData.debugLogged then
                        --debugMsg("Applying ground unit ordnance damage modifier " .. splash_damage_options.groundunitordnance_damage_modifier .. " to " .. wpnData.name .. ", base explosive power: " .. base_explosive)
                       --wpnData.debugLogged = true --Mark as logged
                    --end
                end

                local explosionPower = base_explosive
                if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                    explosionPower = explosionPower * splash_damage_options.shaped_charge_multiplier
                end

                    local blastRadius = splash_damage_options.blast_search_radius * 2 --Wider post-scan (180m default)
                if splash_damage_options.use_dynamic_blast_radius then
                    blastRadius = math.pow(explosionPower, 1/3) * 10 * splash_damage_options.dynamic_blast_radius_modifier 
                end

                    --Set tightRadius, use 50m for ground ordnance if enabled
                    local tightRadius = blastRadius
                    if wpnData.isGroundUnitOrdnance and splash_damage_options.scan_50m_for_groundordnance then
                        tightRadius = 50 --Fixed 50m radius for ground ordnance
                        if splash_damage_options.track_groundunitordnance_debug then
                            debugMsg("Using 50m scan radius for ground ordnance " .. wpnData.name)
                        end
                    end
                local volS = {
                    id = world.VolumeType.SPHERE,
                    params = { 
                        point = wpnData.pos, --Use current pos
                        radius = tightRadius 
                    }
                }
                local tightTargets = {}
                local ifFound = function(foundObject, targets, center)
                    if foundObject:isExist() then
                        local category = foundObject:getCategory()
                        if (category == Object.Category.UNIT and (foundObject:getDesc().category == Unit.Category.GROUND_UNIT or foundObject:getDesc().category == Unit.Category.AIRPLANE)) or
                               category == Object.Category.STATIC then
                                table.insert(targets, {
                                    name = foundObject:getTypeName(),
                                    distance = getDistance(center, foundObject:getPoint()),
                                    health = foundObject:getLife() or 0,
                                    position = foundObject:getPoint(),
                                    maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0,
                                    unit = foundObject,
                                    id = foundObject:getID(),
                                    unitName = foundObject:getName() or "Unknown"
                                })
                        end
                    end
                    return true
                end
                    if splash_damage_options.track_pre_explosion_debug then
                debugMsg("Scanning tight radius " .. tightRadius .. "m at current pos while weapon exists")
                    end
                world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, function(obj) ifFound(obj, tightTargets, wpnData.pos) end)
                wpnData.tightTargets = tightTargets --Store for impact

                --Wider scan for lastKnownTargets
                volS.params.point = predictedImpact
                volS.params.radius = blastRadius
                local foundTargets = {}
                world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, function(obj) ifFound(obj, foundTargets, predictedImpact) end)
                wpnData.lastKnownTargets = foundTargets
            end
                --Submunition impact handling
                local weaponData = explTable[wpnData.parent or wpnData.name] or { submunition_name = "unknown" }
                if wpnData.name == weaponData.submunition_name then
                    local groundHeight = land.getHeight({x = wpnData.pos.x, y = wpnData.pos.z})
                    if wpnData.pos.y - groundHeight < 50 then --Impact threshold like old script
                        debugMsg("Submunition '" .. wpnData.name .. "' from '" .. (wpnData.parent or "unknown") .. "' impacted at X: " .. string.format("%.0f", wpnData.pos.x) .. ", Z: " .. string.format("%.0f", wpnData.pos.z))
                        local parentWeaponData = explTable[wpnData.parent] or { submunition_count = 30, submunition_explosive = 1 }
                        local submunitionCount = parentWeaponData.submunition_count or 30
                        local submunitionPower = (parentWeaponData.submunition_explosive or 1) * splash_damage_options.cluster_bomblet_damage_modifier * splash_damage_options.overall_scaling
						if splash_damage_options.cluster_bomblet_reductionmodifier then
							if submunitionCount > 35 then
                                local reductionFactor = (60 - 35) / (247 - 35)
								submunitionCount = 35 + math.floor((submunitionCount - 35) * reductionFactor)
                                if submunitionCount > 60 then submunitionCount = 60 end
							end
						end
        --Use parent velocity if available, else submunition speed
        local parentDir = wpnData.parentVelocity or wpnData.speed
        local dispersionLength, dispersionWidth = calculate_dispersion(parentDir, 2000) --Match original 2000m
        local dirMag = math.sqrt(parentDir.x^2 + parentDir.z^2)
        local dir = dirMag > 0 and {x = parentDir.x / dirMag, z = parentDir.z / dirMag} or {x = 1, z = 0}
                        debugMsg("Simulating " .. submunitionCount .. " bomblets for submunition '" .. wpnData.name .. "' from '" .. (wpnData.parent or "unknown") .. "' over " .. string.format("%.0f", dispersionLength) .. "m x " .. string.format("%.0f", dispersionWidth) .. "m")
                        for i = 1, submunitionCount do
                            local theta = math.random() * 2 * math.pi
                            local r = math.sqrt(math.random())
                            local xOffset = r * dispersionLength * 0.5 * math.cos(theta)
                            local zOffset = r * dispersionWidth * 0.5 * math.sin(theta)
                            local subPos = {
                                x = wpnData.pos.x + (xOffset * dir.x - zOffset * dir.z),
                                z = wpnData.pos.z + (xOffset * dir.z + zOffset * dir.x)
                            }
                            subPos.y = land.getHeight({x = subPos.x, y = subPos.z})
                            debugMsg("Triggering bomblet #" .. i .. " for submunition '" .. wpnData.name .. "' at X: " .. string.format("%.0f", subPos.x) .. ", Z: " .. string.format("%.0f", subPos.z) .. " with power " .. submunitionPower)
                            trigger.action.explosion(subPos, submunitionPower)
                        end
                        table.insert(weaponsToRemove, wpn_id_)
                    end
                end
            else
            --Weapon has impacted
            debugMsg("Weapon " .. wpnData.name .. " no longer exists at " .. timer.getTime() .. "s")
            local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed))  --terrain intersection point with weapon's nose
            local explosionPoint
            if not ip then --use last calculated IP
                explosionPoint = wpnData.pos
            else --use intersection point
                explosionPoint = ip
            end
            if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance_debug then
                local base_explosive, isShapedCharge = getWeaponExplosive(wpnData.name)
                base_explosive = base_explosive * splash_damage_options.overall_scaling
                if splash_damage_options.rocket_multiplier and wpnData.cat == Weapon.Category.ROCKET then
                    base_explosive = base_explosive * splash_damage_options.rocket_multiplier
                end
                if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance then
                    base_explosive = base_explosive * splash_damage_options.groundunitordnance_damage_modifier
                end
                local explosionPower = base_explosive
                if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                    explosionPower = explosionPower * splash_damage_options.shaped_charge_multiplier
                end
                debugMsg("Ground unit ordnance " .. wpnData.name .. " impacted at X: " .. string.format("%.0f", explosionPoint.x) .. ", Y: " .. string.format("%.0f", explosionPoint.y) .. ", Z: " .. string.format("%.0f", explosionPoint.z) .. " with power " .. explosionPower)
            end
			local chosenTargets = wpnData.tightTargets or {}
            local safeToBlast = true
            --Check if weapon is napalm
            local isNapalm = false
				--Check for napalm override weapons
				if splash_damage_options.napalmoverride_enabled then
					local napalmWeapons = {}
					for weapon in splash_damage_options.napalm_override_weapons:gmatch("[^,]+") do
						napalmWeapons[trim(weapon)] = true
					end
					if napalmWeapons[wpnData.name] then
						isNapalm = true
						debugMsg("Napalm override triggered for " .. wpnData.name .. " at X: " .. string.format("%.0f", explosionPoint.x) .. ", Z: " .. string.format("%.0f", explosionPoint.z))
						napalmOnImpact(explosionPoint, wpnData.speed, wpnData.name)
						table.insert(weaponsToRemove, wpn_id_)
					end
				end

				--Check for MK77 weapons independently
				if splash_damage_options.napalm_mk77_enabled and (wpnData.name == "MK77mod0-WPN" or wpnData.name == "MK77mod1-WPN") then
					isNapalm = true
					debugMsg("MK77 napalm triggered for " .. wpnData.name .. " at X: " .. string.format("%.0f", explosionPoint.x) .. ", Z: " .. string.format("%.0f", explosionPoint.z))
					napalmOnImpact(explosionPoint, wpnData.speed, wpnData.name)
					table.insert(weaponsToRemove, wpn_id_)
				end
            if not isNapalm then
			if splash_damage_options.ordnance_protection then
                local checkVol = { id = world.VolumeType.SPHERE, params = { point = explosionPoint, radius = splash_damage_options.ordnance_protection_radius } }
                    debugMsg("Checking ordnance protection for '" .. wpnData.name .. "' at X: " .. explosionPoint.x .. ", Y: " .. explosionPoint.y .. ", Z: " .. explosionPoint.z .. " with radius " .. splash_damage_options.ordnance_protection_radius .. "m")
				world.searchObjects(Object.Category.WEAPON, checkVol, function(obj)
					if obj:isExist() and tracked_weapons[obj.id_] then
						safeToBlast = false
                            debugMsg("Skipping explosion for '" .. wpnData.name .. "' - nearby bomb '" .. tracked_weapons[obj.id_].name .. "' within " .. splash_damage_options.ordnance_protection_radius .. "m")
						return false
					end
					return true
                end)
            end
            if safeToBlast then
                    debugMsg("FinalPos Check for '" .. wpnData.name .. "': X: " .. string.format("%.0f", explosionPoint.x) .. ", Y: " .. string.format("%.0f", explosionPoint.y) .. ", Z: " .. string.format("%.0f", explosionPoint.z) .. ")")
            local base_explosive, isShapedCharge = getWeaponExplosive(wpnData.name)
            base_explosive = base_explosive * splash_damage_options.overall_scaling
            if splash_damage_options.rocket_multiplier and wpnData.cat == Weapon.Category.ROCKET then
                base_explosive = base_explosive * splash_damage_options.rocket_multiplier
            end
                    if wpnData.isGroundUnitOrdnance and splash_damage_options.track_groundunitordnance then
                        base_explosive = base_explosive * splash_damage_options.groundunitordnance_damage_modifier
                        if splash_damage_options.track_groundunitordnance_debug then
                            debugMsg("Applying ground unit ordnance damage modifier " .. splash_damage_options.groundunitordnance_damage_modifier .. " to " .. wpnData.name .. ", base explosive power: " .. base_explosive)
                end
            end

            local explosionPower = base_explosive
            if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                explosionPower = explosionPower * splash_damage_options.shaped_charge_multiplier
            end

            local blastRadius = splash_damage_options.blast_search_radius * 2 --Wider post-scan (180m default)
            if splash_damage_options.use_dynamic_blast_radius then
                    blastRadius = math.pow(explosionPower, 1/3) * 10 * splash_damage_options.dynamic_blast_radius_modifier
            end


                --Store pre-explosion state of all tracked weapons for detection
                local preExplosionWeapons = {}
                if splash_damage_options.ordnance_protection and splash_damage_options.detect_ordnance_destruction and splash_damage_options.larger_explosions then
                    for id, data in pairs(tracked_weapons) do
                        if data.wpn:isExist() then
                            preExplosionWeapons[id] = {
                                name = data.name,
                                pos = data.wpn:getPosition().p,
                                    distance = getDistance3D(explosionPoint, data.wpn:getPosition().p),
                                    explosive = getWeaponExplosive(data.name) --Store the explosive power
                            }
                        end
                    end
                end
			--Cluster Bomb Handling
			local weaponData = explTable[wpnData.name] or { explosive = 0, shaped_charge = false }
			local isCluster = weaponData.cluster or false
			if splash_damage_options.cluster_enabled and isCluster then
				local submunitionCount = weaponData.submunition_count or 30
				local submunitionPower = (weaponData.submunition_explosive or 1) * splash_damage_options.cluster_bomblet_damage_modifier * splash_damage_options.overall_scaling
                        local submunitionName = weaponData.submunition_name or "unknown"
				--Apply bomblet reduction logic if enabled
				if splash_damage_options.cluster_bomblet_reductionmodifier then
                            if submunitionCount > 35 then  
                                local reductionFactor = (60 - 35) / (247 - 35)
							submunitionCount = 35 + math.floor((submunitionCount - 35) * reductionFactor)
							if submunitionCount > 60 then submunitionCount = 60 end --Cap at 60
						end
					end
                        --Extended scan with general bomblet detection
                    timer.scheduleFunction(track_wpns_cluster_scan, {explosionPoint, wpnData.dir, wpnData.name, submunitionName, submunitionCount, submunitionPower, wpnData.speed}, timer.getTime() + 0.3)
			else
				--Standard explosion handling
				if splash_damage_options.larger_explosions then
                            debugMsg("Triggering initial explosion for '" .. wpnData.name .. "' at power " .. explosionPower)
					trigger.action.explosion(explosionPoint, explosionPower)
                            table.insert(recentExplosions, { pos = explosionPoint, time = timer.getTime(), radius = blastRadius })
                            debugMsg("Added to recentExplosions for '" .. wpnData.name .. "': X: " .. explosionPoint.x .. ", Y: " .. explosionPoint.y .. ", Z: " .. explosionPoint.z .. ", Time: " .. timer.getTime())
    	--Check for units destroyed by initial explosion
	    local playerName = wpnData.init or "unknown"
	    for _, target in ipairs(chosenTargets) do
	        if target.unit:isExist() and target.health > 0 and target.unit:getLife() <= 0 then
	            debugMsg("Unit " .. target.name .. " destroyed by initial explosion, credited to player: " .. playerName)
	        end
	    end
	end
	blastWave(explosionPoint, splash_damage_options.blast_search_radius, wpnData.name, explosionPower, isShapedCharge)

			end
            --detect_ordnance_destruction comes before recent_large_explosion_snap in original
            if splash_damage_options.ordnance_protection and splash_damage_options.detect_ordnance_destruction and splash_damage_options.larger_explosions then
                timer.scheduleFunction(function(args)
                    local explosionPoint = args[1]
                    local blastRadius = args[2]
                    local triggeringWeapon = args[3]
                    local preExplosionWeapons = args[4]
                    for id, preData in pairs(preExplosionWeapons) do
                        if tracked_weapons[id] and not tracked_weapons[id].wpn:isExist() then
                            if preData.distance <= blastRadius then
                                local msg = "WARNING: " .. preData.name .. " destroyed by large explosion from " .. triggeringWeapon .. " at " .. string.format("X: %.0f, Y: %.0f, Z: %.0f", explosionPoint.x, explosionPoint.y, explosionPoint.z)
                                gameMsg(msg)
                                debugMsg(msg)
                                env.info(msg)
                                if splash_damage_options.snap_to_ground_if_destroyed_by_large_explosion then
                                    local groundPos = {
                                        x = preData.pos.x,
                                        y = land.getHeight({x = preData.pos.x, y = preData.pos.z}),
                                        z = preData.pos.z
                                    }
                                    local destroyedWeaponPower, isShapedCharge = preData.explosive
                                    destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.overall_scaling
                                    if splash_damage_options.rocket_multiplier and tracked_weapons[id].cat == Weapon.Category.ROCKET then
                                        destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.rocket_multiplier
                                    end
                                    if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                                        destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.shaped_charge_multiplier
                                    end
                                    debugMsg("Triggering ground explosion for destroyed " .. preData.name .. " (detect_ordnance_destruction) at X: " .. string.format("%.0f", groundPos.x) .. ", Y: " .. string.format("%.0f", groundPos.y) .. ", Z: " .. string.format("%.0f", groundPos.z) .. " with power " .. destroyedWeaponPower)
                                    trigger.action.explosion(groundPos, destroyedWeaponPower)
                                end
                            end
                        end
                    end
                end, {explosionPoint, blastRadius, wpnData.name, preExplosionWeapons}, timer.getTime() + 0.2)
            end
            --recent_large_explosion_snap comes after main explosion and detect_ordnance_destruction
                    if splash_damage_options.ordnance_protection and splash_damage_options.larger_explosions and splash_damage_options.recent_large_explosion_snap and splash_damage_options.snap_to_ground_if_destroyed_by_large_explosion then
                        local currentTime = timer.getTime()
                        for id, data in pairs(tracked_weapons) do
                            if id ~= wpn_id_ and not data.wpn:isExist() then
                                local terrainHeight = land.getHeight({x = data.pos.x, y = data.pos.z})
			        local weaponHeight = data.pos.y - terrainHeight --Calculate height above ground
			        local isMidAir = weaponHeight > 5 --Still checks if above ground
                                    local snapTriggered = false
                                    for _, explosion in ipairs(recentExplosions) do
                                        local timeDiff = currentTime - explosion.time
                                        local distance = getDistance3D(data.pos, explosion.pos)
                                        debugMsg("Checking " .. data.name .. " at X: " .. data.pos.x .. ", Y: " .. data.pos.y .. ", Z: " .. data.pos.z .. " against explosion at X: " .. explosion.pos.x .. ", Y: " .. explosion.pos.y .. ", Z: " .. explosion.pos.z .. " - Distance: " .. distance .. "m, TimeDiff: " .. timeDiff .. "s")
                                        if timeDiff <= splash_damage_options.recent_large_explosion_time and distance <= splash_damage_options.recent_large_explosion_range then
                    				if isMidAir and weaponHeight <= splash_damage_options.max_snapped_height then --New height check
                                                local groundPos = { x = data.pos.x, y = terrainHeight, z = data.pos.z }
                                                local destroyedWeaponPower, isShapedCharge = getWeaponExplosive(data.name)
                                                destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.overall_scaling
                                                if splash_damage_options.rocket_multiplier and data.cat == Weapon.Category.ROCKET then
                                                    destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.rocket_multiplier
                                                end
                                                if splash_damage_options.apply_shaped_charge_effects and isShapedCharge then
                                                    destroyedWeaponPower = destroyedWeaponPower * splash_damage_options.shaped_charge_multiplier
                                                end
                        debugMsg("Weapon " .. data.name .. " detected recent large explosion within " .. splash_damage_options.recent_large_explosion_range .. "m and " .. splash_damage_options.recent_large_explosion_time .. "s, snapping to ground at X: " .. string.format("%.0f", groundPos.x) .. ", Y: " .. string.format("%.0f", groundPos.y) .. ", Z: " .. string.format("%.0f", groundPos.z) .. " with power " .. destroyedWeaponPower .. " (Height: " .. string.format("%.0f", weaponHeight) .. "m)")
                                                trigger.action.explosion(groundPos, destroyedWeaponPower)
                                                snapTriggered = true
                                                table.insert(weaponsToRemove, id)
                                                break
                    elseif isMidAir then
                        debugMsg("Weapon " .. data.name .. " destroyed above max_snapped_height (" .. splash_damage_options.max_snapped_height .. "m) at " .. string.format("%.0f", weaponHeight) .. "m, skipping snap")
                                            else
                                                debugMsg("Weapon " .. data.name .. " impacted ground within recent_large_explosion_range (" .. splash_damage_options.recent_large_explosion_range .. "m) and time (" .. splash_damage_options.recent_large_explosion_time .. "s), no snap needed")
                                    snapTriggered = true
                                                break
                                            end
                                        end
                                    end
                                    if not snapTriggered then
                                        if isMidAir then
                                debugMsg("Weapon " .. data.name .. " destroyed in air, but no recent large explosion within " .. splash_damage_options.recent_large_explosion_range .. "m or " .. splash_damage_options.recent_large_explosion_time .. "s")
                                        else
                                            debugMsg("Weapon " .. data.name .. " impacted ground, not processed by recent large explosion settings")
                                        end
                                    end
                            end
                        end
                        local newExplosions = {}
                        for _, explosion in ipairs(recentExplosions) do
                            if currentTime - explosion.time <= splash_damage_options.recent_large_explosion_time then
                                table.insert(newExplosions, explosion)
                            end
                        end
                        recentExplosions = newExplosions
                    end
                --Mark units as destroyed to avoid MiST accessing them
                local destroyedUnits = {}
                for _, target in ipairs(chosenTargets) do
                    if target.unit:isExist() and target.health > 0 and target.unit:getLife() <= 0 then
                        destroyedUnits[target.name] = true
                        debugMsg("Marked " .. target.name .. " as destroyed pre-impact")
                    end
                end
                --Schedule explosion handling with original 0.1-second delay, enhanced error handling
            timer.scheduleFunction(function(args)
                local finalPos = args[1]
                local explosionPoint = args[2]
                local explosionPower = args[3]
                local isShapedCharge = args[4]
                local blastRadius = args[5]
                local chosenTargets = args[6]
                local weaponName = args[7]
                local wpnData = args[8]
    		if splash_damage_options.debug then
                    debugMsg("Starting impact handling for " .. weaponName .. " at " .. timer.getTime() .. "s")
    		end
                    local status, err = pcall(function()
                --Log pre-explosion targets
                --Sort pre-explosion targets by distance
                table.sort(chosenTargets, function(a, b) return a.distance < b.distance end)
                if splash_damage_options.track_pre_explosion then
                    if #chosenTargets > 0 then
                        local msg = "Targets in blast zone for " .. weaponName .. " BEFORE explosion (last frame, using finalPos):\n"
                        for i, target in ipairs(chosenTargets) do
                            msg = msg .. "- " .. target.name .. " (Dist: " .. string.format("%.1f", target.distance) .. "m, Health: " .. target.health .. ")\n"
                        end
                        debugMsg(msg)
                        env.info("SplashDamage Pre-Explosion (Last Frame): " .. msg)
                    else
                        debugMsg("No targets in blast zone for " .. weaponName .. " BEFORE explosion (last frame)")
                        env.info("SplashDamage Pre-Explosion (Last Frame): No targets in blast zone for " .. weaponName)
                    end
                end

                blastWave(explosionPoint, splash_damage_options.blast_search_radius, wpnData.name, explosionPower, isShapedCharge)

                --Post-explosion analysis and queue cargo effects
                if splash_damage_options.track_pre_explosion then
                    timer.scheduleFunction(function(innerArgs)
                        local impactPoint = innerArgs[1]
                        local blastRadius = innerArgs[2]
                        local preExplosionTargets = innerArgs[3] or {}
                        local weaponName = innerArgs[4]
                        local weaponPower = innerArgs[5]
                        local playerName = innerArgs[6]
						    if splash_damage_options.debug == true then
                                debugMsg("Starting post-explosion analysis for " .. weaponName .. " at " .. timer.getTime() .. "s")
							end

                        --Scan all units in wider radius
                        local postExplosionTargets = {}
                        local volS = {
                            id = world.VolumeType.SPHERE,
                            params = {
                                point = impactPoint,
                                radius = blastRadius
                            }
                        }

                        local ifFound = function(foundObject)
                            if foundObject:isExist() then
                                local category = foundObject:getCategory()
                                if (category == Object.Category.UNIT and (foundObject:getDesc().category == Unit.Category.GROUND_UNIT or foundObject:getDesc().category == Unit.Category.AIRPLANE)) or
                                       category == Object.Category.STATIC then
                                        local distance = getDistance(impactPoint, foundObject:getPoint())
                                        table.insert(postExplosionTargets, {
                                            name = foundObject:getTypeName(),
                                            health = foundObject:getLife() or 0,
                                            position = foundObject:getPoint(),
                                            maxHealth = (category == Object.Category.UNIT and foundObject:getDesc().life) or foundObject:getLife() or 0,
                                            distance = distance,
                                            id = foundObject:getID(),
                                            unitName = foundObject:getName() or "Unknown"
                                        })
                                            end
                                end
                            return true
                        end

                        world.searchObjects({Object.Category.UNIT, Object.Category.STATIC}, volS, ifFound)
                        --Sort post-explosion targets by distance
                        table.sort(postExplosionTargets, function(a, b) return a.distance < b.distance end)
                        local msg = "Post-explosion analysis for " .. weaponName .. ":\n"

                        --Match pre-detected units
                        for _, preTarget in ipairs(preExplosionTargets) do
                            local found = false
                            local postHealth = 0
                            local postPosition = nil
                            local postDistance = 0
                            for _, postTarget in ipairs(postExplosionTargets) do
                                if preTarget.name == postTarget.name and getDistance(preTarget.position, postTarget.position) < 1 then
                                    found = true
                                    postHealth = postTarget.health
                                    postPosition = postTarget.position
                                    postDistance = postTarget.distance
                                    break
                                end
                            end

                            local healthPercent = preTarget.maxHealth > 0 and (postHealth / preTarget.maxHealth * 100) or 0
                            local status = ""

                            if not found or postHealth <= 0 then
                                status = "WAS FULLY DESTROYED"
								--killfeed make sure its not an unknown weapon or an ai
									--if splash_damage_options.killfeed_enable and explTable[weaponName] then
									if splash_damage_options.killfeed_enable and explTable[weaponName] and playerName ~= "unknown" then
										local status, isPlayer = pcall(function()
											local playerList = net.get_player_list() or {}
											for _, pid in ipairs(playerList) do
												local pinfo = net.get_player_info(pid)
												if pinfo and pinfo.name == playerName then
													return true
												end
											end
											return false
										end)
										if status and isPlayer then
											table.insert(splashKillfeedTemp, {
												playerName = playerName,
												weaponName = weaponName,
												unitName = preTarget.unitName,
												unitType = preTarget.name,
												unitId = preTarget.id,
												time = timer.getTime(),
												position = coords
											})
										end
									end
                            elseif healthPercent < splash_damage_options.cargo_damage_threshold then
                                status = "WAS DAMAGED BELOW THRESHOLD"
                            else
                                status = "SURVIVED (Health: " .. postHealth .. ")"
                            end

                            --Always include coords in status message
                            local coords = found and postPosition or preTarget.position
                            local statusMsg = status .. " AT " .. string.format("X: %.0f, Y: %.0f, Z: %.0f", coords.x, coords.y, coords.z) .. " (Dist: " .. string.format("%.1f", postDistance) .. "m, Pre: " .. preTarget.health .. ", Post: " .. postHealth .. ")"
                            --Check if target is in cargoUnits and within blast radius
                            local cargoData = cargoUnits[preTarget.name]
                            if cargoData and preTarget.distance <= blastRadius and 
                               (not found or postHealth <= 0 or healthPercent < splash_damage_options.cargo_damage_threshold) then

                                if splash_damage_options.enable_cargo_effects then
                                    local cargoPower = cargoData.cargoExplosionPower or weaponPower
                                    table.insert(cargoEffectsQueue, {
                                        name = preTarget.name,
                                        distance = preTarget.distance,
                                        coords = coords,
                                        power = cargoPower,
                                        explosion = cargoData.cargoExplosion,
                                        cookOff = cargoData.cargoCookOff,
                                        cookOffCount = cargoData.cookOffCount,
                                        cookOffPower = cargoData.cookOffPower,
                                        cookOffDuration = cargoData.cookOffDuration,
                                        cookOffRandomTiming = cargoData.cookOffRandomTiming,
                                        cookOffPowerRandom = cargoData.cookOffPowerRandom,
                                        isTanker = cargoData.isTanker,
                                        flameSize = cargoData.flameSize,
                                        flameDuration = cargoData.flameDuration
                                    })
                                    statusMsg = statusMsg .. " WITH CARGO EXPLOSION (Power: " .. cargoPower .. ")"
                                    if cargoData.cargoCookOff and cargoData.cookOffCount > 0 then
                                        statusMsg = statusMsg .. " WITH COOK-OFF (" .. cargoData.cookOffCount .. " blasts over " .. cargoData.cookOffDuration .. "s)"
                                    end
                                end
                            elseif splash_damage_options.smokeandcookoffeffectallvehicles and preTarget.distance <= blastRadius and 
                                   (not found or postHealth <= 0 or healthPercent < splash_damage_options.cargo_damage_threshold) then
                                if splash_damage_options.enable_cargo_effects then
                                    table.insert(cargoEffectsQueue, {
                                        name = preTarget.name,
                                        distance = preTarget.distance,
                                        coords = coords,
                                        power = splash_damage_options.allunits_explode_power, --No explosion
                                        explosion = true,
                                        cookOff = splash_damage_options.allunits_enable_cookoff,
                                        cookOffCount = splash_damage_options.allunits_cookoff_count,
                                        cookOffPower = splash_damage_options.allunits_cookoff_power,
                                        cookOffDuration = splash_damage_options.allunits_cookoff_duration,
                                        cookOffRandomTiming = true,
                                        cookOffPowerRandom = splash_damage_options.allunits_cookoff_powerrandom,
                                        isTanker = splash_damage_options.allunits_enable_smoke, --Enable smoke
                                        flameSize = splash_damage_options.allunits_default_flame_size, 
                                        flameDuration = splash_damage_options.allunits_default_flame_duration,
										cargoExplosionMult = 1
                                    })
                                    statusMsg = statusMsg .. " WITH DEFAULT SMOKE (Size: " .. splash_damage_options.allunits_default_flame_size .. ", Duration: " .. splash_damage_options.allunits_default_flame_duration .. "s)"
                                    debugMsg("Queued default smoke effect for " .. preTarget.name .. " at " .. string.format("%.1f", preTarget.distance) .. "m")
                                end
                            end

                            msg = msg .. "- " .. preTarget.name .. " " .. statusMsg .. "\n"
                        end
                        --Check for additional units
                        for _, postTarget in ipairs(postExplosionTargets) do
                            local isPreDetected = false
                            for _, preTarget in ipairs(preExplosionTargets) do
                                if preTarget.name == postTarget.name and getDistance(preTarget.position, postTarget.position) < 1 then
                                    isPreDetected = true
                                    break
                                end
                            end
                            if not isPreDetected then
                                local coords = postTarget.position
                                local healthPercent = postTarget.maxHealth > 0 and (postTarget.health / postTarget.maxHealth * 100) or 0
                                local status = postTarget.health <= 0 and "WAS FULLY DESTROYED" or 
                                              (healthPercent < splash_damage_options.cargo_damage_threshold and "WAS DAMAGED BELOW THRESHOLD" or 
                                              "SURVIVED (Health: " .. postTarget.health .. ")")
                                local statusMsg = status .. " AT " .. string.format("X: %.0f, Y: %.0f, Z: %.0f", coords.x, coords.y, coords.z) .. " (Dist: " .. string.format("%.1f", postTarget.distance) .. "m, Pre: Unknown, Post: " .. postTarget.health .. ")"
                                local cargoData = cargoUnits[postTarget.name]
                                if cargoData and (postTarget.health <= 0 or healthPercent < splash_damage_options.cargo_damage_threshold) then
                                    if splash_damage_options.enable_cargo_effects then
                                                    local cargoPower = cargoData.cargoExplosionPower or weaponPower --Use fixed power or fallback
                                    local distance = getDistance(impactPoint, coords)
                                    table.insert(cargoEffectsQueue, {
                                        name = postTarget.name,
                                        distance = distance,
                                        coords = coords,
                                        power = cargoPower,
                                        explosion = cargoData.cargoExplosion,
                                        cookOff = cargoData.cargoCookOff,
                                        cookOffCount = cargoData.cookOffCount,
                                        cookOffPower = cargoData.cookOffPower,
                                        cookOffDuration = cargoData.cookOffDuration,
                                        cookOffRandomTiming = cargoData.cookOffRandomTiming,
                                        cookOffPowerRandom = cargoData.cookOffPowerRandom,
                                        isTanker = cargoData.isTanker,
                                        flameSize = cargoData.flameSize,
                                        flameDuration = cargoData.flameDuration
                                    })
                                    statusMsg = statusMsg .. " WITH CARGO EXPLOSION (Power: " .. cargoPower .. ")"
                                                if cargoData.cargoCookOff and cargoData.cookOffCount > 0 then
                                        statusMsg = statusMsg .. " WITH COOK-OFF (" .. cargoData.cookOffCount .. " blasts over " .. cargoData.cookOffDuration .. "s)"
                                        end
                                    end
                                end
                                msg = msg .. "- " .. postTarget.name .. " " .. statusMsg .. "\n"
                            end
                        end

                        --Schedule all queued cargo effects
                        if #cargoEffectsQueue > 0 then
                            local effectIndex = 0
                                local processedCargoUnits = {} --Track processed units
    local flamePositions = {} --Track flame coords with 3m radius
                            for _, effect in ipairs(cargoEffectsQueue) do
                                    local unitKey = effect.name .. "_" .. effect.coords.x .. "_" .. effect.coords.z
                                    if not processedUnitsGlobal[unitKey] and not processedCargoUnits[unitKey] then
                                if effect.explosion then
                                    debugMsg("Triggering cargo explosion for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m with power " .. effect.power .. " scheduled at " .. effectIndex .. "s")
                                    timer.scheduleFunction(function(params)
                    debugMsg("Executing cargo explosion at X: " .. string.format("%.0f", params[1].x) .. ", Y: " .. string.format("%.0f", params[1].y) .. ", Z: " .. string.format("%.0f", params[1].z) .. " with power " .. params[2])
                                        trigger.action.explosion(params[1], params[2])
                end, {effect.coords, effect.power}, timer.getTime() + effectIndex + 0.1) --Slight delay for visibility
                                    if effect.isTanker then
                                        local flameSize = effect.flameSize or 3
                    			local flameDuration = effect.flameDuration --Use cargoUnits value directly, no default
                                        local flameDensity = 1.0 --Max density for visibility
                                        local effectId = effectSmokeId
                                        effectSmokeId = effectSmokeId + 1
                    --Check for nearby flames within 3m
                    local isDuplicate = false
                    for _, pos in pairs(flamePositions) do
                        if getDistance3D(effect.coords, pos) < 3 then
                            isDuplicate = true
                            debugMsg("Skipping duplicate flame for " .. effect.name .. " near X: " .. string.format("%.0f", pos.x) .. ", Y: " .. string.format("%.0f", pos.y) .. ", Z: " .. string.format("%.0f", pos.z))
                            break
                        end
                    end
                    if not isDuplicate then
                                        debugMsg("Adding flame effect for tanker " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m (Size: " .. flameSize .. ", Duration: " .. flameDuration .. "s, ID: " .. effectId .. ") scheduled at " .. effectIndex .. "s")
                                        timer.scheduleFunction(function(params)
                                                    --Adjust Y-coordinate to terrain height + offset
                                                    local terrainHeight = land.getHeight({x = params[1].x, y = params[1].z})
                                                    local adjustedCoords = {x = params[1].x, y = terrainHeight + 2, z = params[1].z}
                                                            debugMsg("Spawning flame effect at X: " .. string.format("%.0f", adjustedCoords.x) .. ", Y: " .. string.format("%.0f", adjustedCoords.y) .. ", Z: " .. string.format("%.0f", adjustedCoords.z))
            trigger.action.explosion(adjustedCoords, 10) --Small explosion to force visibility
                                                    trigger.action.effectSmokeBig(adjustedCoords, params[2], params[3], params[4])
                        end, {effect.coords, flameSize, flameDensity, effectId}, timer.getTime() + effectIndex + 0.2) --Slight delay
                                        timer.scheduleFunction(function(id)
                                            debugMsg("Stopping flame effect for " .. effect.name .. " (ID: " .. id .. ")")
                                            trigger.action.effectSmokeStop(id)
                        end, effectId, timer.getTime() + effectIndex + flameDuration + 0.2)
                        table.insert(flamePositions, effect.coords)
                                                end
                                    end
                                end
                                            debugMsg("Checking cook-off for " .. effect.name .. ": cookOff=" .. tostring(effect.cookOff) .. ", count=" .. tostring(effect.cookOffCount))
					if effect.cookOff and effect.cookOffCount > 0 then
						debugMsg("Scheduling " .. effect.cookOffCount .. " cook-off explosions for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m over " .. effect.cookOffDuration .. "s starting at " .. effectIndex .. "s")
						for i = 1, effect.cookOffCount do
							local delay = effect.cookOffRandomTiming and math.random() * effect.cookOffDuration or (i - 1) * (effect.cookOffDuration / effect.cookOffCount)
							local basePower = effect.cookOffPower
							local powerVariation = effect.cookOffPowerRandom / 100
							local cookOffPower = effect.cookOffPowerRandom == 0 and basePower or basePower * (1 + powerVariation * (math.random() * 2 - 1))
							debugMsg("Cook-off #" .. i .. " for " .. effect.name .. " at " .. string.format("%.1f", effect.distance) .. "m scheduled at " .. string.format("%.3f", delay) .. "s with power " .. string.format("%.2f", cookOffPower))
							timer.scheduleFunction(function(params)
								local pos = params[1]
								local power = params[2]
								debugMsg("Executing cook-off at " .. string.format("X: %.0f, Y: %.0f, Z: %.0f", pos.x, pos.y, pos.z) .. " with power " .. power)
								trigger.action.explosion(pos, power)
							end, {effect.coords, cookOffPower}, timer.getTime() + effectIndex + delay)
						end
           					if splash_damage_options.cookoff_flares_enabled then
                					scheduleCookOffFlares(effect.coords, effect.cookOffCount, effect.cookOffDuration, splash_damage_options.cookoff_flare_color)
						end
						--Debris burst only if cook-off is true and enabled
						if splash_damage_options.debris_effects then
							local debrisCount = math.random(splash_damage_options.debris_count_min, splash_damage_options.debris_count_max)
							for j = 1, debrisCount do
								--Random spherical offset
								local theta = math.random() * 2 * math.pi --Horizontal angle
								local phi = math.acos(math.random() * 2 - 1) --Vertical angle for sphere
								local minDist = splash_damage_options.debris_max_distance * 0.1 --10% of max
								local maxDist = splash_damage_options.debris_max_distance
								local r = math.random() * (maxDist - minDist) + minDist --10% to full max distance
								local debrisX = effect.coords.x + r * math.sin(phi) * math.cos(theta)
								local debrisZ = effect.coords.z + r * math.sin(phi) * math.sin(theta)
								local terrainY = land.getHeight({x = debrisX, y = debrisZ})
								local debrisY = terrainY + math.random() * maxDist --0 to max_distance above ground
								local debrisPos = {x = debrisX, y = debrisY, z = debrisZ}
								local debrisPower = splash_damage_options.debris_power
								local debrisDelay = (j - 1) * (effect.cookOffDuration / debrisCount) --Spread over cook-off duration
								timer.scheduleFunction(function(debrisArgs)
									local dPos = debrisArgs[1]
									local dPower = debrisArgs[2]
									debugMsg("Debris explosion at X: " .. string.format("%.0f", dPos.x) .. ", Y: " .. string.format("%.0f", dPos.y) .. ", Z: " .. string.format("%.0f", dPos.z) .. " with power " .. dPower)
									trigger.action.explosion(dPos, dPower)
								end, {debrisPos, debrisPower}, timer.getTime() + effectIndex + debrisDelay)
							end
						end
					end


                                        processedCargoUnits[unitKey] = true
                                        processedUnitsGlobal[unitKey] = true
							effectIndex = effectIndex + 3  --3 secs spacing if not random
                            end
                                end
                            --Clear the queue after scheduling
                            cargoEffectsQueue = {}
                        end

                        debugMsg(msg)
                        env.info("SplashDamage Post-Explosion: " .. msg)
                        -- Schedule splashKillFeed if there are entries
                        if #splashKillfeedTemp > 0 and splash_damage_options.killfeed_enable then
                            timer.scheduleFunction(splashKillFeed, {}, timer.getTime() + splash_damage_options.killfeed_splashdelay)
                        end
                    end, {finalPos, blastRadius, chosenTargets, weaponName, explosionPower, wpnData.init}, timer.getTime() + 1)
                        end
                    end)
                    if not status then
                            debugMsg("Impact handling error for '" .. weaponName .. "': " .. err)
                        end
                    end, {explosionPoint, explosionPoint, explosionPower, isShapedCharge, blastRadius, chosenTargets, wpnData.name, wpnData}, timer.getTime() + 0.1)
                else
                    debugMsg("Explosion skipped due to ordnance protection for '" .. wpnData.name .. "'")
                    if splash_damage_options.larger_explosions then
                        table.insert(recentExplosions, { pos = explosionPoint, time = timer.getTime(), radius = blastRadius })
                        debugMsg("Skipped explosion logged for snap check for '" .. wpnData.name .. "': X: " .. explosionPoint.x .. ", Y: " .. explosionPoint.y .. ", Z: " .. explosionPoint.z .. ", Time: " .. timer.getTime())
                    end
                end
                table.insert(weaponsToRemove, wpn_id_)
            end
			end
        end)
        if not status then
            debugMsg("Error in track_wpns for '" .. (wpnData.name or "unknown weapon") .. "': " .. err)
        end
    end
    --Perform all removals after iteration
    for _, id in ipairs(weaponsToRemove) do
        tracked_weapons[id] = nil
end
    return timer.getTime() + refreshRate
end

function onWpnEvent(event)
    if event.id == world.event.S_EVENT_SHOT then
        if event.weapon then
            local ordnance = event.weapon
            --verify isExist and getDesc
            local isValid = false
            local status, desc = pcall(function() return ordnance:isExist() and ordnance:getDesc() end)
            if status and desc then
                isValid = true
            end
            if not isValid then
                if splash_damage_options.debug then
                    env.info("SplashDamage: Invalid weapon object in S_EVENT_SHOT")
                    debugMsg("Invalid weapon object in S_EVENT_SHOT")
                end
                return
            end
            --Safely get typeName with pcall
            local status, typeName = pcall(function() return trim(ordnance:getTypeName()) end)
            if not status or not typeName then
                if splash_damage_options.debug then
                    env.info("SplashDamage: Failed to get weapon typeName: " .. tostring(typeName))
                    debugMsg("Failed to get weapon typeName: " .. tostring(typeName))
                end
                return
            end
 

            local playerName = "Unknown"
            if event.initiator then
                local status, playerNameResult = pcall(function() return event.initiator:getPlayerName() end)
                if status and playerNameResult then
                    playerName = playerNameResult
                else
                    local status, unitId = pcall(function() return event.initiator:getID() end)
                    if status and unitId then
                        local playerList = net.get_player_list() or {}
                        for _, pid in ipairs(playerList) do
                            local pinfo = net.get_player_info(pid)
                            if pinfo and pinfo.ucid and (tonumber(pinfo.slot) == unitId or pinfo.slot == event.initiator:getName()) then
                                    playerName = pinfo.name or "Unknown"
                                    break
                                end
                            end
                        end
                    end
                end
            if splash_damage_options.debug then
                env.info("Weapon [" .. typeName .. "] fired by player " .. playerName)
                debugMsg("Weapon [" .. typeName .. "] fired by player " .. playerName)
            end
		if splash_damage_options.napalmoverride_enabled then
			local napalmWeapons = {}
			for weapon in splash_damage_options.napalm_override_weapons:gmatch("[^,]+") do
				napalmWeapons[trim(weapon)] = true
			end
			if napalmWeapons[typeName] then
				isNapalm = true
				if splash_damage_options.debug then
					debugMsg("Tracking napalm override weapon: [" .. typeName .. "]")
				end
			end
		end
		if splash_damage_options.napalm_mk77_enabled and (typeName == "MK77mod0-WPN" or typeName == "MK77mod1-WPN") then
			isNapalm = true
			if splash_damage_options.debug then
				debugMsg("Tracking MK77 napalm weapon: [" .. typeName .. "]")
			end
		end
		if isNapalm then
			tracked_weapons[event.weapon.id_] = { 
				wpn = ordnance, 
                    init = playerName, 
				pos = ordnance:getPoint(), 
				dir = ordnance:getPosition().x, 
				name = typeName, 
				speed = ordnance:getVelocity(), 
				cat = ordnance:getCategory()
			}
			return
		end
            --Debug the exact typeName and explTable lookup
            if splash_damage_options.debug then
                debugMsg("Checking explTable for typeName: [" .. typeName .. "]")
            end
            local weaponData = explTable[typeName]
            if splash_damage_options.debug then
            if weaponData then
                    debugMsg("Found in explTable: explosive=" .. weaponData.explosive .. ", groundordnance=" .. tostring(weaponData.groundordnance))
                else
                    debugMsg("Not found in explTable: [" .. typeName .. "]")
                end
            end
                --Handle ground ordnance explicitly
            if weaponData and weaponData.groundordnance then
                if splash_damage_options.track_groundunitordnance then
                    --Count tracked ground ordnance
                    local groundOrdnanceCount = 0
                    for _, wpnData in pairs(tracked_weapons) do
                        if wpnData.isGroundUnitOrdnance then
                            groundOrdnanceCount = groundOrdnanceCount + 1
                        end
                    end
                    if groundOrdnanceCount >= splash_damage_options.groundunitordnance_maxtrackedcount then
                        if splash_damage_options.debug then
                            debugMsg("Skipping tracking for " .. typeName .. ": ground ordnance limit reached (" .. groundOrdnanceCount .. "/" .. splash_damage_options.groundunitordnance_maxtrackedcount .. ")")
                            env.info("SplashDamage: Skipping tracking for " .. typeName .. ": ground ordnance limit reached (" .. groundOrdnanceCount .. "/" .. splash_damage_options.groundunitordnance_maxtrackedcount .. ")")
                        end
                        return
                    end
                    if splash_damage_options.track_groundunitordnance_debug then
                        debugMsg("Tracking ground unit ordnance: " .. typeName .. " fired by " .. (event.initiator and event.initiator:getTypeName() or "unknown"))
                        env.info("SplashDamage: Tracking ground unit ordnance: " .. typeName .. " (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
                    end
                    tracked_weapons[event.weapon.id_] = { 
                        wpn = ordnance, 
                        init = playerName, 
                        pos = ordnance:getPoint(), 
                        dir = ordnance:getPosition().x, 
                        name = typeName, 
                        speed = ordnance:getVelocity(), 
                        cat = ordnance:getCategory(),
                        isGroundUnitOrdnance = true --Flag for ground ordnance
                    }
                elseif splash_damage_options.track_groundunitordnance_debug then
                    debugMsg("Event shot, but not tracking ground unit ordnance: " .. typeName)
                    env.info("SplashDamage: event shot, but not tracking ground unit ordnance: " .. typeName .. " (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
                end
                return
            end
            --Handle other tracked weapons in explTable
            if weaponData then
                if (ordnance:getDesc().category ~= 0) and event.initiator then
                    if ordnance:getDesc().category == 1 then --Missiles
                        if (ordnance:getDesc().MissileCategory ~= 1 and ordnance:getDesc().MissileCategory ~= 2) then --Exclude AAM and SAM
                            tracked_weapons[event.weapon.id_] = { 
                                wpn = ordnance, 
                                init = playerName, 
                                pos = ordnance:getPoint(), 
                                dir = ordnance:getPosition().x, 
                                name = typeName, 
                                speed = ordnance:getVelocity(), 
                                cat = ordnance:getCategory() 
                            }
                        end
                    else --Rockets, bombs, etc.
                        tracked_weapons[event.weapon.id_] = { 
                            wpn = ordnance, 
                            init = playerName, 
                            pos = ordnance:getPoint(), 
                            dir = ordnance:getPosition().x, 
                            name = typeName, 
                            speed = ordnance:getVelocity(), 
                            cat = ordnance:getCategory() 
                        }
                    end
                end
                return --Exit after handling known weapons
            end
            --Handle unknown weapons or non-tracked shells
                if string.find(typeName, "weapons.shells") then 
                if splash_damage_options.debug then
                    debugMsg("Event shot, but not tracking: " .. typeName)
                    env.info("SplashDamage: event shot, but not tracking: " .. typeName .. " (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
		end
                    return
                end

            --Log missing weapons
            env.info("SplashDamage: " .. typeName .. " missing from script (" .. (event.initiator and event.initiator:getTypeName() or "no initiator") .. ")")
            if splash_damage_options.weapon_missing_message then
                        trigger.action.outText("SplashDamage: " .. typeName .. " missing from script (" .. (event.initiator and event.initiator:isExist() and event.initiator:getTypeName() or "no initiator") .. ")", 3)
                        env.info("Current keys in explTable:")
                        for k, v in pairs(explTable) do
                            env.info("Key: [" .. k .. "]")
                end
  
                    end
                end
            end
        end

function splashKillFeed()
    if not splash_damage_options.killfeed_enable then return end

    local status, err = pcall(function()
        local tempTable = splashKillfeedTemp
        splashKillfeedTemp = {}
        local processedUnitIds = {} -- Track unit IDs processed in this batch

        for _, entry in ipairs(tempTable) do
            local unitId = entry.unitId
            local unitName = entry.unitName
            local unitType = entry.unitType
            local playerName = entry.playerName
            local weaponName = entry.weaponName
            local position = entry.position

            -- Skip if unitType is "Unknown"
            if unitType == "Unknown" then
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("SplashKillFeed: Skipped unit ID %s with unknown type at %.2f", unitId, timer.getTime()))
                end
                return
            end

            --Check if unit ID was already processed in this batch
            if processedUnitIds[unitId] then
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("SplashKillFeed: Skipped duplicate splash kill in batch for unit ID %s (%s) by %s with %s at %.2f",
                        unitId, unitType, playerName, weaponName, timer.getTime()))
                end
                return --Skip to next iteration
            end

            local unitExists = false
            local status, exists = pcall(function()
                local obj = Unit.getByName(unitName) or StaticObject.getByName(unitName)
                return obj and obj:isExist()
            end)
            if status and not exists then
                unitExists = false
            elseif status then
                unitExists = true
            else
                if splash_damage_options.killfeed_debug then
                    env.info("SplashKillFeed: Error checking existence of unit ID " .. tostring(unitId) .. ": " .. tostring(exists))
                end
            end

            if not unitExists then
                local isDuplicate = false
                for _, killEntry in ipairs(killfeedTable) do
                    if killEntry.unitID == unitId then
                        isDuplicate = true
                        if splash_damage_options.killfeed_debug then
                            env.info(string.format("SplashKillFeed: Skipped duplicate splash kill for unit ID %s (%s) by %s with %s at %.2f",
                                unitId, unitType, playerName, weaponName, timer.getTime()))
                        end
                        break
                    end
                end

                if not isDuplicate then
                    local msg = string.format("%s destroyed by %s's %s Splash Damage", unitType, playerName, weaponName)
                    if splash_damage_options.killfeed_game_messages then
                        local status, err = pcall(function()
                            trigger.action.outTextForCoalition(2, msg, splash_damage_options.killfeed_game_message_duration)
                        end)
                        if not status then
                            trigger.action.outText(msg, splash_damage_options.killfeed_game_message_duration)
                            if splash_damage_options.killfeed_debug then
                                env.info("SplashKillFeed: Failed coalition message: " .. tostring(err))
                            end
                        end
                    end

                    table.insert(splashKillfeedTable, {
                        unitName = unitName,
                        unitType = unitType,
                        unitId = unitId,
                        playerName = playerName,
                        weaponName = weaponName,
                        time = timer.getTime(),
                        position = position
                    })

                    if splash_damage_options.killfeed_debug then
                        env.info(string.format("SplashKillFeed: %s destroyed by %s's %s Splash Damage [ID: %s] at %.2f",
                            unitType, playerName, weaponName, unitId, timer.getTime()))
                    end
                    processedUnitIds[unitId] = true --Mark unit ID as processed
                end
            elseif splash_damage_options.killfeed_debug then
                env.info(string.format("SplashKillFeed: Unit ID %s (%s) still exists, skipping splash kill at %.2f",
                    unitId, unitType, timer.getTime()))
            end
        end
    end)

    if not status and splash_damage_options.killfeed_debug then
        env.info("SplashKillFeed: Error: " .. tostring(err))
    end
end


local function processSplashKillfeed()
  if not splash_damage_options.killfeed_enable or not splash_damage_options.killfeed_lekas_foothold_integration then
        if splash_damage_options.killfeed_debug then
            env.info("SplashDamage: processSplashKillfeed skipped")
        end
        return timer.getTime() + 60
    end

    if not bc or type(bc) ~= "table" or not bc.addTempStat then
        if splash_damage_options.killfeed_debug then
            env.info("SplashDamage: bc is not accessible or missing addTempStat")
        end
        return timer.getTime() + 60
    end

    local currentTime = timer.getTime()
    local entriesToRemove = {}
    local processedCount = 0

    -- Log bc table state before processing
    if splash_damage_options.killfeed_debug then
        env.info("SplashDamage: processSplashKillfeed started at " .. string.format("%.2f", currentTime))
        env.info("SplashDamage: bc table state: " .. (bc and "exists" or "nil"))
        env.info("SplashDamage: bc.addTempStat: " .. (bc.addTempStat and "exists" or "nil"))
        env.info("SplashDamage: bc.context: " .. (bc.context and "exists" or "nil"))
        if bc.context then
            env.info("SplashDamage: bc.context.playerContributions: " .. (bc.context.playerContributions and "exists" or "nil"))
            if bc.context.playerContributions then
                env.info("SplashDamage: bc.context.playerContributions[2]: " .. (bc.context.playerContributions[2] and "exists" or "nil"))
            end
        end
    end

    for i, entry in ipairs(splashKillfeedTable) do
        if currentTime - entry.time >= splash_damage_options.killfeed_lekas_contribution_delay then
            local playerName = entry.playerName
            local unitType = entry.unitType
            local unitId = entry.unitId

            -- Log entry details
            if splash_damage_options.killfeed_debug then
                env.info(string.format("SplashDamage: Processing splash kill entry %d: unitId=%s, unitType=%s, player=%s, time=%.2f",
                    i, unitId, unitType, playerName, entry.time))
            end

            local status, result = pcall(function()
                local statName = "Ground Units"
                local points = 10
                if unitType:find("Plane") then
                    statName = "Air"
                    points = 30
                elseif unitType:find("Helicopter") then
                    statName = "Helo"
                    points = 30
                elseif unitType:find("SAM") then
                    statName = "SAM"
                    points = 30
                elseif unitType:find("Infantry") then
                    statName = "Infantry"
                    points = 10
                elseif unitType:find("Ship") then
                    statName = "Ship"
                    points = 250
                elseif unitType:find("Building") then
                    statName = "Structure"
                    points = 30
                end
                bc:addTempStat(playerName, statName, 1)
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("SplashDamage: Added temp stat for %s: stat=%s, count=1", playerName, statName))
                end
                if bc.context and type(bc.context) == "table" and bc.context.playerContributions and type(bc.context.playerContributions) == "table" then
                    bc.context.playerContributions[2] = bc.context.playerContributions[2] or {}
                    local oldPoints = bc.context.playerContributions[2][playerName] or 0
                    bc.context.playerContributions[2][playerName] = oldPoints + points
                    if splash_damage_options.killfeed_debug then
                        env.info(string.format("SplashDamage: Updated contributions for %s: old=%d, new=%d, added=%d",
                            playerName, oldPoints, bc.context.playerContributions[2][playerName], points))
                    end
                else
                    if splash_damage_options.killfeed_debug then
                        env.info("SplashDamage: Skipped contribution update for " .. playerName .. ": bc.context or bc.context.playerContributions is nil")
                    end
                end
                processedCount = processedCount + 1
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("SplashDamage: Processed splash kill for %s by %s: stat=%s, points=%d, unitId=%s",
                        unitType, playerName, statName, points, unitId))
                end
            end)
            if not status and splash_damage_options.killfeed_debug then
                env.info("SplashDamage: Error processing splash kill for unitId=" .. tostring(unitId) .. ": " .. tostring(result))
            end
            table.insert(entriesToRemove, i)
        end
    end

    for i = #entriesToRemove, 1, -1 do
        table.remove(splashKillfeedTable, entriesToRemove[i])
    end

    if splash_damage_options.killfeed_debug then
        if bc.tempStats and type(bc.tempStats) == "table" then
            env.info("SplashDamage: tempStats contents:")
            for playerName, stats in pairs(bc.tempStats) do
                local statStr = ""
                for statKey, value in pairs(stats) do
                    statStr = statStr .. statKey .. "=" .. tostring(value) .. ", "
                end
                env.info("SplashDamage:   " .. playerName .. ": " .. (statStr ~= "" and statStr or "empty"))
            end
            if not next(bc.tempStats) then
                env.info("SplashDamage:   tempStats is empty")
            end
        else
            env.info("SplashDamage: bc.tempStats is nil or not a table")
        end
    end

    if splash_damage_options.killfeed_debug and processedCount > 0 then
        env.info("SplashDamage: Processed " .. processedCount .. " splash kills, remaining: " .. #splashKillfeedTable)
    end

    return timer.getTime() + 60
end




 
--Function to log and process unit data from event
function logEvent(eventName, eventData)
    local logStr = "\n---EVENT: " .. eventName .. " ---\n"

    --Variables to hold unit data
    local unitID, unitName, unitType, unitPosition, unitLife

    --Handle DEAD event (use initiator)
    if eventName == "DEAD" and eventData.initiator then
        unitID = safeGet(function() return eventData.initiator:getID() end, "unavailable")
        unitName = safeGet(function() return eventData.initiator:getName() end, "unknown")
        unitType = safeGet(function() return eventData.initiator:getTypeName() end, "unknown")
        unitPosition = safeGet(function()
            local pos = eventData.initiator:getPosition().p
            return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
        end, "unavailable")
        unitLife = safeGet(function() return eventData.initiator:getLife() end, 0)

        --Delay DEAD event processing by 0.1 seconds
        timer.scheduleFunction(function(params)
            local logStr = "\n---EVENT: " .. params.eventName .. " ---\n"

            --Check if unitID is already processed
            if LogEventProcessedUnitTable[params.unitID] then
                logStr = logStr .. "Unit ID " .. params.unitID .. " already processed in LogEventProcessedUnitTable\n"
                if splash_damage_options.events_debug then
                    env.info(logStr)
                end
                return
            end

            --Log and store unit data if valid
            if params.unitID ~= "unavailable" and params.unitName ~= "unavailable" and params.unitType ~= "unavailable" and params.unitPosition ~= "unavailable" and params.unitLife ~= "unavailable" then
                logStr = logStr .. "Stored Unit Data: ID=" .. params.unitID .. ", Name=" .. params.unitName .. ", Type=" .. params.unitType .. ", Position=" .. params.unitPosition .. ", Life=" .. params.unitLife .. "\n"
                logStr = logStr .. "Processing DEAD event for unit " .. params.unitName .. " (ID: " .. params.unitID .. ") at position " .. params.unitPosition .. "\n"

                --Store in LogEventProcessedUnitTable
                LogEventProcessedUnitTable[params.unitID] = {
                    id = params.unitID,
                    name = params.unitName,
                    type = params.unitType,
                    position = params.unitPosition,
                    life = params.unitLife,
                    event = params.eventName,
                    time = timer.getTime()
                }
            else
                --logStr = logStr .. "Unit Data Not Available: One or more fields unavailable\n"
            end

            if splash_damage_options.events_debug then
                env.info(logStr)
            end
        end, {
            eventName = eventName,
            unitID = unitID,
            unitName = unitName,
            unitType = unitType,
            unitPosition = unitPosition,
            unitLife = unitLife
        }, timer.getTime() + 0.1)
        return --Exit early to queue the event
    end

    --Handle HIT and KILL events (use target or object)
    if (eventName == "HIT" or eventName == "KILL") and (eventData.target or eventData.object) then
        local tgt = eventData.target or eventData.object
        unitID = safeGet(function() return tgt:getID() end, "unavailable")
        unitName = safeGet(function() return tgt:getName() end, "unknown")
        unitType = safeGet(function() return tgt:getTypeName() end, "unknown")
        unitPosition = safeGet(function()
            local pos = tgt:getPosition().p
            return string.format("x=%.0f, y=%.0f, z=%.0f", pos.x, pos.y, pos.z)
        end, "unavailable")
        unitLife = safeGet(function() return tgt:getLife() end, "Alive")
    end

    --Handle HIT event with delayed processing to capture last hit
    if eventName == "HIT" and unitID ~= "unavailable" then
        --Skip if life is 0 or below
        if type(unitLife) == "number" and unitLife <= 0 then
            logStr = logStr .. "Unit ID " .. unitID .. " has life <= 0, skipping HIT event\n"
            if splash_damage_options.events_debug then
                env.info(logStr)
            end
            return
        end

        --Store event data temporarily
        local hitData = {
            unitID = unitID,
            unitName = unitName,
            unitType = unitType,
            unitPosition = unitPosition,
            unitLife = unitLife,
            eventName = eventName,
            timestamp = timer.getTime()
        }

        --Schedule or reschedule processing after x seconds
        if not LogEventProcessedUnitTable[unitID] or LogEventProcessedUnitTable[unitID].event ~= "HIT" then
            LogEventProcessedUnitTable[unitID] = { event = "HIT", timerID = nil } --Initialize entry
        end

        --Cancel previous timer if exists
        if LogEventProcessedUnitTable[unitID].timerID then
            timer.removeFunction(LogEventProcessedUnitTable[unitID].timerID)
        end

        --Schedule new timer
        local timerID = timer.scheduleFunction(function(params)
            local logStr = "\n---EVENT: HIT ---\n"

            --Check if unitID is already processed by another event
            if LogEventProcessedUnitTable[params.unitID] and LogEventProcessedUnitTable[params.unitID].event ~= "HIT" then
                logStr = logStr .. "Unit ID " .. params.unitID .. " already processed by " .. LogEventProcessedUnitTable[params.unitID].event .. " event\n"
                if splash_damage_options.events_debug then
                    env.info(logStr)
                end
                return
            end

            --Log and store unit data if valid
            if params.unitID ~= "unavailable" and params.unitName ~= "unavailable" and params.unitType ~= "unavailable" and params.unitPosition ~= "unavailable" and params.unitLife ~= "unavailable" then
                logStr = logStr .. "Stored Unit Data: ID=" .. params.unitID .. ", Name=" .. params.unitName .. ", Type=" .. params.unitType .. ", Position=" .. params.unitPosition .. ", Life=" .. params.unitLife .. "\n"
                logStr = logStr .. "Processing HIT event for unit " .. params.unitName .. " (ID: " .. params.unitID .. ") with life " .. params.unitLife .. "\n"

                --Store in LogEventProcessedUnitTable
                LogEventProcessedUnitTable[params.unitID] = {
                    id = params.unitID,
                    name = params.unitName,
                    type = params.unitType,
                    position = params.unitPosition,
                    life = params.unitLife,
                    event = params.eventName,
                    time = params.timestamp
                }
            else
                --logStr = logStr .. "Unit Data Not Available: One or more fields unavailable\n"
            end

            if splash_damage_options.events_debug then
                env.info(logStr)
            end
        end, hitData, timer.getTime() + 0.15)

        LogEventProcessedUnitTable[unitID].timerID = timerID
        return --Exit early to queue the hit
    elseif eventName == "HIT" then
        --logStr = logStr .. "Unit Data Not Available: One or more fields unavailable\n"
        if splash_damage_options.events_debug then
            env.info(logStr)
        end
        return
    end

    --Check if unitID is already processed for KILL
    if unitID and LogEventProcessedUnitTable[unitID] and eventName == "KILL" then
        logStr = logStr .. "Unit ID " .. unitID .. " already processed in LogEventProcessedUnitTable\n"
        if splash_damage_options.events_debug then
            env.info(logStr)
        end
        return
    end

    --Log and store unit data for KILL if valid
    if eventName == "KILL" and unitID ~= "unavailable" and unitName ~= "unavailable" and unitType ~= "unavailable" and unitPosition ~= "unavailable" and unitLife ~= "unavailable" then
        logStr = logStr .. "Stored Unit Data: ID=" .. unitID .. ", Name=" .. unitName .. ", Type=" .. unitType .. ", Position=" .. unitPosition .. ", Life=" .. unitLife .. "\n"
        logStr = logStr .. "Processing KILL event for unit " .. unitName .. " (ID: " .. unitID .. ") of type " .. unitType .. "\n"

        --Store in LogEventProcessedUnitTable
        LogEventProcessedUnitTable[unitID] = {
            id = unitID,
            name = unitName,
            type = unitType,
            position = unitPosition,
            life = unitLife,
            event = eventName,
            time = timer.getTime()
        }
    elseif eventName == "KILL" then
        --logStr = logStr .. "Unit Data Not Available: One or more fields unavailable\n"
    end

    if splash_damage_options.events_debug then
        env.info(logStr)
    end
end



function WpnHandler:onEvent(event)
	protectedCall(onWpnEvent, event)
		if event.id == world.event.S_EVENT_HIT then
			logEvent("HIT", event)
		elseif event.id == world.event.S_EVENT_KILL then
			logEvent("KILL", event)
			protectedCall(onKillEvent, event)
		elseif event.id == world.event.S_EVENT_DEAD then
			logEvent("DEAD", event)
    end
end

--kill feed event function
function onKillEvent(event)
    if not splash_damage_options.killfeed_enable or event.id ~= world.event.S_EVENT_KILL then return end

    local status, err = pcall(function()
        local killedUnit = event.target
        local killer = event.initiator

        if not killedUnit then
            if splash_damage_options.killfeed_debug then
                env.info(string.format("KillFeed: Skipped, no target at %.2f", timer.getTime()))
            end
            return
        end

        local unitName = safeGet(function() return killedUnit:getName() end, "unknown")
        local unitType = safeGet(function() return killedUnit:getTypeName() end, "unknown")
        local unitID = safeGet(function() return killedUnit:getID() end, "unavailable")
        local position = safeGet(function()
            local pos = killedUnit:getPoint()
            return {x = pos.x, y = pos.y, z = pos.z}
        end, {x=0, y=0, z=0})

        if unitName == "unknown" or unitType == "unknown" or unitID == "unavailable" or unitID == 0 then
            if splash_damage_options.killfeed_debug then
                --env.info(string.format("KillFeed: Skipped unit ID %s with name %s and type %s at %.2f", tostring(unitID), unitName, unitType, timer.getTime()))
            end
            return
        end

        -- Check if unitID is already in killfeedTable
        for _, entry in ipairs(killfeedTable) do
            if entry.unitID == unitID then
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("KillFeed: Skipped unit ID %s (%s) already in killfeedTable at %.2f", unitID, unitType, timer.getTime()))
                end
                return
            end
        end

        local killerName = "Unknown"
        local killerUnitName = "Unknown"
        if killer then
            local status, unitNameResult = pcall(function() return killer:getName() end)
            if status and unitNameResult then
                killerUnitName = unitNameResult
            end
            local status, playerNameResult = pcall(function() return killer:getPlayerName() end)
            if status and playerNameResult then
                killerName = playerNameResult
            else
                local status, unitId = pcall(function() return killer:getID() end)
                if status and unitId then
                    local playerList = net.get_player_list() or {}
                    for _, pid in ipairs(playerList) do
                        local pinfo = net.get_player_info(pid)
                        if pinfo and pinfo.ucid then
                            local slotUnitId = tonumber(pinfo.slot) or pinfo.slot
                            if slotUnitId == unitId or pinfo.slot == killerUnitName then
                                killerName = pinfo.name or killerUnitName
                                break
                            end
                        end
                    end
                end
            end
            if splash_damage_options.killfeed_debug then
                env.info(string.format("KillFeed: Killer UnitName: %s, PlayerName: %s, UnitID: %s, Type: %s, Slot: %s",
                    killerUnitName, killerName, unitID, unitType, killer.getID and killer:getID() or "unknown"))
            end
        elseif splash_damage_options.killfeed_debug then
            env.info(string.format("KillFeed: Unit ID %s (%s) killed with no initiator at %.2f",
                unitID, unitType, timer.getTime()))
        end

        --Log bc table state for direct kill only if Lekas integration is enabled
        if splash_damage_options.killfeed_debug and splash_damage_options.killfeed_lekas_foothold_integration then
            env.info("KillFeed: bc table state for direct kill: " .. (bc and "exists" or "nil"))
            env.info("KillFeed: bc.addTempStat: " .. (bc and bc.addTempStat and "exists" or "nil"))
            env.info("KillFeed: bc.context: " .. (bc and bc.context and "exists" or "nil"))
            if bc and bc.context then
                env.info("KillFeed: bc.context.playerContributions: " .. (bc.context.playerContributions and "exists" or "nil"))
                if bc.context.playerContributions then
                    env.info("KillFeed: bc.context.playerContributions[2]: " .. (bc.context.playerContributions[2] and "exists" or "nil"))
                end
            end
        end

        --Check if unitID is in splashKillfeedTable
        local splashIndex = nil
        for i, entry in ipairs(splashKillfeedTable) do
            if entry.unitId == unitID then
                splashIndex = i
                break
            end
        end
        if splashIndex then
            local dupeMsg = string.format("Duplicate kill: %s (%s) [ID: %s]", unitName, unitType, unitID)
            if splash_damage_options.killfeed_game_messages then
                local status, err = pcall(function()
                    trigger.action.outTextForCoalition(2, dupeMsg, splash_damage_options.killfeed_game_message_duration)
                end)
                if not status then
                    trigger.action.outText(dupeMsg, splash_damage_options.killfeed_game_message_duration)
                    if splash_damage_options.killfeed_debug then
                        env.info("KillFeed: Failed coalition message for duplicate: " .. tostring(err))
                    end
                end
            end
            if splash_damage_options.killfeed_debug then
                env.info(string.format("KillFeed: %s at %.2f", dupeMsg, timer.getTime()))
            end
            table.remove(splashKillfeedTable, splashIndex)
            if splash_damage_options.killfeed_debug then
                env.info(string.format("SplashKillFeed: Removed duplicate entry for unit ID %s (%s) from splashKillfeedTable at %.2f",
                    unitID, unitType, timer.getTime()))
            end
        else
            --Process direct kill contribution
            if killerName ~= "Unknown" and splash_damage_options.killfeed_lekas_foothold_integration then
                local status, result = pcall(function()
                    local statName = "Ground Units"
                    local points = 10
                    if unitType:find("Plane") then
                        statName = "Air"
                        points = 30
                    elseif unitType:find("Helicopter") then
                        statName = "Helo"
                        points = 30
                    elseif unitType:find("SAM") then
                        statName = "SAM"
                        points = 30
                    elseif unitType:find("Infantry") then
                        statName = "Infantry"
                        points = 10
                    elseif unitType:find("Ship") then
                        statName = "Ship"
                        points = 250
                    elseif unitType:find("Building") then
                        statName = "Structure"
                        points = 30
                    end
                    bc:addTempStat(killerName, statName, 1)
                    if splash_damage_options.killfeed_debug then
                        env.info(string.format("KillFeed: Added temp stat for %s: stat=%s, count=1", killerName, statName))
                    end
                    if bc.context and type(bc.context) == "table" and bc.context.playerContributions and type(bc.context.playerContributions) == "table" then
                        bc.context.playerContributions[2] = bc.context.playerContributions[2] or {}
                        local oldPoints = bc.context.playerContributions[2][killerName] or 0
                        bc.context.playerContributions[2][killerName] = oldPoints + points
                        if splash_damage_options.killfeed_debug then
                            env.info(string.format("KillFeed: Updated contributions for %s: old=%d, new=%d, added=%d",
                                killerName, oldPoints, bc.context.playerContributions[2][killerName], points))
                        end
                    else
                        if splash_damage_options.killfeed_debug then
                            env.info("KillFeed: Skipped contribution update for " .. killerName .. ": bc.context or bc.context.playerContributions is nil")
                        end
                    end
                end)
                if not status and splash_damage_options.killfeed_debug then
                    env.info("KillFeed: Error processing direct kill for unitId=" .. tostring(unitID) .. ": " .. tostring(result))
                end
            end
        end

        if unitType ~= "Unknown" then
            table.insert(killfeedTable, {
                unitName = unitName,
                unitType = unitType,
                unitID = unitID,
                killer = killerName,
                time = timer.getTime(),
                position = position
            })

            if splash_damage_options.killfeed_game_messages and not splashIndex then
                local msg = string.format("%s destroyed by %s", unitType, killerName)
                local status, err = pcall(function()
                    trigger.action.outTextForCoalition(2, msg, splash_damage_options.killfeed_game_message_duration)
                end)
				
                if not status then
                    trigger.action.outText(msg, splash_damage_options.killfeed_game_message_duration)
                    if splash_damage_options.killfeed_debug then
                        env.info("KillFeed: Failed coalition message: " .. tostring(err))
                    end
                end
            end

            if splash_damage_options.killfeed_debug then
                env.info(string.format("KillFeed: Recorded %s destroyed by %s [ID: %s] at %.2f",
                    unitType, killerName, unitID, timer.getTime()))
            end
        end
    end)

    if not status and splash_damage_options.killfeed_debug then
        env.info("KillFeed: Error: " .. tostring(err))
    end
end


--kill feed event function
--kill feed event function
function onDeadEvent(event)
    if not splash_damage_options.killfeed_enable or event.id ~= world.event.S_EVENT_DEAD then return end

    local status, err = pcall(function()
        local deadUnit = event.initiator

        if not deadUnit then
            if splash_damage_options.killfeed_debug then
                env.info(string.format("DeadFeed: Skipped, no initiator at %.2f", timer.getTime()))
            end
            return
        end

        --Extract unit data using safeGet, matching logEvent defaults
        local unitID = safeGet(function() return deadUnit:getID() end, "unavailable")
        local unitName = safeGet(function() return deadUnit:getName() end, "unknown")
        local unitType = safeGet(function() return deadUnit:getTypeName() end, "unknown")
        local position = safeGet(function()
            local pos = deadUnit:getPoint()
            return {x = pos.x, y = pos.y, z = pos.z}
        end, {x=0, y=0, z=0})

        --Skip invalid units (unknown type, unavailable ID, or scenery with ID 0)
        if unitName == "unknown" or unitType == "unknown" or unitID == "unavailable" or unitID == 0 then
            if splash_damage_options.killfeed_debug then
                env.info(string.format("DeadFeed: Skipped unit ID %s with name %s and type %s at %.2f", tostring(unitID), unitName, unitType, timer.getTime()))
            end
            return
        end

        -- Check if unitID is already in killfeedTable before scheduling
        for _, entry in ipairs(killfeedTable) do
            if entry.unitID == unitID then
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("DeadFeed: Skipped unit ID %s (%s) already in killfeedTable at %.2f", unitID, unitType, timer.getTime()))
                end
                return
            end
        end

        --Delay processing by 2 seconds to allow S_EVENT_KILL to take precedence
        timer.scheduleFunction(function(params)
            local unitID = params.unitID
            local unitName = params.unitName
            local unitType = params.unitType
            local position = params.position
            local currentTime = timer.getTime()

            -- Re-check killfeedTable after delay to ensure no race condition
            for _, entry in ipairs(killfeedTable) do
                if entry.unitID == unitID then
                    if splash_damage_options.killfeed_debug then
                        env.info(string.format("DeadFeed: Skipped unit ID %s (%s) already in killfeedTable at %.2f", unitID, unitType, currentTime))
                    end
                    return
                end
            end

            --Remove from splashKillfeedTable if present
            local splashIndex = nil
            for i, entry in ipairs(splashKillfeedTable) do
                if entry.unitId == unitID then
                    splashIndex = i
                    break
                end
            end
            if splashIndex then
                table.remove(splashKillfeedTable, splashIndex)
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("DeadFeed: Removed unit ID %s (%s) from splashKillfeedTable at %.2f", unitID, unitType, currentTime))
                end
            end

            --Remove from splashKillfeedTemp if present
            local tempIndex = nil
            for i, entry in ipairs(splashKillfeedTemp) do
                if entry.unitId == unitID then
                    tempIndex = i
                    break
                end
            end
            if tempIndex then
                table.remove(splashKillfeedTemp, tempIndex)
                if splash_damage_options.killfeed_debug then
                    env.info(string.format("DeadFeed: Removed unit ID %s (%s) from splashKillfeedTemp at %.2f", unitID, unitType, currentTime))
                end
            end

            --Add to killfeedTable
            table.insert(killfeedTable, {
                unitName = unitName,
                unitType = unitType,
                unitID = unitID,
                killer = "unknown",
                time = currentTime,
                position = position
            })

            --Display in-game message
            if splash_damage_options.killfeed_game_messages then
                local msg = string.format("%s destroyed", unitType)
                local status, err = pcall(function()
                    trigger.action.outTextForCoalition(2, msg, splash_damage_options.killfeed_game_message_duration)
                end)
                if not status then
                    trigger.action.outText(msg, splash_damage_options.killfeed_game_message_duration)
                    if splash_damage_options.killfeed_debug then
                        env.info("DeadFeed: Failed coalition message: " .. tostring(err))
                    end
                end
            end

            if splash_damage_options.killfeed_debug then
                env.info(string.format("DeadFeed: Recorded %s destroyed [ID: %s] at %.2f", unitType, unitID, currentTime))
            end
        end, {
            unitID = unitID,
            unitName = unitName,
            unitType = unitType,
            position = position
        }, timer.getTime() + 2)
    end)

    if not status and splash_damage_options.killfeed_debug then
        env.info("DeadFeed: Error: " .. tostring(err))
    end
end

function explodeObject(args)
    local point = args[1]
    local distance = args[2]
    local power = args[3]
    trigger.action.explosion(point, power)
end
  
function blastWave(_point, _radius, weapon, power, isShapedCharge)
    if isShapedCharge then
        _radius = _radius * splash_damage_options.shaped_charge_multiplier
    end
    if splash_damage_options.use_dynamic_blast_radius then
        local dynamicRadius = math.pow(power, 1/3) * 5 * splash_damage_options.dynamic_blast_radius_modifier
        _radius = isShapedCharge and dynamicRadius * splash_damage_options.shaped_charge_multiplier or dynamicRadius
        end
    if splash_damage_options.debug then
        debugMsg("blastWave called for weapon '" .. weapon .. "' at X: " .. _point.x .. ", Y: " .. _point.y .. ", Z: " .. _point.z .. " with power " .. power .. " and radius " .. _radius .. "m")
    end
    
    local foundUnits = {}
    local volS = {
        id = world.VolumeType.SPHERE,
        params = {
            point = _point,
            radius = _radius
        }
    }
  
    local ifFound = function(foundObject, val)
        if foundObject:getDesc().category == Unit.Category.GROUND_UNIT and foundObject:getCategory() == Object.Category.UNIT then
            foundUnits[#foundUnits + 1] = foundObject
        end
        if foundObject:getDesc().category == Unit.Category.GROUND_UNIT and splash_damage_options.blast_stun then
            --suppressUnit(foundObject, 2, weapon) --Not implemented, commented out
        end
        if splash_damage_options.wave_explosions then
            local obj = foundObject
            local obj_location = obj:getPoint()
            local dist = getDistance(_point, obj_location)
            if dist > 1 then --Avoid re-exploding at exact impact point
            local timing = dist / 500
            if obj:isExist() and tableHasKey(obj:getDesc(), "box") then
                local length = (obj:getDesc().box.max.x + math.abs(obj:getDesc().box.min.x))
                local height = (obj:getDesc().box.max.y + math.abs(obj:getDesc().box.min.y))
                local depth = (obj:getDesc().box.max.z + math.abs(obj:getDesc().box.min.z))
                local _length = length
                local _depth = depth
                if depth > length then 
                    _length = depth 
                    _depth = length
                end
                local surface_distance = dist - _depth / 2
                local scaled_power_factor = 0.006 * power + 1
                local intensity = (power * scaled_power_factor) / (4 * math.pi * surface_distance^2)
                --Apply ground ordnance blastwave modifier
                local weaponData = explTable[weapon] or {}
                if splash_damage_options.track_groundunitordnance and weaponData.groundordnance then
                    intensity = intensity * splash_damage_options.groundunitordnance_blastwave_modifier
                    if splash_damage_options.track_groundunitordnance_debug then
                        debugMsg("Applied groundunitordnance_blastwave_modifier " .. splash_damage_options.groundunitordnance_blastwave_modifier .. " to " .. weapon .. ", intensity now: " .. intensity)
                    end
                end
                local surface_area = _length * height
                local damage_for_surface = intensity * surface_area
                    if splash_damage_options.debug then
                        debugMsg("Processing unit '" .. obj:getTypeName() .. "' at dist=" .. string.format("%.1f", dist) .. "m: intensity=" .. string.format("%.4f", intensity) .. ", surface_area=" .. string.format("%.2f", surface_area) .. ", damage_for_surface=" .. string.format("%.4f", damage_for_surface))
                    end
                if damage_for_surface > splash_damage_options.cascade_damage_threshold then
                    local explosion_size = damage_for_surface
                    if obj:getDesc().category == Unit.Category.STRUCTURE then
                        explosion_size = intensity * splash_damage_options.static_damage_boost
                    end
                    if explosion_size > power then explosion_size = power end
                    local triggerExplosion = false
                    if splash_damage_options.always_cascade_explode then
                            triggerExplosion = true
                            if splash_damage_options.debug then
                                debugMsg("Triggering secondary explosion for '" .. obj:getTypeName() .. "' due to always_cascade_explode")
                            end
                        else
                            if obj:getDesc().life then
                                local health = obj:getLife() or 0
                                local maxHealth = obj:getDesc().life or 1
                                local healthPercent = (health / maxHealth) * 100
                                if splash_damage_options.debug then
                                    debugMsg("Health check for '" .. obj:getTypeName() .. "': " .. health .. "/" .. maxHealth .. " (" .. string.format("%.2f", healthPercent) .. "%) vs threshold " .. splash_damage_options.cascade_explode_threshold)
                                end
                                if healthPercent <= splash_damage_options.cascade_explode_threshold then
                                    triggerExplosion = true
                                end
                            else
                                triggerExplosion = true
                                if splash_damage_options.debug then
                                    debugMsg("Triggering secondary explosion for '" .. obj:getTypeName() .. "' (no life data)")
                                end
                            end
                            if not triggerExplosion and obj:getDesc().category == Unit.Category.GROUND_UNIT then
                                local health = obj:getLife() or 0
                                if health <= 0 then
                                    triggerExplosion = true
                                    if splash_damage_options.debug then
                                        debugMsg("Triggering secondary explosion for '" .. obj:getTypeName() .. "' (health <= 0)")
                                    end
                                end
                            end
                        end
                            --Queue cargo effects for units below
                        if obj:getDesc().life then
                            local healthPercent = (obj:getLife() / obj:getDesc().life) * 100
                            local cargoData = cargoUnits[obj:getTypeName()]
                            if cargoData and healthPercent <= splash_damage_options.cargo_damage_threshold and splash_damage_options.enable_cargo_effects then
                                local cargoPower = power * cargoData.cargoExplosionMult
                                table.insert(cargoEffectsQueue, {
                                    name = obj:getTypeName(),
                                    distance = dist,
                                    coords = obj_location,
                                    power = cargoPower,
                                    explosion = cargoData.cargoExplosion,
                                    cookOff = cargoData.cargoCookOff,
                                    cookOffCount = cargoData.cookOffCount,
                                    cookOffPower = cargoData.cookOffPower,
                                    cookOffDuration = cargoData.cookOffDuration,
                                    cookOffRandomTiming = cargoData.cookOffRandomTiming,
                                    cookOffPowerRandom = cargoData.cookOffPowerRandom,
                                    isTanker = cargoData.isTanker,
                                    flameSize = cargoData.flameSize,
                                    flameDuration = cargoData.flameDuration
                                })
                                if splash_damage_options.debug then
                                    debugMsg("Queued cargo effect for '" .. obj:getTypeName() .. "' with power " .. cargoPower)
                                end
                            end
                    end
                    if triggerExplosion then
                            local final_power = explosion_size * splash_damage_options.cascade_scaling
                            if splash_damage_options.debug then
                                debugMsg("Scheduling secondary explosion for '" .. obj:getTypeName() .. "' at X: " .. obj_location.x .. ", Y: " .. obj_location.y .. ", Z: " .. obj_location.z .. ", dist=" .. string.format("%.1f", dist) .. "m, power=" .. string.format("%.2f", final_power))
                            end
                            if splash_damage_options.track_groundunitordnance_debug and weaponData.groundordnance then
                                debugMsg("Calculated power for '" .. obj:getTypeName() .. "' at X: " .. obj_location.x .. ", Y: " .. obj_location.y .. ", Z: " .. obj_location.z .. ", distance " .. dist .. "m: " .. final_power)
                            end
                            local playerName = tracked_weapons[weapon] and tracked_weapons[weapon].init or "unknown"
                            timer.scheduleFunction(function(args)
                                local obj = args[1]
                                local playerName = args[2]
                                if obj:isExist() and obj:getLife() <= 0 then
                                    debugMsg("Unit '" .. obj:getTypeName() .. "' destroyed by secondary explosion, credited to player: " .. playerName)
                                end
                            end, {obj, playerName}, timer.getTime() + timing + 0.1)
                            timer.scheduleFunction(explodeObject, {obj_location, dist, final_power}, timer.getTime() + timing)
                        else
                            if splash_damage_options.debug then
                                debugMsg("No secondary explosion for '" .. obj:getTypeName() .. "': health above threshold (" .. string.format("%.2f", (obj:getLife() / obj:getDesc().life) * 100) .. "% > " .. splash_damage_options.cascade_explode_threshold .. "%)")
                            end
                        end
                    else
                        if splash_damage_options.debug then
                            debugMsg("No secondary explosion for '" .. obj:getTypeName() .. "': damage_for_surface=" .. string.format("%.4f", damage_for_surface) .. " below threshold " .. splash_damage_options.cascade_damage_threshold)
                        end
                    end
                end
            end
        end
        return true
    end
  
    --Search all relevant object categories
    if splash_damage_options.debug then
        debugMsg("Scanning for objects within " .. _radius .. "m radius")
    end
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    world.searchObjects(Object.Category.STATIC, volS, ifFound)
    world.searchObjects(Object.Category.SCENERY, volS, ifFound)
    world.searchObjects(Object.Category.CARGO, volS, ifFound)
    if splash_damage_options.debug then
        debugMsg("Found " .. #foundUnits .. " ground units for damage modeling")
    end
    --Apply damage model if enabled
    if splash_damage_options.damage_model then
        timer.scheduleFunction(modelUnitDamage, foundUnits, timer.getTime() + 1.5)
    end
end
  
function modelUnitDamage(units)
    for i, unit in ipairs(units) do
        if unit:isExist() then
            local health = (unit:getLife() / unit:getDesc().life) * 100
            if unit:hasAttribute("Infantry") and health > 0 then
                if health <= splash_damage_options.infantry_cant_fire_health then
                    unit:getController():setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                end
            end
            if unit:getDesc().category == Unit.Category.GROUND_UNIT and (not unit:hasAttribute("Infantry")) and health > 0 then
                if health <= splash_damage_options.unit_cant_fire_health then
                    unit:getController():setOption(AI.Option.Ground.id.ROE, AI.Option.Ground.val.ROE.WEAPON_HOLD)
                    --gameMsg(unit:getTypeName() .. " weapons disabled")
                end
                if health <= splash_damage_options.unit_disabled_health and health > 0 then
                    unit:getController():setTask({id = 'Hold', params = {}})
                    unit:getController():setOnOff(false)
                    --gameMsg(unit:getTypeName() .. " disabled")
                end
            end
        end
    end
end

function updateSplashDamageSetting(setting, increment)
    if not splash_damage_options[setting] then
        env.info("Error: Setting " .. setting .. " does not exist.")
        return
    end

    local newValue = math.max(0, splash_damage_options[setting] + increment)
    env.info("Updating " .. setting .. " from " .. tostring(splash_damage_options[setting]) .. " to " .. tostring(newValue))
    splash_damage_options[setting] = newValue
    trigger.action.outText("Updated " .. setting .. " to: " .. tostring(splash_damage_options[setting]), 5)
end

function toggleSplashDamageSetting(setting)
    splash_damage_options[setting] = not splash_damage_options[setting]
    trigger.action.outText("Toggled " .. setting .. " to: " .. tostring(splash_damage_options[setting]), 5)

    if setting == "enable_radio_menu" then
        if splash_damage_options.enable_radio_menu then
            addSplashDamageMenu()
        else
            missionCommands.removeItem(splash_damage_menu)
            splash_damage_menu = nil
        end
    end
end

function addValueAdjustmentCommands(menu, setting, increments)
    for _, inc in ipairs(increments) do
        missionCommands.addCommand("+" .. inc, menu, updateSplashDamageSetting, setting, inc)
        missionCommands.addCommand("-" .. inc, menu, updateSplashDamageSetting, setting, -inc)
    end
end

function exitSplashDamageMenu()
    if splash_damage_menu then
        missionCommands.removeItem(splash_damage_menu)
        splash_damage_menu = nil
    end
end

function addSplashDamageMenu()
    if not splash_damage_options.enable_radio_menu then return end

    if splash_damage_menu then
        missionCommands.removeItem(splash_damage_menu)
    end

    splash_damage_menu = missionCommands.addSubMenu("Splash Damage Settings")

    --1. Debug and Messages
    local debugMenu = missionCommands.addSubMenu("Debug and Messages", splash_damage_menu)
    local debugSettings = {
        "game_messages",
        "debug",
        "weapon_missing_message",
        "track_pre_explosion_debug",
        "track_groundunitordnance_debug",
        "napalm_unitdamage_debug"
    }
    for _, setting in ipairs(debugSettings) do
        missionCommands.addCommand("Toggle " .. setting:gsub("_", " "), debugMenu, toggleSplashDamageSetting, setting)
    end

    --2. Basic Splash Settings
    local splashMenu = missionCommands.addSubMenu("Basic Splash Settings", splash_damage_menu)
    local splashToggles = {
        "wave_explosions",
        "larger_explosions",
        "damage_model",
        "blast_stun"
    }
    for _, setting in ipairs(splashToggles) do
        missionCommands.addCommand("Toggle " .. setting:gsub("_", " "), splashMenu, toggleSplashDamageSetting, setting)
    end
    local staticDamageMenu = missionCommands.addSubMenu("Static Damage Boost", splashMenu)
    addValueAdjustmentCommands(staticDamageMenu, "static_damage_boost", {100, 500, 1000})

    --Submenu: Scaling and Cascading
    local scalingMenu = missionCommands.addSubMenu("Scaling and Cascading", splashMenu)
    local scalingSettings = {
        {name = "Overall Scaling", setting = "overall_scaling", increments = {0.1, 0.5, 1}},
        {name = "Rocket Multiplier", setting = "rocket_multiplier", increments = {0.1, 0.5, 1}},
        {name = "Cascade Scaling", setting = "cascade_scaling", increments = {0.1, 0.5, 1}},
        {name = "Cascade Damage Threshold", setting = "cascade_damage_threshold", increments = {0.01, 0.05, 0.1}},
        {name = "Cascade Explode Threshold", setting = "cascade_explode_threshold", increments = {5, 10, 25}}
    }
    for _, s in ipairs(scalingSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, scalingMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end
    missionCommands.addCommand("Toggle Always Cascade Explode", scalingMenu, toggleSplashDamageSetting, "always_cascade_explode")

    --Submenu: Blast Radius & Shaped Charge
    local blastMenu = missionCommands.addSubMenu("Blast Radius & Shaped Charge", splashMenu)
    local blastRadiusMenu = missionCommands.addSubMenu("Blast Search Radius", blastMenu)
    addValueAdjustmentCommands(blastRadiusMenu, "blast_search_radius", {5, 10, 25})
    missionCommands.addCommand("Toggle Dynamic Blast Radius", blastMenu, toggleSplashDamageSetting, "use_dynamic_blast_radius")
    local dynamicBlastMenu = missionCommands.addSubMenu("Dynamic Blast Radius Modifier", blastMenu)
    addValueAdjustmentCommands(dynamicBlastMenu, "dynamic_blast_radius_modifier", {0.1, 0.5, 1})
    missionCommands.addCommand("Toggle Shaped Charge Effects", blastMenu, toggleSplashDamageSetting, "apply_shaped_charge_effects")
    local shapedChargeMenu = missionCommands.addSubMenu("Shaped Charge Multiplier", blastMenu)
    addValueAdjustmentCommands(shapedChargeMenu, "shaped_charge_multiplier", {0.1, 0.5, 1})

    --Submenu: Units
    local unitsMenu = missionCommands.addSubMenu("Units", splashMenu)
    local unitSettings = {
        {name = "Unit Disabled Health", setting = "unit_disabled_health", increments = {5, 10, 25}},
        {name = "Unit Can't Fire Health", setting = "unit_cant_fire_health", increments = {5, 10, 25}},
        {name = "Infantry Can't Fire Health", setting = "infantry_cant_fire_health", increments = {5, 10, 25}}
    }
    for _, s in ipairs(unitSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, unitsMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end

    --Submenu: Ground Ordnance Tracking
    local groundOrdnanceMenu = missionCommands.addSubMenu("Ground Ordnance Tracking", splashMenu)
    missionCommands.addCommand("Toggle Ground Ordnance Tracking", groundOrdnanceMenu, toggleSplashDamageSetting, "track_groundunitordnance")
    local groundSettings = {
        {name = "Damage Modifier", setting = "groundunitordnance_damage_modifier", increments = {0.1, 0.5, 1}},
        {name = "Blastwave Modifier", setting = "groundunitordnance_blastwave_modifier", increments = {0.1, 0.5, 1}},
        {name = "Max Tracked Count", setting = "groundunitordnance_maxtrackedcount", increments = {5, 10, 25}}
    }
    for _, s in ipairs(groundSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, groundOrdnanceMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end
    missionCommands.addCommand("Toggle 50m Scan", groundOrdnanceMenu, toggleSplashDamageSetting, "scan_50m_for_groundordnance")

    --3. Cargo Cook-off & Fuel Explosion
    local cargoMenu = missionCommands.addSubMenu("Cargo Cook-off & Fuel Explosion", splash_damage_menu)
    missionCommands.addCommand("Toggle Track Pre-Explosion", cargoMenu, toggleSplashDamageSetting, "track_pre_explosion")
    missionCommands.addCommand("Toggle Cargo Effects", cargoMenu, toggleSplashDamageSetting, "enable_cargo_effects")
    local cargoThresholdMenu = missionCommands.addSubMenu("Cargo Damage Threshold", cargoMenu)
    addValueAdjustmentCommands(cargoThresholdMenu, "cargo_damage_threshold", {5, 10, 25})
    missionCommands.addCommand("Toggle Debris Effects", cargoMenu, toggleSplashDamageSetting, "debris_effects")
    local debrisSettings = {
        {name = "Debris Power", setting = "debris_power", increments = {1, 5, 10}},
        {name = "Min Debris Count", setting = "debris_count_min", increments = {1, 5, 10}},
        {name = "Max Debris Count", setting = "debris_count_max", increments = {1, 5, 10}},
        {name = "Max Debris Distance", setting = "debris_max_distance", increments = {1, 5, 10}}
    }
    for _, s in ipairs(debrisSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, cargoMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end

    --Submenu: Cook-off Flares
    local flareMenu = missionCommands.addSubMenu("Cook-off Flares", cargoMenu)
    missionCommands.addCommand("Toggle Cook-off Flares", flareMenu, toggleSplashDamageSetting, "cookoff_flares_enabled")
    local flareColorMenu = missionCommands.addSubMenu("Flare Color", flareMenu)
    local flareColors = {
        {name = "Green", value = 0},
        {name = "White", value = 1},
        {name = "Red", value = 2},
        {name = "Yellow", value = 3}
    }
    for _, color in ipairs(flareColors) do
        missionCommands.addCommand(color.name, flareColorMenu, function()
            splash_damage_options.cookoff_flare_color = color.value
            trigger.action.outText("Cook-off flare color set to " .. color.name, 5)
        end)
    end
    local flareCountMenu = missionCommands.addSubMenu("Flare Count Modifier", flareMenu)
    addValueAdjustmentCommands(flareCountMenu, "cookoff_flare_count_modifier", {0.1, 0.5, 1})
    local flareOffsetMenu = missionCommands.addSubMenu("Flare Offset", flareMenu)
    addValueAdjustmentCommands(flareOffsetMenu, "cookoff_flare_offset", {1, 5, 10})

    --Submenu: All Vehicles Options
    local allVehiclesMenu = missionCommands.addSubMenu("All Vehicles Options", cargoMenu)
    local vehicleToggles = {
        "smokeandcookoffeffectallvehicles",
        "allunits_enable_smoke",
        "allunits_enable_cookoff"
    }
    for _, setting in ipairs(vehicleToggles) do
        missionCommands.addCommand("Toggle " .. setting:gsub("_", " "), allVehiclesMenu, toggleSplashDamageSetting, setting)
    end
    local vehicleSettings = {
        {name = "Explosion Power", setting = "allunits_explode_power", increments = {5, 10, 25}},
        {name = "Default Flame Size", setting = "allunits_default_flame_size", increments = {1, 5, 10}},
        {name = "Default Flame Duration", setting = "allunits_default_flame_duration", increments = {5, 10, 25}},
        {name = "Cook-off Count", setting = "allunits_cookoff_count", increments = {1, 5, 10}},
        {name = "Cook-off Duration", setting = "allunits_cookoff_duration", increments = {5, 10, 25}},
        {name = "Cook-off Power", setting = "allunits_cookoff_power", increments = {5, 10, 25}},
        {name = "Cook-off Power Random", setting = "allunits_cookoff_powerrandom", increments = {5, 10, 25}}
    }
    for _, s in ipairs(vehicleSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, allVehiclesMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end

    --4. Ordnance Protection & Cluster
    local ordnanceMenu = missionCommands.addSubMenu("Ordnance Protection & Cluster", splash_damage_menu)
    local ordnanceToggles = {
        "ordnance_protection",
        "detect_ordnance_destruction",
        "snap_to_ground_if_destroyed_by_large_explosion",
        "recent_large_explosion_snap"
    }
    for _, setting in ipairs(ordnanceToggles) do
        missionCommands.addCommand("Toggle " .. setting:gsub("_", " "), ordnanceMenu, toggleSplashDamageSetting, setting)
    end
    local ordnanceSettings = {
        {name = "Ordnance Protection Radius", setting = "ordnance_protection_radius", increments = {5, 10, 25}},
        {name = "Max Snapped Height", setting = "max_snapped_height", increments = {5, 10, 25}},
        {name = "Recent Explosion Range", setting = "recent_large_explosion_range", increments = {5, 10, 25}},
        {name = "Recent Explosion Time", setting = "recent_large_explosion_time", increments = {1, 5, 10}}
    }
    for _, s in ipairs(ordnanceSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, ordnanceMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end

    --Submenu: Cluster Bombs
    local clusterMenu = missionCommands.addSubMenu("Cluster Bombs", ordnanceMenu)
    missionCommands.addCommand("Toggle Cluster Enabled", clusterMenu, toggleSplashDamageSetting, "cluster_enabled")
    local clusterSettings = {
        {name = "Cluster Base Length", setting = "cluster_base_length", increments = {25, 50, 100}},
        {name = "Cluster Base Width", setting = "cluster_base_width", increments = {25, 50, 100}},
        {name = "Cluster Max Length", setting = "cluster_max_length", increments = {25, 50, 100}},
        {name = "Cluster Max Width", setting = "cluster_max_width", increments = {25, 50, 100}},
        {name = "Cluster Min Length", setting = "cluster_min_length", increments = {25, 50, 100}},
        {name = "Cluster Min Width", setting = "cluster_min_width", increments = {25, 50, 100}},
        {name = "Bomblet Damage Modifier", setting = "cluster_bomblet_damage_modifier", increments = {1, 5, 10}}
    }
    for _, s in ipairs(clusterSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, clusterMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end
    missionCommands.addCommand("Toggle Bomblet Reduction", clusterMenu, toggleSplashDamageSetting, "cluster_bomblet_reductionmodifier")

    --5. Giant Explosions
    local giantExplosionMenu = missionCommands.addSubMenu("Giant Explosions", splash_damage_menu)
    local giantToggles = {
        "giant_explosion_enabled",
        "giant_explosion_target_static",
        "giantexplosion_ondamage",
        "giantexplosion_ondeath",
    }
    for _, setting in ipairs(giantToggles) do
        missionCommands.addCommand("Toggle " .. setting:gsub("_", " "), giantExplosionMenu, toggleSplashDamageSetting, setting)
    end
    local giantSettings = {
        {name = "Explosion Power", setting = "giant_explosion_power", increments = {500, 1000, 2000}},
        {name = "Size Scale", setting = "giant_explosion_scale", increments = {0.1, 0.5, 1, 2}},
        {name = "Duration", setting = "giant_explosion_duration", increments = {0.1, 0.5, 1, 2}},
        {name = "Explosion Count", setting = "giant_explosion_count", increments = {25, 50, 100}},
    }
    for _, s in ipairs(giantSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, giantExplosionMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end
    local testExplosionMenu = missionCommands.addSubMenu("Test Explosions", giantExplosionMenu)
    if splash_damage_options.giantexplosion_testmode then
        for _, target in ipairs(giantExplosionTestTargets) do
            missionCommands.addCommand("Detonate " .. target.name, testExplosionMenu, function()
                triggerGiantExplosion({
                    pos = target.pos,
                    power = splash_damage_options.giant_explosion_power,
                    scale = splash_damage_options.giant_explosion_scale,
                    duration = splash_damage_options.giant_explosion_duration,
                    count = splash_damage_options.giant_explosion_count
                })
            end)
        end
        missionCommands.addCommand("Detonate All Giant Targets", testExplosionMenu, function()
            for _, target in ipairs(giantExplosionTestTargets) do
                triggerGiantExplosion({
                    pos = target.pos,
                    power = splash_damage_options.giant_explosion_power,
                    scale = splash_damage_options.giant_explosion_scale,
                    duration = splash_damage_options.giant_explosion_duration,
                    count = splash_damage_options.giant_explosion_count
                })
            end
        end)
    end

    --6. Napalm
    local napalmMenu = missionCommands.addSubMenu("Napalm", splash_damage_menu)
    local napalmToggles = {
        "napalm_mk77_enabled",
        "napalmoverride_enabled",
        "napalm_phosphor_enabled",
        "napalm_addflame"
    }
    for _, setting in ipairs(napalmToggles) do
        missionCommands.addCommand("Toggle " .. setting:gsub("_", " "), napalmMenu, toggleSplashDamageSetting, setting)
    end

    --Submenu: Spread/Phosphor/Flame
    local spreadPhosphorFlameMenu = missionCommands.addSubMenu("Spread/Phosphor/Flame", napalmMenu)
    local napalmSettings = {
        {name = "Spread Points", setting = "napalm_spread_points", increments = {1, 2, 3}},
        {name = "Spread Spacing", setting = "napalm_spread_spacing", increments = {1, 5, 10}},
        {name = "Phosphor Multiplier", setting = "napalm_phosphor_multiplier", increments = {0.1, 0.5, 1}},
        {name = "Flame Duration", setting = "napalm_addflame_duration", increments = {10, 30, 60}}
    }
    for _, s in ipairs(napalmSettings) do
        local subMenu = missionCommands.addSubMenu(s.name, spreadPhosphorFlameMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end
    local napalmFlameSizeMenu = missionCommands.addSubMenu("Flame Size", spreadPhosphorFlameMenu)
    for i = 1, 8 do
        missionCommands.addCommand("Set " .. i, napalmFlameSizeMenu, function()
            splash_damage_options.napalm_addflame_size = i
            trigger.action.outText("Napalm flame size set to " .. i, 5)
        end)
    end

    --Submenu: Delay Settings
    local napalmDelayMenu = missionCommands.addSubMenu("Delay Settings", napalmMenu)
    local napalmDelaySettings = {
        {name = "Explode Delay", setting = "napalm_explode_delay", increments = {0.01, 0.05, 0.1}},
        {name = "Destroy Delay", setting = "napalm_destroy_delay", increments = {0.01, 0.05, 0.1}},
        {name = "Flame Delay", setting = "napalm_flame_delay", increments = {0.01, 0.05, 0.1}}
    }
    for _, s in ipairs(napalmDelaySettings) do
        local subMenu = missionCommands.addSubMenu(s.name, napalmDelayMenu)
        addValueAdjustmentCommands(subMenu, s.setting, s.increments)
    end

    --Submenu: DoubleWide
    local doubleWideMenu = missionCommands.addSubMenu("DoubleWide", napalmMenu)
    missionCommands.addCommand("Toggle DoubleWide Enabled", doubleWideMenu, toggleSplashDamageSetting, "napalm_doublewide_enabled")
    local doubleWideSpreadMenu = missionCommands.addSubMenu("DoubleWide Spread", doubleWideMenu)
    addValueAdjustmentCommands(doubleWideSpreadMenu, "napalm_doublewide_spread", {1, 5, 10})

    --Submenu: Unit Damage
    local unitDamageMenu = missionCommands.addSubMenu("Unit Damage", napalmMenu)
    missionCommands.addCommand("Toggle Unit Damage Enabled", unitDamageMenu, toggleSplashDamageSetting, "napalm_unitdamage_enable")
    missionCommands.addCommand("Toggle Infantry Fire", unitDamageMenu, toggleSplashDamageSetting, "napalm_unitdamage_infantryfire")
    local scanDistanceMenu = missionCommands.addSubMenu("Scan Distance", unitDamageMenu)
    addValueAdjustmentCommands(scanDistanceMenu, "napalm_unitdamage_scandistance", {20, 25, 50})
    local startDelayMenu = missionCommands.addSubMenu("Start Delay", unitDamageMenu)
    addValueAdjustmentCommands(startDelayMenu, "napalm_unitdamage_startdelay", {0.1, 0.2, 0.5})
    local spreadDelayMenu = missionCommands.addSubMenu("Spread Delay", unitDamageMenu)
    addValueAdjustmentCommands(spreadDelayMenu, "napalm_unitdamage_spreaddelay", {0.1, 0.2, 0.5})


    --7. Exit Menu
    missionCommands.addCommand("Exit Splash Damage Menu", splash_damage_menu, exitSplashDamageMenu)
end

if (script_enable == 1) then
    gameMsg("SPLASH DAMAGE 3.4 SCRIPT RUNNING")
    env.info("SPLASH DAMAGE 3.4 SCRIPT RUNNING")

    timer.scheduleFunction(function()
        protectedCall(track_wpns)
        return timer.getTime() + refreshRate
    end, {}, timer.getTime() + refreshRate)

    if splash_damage_options.giant_explosion_enabled then
        scanGiantExplosionTargets()
        if not splash_damage_options.giant_explosion_target_static then
            timer.scheduleFunction(updateGiantExplosionPositions, {}, timer.getTime() + 1.0)
        end
    end
	
	if splash_damage_options.killfeed_enable then
        world.addEventHandler({ onEvent = function(self, event) protectedCall(onKillEvent, event) end }) --Add kill event handler
    end

    world.addEventHandler(WpnHandler)
    addSplashDamageMenu()
	
	--Lekas integration
	if splash_damage_options.killfeed_enable and splash_damage_options.killfeed_lekas_foothold_integration then
		timer.scheduleFunction(processSplashKillfeed, {}, timer.getTime() + 60)
		if splash_damage_options.killfeed_debug then
			env.info("SplashDamage: Scheduled processSplashKillfeed for Lekas Foothold integration")
		end
	end	

end

--[[-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=
                            		##### Changelog #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=- =--=-=-=-=-=-=-=
   
    24th May 2025 - 3.3

		(Stevey666) 
		
	  - Added some naval weapons into weapon/expl table
	  - Added some ground unit ordnance to explosive table and allowing a wider area to be tracked
	  - Game_mesages and enable_radio_menu options defaulted to false. 
			-Please be advised that the non debug script has these two defaulted to false, so that users don't see that the script is in use nor can they access the test/config radio options.  
			-Set either to true as required.   The notice that the Splash Damage 3.x is running uses game_messsages.
	  - Overhauled the radio options
	  - Added optional cook-off effect - signal flares firing at random throughout the cook-off (see cookoff_flares_enabled). Not sure if I like this one so leaving in as optional
	  - Reduced cargo cook off initial explosion values as they were a little too high
	  - New feature: Napalm. MK77 A4 Skyhawk Napalm and Optional Napalm weapon override - Allows napalm effects, overriding specific weapons set in options is possible too.
	  		- This feature has been adapated from titi69's Napalm script https://www.digitalcombatsimulator.com/en/files/3340469/ , credit to him and the Olympus mod team for the Napalm method

	    (Sniex)
	    
	  - Added weapon types in the weapon/expl
	  - Adjusted some rocket explosive power numbers (+1 or 2)
	  - Adjusted explosive power for anti radar, ship missile, cruise missile and some others
	  - Increased script readability
	  
	    (Kurdes)
	    
	  - Added changed/missing JF17 ordnance to weapons table
	  - Added JF29 mod ordnance to the weapons table
	  
    10 May 2025 (Stevey666) - 3.2
	  - New feature (user request): ground ordnance tracking, this tracks ground artillery etc if in the explosives table, set to false by default.
	  - New feature (user request): option to create additional smoke and cargo cookoff effect for all ground vehicles initially destroyed by your ordnance or the script, set to false by default.
	  - Adjusted blastwave explosion
	  - Changes to debug output, ordering by vehicle distance
	  - Thanks to tae. for the report, adjusted Ural-4320 in vehicle table, had incorrect name so wasn't triggering cook off.
	  - Fixed error popup when using Mig 21's SPRD-99
	  - Added Cargo Cook off / fireball to some static objects i.e crates/barrels
	  - Reworked Giant Explosion tracking - no mission editor trigger needed, just name static unit or unit "GiantExplosionTarget[X]"
	  - Allow for Giant Explosion trigger on damage or on death

    04 April 2025 (Stevey666) - 3.1
	  - Set default cluster munitions option to false, set this to true in the options if you want it
      - Added missing radio commands for Cascade Scaling
	  - Adjust default cascading to 2 (from 1)
	  - Adjusted Ural-4320 to be a tanker and ammo carrier for cargo cookoff
	  - Prevent weapons not in the list from being tracked
	  - Moved some logging behind the debug mode flag
	  - Ordnance Protection, added a max height ordnance protection will snap explosion to ground
	  - Ordnance Protection, fixed enable/disable option
	  - Added Giant Explosion feature
	  - Adjusted some hydra70 values on recom. from ETBSmorgan
	  
	  
    09 March 2025 (Stevey666) - 3.0
      - Added ordinance protection gives a few options - stop the additional larger_explosion that tends to blow up your own bombs if theyre dropped at the same place if its within x m
	  - Additional ordnance protection option that will cause a snap to ground larger_explosion if its within x meters of a recent larger explosion and within x seconds (can set in options)
      - Added vehicle scanning around a weapon to allow for..
	  - Cook offs - you can set vehicles that will cook off i.e ammo trucks, number of explosions, debris explosions, power adjustable
	  - Fuel/Tanker explosion and flames - when a fuel tanker blows it will through up a big flame - adjustable in the scripts
	  - Added section for vehicles for the above
	  - Added radio commands for everything
	  - Added in cluster munitions changes (note: barely tested, its not particularly accurate or that useful at this point so leaving disabled)
	  - Potential bug - testing, stacking too many units together may cause a MIST error if you're using mist
	  
	  - Setting this as 3.0 as I'd like to be responsive to requests, updates etc - creating a new fork to track this
	

    10 Feb 2025 (Stevey666) - 2.0.7
      - Fixed AGM 154/Adjusted weapons
      - Added overall damage scaling 
      - Added modifier for shaped charges (i.e. Mavericks), adjusted weapon list accordingly
      - Adjusted blast radius and damage calculations, created option for dynamic blast radius
      - Adjusted cascading explosions, added additional "cascade_scaling" modifier and cascade explode threshold modifier. Units wont explode on initial impact unless health drops under threshold
      - Added always_cascade_explode option so you can set it to the old ways of making everything in the blast wave go kaboom
      - Added in game radio commands to change the new options ingame without having to reload everything in mission editor to test it out

    12 November 2024 (by JGi | Quéton 1-1)
    - Tweak down radius 100>90 (Thanks Arhibeau)
    - Tweak down some values

    20 January 2024 (by JGi | Quéton 1-1)
    - Added missing weapons to explTable
    - Sort weapons in explTable by type
    - Added aircraft type in log when missing

    03 May 2023 (KERV)
      Correction AGM 154 (https://forum.dcs.world/topic/289290-splash-damage-20-script-make-explosions-better/page/5/#comment-5207760)
  
    06 March 2023 (Kerv)
    - Add some data for new ammunition

    16 April 2022
      spencershepard (GRIMM):
      - Added new/missing weapons to explTable
      - Added new option rocket_multiplier

    31 December 2021
      spencershepard (GRIMM):
      - Added many new weapons
      - Added filter for weapons.shells events
      - Fixed mission weapon message option
      - Changed default for damage_model option
  
    21 December 2021
      spencershepard (GRIMM):
      SPLASH DAMAGE 2.0:
      - Added blast wave effect to add timed and scaled secondary explosions on top of game objects
      - Object geometry within blast wave changes damage intensity
      - Damage boost for structures since they are hard to kill, even if very close to large explosions
      - Increased some rocket values in explTable
      - Missing weapons from explTable will display message to user and log to DCS.log so that we can add what's missing
      - Damage model for ground units that will disable their weapons and ability to move with partial damage before they are killed
      - Added options table to allow easy adjustments before release
      - General refactoring and restructure

    28 October 2020
      FrozenDroid: 
      - Uncommented error logging, actually made it an error log which shows a message box on error.
      - Fixed the too restrictive weapon filter (took out the HE warhead requirement)

    2 October 2020
      FrozenDroid:
      - Added error handling to all event handler and scheduled functions. Lua script errors can no longer bring the server down.
      - Added some extra checks to which weapons to handle, make sure they actually have a warhead (how come S-8KOM's don't have a warhead field...?)

-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=
                            		##### END of Changelog #####
-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=--=-=-=-=-=-]]
