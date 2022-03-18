# FS22_ProductionInspector

![GitHub release (latest by date)](https://img.shields.io/github/v/release/jtsage/FS22_ProductionInspector) ![GitHub all releases](https://img.shields.io/github/downloads/jtsage/FS22_ProductionInspector/total)

<p align="left">
  <img src="https://github.com/jtsage/FS22_ProductionInspector/raw/main/modIcon.png">
</p>

First I did the vehicle one.  Then I thought it might be nice to have productions on screen too.  Then there was an animal one, but it was too much so - BIG NEWS:

ProductionInspector now includes AnimalInspector and the conceived, but never released SiloInspector

## Note about the ZIP in the repo

That ZIP file, while the ?working? mod, is usually my test version.  It's updated multiple times per
version string, so be aware if you download from there, instead of the releases page, you might be
unknowingly using an old version.  For "official" releases, please use the release link to the right.

## Multiplayer

No idea.  I left the flag on for now, but I can't imagine it will work flawlessly.

## Features

* Show input materials and their fill levels for production facilities
* Show output products and their fill levels for production facilities
* Show production lines and their status in production facilities
* Show number of animals and space left
* Show food levels (total and individual)
* Show output products and their fill levels
* Show animal health average, breeding average, and immature animal percentage
* Show silo fill percentage, and what is in it.
* Add an underscore to a production point, animal pen, or silo name to hide it from the HUD (_)
* HUD elements can be shown, hidden and positioned individually.  When in the same position, they will stack.

## Default Input Bindings

* `Left Ctrl` + `Left Alt` + `Num Pad 8` : Reload configuration file from disk
* `Left Alt` + `Num Pad 8` : Toggle productions display on and off
* `Left Alt` + `Num Pad 7` : Toggle animal pens display on and off
* `Left Alt` + `Num Pad 6` : Toggle silos display on and off

## Options

All options are set via a xml file in `modSettings/FS22_ProductionInspector/savegame##/productionInspector.xml`

Most view options can be set in the in-game settings menu (scroll down)

### displayMode (configurable in the game settings menu)

* __1__ - Top left, under the input help display (auto height under key bindings, if active). Not compatible with FS22_InfoMessageHUD (they overlap).  Hidden if large map and key bindings are visible together.
* __2__ - Top right, under the clock.  Not compatible with FS22_EnhancedVehicle new damage / fuel displays
* __3__ - Bottom left, over the map (if shown). Hidden if large map and key bindings are visible together.
* __4__ - Bottom right, over the speedometer.  Special logic added for FS22_EnhancedVehicle HUD (but not the old style damage / fuel)
* __5__ - Custom placement.  Set X/Y origin point in settings XML file as well.

### in-game configurable


* __isEnabledProdVisible__ - Productions HUD visibility
* __isEnabledAnimVisible__ - Animals HUD visibility
* __isEnabledSiloVisible__ - Silo HUD visiblity
* __isEnabledForceProdJustify__ - Force justification, productions (1 - no, 2 - left, 3 - right )
* __isEnabledForceAnimJustify__ - Force justification, animals (1 - no, 2 - left, 3 - right )
* __isEnabledForceSiloJustify__ - Force justification, silos (1 - no, 2 - left, 3 - right )
* __isEnabledProdOnlyOwned__ - Only owned productions visible
* __isEnabledProdInactivePoint__ - Inactive productions visible
* __isEnabledProdInactiveProd__ - Inactive products visible
* __isEnabledProdOutPercent__ - Production output percentages
* __isEnabledProdOutFillLevel__ - Production output raw fill levels
* __isEnabledProdInPercent__ - Production input percentages
* __isEnabledProdInFillLevel__ - Production input raw fill levels
* __isEnabledProdInputs__ - Production input visibility
* __isEnabledProdOutputs__ - Production output visibility
* __isEnabledProdEmptyOutput__ - Productions show empty outputs
* __isEnabledProdEmptyInput__ - Productions show empty inputs
* __isEnabledProdShortEmptyOut__ - Productions show empty inputs as "--" instead of 0 (0%)
* __isEnabledProdOutputMode__ - Productions show output mode
* __isEnabledProdMax__ - Maximum number of productions to show
* __isEnabledAnimCount__ - Animal counts
* __isEnabledAnimFood__ - Animal food percentage
* __isEnabledAnimFoodTypes__ - Animal food types
* __isEnabledAnimProductivity__ - Animal productivity
* __isEnabledAnimReproduction__ - Animal reproduction percentage
* __isEnabledAnimPuberty__ - Animals below breeding age percentage
* __isEnabledAnimHealth__ - Animal average health
* __isEnabledAnimOutputs__ - Animal output products
* __isEnabledAnimMax__ - Maximum number of animal pens to show
* __isEnabledSiloMax__ - Maximum number of silos to show

### colors

Fill type levels are color coded from empty (green) to full (red) unless it is a consumable in a consuming vehicle, in which case the scale is flipped.  There is a color blind mode available (use the game setting).  All other colors are defined with a red, green, blue, and alpha component

* __colorPointOwned__ - Color for owned production points
* __colorPointNotOwned__ - Color for not owned production points
* __colorProdName__ - Color for production line name
* __colorFillType__ - Color for fill type names
* __colorCaption__ - Color for captions (Input: Output: Productions:)
* __colorEmpty__ - Color for empty entries (no input or output or product lines)
* __colorEmptyInput__ - Color for empty inputs
* __ColorAniHome__ - Color for animal pen and silo names
* __ColorAniData__ - Color for animal pen and silo data points
* __colorSep__ - Color for seperator
* __colorEmpty__ - Color for empty input / output / production lines
* __colorStatusInactive__ - Color for production line status when inactive
* __colorStatusRunning__ - Color for production line status when running
* __colorStatusMissing__ - Color for production line status when missing materials
* __colorStatusNoSpace__ - Color for production line status when full

### text

* __setStringTextIndent__ - text for indentation of production lines, default "    " (4 spaces)
* __setStringTextSep__ - text for separators, default " | "
* __setValueTextMarginX__ - text margin height, default "15"
* __setValueTextMarginY__ - text margin width, default "10"
* __setValueTextSize__ - text size, default "12"
* __setStringTextSelling__ - text string for output mode selling , default "↑"
* __setStringTextStoring__ - text string for output mode storing, default "↓"
* __setStringTextDistribute__ - text string for output mode distributing, default "→"
* __setTotalMaxProductions__ - maximum number of productions available in the settings menu, default 40.
* __setTotalMaxAnimals__ - maximum number of animal pens available in the settings menu, default 20
* __setTotalMaxSilos__ - maximum number of silos available in the settings menu, default 10

### dev, debug and extras

* __setValueTimerFrequency__ - timer update frequency. We probably don't need to query every vehicle on every tick for performance reasons
* __debugMode__ - show debug output.  Mostly garbage.

## Sample

<p align="center">
  <img width="650" src="https://github.com/jtsage/FS22_ProductionInspector/raw/main/readme_sample.png">
</p>
