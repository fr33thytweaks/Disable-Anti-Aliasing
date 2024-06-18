# Disable-Anti-Aliasing

## Description
Ability to disable Anti-Aliasing in modern games that support DLSS and/or DLAA.<br>
Use case for when native options to disable Anti-Aliasing are unavailable.<br>

Original guide from [TheHybred](<https://www.reddit.com/r/MotionClarity/comments/1d206jv/disable_forced_antialiasing_with_dlss>).<br>
More in depth DLAA/DLSS modding and information from [emoose](<https://github.com/emoose/DLSSTweaks>).

## How It Works
Replace DLSS files with the developer's version and toggle debug keyboard shortcuts.

## Requirements
DLSS supported game.<br>
DLSS supported graphics card.

## What Is DLSS & DLAA
[NVIDIA](<https://developer.nvidia.com/rtx/streamline#:~:text=NVIDIA%20DLAA%20is%20an%20AI,higher%20levels%20of%20image%20quality.>)<br>
[Wikipedia](<https://en.wikipedia.org/wiki/Deep_learning_super_sampling>)

## Standard Method
Best suited for DLAA on in-game.<br>
Can be used with DLSS (results in non-native resolution).

1. Run "DLSS Indicator.reg"
2. Copy and replace "nvngx_dlss.dll" in game folder
3. Open game and enable DLSS or DLAA
4. Press "Ctrl-Alt-F6" 2x = "JITTER_DEBUG_JITTER" to disable Anti Aliasing
5. Experiment with "Ctrl-Alt-F7" 1x = "Sharpen On/Off" if viable
6. Experiment with DLAA/DLSS sharpen in game graphic options if viable

## Advanced Method
Best suited for DLSS on in-game.<br>
Will be native resolution in all DLSS quality levels.

1. Run "Signature Override.reg"
2. Copy and replace "nvngx_dlss.dll" in game folder
3. Copy "DLSSTweaks.ini" and "nvngx.dll" in game folder
4. Open game and enable DLSS
5. Press "Ctrl-Alt-F6" 2x = "JITTER_DEBUG_JITTER" to disable Anti Aliasing
6. Experiment with "Ctrl-Alt-F7" 1x = "Sharpen On/Off" if viable
7. Experiment with DLAA/DLSS sharpen in game graphic options if viable

## Note
Some game launchers like Battle.net verify files on startup.<br>
It is recommended to open the game launcher first before moving or replacing files.<br>
You may need to copy the files after each time you start the game launcher.

If overlay states "DLSS mode: DLAA", Advanced method is working.<br>
If overlay states "DLSS mode: Current DLSS quality level", only Standard method is working.<br>
Standard method will be the only option if anti cheat is blocking "DLSSTweaks.ini" and "nvngx.dll".

If stuck with Standard method and you are able to change render resolution in game settings or console.<br>
Try render resolution at 1.5 or 150% using dlss at quality to mimic a native resolution.

To turn off the dev overlay text, run "Revert DLSS Indicator.reg" and edit "DLSSTweaks.ini" with the following settings:
- OverrideDlssHud=-1
- DisableDevWatermark=true

## How To Revert
1. Run "Revert DLSS Indicator.reg"
2. Run "Revert Signature Override.reg"
3. Delete "nvngx_dlss.dll", "DLSSTweaks.ini", "nvngx.dll" & "dlsstweaks.log" files in game folder
4. Scan and repair or verify files in game launcher

## Video
add video link here <br>
add video photo here
