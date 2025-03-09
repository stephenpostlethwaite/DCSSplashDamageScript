# DCS-Scripts
A small collection of scripts for DCS


Drop in scripts to handle IADS and splash damage model changes.

Will update with more informaiton soon.

## IADS tips:

### INSTALLATION:
 Load at mission start in mission editor using Trigger> 4 Mission Start > Do Script File (this file)

 No naming required.
 
 Works on red coalition ground units for now.
 
 SAMs within 80km of an EWR are considered controlled, will only turn on when a blue air unit is in the air within ranges specified at the top of the file
 
 Uncontrolled SAMs will blink on and off
 
 HARMs and other ARMs detected by EWRs and SAMs have a chance of causing defensive behaviour in the SAM sites
 
 TORs remain on
 
### Mission Designer tips:
 Don't mix EWR and SAM sites
 
 Don't mix SAM types


## Splash Damage 2.0:

 -Adds a blast wave effect which adds timed and scaled secondary explosions on top of game objects
 
 -Object geometry within blast wave changes damage intensity
 
 -Additional damage boost for structures since they are hard to kill, even if very close to large explosions.
 
 -Damage model for ground units that will disable their weapons and ability to move with partial damage before they are killed.
 
 -New options table 

 
 If you see a message like "[weapon] is missing from Splash Damage script", please post your DCS.log (C:\Users\you\Saved Games\DCS\Logs) so the missing weapon can be added.
 
 ### INSTALLATION:
 Load at mission start in mission editor using Trigger> 4 Mission Start > Do Script File (script file) 
 
 ![alt text](https://github.com/spencershepard/DCS-Scripts/blob/develop/splash%20damage%202.gif?raw=true)
 

----------------------------------------------------------------------------------------------------------------------------------------------------
