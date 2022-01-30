# FS22_ProductionInspector

<p align="left">
  <img src="https://github.com/jtsage/FS22_ProductionInspector/raw/main/modIcon.png">
</p>

First I did the vehicle one.  Then I thought it might be nice to have productions on screen too.

## Note about the ZIP in the repo

That ZIP file, while the ?working? mod, is usually my test version.  It's updated multiple times per
version string, so be aware if you download from there, instead of the releases page, you might be
unknowingly using an old version.  For "official" releases, please use the release link to the right.

## Multiplayer

No idea.  I left the flag on for now, but I can't imagine it will work flawlessly.

## Features

* Display all (enterable) vehicles or just those with the motor running
* Show speed for vehicles
* Show is the vehicle is AI or user controlled
* Show fill level of the vehicle

## Default Input Bindings

* `Left Ctrl` + `Left Alt` + `Num Pad 9` : Reload configuration file from disk

## Options

All options are set via a xml file your savegame folder - simpleInspector.xml

Most view options can be set in the in-game settings menu (scroll down)

### displayMode (configurable in the game settings menu)

* __1__ - Top left, under the input help display (auto height under key bindings, if active). Not compatible with FS22_InfoMessageHUD (they overlap).  Hidden if large map and key bindings are visible together.
* __2__ - Top right, under the clock.  Not compatible with FS22_EnhancedVehicle new damage / fuel displays
* __3__ - Bottom left, over the map (if shown). Hidden if large map and key bindings are visible together.
* __4__ - Bottom right, over the speedometer.  Special logic added for FS22_EnhancedVehicle HUD (but not the old style damage / fuel)
* __5__ - Custom placement.  Set X/Y origin point in settings XML file as well.

### in-game configurable

* __isEnabledVisible__ - Show / Hide the HUD
* __isEnabledShowInputs__ - Show Input levels
* __isEnabledOnlyOwned__ - Show only owned production points
* __isEnabledShowInactivePoint__ - Show inactive production points
* __isEnabledShowInactiveProd__ - Show inactive production lines
* __isEnabledShowPercent__ - Show fill percentages
* __isEnabledShowInputs__ - Show inputs
* __isEnabledShowOutputs__ - Show outputs
* __isEnabledShowEmptyOutput__ - Show outputs when empty

### colors

Fill type levels are color coded from empty (green) to full (red) unless it is a consumable in a consuming vehicle, in which case the scale is flipped.  There is a color blind mode available (use the game setting).  All other colors are defined with a red, green, blue, and alpha component

* __colorPointOwned__ - Color for owned production points
* __colorPointNotOwned__ - Color for not owned production points
* __colorProdName__ - Color for production line name
* __colorStatus__ - Color for production line status
* __colorFillType__ - Color for fill type names
* __colorCaption__ - Color for captions (Input: Output: Productions:)
* __colorSep__ - Color for seperator
* __colorEmpty__ - Color for empty input / output / production lines

### text

* __setStringTextIndent__ - text for indentation of production lines, default "    " (4 spaces)
* __setStringTextSep__ - text for separators, default " | "
* __setValueTextMarginX__ - text margin height, default "15"
* __setValueTextMarginY__ - text margin width, default "10"
* __setValueTextSize__ - text size, default "12"

### dev, debug and extras

* __setValueTimerFrequency__ - timer update frequency. We probably don't need to query every vehicle on every tick for performance reasons
* __debugMode__ - show debug output.  Mostly garbage.

## Sample

<p align="center">
  <img width="650" src="https://github.com/jtsage/FS22_ProductionInspector/raw/main/readme_sample.png">
</p>
