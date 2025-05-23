# Splash Damage Script

# Installation
Download the script.
In mission editor have a mission start trigger with the action "DO SCRIPT FILE" and point it to this script.

Please see the wiki for some notes on features

# Release Notes

--[[

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
