
local modDirectory = g_currentModDirectory or ""
local modName = g_currentModName or "unknown"
local modEnvironment

source(g_currentModDirectory .. 'ProductionInspector.lua')

local function load(mission)
	assert(g_productionInspector == nil)

	modEnvironment = ProductionInspector:new(mission, g_i18n, modDirectory, modName)

	getfenv(0)["g_productionInspector"] = modEnvironment

	if mission:getIsClient() then
		addModEventListener(modEnvironment)
		FSBaseMission.registerActionEvents = Utils.appendedFunction(FSBaseMission.registerActionEvents, ProductionInspector.registerActionEvents);
		FSBaseMission.onToggleConstructionScreen = Utils.prependedFunction(FSBaseMission.onToggleConstructionScreen, ProductionInspector.openConstructionScreen)
	end
end

local function unload()
	removeModEventListener(modEnvironment)
	modEnvironment:delete()
	modEnvironment = nil -- Allows garbage collecting
	getfenv(0)["g_productionInspector"] = nil
end

local function startMission(mission)
	modEnvironment:onStartMission(mission)
end


local function init()
	FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

	Mission00.load = Utils.prependedFunction(Mission00.load, load)
	Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, startMission)

	InGameMenuGeneralSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameOpen, ProductionInspector.initGui)

	FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, ProductionInspector.saveSettings) -- Settings are saved live, but we need to do it here too, since the old save directory (with our xml) is now a backup
end

init()