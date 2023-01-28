
local debug        = false
local modDirectory = g_currentModDirectory or ""
local modName      = g_currentModName or "unknown"
local modEnvironment

source(g_currentModDirectory .. 'ProductionInspector.lua')
source(g_currentModDirectory .. 'lib/fs22Logger.lua')
source(g_currentModDirectory .. 'lib/fs22SimpleUtils.lua')

local function load(mission)
	assert(g_productionInspector == nil)

	local piLogger = FS22Log:new(
		"productionInspector",
		debug and FS22Log.DEBUG_MODE.VERBOSE or FS22Log.DEBUG_MODE.WARNINGS,
		{
			"getValue",
			"setValue",
			"display_table_prod",
			"display_table_anim",
			"display_table_silo",
			"display_data_prod",
			"display_data_anim",
			"display_data_silo",
		}
	)

	modEnvironment = ProductionInspector:new(mission, modDirectory, modName, piLogger)

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

local function save()
	modEnvironment:save()
end

local function init()
	FSBaseMission.delete = Utils.appendedFunction(FSBaseMission.delete, unload)

	Mission00.load = Utils.prependedFunction(Mission00.load, load)
	Mission00.onStartMission = Utils.appendedFunction(Mission00.onStartMission, startMission)

	InGameMenuGeneralSettingsFrame.onFrameOpen = Utils.appendedFunction(InGameMenuGeneralSettingsFrame.onFrameOpen, ProductionInspector.initGui)

	FSCareerMissionInfo.saveToXMLFile = Utils.appendedFunction(FSCareerMissionInfo.saveToXMLFile, save)
end

init()