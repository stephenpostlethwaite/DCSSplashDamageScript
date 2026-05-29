# Splash Damage Script

# Installation
Download the script.
In mission editor have a mission start trigger with the action "DO SCRIPT FILE" and point it to this script.

Please see the wiki for some notes on features

# Release Notes

--[[
    27th May 2026 3.4.5
        (Stevey666)
        Fixed faulty CBU_Bomblet_Hit_Explosion and severely reduced damage from it as a default config value
        Added small performance improvement to continuous  napalm damage  
        Default continuous  napalm damage config to false as it can cause performance issues on larger maps with a lot of napalm explosions, but it can be enabled in the config for those who want it.
        Added some performance improvements - Thanks to RedactedCallSign
            -AGL - Above ground level height limit before pre-scanning, set to 1000m by default - will help reduce tracking all the way down from a 20k bomb drop for example
                -This is for pre-scanning which is used for cargo cookoff effects
            -Log event setting debugging variable moved as to not occur every time
            -Adding pruning to recent explosion table
            -Reworking closest unit/static searches
			
    17th May 2026 3.4.4
		(Stevey666)
        Brought in RedactedCallSign's changes for Wave Explosions - Thank you RedactedCallSign
        Added Continous Napalm Damage - Damage will hit every x seconds until the napalm timer runs out
        Fixed Napalm damage not applying if phosphor was disabled
        Added in a number of new weapons - Thank you to Retnek, Sniex
        Adjusted a number of explosive values - Thank you to Sniex
        Added BIN 200 to weapons list and default napalm - Thank you to Stackup

    4th July 2025 - 3.4

		(Stevey666) 
		
	  - Added in optional kill feed feature, this will try to display kills from DCS engine and kills from the additional explosions by checking pre/post scans of the explosion area
			    --SPLASH KILL FEED WORKS IN MP ONLY (you can host your local SP mission as MP if you want to see it)
	  - Added in Lekas Foothold Integration to allow splash kills to count towards the points, killfeed is required to be enabled for this
	  - Added AGM_45B to expl table
	  - Added instant phosphor/signal flares option to cook off events
	  - Added in missing JF17/JAS39 weapons as per Kurdes
	  - Added killfeed to napalm and cluster features.  Note, it may not support all features in this script i.e ied explosions but should work with splashdamage by dropping bombs, the new CBU cluster feature and napalm.
	  - New Feature: A-10 Murder Mode, Named Unit Murder Mode (disabled by default) 
			- adds a configurable sized explosion to every hit event with the a10 or the named unit with the name MurderMode in it as an initiator
	  - New Feature: Trophy APS System (disabled by default)
			-The script tracks weapons heading towards a TrophyAPS vehicle, triggers a small explosion by the unit to mimic the Trophy system and triggers a larger explosion at the co-ords of the incoming weapon.   The script mimics there being a Trophy system on the front right and back left of the vehicle, with each launcher having 4 rounds.
			-It contains 2 methods of enabling, either the vehicle has TrophyAPS in its name or you put the unit type into the AllUnitType table. By default, only the name method is enabled, both can be enabled at the same time as below:
	  - New Feature: Vehicle IEDs. (disabled by default)  If a unit is contains VehicleIEDTarget (or other names as set in the config) it will trigger a large configurable explosion
	  - New Feature: Tactical Explosion, similar to the IED effect but a little bigger and has the ability to be assigned to a weapon in a table or as an override
	  - New Feature: Critical Component.  % chance on a hit event of triggering an explosion at unit level
	  - New Feature: Ground Unit Explosion On Death. 
			- If a vehicle is flaming it takes time to pop, this will trigger an explosion with a %chance when its begins to flame (when it does not "exist" but has not triggerd a killed/dead event)
			- There's a % chance settable
			- You can also trigger this to happen if the unit has "GUED" in its name even if chance is set to 0
	  - New Feature: CBU Bomblet Hit Spread - On a Hit event from a cluster bomb, it will scan the local area for nearby vehicles and trigger an additional explosion
			- This features aims to help wipe out areas, but it works by scanning 20 meters radius (adjustable) for any vehicles nearby the hit vehicle and then 20m (adjustable) from those vehicles
			- Max of 1 additional explosion will spawn on the vehicles. Not enabled for CBU_97/CBU_105 due to them already being effective.
			- The spread mechanic could miss vehicles in the area still if one doesnt get hit, or theyre at opposite sides of the visible area and not within 20m (adjustable)
			- There is % chance to hit per unit found in the area, % chance for that hit to be indirect, and armour damage modifiers
	  - New Feature: Strobe Marker - generates a tiny explosion above a unit, no smoke but sound + light appears - can be used as a marker for planes
			- Generates on an active and living unit with "Strobe" in the name
			- Good: Visible to eye/FLIR(TV mode)
			- Not good: Not visible in IR, audible explosions if you're close to the unit
	  - New Feature: All Unit Cook/off smoke chances and advanced sequences
			- It's possible to assign a % chance to allunits having smoke/cookoffs
			- Advanced sequences allow for having multiple smoke/fire sizes of multiple lengths of time - and have smoke for example indefinitely burn
	  - New trigger for cookoff - Cookoff with the allunits settings can be enabled for specific units by the having "CargoCookoffTarget" in the name
	  - Reworked how cookoff works, cookoffs will now follow a moving vehicle as it travels instead of just going off where it was.  Flames/smoke will trigger when the vehicle stops.
			- You can have a chance of cookoff, smoke with a cookoff and also a chance of smoke only
			- Added chance options to the flares for cookoffs also
	  - Effects (i.e cookoff) no longer only bound by damage from tracked weapons.  Gun cannon kills will now count!  May time until the unit pops before it triggers a cookoff
	  - Giant explosion effects now tracked on events instead of checking the unit every second
	  - Jogaredi's suggestion added - ["only_players_weapons"] = true, --track only weapons launch by players, this will be defaulted to false
	  - Due to ED boosting damage values for MK82s and a few others, added the ability to skip larger_explosion and damage_model by having a specific entry in the explosive table
			- Example below, you would need to add this to each weapon that you need this for (or I can do it in the base script if multiple people think its a good idea)
			- ["Mk_82"] = { explosive = 100, Skip_larger_explosions = true, Skip_damage_model = true },
			
	  --3.4.2 
	  	- Adjusted Lekas Foothold Integration
		- Added flak units to ground ord tracking with 0 extra damage for night time light bursts]
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
--]]

----------------------------------------------------------------------------------------------------------------------------------------------------
