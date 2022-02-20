--
-- Mod: FS22_ProductionInspector
--
-- Author: JTSage
-- source: https://github.com/jtsage/FS22_Production_Inspector

ProductionInspector= {}

local ProductionInspector_mt = Class(ProductionInspector)


-- default options
ProductionInspector.displayMode     = 1 -- 1: top left, 2: top right (default), 3: bot left, 4: bot right, 5: custom
ProductionInspector.displayMode5X   = 0.2
ProductionInspector.displayMode5Y   = 0.2

ProductionInspector.debugMode       = true

ProductionInspector.isEnabledVisible           = true
ProductionInspector.isEnabledOnlyOwned         = true
ProductionInspector.isEnabledShowInactivePoint = false
ProductionInspector.isEnabledShowInactiveProd  = false
ProductionInspector.isEnabledShowOutPercent    = true
ProductionInspector.isEnabledShowOutFillLevel  = true
ProductionInspector.isEnabledShowInPercent     = true
ProductionInspector.isEnabledShowInFillLevel   = true
ProductionInspector.isEnabledShowInputs        = true
ProductionInspector.isEnabledShowOutputs       = true
ProductionInspector.isEnabledShowEmptyOutput   = false
ProductionInspector.isEnabledShowEmptyInput    = true
ProductionInspector.isEnabledShortEmptyOutput  = true

ProductionInspector.setValueTimerFrequency  = 60
ProductionInspector.setValueTextMarginX     = 15
ProductionInspector.setValueTextMarginY     = 10
ProductionInspector.setValueTextSize        = 12
ProductionInspector.isEnabledTextBold       = false

ProductionInspector.colorPointOwned    = {0.182, 0.493, 0.875, 1}
ProductionInspector.colorPointNotOwned = {0.738, 0.738, 0.738, 1}
ProductionInspector.colorProdName      = {0.991, 0.399, 0.038, 1}
ProductionInspector.colorFillType      = {0.700, 0.700, 0.700, 1}
ProductionInspector.colorCaption       = {0.550, 0.550, 0.550, 1}
ProductionInspector.colorSep           = {1.000, 1.000, 1.000, 1}
ProductionInspector.colorEmpty         = {0.830, 0.019, 0.033, 1}
ProductionInspector.colorEmptyInput    = {1.000, 0.200, 0.200, 1}

ProductionInspector.colorStatusInactive = {0.600, 0.600, 0.600, 1}
ProductionInspector.colorStatusRunning  = {1.000, 1.000, 1.000, 1}
ProductionInspector.colorStatusMissing  = {1.000, 0.200, 0.200, 1}
ProductionInspector.colorStatusNoSpace  = {1.000, 0.200, 0.200, 1}

ProductionInspector.setStringTextSep         = " | "
ProductionInspector.setStringTextIndent      = "    "
ProductionInspector.setStringTextEmptyInput  = "--"

ProductionInspector.statusColorsMap = {
	[ProductionPoint.PROD_STATUS.INACTIVE]        = "colorStatusInactive",
	[ProductionPoint.PROD_STATUS.RUNNING]         = "colorStatusRunning",
	[ProductionPoint.PROD_STATUS.MISSING_INPUTS]  = "colorStatusMissing",
	[ProductionPoint.PROD_STATUS.NO_OUTPUT_SPACE] = "colorStatusNoSpace"
}

function ProductionInspector:new(mission, i18n, modDirectory, modName)
	local self = setmetatable({}, ProductionInspector_mt)

	self.myName            = "ProductionInspector"
	self.isServer          = mission:getIsServer()
	self.isClient          = mission:getIsClient()
	self.isMPGame          = g_currentMission.missionDynamicInfo.isMultiplayer
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

	self.display_data = { }

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
		{"displayMode", "int"},
		{"displayMode5X", "float"},
		{"displayMode5Y", "float"},
		{"debugMode", "bool"},
		{"isEnabledVisible", "bool"},
		{"isEnabledOnlyOwned", "bool"},
		{"isEnabledShowInactivePoint", "bool"},
		{"isEnabledShowInactiveProd", "bool"},
		{"isEnabledShowOutPercent", "bool"},
		{"isEnabledShowOutFillLevel", "bool"},
		{"isEnabledShowInPercent", "bool"},
		{"isEnabledShowInFillLevel", "bool"},
		{"isEnabledShowInputs", "bool"},
		{"isEnabledShowOutputs", "bool"},
		{"isEnabledShowEmptyInput", "bool"},
		{"isEnabledShowEmptyOutput", "bool"},
		{"isEnabledShortEmptyOutput", "bool"},
		{"setValueTimerFrequency", "int"},
		{"setValueTextMarginX", "int"},
		{"setValueTextMarginY", "int"},
		{"setValueTextSize", "int"},
		{"isEnabledTextBold", "bool"},
		{"colorPointOwned", "color"},
		{"colorPointNotOwned", "color"},
		{"colorProdName", "color"},
		{"colorFillType", "color"},
		{"colorCaption", "color"},
		{"colorSep", "color"},
		{"colorEmpty", "color"},
		{"colorEmptyInput", "color"},
		{"colorStatusInactive", "color"},
		{"colorStatusRunning", "color"},
		{"colorStatusMissing", "color"},
		{"colorStatusNoSpace", "color"},
		{"setStringTextSep", "string"},
		{"setStringTextIndent", "string"},
		{"setStringTextEmptyInput", "string"}
	}

	return self
end

function ProductionInspector:makeFillColor(percentage, flip)
	local colorIndex = math.floor(percentage/4) + 1
	local colorTab = nil

	if percentage == 100 then colorIndex = 25 end

	if not flip then colorIndex = 26 - colorIndex end

	if g_gameSettings:getValue('useColorblindMode') then
		colorTab = self.fill_color_CB[colorIndex]
	else
		colorTab = self.fill_color[colorIndex]
	end

	if colorTab ~= nil then
		return colorTab
	else
		return {1,1,1,1}
	end
end

function ProductionInspector:updateProductions()
	local new_data_table = {}

	if g_currentMission ~= nil and g_currentMission.productionChainManager ~= nil then
		for v=1, #g_currentMission.productionChainManager.productionPoints do
			local thisProd = g_currentMission.productionChainManager.productionPoints[v]

			local ownedBy          = thisProd:getOwnerFarmId()
			local isMine           = ownedBy == self.mission:getFarmId()
			local weAreWorkingHere = false

			local inputTable  = {}
			local outputTable = {}
			local procTable   = {}

			for x = 1, #thisProd.inputFillTypeIdsArray do
				local fillType  = thisProd.inputFillTypeIdsArray[x]
				local fillLevel = thisProd.storage:getFillLevel(fillType)
				local fillCap   = thisProd.storage:getCapacity(fillType)
				local fillPerc  = math.ceil((fillLevel / fillCap) * 100)

				if ( fillLevel > 0 or g_productionInspector.isEnabledShowEmptyInput ) then
					table.insert(inputTable, { fillType, math.ceil(fillLevel), fillCap, fillPerc })
				end
			end

			for x = 1, #thisProd.outputFillTypeIdsArray do
				local fillType  = thisProd.outputFillTypeIdsArray[x]
				local fillLevel = thisProd.storage:getFillLevel(fillType)
				local fillCap   = thisProd.storage:getCapacity(fillType)
				local fillPerc  = math.ceil((fillLevel / fillCap) * 100)

				if ( fillLevel > 0 or g_productionInspector.isEnabledShowEmptyOutput) then
					table.insert(outputTable, { fillType, math.ceil(fillLevel), fillCap, fillPerc })
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

					if prRunning or g_productionInspector.isEnabledShowInactiveProd then
						table.insert(procTable, {thisProcess.name, prRunning, prStatusTxt, prStatusCol})
					end

				end
			end

			local prodStatusTxt = g_i18n:getText("ui_production_status_inactive")

			if weAreWorkingHere then
				prodStatusTxt = g_i18n:getText("ui_production_status_running")
			end

			if isMine or not g_productionInspector.isEnabledOnlyOwned then
				if weAreWorkingHere or g_productionInspector.isEnabledShowInactivePoint then

					table.insert(new_data_table, {
						thisProd:getName(),
						isMine,
						weAreWorkingHere,
						prodStatusTxt,
						inputTable,
						outputTable,
						procTable
					})
				end
			end
		end
	end

	self.display_data = {unpack(new_data_table)}
end

function ProductionInspector:draw()
	if not self.isClient then
		return
	end

	if self.inspectBox ~= nil then
		local info_text = self.display_data
		local overlayH, dispTextH, dispTextW = 0, 0, 0
		local linesPerEntry = 4.5

		if not g_productionInspector.isEnabledShowInputs then
			linesPerEntry = linesPerEntry - 1
		end
		if not g_productionInspector.isEnabledShowOutputs then
			linesPerEntry = linesPerEntry - 1
		end

		if #info_text == 0 or not g_productionInspector.isEnabledVisible or g_sleepManager:getIsSleeping()  then
			-- we have no entries, hide the overlay and leave
			-- also if we hid it on purpose
			self.inspectBox:setVisible(false)
			return
		elseif g_gameSettings:getValue("ingameMapState") == 4 and g_productionInspector.displayMode % 2 ~= 0 and g_currentMission.inGameMenu.hud.inputHelp.overlay.visible then
			-- Left side display hide on big map with help open
			self.inspectBox:setVisible(false)
			return
		else
			-- we have entries, lets get the overall height of the box and unhide
			self.inspectBox:setVisible(true)
			dispTextH = self.inspectText.size * ( #info_text * linesPerEntry )
			overlayH = dispTextH + ( 2 * self.inspectText.marginHeight)
		end

		setTextBold(g_productionInspector.isEnabledTextBold)
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_TOP)

		-- overlayX/Y is where the box starts
		local overlayX, overlayY = self:findOrigin()
		-- dispTextX/Y is where the text starts (sort of)
		local dispTextX, dispTextY = self:findOrigin()

		if ( g_productionInspector.displayMode == 2 ) then
			-- top right (subtract both margins)
			dispTextX = dispTextX - self.marginWidth
			dispTextY = dispTextY - self.marginHeight
			overlayY  = overlayY - overlayH
		elseif ( g_productionInspector.displayMode == 3 ) then
			-- bottom left (add x width, add Y height)
			dispTextX = dispTextX + self.marginWidth
			dispTextY = dispTextY - self.marginHeight + overlayH
		elseif ( g_productionInspector.displayMode == 4 ) then
			-- bottom right (subtract x width, add Y height)
			dispTextX = dispTextX - self.marginWidth
			dispTextY = dispTextY - self.marginHeight + overlayH
		else
			-- top left (add X width, subtract Y height)
			dispTextX = dispTextX + self.marginWidth
			dispTextY = dispTextY - self.marginHeight
			overlayY  = overlayY - overlayH
		end

		if ( g_productionInspector.displayMode % 2 == 0 ) then
			setTextAlignment(RenderText.ALIGN_RIGHT)
		else
			setTextAlignment(RenderText.ALIGN_LEFT)
		end

		if g_currentMission.hud.sideNotifications ~= nil and g_productionInspector.displayMode == 2 then
			if #g_currentMission.hud.sideNotifications.notificationQueue > 0 then
				local deltaY = g_currentMission.hud.sideNotifications:getHeight()
				dispTextY = dispTextY - deltaY
				overlayY  = overlayY - deltaY
			end
		end

		self.inspectText.posX = dispTextX
		self.inspectText.posY = dispTextY

		for _, dText in pairs(info_text) do
			local thisTextLine  = {}
			local firstRun      = true

			if dText[2] then
				table.insert(thisTextLine, {"colorPointOwned", dText[1], false, true})
			else
				table.insert(thisTextLine, {"colorPointNotOwned", dText[1], false, true})
			end

			dispTextY, dispTextW = self:renderLine(thisTextLine, dispTextX, dispTextY, dispTextW)

			thisTextLine = {}
			firstRun     = true

			if ( g_productionInspector.displayMode % 2 ~= 0 ) then
				table.insert(thisTextLine, {"colorPointOwned", g_productionInspector.setStringTextIndent, false})
			end
			table.insert(thisTextLine, {"colorCaption", g_i18n:getText("ui_productions_production") .. " - ", false})

			for _, lines in pairs(dText[7]) do
				if not firstRun then
					table.insert(thisTextLine, {false, false, false})
				else
					firstRun = false
				end

				table.insert(thisTextLine, {"colorProdName", lines[1] .. ": ", false})
				table.insert(thisTextLine, {lines[4], lines[3], false})
			end

			if firstRun then
				table.insert(thisTextLine, {"colorEmpty", g_i18n:getText("ui_none"), false})
			end

			if ( g_productionInspector.displayMode % 2 == 0 ) then
				table.insert(thisTextLine, {"colorPointOwned", g_productionInspector.setStringTextIndent, false})
			end

			dispTextY, dispTextW = self:renderLine(thisTextLine, dispTextX, dispTextY, dispTextW)

			if g_productionInspector.isEnabledShowInputs then
				thisTextLine = {}
				firstRun     = true

				if ( g_productionInspector.displayMode % 2 ~= 0 ) then
					table.insert(thisTextLine, {"colorPointOwned", g_productionInspector.setStringTextIndent, false})
				end
				table.insert(thisTextLine, {"colorCaption", g_i18n:getText("ui_productions_incomingMaterials") .. " - ", false})

				for _, inputs in pairs(dText[5]) do
					local thisFillType = g_fillTypeManager:getFillTypeByIndex(inputs[1])
					local fillColor    = self:makeFillColor(inputs[4], true)

					if not firstRun then
						table.insert(thisTextLine, {false, false, false})
					else
						firstRun = false
					end 
					table.insert(thisTextLine, {"colorFillType", thisFillType.title .. ": ", false})

					if ( inputs[2] == 0 and g_productionInspector.isEnabledShortEmptyOutput ) then
						table.insert(thisTextLine, {"colorEmptyInput", g_productionInspector.setStringTextEmptyInput, false})
					else
						if g_productionInspector.isEnabledShowInFillLevel then
							table.insert(thisTextLine, {"rawFillColor", tostring(inputs[2]), fillColor})
						end

						if g_productionInspector.isEnabledShowInPercent then
							if g_productionInspector.isEnabledShowInFillLevel then
								table.insert(thisTextLine, {"rawFillColor", " (" .. tostring(inputs[4]) ..  "%)", fillColor})
							else
								table.insert(thisTextLine, {"rawFillColor", tostring(inputs[4]) ..  "%", fillColor})
							end
						end
					end
				end

				if firstRun then
					table.insert(thisTextLine, {"colorEmpty", g_i18n:getText("ui_none"), false})
				end

				if g_productionInspector.displayMode % 2 == 0 then
					table.insert(thisTextLine, {"colorPointOwned", g_productionInspector.setStringTextIndent, false})
				end

				dispTextY, dispTextW = self:renderLine(thisTextLine, dispTextX, dispTextY, dispTextW)
			end

			if g_productionInspector.isEnabledShowOutputs then
				thisTextLine = {}
				firstRun     = true

				if ( g_productionInspector.displayMode % 2 ~= 0 ) then
					table.insert(thisTextLine, {"colorPointOwned", g_productionInspector.setStringTextIndent, false})
				end
				table.insert(thisTextLine, {"colorCaption", g_i18n:getText("ui_productions_outgoingProducts") .. " - ", false})

				for _, outputs in pairs(dText[6]) do
					local thisFillType = g_fillTypeManager:getFillTypeByIndex(outputs[1])
					local fillColor    = self:makeFillColor(outputs[4], false)

					if not firstRun then
						table.insert(thisTextLine, {false, false, false})
					else
						firstRun = false
					end
					table.insert(thisTextLine, {"colorFillType", thisFillType.title .. ": ", false})

					if g_productionInspector.isEnabledShowOutFillLevel then
						table.insert(thisTextLine, {"rawFillColor", tostring(outputs[2]), fillColor})
					end

					if g_productionInspector.isEnabledShowOutPercent then
						if g_productionInspector.isEnabledShowOutFillLevel then
							table.insert(thisTextLine, {"rawFillColor", " (" .. tostring(outputs[4]) ..  "%)", fillColor})
						else
							table.insert(thisTextLine, {"rawFillColor", tostring(outputs[4]) ..  "%", fillColor})
						end
					end
				end

				if firstRun then
					table.insert(thisTextLine, {"colorEmpty", g_i18n:getText("ui_none"), false})
				end

				if g_productionInspector.displayMode % 2 == 0 then
					table.insert(thisTextLine, {"colorPointOwned", g_productionInspector.setStringTextIndent, false})
				end

				dispTextY, dispTextW = self:renderLine(thisTextLine, dispTextX, dispTextY, dispTextW)
			end

			dispTextY = dispTextY - ( self.inspectText.size / 2 )
		end

		-- update overlay background
		if g_productionInspector.displayMode % 2 == 0 then
			self.inspectBox.overlay:setPosition(overlayX - ( dispTextW + ( 2 * self.inspectText.marginWidth ) ), overlayY)
		else
			self.inspectBox.overlay:setPosition(overlayX, overlayY)
		end

		self.inspectBox.overlay:setDimension(dispTextW + (self.inspectText.marginWidth * 2), overlayH)

		-- reset text render to "defaults" to be kind
		setTextColor(1,1,1,1)
		setTextAlignment(RenderText.ALIGN_LEFT)
		setTextVerticalAlignment(RenderText.VERTICAL_ALIGN_BASELINE)
		setTextBold(false)
	end
end

function ProductionInspector:renderLine(thisTextLine, dispTextX, dispTextY, dispTextW)
	local fullTextSoFar = ""

	if ( g_productionInspector.displayMode % 2 ~= 0 ) then
		for _, thisLine in ipairs(thisTextLine) do
			-- future note: thisLine[4] is not nil and is true for the facility name

			if thisLine[1] == false then
				fullTextSoFar = self:renderSep(dispTextX, dispTextY, fullTextSoFar)
			elseif thisLine[1] == "rawFillColor" then
				setTextColor(unpack(thisLine[3]))
				fullTextSoFar = self:renderText(dispTextX, dispTextY, fullTextSoFar, thisLine[2])
			else
				self:renderColor(thisLine[1])
				fullTextSoFar = self:renderText(dispTextX, dispTextY, fullTextSoFar, thisLine[2])
			end
		end
	else
		for i = #thisTextLine, 1, -1 do
			-- future note: thisTextLine[i][4] is not nil and is true for the facility name

			if thisTextLine[i][1] == false then
				fullTextSoFar = self:renderSep(dispTextX, dispTextY, fullTextSoFar)
			elseif thisTextLine[i][1] == "rawFillColor" then
				setTextColor(unpack(thisTextLine[i][3]))
				fullTextSoFar = self:renderText(dispTextX, dispTextY, fullTextSoFar, thisTextLine[i][2])
			else
				self:renderColor(thisTextLine[i][1])
				fullTextSoFar = self:renderText(dispTextX, dispTextY, fullTextSoFar, thisTextLine[i][2])
			end
		end
	end

	local newDispTextY  = dispTextY - self.inspectText.size
	local tmpW          = getTextWidth(self.inspectText.size, fullTextSoFar)
	local newDispTextW  = dispTextW

	if tmpW > dispTextW then newDispTextW = tmpW end

	return newDispTextY, newDispTextW
end

function ProductionInspector:update(dt)
	if not self.isClient then
		return
	end

	if g_updateLoopIndex % g_productionInspector.setValueTimerFrequency == 0 then
		-- Lets not be rediculous, only update the vehicles "infrequently"
		self:updateProductions()
	end
end

function ProductionInspector:renderColor(name)
	-- fall back to white if it's not known
	local colorString = Utils.getNoNil(g_productionInspector[name], {1,1,1,1})

	setTextColor(unpack(colorString))
end

function ProductionInspector:renderText(x, y, fullTextSoFar, text)
	local newX = x

	if g_productionInspector.displayMode % 2 == 0 then
		newX = newX - getTextWidth(self.inspectText.size, fullTextSoFar)
	else
		newX = newX + getTextWidth(self.inspectText.size, fullTextSoFar)
	end

	renderText(newX, y, self.inspectText.size, text)
	return text .. fullTextSoFar
end

function ProductionInspector:renderSep(x, y, fullTextSoFar)
	self:renderColor("colorSep")
	return self:renderText(x, y, fullTextSoFar, g_productionInspector.setStringTextSep)
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

function ProductionInspector:findOrigin()
	local tmpX = 0
	local tmpY = 0

	if ( g_productionInspector.displayMode == 2 ) then
		-- top right display
		tmpX, tmpY = self.gameInfoDisplay:getPosition()
		tmpX = 1
		tmpY = tmpY - 0.012
	elseif ( g_productionInspector.displayMode == 3 ) then
		-- Bottom left, correct origin.
		tmpX = 0.01622
		tmpY = 0 + self.ingameMap:getHeight() + 0.01622
		if g_gameSettings:getValue("ingameMapState") > 1 then
			tmpY = tmpY + 0.032
		end
	elseif ( g_productionInspector.displayMode == 4 ) then
		-- bottom right display
		tmpX = 1
		tmpY = 0.01622
		if g_currentMission.inGameMenu.hud.speedMeter.overlay.visible then
			tmpY = tmpY + self.speedMeterDisplay:getHeight() + 0.032
			if g_modIsLoaded["FS22_EnhancedVehicle"] then
				tmpY = tmpY + 0.03
			end
		end
	elseif ( g_productionInspector.displayMode == 5 ) then
		tmpX = g_productionInspector.displayMode5X
		tmpY = g_productionInspector.displayMode5Y
	else
		-- top left display
		tmpX = 0.014
		tmpY = 0.945
		if g_currentMission.inGameMenu.hud.inputHelp.overlay.visible then
			tmpY = tmpY - self.inputHelpDisplay:getHeight() - 0.012
		end
	end

	return tmpX, tmpY
end

function ProductionInspector:createTextBox()
	-- make the box we live in.
	if ( g_productionInspector.debugMode ) then
		print("~~" .. self.myName .." :: createTextBox")
	end

	local baseX, baseY = self:findOrigin()

	local boxOverlay = nil

	self.marginWidth, self.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector({ 8, 8 })

	if ( g_productionInspector.displayMode % 2 == 0 ) then -- top right
		boxOverlay = Overlay.new(self.bgName, baseX, baseY - self.marginHeight, 1, 1)
	else -- default to 1
		boxOverlay = Overlay.new(self.bgName, baseX, baseY + self.marginHeight, 1, 1)
	end

	local boxElement = HUDElement.new(boxOverlay)

	self.inspectBox = boxElement

	self.inspectBox:setUVs(GuiUtils.getUVs(self.boxBGColor))
	self.inspectBox:setColor(unpack(SpeedMeterDisplay.COLOR.GEARS_BG))
	self.inspectBox:setVisible(false)
	self.gameInfoDisplay:addChild(boxElement)

	self.inspectText.marginWidth, self.inspectText.marginHeight = self.gameInfoDisplay:scalePixelToScreenVector({g_productionInspector.setValueTextMarginX, g_productionInspector.setValueTextMarginY})
	self.inspectText.size = self.gameInfoDisplay:scalePixelToScreenHeight(g_productionInspector.setValueTextSize)
end

function ProductionInspector:delete()
	-- clean up on remove
	if self.inspectBox ~= nil then
		self.inspectBox:delete()
	end
end

function ProductionInspector:saveSettings()
	local savegameFolderPath = ('%smodSettings/FS22_ProductionExplorer/savegame%d'):format(getUserProfileAppPath(), g_currentMission.missionInfo.savegameIndex)
	local savegameFile = savegameFolderPath .. "/productionInspector.xml"

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
	local key = "productionInspector"

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
	end
end

function ProductionInspector:registerActionEvents()
	local _, reloadConfig = g_inputBinding:registerActionEvent('ProductionInspector_reload_config', self,
		ProductionInspector.actionReloadConfig, false, true, false, true)
	g_inputBinding:setActionEventTextVisibility(reloadConfig, false)
	local _, toggleVisible = g_inputBinding:registerActionEvent('ProductionInspector_toggle_visible', self,
		ProductionInspector.actionToggleVisible, false, true, false, true)
	g_inputBinding:setActionEventTextVisibility(toggleVisible, false)
end

function ProductionInspector:actionReloadConfig()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]
	if ( thisModEnviroment.debugMode ) then
		print("~~" .. thisModEnviroment.myName .." :: reload settings from disk")
	end
	thisModEnviroment:loadSettings()
end

function ProductionInspector:actionToggleVisible()
	local thisModEnviroment = getfenv(0)["g_productionInspector"]
	if ( thisModEnviroment.debugMode ) then
		print("~~" .. thisModEnviroment.myName .." :: toggle display on/off")
	end
	thisModEnviroment.isEnabledVisible = (not thisModEnviroment.isEnabledVisible)
end

function ProductionInspector.initGui(self)
	local boolMenuOptions = {
		"Visible", "OnlyOwned", "ShowInactivePoint", "ShowInactiveProd",
		"ShowInputs", "ShowEmptyInput", "ShortEmptyOutput", "ShowInPercent", "ShowInFillLevel",
		"ShowOutputs", "ShowEmptyOutput", "ShowOutPercent", "ShowOutFillLevel",
		"TextBold"
	}

	if not g_productionInspector.createdGUI then -- Skip if we've already done this once
		g_productionInspector.createdGUI = true

		self.menuOption_DisplayMode = self.checkInvertYLook:clone()
		self.menuOption_DisplayMode.target = g_productionInspector
		self.menuOption_DisplayMode.id = "productionInspector_DisplayMode"
		self.menuOption_DisplayMode:setCallback("onClickCallback", "onMenuOptionChanged_DisplayMode")
		self.menuOption_DisplayMode:setDisabled(false)

		local settingTitle = self.menuOption_DisplayMode.elements[4]
		local toolTip = self.menuOption_DisplayMode.elements[6]

		self.menuOption_DisplayMode:setTexts({
			g_i18n:getText("setting_productionInspector_DisplayMode1"),
			g_i18n:getText("setting_productionInspector_DisplayMode2"),
			g_i18n:getText("setting_productionInspector_DisplayMode3"),
			g_i18n:getText("setting_productionInspector_DisplayMode4")
		})

		settingTitle:setText(g_i18n:getText("setting_productionInspector_DisplayMode"))
		toolTip:setText(g_i18n:getText("toolTip_productionInspector_DisplayMode"))


		for _, optName in pairs(boolMenuOptions) do
			local fullName = "menuOption_" .. optName

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

		local title = TextElement.new()
		title:applyProfile("settingsMenuSubtitle", true)
		title:setText(g_i18n:getText("title_productionInspector"))

		self.boxLayout:addElement(title)
		self.boxLayout:addElement(self.menuOption_DisplayMode)
		for _, value in ipairs(boolMenuOptions) do
			local thisOption = "menuOption_" .. value
			self.boxLayout:addElement(self[thisOption])
		end
	end

	self.menuOption_DisplayMode:setState(g_productionInspector.displayMode)
	for _, value in ipairs(boolMenuOptions) do
		local thisMenuOption = "menuOption_" .. value
		local thisRealOption = "isEnabled" .. value
		self[thisMenuOption]:setIsChecked(g_productionInspector[thisRealOption])
	end
end

function ProductionInspector:onMenuOptionChanged_DisplayMode(state)
	self.displayMode = state
	ProductionInspector:saveSettings()
end

function ProductionInspector:onMenuOptionChanged_boolOpt(state, info)
	local thisOption = "isEnabled" .. string.sub(info.id,21)
	self[thisOption] = state == CheckedOptionElement.STATE_CHECKED
	ProductionInspector:saveSettings()
end