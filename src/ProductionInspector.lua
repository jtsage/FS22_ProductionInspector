--
-- Mod: FS22_ProductionInspector
--
-- Author: JTSage
-- source: https://github.com/jtsage/FS22_Production_Inspector

ProductionInspector= {}

local ProductionInspector_mt = Class(ProductionInspector)


-- default options
ProductionInspector.displayModeProd = 1
ProductionInspector.displayModeAnim = 1
ProductionInspector.displayModeSilo = 1

ProductionInspector.debugMode       = false

ProductionInspector.isEnabledProdVisible        = true
ProductionInspector.isEnabledAnimVisible        = false
ProductionInspector.isEnabledSiloVisible        = false

ProductionInspector.isEnabledForceProdJustify   = 1
ProductionInspector.isEnabledForceAnimJustify   = 1
ProductionInspector.isEnabledForceSiloJustify   = 1

ProductionInspector.isEnabledProdOnlyOwned     = true
ProductionInspector.isEnabledProdInactivePoint = false
ProductionInspector.isEnabledProdInactiveProd  = false
ProductionInspector.isEnabledProdOutPercent    = true
ProductionInspector.isEnabledProdOutFillLevel  = true
ProductionInspector.isEnabledProdInPercent     = true
ProductionInspector.isEnabledProdInFillLevel   = true
ProductionInspector.isEnabledProdInputs        = true
ProductionInspector.isEnabledProdOutputs       = true
ProductionInspector.isEnabledProdEmptyOutput   = false
ProductionInspector.isEnabledProdEmptyInput    = true
ProductionInspector.isEnabledProdShortEmptyOut = true
ProductionInspector.isEnabledProdOutputMode    = true
ProductionInspector.isEnabledProdMax           = 0
ProductionInspector.isEnabledProdFullInput     = true

ProductionInspector.isEnabledAnimCount         = true
ProductionInspector.isEnabledAnimFood          = true
ProductionInspector.isEnabledAnimFoodTypes     = true
ProductionInspector.isEnabledAnimProductivity  = true
ProductionInspector.isEnabledAnimReproduction  = true
ProductionInspector.isEnabledAnimPuberty       = true
ProductionInspector.isEnabledAnimHealth        = true
ProductionInspector.isEnabledAnimOutputs       = true
ProductionInspector.isEnabledAnimMax           = 0

ProductionInspector.isEnabledSiloMax           = 0

ProductionInspector.setValueTimerFrequency  = 60
ProductionInspector.setValueTextMarginX     = 15
ProductionInspector.setValueTextMarginY     = 10
ProductionInspector.setValueTextSize        = 12
ProductionInspector.setTotalMaxProductions  = 40
ProductionInspector.setTotalMaxAnimals      = 20
ProductionInspector.setTotalMaxSilos        = 10
ProductionInspector.isEnabledTextBold       = false

ProductionInspector.colorPointOwned    = {0.182, 0.493, 0.875, 1}
ProductionInspector.colorPointNotOwned = {0.738, 0.738, 0.738, 1}
ProductionInspector.colorProdName      = {0.991, 0.399, 0.038, 1}
ProductionInspector.colorFillType      = {0.700, 0.700, 0.700, 1}
ProductionInspector.colorCaption       = {0.550, 0.550, 0.550, 1}
ProductionInspector.colorSep           = {1.000, 1.000, 1.000, 1}
ProductionInspector.colorEmpty         = {0.830, 0.019, 0.033, 1}
ProductionInspector.colorEmptyInput    = {1.000, 0.200, 0.200, 1}
ProductionInspector.colorAniHome       = {0.182, 0.493, 0.875, 1}
ProductionInspector.colorAniData       = {0.850, 0.850, 0.850, 1}
ProductionInspector.colorSep           = {1.000, 1.000, 1.000, 1}

ProductionInspector.colorStatusInactive = {0.600, 0.600, 0.600, 1}
ProductionInspector.colorStatusRunning  = {1.000, 1.000, 1.000, 1}
ProductionInspector.colorStatusMissing  = {1.000, 0.200, 0.200, 1}
ProductionInspector.colorStatusNoSpace  = {1.000, 0.200, 0.200, 1}

ProductionInspector.setStringTextSep         = " | "
ProductionInspector.setStringTextIndent      = "    "
ProductionInspector.setStringTextEmptyInput  = "--"
ProductionInspector.setStringTextSelling     = "↑"
ProductionInspector.setStringTextStoring     = "↓"
ProductionInspector.setStringTextDistribute  = "→"
ProductionInspector.setStringTextRealStore   = "←"

ProductionInspector.menuTextSizes = { 8, 10, 12, 14, 16 }

ProductionInspector.statusColorsMap = {
	[ProductionPoint.PROD_STATUS.INACTIVE]        = "colorStatusInactive",
	[ProductionPoint.PROD_STATUS.RUNNING]         = "colorStatusRunning",
	[ProductionPoint.PROD_STATUS.MISSING_INPUTS]  = "colorStatusMissing",
	[ProductionPoint.PROD_STATUS.NO_OUTPUT_SPACE] = "colorStatusNoSpace"
}

ProductionInspector.outputModeMap = {
	[ProductionPoint.OUTPUT_MODE.KEEP]         = "setStringTextStoring",
	[ProductionPoint.OUTPUT_MODE.DIRECT_SELL]  = "setStringTextSelling",
	[ProductionPoint.OUTPUT_MODE.AUTO_DELIVER] = "setStringTextDistribute",
	[3]                                        = "setStringTextRealStore",
}

ProductionInspector.lastCoords = {
	prod = {},
	anim = {},
	silo = {}
}

function ProductionInspector:new(mission, i18n, modDirectory, modName)
	local self = setmetatable({}, ProductionInspector_mt)

	self.myName            = "ProductionInspector"
	self.isClient          = mission:getIsClient()
	self.mission           = mission
	self.i18n              = i18n
	self.modDirectory      = modDirectory
	self.modName           = modName
	self.gameInfoDisplay   = mission.hud.gameInfoDisplay
	self.inputHelpDisplay  = mission.hud.inputHelp
	self.speedMeterDisplay = mission.hud.speedMeter
	self.ingameMap         = mission.hud.ingameMap

	self.debugTimerRuns = 0
	self.inspectText    = {}
	self.boxBGColor     = { 544, 20, 200, 44 }
	self.bgName         = 'dataS/menu/blank.png'

	local modDesc       = loadXMLFile("modDesc", modDirectory .. "modDesc.xml");
	self.version        = getXMLString(modDesc, "modDesc.version");
	delete(modDesc)

	self.display_data_prod = { }
	self.display_data_anim = { }
	self.display_data_silo = { }

	self.fill_color_CB = {
		{ 1.00, 0.76, 0.04, 1 },
		{ 0.98, 0.75, 0.15, 1 },
		{ 0.96, 0.73, 0.20, 1 },
		{ 0.94, 0.72, 0.25, 1 },
		{ 0.92, 0.71, 0.29, 1 },
		{ 0.90, 0.69, 0.33, 1 },
		{ 0.87, 0.68, 0.37, 1 },
		{ 0.85, 0.67, 0.40, 1 },
		{ 0.83, 0.66, 0.43, 1 },
		{ 0.81, 0.65, 0.46, 1 },
		{ 0.78, 0.64, 0.49, 1 },
		{ 0.76, 0.62, 0.52, 1 },
		{ 0.73, 0.61, 0.55, 1 },
		{ 0.70, 0.60, 0.57, 1 },
		{ 0.67, 0.59, 0.60, 1 },
		{ 0.64, 0.58, 0.63, 1 },
		{ 0.61, 0.56, 0.65, 1 },
		{ 0.57, 0.55, 0.68, 1 },
		{ 0.53, 0.54, 0.71, 1 },
		{ 0.49, 0.53, 0.73, 1 },
		{ 0.45, 0.52, 0.76, 1 },
		{ 0.39, 0.51, 0.78, 1 },
		{ 0.33, 0.50, 0.81, 1 },
		{ 0.24, 0.49, 0.84, 1 },
		{ 0.05, 0.48, 0.86, 1 }
	}
	self.fill_color = {
		{ 1.00, 0.00, 0.00, 1 },
		{ 1.00, 0.15, 0.00, 1 },
		{ 1.00, 0.22, 0.00, 1 },
		{ 0.99, 0.29, 0.00, 1 },
		{ 0.98, 0.34, 0.00, 1 },
		{ 0.98, 0.38, 0.00, 1 },
		{ 0.96, 0.43, 0.00, 1 },
		{ 0.95, 0.47, 0.00, 1 },
		{ 0.93, 0.51, 0.00, 1 },
		{ 0.91, 0.55, 0.00, 1 },
		{ 0.89, 0.58, 0.00, 1 },
		{ 0.87, 0.62, 0.00, 1 },
		{ 0.84, 0.65, 0.00, 1 },
		{ 0.81, 0.69, 0.00, 1 },
		{ 0.78, 0.72, 0.00, 1 },
		{ 0.75, 0.75, 0.00, 1 },
		{ 0.71, 0.78, 0.00, 1 },
		{ 0.67, 0.81, 0.00, 1 },
		{ 0.63, 0.84, 0.00, 1 },
		{ 0.58, 0.87, 0.00, 1 },
		{ 0.53, 0.89, 0.00, 1 },
		{ 0.46, 0.92, 0.00, 1 },
		{ 0.38, 0.95, 0.00, 1 },
		{ 0.27, 0.98, 0.00, 1 },
		{ 0.00, 1.00, 0.00, 1 }
	}

	self.settingsNames = {
		{"displayModeProd", "int" },
		{"displayModeAnim", "int" },
		{"displayModeSilo", "int" },
		{"isEnabledForceProdJustify", "int"},
		{"isEnabledForceAnimJustify", "int"},
		{"isEnabledForceSiloJustify", "int"},
		{"debugMode", "bool" },
		{"isEnabledProdVisible", "bool" },
		{"isEnabledAnimVisible", "bool" },
		{"isEnabledSiloVisible", "bool" },
		{"isEnabledProdOnlyOwned", "bool" },
		{"isEnabledProdInactivePoint", "bool" },
		{"isEnabledProdInactiveProd", "bool" },
		{"isEnabledProdOutPercent", "bool" },
		{"isEnabledProdOutFillLevel", "bool" },
		{"isEnabledProdInPercent", "bool" },
		{"isEnabledProdInFillLevel", "bool" },
		{"isEnabledProdInputs", "bool" },
		{"isEnabledProdOutputs", "bool" },
		{"isEnabledProdEmptyOutput", "bool" },
		{"isEnabledProdEmptyInput", "bool" },
		{"isEnabledProdFullInput", "bool"},
		{"isEnabledProdShortEmptyOut", "bool" },
		{"isEnabledProdOutputMode", "bool" },
		{"isEnabledProdMax", "int" },
		{"isEnabledSiloMax", "int" },
		{"isEnabledAnimMax", "int" },
		{"isEnabledAnimCount", "bool" },
		{"isEnabledAnimFood", "bool" },
		{"isEnabledAnimFoodTypes", "bool" },
		{"isEnabledAnimProductivity", "bool" },
		{"isEnabledAnimReproduction", "bool" },
		{"isEnabledAnimPuberty", "bool" },
		{"isEnabledAnimHealth", "bool" },
		{"isEnabledAnimOutputs", "bool" },
		{"setValueTimerFrequency", "int" },
		{"setValueTextMarginX", "int" },
		{"setValueTextMarginY", "int" },
		{"setValueTextSize", "int" },
		{"setTotalMaxProductions", "int" },
		{"setTotalMaxAnimals", "int" },
		{"setTotalMaxSilos", "int" },
		{"isEnabledTextBold", "bool" },
		{"colorPointOwned", "color" },
		{"colorPointNotOwned", "color" },
		{"colorProdName", "color" },
		{"colorFillType", "color" },
		{"colorCaption", "color" },
		{"colorSep", "color" },
		{"colorEmpty", "color" },
		{"colorEmptyInput", "color" },
		{"colorAniHome", "color" },
		{"colorAniData", "color" },
		{"colorSep", "color" },
		{"colorStatusInactive", "color" },
		{"colorStatusRunning", "color" },
		{"colorStatusMissing", "color" },
		{"colorStatusNoSpace", "color" },
		{"setStringTextSep", "string" },
		{"setStringTextIndent", "string" },
		{"setStringTextEmptyInput", "string" },
		{"setStringTextSelling", "string" },
		{"setStringTextStoring", "string" },
		{"setStringTextDistribute", "string" },
		{"setStringTextRealStore", "string"}
	}

	return self
end

function ProductionInspector:makeFillColor(percentage, flip)
	local colorIndex = math.floor(percentage/4) + 1
	local colorTab   = nil

	if percentage == 100 then colorIndex = 25 end

	if not flip then colorIndex = 26 - colorIndex end

	if g_gameSettings:getValue('useColorblindMode') then
		colorTab = self.fill_color_CB[colorIndex]
	else
		colorTab = self.fill_color[colorIndex]
	end

	return Utils.getNoNil(colorTab, {1,1,1,1})
end

function ProductionInspector:updateSilos()
	local new_data_table = {}
	local theseSilos     = {}
	local myFarmID       = self.mission:getFarmId()

	if not g_productionInspector.isEnabledSiloVisible then
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
					table.insert(cleanFillLevels, {fillType, roundFillLevel})
					totalFill = totalFill + roundFillLevel
				end
			end

			table.insert(new_data_table, {
				name       = thisSilo:getName(),
				percent    = MathUtil.getFlooredPercent(totalFill, capacity),
				fillLevels = cleanFillLevels
			})
		end
	end

	self.display_data_silo = {unpack(new_data_table)}
end

function ProductionInspector:updateProductions()
	local new_data_table = {}

	if not g_productionInspector.isEnabledProdVisible then
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

				if ( fillLevel > 0 or g_productionInspector.isEnabledProdEmptyInput ) then
					if ( fillPerc < 84 or g_productionInspector.isEnabledProdFullInput ) then
						table.insert(inputTable, { fillType, fillLevel, fillCap, fillPerc })
					end
				end
			end

			for x = 1, #thisProd.outputFillTypeIdsArray do
				local fillType  = thisProd.outputFillTypeIdsArray[x]
				local fillLevel = MathUtil.round(thisProd.storage:getFillLevel(fillType))
				local fillCap   = thisProd.storage:getCapacity(fillType)
				local fillPerc  = MathUtil.getFlooredPercent(fillLevel, fillCap)
				local fillDest  = thisProd:getOutputDistributionMode(fillType)

				if ( fillLevel > 0 or g_productionInspector.isEnabledProdEmptyOutput) then
					table.insert(outputTable, { fillType, fillLevel, fillCap, fillPerc, fillDest })
				end
			end

			if thisProd.productions ~= nil then
				for _, thisProcess in ipairs(thisProd.productions) do
					local prRunning   = thisProd:getIsProductionEnabled(thisProcess.id)
					local prStatus    = thisProd:getProductionStatus(thisProcess.id)
					local prStatusCol = g_productionInspector.statusColorsMap[prStatus] or "colorStatusInactive"
					local prStatusTxt = g_i18n:getText(ProductionPoint.PROD_STATUS_TO_L10N[prStatus]) or "unknown"

					if not weAreWorkingHere and prRunning then
						-- Something in this production point is running
						weAreWorkingHere = true
					end

					if prRunning or g_productionInspector.isEnabledProdInactiveProd then
						table.insert(procTable, {thisProcess.name, prRunning, prStatusTxt, prStatusCol})
					end

				end
			end

			local prodStatusTxt = g_i18n:getText("ui_production_status_inactive")

			if weAreWorkingHere then
				prodStatusTxt = g_i18n:getText("ui_production_status_running")
			end

			if isMine or not g_productionInspector.isEnabledProdOnlyOwned then
				if weAreWorkingHere or g_productionInspector.isEnabledProdInactivePoint then

					table.insert(new_data_table, {
						name       = thisProd:getName(),
						isMine     = isMine,
						prodActive = weAreWorkingHere,
						prodStatus = prodStatusTxt,
						inputs     = inputTable,
						outputs    = outputTable,
						products   = procTable
					})
				end
			end
		end
	end

	self.display_data_prod = {unpack(new_data_table)}
end

function ProductionInspector:updateAnimals()
	local new_data_table = {}

	if not g_productionInspector.isEnabledAnimVisible or g_currentMission == nil or g_currentMission.husbandrySystem == nil then
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

	self.display_data_anim = {unpack(new_data_table)}
end

function ProductionInspector:openConstructionScreen()
	-- hack for construction screen showing blank box.
	g_productionInspector.inspectBox_prod:setVisible(false)
	g_productionInspector.inspectBox_anim:setVisible(false)
	g_productionInspector.inspectBox_silo:setVisible(false)
end

function ProductionInspector:buildSeperator(doSeperate, currentLineTable, currentLineText)
	if doSeperate then
		currentLineTable, currentLineText = self:buildLine(currentLineTable, currentLineText, "colorSep", g_productionInspector.setStringTextSep)
	end
	return true, currentLineTable, currentLineText
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

function ProductionInspector:buildDisplay_anim()
	local working_table = self.display_data_anim
	local currentCount  = 0
	local tempWidth     = 0
	local currentLine   = {}
	local currentText   = ""
	local display_table = {
		maxLength     = 0,
		displayLines  = {},
		fullLines     = {}
	}

	for _, thisDisplay in ipairs(working_table) do
		if ( g_productionInspector.isEnabledAnimMax == 0 or currentCount < g_productionInspector.isEnabledAnimMax ) then
			local doSeperate = false

			currentCount = currentCount + 1

			currentLine, currentText = self:buildLine({}, "", "colorAniHome", thisDisplay.name .. ": ")

			if ( g_productionInspector.isEnabledAnimProductivity ) then
				local fillColor   = self:makeFillColor(thisDisplay.productivity, true)
				doSeperate        = true

				currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", g_i18n:getText("statistic_productivity") .. ": ")
				currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, tostring(thisDisplay.productivity) .. "%")
			end

			if ( g_productionInspector.isEnabledAnimCount ) then
				local fillColor    = self:makeFillColor(math.ceil((thisDisplay.totalAnimals / thisDisplay.maxAnimals) * 100), false)

				doSeperate, currentLine, currentText = self:buildSeperator(doSeperate, currentLine, currentText)

				currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", g_i18n:getText("ui_numAnimals") .. ": ")
				currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, thisDisplay.totalAnimals)
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorSep", " / ")
				currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, thisDisplay.maxAnimals)
			end

			if ( g_productionInspector.isEnabledAnimFood ) then
				local fillColor    = self:makeFillColor(thisDisplay.totalFood, true)

				doSeperate, currentLine, currentText = self:buildSeperator(doSeperate, currentLine, currentText)

				currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", g_i18n:getText("ui_animalFood") .. ": ")
				currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, tostring(thisDisplay.totalFood) .. "%")
			end

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			doSeperate = false
			tempWidth  = getTextWidth(self.inspectText.size, currentText)
			if tempWidth > display_table.maxLength then
				display_table.maxLength = tempWidth
			end

			if ( g_productionInspector.isEnabledAnimHealth or g_productionInspector.isEnabledAnimReproduction or g_productionInspector.isEnabledAnimPuberty ) then
				currentLine, currentText = self:buildLine({}, "", nil, nil)

				if g_productionInspector.isEnabledAnimHealth then
					local fillColor    = self:makeFillColor(thisDisplay.healthFactor, true)

					doSeperate, currentLine, currentText = self:buildSeperator(doSeperate, currentLine, currentText)

					currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", g_i18n:getText("hud_productionInspector_avgHealth") .. ": ")
					currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, tostring(thisDisplay.healthFactor) .. "%")
				end

				if g_productionInspector.isEnabledAnimPuberty then
					local fillColor    = self:makeFillColor(thisDisplay.underageFactor, false)

					doSeperate, currentLine, currentText = self:buildSeperator(doSeperate, currentLine, currentText)

					currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", g_i18n:getText("hud_productionInspector_tooYoung") .. ": ")
					currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, tostring(thisDisplay.underageFactor) .. "%")
				end

				if g_productionInspector.isEnabledAnimReproduction then
					local fillColor    = self:makeFillColor(thisDisplay.breedFactor, true)

					doSeperate, currentLine, currentText = self:buildSeperator(doSeperate, currentLine, currentText)

					currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", g_i18n:getText("hud_productionInspector_avgBreed") .. ": ")
					currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, tostring(thisDisplay.breedFactor) .. "%")
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				tempWidth  = getTextWidth(self.inspectText.size, currentText .. g_productionInspector.setStringTextIndent)
				if tempWidth > display_table.maxLength then
					display_table.maxLength = tempWidth
				end
			end

			if ( g_productionInspector.isEnabledAnimFoodTypes ) then
				currentLine, currentText = self:buildLine({}, "", nil, nil)

				for idx, foodType in ipairs(thisDisplay.foodTypes) do
					if idx > 1 then
						_, currentLine, currentText = self:buildSeperator(true, currentLine, currentText)
					end

					local fillColor    = self:makeFillColor(foodType.percent, true)

					currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", foodType.title .. ": ")
					currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, tostring(foodType.percent) .. "%")
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				tempWidth  = getTextWidth(self.inspectText.size, currentText .. g_productionInspector.setStringTextIndent)
				if tempWidth > display_table.maxLength then
					display_table.maxLength = tempWidth
				end
			end

			if ( g_productionInspector.isEnabledAnimOutputs ) then
				currentLine, currentText = self:buildLine({}, "", nil, nil)

				for idx, outType in ipairs(thisDisplay.outTypes) do
					if idx > 1 then
						_, currentLine, currentText = self:buildSeperator(true, currentLine, currentText)
					end

					local fillColor    = self:makeFillColor(outType.percent, (not outType.invert))

					currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", outType.title .. ": ")
					currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, tostring(outType.fillLevel) .. " (" .. tostring(outType.percent) .. "%)")
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				tempWidth  = getTextWidth(self.inspectText.size, currentText .. g_productionInspector.setStringTextIndent)
				if tempWidth > display_table.maxLength then
					display_table.maxLength = tempWidth
				end
			end

			table.insert(display_table.displayLines, false)
			table.insert(display_table.fullLines, false)
		end
	end
	return display_table
end

function ProductionInspector:buildDisplay_prod()
	local working_table = self.display_data_prod
	local currentCount  = 0
	local tempWidth     = 0
	local currentLine   = {}
	local currentText   = ""
	local display_table = {
		maxLength     = 0,
		displayLines  = {},
		fullLines     = {}
	}

	for _, thisDisplay in ipairs(working_table) do
		if ( g_productionInspector.isEnabledProdMax == 0 or currentCount < g_productionInspector.isEnabledProdMax ) then
			currentCount = currentCount + 1

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
				if idx > 1 then
					_, currentLine, currentText = self:buildSeperator(true, currentLine, currentText)
				end

				currentLine, currentText = self:buildLine(currentLine, currentText, "colorProdName", prodLine[1] .. ": ")
				currentLine, currentText = self:buildLine(currentLine, currentText, prodLine[4], prodLine[3])
			end

			if thisDisplay.products == nil or #thisDisplay.products == 0 then
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
			end

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			tempWidth = getTextWidth(self.inspectText.size, currentText .. g_productionInspector.setStringTextIndent)
			if tempWidth > display_table.maxLength then
				display_table.maxLength = tempWidth
			end

			-- Production point inputs
			if g_productionInspector.isEnabledProdInputs then
				currentLine, currentText = self:buildLine({}, "", nil, nil)
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorCaption", g_i18n:getText("ui_productions_incomingMaterials") .. " - ")

				for idx, inputs in ipairs(thisDisplay.inputs) do
					local thisFillType = g_fillTypeManager:getFillTypeByIndex(inputs[1])
					local fillColor    = self:makeFillColor(inputs[4], true)

					if idx > 1 then
						_, currentLine, currentText = self:buildSeperator(true, currentLine, currentText)
					end

					currentLine, currentText = self:buildLine(currentLine, currentText, "colorFillType", thisFillType.title .. ": ")

					if ( inputs[2] == 0 and g_productionInspector.isEnabledProdShortEmptyOut ) then
						currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmptyInput", g_productionInspector.setStringTextEmptyInput)
					else
						local levelString = ""
						if g_productionInspector.isEnabledProdInFillLevel then
							levelString = levelString .. tostring(inputs[2])
						end
						if g_productionInspector.isEnabledProdInPercent then
							if g_productionInspector.isEnabledProdInFillLevel then
								levelString = levelString .. " (" .. tostring(inputs[4]) .. "%)"
							else
								levelString = levelString .. tostring(inputs[4]) .. "%"
							end
						end
						currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, levelString)
					end
				end

				if thisDisplay.inputs == nil or #thisDisplay.inputs == 0 then
					currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				tempWidth = getTextWidth(self.inspectText.size, currentText .. g_productionInspector.setStringTextIndent)
				if tempWidth > display_table.maxLength then
					display_table.maxLength = tempWidth
				end
			end

			if g_productionInspector.isEnabledProdOutputs then
				currentLine, currentText = self:buildLine({}, "", nil, nil)
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorCaption", g_i18n:getText("ui_productions_outgoingProducts") .. " - ")

				for idx, outputs in ipairs(thisDisplay.outputs) do
					local thisFillType = g_fillTypeManager:getFillTypeByIndex(outputs[1])
					local fillColor    = self:makeFillColor(outputs[4], false)

					if idx > 1 then
						_, currentLine, currentText = self:buildSeperator(true, currentLine, currentText)
					end

					local fillTypeString = thisFillType.title

					if g_productionInspector.isEnabledProdOutputMode then
						fillTypeString = fillTypeString .. " " .. g_productionInspector[g_productionInspector.outputModeMap[outputs[5]]] .. " "
					else
						fillTypeString = fillTypeString .. ": "
					end

					currentLine, currentText = self:buildLine(currentLine, currentText, "colorFillType", fillTypeString)

					local levelString = ""
					if g_productionInspector.isEnabledProdOutFillLevel then
						levelString = levelString .. tostring(outputs[2])
					end

					if g_productionInspector.isEnabledProdOutPercent then
						if g_productionInspector.isEnabledProdOutFillLevel then
							levelString = levelString .. " (" .. tostring(outputs[4]) .. "%)"
						else
							levelString = levelString .. tostring(outputs[4]) .. "%"
						end
					end
					currentLine, currentText = self:buildLine(currentLine, currentText, fillColor, levelString)
				end

				if thisDisplay.outputs == nil or #thisDisplay.outputs == 0 then
					currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
				end

				table.insert(display_table.displayLines, currentLine)
				table.insert(display_table.fullLines, currentText)

				tempWidth = getTextWidth(self.inspectText.size, currentText .. g_productionInspector.setStringTextIndent)
				if tempWidth > display_table.maxLength then
					display_table.maxLength = tempWidth
				end
			end

			table.insert(display_table.displayLines, false)
			table.insert(display_table.fullLines, false)
		end
	end
	return display_table
end

function ProductionInspector:buildDisplay_silo()
	local working_table = self.display_data_silo
	local currentCount  = 0
	local tempWidth     = 0
	local currentLine   = {}
	local currentText   = ""
	local display_table = {
		maxLength     = 0,
		displayLines  = {},
		fullLines     = {}
	}

	for _, thisDisplay in ipairs(working_table) do
		if ( g_productionInspector.isEnabledSiloMax == 0 or currentCount < g_productionInspector.isEnabledSiloMax ) then
			currentCount = currentCount + 1

			currentLine, currentText = self:buildLine({}, "", "colorAniHome", thisDisplay.name .. ": ")
			currentLine, currentText = self:buildLine(currentLine, currentText, self:makeFillColor(thisDisplay.percent, false), tostring(thisDisplay.percent) .. "%")

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			tempWidth  = getTextWidth(self.inspectText.size, currentText)
			if tempWidth > display_table.maxLength then
				display_table.maxLength = tempWidth
			end

			currentLine, currentText = self:buildLine({}, "", nil, nil)

			for idx, thisFill in ipairs(thisDisplay.fillLevels) do
				if idx > 1 then
					_, currentLine, currentText = self:buildSeperator(true, currentLine, currentText)
				end

				local thisFillType = g_fillTypeManager:getFillTypeByIndex(thisFill[1])

				currentLine, currentText = self:buildLine(currentLine, currentText, "colorAniData", thisFillType.title .. ": ")
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorFillType", thisFill[2])
			end

			if thisDisplay.fillLevels == nil or #thisDisplay.fillLevels == 0 then
				currentLine, currentText = self:buildLine(currentLine, currentText, "colorEmpty", g_i18n:getText("ui_none"))
			end

			table.insert(display_table.displayLines, currentLine)
			table.insert(display_table.fullLines, currentText)

			tempWidth  = getTextWidth(self.inspectText.size, currentText .. g_productionInspector.setStringTextIndent)
			if tempWidth > display_table.maxLength then
				display_table.maxLength = tempWidth
			end

			table.insert(display_table.displayLines, false)
			table.insert(display_table.fullLines, false)
		end
	end
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
		thisDisplayMode = g_productionInspector.displayModeProd
	elseif dataType == "anim" then
		thisDisplayMode = g_productionInspector.displayModeAnim
	else
		thisDisplayMode = g_productionInspector.displayModeSilo
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

	if dataType == "anim" and g_productionInspector.displayModeProd == g_productionInspector.displayModeAnim and g_productionInspector.isEnabledProdVisible then
		if ( thisDisplayMode < 3 ) then
			overlayY  = overlayY - self.lastCoords.prod[3] - (self.marginHeight * 2)
			dispTextY = dispTextY - self.lastCoords.prod[3] - (self.marginHeight * 2)
		else
			overlayY  = overlayY + self.lastCoords.prod[3] + (self.marginHeight * 2)
			dispTextY = dispTextY + self.lastCoords.prod[3] + (self.marginHeight * 2)
		end
	end
	if dataType == "silo" then
		local sameAsAnimal = g_productionInspector.displayModeAnim == g_productionInspector.displayModeSilo and g_productionInspector.isEnabledAnimVisible
		local sameAsProd   = g_productionInspector.displayModeProd == g_productionInspector.displayModeSilo and g_productionInspector.isEnabledProdVisible

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
	if not g_productionInspector.isEnabledProdVisible then return false end
	return self:shouldDraw_any(g_productionInspector.displayModeProd)
end

function ProductionInspector:shouldDraw_anim()
	if #self.display_data_anim == 0 then return false end
	if not g_productionInspector.isEnabledAnimVisible then return false end
	return self:shouldDraw_any(g_productionInspector.displayModeAnim)
end

function ProductionInspector:shouldDraw_silo()
	if #self.display_data_silo == 0 then return false end
	if not g_productionInspector.isEnabledSiloVisible then return false end
	return self:shouldDraw_any(g_productionInspector.displayModeSilo)
end

function ProductionInspector:draw()
	if not self.isClient then return end

	if self.inspectBox_prod ~= nil then
		if not self:shouldDraw_prod() then
			self.inspectBox_prod:setVisible(false)
		else
			local thisDisplayTable = self:buildDisplay_prod()
			local overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW = self:getSizes("prod", thisDisplayTable)

			self.lastCoords.prod = {
				overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW
			}

			setTextBold(g_productionInspector.isEnabledTextBold)
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
						fullTextSoFar = self:renderText(dispTextX, dispTextY, fullTextSoFar, thisPart[2], g_productionInspector.displayModeProd, indentLine, fullTextLine, dispTextW, g_productionInspector.isEnabledForceProdJustify)
					end
					dispTextY = dispTextY - self.inspectText.size
				end
			end

			self.inspectBox_prod:setVisible(true)
			self.inspectBox_prod.overlay:setPosition(overlayX, overlayY)
			self.inspectBox_prod.overlay:setDimension(overlayW, overlayH)

			setTextColor(1,1,1,1)
			setTextAlignment(RenderText.ALIGN_LEFT)
			setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
			setTextBold(false)
		end
	end
	if self.inspectBox_anim ~= nil then
		if not self:shouldDraw_anim() then
			self.inspectBox_anim:setVisible(false)
		else
			local thisDisplayTable = self:buildDisplay_anim()
			local overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW = self:getSizes("anim", thisDisplayTable)

			self.lastCoords.anim = {
				overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW
			}

			setTextBold(g_productionInspector.isEnabledTextBold)
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
						fullTextSoFar = self:renderText(dispTextX, dispTextY, fullTextSoFar, thisPart[2], g_productionInspector.displayModeAnim, indentLine, fullTextLine, dispTextW, g_productionInspector.isEnabledForceAnimJustify)
					end
					dispTextY = dispTextY - self.inspectText.size
				end
			end

			self.inspectBox_anim:setVisible(true)
			self.inspectBox_anim.overlay:setPosition(overlayX, overlayY)
			self.inspectBox_anim.overlay:setDimension(overlayW, overlayH)

			setTextColor(1,1,1,1)
			setTextAlignment(RenderText.ALIGN_LEFT)
			setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
			setTextBold(false)
		end
	end
	if self.inspectBox_silo ~= nil then
		if not self:shouldDraw_silo() then
			self.inspectBox_silo:setVisible(false)
		else
			local thisDisplayTable = self:buildDisplay_silo()
			local overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW = self:getSizes("silo", thisDisplayTable)

			self.lastCoords.silo = {
				overlayX, overlayY, overlayH, overlayW, dispTextX, dispTextY, dispTextH, dispTextW
			}

			setTextBold(g_productionInspector.isEnabledTextBold)
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
						fullTextSoFar = self:renderText(dispTextX, dispTextY, fullTextSoFar, thisPart[2], g_productionInspector.displayModeSilo, indentLine, fullTextLine, dispTextW, g_productionInspector.isEnabledForceSiloJustify)
					end
					dispTextY = dispTextY - self.inspectText.size
				end
			end

			self.inspectBox_silo:setVisible(true)
			self.inspectBox_silo.overlay:setPosition(overlayX, overlayY)
			self.inspectBox_silo.overlay:setDimension(overlayW, overlayH)

			setTextColor(1,1,1,1)
			setTextAlignment(RenderText.ALIGN_LEFT)
			setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
			setTextBold(false)
		end
	end
end

function ProductionInspector:update(dt)
	if not self.isClient then
		return
	end

	if g_updateLoopIndex % g_productionInspector.setValueTimerFrequency == 0 then
		-- Lets not be rediculous, only update the vehicles "infrequently"
		self:updateProductions()
		self:updateAnimals()
		self:updateSilos()
	end
end

function ProductionInspector:getColorQuad(name)
	if name == nil then return { 1,1,1,1 } end
	return Utils.getNoNil(g_productionInspector[name], {1,1,1,1})
end

function ProductionInspector:renderText(x, y, fullTextSoFar, text, displayMode, indentLine, fullTextTotal, dispTextW, forceJustify)
	if text == nil then
		if ( displayMode % 2 ~= 0 and forceJustify == 1 ) or forceJustify == 2 then
			text = g_productionInspector.setStringTextIndent
		else
			return fullTextSoFar
		end
	end

	local newX = x + getTextWidth(self.inspectText.size, fullTextSoFar)

	if ( displayMode % 2 == 0  and forceJustify == 1 ) or forceJustify == 3 then
		-- right justify
		newX = newX + ( dispTextW - getTextWidth(self.inspectText.size, fullTextTotal))

		if indentLine then
			newX = newX - getTextWidth(self.inspectText.size, g_productionInspector.setStringTextIndent)
		end
	end

	renderText(newX, y, self.inspectText.size, text)
	return text .. fullTextSoFar
end


function ProductionInspector:onStartMission(mission)
	-- Load the mod, make the box that info lives in.
	print("~~" .. self.myName .." :: version " .. self.version .. " loaded.")
	if not self.isClient then
		return
	end

	-- Just call both, load fails gracefully if it doesn't exists.
	self:loadSettings()
	self:saveSettings()

	if ( g_productionInspector.debugMode ) then
		print("~~" .. self.myName .." :: onStartMission")
	end

	self:createTextBox()
end

function ProductionInspector:findOrigin(dataType)
	local tmpX            = 0
	local tmpY            = 0
	local thisDisplayMode = 0

	if dataType == "prod" then
		thisDisplayMode = g_productionInspector.displayModeProd
	elseif dataType == "anim" then
		thisDisplayMode = g_productionInspector.displayModeAnim
	else
		thisDisplayMode = g_productionInspector.displayModeSilo
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
			if g_modIsLoaded["FS22_EnhancedVehicle"] then
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
	if ( g_productionInspector.debugMode ) then
		print("~~" .. self.myName .." :: createTextBoxes")
	end

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

	self.inspectText.marginWidth, self.inspectText.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector({g_productionInspector.setValueTextMarginX, g_productionInspector.setValueTextMarginY})
	self.inspectText.size = self.gameInfoDisplay:scalePixelToScreenHeight(g_productionInspector.setValueTextSize)
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

function ProductionInspector:saveSettings()
	local savegameFolderPath = ('%smodSettings/FS22_ProductionExplorer/savegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
	local savegameFile       = savegameFolderPath .. "/productionInspector.xml"

	if ( not fileExists(savegameFile) ) then
		createFolder(('%smodSettings/FS22_ProductionExplorer'):format(getUserProfileAppPath()))
		createFolder(savegameFolderPath)
	end

	local key = "productionInspector"
	local xmlFile = createXMLFile(key, savegameFile, key)

	for _, setting in pairs(g_productionInspector.settingsNames) do
		if ( setting[2] == "bool" ) then
			setXMLBool(xmlFile, key .. "." .. setting[1] .. "#value", g_productionInspector[setting[1]])
		elseif ( setting[2] == "string" ) then
			setXMLString(xmlFile, key .. "." .. setting[1] .. "#value", g_productionInspector[setting[1]])
		elseif ( setting[2] == "int" ) then
			setXMLInt(xmlFile, key .. "." .. setting[1] .. "#value", g_productionInspector[setting[1]])
		elseif ( setting[2] == "float" ) then
			setXMLFloat(xmlFile, key .. "." .. setting[1] .. "#value", g_productionInspector[setting[1]])
		elseif ( setting[2] == "color" ) then
			local r, g, b, a = unpack(g_productionInspector[setting[1]])
			setXMLFloat(xmlFile, key .. "." .. setting[1] .. "#r", r)
			setXMLFloat(xmlFile, key .. "." .. setting[1] .. "#g", g)
			setXMLFloat(xmlFile, key .. "." .. setting[1] .. "#b", b)
			setXMLFloat(xmlFile, key .. "." .. setting[1] .. "#a", a)
		end
	end

	saveXMLFile(xmlFile)
	print("~~" .. g_productionInspector.myName .." :: saved config file")
end

function ProductionInspector:loadSettings()
	local savegameFolderPath = ('%smodSettings/FS22_ProductionExplorer/savegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
	local key                = "productionInspector"

	if fileExists(savegameFolderPath .. "/productionInspector.xml") then
		print("~~" .. self.myName .." :: loading config file")
		local xmlFile = loadXMLFile(key, savegameFolderPath .. "/productionInspector.xml")

		for _, setting in pairs(self.settingsNames) do
			if ( setting[2] == "bool" ) then
				g_productionInspector[setting[1]] = Utils.getNoNil(getXMLBool(xmlFile, key .. "." .. setting[1] .. "#value"), g_productionInspector[setting[1]])
			elseif ( setting[2] == "string" ) then
				g_productionInspector[setting[1]] = Utils.getNoNil(getXMLString(xmlFile, key .. "." .. setting[1] .. "#value"), g_productionInspector[setting[1]])
			elseif ( setting[2] == "int" ) then
				g_productionInspector[setting[1]] = Utils.getNoNil(getXMLInt(xmlFile, key .. "." .. setting[1] .. "#value"), g_productionInspector[setting[1]])
			elseif ( setting[2] == "float" ) then
				g_productionInspector[setting[1]] = Utils.getNoNil(getXMLFloat(xmlFile, key .. "." .. setting[1] .. "#value"), g_productionInspector[setting[1]])
			elseif ( setting[2] == "color" ) then
				local r, g, b, a = unpack(g_productionInspector[setting[1]])
				r = Utils.getNoNil(getXMLFloat(xmlFile, key .. "." .. setting[1] .. "#r"), r)
				g = Utils.getNoNil(getXMLFloat(xmlFile, key .. "." .. setting[1] .. "#g"), g)
				b = Utils.getNoNil(getXMLFloat(xmlFile, key .. "." .. setting[1] .. "#b"), b)
				a = Utils.getNoNil(getXMLFloat(xmlFile, key .. "." .. setting[1] .. "#a"), a)
				g_productionInspector[setting[1]] = {r, g, b, a}
			end
		end

		delete(xmlFile)
		-- Adjust text size
		g_productionInspector.inspectText.size = g_productionInspector.gameInfoDisplay:scalePixelToScreenHeight(g_productionInspector.setValueTextSize)
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
	if ( thisModEnviroment.debugMode ) then
		print("~~" .. thisModEnviroment.myName .." :: reload settings from disk")
	end
	thisModEnviroment:loadSettings()
end

function ProductionInspector:actionToggleProdVisible()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]
	if ( thisModEnviroment.debugMode ) then
		print("~~" .. thisModEnviroment.myName .." :: toggle prod display on/off")
	end
	thisModEnviroment.isEnabledProdVisible = (not thisModEnviroment.isEnabledProdVisible)
	thisModEnviroment:saveSettings()
end

function ProductionInspector:actionToggleAnimVisible()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]
	if ( thisModEnviroment.debugMode ) then
		print("~~" .. thisModEnviroment.myName .." :: toggle anim display on/off")
	end
	thisModEnviroment.isEnabledAnimVisible = (not thisModEnviroment.isEnabledAnimVisible)
	thisModEnviroment:saveSettings()
end

function ProductionInspector:actionToggleSiloVisible()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]
	if ( thisModEnviroment.debugMode ) then
		print("~~" .. thisModEnviroment.myName .." :: toggle silo display on/off")
	end
	thisModEnviroment.isEnabledSiloVisible = (not thisModEnviroment.isEnabledSiloVisible)
	thisModEnviroment:saveSettings()
end

function ProductionInspector.initGui(self)
	local boolMenuOptions = {
		"ProdVisible", "AnimVisible", "SiloVisible",

		"ProdOnlyOwned", "ProdInactivePoint", "ProdInactiveProd", "ProdOutPercent",
		"ProdOutFillLevel", "ProdInPercent", "ProdInFillLevel", "ProdInputs",
		"ProdOutputs", "ProdEmptyOutput", "ProdEmptyInput", "ProdShortEmptyOut",
		"ProdFullInput","ProdOutputMode",

		"AnimCount", "AnimFood", "AnimFoodTypes", "AnimProductivity", "AnimReproduction",
		"AnimPuberty", "AnimHealth", "AnimOutputs",
		"TextBold",
	}

	if not g_productionInspector.createdGUI then -- Skip if we've already done this once
		g_productionInspector.createdGUI = true

		for _, optName in ipairs({"DisplayModeProd", "DisplayModeAnim", "DisplayModeSilo"}) do
			local fullName           = "menuOption_" .. optName
			self[fullName]           = self.checkInvertYLook:clone()
			self[fullName]["target"] = g_productionInspector
			self[fullName]["id"]     = "productionInspector_" .. optName
			self[fullName]:setCallback("onClickCallback", "onMenuOptionChanged_" .. optName)
			self[fullName]:setDisabled(false)

			local settingTitle = self[fullName]["elements"][4]
			local toolTip      = self[fullName]["elements"][6]

			self[fullName]:setTexts({
				g_i18n:getText("setting_productionInspector_DisplayMode1"),
				g_i18n:getText("setting_productionInspector_DisplayMode2"),
				g_i18n:getText("setting_productionInspector_DisplayMode3"),
				g_i18n:getText("setting_productionInspector_DisplayMode4")
			})

			settingTitle:setText(g_i18n:getText("setting_productionInspector_" .. optName))
			toolTip:setText(g_i18n:getText("toolTip_productionInspector_" .. optName))
		end

		for _, optName in ipairs({"ProdMax", "AnimMax", "SiloMax"}) do
			local fullName           = "menuOption_" .. optName
			self[fullName]           = self.checkInvertYLook:clone()
			self[fullName]["target"] = g_productionInspector
			self[fullName]["id"]     = "productionInspector_" .. optName
			self[fullName]:setCallback("onClickCallback", "onMenuOptionChanged_" .. optName)
			self[fullName]:setDisabled(false)

			local settingTitle = self[fullName]["elements"][4]
			local toolTip      = self[fullName]["elements"][6]

			local numRange = {g_i18n:getText("ui_no")}

			local maxNum = g_productionInspector.setTotalMaxProductions
			if optName == "AnimMax"  then
				maxNum = g_productionInspector.setTotalMaxAnimals
			elseif optName == "SiloMax" then
				maxNum = g_productionInspector.setTotalMaxSilos
			end

			for i=1, maxNum do
				table.insert(numRange, tostring(i))
			end

			self[fullName]:setTexts(numRange)

			settingTitle:setText(g_i18n:getText("setting_productionInspector_" .. optName))
			toolTip:setText(g_i18n:getText("toolTip_productionInspector_" .. optName))
		end

		for _, optName in ipairs({"ForceProdJustify", "ForceAnimJustify", "ForceSiloJustify"}) do
			local fullName           = "menuOption_" .. optName
			self[fullName]           = self.checkInvertYLook:clone()
			self[fullName]["target"] = g_productionInspector
			self[fullName]["id"]     = "productionInspector_" .. optName
			self[fullName]:setCallback("onClickCallback", "onMenuOptionChanged_" .. optName)
			self[fullName]:setDisabled(false)

			local settingTitle = self[fullName]["elements"][4]
			local toolTip      = self[fullName]["elements"][6]

			self[fullName]:setTexts({
				g_i18n:getText("ui_no"),
				g_i18n:getText("info_tipSideLeft"),
				g_i18n:getText("info_tipSideRight")
			})

			settingTitle:setText(g_i18n:getText("setting_productionInspector_" .. optName))
			toolTip:setText(g_i18n:getText("toolTip_productionInspector_" .. optName))
		end

		for _, optName in pairs(boolMenuOptions) do
			local fullName           = "menuOption_" .. optName
			self[fullName]           = self.checkInvertYLook:clone()
			self[fullName]["target"] = g_productionInspector
			self[fullName]["id"]     = "productionInspector_" .. optName
			self[fullName]:setCallback("onClickCallback", "onMenuOptionChanged_boolOpt")
			self[fullName]:setDisabled(false)

			local settingTitle = self[fullName]["elements"][4]
			local toolTip      = self[fullName]["elements"][6]

			self[fullName]:setTexts({g_i18n:getText("ui_no"), g_i18n:getText("ui_yes")})

			settingTitle:setText(g_i18n:getText("setting_productionInspector_" .. optName))
			toolTip:setText(g_i18n:getText("toolTip_productionInspector_" .. optName))
		end

		self.menuOption_TextSize        = self.checkInvertYLook:clone()
		self.menuOption_TextSize.target = g_productionInspector
		self.menuOption_TextSize.id     = "productionInspector_setValueTextSize"
		self.menuOption_TextSize:setCallback("onClickCallback", "onMenuOptionChanged_setValueTextSize")
		self.menuOption_TextSize:setDisabled(false)

		local settingTitle = self.menuOption_TextSize.elements[4]
		local toolTip      = self.menuOption_TextSize.elements[6]

		local textSizeTexts = {}
		for _, size in ipairs(g_productionInspector.menuTextSizes) do
			table.insert(textSizeTexts, tostring(size) .. " px")
		end
		self.menuOption_TextSize:setTexts(textSizeTexts)

		settingTitle:setText(g_i18n:getText("setting_productionInspector_TextSize"))
		toolTip:setText(g_i18n:getText("toolTip_productionInspector_TextSize"))


		local title = TextElement.new()
		title:applyProfile("settingsMenuSubtitle", true)
		title:setText(g_i18n:getText("title_productionInspector"))

		self.boxLayout:addElement(title)

		for _, value in ipairs({"DisplayModeProd", "DisplayModeAnim", "DisplayModeSilo"}) do
			local thisOption = "menuOption_" .. value
			self.boxLayout:addElement(self[thisOption])
		end

		for _, value in ipairs(boolMenuOptions) do
			local thisOption = "menuOption_" .. value
			self.boxLayout:addElement(self[thisOption])
		end

		self.boxLayout:addElement(self.menuOption_TextSize)

		for _, value in ipairs({"ProdMax", "AnimMax", "SiloMax"}) do
			local thisOption = "menuOption_" .. value
			self.boxLayout:addElement(self[thisOption])
		end

		for _, value in ipairs({"ForceProdJustify", "ForceAnimJustify", "ForceSiloJustify"}) do
			local thisOption = "menuOption_" .. value
			self.boxLayout:addElement(self[thisOption])
		end
	end

	self.menuOption_DisplayModeProd:setState(g_productionInspector.displayModeProd)
	self.menuOption_DisplayModeAnim:setState(g_productionInspector.displayModeAnim)
	self.menuOption_DisplayModeSilo:setState(g_productionInspector.displayModeSilo)
	self.menuOption_ForceProdJustify:setState(g_productionInspector.isEnabledForceProdJustify)
	self.menuOption_ForceAnimJustify:setState(g_productionInspector.isEnabledForceAnimJustify)
	self.menuOption_ForceSiloJustify:setState(g_productionInspector.isEnabledForceSiloJustify)
	self.menuOption_ProdMax:setState(g_productionInspector.isEnabledProdMax + 1)
	self.menuOption_AnimMax:setState(g_productionInspector.isEnabledAnimMax + 1)
	self.menuOption_SiloMax:setState(g_productionInspector.isEnabledSiloMax + 1)

	local textSizeState = 3 -- backup value for it set odd in the xml.
	for idx, textSize in ipairs(g_productionInspector.menuTextSizes) do
		if g_productionInspector.setValueTextSize == textSize then
			textSizeState = idx
		end
	end
	self.menuOption_TextSize:setState(textSizeState)

	for _, value in ipairs(boolMenuOptions) do
		local thisMenuOption = "menuOption_" .. value
		local thisRealOption = "isEnabled" .. value
		self[thisMenuOption]:setIsChecked(g_productionInspector[thisRealOption])
	end
end

function ProductionInspector:onMenuOptionChanged_ForceProdJustify(state)
	self.isEnabledForceProdJustify = state
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_ForceAnimJustify(state)
	self.isEnabledForceAnimJustify = state
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_ForceSiloJustify(state)
	self.isEnabledForceSiloJustify = state
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_DisplayModeProd(state)
	self.displayModeProd = state
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_DisplayModeAnim(state)
	self.displayModeAnim = state
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_DisplayModeSilo(state)
	self.displayModeSilo = state
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_ProdMax(state)
	self.isEnabledProdMax = state - 1
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_AnimMax(state)
	self.isEnabledAnimMax = state - 1
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_SiloMax(state)
	self.isEnabledSiloMax = state - 1
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_setValueTextSize(state)
	self.setValueTextSize = g_productionInspector.menuTextSizes[state]
	self.inspectText.size = self.gameInfoDisplay:scalePixelToScreenHeight(self.setValueTextSize)
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_boolOpt(state, info)
	local thisOption = "isEnabled" .. string.sub(info.id,21)
	self[thisOption] = state == CheckedOptionElement.STATE_CHECKED
	ProductionInspector:saveSettings()
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