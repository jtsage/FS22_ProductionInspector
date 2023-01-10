--
-- Mod: FS22_ProductionInspector
--
-- Author: JTSage
-- source: https://github.com/jtsage/FS22_Production_Inspector

ProductionInspector= {}

local ProductionInspector_mt = Class(ProductionInspector)

function ProductionInspector:new(mission, modDirectory, modName, logger)
	local self = setmetatable({}, ProductionInspector_mt)

	self.myName            = "ProductionInspector"
	self.logger            = logger
	self.isClient          = mission:getIsClient()
	self.mission           = mission
	self.modDirectory      = modDirectory
	self.modName           = modName
	self.gameInfoDisplay   = mission.hud.gameInfoDisplay
	self.inputHelpDisplay  = mission.hud.inputHelp
	self.speedMeterDisplay = mission.hud.speedMeter
	self.ingameMap         = mission.hud.ingameMap

	source(modDirectory .. 'lib/fs22ModPrefSaver.lua')

	self.settings = FS22PrefSaver:new(
		"FS22_ProductionInspector",
		"productionInspector.xml",
		true,
		{
			displayModeProd = { 1, "int" },
			displayModeAnim = { 1, "int" },
			displayModeSilo = { 1, "int" },

			isEnabledProdVisible = true,
			isEnabledAnimVisible = false,
			isEnabledSiloVisible = false,

			isEnabledForceProdJustify = { 1, "int" },
			isEnabledForceAnimJustify = { 1, "int" },
			isEnabledForceSiloJustify = { 1, "int" },

			isEnabledProdOnlyOwned     = true,
			isEnabledProdInactivePoint = false,
			isEnabledProdInactiveProd  = false,
			isEnabledProdOutPercent    = true,
			isEnabledProdOutFillLevel  = true,
			isEnabledProdInPercent     = true,
			isEnabledProdInFillLevel   = true,
			isEnabledProdInputs        = true,
			isEnabledProdOutputs       = true,
			isEnabledProdEmptyOutput   = false,
			isEnabledProdEmptyInput    = true,
			isEnabledProdShortEmptyOut = true,
			isEnabledProdOutputMode    = true,
			isEnabledProdMax           = { 0, "int" },
			isEnabledProdFullInput     = true,

			isEnabledAnimCount         = true,
			isEnabledAnimFood          = true,
			isEnabledAnimFoodTypes     = true,
			isEnabledAnimProductivity  = true,
			isEnabledAnimReproduction  = true,
			isEnabledAnimPuberty       = true,
			isEnabledAnimHealth        = true,
			isEnabledAnimOutputs       = true,
			isEnabledAnimMax           = { 0, "int" },

			isEnabledSiloMax           = { 0, "int" },

			setValueTextMarginX     = { 15, "int" },
			setValueTextMarginY     = { 10, "int" },
			setValueTextSize        = { 12, "int" },
			setTotalMaxProductions  = { 40, "int" },
			setTotalMaxAnimals      = { 20, "int" },
			setTotalMaxSilos        = { 10, "int" },
			isEnabledTextBold       = false,

			colorPointOwned    = { {0.182, 0.493, 0.875, 1}, "color" },
			colorPointNotOwned = { {0.738, 0.738, 0.738, 1}, "color" },
			colorProdName      = { {0.991, 0.399, 0.038, 1}, "color" },
			colorFillType      = { {0.700, 0.700, 0.700, 1}, "color" },
			colorCaption       = { {0.550, 0.550, 0.550, 1}, "color" },
			colorSep           = { {1.000, 1.000, 1.000, 1}, "color" },
			colorEmpty         = { {0.830, 0.019, 0.033, 1}, "color" },
			colorEmptyInput    = { {1.000, 0.200, 0.200, 1}, "color" },
			colorAniHome       = { {0.182, 0.493, 0.875, 1}, "color" },
			colorAniData       = { {0.850, 0.850, 0.850, 1}, "color" },

			colorStatusInactive = { {0.600, 0.600, 0.600, 1}, "color" },
			colorStatusRunning  = { {1.000, 1.000, 1.000, 1}, "color" },
			colorStatusMissing  = { {1.000, 0.200, 0.200, 1}, "color" },
			colorStatusNoSpace  = { {1.000, 0.200, 0.200, 1}, "color" },

			setStringTextSep         = " | ",
			setStringTextIndent      = "    ",
			setStringTextEmptyInput  = "--",
			setStringTextSelling     = "↑",
			setStringTextStoring     = "↓",
			setStringTextDistribute  = "→",
			setStringTextRealStore   = "←",
		},
		function ()
			self.inspectBox_prod.size = self.gameInfoDisplay:scalePixelToScreenHeight(self.settings:getValue("setValueTextSize"))
			self.inspectBox_anim.size = self.gameInfoDisplay:scalePixelToScreenHeight(self.settings:getValue("setValueTextSize"))
			self.inspectBox_silo.size = self.gameInfoDisplay:scalePixelToScreenHeight(self.settings:getValue("setValueTextSize"))
		end,
		nil,
		self.logger
	)

	self.setValueTimerFrequency  = 60
	self.debugTimerRuns = 0
	self.inspectText    = {}
	self.boxBGColor     = { 544, 20, 200, 44 }
	self.bgName         = 'dataS/menu/blank.png'
	self.menuTextSizes          = { 8, 10, 12, 14, 16 }
	

	local modDesc       = loadXMLFile("modDesc", modDirectory .. "modDesc.xml");
	self.version        = getXMLString(modDesc, "modDesc.version");
	delete(modDesc)

	self.display_data_prod = { }
	self.display_data_anim = { }
	self.display_data_silo = { }

	
	self.statusColorsMap = {
		[ProductionPoint.PROD_STATUS.INACTIVE]        = "colorStatusInactive",
		[ProductionPoint.PROD_STATUS.RUNNING]         = "colorStatusRunning",
		[ProductionPoint.PROD_STATUS.MISSING_INPUTS]  = "colorStatusMissing",
		[ProductionPoint.PROD_STATUS.NO_OUTPUT_SPACE] = "colorStatusNoSpace"
	}

	self.outputModeMap = {
		[ProductionPoint.OUTPUT_MODE.KEEP]         = "setStringTextStoring",
		[ProductionPoint.OUTPUT_MODE.DIRECT_SELL]  = "setStringTextSelling",
		[ProductionPoint.OUTPUT_MODE.AUTO_DELIVER] = "setStringTextDistribute",
		[3]                                        = "setStringTextRealStore",
	}

	self.lastCoords = {
		prod = {},
		anim = {},
		silo = {}
	}

	return self
end

function ProductionInspector:save()
	self.settings:saveSettings()
end

function ProductionInspector:updateSilos()
	local new_data_table = {}
	local theseSilos     = {}
	local myFarmID       = self.mission:getFarmId()

	if not self.settings:getValue("isEnabledSiloVisible") then
		self.display_data_silo = {}
		return
	end

	if g_currentMission ~= nil and g_currentMission.placeableSystem and g_currentMission.placeableSystem.placeables then
		for v=1, #g_currentMission.placeableSystem.placeables do
			local thisPlaceable = g_currentMission.placeableSystem.placeables[v]
			if thisPlaceable.spec_silo ~= nil and thisPlaceable.ownerFarmId == myFarmID then
				table.insert(theseSilos, thisPlaceable)
			end
		end

		local sortOrder   = self:util_sortPoints(theseSilos)

		for _, sortEntry in ipairs(sortOrder) do
			local thisSilo         = theseSilos[sortEntry[1]]
			local rawFillLevels    = {}
			local cleanFillLevels  = {}
			local capacity         = 0
			local totalFill        = 0
			local spec             = thisSilo.spec_silo

			for _,storage in pairs(spec.loadingStation:getSourceStorages()) do
				capacity = capacity + storage.capacity
			end

			for fillType, fillLevel in pairs(spec.loadingStation:getAllFillLevels(myFarmID)) do
				rawFillLevels[fillType] = (rawFillLevels[fillType] or 0) + fillLevel
			end

			for fillType, fillLevel in pairs(rawFillLevels) do
				if fillLevel > 0 then
					local roundFillLevel = MathUtil.round(fillLevel)
					table.insert(cleanFillLevels, {
						fillTypeIdx = fillType,
						level       = roundFillLevel
					})
					totalFill = totalFill + roundFillLevel
				end
			end

			table.insert(new_data_table, {
				name       = thisSilo:getName(),
				percent    = MathUtil.getFlooredPercent(totalFill, capacity),
				fillLevels = cleanFillLevels
			})
		end

		self.logger:printVariable(new_data_table, FS22Log.LOG_LEVEL.VERBOSE, "display_data_silo", 3)
	end

	self.display_data_silo = {unpack(new_data_table)}
end

function ProductionInspector:updateProductions()
	local new_data_table = {}

	if not self.settings:getValue("isEnabledProdVisible") then
		self.display_data_prod = {}
		return
	end

	if g_currentMission ~= nil and g_currentMission.productionChainManager ~= nil then
		local thesePoints = g_currentMission.productionChainManager.productionPoints
		local sortOrder   = self:util_sortPoints(thesePoints)

		for _, sortEntry in ipairs(sortOrder) do
			local thisProd         = thesePoints[sortEntry[1]]
			local ownedBy          = thisProd:getOwnerFarmId()
			local isMine           = ownedBy == self.mission:getFarmId()
			local weAreWorkingHere = false

			local inputTable  = {}
			local outputTable = {}
			local procTable   = {}

			for x = 1, #thisProd.inputFillTypeIdsArray do
				local fillType  = thisProd.inputFillTypeIdsArray[x]
				local fillLevel = MathUtil.round(thisProd.storage:getFillLevel(fillType))
				local fillCap   = thisProd.storage:getCapacity(fillType)
				local fillPerc  = MathUtil.getFlooredPercent(fillLevel, fillCap)

				if ( fillLevel > 0 or self.settings:getValue("isEnabledProdEmptyInput") ) then
					if ( fillPerc < 84 or self.settings:getValue("isEnabledProdFullInput") ) then
						table.insert(inputTable, {
							fillTypeIdx  = fillType,
							level        = fillLevel,
							capacity     = fillCap,
							wholePercent = fillPerc
						})
					end
				end
			end

			for x = 1, #thisProd.outputFillTypeIdsArray do
				local fillType  = thisProd.outputFillTypeIdsArray[x]
				local fillLevel = MathUtil.round(thisProd.storage:getFillLevel(fillType))
				local fillCap   = thisProd.storage:getCapacity(fillType)
				local fillPerc  = MathUtil.getFlooredPercent(fillLevel, fillCap)
				local fillDest  = thisProd:getOutputDistributionMode(fillType)

				if ( fillLevel > 0 or self.settings:getValue("isEnabledProdEmptyOutput") ) then
					table.insert(outputTable, {
						fillTypeIdx  = fillType,
						level        = fillLevel,
						capacity     = fillCap,
						wholePercent = fillPerc,
						destination  = fillDest
					})
				end
			end

			if thisProd.productions ~= nil then
				for _, thisProcess in ipairs(thisProd.productions) do
					local prRunning   = thisProd:getIsProductionEnabled(thisProcess.id)
					local prStatus    = thisProd:getProductionStatus(thisProcess.id)
					local prStatusCol = Utils.getNoNil(self.statusColorsMap[prStatus], "colorStatusInactive")
					local prStatusTxt = Utils.getNoNil(g_i18n:getText(ProductionPoint.PROD_STATUS_TO_L10N[prStatus]), "unknown")

					if not weAreWorkingHere and prRunning then
						-- Something in this production point is running
						weAreWorkingHere = true
					end

					if prRunning or self.settings:getValue("isEnabledProdInactiveProd") then
						table.insert(procTable, {
							name        = thisProcess.name,
							isRunning   = prRunning,
							statusText  = prStatusTxt,
							statusColor = prStatusCol
						})
					end

				end
			end

			if isMine or not self.settings:getValue("isEnabledProdOnlyOwned") then
				if weAreWorkingHere or self.settings:getValue("isEnabledProdInactivePoint") then

					table.insert(new_data_table, {
						name       = thisProd:getName(),
						isMine     = isMine,
						prodActive = weAreWorkingHere,
						prodStatus = weAreWorkingHere and g_i18n:getText("ui_production_status_running") or g_i18n:getText("ui_production_status_inactive"),
						inputs     = inputTable,
						outputs    = outputTable,
						products   = procTable
					})
				end
			end
		end
	end

	self.logger:printVariable(new_data_table, FS22Log.LOG_LEVEL.VERBOSE, "display_data_prod", 3)

	self.display_data_prod = {unpack(new_data_table)}
end

function ProductionInspector:updateAnimals()
	local new_data_table = {}

	if not self.settings:getValue("isEnabledAnimVisible") or g_currentMission == nil or g_currentMission.husbandrySystem == nil then
		-- This is in case you sell your last animal placeable, otherwise it'll display old stats forever? (also hidden)
		self.display_data_anim = {}
		return
	end

	local myHusbandries = g_currentMission.husbandrySystem:getPlaceablesByFarm(self.mission:getFarmId())
	local sortOrder     = self:util_sortPoints(myHusbandries)


	for _, sortEntry in ipairs(sortOrder) do
		local thisHusb = myHusbandries[sortEntry[1]]
		local thisNumClusters = thisHusb:getNumOfClusters()

		if thisHusb:getAnimalTypeIndex() ~= AnimalType.HORSE and thisNumClusters > 0 then
			local dispFood = {}
			local dispOuts = {}
			local dispRoot = {
				productivty  = 0,
				foodTypes    = {},
				outTypes     = {},
				name         = thisHusb:getName(),
				totalAnimals = thisHusb:getNumOfAnimals(),
				maxAnimals   = thisHusb:getMaxNumOfAnimals(),
				totalFood    = MathUtil.getFlooredPercent(thisHusb:getTotalFood(), thisHusb:getFoodCapacity())
			}

			if thisHusb.getFoodInfos ~= nil then
				local thisFood = thisHusb:getFoodInfos()
				for _, thisFoodInfo in ipairs(thisFood) do
					table.insert(dispFood, {
						title    = thisFoodInfo.title,
						percent  = math.ceil(thisFoodInfo.ratio * 100)
					})
				end
				dispRoot.foodTypes = {unpack(dispFood)}
			end

			if thisHusb.getConditionInfos ~= nil then
				local thisCond = thisHusb:getConditionInfos()

				dispRoot.productivity = math.ceil(thisCond[1]["ratio"] * 100)

				if #thisCond > 1 then
					for v=2, #thisCond do
						local thisCondInfo = thisCond[v]
						table.insert(dispOuts, {
							title     = thisCondInfo.title,
							percent   = math.ceil(thisCondInfo.ratio * 100),
							fillLevel = math.floor(thisCondInfo.value),
							invert    = thisCondInfo.invertedBar
						})
					end

					dispRoot.outTypes = {unpack(dispOuts)}
				end
			end

			local clus_totalAnimals    = 0
			local clus_healthPercTotal = 0
			local clus_nonBreedAnimals = 0
			local clus_breedAnimals    = 0
			local clus_breedPercTotal  = 0

			for w=1, thisNumClusters do
				local thisCluster    = thisHusb:getCluster(w)
				local thisNumAnimals = thisCluster:getNumAnimals()
				local subType        = g_currentMission.animalSystem:getSubTypeByIndex(thisCluster:getSubTypeIndex())

				clus_totalAnimals    = clus_totalAnimals + thisNumAnimals
				clus_healthPercTotal = clus_healthPercTotal + ( thisNumAnimals * math.ceil( thisCluster:getHealthFactor() * 100))

				if subType.supportsReproduction then
					if ( thisCluster.age < subType.reproductionMinAgeMonth ) then
						clus_nonBreedAnimals = clus_nonBreedAnimals + thisNumAnimals
					else
						clus_breedAnimals   = clus_breedAnimals + thisNumAnimals
						clus_breedPercTotal = clus_breedPercTotal + ( thisNumAnimals * math.ceil( thisCluster:getReproductionFactor() * 100))
					end
				end
			end

			dispRoot.healthFactor   = math.ceil(clus_healthPercTotal / clus_totalAnimals)

			if clus_breedAnimals == 0 then
				dispRoot.breedFactor = 0
			else
				dispRoot.breedFactor    = math.ceil(clus_breedPercTotal / clus_breedAnimals)
			end

			if clus_nonBreedAnimals == 0 then
				dispRoot.underageFactor = 0
			else
				dispRoot.underageFactor = math.ceil((clus_nonBreedAnimals / clus_totalAnimals) * 100)
			end

			table.insert(new_data_table, dispRoot)
		end
	end

	self.logger:printVariable(new_data_table, FS22Log.LOG_LEVEL.VERBOSE, "display_data_anim", 3)

	self.display_data_anim = {unpack(new_data_table)}
end

function ProductionInspector:openConstructionScreen()
	-- hack for construction screen showing blank box.
	g_productionInspector.inspectBox_prod:setVisible(false)
	g_productionInspector.inspectBox_anim:setVisible(false)
	g_productionInspector.inspectBox_silo:setVisible(false)
end

function ProductionInspector:getMaxLength(display_table, currentText, useIndent)
	local thisText = currentText

	if ( useIndent ~= nil and useIndent == true ) then
		thisText = thisText .. self.settings:getValue("setStringTextIndent")
	end
	return math.max(display_table.maxLength, getTextWidth(self.inspectText.size, thisText))
end

function ProductionInspector:levelWithPercent(level, wholePercent, configShowLevel, configShowPercent)
	if self.settings:getValue(configShowPercent) then
		if self.settings:getValue(configShowLevel) then
			return JTSUtil.qConcat(level, " (", wholePercent, "%)")
		else
			return JTSUtil.qConcat(wholePercent, "%")
		end
	end

	if self.settings:getValue(configShowLevel) then
		return tostring(level)
	end

	return ""
end

function ProductionInspector:buildSeperator(doSeperate, currentLineTable, currentLineText)
	if doSeperate then
		currentLineTable, currentLineText = self:buildLine(
			currentLineTable,
			currentLineText,
			"colorSep",
			self.settings:getValue("setStringTextSep")
		)
	end
	return true, currentLineTable, currentLineText
end

function ProductionInspector:buildLine2Part(beginSeperate, currentLineTable, currentLineText, part1Text, part1ColorTab, part2Text, part2ColorTab)
	local thisTextAdditon = JTSUtil.qConcat(part1Text, part2Text)

	if beginSeperate then
		table.insert(currentLineTable, { self:getColorQuad("colorSep"), self.settings:getValue("setStringTextSep") })
		thisTextAdditon = self.settings:getValue("setStringTextSep") .. thisTextAdditon
	end

	table.insert(currentLineTable, { part1ColorTab, part1Text})

	if ( part2Text ~= nil ) then
		table.insert(currentLineTable, { part2ColorTab, part2Text})
	end

	return beginSeperate, currentLineTable, currentLineText .. thisTextAdditon
end

function ProductionInspector:buildLineLabelValue(beginSeperate, currentLineTable, currentLineText, labelText, labelColor, valueText, valueColor)
	return self:buildLine2Part(
		beginSeperate,
		currentLineTable,
		currentLineText,
		JTSUtil.qConcat(labelText, ": "),
		self:getColorQuad(labelColor),
		valueText,
		self:getColorQuad(valueColor)
	)
end

function ProductionInspector:buildLinePerc(beginSeperate, currentLineTable, currentLineText, labelText, labelColor, wholePercentage, percentFlip, withFill)
	local thisPercText = withFill ~= nil and JTSUtil.qConcat(withFill, " (", wholePercentage, ")") or JTSUtil.qConcat(wholePercentage, "%")

	return self:buildLine2Part(
		beginSeperate,
		currentLineTable,
		currentLineText,
		JTSUtil.qConcat(labelText, ": "),
		self:getColorQuad(labelColor),
		thisPercText,
		JTSUtil.colorPercent(wholePercentage, percentFlip)
	)
end

function ProductionInspector:buildLine(currentLineTable, currentLineText, newColor, newText)
	if newText == nil then
		-- Marker for indented text on left justify
		table.insert(currentLineTable, {{ 1,1,1,1 }, nil})
		return currentLineTable, currentLineText
	end
	if type(newColor) == "table" then
		table.insert(currentLineTable, {newColor, tostring(newText)})
	else
		table.insert(currentLineTable, {self:getColorQuad(newColor), tostring(newText)})
	end
	return currentLineTable, currentLineText .. tostring(newText)
end

function ProductionInspector:checkDisplayCount(num, config)
	return self.settings:getValue(config) == 0 or num < self.settings:getValue(config)
end

function ProductionInspector:buildDisplay_anim()
	local working_table = self.display_data_anim
	local currentLine   = {}
	local currentText   = ""
	local display_table = {
		maxLength     = 0,
		displayLines  = {},
		fullLines     = {}
	}

	for animIdx, thisDisplay in ipairs(working_table) do
		if self:checkDisplayCount(animIdx, "isEnabledAnimMax") then
			local doSeperate = false

			currentLine, currentText = self:buildLine({}, "", "colorAniHome", thisDisplay.name .. ": ")

			if ( self.settings:getValue("isEnabledAnimProductivity") ) then
				doSeperate, currentLine, currentText = self:buildLinePerc(
					doSeperate,
					currentLine,
					currentText,
					g_i18n:getText("statistic_productivity"),
					"colorAniData",
					thisDisplay.productivity,
					true
				)
			end

			if ( self.settings:getValue("isEnabledAnimCount") ) then
				local fillColor    = JTSUtil.colorPercent(math.ceil((thisDisplay.totalAnimals / thisDisplay.maxAnimals) * 100), false)

				doSeperate, currentLine, currentText = self:buildSeperator(doSeperate, currentLine, currentText)

				currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", g_i18n:getText("ui_numAnimals") .. ": ")
				currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, thisDisplay.totalAnimals)
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorSep", " / ")
				currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, thisDisplay.maxAnimals)
			end

			if ( self.settings:getValue("isEnabledAnimFood") ) then
				doSeperate, currentLine, currentText = self:buildLinePerc(
					doSeperate,
					currentLine,
					currentText,
					g_i18n:getText("ui_animalFood"),
					"colorAniData",
					thisDisplay.totalFood,
					true
				)
			end

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			doSeperate = false
			display_table.maxLength = self:getMaxLength(display_table, currentText, false)

			if ( self.settings:getValue("isEnabledAnimHealth") or self.settings:getValue("isEnabledAnimReproduction") or self.settings:getValue("isEnabledAnimPuberty") ) then
				currentLine, currentText = self:buildLine({}, "", nil, nil)

				if self.settings:getValue("isEnabledAnimHealth") then
					doSeperate, currentLine, currentText = self:buildLinePerc(
						doSeperate,
						currentLine,
						currentText,
						g_i18n:getText("hud_productionInspector_avgHealth"),
						"colorAniData",
						thisDisplay.healthFactor,
						true
					)
				end

				if self.settings:getValue("isEnabledAnimPuberty") then
					doSeperate, currentLine, currentText = self:buildLinePerc(
						doSeperate,
						currentLine,
						currentText,
						g_i18n:getText("hud_productionInspector_tooYoung"),
						"colorAniData",
						thisDisplay.underageFactor,
						false
					)
				end

				if self.settings:getValue("isEnabledAnimReproduction") then
					doSeperate, currentLine, currentText = self:buildLinePerc(
						doSeperate,
						currentLine,
						currentText,
						g_i18n:getText("hud_productionInspector_avgBreed"),
						"colorAniData",
						thisDisplay.breedFactor,
						true
					)
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				display_table.maxLength = self:getMaxLength(display_table, currentText, true)
			end

			if self.settings:getValue("isEnabledAnimFoodTypes") then
				currentLine, currentText = self:buildLine({}, "", nil, nil)

				for idx, foodType in ipairs(thisDisplay.foodTypes) do
					_, currentLine, currentText = self:buildLinePerc(
						idx > 1,
						currentLine,
						currentText,
						foodType.title,
						"colorAniData",
						foodType.percent,
						true
					)
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				display_table.maxLength = self:getMaxLength(display_table, currentText, true)
			end

			if self.settings:getValue("isEnabledAnimOutputs") then
				currentLine, currentText = self:buildLine({}, "", nil, nil)

				for idx, outType in ipairs(thisDisplay.outTypes) do
					_, currentLine, currentText = self:buildLinePerc(
						idx > 1,
						currentLine,
						currentText,
						outType.title,
						"colorAniData",
						outType.percent,
						not outType.invert,
						outType.fillLevel
					)
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				display_table.maxLength = self:getMaxLength(display_table, currentText, true)
			end

			table.insert(display_table.displayLines, false)
			table.insert(display_table.fullLines, false)
		end
	end

	self.logger:printVariable(display_table, FS22Log.LOG_LEVEL.VERBOSE, "display_table_anim", 3)

	return display_table
end

function ProductionInspector:buildDisplay_prod()
	local working_table = self.display_data_prod
	local currentLine   = {}
	local currentText   = ""
	local display_table = {
		maxLength     = 0,
		displayLines  = {},
		fullLines     = {}
	}

	for prodIdx, thisDisplay in ipairs(working_table) do
		if self:checkDisplayCount(prodIdx, "isEnabledProdMax") then
			-- Production point Name
			if thisDisplay.isMine then
				table.insert(display_table.displayLines, {{ self:getColorQuad("colorPointOwned"), thisDisplay.name }})
				table.insert(display_table.fullLines, thisDisplay.name)
			else
				table.insert(display_table.displayLines, {{ self:getColorQuad("colorPointNotOwned"), thisDisplay.name }})
				table.insert(display_table.fullLines, thisDisplay.name)
			end

			-- Production point products and statuses
			currentLine, currentText = self:buildLine({}, "", nil, nil)
			currentLine, currentText = self:buildLine(currentLine, currentText, "colorCaption", g_i18n:getText("ui_productions_production") .. " - ")

			for idx, prodLine in ipairs(thisDisplay.products) do
				_, currentLine, currentText = self:buildLineLabelValue(
					idx > 1,
					currentLine,
					currentText,
					prodLine.name,
					"colorProdName",
					prodLine.statusText,
					prodLine.statusColor
				)
			end

			if JTSUtil.nilOrEmptyTable(thisDisplay.products) then
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
			end

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			display_table.maxLength = self:getMaxLength(display_table, currentText, true)

			-- Production point inputs
			if self.settings:getValue("isEnabledProdInputs") then
				currentLine, currentText = self:buildLine({}, "", nil, nil)
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorCaption", g_i18n:getText("ui_productions_incomingMaterials") .. " - ")

				for idx, inputs in ipairs(thisDisplay.inputs) do
					local thisFillType = g_fillTypeManager:getFillTypeByIndex(inputs.fillTypeIdx)

					_, currentLine, currentText = self:buildLine2Part(
						idx > 1,
						currentLine,
						currentText,
						JTSUtil.qConcat(thisFillType.title,": "),
						self:getColorQuad("colorFillType"),
						self:levelWithPercent(
							inputs.level,
							inputs.wholePercent,
							"isEnabledProdInFillLevel",
							"isEnabledProdInPercent"
						),
						JTSUtil.colorPercent(inputs.wholePercent, true)
					)
				end

				if JTSUtil.nilOrEmptyTable(thisDisplay.inputs) then
					currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				display_table.maxLength = self:getMaxLength(display_table, currentText, true)
			end

			if self.settings:getValue("isEnabledProdOutputs") then
				currentLine, currentText = self:buildLine({}, "", nil, nil)
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorCaption", g_i18n:getText("ui_productions_outgoingProducts") .. " - ")

				for idx, outputs in ipairs(thisDisplay.outputs) do
					local thisFillType   = g_fillTypeManager:getFillTypeByIndex(outputs.fillTypeIdx)

					_, currentLine, currentText = self:buildLine2Part(
						idx > 1,
						currentLine,
						currentText,
						JTSUtil.logicStringBuild(
							self.settings:getValue("isEnabledProdOutputMode"),
							thisFillType.title,
							JTSUtil.qConcat(" ", self.settings:getValue(self.outputModeMap[outputs.destination]), " "),
							": "
						),
						self:getColorQuad("colorFillType"),
						self:levelWithPercent(
							outputs.level,
							outputs.wholePercent,
							"isEnabledProdOutFillLevel",
							"isEnabledProdOutPercent"
						),
						JTSUtil.colorPercent(outputs.wholePercent, false)
					)
				end

				if JTSUtil.nilOrEmptyTable(thisDisplay.outputs) then
					currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				display_table.maxLength = self:getMaxLength(display_table, currentText, true)
			end

			table.insert(display_table.displayLines, false)
			table.insert(display_table.fullLines, false)
		end
	end

	self.logger:printVariable(display_table, FS22Log.LOG_LEVEL.VERBOSE, "display_table_prod", 3)

	return display_table
end

function ProductionInspector:buildDisplay_silo()
	local working_table = self.display_data_silo
	local currentLine   = {}
	local currentText   = ""
	local display_table = {
		maxLength     = 0,
		displayLines  = {},
		fullLines     = {}
	}

	for siloIdx, thisDisplay in ipairs(working_table) do
		if self:checkDisplayCount(siloIdx, "isEnabledSiloMax") then
			currentLine, currentText = self:buildLine({}, "", "colorAniHome", thisDisplay.name .. ": ")
			currentLine, currentText = self:buildLine(currentLine, currentText, self:makeFillColor(thisDisplay.percent, false), tostring(thisDisplay.percent) .. "%")

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			display_table.maxLength = self:getMaxLength(display_table, currentText, false)


			currentLine, currentText = self:buildLine({}, "", nil, nil)

			for idx, thisFill in ipairs(thisDisplay.fillLevels) do
				local thisFillType = g_fillTypeManager:getFillTypeByIndex(thisFill.fillTypeIdx)

				_, currentLine, currentText = self:buildLineLabelValue(
					idx > 1,
					currentLine,
					currentText,
					thisFillType.title,
					"colorAniData",
					thisFillType.level,
					"colorFillType"
				)
			end

			if JTSUtil.nilOrEmptyTable(thisDisplay.fillLevels) then
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
			end

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			display_table.maxLength = self:getMaxLength(display_table, currentText, true)

			table.insert(display_table.displayLines, false)
			table.insert(display_table.fullLines, false)
		end
	end

	self.logger:printVariable(display_table, FS22Log.LOG_LEVEL.VERBOSE, "display_table_silo", 3)

	return display_table
end

function ProductionInspector:getSizes(dataType, display_table)
	local overlayX, overlayY, overlayH    = 0, 0, 0
	local dispTextX, dispTextY, dispTextH = 0, 0, 0
	local linesHeight                     = 0
	local thisDisplayMode                 = 0
	local dispTextW                       = display_table.maxLength
	local overlayW                        = dispTextW + ( 2 * self.inspectText.marginWidth )

	overlayX, overlayY   = self:findOrigin(dataType)
	dispTextX, dispTextY = self:findOrigin(dataType)

	for idx, line in ipairs(display_table.displayLines) do
		if line == false then
			if ( idx ~= #display_table.displayLines ) then
				linesHeight = linesHeight + 0.5
			end
		else
			linesHeight = linesHeight + 1
		end
	end

	dispTextH = self.inspectText.size * ( linesHeight )
	overlayH  = dispTextH + ( 2 * self.inspectText.marginHeight)

	if dataType == "prod" then
		thisDisplayMode = self.settings:getValue("displayModeProd")
	elseif dataType == "anim" then
		thisDisplayMode = self.settings:getValue("displayModeAnim")
	else
		thisDisplayMode = self.settings:getValue("displayModeSilo")
	end

	if thisDisplayMode == 1 then
		-- top left
		dispTextX = dispTextX + self.marginWidth
		dispTextY = dispTextY - self.marginHeight
		overlayY  = overlayY - overlayH
	elseif thisDisplayMode == 2 then
		-- top right
		dispTextX = dispTextX - ( self.marginWidth * 2 ) - dispTextW
		dispTextY = dispTextY - self.marginHeight
		overlayY  = overlayY - overlayH
		overlayX  = overlayX - overlayW
	elseif thisDisplayMode == 3 then
		-- bottom left
		dispTextX = dispTextX + self.marginWidth
		dispTextY = dispTextY - self.marginHeight + overlayH
	elseif thisDisplayMode == 4 then
		dispTextX = dispTextX - ( self.marginWidth * 2 ) - dispTextW
		dispTextY = dispTextY - self.marginHeight + overlayH
		overlayX  = overlayX - overlayW
	end

	if g_currentMission.hud.sideNotifications ~= nil and thisDisplayMode == 2 then
		if #g_currentMission.hud.sideNotifications.notificationQueue > 0 then
			local deltaY = g_currentMission.hud.sideNotifications:getHeight()
			dispTextY = dispTextY - deltaY
			overlayY  = overlayY - deltaY
		end
	end

	if dataType == "anim" and self.settings:getValue("displayModeProd") == self.settings:getValue("displayModeAnim") and self.settings:getValue("isEnabledProdVisible") then
		if ( thisDisplayMode < 3 ) then
			overlayY  = overlayY - self.lastCoords.prod[3] - (self.marginHeight * 2)
			dispTextY = dispTextY - self.lastCoords.prod[3] - (self.marginHeight * 2)
		else
			overlayY  = overlayY + self.lastCoords.prod[3] + (self.marginHeight * 2)
			dispTextY = dispTextY + self.lastCoords.prod[3] + (self.marginHeight * 2)
		end
	end
	if dataType == "silo" then
		local sameAsAnimal = self.settings:getValue("displayModeAnim") == self.settings:getValue("displayModeSilo") and self.settings:getValue("isEnabledAnimVisible")
		local sameAsProd   = self.settings:getValue("displayModeProd") == self.settings:getValue("displayModeSilo") and self.settings:getValue("isEnabledProdVisible")

		if sameAsAnimal and sameAsProd then
			if ( thisDisplayMode < 3 ) then
				overlayY  = overlayY - self.lastCoords.prod[3] - self.lastCoords.anim[3] - (self.marginHeight * 4)
				dispTextY = dispTextY - self.lastCoords.prod[3] - self.lastCoords.anim[3] - (self.marginHeight * 4)
			else
				overlayY  = overlayY + self.lastCoords.prod[3] + self.lastCoords.anim[3] + (self.marginHeight * 4)
				dispTextY = dispTextY + self.lastCoords.prod[3] + self.lastCoords.anim[3] + (self.marginHeight * 4)
			end
		elseif sameAsAnimal then
			-- adjust for silo & anim in same
			if ( thisDisplayMode < 3 ) then
				overlayY  = overlayY - self.lastCoords.anim[3] - (self.marginHeight * 2)
				dispTextY = dispTextY - self.lastCoords.anim[3] - (self.marginHeight * 2)
			else
				overlayY  = overlayY + self.lastCoords.anim[3] + (self.marginHeight * 2)
				dispTextY = dispTextY + self.lastCoords.anim[3] + (self.marginHeight * 2)
			end
		elseif sameAsProd then
			if ( thisDisplayMode < 3 ) then
				overlayY  = overlayY - self.lastCoords.prod[3] - (self.marginHeight * 2)
				dispTextY = dispTextY - self.lastCoords.prod[3] - (self.marginHeight * 2)
			else
				overlayY  = overlayY + self.lastCoords.prod[3] + (self.marginHeight * 2)
				dispTextY = dispTextY + self.lastCoords.prod[3] + (self.marginHeight * 2)
			end
		end
	end

	return overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, display_table.maxLength
end

function ProductionInspector:shouldDraw_any(mode)
	if g_sleepManager:getIsSleeping() then return false end
	if g_noHudModeEnabled then return false end
	if not g_currentMission.hud.isVisible then return false end
	if mode == 1 or mode == 3 then
		if g_gameSettings:getValue("ingameMapState") == 4  and g_currentMission.inGameMenu.hud.inputHelp.overlay.visible then
			return false
		end
	end
	return true
end

function ProductionInspector:shouldDraw_prod()
	if #self.display_data_prod == 0 then return false end
	if not self.settings:getValue("isEnabledProdVisible") then return false end
	return self:shouldDraw_any(self.settings:getValue("displayModeProd"))
end

function ProductionInspector:shouldDraw_anim()
	if #self.display_data_anim == 0 then return false end
	if not self.settings:getValue("isEnabledAnimVisible") then return false end
	return self:shouldDraw_any(self.settings:getValue("displayModeAnim"))
end

function ProductionInspector:shouldDraw_silo()
	if #self.display_data_silo == 0 then return false end
	if not self.settings:getValue("isEnabledSiloVisible") then return false end
	return self:shouldDraw_any(self.settings:getValue("displayModeSilo"))
end

function ProductionInspector:draw_variant(thisDisplayTable, dataType)
	local overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW = self:getSizes(dataType, thisDisplayTable)
	local settingDisplayMode  = JTSUtil.qConcat("displayMode", dataType:sub(1,1):upper(), dataType:sub(2))
	local settingForceJustify = JTSUtil.qConcat("isEnabledForce", dataType:sub(1,1):upper(), dataType:sub(2), "Justify")
	local inspectBoxName      = JTSUtil.qConcat("inspectBox_", dataType)

	self.lastCoords[dataType] = {
		overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW
	}

	setTextBold(self.settings:getValue("isEnabledTextBold"))
	setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)
	setTextAlignment(RenderText.ALIGN_LEFT)

	self.inspectText.posX = dispTextX
	self.inspectText.posY = dispTextY

	for lineIdx, thisLine in ipairs(thisDisplayTable.displayLines) do
		if thisLine == false then
			dispTextY = dispTextY - ( self.inspectText.size / 2 )
		else
			local fullTextSoFar = ""
			local fullTextLine  = thisDisplayTable.fullLines[lineIdx]
			local indentLine    = false
			for idx, thisPart in ipairs(thisLine) do
				if idx == 1 and thisPart[2] == nil then
					indentLine = true
				end
				setTextColor(unpack(thisPart[1]))
				fullTextSoFar = self:renderText(
					dispTextX,
					dispTextY,
					fullTextSoFar,
					thisPart[2],
					self.settings.getValue(settingDisplayMode),
					indentLine,
					fullTextLine,
					dispTextW,
					self.settings.getValue(settingForceJustify)
				)
			end
			dispTextY = dispTextY - self.inspectText.size
		end
	end

	self[inspectBoxName]:setVisible(true)
	self[inspectBoxName].overlay:setPosition(overlayX, overlayY)
	self[inspectBoxName].overlay:setDimension(overlayW, overlayH)

	setTextColor(1,1,1,1)
	setTextAlignment(RenderText.ALIGN_LEFT)
	setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
	setTextBold(false)
end

function ProductionInspector:draw()
	if not self.isClient then return end

	if self.inspectBox_prod ~= nil then
		if not self:shouldDraw_prod() then
			self.inspectBox_prod:setVisible(false)
		else
			self:draw_variant(self:buildDisplay_prod(), "prod")
		end
	end
	if self.inspectBox_anim ~= nil then
		if not self:shouldDraw_anim() then
			self.inspectBox_anim:setVisible(false)
		else
			self:draw_variant(self:buildDisplay_anim(), "anim")
		end
	end
	if self.inspectBox_silo ~= nil then
		if not self:shouldDraw_silo() then
			self.inspectBox_silo:setVisible(false)
		else
			self:draw_variant(self:buildDisplay_silo(), "silo")
		end
	end
end

function ProductionInspector:update(dt)
	if not self.isClient then
		return
	end

	if g_updateLoopIndex % self.setValueTimerFrequency == 0 then
		-- Lets not be rediculous, only update the vehicles "infrequently"
		self:updateProductions()
		self:updateAnimals()
		self:updateSilos()
	end
end

function ProductionInspector:getColorQuad(name)
	if name == nil then return { 1,1,1,1 } end
	return Utils.getNoNil(self.settings:getValue(name), {1,1,1,1})
end

function ProductionInspector:renderText(x, y, fullTextSoFar, text, displayMode, indentLine, fullTextTotal, dispTextW, forceJustify)
	if text == nil then
		if ( displayMode % 2 ~= 0 and forceJustify == 1 ) or forceJustify == 2 then
			text = self.settings:getValue("setStringTextIndent")
		else
			return fullTextSoFar
		end
	end

	local newX = x + getTextWidth(self.inspectText.size, fullTextSoFar)

	if ( displayMode % 2 == 0  and forceJustify == 1 ) or forceJustify == 3 then
		-- right justify
		newX = newX + ( dispTextW - getTextWidth(self.inspectText.size, fullTextTotal))

		if indentLine then
			newX = newX - getTextWidth(self.inspectText.size, self.settings:getValue("setStringTextIndent"))
		end
	end

	renderText(newX, y, self.inspectText.size, text)
	return text .. fullTextSoFar
end


function ProductionInspector:onStartMission(mission)
	-- Load the mod, make the box that info lives in.
	self.logger:print(JTSUtil.qConcat("Loaded - version : ", self.version), FS22Log.LOG_LEVEL.INFO, "user_info")
	
	if not self.isClient then
		return
	end

	-- Just call both, load fails gracefully if it doesn't exists.
	self.settings:loadSettings()
	self.settings:saveSettings()

	self.logger:print(":onStartMission()", FS22Log.LOG_LEVEL.VERBOSE, "method_track")

	self:createTextBox()
end

function ProductionInspector:findOrigin(dataType)
	local tmpX            = 0
	local tmpY            = 0
	local thisDisplayMode = 0

	if dataType == "prod" then
		thisDisplayMode = self.settings:getValue("displayModeProd")
	elseif dataType == "anim" then
		thisDisplayMode = self.settings:getValue("displayModeAnim")
	else
		thisDisplayMode = self.settings:getValue("displayModeSilo")
	end

	if ( thisDisplayMode == 2 ) then
		-- top right display
		tmpX, tmpY = self.gameInfoDisplay:getPosition()
		tmpX = 1
		tmpY = tmpY - 0.012
	elseif ( thisDisplayMode == 3 ) then
		-- Bottom left, correct origin.
		tmpX = 0.01622
		tmpY = 0 + self.ingameMap:getHeight() + 0.01622
		if g_gameSettings:getValue("ingameMapState") > 1 then
			tmpY = tmpY + 0.032
		end
	elseif ( thisDisplayMode == 4 ) then
		-- bottom right display
		tmpX = 1
		tmpY = 0.01622
		if g_currentMission.inGameMenu.hud.speedMeter.overlay.visible then
			tmpY = tmpY + self.speedMeterDisplay:getHeight() + 0.032
			if g_modIsLoaded["FS22_EnhancedVehicle"] or g_modIsLoaded["FS22_guidanceSteering"] then
				tmpY = tmpY + 0.03
			end
		end
	else
		-- top left display
		tmpX = 0.014
		tmpY = 0.945
		if g_currentMission.inGameMenu.hud.inputHelp.overlay.visible then
			tmpY = tmpY - self.inputHelpDisplay:getHeight() - 0.012
		end
	end

	-- at this point, we've not adjusted for multiples.
	return tmpX, tmpY
end

function ProductionInspector:createTextBox()
	-- make the box we (visually) live in.
	self.logger:print(":createTextBox()", FS22Log.LOG_LEVEL.VERBOSE, "method_track")

	self.marginWidth, self.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector({ 8, 8 })

	local boxElement_prod = HUDElement.new(Overlay.new(self.bgName, 0, 0, 1, 1))
	local boxElement_anim = HUDElement.new(Overlay.new(self.bgName, 0, 0, 1, 1))
	local boxElement_silo = HUDElement.new(Overlay.new(self.bgName, 0, 0, 1, 1))

	self.inspectBox_prod = boxElement_prod
	self.inspectBox_anim = boxElement_anim
	self.inspectBox_silo = boxElement_silo

	self.inspectBox_prod:setUVs(GuiUtils.getUVs(self.boxBGColor))
	self.inspectBox_prod:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
	self.inspectBox_prod:setVisible(false)

	self.inspectBox_anim:setUVs(GuiUtils.getUVs(self.boxBGColor))
	self.inspectBox_anim:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
	self.inspectBox_anim:setVisible(false)

	self.inspectBox_silo:setUVs(GuiUtils.getUVs(self.boxBGColor))
	self.inspectBox_silo:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
	self.inspectBox_silo:setVisible(false)

	self.gameInfoDisplay:addChild(boxElement_prod)
	self.gameInfoDisplay:addChild(boxElement_anim)
	self.gameInfoDisplay:addChild(boxElement_silo)

	self.inspectText.marginWidth, self.inspectText.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector({self.settings:getValue("setValueTextMarginX"), self.settings:getValue("setValueTextMarginY")})
	self.inspectText.size = self.gameInfoDisplay:scalePixelToScreenHeight(self.settings:getValue("setValueTextSize"))
end

function ProductionInspector:delete()
	-- clean up on remove
	if self.inspectBox_prod ~= nil then
		self.inspectBox_prod:delete()
	end
	if self.inspectBox_anim ~= nil then
		self.inspectBox_anim:delete()
	end
	if self.inspectBox_silo ~= nil then
		self.inspectBox_silo:delete()
	end
end

function ProductionInspector:registerActionEvents()
	local _, reloadConfig = g_inputBinding:registerActionEvent('ProductionInspector_reload_config', self,
		ProductionInspector.actionReloadConfig, false, true, false, true)
	g_inputBinding:setActionEventTextVisibility(reloadConfig, false)

	local _, toggleVisible = g_inputBinding:registerActionEvent('ProductionInspector_toggle_prod_visible', self,
		ProductionInspector.actionToggleProdVisible, false, true, false, true)
	g_inputBinding:setActionEventTextVisibility(toggleVisible, false)

	local _, toggleVisible = g_inputBinding:registerActionEvent('ProductionInspector_toggle_anim_visible', self,
		ProductionInspector.actionToggleAnimVisible, false, true, false, true)
	g_inputBinding:setActionEventTextVisibility(toggleVisible, false)

	local _, toggleVisible = g_inputBinding:registerActionEvent('ProductionInspector_toggle_silo_visible', self,
		ProductionInspector.actionToggleSiloVisible, false, true, false, true)
	g_inputBinding:setActionEventTextVisibility(toggleVisible, false)
end

function ProductionInspector:actionReloadConfig()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]

	thisModEnviroment.logger:print("reload settings from disk", FS22Log.LOG_LEVEL.INFO, "user_info")
	thisModEnviroment:loadSettings()
end

function ProductionInspector:actionToggleProdVisible()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]

	thisModEnviroment.logger:print("toggle production display on/off", FS22Log.LOG_LEVEL.INFO, "user_info")
	thisModEnviroment.settings:setValue("isEnabledProdVisible", not thisModEnviroment.settings:getValue("isEnabledProdVisible"))
	thisModEnviroment.settings:saveSettings()
end

function ProductionInspector:actionToggleAnimVisible()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]

	thisModEnviroment.logger:print("toggle animal display on/off", FS22Log.LOG_LEVEL.INFO, "user_info")
	thisModEnviroment.settings:setValue("isEnabledAnimVisible", not thisModEnviroment.settings:getValue("isEnabledAnimVisible"))
	thisModEnviroment.settings:saveSettings()
end

function ProductionInspector:actionToggleSiloVisible()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]

	thisModEnviroment.logger:print("toggle silo display on/off", FS22Log.LOG_LEVEL.INFO, "user_info")
	thisModEnviroment.settings:setValue("isEnabledSiloVisible", not thisModEnviroment.settings:getValue("isEnabledSiloVisible"))
	thisModEnviroment.settings:saveSettings()
end

function ProductionInspector.addMenuOption(original, target, id, i18n_title, i18n_tooltip, options, callback)
	local menuOption = original:clone()

	menuOption.target = target
	menuOption.id     = id

	menuOption:setCallback("onClickCallback", callback)
	menuOption:setDisabled(false)

	local settingTitle = menuOption.elements[4]
	local toolTip      = menuOption.elements[6]

	menuOption:setTexts({unpack(options)})
	settingTitle:setText(g_i18n:getText(i18n_title))
	toolTip:setText(g_i18n:getText(i18n_tooltip))

	return menuOption
end

function ProductionInspector.initGui(self)
	local optsByType = {
		{ "DisplayModeProd", "disp"},
		{ "ProdVisible", "bool"},
		{ "ProdMax", "max"},
		{ "ProdOnlyOwned", "bool"},
		{ "ProdInactivePoint", "bool"},
		{ "ProdInactiveProd", "bool"},
		{ "ProdInputs", "bool"},
		{ "ProdInPercent", "bool"},
		{ "ProdInFillLevel", "bool"},
		{ "ProdFullInput", "bool"},
		{ "ProdOutputs", "bool"},
		{ "ProdOutPercent", "bool"},
		{ "ProdOutFillLevel", "bool"},
		{ "ProdEmptyOutput", "bool"},
		{ "ProdEmptyInput", "bool"},
		{ "ProdShortEmptyOut", "bool"},
		{ "ProdOutputMode", "bool"},
		{ "ForceProdJustify", "just"},
		{ "DisplayModeAnim", "disp"},
		{ "AnimVisible", "bool"},
		{ "AnimMax", "max"},
		{ "AnimCount", "bool"},
		{ "AnimFood", "bool"},
		{ "AnimFoodTypes", "bool"},
		{ "AnimProductivity", "bool"},
		{ "AnimReproduction", "bool"},
		{ "AnimPuberty", "bool"},
		{ "AnimHealth", "bool"},
		{ "AnimOutputs", "bool"},
		{ "ForceAnimJustify", "just"},
		{ "DisplayModeSilo", "disp"},
		{ "SiloVisible", "bool"},
		{ "SiloMax", "max"},
		{ "ForceSiloJustify", "just"},
		{ "TextBold", "bool"},
		{ "TextSize", "size"},
	}
	local textsByType = {
		bool = {
			g_i18n:getText("ui_no"),
			g_i18n:getText("ui_yes")
		},
		just = {
			g_i18n:getText("ui_no"),
			g_i18n:getText("info_tipSideLeft"),
			g_i18n:getText("info_tipSideRight")
		},
		disp = {
			g_i18n:getText("setting_productionInspector_DisplayMode1"),
			g_i18n:getText("setting_productionInspector_DisplayMode2"),
			g_i18n:getText("setting_productionInspector_DisplayMode3"),
			g_i18n:getText("setting_productionInspector_DisplayMode4")
		},
		size = {
			"8px", "10px", "12px", "14px", "16px"
		}
	}
	local maxOptToSetting = {
		ProdMax = "setTotalMaxProductions",
		AnimMax = "setTotalMaxAnimals",
		SiloMax = "setTotalMaxSilos"
	}

	if not g_productionInspector.createdGUI then -- Skip if we've already done this once
		g_productionInspector.createdGUI = true

		local title = TextElement.new()
		title:applyProfile("settingsMenuSubtitle", true)
		title:setText(g_i18n:getText("title_productionInspector"))
		self.boxLayout:addElement(title)

		for _, optNameType in ipairs(optsByType) do
			local fullOptionName = "menuOption_" .. optNameType[1]
			local thisOptionList = {}

			if ( optNameType[2] == "max" ) then
				thisOptionList = {g_i18n:getText("ui_no")}

				for i=1, g_productionInspector.settings:getValue(maxOptToSetting[optNameType[1]]) do
					table.insert(thisOptionList, tostring(i))
				end
			else
				thisOptionList = textsByType[optNameType[2]]
			end

			self[fullOptionName] = SimpleInspector.addMenuOption(
				self.checkInvertYLook,
				g_productionInspector,
				"productionInspector_" .. optNameType[1],
				"setting_productionInspector_" .. optNameType[1],
				"toolTip_productionInspector_" .. optNameType[1],
				thisOptionList,
				"onMenuOptionChanged_" .. optNameType[2] .. "Opt"
			)
			self.boxLayout:addElement(self[fullOptionName])
		end
	end

	for _, optNameType in ipairs(optsByType) do
		local realMenuName    = "menuOption_" .. optNameType[1]
		local realSettingName = "isEnabled" .. optNameType[1]
		if optNameType[2] == "disp" then
			realSettingName = optNameType[1]:sub(1,1):lower() .. optNameType[1]:sub(2)
			self[realMenuName]:setState(g_productionInspector.settings:getValue(realSettingName))
		elseif optNameType[2] == "just" then
			self[realMenuName]:setState(g_productionInspector.settings:getValue(realSettingName))
		elseif optNameType[2] == "max" then
			self[realMenuName]:setState(g_productionInspector.settings:getValue(realSettingName) + 1)
		elseif optNameType[2] == "bool" then
			self[realMenuName]:setIsChecked(g_productionInspector.settings:getValue(realSettingName))
		elseif optNameType[2] == "size" then
			local textSizeState = 3 -- backup value for it set odd in the xml.
			for idx, textSize in ipairs(g_productionInspector.menuTextSizes) do
				if g_productionInspector.settings:getValue("setValueTextSize") == textSize then
					textSizeState = idx
				end
			end
			self.menuOption_TextSize:setState(textSizeState)
		end
	end
end

function ProductionInspector:onMenuOptionChanged_dispOpt(state, info)
	self.settings:setValue(
		string.sub(info.id, (#"productionInspector_"+1),1):lower() .. string.sub(info.id, (#"productionInspector_"+2)) ,
		state
	)
	self.settings:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_justOpt(state, info)
	self.settings:setValue(
		"isEnabled" .. string.sub(info.id, (#"productionInspector_"+1)),
		state
	)
	self.settings:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_maxOpt(state, info)
	self.settings:setValue(
		"isEnabled" .. string.sub(info.id, (#"productionInspector_"+1)),
		state - 1
	)
	self.settings:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_boolOpt(state, info)
	self.settings:setValue(
		"isEnabled" .. string.sub(info.id, (#"productionInspector_"+1)),
		state == CheckedOptionElement.STATE_CHECKED
	)
	self.settings:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_sizeOpt(state, info)
	self.settings:setValue("setValueTextSize", self.menuTextSizes[state])
	self.inspectText.size = self.gameInfoDisplay:scalePixelToScreenHeight(self.settings:getValue("setValueTextSize"))
	self.settings:saveSettings()
end

function ProductionInspector:util_sortPoints(points)
	local function sorter(a,b) return a[2] < b[2] end
	local sortOrder = {}

	for v=1, #points do
		local thisName = points[v]:getName()
		if ( string.sub(thisName, -1) ~= "_") then
			table.insert(sortOrder, {v, thisName})
		end
	end

	table.sort(sortOrder, sorter)
	return sortOrder
end