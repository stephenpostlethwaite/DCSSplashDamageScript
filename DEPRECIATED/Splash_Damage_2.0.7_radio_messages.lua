--[[
    10 Feb 2025 (Stevey666) - 2.07
      - Fixed AGM 154/Adjusted weapons
      - Added overall damage scaling 
      - Added modifier for shaped charges (i.e. Mavericks), adjusted weapon list accordingly
      - Adjusted blast radius and damage calculations, created option for dynamic blast radius
      - Adjusted cascading explosions, added additional "cascade_scaling" modifier and cascade explode threshold modifier.  Units wont explode on initial impact unless health drops under threshold
	  - Added always_cascade_explode option so you can set it to the old ways of making everything in the blast wave go kaboom
	  - Added in game radio commands to change the new options ingame without having to reload everything in mission editor to test it out

    12 november 2024 (by JGi | Quéton 1-1)
    - Tweak down radius 100>90 (Thanks Arhibeau)
    - Tweak down somes values

    20 january 2024 (by JGi | Quéton 1-1)
    - added missing weapons to explTable
    - Sort weapons in explTable by type
    - added aircraft type in log when missing

  03 mai 2023 (KERV)
      correction AGM 154 (https://forum.dcs.world/topic/289290-splash-damage-20-script-make-explosions-better/page/5/#comment-5207760)
  
  06 mars 2023 (Kerv)
  Add some data for new ammunition

  16 April 2022
      spencershepard (GRIMM):
      - added new/missing weapons to explTable
      - added new option rocket_multiplier

  31 December 2021
      spencershepard (GRIMM):
      -added many new weapons
      -added filter for weapons.shells events
      -fixed mission weapon message option
      -changed default for damage_model option
  
  21 December 2021
      spencershepard (GRIMM):
      SPLASH DAMAGE 2.0:
      -Added blast wave effect to add timed and scaled secondary explosions on top of game objects
      -object geometry within blast wave changes damage intensity
      -damage boost for structures since they are hard to kill, even if very close to large explosions
      -increased some rocket values in explTable
      -missing weapons from explTable will display message to user and log to DCS.log so that we can add what's missing
      -damage model for ground units that will disable their weapons and ability to move with partial damage before they are killed
      -added options table to allow easy adjustments before release
      -general refactoring and restructure

  28 October 2020
      FrozenDroid: 
      - Uncommented error logging, actually made it an error log which shows a message box on error.
      - Fixed the too restrictive weapon filter (took out the HE warhead requirement)

  2 October 2020
      FrozenDroid:
      - Added error handling to all event handler and scheduled functions. Lua script errors can no longer bring the server down.
      - Added some extra checks to which weapons to handle, make sure they actually have a warhead (how come S-8KOM's don't have a warhead field...?)
--]]

----[[ ##### SCRIPT CONFIGURATION ##### ]]----
splash_damage_options = {
    ["game_messages"] = true, --enable some messages on screen
	["debug"] = true,  --enable debugging messages 
    ["weapon_missing_message"] = true, --false disables messages alerting you to weapons missing from the explTable
	
    ["static_damage_boost"] = 2000, --apply extra damage to Unit.Category.STRUCTUREs with wave explosions
    ["wave_explosions"] = true, --secondary explosions on top of game objects, radiating outward from the impact point and scaled based on size of object and distance from weapon impact point
    ["larger_explosions"] = true, --secondary explosions on top of weapon impact points, dictated by the values in the explTable
    ["damage_model"] = true, --allow blast wave to affect ground unit movement and weapons
    ["blast_search_radius"] = 90, --this is the max size of any blast wave radius, since we will only find objects within this zone
    ["cascade_damage_threshold"] = 0.1, --if the calculated blast damage doesn't exeed this value, there will be no secondary explosion damage on the unit.  If this value is too small, the appearance of explosions far outside of an expected radius looks incorrect.
    ["blast_stun"] = false, --not implemented
    ["unit_disabled_health"] = 30, --if health is below this value after our explosions, disable its movement 
    ["unit_cant_fire_health"] = 40, --if health is below this value after our explosions, set ROE to HOLD to simulate damage weapon systems
    ["infantry_cant_fire_health"] = 60,  --if health is below this value after our explosions, set ROE to HOLD to simulate severe injury
    ["rocket_multiplier"] = 1.3, --multiplied by the explTable value for rockets
	
    ["overall_scaling"]             = 1,    --overall scaling for explosive power
	
    ["apply_shaped_charge_effects"] = true, --apply reduction in blastwave etc for shaped charge munitions
	["shaped_charge_multiplier"]    = 0.2,  --multiplier that reduces blast radius and explosion power for shaped charge munitions.
	
	["use_dynamic_blast_radius"]    = true,   --if true, blast radius is calculated from explosion power; if false, blast_search_radius (90) is used
    ["dynamic_blast_radius_modifier"] = 2.5,  --multiplier for the blast radius
	
    ["cascade_scaling"]             = 5,    --multiplier for secondary (cascade) blast damage, 1 damage fades out too soon, 3 damage seems a good balance
    ["cascade_explode_threshold"]   = 90,   --only trigger cascade explosion if the unit's current health is <= this percent of its maximum, setting can help blow nearby jeeps but not tanks
    ["always_cascade_explode"] = false, --switch if you want everything to explode like with the original script
    
	["enable_radio_menu"] = true, --enables the in-game radio menu for modifying settings

        --If you're making modifications to these, in mission editor you'll need to select the file again in the mission start trigger - alteast in my experience)
}
  
local script_enable = 1
refreshRate = 0.1
----[[ ##### End of SCRIPT CONFIGURATION ##### ]]----
  
--Helper function: Trim whitespace.
local function trim(s)
    return s:match("^%s*(.-)%s*$")
end
  
--Weapon Explosive Table:
--Each entry is a table with an "explosive" value and a "shaped_charge" flag.
--(Keys must exactly match the string returned by ordnance:getTypeName().)
explTable = {
    --*** WWII BOMBS ***
    ["British_GP_250LB_Bomb_Mk1"]       = { explosive = 100, shaped_charge = false },           --("250 lb GP Mk.I")
    ["British_GP_250LB_Bomb_Mk4"]       = { explosive = 100, shaped_charge = false },           --("250 lb GP Mk.IV")
    ["British_GP_250LB_Bomb_Mk5"]       = { explosive = 100, shaped_charge = false },           --("250 lb GP Mk.V")
    ["British_GP_500LB_Bomb_Mk1"]       = { explosive = 213, shaped_charge = false },           --("500 lb GP Mk.I")
    ["British_GP_500LB_Bomb_Mk4"]       = { explosive = 213, shaped_charge = false },           --("500 lb GP Mk.IV")
    ["British_GP_500LB_Bomb_Mk4_Short"] = { explosive = 213, shaped_charge = false },           --("500 lb GP Short tail")
    ["British_GP_500LB_Bomb_Mk5"]       = { explosive = 213, shaped_charge = false },           --("500 lb GP Mk.V")
    ["British_MC_250LB_Bomb_Mk1"]       = { explosive = 100, shaped_charge = false },           --("250 lb MC Mk.I")
    ["British_MC_250LB_Bomb_Mk2"]       = { explosive = 100, shaped_charge = false },           --("250 lb MC Mk.II")
    ["British_MC_500LB_Bomb_Mk1_Short"] = { explosive = 213, shaped_charge = false },           --("500 lb MC Short tail")
    ["British_MC_500LB_Bomb_Mk2"]       = { explosive = 213, shaped_charge = false },           --("500 lb MC Mk.II")
    ["British_SAP_250LB_Bomb_Mk5"]      = { explosive = 100, shaped_charge = false },           --("250 lb S.A.P.")
    ["British_SAP_500LB_Bomb_Mk5"]      = { explosive = 213, shaped_charge = false },           --("500 lb S.A.P.")
    ["British_AP_25LBNo1_3INCHNo1"]     = { explosive = 4,   shaped_charge = false },           --("RP-3 25lb AP Mk.I")
    ["British_HE_60LBSAPNo2_3INCHNo1"]  = { explosive = 4,   shaped_charge = false },           --("RP-3 60lb SAP No2 Mk.I")
    ["British_HE_60LBFNo1_3INCHNo1"]    = { explosive = 4,   shaped_charge = false },           --("RP-3 60lb F No1 Mk.I")
  
    ["SC_50"]      = { explosive = 20,  shaped_charge = false },                       --("SC 50 - 50kg GP Bomb LD")
    ["ER_4_SC50"]  = { explosive = 20,  shaped_charge = false },                       --("4 x SC 50 - 50kg GP Bomb LD")
    ["SC_250_T1_L2"]  = { explosive = 100, shaped_charge = false },                    --("SC 250 Type 1 L2 - 250kg GP Bomb LD")
    ["SC_501_SC250"]  = { explosive = 100, shaped_charge = false },                    --("SC 250 Type 3 J - 250kg GP Bomb LD")
    ["Schloss500XIIC1_SC_250_T3_J"] = { explosive = 100, shaped_charge = false },         --("SC 250 Type 3 J - 250kg GP Bomb LD")
    ["SC_501_SC500"] = { explosive = 213, shaped_charge = false },                     --("SC 500 J - 500kg GP Bomb LD")
    ["SC_500_L2"]  = { explosive = 213, shaped_charge = false },                        --("SC 500 L2 - 500kg GP Bomb LD")
    ["SD_250_Stg"] = { explosive = 100, shaped_charge = false },                       --("SD 250 Stg - 250kg GP Bomb LD")
    ["SD_500_A"]   = { explosive = 213, shaped_charge = false },                       --("SD 500 A - 500kg GP Bomb LD")
  
    --*** WWII CBU ***
    --/!\ Use with caution, may explode your aircraft
    ["AB_250_2_SD_2"]   = { explosive = 100, shaped_charge = false },                  --("AB 250-2 - 144 x SD-2, 250kg CBU with HE submunitions")
    ["AB_250_2_SD_10A"] = { explosive = 100, shaped_charge = false },                  --("AB 250-2 - 17 x SD-10A, 250kg CBU with 10kg Frag/HE submunitions")
    ["AB_500_1_SD_10A"] = { explosive = 213, shaped_charge = false },                  --("AB 500-1 - 34 x SD-10A, 500kg CBU with 10kg Frag/HE submunitions")
  
    --*** WWII ROCKETS ***
    ["3xM8_ROCKETS_IN_TUBES"] = { explosive = 4, shaped_charge = false },              --("4.5 inch M8 UnGd Rocket")
    ["WGr21"] = { explosive = 4, shaped_charge = false },              --("Werfer-Granate 21 - 21 cm UnGd air-to-air rocket")
  
    --*** UNGUIDED BOMBS (UGB) ***
    --500lbs or 250Kg bombs initial value : 118, replaced by 100
    ["M_117"]     = { explosive = 201, shaped_charge = false },                        --F-86F, 750lbs
    ["AN_M30A1"]  = { explosive = 45,  shaped_charge = false },                        --A-4E, ("AN-M30A1 - 100lb GP Bomb LD")
    ["AN_M57"]    = { explosive = 100, shaped_charge = false },                        --A-4E, ("AN-M57 - 250lb GP Bomb LD")
    ["AN_M64"]    = { explosive = 121, shaped_charge = false },                        --A-4E | F-86F, 500lbs
    ["AN_M65"]    = { explosive = 400, shaped_charge = false },                        --A-4E, ("AN-M65 - 1000lb GP Bomb LD")
    ["AN_M66"]    = { explosive = 800, shaped_charge = false },                        --("AN-M66 - 2000lb GP Bomb LD")
    ["AN-M66A2"]  = { explosive = 536, shaped_charge = false },                        --A-4E
    ["AN-M81"]    = { explosive = 100, shaped_charge = false },                        --A-4E,
    ["AN-M88"]    = { explosive = 100, shaped_charge = false },                        --A-4E,
  
    ["Mk_81"]     = { explosive = 60,  shaped_charge = false },                        --250lbs
    ["MK-81SE"]   = { explosive = 60,  shaped_charge = false },
    ["Mk_82"]     = { explosive = 100, shaped_charge = false },                       --500lbs
    ["MK_82AIR"]  = { explosive = 100, shaped_charge = false },
    ["MK_82SNAKEYE"] = { explosive = 100, shaped_charge = false },
    ["Mk_83"]     = { explosive = 274, shaped_charge = false },                       --1000lbs
    ["Mk_84"]     = { explosive = 582, shaped_charge = false },                       --2000lbs
  
    ["HEBOMB"]    = { explosive = 40,  shaped_charge = false },                       --Viggen ?
    ["HEBOMBD"]   = { explosive = 40,  shaped_charge = false },                       --Viggen ?
  
    ["SAMP125LD"] = { explosive = 60,  shaped_charge = false },                       --F1, 250lbs
    ["SAMP250LD"] = { explosive = 118, shaped_charge = false },                       --F1, 500lbs
    ["SAMP250HD"] = { explosive = 118, shaped_charge = false },
    ["SAMP400LD"] = { explosive = 274, shaped_charge = false },                       --F1, 1000lbs
    ["SAMP400HD"] = { explosive = 274, shaped_charge = false },
  
    ["BR_250"]    = { explosive = 100, shaped_charge = false },
    ["BR_500"]    = { explosive = 100, shaped_charge = false },
  
    ["FAB_100"]   = { explosive = 45,  shaped_charge = false },
    ["FAB_250"]   = { explosive = 118, shaped_charge = false },
    ["FAB_250M54TU"] = { explosive = 118, shaped_charge = false },
    ["FAB-250-M62"]  = { explosive = 118, shaped_charge = false },
    ["FAB_500"]   = { explosive = 213, shaped_charge = false },
    ["FAB_1500"]  = { explosive = 675, shaped_charge = false },
  
    --*** UNGUIDED BOMBS WITH PENETRATOR / ANTI-RUNWAY ***
    ["Durandal"]  = { explosive = 64,  shaped_charge = false },
    ["BLU107B_DURANDAL"] = { explosive = 64,  shaped_charge = false },
    ["BAP_100"]   = { explosive = 32,  shaped_charge = false },                     --M-2000
    ["BAP-100"]   = { explosive = 32,  shaped_charge = false },                     --M-339A
    ["BAT-120"]   = { explosive = 32,  shaped_charge = false },                     --M-339A
    ["TYPE-200A"] = { explosive = 107, shaped_charge = false },
    ["BetAB_500"] = { explosive = 98,  shaped_charge = false },
	
    ["BetAB_500ShP"] = { explosive = 107, shaped_charge = false },
    
    --*** GUIDED BOMBS (GBU) ***
    ["GBU_10"]    = { explosive = 582, shaped_charge = false },                      --2000lbs
    ["GBU_12"]    = { explosive = 100, shaped_charge = false },                      --500lbs
    ["GBU_16"]    = { explosive = 274, shaped_charge = false },                      --1000lbs
    ["GBU_24"]    = { explosive = 582, shaped_charge = false },                      --2000lbs
    ["KAB_1500Kr"] = { explosive = 675, shaped_charge = false },                      --Su-30 mod
    ["KAB_500Kr"]  = { explosive = 213, shaped_charge = false },                      --Su-25T
    ["KAB_500"]   = { explosive = 213, shaped_charge = false },                       --?
  
    --*** CLUSTER BOMBS (CBU) ***
    --/!\ Use with caution, may explode your aircraft
    --Ammunition dispersion count as a hit, that's why value = 0
    --["CBU_52B"] = 0, --F-5E, explode aircraft
    ["CBU_99"]    = { explosive = 0,   shaped_charge = false },                     --Mk20 Rockeye, various US aircraft
    ["ROCKEYE"]   = { explosive = 0,   shaped_charge = false },                     --Mk20 Rockeye, various US aircraft
    ["BLU_3B_GROUP"] = { explosive = 0,   shaped_charge = false },                   --A-4E
    ["MK77mod0-WPN"] = { explosive = 0,   shaped_charge = false },                   --A-4E
    ["MK77mod1-WPN"] = { explosive = 0,   shaped_charge = false },                   --A-4E
    ["CBU_87"]    = { explosive = 0,   shaped_charge = false },                     --A-10C | F-16CM | F/A-18C
    ["CBU_103"]   = { explosive = 0,   shaped_charge = false },                     --A-10C | F-16CM, CBU-87 with wind correction
    ["CBU_97"]    = { explosive = 0,   shaped_charge = false },                     --A-10C | F-16CM | F/A-18C
    ["CBU_105"]   = { explosive = 0,   shaped_charge = false },                     --A-10C | F-16CM, CBU-97 with wind correction
    ["BELOUGA"]   = { explosive = 0,   shaped_charge = false },                     --M-2000C | F1
    ["BLG66_BELOUGA"] = { explosive = 0,   shaped_charge = false },                 --M-2000C | F1 | MB-339A
    ["BL_755"]    = { explosive = 0,   shaped_charge = false },                     --MB-339A
  
    ["RBK_250"]   = { explosive = 0,   shaped_charge = false },                     --FC3, RBK
    ["RBK_250_275_AO_1SCH"] = { explosive = 0,   shaped_charge = false },             --FC3, RBK
    ["RBK_500"]   = { explosive = 0,   shaped_charge = false },                     --FC3, RBK
    ["RBK_500U"]  = { explosive = 0,   shaped_charge = false },                     --FC3, RBK
    ["RBK_500AO"] = { explosive = 0,   shaped_charge = false },                     --FC3, RBK
    ["RBK_500U_OAB_2_5RT"] = { explosive = 0,   shaped_charge = false },             --FC3, RBK
    --["BKF_AO2_5RT"] = { explosive = 0,   shaped_charge = false }, --FC3, KMGU, explode aircraft
    --["BKF_PTAB2_5KO"] = { explosive = 0,   shaped_charge = false }, --FC3, KMGU, explode aircraft
  
    --*** INS/GPS BOMBS (JDAM) ***
    ["GBU_31"]    = { explosive = 582, shaped_charge = false },                     --F/A-18C, 2000lbs
    ["GBU_31_V_3B"] = { explosive = 582, shaped_charge = false },
    ["GBU_31_V_2B"] = { explosive = 582, shaped_charge = false },
    ["GBU_31_V_4B"] = { explosive = 582, shaped_charge = false },
    ["GBU_32_V_2B"] = { explosive = 202, shaped_charge = false },                     --F/A-18C, 1000lbs
    ["GBU_38"]    = { explosive = 100, shaped_charge = false },                      --F/A-18C, 500lbs
    ["GBU_54_V_1B"] = { explosive = 100, shaped_charge = false },                     --Harrier, 500lbs
  
    --*** GLIDE BOMBS (JSOW) ***
    ["AGM_154A"]  = { explosive = 300,   shaped_charge = false },                      --F-16CM | F/A-18C, Cluster
    ["AGM_154C"]  = { explosive = 305, shaped_charge = false },                      --F-16CM | F/A-18C
    ["AGM_154"]  = { explosive = 305, shaped_charge = false }, --F-16CM | F/A-18C
    ["BK90_MJ1"] = { explosive = 0,   shaped_charge = false }, --Viggen, Mjolnir
    ["BK90_MJ1_MJ2"] = { explosive = 0,   shaped_charge = false }, --Viggen, Mjolnir
    ["BK90_MJ2"] = { explosive = 0,   shaped_charge = false }, --Viggen, Mjolnir
  
    ["LS-6-100"] = { explosive = 45,   shaped_charge = false }, --JF-17
    ["LS-6-250"] = { explosive = 100,   shaped_charge = false }, --JF-17
    ["LS-6-500"] = { explosive = 274,   shaped_charge = false }, --JF-17
    ["GB-6"] = { explosive = 0,   shaped_charge = false }, --JF-17, Cluster
    ["GB-6-HE"] = { explosive = 0,   shaped_charge = false }, --JF-17, Cluster
    ["GB-6-SFW"] = { explosive = 0,   shaped_charge = false }, --JF-17, Cluster
    --*** AIR GROUND MISSILE (AGM) ***
    ["AGM_62"]    = { explosive = 400, shaped_charge = false },                      --F/A-18C, WallEye
    --AGM_65 family: mark as shaped charges.
    ["AGM_65D"]   = { explosive = 38,  shaped_charge = true },                       --Mavericks
    ["AGM_65E"]   = { explosive = 80,  shaped_charge = true },
    ["AGM_65F"]   = { explosive = 80,  shaped_charge = true },
    ["AGM_65G"]   = { explosive = 80,  shaped_charge = true },
    ["AGM_65H"]   = { explosive = 38,  shaped_charge = true },
    ["AGM_65K"]   = { explosive = 80,  shaped_charge = true },
    ["AGM_65L"]   = { explosive = 80,  shaped_charge = true },
    ["AGM_123"]   = { explosive = 274, shaped_charge = false },
    ["AGM_130"]   = { explosive = 582, shaped_charge = false },
    ["AGM_119"]   = { explosive = 176, shaped_charge = false },
    ["AGM_114"]   = { explosive = 10,  shaped_charge = true },                       --AH-64D, HellFire L
    ["AGM_114K"]  = { explosive = 10,  shaped_charge = true },                       --AH-64D, Hellfire K
  
    ["Rb 05A"]    = { explosive = 217, shaped_charge = false },                      --Viggen
    ["RB75"]      = { explosive = 38,  shaped_charge = false },                       --Viggen, Maverick
    ["RB75A"]     = { explosive = 38,  shaped_charge = false },                       --Viggen, Maverick A
    ["RB75B"]     = { explosive = 38,  shaped_charge = false },                       --Viggen, Maverick B
    ["RB75T"]     = { explosive = 80,  shaped_charge = false },                       --Viggen, Maverick T
    ["HOT3_MBDA"] = { explosive = 15,  shaped_charge = false },                       --Gazelle
    ["C-701T"]    = { explosive = 38,  shaped_charge = false },                       --JF-17, Maverick
    ["C-701IR"]   = { explosive = 38,  shaped_charge = false },                       --JF-17, Maverick
  
    ["Vikhr_M"]   = { explosive = 11,  shaped_charge = false },                       --Ka-50 | Su25T
    ["Vikhr_9M127_1"] = { explosive = 11, shaped_charge = false },                   --Ka-50 | Su25T
    ["AT_6"]      = { explosive = 11,  shaped_charge = false },                       --Mi-24P
    ["Ataka_9M120"] = { explosive = 11, shaped_charge = false },                      --Mi-24P
    ["Ataka_9M120F"] = { explosive = 11, shaped_charge = false },                     --Mi-24P
    ["P_9M117"]   = { explosive = 0,   shaped_charge = false },                      --?
    
    ["KH-66_Grom"] = { explosive = 108, shaped_charge = false },                      --MiG-21Bis
    ["X_23"]      = { explosive = 111, shaped_charge = false },
    ["X_23L"]     = { explosive = 111, shaped_charge = false },
    ["X_28"]      = { explosive = 160, shaped_charge = false },
    ["X_25ML"]    = { explosive = 89,  shaped_charge = false },
    ["X_25MR"]    = { explosive = 140, shaped_charge = false },
    ["X_29L"]     = { explosive = 320, shaped_charge = false },
    ["X_29T"]     = { explosive = 320, shaped_charge = false },
    ["X_29TE"]    = { explosive = 320, shaped_charge = false },
  
    --*** ANTI-RADAR MISSILE (ARM) ***
    ["AGM_88C"]   = { explosive = 89,  shaped_charge = false },  --F/A-18C?
    ["AGM_88"]    = { explosive = 89,  shaped_charge = false }, --F-16CM
    ["AGM_122"]   = { explosive = 15,  shaped_charge = false }, --Harrier
    ["LD-10"]     = { explosive = 89,  shaped_charge = false }, --JF-17
    ["AGM_45A"]   = { explosive = 38,  shaped_charge = false }, --A-4E, Shrike       /!\ TO TEST
    ["X_58"]      = { explosive = 140, shaped_charge = false }, --Su-25T, Kh-58
    ["X_25MP"]    = { explosive = 89,  shaped_charge = false }, --Su-25T, Kh-25MP/MPU
  
    --*** ANTI-SHIP MISSILE (ASh) ***
    ["AGM_84D"]   = { explosive = 488, shaped_charge = false }, --F/A-18C, Harpoon
    ["Rb 15F"]    = { explosive = 500, shaped_charge = false }, --Viggen
    ["C-802AK"]   = { explosive = 500, shaped_charge = false }, --JF-17
  
    --*** CRUISE MISSILE ***
    ["CM-802AKG"] = { explosive = 488, shaped_charge = false }, --JF-17       /!\ TO TEST
    ["AGM_84E"]   = { explosive = 488, shaped_charge = false }, --F/A-18C, SLAM       /!\ TO TEST
    ["AGM_84H"]   = { explosive = 488, shaped_charge = false }, --F/A-18C, SLAM-ER       /!\ TO TEST
    ["X_59M"]     = { explosive = 488, shaped_charge = false }, --Su-30 or Mods       /!\ TO TEST
  
    --*** ROCKETS ***
    --HE / HEI : 5
    --AP / HEAT : 8
    ["HYDRA_70M15"] = { explosive = 5,  shaped_charge = false },                     --?
    ["HYDRA_70_MK1"] = { explosive = 5,  shaped_charge = false },                    --UH-1H, HE
    ["HYDRA_70_MK5"] = { explosive = 8,  shaped_charge = false },                    --UH-1H, HEAT
    --HYDRA_70_MK61 : Practice Smoke
    ["HYDRA_70_M151"] = { explosive = 5,  shaped_charge = false },                   --AH-64D, HE
    ["HYDRA_70_M151_M433"] = { explosive = 5,  shaped_charge = false },              --AH-64D, HE
    ["HYDRA_70_M229"] = { explosive = 5,  shaped_charge = false },                   --AH-64D, HE
    --HYDRA_70_M156 : Practice Smoke
    --HYDRA_70_M257 : IL
    --HYDRA_70_M274 : Practice Smoke
    --HYDRA_70_WTU1B : Practice Smoke
    ["FFAR Mk1 HE"]  = { explosive = 5,  shaped_charge = false },                    --F-5E | A-4E, HE
    ["FFAR Mk5 HEAT"] = { explosive = 8,  shaped_charge = false },                    --F-5E | A-4E, HEAT
    --FFAR M156, M257, M274 : Target Marking
    ["HVAR"]         = { explosive = 5,  shaped_charge = false },                    --F-86, HE
    ["Zuni_127"]     = { explosive = 8,  shaped_charge = false },
    ["ARAKM70BHE"]   = { explosive = 5,  shaped_charge = false },                    --Viggen
    ["ARAKM70BAP"]   = { explosive = 8,  shaped_charge = false },                    --Viggen
    ["SNEB_TYPE251_F1B"] = { explosive = 4,  shaped_charge = false },
    ["SNEB_TYPE252_F1B"] = { explosive = 4,  shaped_charge = false },
    ["SNEB_TYPE253_F1B"] = { explosive = 5,  shaped_charge = false },
    ["SNEB_TYPE256_F1B"] = { explosive = 6,  shaped_charge = false },
    ["SNEB_TYPE257_F1B"] = { explosive = 8,  shaped_charge = false },
    ["SNEB_TYPE251_F4B"] = { explosive = 4,  shaped_charge = false },
    ["SNEB_TYPE252_F4B"] = { explosive = 4,  shaped_charge = false },
    ["SNEB_TYPE253_F4B"] = { explosive = 5,  shaped_charge = false },
    ["SNEB_TYPE256_F4B"] = { explosive = 6,  shaped_charge = false },
    ["SNEB_TYPE257_F4B"] = { explosive = 8,  shaped_charge = false },
    ["SNEB_TYPE251_H1"] = { explosive = 4,  shaped_charge = false },
    ["SNEB_TYPE252_H1"] = { explosive = 4,  shaped_charge = false },
    ["SNEB_TYPE253_H1"] = { explosive = 5,  shaped_charge = false },
    ["SNEB_TYPE256_H1"] = { explosive = 6,  shaped_charge = false },
    ["SNEB_TYPE257_H1"] = { explosive = 8,  shaped_charge = false },
    ["MATRA_F4_SNEBT251"] = { explosive = 8,  shaped_charge = false },              --F1
    ["MATRA_F4_SNEBT253"] = { explosive = 8,  shaped_charge = false },
    ["MATRA_F4_SNEBT256"] = { explosive = 8,  shaped_charge = false },
    ["MATRA_F1_SNEBT253"] = { explosive = 8,  shaped_charge = false },
    ["MATRA_F1_SNEBT256"] = { explosive = 8,  shaped_charge = false },
    ["TELSON8_SNEBT251"] = { explosive = 4,  shaped_charge = false },               --Gazelle, HE
    ["TELSON8_SNEBT253"] = { explosive = 8,  shaped_charge = false },               --Gazelle, HEAT
    ["TELSON8_SNEBT256"] = { explosive = 4,  shaped_charge = false },               --Gazelle, HE/FRAG
    ["TELSON8_SNEBT257"] = { explosive = 6,  shaped_charge = false },               --Gazelle, HE/FRAG lg
    ["ARF8M3API"] = { explosive = 8,  shaped_charge = false },                      --MB-339A, API
    ["UG_90MM"]   = { explosive = 8,  shaped_charge = false },                      --JF-17, HEAT
    ["S-24A"]     = { explosive = 24, shaped_charge = false },
    --["S-24B"]  = { explosive = 123, shaped_charge = false },
    ["S-25OF"]    = { explosive = 194, shaped_charge = false },
    ["S-25OFM"]   = { explosive = 150, shaped_charge = false },
    ["S-25O"]     = { explosive = 150, shaped_charge = false },
    ["S-25-O"]    = { explosive = 150, shaped_charge = false },
    ["S_25L"]     = { explosive = 190, shaped_charge = false },
    ["S-5M"]      = { explosive = 1,   shaped_charge = false },
    ["C_5"]       = { explosive = 8,   shaped_charge = false },                      --Su-25T, S-5
    ["C5"]        = { explosive = 5,   shaped_charge = false },                      --MiG-19P, S-5
    ["C_8"]       = { explosive = 4,   shaped_charge = false },
    ["C_8OFP2"]   = { explosive = 3,   shaped_charge = false },
    ["C_13"]      = { explosive = 21,  shaped_charge = false },
    ["C_24"]      = { explosive = 123, shaped_charge = false },
    ["C_25"]      = { explosive = 151, shaped_charge = false },
  
    --*** LASER ROCKETS ***
    ["AGR_20"]    = { explosive = 8,  shaped_charge = false }, --?        /!\ TO TEST
    ["AGR_20A"]   = { explosive = 8,  shaped_charge = false }, --?        /!\ TO TEST
    ["AGR_20_M282"] = { explosive = 8,  shaped_charge = false }, --A10C, APKWS        /!\ TO TEST
    ["Hydra_70_M282_MPP"] = { explosive = 8,  shaped_charge = false }, --?        /!\ TO TEST
    ["BRM-1_90MM"] = { explosive = 8,  shaped_charge = false }, --JF-17
}
  
----[[ ##### HELPER/UTILITY FUNCTIONS ##### ]]----
  
local function tableHasKey(table,key)
    return table[key] ~= nil
end
  
local function debugMsg(str)
    if splash_damage_options.debug == true then
        debugCounter = (debugCounter or 0) + 1
        local uniqueStr = str .. " [" .. timer.getTime() .. " - " .. debugCounter .. "]"
        trigger.action.outText(uniqueStr , 5)
        env.info("DEBUG: " .. uniqueStr)
    end
end
  
local function gameMsg(str)
    if splash_damage_options.game_messages == true then
        trigger.action.outText(str , 5)
    end
end
  
local function getDistance(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1-x2)
    local dZ = math.abs(z1-z2)
    local distance = math.sqrt(dX*dX + dZ*dZ)
    return distance
end
  
local function getDistance3D(point1, point2)
    local x1 = point1.x
    local y1 = point1.y
    local z1 = point1.z
    local x2 = point2.x
    local y2 = point2.y
    local z2 = point2.z
    local dX = math.abs(x1-x2)
    local dY = math.abs(y1-y2)
    local dZ = math.abs(z1-z2)
    local distance = math.sqrt(dX*dX + dZ*dZ + dY*dY)
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
  
----[[ ##### End of HELPER/UTILITY FUNCTIONS ##### ]]----
  
  
WpnHandler = {}
tracked_weapons = {}
  
--retrieve the explosive value and shaped charge flag for a given munition.
function getWeaponExplosive(name)
    local weaponData = explTable[name]
    if weaponData then
        return weaponData.explosive, weaponData.shaped_charge
    else
        return 0, false
    end
end
  
function track_wpns()
    for wpn_id_, wpnData in pairs(tracked_weapons) do   
      if wpnData.wpn:isExist() then  --just update speed, position and direction.
        wpnData.pos = wpnData.wpn:getPosition().p
        wpnData.dir = wpnData.wpn:getPosition().x
        wpnData.speed = wpnData.wpn:getVelocity()
      else --wpn no longer exists, must be dead.
          local ip = land.getIP(wpnData.pos, wpnData.dir, lookahead(wpnData.speed))  --terrain intersection point with weapon's nose.
          local impactPoint
          if not ip then --use last calculated IP
              impactPoint = wpnData.pos
          else --use intersection point
              impactPoint = ip
          end
          local base_explosive, isShapedCharge = getWeaponExplosive(wpnData.name)
          base_explosive = base_explosive * splash_damage_options.overall_scaling
          if splash_damage_options.rocket_multiplier and splash_damage_options.rocket_multiplier > 0 and wpnData.cat == Weapon.Category.ROCKET then
              base_explosive = base_explosive * splash_damage_options.rocket_multiplier
          end
  
          --use only the shaped_charge flag from explTable if toggle
          local shapedCharge = splash_damage_options.apply_shaped_charge_effects and isShapedCharge
  
          --adjust the explosion power if this is a shaped charge
          local explosionPower = base_explosive
          if shapedCharge then
              explosionPower = explosionPower * splash_damage_options.shaped_charge_multiplier
          end
  
          if splash_damage_options.larger_explosions then
              trigger.action.explosion(impactPoint, explosionPower)
          end
  
          blastWave(impactPoint, splash_damage_options.blast_search_radius, wpnData.ordnance, explosionPower, shapedCharge)
          tracked_weapons[wpn_id_] = nil
      end
    end
end
  
function onWpnEvent(event)
    if event.id == world.event.S_EVENT_SHOT then
        if event.weapon then
            local ordnance = event.weapon
            local typeName = trim(ordnance:getTypeName())
            env.info("Weapon fired: [" .. typeName .. "]")
            debugMsg("Weapon fired: [" .. typeName .. "]")
  
            if string.find(typeName, "weapons.shells") then 
                debugMsg("Event shot, but not tracking: " .. typeName)
                env.info("SplashDamage: event shot, but not tracking: " .. typeName .. " (" .. event.initiator:getTypeName() .. ")")
                return  --we wont track these types of weapons, so exit here
            end
  
            if not explTable[typeName] then
                env.info("SplashDamage: " .. typeName .. " missing from script (" .. event.initiator:getTypeName() .. ")")
                if splash_damage_options.weapon_missing_message == true then
                    trigger.action.outText("SplashDamage: " .. typeName .. " missing from script (" .. event.initiator:getTypeName() .. ")", 3)
                    if mist and mist.utils and mist.utils.tableShow then
                        local success, desc = pcall(mist.utils.tableShow, ordnance:getDesc())
                        if success then
                            debugMsg("desc for [" .. typeName .. "]: " .. desc)
                        else
                            debugMsg("Could not retrieve description for [" .. typeName .. "]. Object may no longer exist.")
                        end
                    end
                    env.info("Current keys in explTable:")
                    for k, v in pairs(explTable) do
                        env.info("Key: [" .. k .. "]")
                    end
                end
            end
  
            if (ordnance:getDesc().category ~= 0) and event.initiator then
                if ordnance:getDesc().category == 1 then
                    if (ordnance:getDesc().MissileCategory ~= 1 and ordnance:getDesc().MissileCategory ~= 2) then
                        tracked_weapons[event.weapon.id_] = { wpn = ordnance, init = event.initiator:getName(), pos = ordnance:getPoint(), dir = ordnance:getPosition().x, name = typeName, speed = ordnance:getVelocity(), cat = ordnance:getCategory() }
                    end
                else
                    tracked_weapons[event.weapon.id_] = { wpn = ordnance, init = event.initiator:getName(), pos = ordnance:getPoint(), dir = ordnance:getPosition().x, name = typeName, speed = ordnance:getVelocity(), cat = ordnance:getCategory() }
                end
            end
        end
    end
end
  
local function protectedCall(...)
    local status, retval = pcall(...)
    if not status then
        env.warning("Splash damage script error... gracefully caught! " .. retval, true)
    end
end
  
function WpnHandler:onEvent(event)
    protectedCall(onWpnEvent, event)
end
  
function explodeObject(args)
    local point = args[1]
    local distance = args[2]
    local power = args[3]
    trigger.action.explosion(point, power)
end
  
--if shaped charge is true, reduce the blast radius. if use_dynamic_blast_radius is true calculate the blast radius from power. only schedule a cascade explosion if the object's health is less than or equal to cascade_explode_threshold
function blastWave(_point, _radius, weapon, power, isShapedCharge)
    if isShapedCharge then
        _radius = _radius * splash_damage_options.shaped_charge_multiplier  --Use the configured multiplier for shaped charges.
    end
    --calculate the blast radius dynamically from explosion power
    if splash_damage_options.use_dynamic_blast_radius then
        local dynamicRadius = math.pow(power, 1/3) * 5 * splash_damage_options.dynamic_blast_radius_modifier
        if isShapedCharge then
            _radius = dynamicRadius * splash_damage_options.shaped_charge_multiplier
        else
            _radius = dynamicRadius
        end
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
        if foundObject:getDesc().category == Unit.Category.GROUND_UNIT then --if ground unit
            if splash_damage_options.blast_stun == true then
                --suppressUnit(foundObject, 2, weapon)
            end
        end
        if splash_damage_options.wave_explosions then
            local obj = foundObject
            local obj_location = obj:getPoint()
            local dist = getDistance(_point, obj_location)
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
                local scaled_power_factor = 0.006 * power + 1 --this could be reduced into the calc on the next line
                local intensity = (power * scaled_power_factor) / (4 * math.pi * surface_distance^2)
                local surface_area = _length * height --Ideally we should roughly calculate the surface area facing the blast point, but we'll just find the largest side of the object for now
                local damage_for_surface = intensity * surface_area
                if damage_for_surface > splash_damage_options.cascade_damage_threshold then
                    local explosion_size = damage_for_surface
                    if obj:getDesc().category == Unit.Category.STRUCTURE then
                              explosion_size = intensity * splash_damage_options.static_damage_boost --apply an extra damage boost for static objects. should we factor in surface_area?
                    end
                    if explosion_size > power then explosion_size = power end
                    local triggerExplosion = false
                    if splash_damage_options.always_cascade_explode then
                        triggerExplosion = true
                    else
                        if obj:getDesc().life then
                            local healthPercent = (obj:getLife() / obj:getDesc().life) * 100
                            if healthPercent <= splash_damage_options.cascade_explode_threshold then
                                triggerExplosion = true
                            end
                        else
                            triggerExplosion = true
                        end
                        if not triggerExplosion and obj:getDesc().category == Unit.Category.GROUND_UNIT then
                            local health = obj:getLife() or 0
                            if health <= 0 then
                                triggerExplosion = true
                            end
                        end
                    end
                    if triggerExplosion then
                        timer.scheduleFunction(explodeObject, {obj_location, dist, explosion_size * splash_damage_options.cascade_scaling}, timer.getTime() + timing)
                    end
                end
            end
        end
        return true
    end
  
    world.searchObjects(Object.Category.UNIT, volS, ifFound)
    world.searchObjects(Object.Category.STATIC, volS, ifFound)
    world.searchObjects(Object.Category.SCENERY, volS, ifFound)
    world.searchObjects(Object.Category.CARGO, volS, ifFound)
    if splash_damage_options.damage_model then
        timer.scheduleFunction(modelUnitDamage, foundUnits, timer.getTime() + 1.5)
    end
end
  
--for ground units: disable weapons or movement based on health thresholds.
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
                    gameMsg(unit:getTypeName() .. " weapons disabled")
                end
                if health <= splash_damage_options.unit_disabled_health and health > 0 then
                    unit:getController():setTask({id = 'Hold', params = {}})
                    unit:getController():setOnOff(false)
                    gameMsg(unit:getTypeName() .. " disabled")
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

    local newValue = math.max(0, splash_damage_options[setting] + increment) --Add to existing value, not reset

    --debug print to confirm value updates
    env.info("Updating " .. setting .. " from " .. tostring(splash_damage_options[setting]) .. " to " .. tostring(newValue))

    splash_damage_options[setting] = newValue
    trigger.action.outText("Updated " .. setting .. " to: " .. tostring(splash_damage_options[setting]), 5)
end



function toggleSplashDamageSetting(setting)
    splash_damage_options[setting] = not splash_damage_options[setting]
    trigger.action.outText("Toggled " .. setting .. " to: " .. tostring(splash_damage_options[setting]), 5)

    --toggling the radio menu, remove or re-add
    if setting == "enable_radio_menu" then
        if splash_damage_options.enable_radio_menu then
            addSplashDamageMenu() --Re-add the menu
        else
            missionCommands.removeItem(splash_damage_menu)
            splash_damage_menu = nil
        end
    end
end



function addValueAdjustmentCommands(menu, setting)
    missionCommands.addCommand("+0.1", menu, updateSplashDamageSetting, setting, 0.1)
    missionCommands.addCommand("+1", menu, updateSplashDamageSetting, setting, 1)
    missionCommands.addCommand("+10", menu, updateSplashDamageSetting, setting, 10)
    missionCommands.addCommand("+100", menu, updateSplashDamageSetting, setting, 100)

    missionCommands.addCommand("-0.1", menu, updateSplashDamageSetting, setting, -0.1)
    missionCommands.addCommand("-1", menu, updateSplashDamageSetting, setting, -1)
    missionCommands.addCommand("-10", menu, updateSplashDamageSetting, setting, -10)
    missionCommands.addCommand("-100", menu, updateSplashDamageSetting, setting, -100)
end



function exitSplashDamageMenu()
    if splash_damage_menu then
        missionCommands.removeItem(splash_damage_menu)
        splash_damage_menu = nil
        --trigger.action.outText("Splash Damage menu closed. Use 'Toggle Radio Menu' to reopen.", 5)
    end
end


function addSplashDamageMenu()
    if not splash_damage_options.enable_radio_menu then return end

    if splash_damage_menu then
        missionCommands.removeItem(splash_damage_menu) --ensure no duplicates
    end

    splash_damage_menu = missionCommands.addSubMenu("Splash Damage Settings")

    --Overall Scaling
    local overallMenu = missionCommands.addSubMenu("Overall Scaling", splash_damage_menu)
    addValueAdjustmentCommands(overallMenu, "overall_scaling", 0.1, 0.5, 1, 10, 100)

    --Shaped Charge Settings
    missionCommands.addCommand("Toggle Shaped Charges", splash_damage_menu, toggleSplashDamageSetting, "apply_shaped_charge_effects")
    local shapedMenu = missionCommands.addSubMenu("Shaped Charge Multiplier", splash_damage_menu)
    addValueAdjustmentCommands(shapedMenu, "shaped_charge_multiplier", 0.1, 0.5, 1, 10, 100)

    --Blast Radius
    missionCommands.addCommand("Toggle Dynamic Blast Radius", splash_damage_menu, toggleSplashDamageSetting, "use_dynamic_blast_radius")
    local blastRadiusMenu = missionCommands.addSubMenu("Blast Radius Modifier", splash_damage_menu)
    addValueAdjustmentCommands(blastRadiusMenu, "dynamic_blast_radius_modifier", 0.1, 0.5, 1, 10, 100)

    --Cascade Explosions
    local cascadeMenu = missionCommands.addSubMenu("Cascade Scaling", splash_damage_menu)
    addValueAdjustmentCommands(cascadeMenu, "cascade_scaling", 0.1, 0.5, 1, 10, 100)

    local thresholdMenu = missionCommands.addSubMenu("Cascade Explode Threshold", splash_damage_menu)
    addValueAdjustmentCommands(thresholdMenu, "cascade_explode_threshold", 0.1, 0.5, 1, 10, 100)
    missionCommands.addCommand("Toggle Always Cascade Explode", splash_damage_menu, toggleSplashDamageSetting, "always_cascade_explode")

    --Toggle Radio Menu
    missionCommands.addCommand("Toggle Radio Menu On/Off", splash_damage_menu, toggleSplashDamageSetting, "enable_radio_menu")
end




  
if (script_enable == 1) then
    gameMsg("SPLASH DAMAGE 2.0.7 SCRIPT RUNNING")
    env.info("SPLASH DAMAGE 2.0.7 SCRIPT RUNNING")

    timer.scheduleFunction(function()
        protectedCall(track_wpns)
        return timer.getTime() + refreshRate
    end, {}, timer.getTime() + refreshRate)

    world.addEventHandler(WpnHandler)

    --menu is created at startup
    addSplashDamageMenu()
end
