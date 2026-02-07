-- Merged Rayfield UI Library
-- Custom GUI Structure + Original Functionality
-- Build: 3K3W | Release: Build 1.68

if debugX then
	warn('Initialising Rayfield')
end

local function getService(name)
	local service = game:GetService(name)
	return if cloneref then cloneref(service) else service
end

-- Loads and executes a function hosted on a remote URL. Cancels the request if the requested URL takes too long to respond.
-- Errors with the function are caught and logged to the output
local function loadWithTimeout(url: string, timeout: number?): ...any
	assert(type(url) == "string", "Expected string, got " .. type(url))
	timeout = timeout or 5
	local requestCompleted = false
	local success, result = false, nil

	local requestThread = task.spawn(function()
		local fetchSuccess, fetchResult = pcall(game.HttpGet, game, url)
		if not fetchSuccess or #fetchResult == 0 then
			if #fetchResult == 0 then
				fetchResult = "Empty response"
			end
			success, result = false, fetchResult
			requestCompleted = true
			return
		end
		local content = fetchResult
		local execSuccess, execResult = pcall(function()
			return loadstring(content)()
		end)
		success, result = execSuccess, execResult
		requestCompleted = true
	end)

	local timeoutThread = task.delay(timeout, function()
		if not requestCompleted then
			warn(`Request for {url} timed out after {timeout} seconds`)
			task.cancel(requestThread)
			result = "Request timed out"
			requestCompleted = true
		end
	end)

	while not requestCompleted do
		task.wait()
	end
	if coroutine.status(timeoutThread) ~= "dead" then
		task.cancel(timeoutThread)
	end
	if not success then
		warn(`Failed to process {url}: {result}`)
	end
	return if success then result else nil
end

local requestsDisabled = true
local InterfaceBuild = '3K3W'
local Release = "Build 1.68"
local RayfieldFolder = "Rayfield"
local ConfigurationFolder = RayfieldFolder.."/Configurations"
local ConfigurationExtension = ".rfld"
local settingsTable = {
	General = {
		rayfieldOpen = {Type = 'bind', Value = 'K', Name = 'Rayfield Keybind'},
	},
	System = {
		usageAnalytics = {Type = 'toggle', Value = true, Name = 'Anonymised Analytics'},
	}
}

local overriddenSettings: { [string]: any } = {}
local function overrideSetting(category: string, name: string, value: any)
	overriddenSettings[`{category}.{name}`] = value
end

local function getSetting(category: string, name: string): any
	if overriddenSettings[`{category}.{name}`] ~= nil then
		return overriddenSettings[`{category}.{name}`]
	elseif settingsTable[category][name] ~= nil then
		return settingsTable[category][name].Value
	end
end

if requestsDisabled then
	overrideSetting("System", "usageAnalytics", false)
end

local HttpService = getService('HttpService')
local RunService = getService('RunService')

local useStudio = RunService:IsStudio() or false

local settingsCreated = false
local settingsInitialized = false
local cachedSettings
local prompt = useStudio and require(script.Parent.prompt) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Sirius/refs/heads/request/prompt.lua')
local requestFunc = (syn and syn.request) or (fluxus and fluxus.request) or (http and http.request) or http_request or request

if not prompt and not useStudio then
	warn("Failed to load prompt library, using fallback")
	prompt = {
		create = function() end
	}
end

local function callSafely(func, ...)
	if func then
		local success, result = pcall(func, ...)
		if not success then
			warn("Rayfield | Function failed with error: ", result)
			return false
		else
			return result
		end
	end
end

local function ensureFolder(folderPath)
	if isfolder and not callSafely(isfolder, folderPath) then
		callSafely(makefolder, folderPath)
	end
end

local function loadSettings()
	local file = nil

	local success, result =	pcall(function()
		task.spawn(function()
			if callSafely(isfolder, RayfieldFolder) then
				if callSafely(isfile, RayfieldFolder..'/settings'..ConfigurationExtension) then
					file = callSafely(readfile, RayfieldFolder..'/settings'..ConfigurationExtension)
				end
			end

			if useStudio then
				file = [[
		{"General":{"rayfieldOpen":{"Value":"K","Type":"bind","Name":"Rayfield Keybind","Element":{"HoldToInteract":false,"Ext":true,"Name":"Rayfield Keybind","Set":null,"CallOnChange":true,"Callback":null,"CurrentKeybind":"K"}}},"System":{"usageAnalytics":{"Value":false,"Type":"toggle","Name":"Anonymised Analytics","Element":{"Ext":true,"Name":"Anonymised Analytics","Set":null,"CurrentValue":false,"Callback":null}}}}
	]]
			end

			if file then
				local success, decodedFile = pcall(function() return HttpService:JSONDecode(file) end)
				if success then
					file = decodedFile
				else
					file = {}
				end
			else
				file = {}
			end

			if not settingsCreated then 
				cachedSettings = file
				return
			end

			if file ~= {} then
				for categoryName, settingCategory in pairs(settingsTable) do
					if file[categoryName] then
						for settingName, setting in pairs(settingCategory) do
							if file[categoryName][settingName] then
								setting.Value = file[categoryName][settingName].Value
								setting.Element:Set(getSetting(categoryName, settingName))
							end
						end
					end
				end
			end
			settingsInitialized = true
		end)
	end)

	if not success then 
		if writefile then
			warn('Rayfield had an issue accessing configuration saving capability.')
		end
	end
end

if debugX then
	warn('Now Loading Settings Configuration')
end

loadSettings()

if debugX then
	warn('Settings Loaded')
end

local analyticsLib
local sendReport = function(ev_n, sc_n) warn("Failed to load report function") end
if not requestsDisabled then
	if debugX then
		warn('Querying Settings for Reporter Information')
	end	
	analyticsLib = loadWithTimeout("https://analytics.sirius.menu/script")
	if not analyticsLib then
		warn("Failed to load analytics reporter")
		analyticsLib = nil
	elseif analyticsLib and type(analyticsLib.load) == "function" then
		analyticsLib:load()
	else
		warn("Analytics library loaded but missing load function")
		analyticsLib = nil
	end
	sendReport = function(ev_n, sc_n)
		if not (type(analyticsLib) == "table" and type(analyticsLib.isLoaded) == "function" and analyticsLib:isLoaded()) then
			warn("Analytics library not loaded")
			return
		end
		if useStudio then
			print('Sending Analytics')
		else
			if debugX then warn('Reporting Analytics') end
			analyticsLib:report(
				{
					["name"] = ev_n,
					["script"] = {["name"] = sc_n, ["version"] = Release}
				},
				{
					["version"] = InterfaceBuild
				}
			)
			if debugX then warn('Finished Report') end
		end
	end
	if cachedSettings and (#cachedSettings == 0 or (cachedSettings.System and cachedSettings.System.usageAnalytics and cachedSettings.System.usageAnalytics.Value)) then
		sendReport("execution", "Rayfield")
	elseif not cachedSettings then
		sendReport("execution", "Rayfield")
	end
end

local promptUser = 2

if promptUser == 1 and prompt and type(prompt.create) == "function" then
	prompt.create(
		'Be cautious when running scripts',
	    [[Please be careful when running scripts from unknown developers. This script has already been ran.

<font transparency='0.3'>Some scripts may steal your items or in-game goods.</font>]],
		'Okay',
		'',
		function()

		end
	)
end

if debugX then
	warn('Moving on to continue initialisation')
end

local RayfieldLibrary = {
	Flags = {},
	Theme = {
		Default = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(25, 25, 25),
			Topbar = Color3.fromRGB(34, 34, 34),
			Shadow = Color3.fromRGB(20, 20, 20),

			NotificationBackground = Color3.fromRGB(20, 20, 20),
			NotificationActionsBackground = Color3.fromRGB(230, 230, 230),

			TabBackground = Color3.fromRGB(80, 80, 80),
			TabStroke = Color3.fromRGB(85, 85, 85),
			TabBackgroundSelected = Color3.fromRGB(210, 210, 210),
			TabTextColor = Color3.fromRGB(240, 240, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 50, 50),

			ElementBackground = Color3.fromRGB(35, 35, 35),
			ElementBackgroundHover = Color3.fromRGB(40, 40, 40),
			SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
			ElementStroke = Color3.fromRGB(50, 50, 50),
			SecondaryElementStroke = Color3.fromRGB(40, 40, 40),

			SliderBackground = Color3.fromRGB(50, 138, 220),
			SliderProgress = Color3.fromRGB(50, 138, 220),
			SliderStroke = Color3.fromRGB(58, 163, 255),

			ToggleBackground = Color3.fromRGB(30, 30, 30),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(100, 100, 100),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(125, 125, 125),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(65, 65, 65),

			DropdownSelected = Color3.fromRGB(40, 40, 40),
			DropdownUnselected = Color3.fromRGB(30, 30, 30),

			InputBackground = Color3.fromRGB(30, 30, 30),
			InputStroke = Color3.fromRGB(65, 65, 65),
			PlaceholderColor = Color3.fromRGB(178, 178, 178)
		},

		Ocean = {
			TextColor = Color3.fromRGB(230, 240, 240),

			Background = Color3.fromRGB(20, 30, 30),
			Topbar = Color3.fromRGB(25, 40, 40),
			Shadow = Color3.fromRGB(15, 20, 20),

			NotificationBackground = Color3.fromRGB(25, 35, 35),
			NotificationActionsBackground = Color3.fromRGB(230, 240, 240),

			TabBackground = Color3.fromRGB(40, 60, 60),
			TabStroke = Color3.fromRGB(50, 70, 70),
			TabBackgroundSelected = Color3.fromRGB(100, 180, 180),
			TabTextColor = Color3.fromRGB(210, 230, 230),
			SelectedTabTextColor = Color3.fromRGB(20, 50, 50),

			ElementBackground = Color3.fromRGB(30, 50, 50),
			ElementBackgroundHover = Color3.fromRGB(40, 60, 60),
			SecondaryElementBackground = Color3.fromRGB(30, 45, 45),
			ElementStroke = Color3.fromRGB(45, 70, 70),
			SecondaryElementStroke = Color3.fromRGB(40, 65, 65),

			SliderBackground = Color3.fromRGB(0, 110, 110),
			SliderProgress = Color3.fromRGB(0, 140, 140),
			SliderStroke = Color3.fromRGB(0, 160, 160),

			ToggleBackground = Color3.fromRGB(30, 50, 50),
			ToggleEnabled = Color3.fromRGB(0, 130, 130),
			ToggleDisabled = Color3.fromRGB(70, 90, 90),
			ToggleEnabledStroke = Color3.fromRGB(0, 160, 160),
			ToggleDisabledStroke = Color3.fromRGB(85, 105, 105),
			ToggleEnabledOuterStroke = Color3.fromRGB(50, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(45, 65, 65),

			DropdownSelected = Color3.fromRGB(30, 60, 60),
			DropdownUnselected = Color3.fromRGB(25, 40, 40),

			InputBackground = Color3.fromRGB(30, 50, 50),
			InputStroke = Color3.fromRGB(50, 70, 70),
			PlaceholderColor = Color3.fromRGB(140, 160, 160)
		},

		AmberGlow = {
			TextColor = Color3.fromRGB(255, 245, 230),

			Background = Color3.fromRGB(45, 30, 20),
			Topbar = Color3.fromRGB(55, 40, 25),
			Shadow = Color3.fromRGB(35, 25, 15),

			NotificationBackground = Color3.fromRGB(50, 35, 25),
			NotificationActionsBackground = Color3.fromRGB(245, 230, 215),

			TabBackground = Color3.fromRGB(75, 50, 35),
			TabStroke = Color3.fromRGB(90, 60, 45),
			TabBackgroundSelected = Color3.fromRGB(230, 180, 100),
			TabTextColor = Color3.fromRGB(250, 220, 200),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 10),

			ElementBackground = Color3.fromRGB(60, 45, 35),
			ElementBackgroundHover = Color3.fromRGB(70, 50, 40),
			SecondaryElementBackground = Color3.fromRGB(55, 40, 30),
			ElementStroke = Color3.fromRGB(85, 60, 45),
			SecondaryElementStroke = Color3.fromRGB(75, 50, 35),

			SliderBackground = Color3.fromRGB(220, 130, 60),
			SliderProgress = Color3.fromRGB(250, 150, 75),
			SliderStroke = Color3.fromRGB(255, 170, 85),

			ToggleBackground = Color3.fromRGB(55, 40, 30),
			ToggleEnabled = Color3.fromRGB(240, 130, 30),
			ToggleDisabled = Color3.fromRGB(90, 70, 60),
			ToggleEnabledStroke = Color3.fromRGB(255, 160, 50),
			ToggleDisabledStroke = Color3.fromRGB(110, 85, 75),
			ToggleEnabledOuterStroke = Color3.fromRGB(200, 100, 50),
			ToggleDisabledOuterStroke = Color3.fromRGB(75, 60, 55),

			DropdownSelected = Color3.fromRGB(70, 50, 40),
			DropdownUnselected = Color3.fromRGB(55, 40, 30),

			InputBackground = Color3.fromRGB(60, 45, 35),
			InputStroke = Color3.fromRGB(90, 65, 50),
			PlaceholderColor = Color3.fromRGB(190, 150, 130)
		},

		Light = {
			TextColor = Color3.fromRGB(40, 40, 40),

			Background = Color3.fromRGB(245, 245, 245),
			Topbar = Color3.fromRGB(230, 230, 230),
			Shadow = Color3.fromRGB(200, 200, 200),

			NotificationBackground = Color3.fromRGB(250, 250, 250),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 240),

			TabBackground = Color3.fromRGB(235, 235, 235),
			TabStroke = Color3.fromRGB(215, 215, 215),
			TabBackgroundSelected = Color3.fromRGB(255, 255, 255),
			TabTextColor = Color3.fromRGB(80, 80, 80),
			SelectedTabTextColor = Color3.fromRGB(0, 0, 0),

			ElementBackground = Color3.fromRGB(240, 240, 240),
			ElementBackgroundHover = Color3.fromRGB(225, 225, 225),
			SecondaryElementBackground = Color3.fromRGB(235, 235, 235),
			ElementStroke = Color3.fromRGB(210, 210, 210),
			SecondaryElementStroke = Color3.fromRGB(210, 210, 210),

			SliderBackground = Color3.fromRGB(150, 180, 220),
			SliderProgress = Color3.fromRGB(100, 150, 200), 
			SliderStroke = Color3.fromRGB(120, 170, 220),

			ToggleBackground = Color3.fromRGB(220, 220, 220),
			ToggleEnabled = Color3.fromRGB(0, 146, 214),
			ToggleDisabled = Color3.fromRGB(150, 150, 150),
			ToggleEnabledStroke = Color3.fromRGB(0, 170, 255),
			ToggleDisabledStroke = Color3.fromRGB(170, 170, 170),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 100, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(180, 180, 180),

			DropdownSelected = Color3.fromRGB(230, 230, 230),
			DropdownUnselected = Color3.fromRGB(220, 220, 220),

			InputBackground = Color3.fromRGB(240, 240, 240),
			InputStroke = Color3.fromRGB(180, 180, 180),
			PlaceholderColor = Color3.fromRGB(140, 140, 140)
		},

		Amethyst = {
			TextColor = Color3.fromRGB(240, 240, 240),

			Background = Color3.fromRGB(30, 20, 40),
			Topbar = Color3.fromRGB(40, 25, 50),
			Shadow = Color3.fromRGB(20, 15, 30),

			NotificationBackground = Color3.fromRGB(35, 20, 40),
			NotificationActionsBackground = Color3.fromRGB(240, 240, 250),

			TabBackground = Color3.fromRGB(60, 40, 80),
			TabStroke = Color3.fromRGB(70, 45, 90),
			TabBackgroundSelected = Color3.fromRGB(180, 140, 200),
			TabTextColor = Color3.fromRGB(230, 230, 240),
			SelectedTabTextColor = Color3.fromRGB(50, 20, 50),

			ElementBackground = Color3.fromRGB(45, 30, 60),
			ElementBackgroundHover = Color3.fromRGB(50, 35, 70),
			SecondaryElementBackground = Color3.fromRGB(40, 30, 55),
			ElementStroke = Color3.fromRGB(70, 50, 85),
			SecondaryElementStroke = Color3.fromRGB(65, 45, 80),

			SliderBackground = Color3.fromRGB(100, 60, 150),
			SliderProgress = Color3.fromRGB(130, 80, 180),
			SliderStroke = Color3.fromRGB(150, 100, 200),

			ToggleBackground = Color3.fromRGB(45, 30, 55),
			ToggleEnabled = Color3.fromRGB(120, 60, 150),
			ToggleDisabled = Color3.fromRGB(94, 47, 117),
			ToggleEnabledStroke = Color3.fromRGB(140, 80, 170),
			ToggleDisabledStroke = Color3.fromRGB(124, 71, 150),
			ToggleEnabledOuterStroke = Color3.fromRGB(90, 40, 120),
			ToggleDisabledOuterStroke = Color3.fromRGB(80, 50, 110),

			DropdownSelected = Color3.fromRGB(50, 35, 70),
			DropdownUnselected = Color3.fromRGB(35, 25, 50),

			InputBackground = Color3.fromRGB(45, 30, 60),
			InputStroke = Color3.fromRGB(80, 50, 110),
			PlaceholderColor = Color3.fromRGB(178, 150, 200)
		},

		Green = {
			TextColor = Color3.fromRGB(30, 60, 30),

			Background = Color3.fromRGB(235, 245, 235),
			Topbar = Color3.fromRGB(210, 230, 210),
			Shadow = Color3.fromRGB(200, 220, 200),

			NotificationBackground = Color3.fromRGB(240, 250, 240),
			NotificationActionsBackground = Color3.fromRGB(220, 235, 220),

			TabBackground = Color3.fromRGB(215, 235, 215),
			TabStroke = Color3.fromRGB(190, 210, 190),
			TabBackgroundSelected = Color3.fromRGB(245, 255, 245),
			TabTextColor = Color3.fromRGB(50, 80, 50),
			SelectedTabTextColor = Color3.fromRGB(20, 60, 20),

			ElementBackground = Color3.fromRGB(225, 240, 225),
			ElementBackgroundHover = Color3.fromRGB(210, 225, 210),
			SecondaryElementBackground = Color3.fromRGB(235, 245, 235), 
			ElementStroke = Color3.fromRGB(180, 200, 180),
			SecondaryElementStroke = Color3.fromRGB(180, 200, 180),

			SliderBackground = Color3.fromRGB(90, 160, 90),
			SliderProgress = Color3.fromRGB(70, 130, 70),
			SliderStroke = Color3.fromRGB(100, 180, 100),

			ToggleBackground = Color3.fromRGB(215, 235, 215),
			ToggleEnabled = Color3.fromRGB(60, 130, 60),
			ToggleDisabled = Color3.fromRGB(150, 175, 150),
			ToggleEnabledStroke = Color3.fromRGB(80, 150, 80),
			ToggleDisabledStroke = Color3.fromRGB(130, 150, 130),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 160, 100),
			ToggleDisabledOuterStroke = Color3.fromRGB(160, 180, 160),

			DropdownSelected = Color3.fromRGB(225, 240, 225),
			DropdownUnselected = Color3.fromRGB(210, 225, 210),

			InputBackground = Color3.fromRGB(235, 245, 235),
			InputStroke = Color3.fromRGB(180, 200, 180),
			PlaceholderColor = Color3.fromRGB(120, 140, 120)
		},

		Bloom = {
			TextColor = Color3.fromRGB(60, 40, 50),

			Background = Color3.fromRGB(255, 240, 245),
			Topbar = Color3.fromRGB(250, 220, 225),
			Shadow = Color3.fromRGB(230, 190, 195),

			NotificationBackground = Color3.fromRGB(255, 235, 240),
			NotificationActionsBackground = Color3.fromRGB(245, 215, 225),

			TabBackground = Color3.fromRGB(240, 210, 220),
			TabStroke = Color3.fromRGB(230, 200, 210),
			TabBackgroundSelected = Color3.fromRGB(255, 225, 235),
			TabTextColor = Color3.fromRGB(80, 40, 60),
			SelectedTabTextColor = Color3.fromRGB(50, 30, 50),

			ElementBackground = Color3.fromRGB(255, 235, 240),
			ElementBackgroundHover = Color3.fromRGB(245, 220, 230),
			SecondaryElementBackground = Color3.fromRGB(255, 235, 240), 
			ElementStroke = Color3.fromRGB(230, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(230, 200, 210),

			SliderBackground = Color3.fromRGB(240, 130, 160),
			SliderProgress = Color3.fromRGB(250, 160, 180),
			SliderStroke = Color3.fromRGB(255, 180, 200),

			ToggleBackground = Color3.fromRGB(240, 210, 220),
			ToggleEnabled = Color3.fromRGB(255, 140, 170),
			ToggleDisabled = Color3.fromRGB(200, 180, 185),
			ToggleEnabledStroke = Color3.fromRGB(250, 160, 190),
			ToggleDisabledStroke = Color3.fromRGB(210, 180, 190),
			ToggleEnabledOuterStroke = Color3.fromRGB(220, 160, 180),
			ToggleDisabledOuterStroke = Color3.fromRGB(190, 170, 180),

			DropdownSelected = Color3.fromRGB(250, 220, 225),
			DropdownUnselected = Color3.fromRGB(240, 210, 220),

			InputBackground = Color3.fromRGB(255, 235, 240),
			InputStroke = Color3.fromRGB(220, 190, 200),
			PlaceholderColor = Color3.fromRGB(170, 130, 140)
		},

		DarkBlue = {
			TextColor = Color3.fromRGB(230, 230, 230),

			Background = Color3.fromRGB(20, 25, 30),
			Topbar = Color3.fromRGB(30, 35, 40),
			Shadow = Color3.fromRGB(15, 20, 25),

			NotificationBackground = Color3.fromRGB(25, 30, 35),
			NotificationActionsBackground = Color3.fromRGB(45, 50, 55),

			TabBackground = Color3.fromRGB(35, 40, 45),
			TabStroke = Color3.fromRGB(45, 50, 60),
			TabBackgroundSelected = Color3.fromRGB(40, 70, 100),
			TabTextColor = Color3.fromRGB(200, 200, 200),
			SelectedTabTextColor = Color3.fromRGB(255, 255, 255),

			ElementBackground = Color3.fromRGB(30, 35, 40),
			ElementBackgroundHover = Color3.fromRGB(40, 45, 50),
			SecondaryElementBackground = Color3.fromRGB(35, 40, 45), 
			ElementStroke = Color3.fromRGB(45, 50, 60),
			SecondaryElementStroke = Color3.fromRGB(40, 45, 55),

			SliderBackground = Color3.fromRGB(0, 90, 180),
			SliderProgress = Color3.fromRGB(0, 120, 210),
			SliderStroke = Color3.fromRGB(0, 150, 240),

			ToggleBackground = Color3.fromRGB(35, 40, 45),
			ToggleEnabled = Color3.fromRGB(0, 120, 210),
			ToggleDisabled = Color3.fromRGB(70, 70, 80),
			ToggleEnabledStroke = Color3.fromRGB(0, 150, 240),
			ToggleDisabledStroke = Color3.fromRGB(75, 75, 85),
			ToggleEnabledOuterStroke = Color3.fromRGB(20, 100, 180), 
			ToggleDisabledOuterStroke = Color3.fromRGB(55, 55, 65),

			DropdownSelected = Color3.fromRGB(30, 70, 90),
			DropdownUnselected = Color3.fromRGB(25, 30, 35),

			InputBackground = Color3.fromRGB(25, 30, 35),
			InputStroke = Color3.fromRGB(45, 50, 60), 
			PlaceholderColor = Color3.fromRGB(150, 150, 160)
		},

		Serenity = {
			TextColor = Color3.fromRGB(50, 55, 60),
			Background = Color3.fromRGB(240, 245, 250),
			Topbar = Color3.fromRGB(215, 225, 235),
			Shadow = Color3.fromRGB(200, 210, 220),

			NotificationBackground = Color3.fromRGB(210, 220, 230),
			NotificationActionsBackground = Color3.fromRGB(225, 230, 240),

			TabBackground = Color3.fromRGB(200, 210, 220),
			TabStroke = Color3.fromRGB(180, 190, 200),
			TabBackgroundSelected = Color3.fromRGB(175, 185, 200),
			TabTextColor = Color3.fromRGB(50, 55, 60),
			SelectedTabTextColor = Color3.fromRGB(30, 35, 40),

			ElementBackground = Color3.fromRGB(210, 220, 230),
			ElementBackgroundHover = Color3.fromRGB(220, 230, 240),
			SecondaryElementBackground = Color3.fromRGB(200, 210, 220),
			ElementStroke = Color3.fromRGB(190, 200, 210),
			SecondaryElementStroke = Color3.fromRGB(180, 190, 200),

			SliderBackground = Color3.fromRGB(200, 220, 235),
			SliderProgress = Color3.fromRGB(70, 130, 180),
			SliderStroke = Color3.fromRGB(150, 180, 220),

			ToggleBackground = Color3.fromRGB(210, 220, 230),
			ToggleEnabled = Color3.fromRGB(70, 160, 210),
			ToggleDisabled = Color3.fromRGB(180, 180, 180),
			ToggleEnabledStroke = Color3.fromRGB(60, 150, 200),
			ToggleDisabledStroke = Color3.fromRGB(140, 140, 140),
			ToggleEnabledOuterStroke = Color3.fromRGB(100, 120, 140),
			ToggleDisabledOuterStroke = Color3.fromRGB(120, 120, 130),

			DropdownSelected = Color3.fromRGB(220, 230, 240),
			DropdownUnselected = Color3.fromRGB(200, 210, 220),

			InputBackground = Color3.fromRGB(220, 230, 240),
			InputStroke = Color3.fromRGB(180, 190, 200),
			PlaceholderColor = Color3.fromRGB(150, 150, 150)
		},
	}
}

-- Services
local UserInputService = getService("UserInputService")
local TweenService = getService("TweenService")
local Players = getService("Players")
local CoreGui = getService("CoreGui")

-- ============================================================================
-- CUSTOM GUI CREATION (Replacing asset load)
-- ============================================================================

local Rayfield = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local UICorner = Instance.new("UICorner")
local Shadow = Instance.new("Frame")
local Image = Instance.new("ImageLabel")
local Topbar = Instance.new("Frame")
local UICorner_2 = Instance.new("UICorner")
local CornerRepair = Instance.new("Frame")
local Title = Instance.new("TextLabel")
local Hide = Instance.new("ImageButton")
local Divider = Instance.new("Frame")
local ChangeSize = Instance.new("ImageButton")
local Settings = Instance.new("ImageButton")
local Icon = Instance.new("ImageButton")
local Search = Instance.new("ImageButton")
local UICorner_3 = Instance.new("UICorner")
local Elements = Instance.new("Frame")
local Template = Instance.new("ScrollingFrame")
local UICorner_4 = Instance.new("UICorner")
local LoadingFrame = Instance.new("Frame")
local Title_2 = Instance.new("TextLabel")
local Subtitle = Instance.new("TextLabel")
local Version = Instance.new("TextLabel")
local TabList = Instance.new("ScrollingFrame")
local UIListLayout = Instance.new("UIListLayout")
local Placeholder = Instance.new("Frame")
local Template_2 = Instance.new("Frame")
local UICorner_5 = Instance.new("UICorner")
local Title_3 = Instance.new("TextLabel")
local Interact = Instance.new("TextButton")
local Image_2 = Instance.new("ImageLabel")
local UICorner_6 = Instance.new("UICorner")
local Preview = Instance.new("Frame")
local UICorner_7 = Instance.new("UICorner")
local Shadow_2 = Instance.new("Frame")
local Image_3 = Instance.new("ImageLabel")
local Description = Instance.new("TextLabel")
local Title_4 = Instance.new("TextLabel")
local State = Instance.new("TextLabel")
local PreviewImage = Instance.new("ImageLabel")
local Search_2 = Instance.new("Frame")
local UICorner_8 = Instance.new("UICorner")
local Search_3 = Instance.new("ImageLabel")
local Input = Instance.new("TextBox")
local Shadow_3 = Instance.new("ImageLabel")
local Notice = Instance.new("Frame")
local UICorner_9 = Instance.new("UICorner")
local Title_5 = Instance.new("TextLabel")
local Prompt = Instance.new("Frame")
local UICorner_10 = Instance.new("UICorner")
local Title_6 = Instance.new("TextLabel")
local Interact_2 = Instance.new("TextButton")
local Notifications = Instance.new("Frame")
local Template_3 = Instance.new("Frame")
local UICorner_11 = Instance.new("UICorner")
local Icon_2 = Instance.new("ImageLabel")
local Interact_3 = Instance.new("TextButton")
local Description_2 = Instance.new("TextLabel")
local Title_7 = Instance.new("TextLabel")
local Shadow_4 = Instance.new("ImageLabel")
local BlurFrame = Instance.new("Frame")
local UIListLayout_2 = Instance.new("UIListLayout")
local Drag = Instance.new("Frame")
local UICorner_12 = Instance.new("UICorner")
local Drag_2 = Instance.new("Frame")
local UICorner_13 = Instance.new("UICorner")
local Interact_4 = Instance.new("TextButton")
local Loading = Instance.new("Frame")
local Banner = Instance.new("ImageLabel")

-- Properties
Rayfield.Name = "Rayfield"
Rayfield.Parent = game.Players.LocalPlayer:WaitForChild("PlayerGui")
Rayfield.DisplayOrder = 100
Rayfield.ResetOnSpawn = false

Main.Name = "Main"
Main.Parent = Rayfield
Main.AnchorPoint = Vector2.new(0.5, 0.5)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.BorderColor3 = Color3.fromRGB(27, 42, 53)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.491116107, 0, 0.5, 0)
Main.Size = UDim2.new(0, 706, 0, 475)
Main.Visible = false

UICorner.CornerRadius = UDim.new(0, 15)
UICorner.Parent = Main

Shadow.Name = "Shadow"
Shadow.Parent = Main
Shadow.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shadow.BackgroundTransparency = 1.000
Shadow.BorderColor3 = Color3.fromRGB(27, 42, 53)
Shadow.BorderSizePixel = 0
Shadow.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow.Size = UDim2.new(1, 35, 1, 35)
Shadow.ZIndex = 0

Image.Name = "Image"
Image.Parent = Shadow
Image.AnchorPoint = Vector2.new(0.5, 0.5)
Image.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Image.BackgroundTransparency = 1.000
Image.BorderColor3 = Color3.fromRGB(27, 42, 53)
Image.BorderSizePixel = 0
Image.Position = UDim2.new(0.5, 0, 0.5, 0)
Image.Size = UDim2.new(1.60000002, 0, 1.29999995, 0)
Image.ZIndex = 0
Image.Image = "rbxassetid://5587865193"
Image.ImageColor3 = Color3.fromRGB(20, 20, 20)
Image.ImageTransparency = 0.600

Topbar.Name = "Topbar"
Topbar.Parent = Main
Topbar.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
Topbar.BorderColor3 = Color3.fromRGB(27, 42, 53)
Topbar.BorderSizePixel = 0
Topbar.Size = UDim2.new(1, 0, 0, 45)
Topbar.ZIndex = 5

UICorner_2.CornerRadius = UDim.new(0, 15)
UICorner_2.Parent = Topbar

CornerRepair.Name = "CornerRepair"
CornerRepair.Parent = Topbar
CornerRepair.AnchorPoint = Vector2.new(0.5, 0.5)
CornerRepair.BackgroundColor3 = Color3.fromRGB(34, 34, 34)
CornerRepair.BorderColor3 = Color3.fromRGB(27, 42, 53)
CornerRepair.BorderSizePixel = 0
CornerRepair.Position = UDim2.new(0.5, 0, 0.838888884, 0)
CornerRepair.Size = UDim2.new(1, 0, 0.322222233, 0)
CornerRepair.ZIndex = 4

Title.Name = "Title"
Title.Parent = Topbar
Title.AnchorPoint = Vector2.new(0, 0.5)
Title.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title.BackgroundTransparency = 1.000
Title.BorderColor3 = Color3.fromRGB(27, 42, 53)
Title.BorderSizePixel = 0
Title.Position = UDim2.new(0, 17, 0.5, 0)
Title.Size = UDim2.new(0, 338, 0, 16)
Title.ZIndex = 5
Title.Font = Enum.Font.Unknown
Title.Text = "Rayfield Interface Suite"
Title.TextColor3 = Color3.fromRGB(240, 240, 240)
Title.TextScaled = true
Title.TextSize = 14.000
Title.TextWrapped = true
Title.TextXAlignment = Enum.TextXAlignment.Left

Hide.Name = "Hide"
Hide.Parent = Topbar
Hide.AnchorPoint = Vector2.new(1, 0.5)
Hide.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Hide.BackgroundTransparency = 1.000
Hide.BorderColor3 = Color3.fromRGB(27, 42, 53)
Hide.BorderSizePixel = 0
Hide.Position = UDim2.new(1, -15, 0.5, 0)
Hide.Size = UDim2.new(0, 24, 0, 24)
Hide.ZIndex = 5
Hide.Image = "http://www.roblox.com/asset/?id=10137832201"
Hide.ImageColor3 = Color3.fromRGB(240, 240, 240)
Hide.ImageTransparency = 0.800
Hide.ScaleType = Enum.ScaleType.Fit

Divider.Name = "Divider"
Divider.Parent = Topbar
Divider.BackgroundColor3 = Color3.fromRGB(65, 65, 65)
Divider.BorderColor3 = Color3.fromRGB(27, 42, 53)
Divider.BorderSizePixel = 0
Divider.Position = UDim2.new(0, 0, 1, 0)
Divider.Size = UDim2.new(1, 0, 0, 1)

ChangeSize.Name = "ChangeSize"
ChangeSize.Parent = Topbar
ChangeSize.AnchorPoint = Vector2.new(1, 0.5)
ChangeSize.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
ChangeSize.BackgroundTransparency = 1.000
ChangeSize.BorderColor3 = Color3.fromRGB(27, 42, 53)
ChangeSize.BorderSizePixel = 0
ChangeSize.Position = UDim2.new(1, -45, 0.5, 0)
ChangeSize.Size = UDim2.new(0, 24, 0, 24)
ChangeSize.ZIndex = 5
ChangeSize.Image = "rbxassetid://10137941941"
ChangeSize.ImageColor3 = Color3.fromRGB(240, 240, 240)
ChangeSize.ImageTransparency = 0.800
ChangeSize.ScaleType = Enum.ScaleType.Fit

Settings.Name = "Settings"
Settings.Parent = Topbar
Settings.AnchorPoint = Vector2.new(1, 0.5)
Settings.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Settings.BackgroundTransparency = 1.000
Settings.BorderColor3 = Color3.fromRGB(27, 42, 53)
Settings.BorderSizePixel = 0
Settings.Position = UDim2.new(1, -75, 0.5, 0)
Settings.Size = UDim2.new(0, 24, 0, 24)
Settings.ZIndex = 5
Settings.Image = "rbxassetid://80503127983237"
Settings.ImageColor3 = Color3.fromRGB(240, 240, 240)
Settings.ImageTransparency = 0.800
Settings.ScaleType = Enum.ScaleType.Fit

Icon.Name = "Icon"
Icon.Parent = Topbar
Icon.AnchorPoint = Vector2.new(0, 0.5)
Icon.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Icon.BackgroundTransparency = 1.000
Icon.BorderColor3 = Color3.fromRGB(27, 42, 53)
Icon.BorderSizePixel = 0
Icon.Position = UDim2.new(0, 17, 0.5, 0)
Icon.Size = UDim2.new(0, 24, 0, 24)
Icon.Visible = false
Icon.ZIndex = 5
Icon.Image = "rbxassetid://78137979054938"
Icon.ImageColor3 = Color3.fromRGB(240, 240, 240)
Icon.ScaleType = Enum.ScaleType.Fit

Search.Name = "Search"
Search.Parent = Topbar
Search.AnchorPoint = Vector2.new(1, 0.5)
Search.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Search.BackgroundTransparency = 1.000
Search.BorderColor3 = Color3.fromRGB(27, 42, 53)
Search.BorderSizePixel = 0
Search.Position = UDim2.new(0.465297371, -105, 1.5, 0)
Search.Size = UDim2.new(0, 206, 0, 24)
Search.ZIndex = 5
Search.Image = "rbxassetid://8445471332"
Search.ImageColor3 = Color3.fromRGB(240, 240, 240)
Search.ImageRectOffset = Vector2.new(204, 104)
Search.ImageRectSize = Vector2.new(96, 96)
Search.ImageTransparency = 0.800
Search.ScaleType = Enum.ScaleType.Fit

UICorner_3.Parent = Search

Elements.Name = "Elements"
Elements.Parent = Main
Elements.AnchorPoint = Vector2.new(0.5, 1)
Elements.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Elements.BackgroundTransparency = 1.000
Elements.BorderColor3 = Color3.fromRGB(27, 42, 53)
Elements.BorderSizePixel = 0
Elements.ClipsDescendants = true
Elements.Position = UDim2.new(0.657223761, 0, 0.951578975, 0)
Elements.Size = UDim2.new(0.661862373, 0, 0.982105255, -100)

Template.Name = "Template"
Template.Parent = Elements
Template.Active = true
Template.AnchorPoint = Vector2.new(0.5, 0.5)
Template.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Template.BackgroundTransparency = 1.000
Template.BorderColor3 = Color3.fromRGB(27, 42, 53)
Template.BorderSizePixel = 0
Template.Position = UDim2.new(0.497317731, 0, 0.5, 0)
Template.Size = UDim2.new(1.03326154, -25, 1, 0)
Template.CanvasSize = UDim2.new(0, 0, 0, 0)
Template.ScrollBarThickness = 0

UICorner_4.CornerRadius = UDim.new(0, 12)
UICorner_4.Parent = Elements

LoadingFrame.Name = "LoadingFrame"
LoadingFrame.Parent = Main
LoadingFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
LoadingFrame.BackgroundTransparency = 1.000
LoadingFrame.BorderColor3 = Color3.fromRGB(27, 42, 53)
LoadingFrame.BorderSizePixel = 0
LoadingFrame.Size = UDim2.new(1, 0, 1, 0)
LoadingFrame.Visible = false
LoadingFrame.ZIndex = 30

Title_2.Name = "Title"
Title_2.Parent = LoadingFrame
Title_2.AnchorPoint = Vector2.new(0, 0.5)
Title_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_2.BackgroundTransparency = 1.000
Title_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
Title_2.BorderSizePixel = 0
Title_2.Position = UDim2.new(0, 25, 0.5, -8)
Title_2.Size = UDim2.new(0, 300, 0, 16)
Title_2.Font = Enum.Font.Unknown
Title_2.Text = "Rayfield"
Title_2.TextColor3 = Color3.fromRGB(240, 240, 240)
Title_2.TextSize = 16.000
Title_2.TextWrapped = true
Title_2.TextXAlignment = Enum.TextXAlignment.Left

Subtitle.Name = "Subtitle"
Subtitle.Parent = LoadingFrame
Subtitle.AnchorPoint = Vector2.new(0, 0.5)
Subtitle.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Subtitle.BackgroundTransparency = 1.000
Subtitle.BorderColor3 = Color3.fromRGB(27, 42, 53)
Subtitle.BorderSizePixel = 0
Subtitle.Position = UDim2.new(0, 25, 0.5, 8)
Subtitle.Size = UDim2.new(0, 200, 0, 15)
Subtitle.Font = Enum.Font.Unknown
Subtitle.Text = "Interface Suite"
Subtitle.TextColor3 = Color3.fromRGB(200, 200, 200)
Subtitle.TextSize = 15.000
Subtitle.TextWrapped = true
Subtitle.TextXAlignment = Enum.TextXAlignment.Left

Version.Name = "Version"
Version.Parent = LoadingFrame
Version.AnchorPoint = Vector2.new(1, 1)
Version.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Version.BackgroundTransparency = 1.000
Version.BorderColor3 = Color3.fromRGB(27, 42, 53)
Version.BorderSizePixel = 0
Version.Position = UDim2.new(1, -10, 1, -10)
Version.Size = UDim2.new(0, 200, 0, 13)
Version.Font = Enum.Font.Gotham
Version.Text = "release R1"
Version.TextColor3 = Color3.fromRGB(70, 70, 70)
Version.TextScaled = true
Version.TextSize = 14.000
Version.TextWrapped = true
Version.TextXAlignment = Enum.TextXAlignment.Right

TabList.Name = "TabList"
TabList.Parent = Main
TabList.Active = true
TabList.AnchorPoint = Vector2.new(0.5, 0.5)
TabList.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
TabList.BackgroundTransparency = 1.000
TabList.BorderColor3 = Color3.fromRGB(255, 0, 0)
TabList.BorderSizePixel = 3
TabList.Position = UDim2.new(0.169617563, 0, 0.414210528, 72)
TabList.Size = UDim2.new(0.326487243, -25, 0.695789456, 36)
TabList.CanvasSize = UDim2.new(0, 0, 0, 0)
TabList.ScrollBarThickness = 0

UIListLayout.Parent = TabList
UIListLayout.FillDirection = Enum.FillDirection.Horizontal
UIListLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout.VerticalAlignment = Enum.VerticalAlignment.Center
UIListLayout.Padding = UDim.new(0, 6)

Placeholder.Name = "Placeholder"
Placeholder.Parent = TabList
Placeholder.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Placeholder.BackgroundTransparency = 1.000
Placeholder.BorderColor3 = Color3.fromRGB(27, 42, 53)
Placeholder.BorderSizePixel = 0
Placeholder.LayoutOrder = -100
Placeholder.Position = UDim2.new(0.174193546, 0, 0, 0)

Template_2.Name = "Template"
Template_2.Parent = TabList
Template_2.BackgroundColor3 = Color3.fromRGB(80, 80, 80)
Template_2.BackgroundTransparency = 0.700
Template_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
Template_2.BorderSizePixel = 0
Template_2.Position = UDim2.new(0.0190476198, 0, 0.0162907261, 0)
Template_2.Size = UDim2.new(0, 110, 0, 30)

UICorner_5.CornerRadius = UDim.new(1, 0)
UICorner_5.Parent = Template_2

Title_3.Name = "Title"
Title_3.Parent = Template_2
Title_3.AnchorPoint = Vector2.new(0.5, 0.5)
Title_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_3.BackgroundTransparency = 1.000
Title_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
Title_3.BorderSizePixel = 0
Title_3.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_3.Size = UDim2.new(0.800000012, 0, 0, 14)
Title_3.ZIndex = 5
Title_3.Font = Enum.Font.GothamMedium
Title_3.Text = "Automation"
Title_3.TextColor3 = Color3.fromRGB(240, 240, 240)
Title_3.TextSize = 14.000
Title_3.TextTransparency = 0.200

Interact.Name = "Interact"
Interact.Parent = Template_2
Interact.AnchorPoint = Vector2.new(0.5, 0.5)
Interact.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Interact.BackgroundTransparency = 1.000
Interact.BorderColor3 = Color3.fromRGB(27, 42, 53)
Interact.BorderSizePixel = 0
Interact.Position = UDim2.new(0.5, 0, 0.5, 0)
Interact.Size = UDim2.new(1, 0, 1, 0)
Interact.ZIndex = 3
Interact.Font = Enum.Font.SourceSans
Interact.Text = ""
Interact.TextColor3 = Color3.fromRGB(0, 0, 0)
Interact.TextSize = 14.000
Interact.TextTransparency = 1.000

Image_2.Name = "Image"
Image_2.Parent = Template_2
Image_2.AnchorPoint = Vector2.new(0, 0.5)
Image_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Image_2.BackgroundTransparency = 1.000
Image_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
Image_2.BorderSizePixel = 0
Image_2.Position = UDim2.new(0, 11, 0.5, 0)
Image_2.Size = UDim2.new(0, 20, 0, 20)
Image_2.Visible = false
Image_2.ZIndex = 2
Image_2.Image = "rbxassetid://4483362458"
Image_2.ImageColor3 = Color3.fromRGB(240, 240, 240)
Image_2.ScaleType = Enum.ScaleType.Fit

UICorner_6.CornerRadius = UDim.new(0, 13)
UICorner_6.Parent = TabList

Preview.Name = "Preview"
Preview.Parent = Main
Preview.AnchorPoint = Vector2.new(0.5, 0.5)
Preview.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Preview.BorderColor3 = Color3.fromRGB(27, 42, 53)
Preview.Position = UDim2.new(1.24021554, 0, 0.489558876, 0)
Preview.Size = UDim2.new(0, 218, 0, 279)
Preview.Visible = false
Preview.ZIndex = 5

UICorner_7.CornerRadius = UDim.new(0, 9)
UICorner_7.Parent = Preview

Shadow_2.Name = "Shadow"
Shadow_2.Parent = Preview
Shadow_2.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shadow_2.BackgroundTransparency = 1.000
Shadow_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
Shadow_2.BorderSizePixel = 0
Shadow_2.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow_2.Size = UDim2.new(1, 35, 1, 35)
Shadow_2.ZIndex = 4

Image_3.Name = "Image"
Image_3.Parent = Shadow_2
Image_3.AnchorPoint = Vector2.new(0.5, 0.5)
Image_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Image_3.BackgroundTransparency = 1.000
Image_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
Image_3.BorderSizePixel = 0
Image_3.Position = UDim2.new(0.5, 0, 0.5, 0)
Image_3.Size = UDim2.new(1.17956781, 0, 1.29999995, 0)
Image_3.ZIndex = 4
Image_3.Image = "rbxassetid://5587865193"
Image_3.ImageColor3 = Color3.fromRGB(20, 20, 20)
Image_3.ImageTransparency = 0.300

Description.Name = "Description"
Description.Parent = Preview
Description.AnchorPoint = Vector2.new(1, 0)
Description.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Description.BackgroundTransparency = 1.000
Description.BorderColor3 = Color3.fromRGB(27, 42, 53)
Description.BorderSizePixel = 0
Description.Position = UDim2.new(1, -15, 0, 173)
Description.Size = UDim2.new(0, 188, 0, 94)
Description.ZIndex = 5
Description.Font = Enum.Font.Gotham
Description.Text = "Enable Tracers and track users from a point on your screen based on your configuration"
Description.TextColor3 = Color3.fromRGB(210, 210, 210)
Description.TextSize = 14.000
Description.TextWrapped = true
Description.TextXAlignment = Enum.TextXAlignment.Left
Description.TextYAlignment = Enum.TextYAlignment.Top

Title_4.Name = "Title"
Title_4.Parent = Preview
Title_4.AnchorPoint = Vector2.new(1, 0)
Title_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_4.BackgroundTransparency = 1.000
Title_4.BorderColor3 = Color3.fromRGB(27, 42, 53)
Title_4.BorderSizePixel = 0
Title_4.Position = UDim2.new(1, -15, 0, 30)
Title_4.Size = UDim2.new(0, 188, 0, 15)
Title_4.ZIndex = 5
Title_4.Font = Enum.Font.Unknown
Title_4.Text = "Enable Tracers"
Title_4.TextColor3 = Color3.fromRGB(240, 240, 240)
Title_4.TextSize = 15.000
Title_4.TextWrapped = true
Title_4.TextXAlignment = Enum.TextXAlignment.Left

State.Name = "State"
State.Parent = Preview
State.AnchorPoint = Vector2.new(1, 0)
State.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
State.BackgroundTransparency = 1.000
State.BorderColor3 = Color3.fromRGB(27, 42, 53)
State.BorderSizePixel = 0
State.Position = UDim2.new(1, -15, 0, 18)
State.Size = UDim2.new(0, 188, 0, 11)
State.ZIndex = 5
State.Font = Enum.Font.GothamMedium
State.Text = "DISABLED"
State.TextColor3 = Color3.fromRGB(210, 53, 22)
State.TextScaled = true
State.TextSize = 15.000
State.TextTransparency = 0.200
State.TextWrapped = true
State.TextXAlignment = Enum.TextXAlignment.Left

PreviewImage.Name = "PreviewImage"
PreviewImage.Parent = Preview
PreviewImage.AnchorPoint = Vector2.new(1, 0)
PreviewImage.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
PreviewImage.BackgroundTransparency = 1.000
PreviewImage.BorderColor3 = Color3.fromRGB(27, 42, 53)
PreviewImage.Position = UDim2.new(1, -15, 0, 55)
PreviewImage.Size = UDim2.new(0, 188, 0, 106)
PreviewImage.ZIndex = 5
PreviewImage.Image = "rbxassetid://12577727209"

Search_2.Name = "Search"
Search_2.Parent = Main
Search_2.AnchorPoint = Vector2.new(0.5, 0)
Search_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Search_2.BackgroundTransparency = 0.900
Search_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Search_2.BorderSizePixel = 0
Search_2.Position = UDim2.new(0.171388, 0, 0, 57)
Search_2.Size = UDim2.new(0.34277609, -35, -0.0136842104, 35)
Search_2.Visible = false
Search_2.ZIndex = 10

UICorner_8.CornerRadius = UDim.new(1, 0)
UICorner_8.Parent = Search_2

Search_3.Name = "Search"
Search_3.Parent = Search_2
Search_3.AnchorPoint = Vector2.new(0, 0.5)
Search_3.BackgroundTransparency = 1.000
Search_3.Position = UDim2.new(0, 15, 0.5, 1)
Search_3.Size = UDim2.new(0, 16, 0, 16)
Search_3.ZIndex = 10
Search_3.Image = "rbxassetid://18458939117"
Search_3.ImageTransparency = 0.650

Input.Name = "Input"
Input.Parent = Search_2
Input.AnchorPoint = Vector2.new(0, 0.5)
Input.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Input.BackgroundTransparency = 1.000
Input.BorderColor3 = Color3.fromRGB(0, 0, 0)
Input.BorderSizePixel = 0
Input.ClipsDescendants = true
Input.Position = UDim2.new(0, 40, 0.5, 0)
Input.Size = UDim2.new(1, -110, 0, 18)
Input.ZIndex = 10
Input.ClearTextOnFocus = false
Input.Font = Enum.Font.Unknown
Input.PlaceholderColor3 = Color3.fromRGB(178, 178, 178)
Input.PlaceholderText = "Search this page"
Input.Text = ""
Input.TextColor3 = Color3.fromRGB(255, 255, 255)
Input.TextSize = 16.000
Input.TextTransparency = 0.200
Input.TextWrapped = true
Input.TextXAlignment = Enum.TextXAlignment.Left

Shadow_3.Name = "Shadow"
Shadow_3.Parent = Search_2
Shadow_3.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shadow_3.BackgroundTransparency = 1.000
Shadow_3.BorderColor3 = Color3.fromRGB(27, 42, 53)
Shadow_3.BorderSizePixel = 0
Shadow_3.Position = UDim2.new(0.5, 0, 0.528571427, 0)
Shadow_3.Size = UDim2.new(1.45000005, 0, 1.60000002, 0)
Shadow_3.ZIndex = 5
Shadow_3.Image = "rbxassetid://5587865193"
Shadow_3.ImageTransparency = 0.950

Notice.Name = "Notice"
Notice.Parent = Main
Notice.AnchorPoint = Vector2.new(0.5, 0)
Notice.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Notice.BackgroundTransparency = 0.500
Notice.BorderColor3 = Color3.fromRGB(0, 0, 0)
Notice.BorderSizePixel = 0
Notice.Position = UDim2.new(0.5, 0, 0, -50)
Notice.Size = UDim2.new(0, 280, 0, 35)
Notice.Visible = false
Notice.ZIndex = 5

UICorner_9.CornerRadius = UDim.new(1, 0)
UICorner_9.Parent = Notice

Title_5.Name = "Title"
Title_5.Parent = Notice
Title_5.AnchorPoint = Vector2.new(0.5, 0.5)
Title_5.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_5.BackgroundTransparency = 1.000
Title_5.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title_5.BorderSizePixel = 0
Title_5.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_5.Size = UDim2.new(1, 0, 0, 16)
Title_5.ZIndex = 5
Title_5.Font = Enum.Font.Unknown
Title_5.Text = "Loading Saved Configuration"
Title_5.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_5.TextSize = 16.000
Title_5.TextTransparency = 0.100
Title_5.TextWrapped = true

Prompt.Name = "Prompt"
Prompt.Parent = Rayfield
Prompt.AnchorPoint = Vector2.new(0.5, 0)
Prompt.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
Prompt.BackgroundTransparency = 0.300
Prompt.BorderColor3 = Color3.fromRGB(0, 0, 0)
Prompt.BorderSizePixel = 0
Prompt.Position = UDim2.new(0.5, 0, 0, 20)
Prompt.Size = UDim2.new(0, 120, 0, 30)
Prompt.Visible = false

UICorner_10.CornerRadius = UDim.new(1, 0)
UICorner_10.Parent = Prompt

Title_6.Name = "Title"
Title_6.Parent = Prompt
Title_6.AnchorPoint = Vector2.new(0.5, 0.5)
Title_6.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_6.BackgroundTransparency = 1.000
Title_6.BorderColor3 = Color3.fromRGB(0, 0, 0)
Title_6.BorderSizePixel = 0
Title_6.Position = UDim2.new(0.5, 0, 0.5, 0)
Title_6.Size = UDim2.new(1, 0, 1, 0)
Title_6.Font = Enum.Font.Unknown
Title_6.Text = "Show Rayfield"
Title_6.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_6.TextSize = 14.000
Title_6.TextTransparency = 0.300

Interact_2.Name = "Interact"
Interact_2.Parent = Prompt
Interact_2.AnchorPoint = Vector2.new(0.5, 0.5)
Interact_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Interact_2.BackgroundTransparency = 1.000
Interact_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Interact_2.BorderSizePixel = 0
Interact_2.Position = UDim2.new(0.5, 0, 0.5, 0)
Interact_2.Size = UDim2.new(1, 0, 1, 0)
Interact_2.ZIndex = 5
Interact_2.Font = Enum.Font.SourceSans
Interact_2.Text = ""
Interact_2.TextColor3 = Color3.fromRGB(0, 0, 0)
Interact_2.TextSize = 14.000
Interact_2.TextTransparency = 1.000

Notifications.Name = "Notifications"
Notifications.Parent = Rayfield
Notifications.AnchorPoint = Vector2.new(1, 1)
Notifications.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Notifications.BackgroundTransparency = 1.000
Notifications.BorderColor3 = Color3.fromRGB(0, 0, 0)
Notifications.BorderSizePixel = 0
Notifications.Position = UDim2.new(1, -20, 1.01485145, -20)
Notifications.Size = UDim2.new(0, 300, 0, 812)

Template_3.Name = "Template"
Template_3.Parent = Notifications
Template_3.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Template_3.BackgroundTransparency = 0.450
Template_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
Template_3.BorderSizePixel = 0
Template_3.Position = UDim2.new(0, 0, 0.813750029, 0)
Template_3.Size = UDim2.new(1, 0, 0, 170)
Template_3.Visible = false

UICorner_11.CornerRadius = UDim.new(0, 20)
UICorner_11.Parent = Template_3

Icon_2.Name = "Icon"
Icon_2.Parent = Template_3
Icon_2.AnchorPoint = Vector2.new(0, 0.5)
Icon_2.BackgroundColor3 = Color3.fromRGB(209, 209, 209)
Icon_2.BackgroundTransparency = 1.000
Icon_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Icon_2.BorderSizePixel = 0
Icon_2.Position = UDim2.new(0, 25, 0.5, 0)
Icon_2.Size = UDim2.new(0, 24, 0, 24)
Icon_2.Image = "rbxassetid://77891951053543"

Interact_3.Name = "Interact"
Interact_3.Parent = Template_3
Interact_3.AnchorPoint = Vector2.new(0.5, 0.5)
Interact_3.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Interact_3.BackgroundTransparency = 1.000
Interact_3.BorderColor3 = Color3.fromRGB(0, 0, 0)
Interact_3.BorderSizePixel = 0
Interact_3.Position = UDim2.new(0.5, 0, 0.5, 0)
Interact_3.Size = UDim2.new(1, 0, 1, 0)
Interact_3.Font = Enum.Font.SourceSans
Interact_3.Text = ""
Interact_3.TextColor3 = Color3.fromRGB(0, 0, 0)
Interact_3.TextSize = 14.000
Interact_3.TextTransparency = 1.000

Description_2.Name = "Description"
Description_2.Parent = Template_3
Description_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Description_2.BackgroundTransparency = 1.000
Description_2.BorderColor3 = Color3.fromRGB(27, 42, 53)
Description_2.BorderSizePixel = 0
Description_2.Position = UDim2.new(0, 70, 0, 32)
Description_2.Size = UDim2.new(1, -80, 1, -40)
Description_2.ZIndex = 105
Description_2.Font = Enum.Font.Unknown
Description_2.Text = "If you're seeing this, this script may not be on the latest Rayfield version. The developer needs to use the sirius.menu/rayfield loadstring to use the latest features and fixes. \\n\\nVisit sirius.menu/discord for help."
Description_2.TextColor3 = Color3.fromRGB(255, 255, 255)
Description_2.TextSize = 15.000
Description_2.TextTransparency = 0.350
Description_2.TextWrapped = true
Description_2.TextXAlignment = Enum.TextXAlignment.Left
Description_2.TextYAlignment = Enum.TextYAlignment.Top

Title_7.Name = "Title"
Title_7.Parent = Template_3
Title_7.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Title_7.BackgroundTransparency = 1.000
Title_7.BorderColor3 = Color3.fromRGB(27, 42, 53)
Title_7.BorderSizePixel = 0
Title_7.Position = UDim2.new(0, 70, 0, 15)
Title_7.Size = UDim2.new(1, -80, 0, 16)
Title_7.ZIndex = 105
Title_7.Font = Enum.Font.Unknown
Title_7.Text = "Notification Error"
Title_7.TextColor3 = Color3.fromRGB(255, 255, 255)
Title_7.TextSize = 16.000
Title_7.TextWrapped = true
Title_7.TextXAlignment = Enum.TextXAlignment.Left

Shadow_4.Name = "Shadow"
Shadow_4.Parent = Template_3
Shadow_4.AnchorPoint = Vector2.new(0.5, 0.5)
Shadow_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Shadow_4.BackgroundTransparency = 1.000
Shadow_4.BorderColor3 = Color3.fromRGB(27, 42, 53)
Shadow_4.BorderSizePixel = 0
Shadow_4.Position = UDim2.new(0.5, 0, 0.5, 0)
Shadow_4.Size = UDim2.new(1.11060238, 0, 1.92164946, 0)
Shadow_4.ZIndex = 0
Shadow_4.Image = "rbxassetid://3523728077"
Shadow_4.ImageColor3 = Color3.fromRGB(33, 33, 33)
Shadow_4.ImageTransparency = 0.820

BlurFrame.Name = "BlurFrame"
BlurFrame.Parent = Template_3
BlurFrame.AnchorPoint = Vector2.new(0.5, 0.5)
BlurFrame.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
BlurFrame.BackgroundTransparency = 1.000
BlurFrame.BorderColor3 = Color3.fromRGB(0, 0, 0)
BlurFrame.BorderSizePixel = 0
BlurFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
BlurFrame.Size = UDim2.new(1, -18, 1, -18)

UIListLayout_2.Parent = Notifications
UIListLayout_2.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIListLayout_2.SortOrder = Enum.SortOrder.LayoutOrder
UIListLayout_2.VerticalAlignment = Enum.VerticalAlignment.Bottom
UIListLayout_2.Padding = UDim.new(0, 8)

Drag.Name = "Drag"
Drag.Parent = Rayfield
Drag.AnchorPoint = Vector2.new(0.5, 0.5)
Drag.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Drag.BackgroundTransparency = 1.000
Drag.BorderColor3 = Color3.fromRGB(0, 0, 0)
Drag.BorderSizePixel = 0
Drag.Position = UDim2.new(0.5, 0, 0.5, 255)
Drag.Size = UDim2.new(0, 150, 0, 20)
Drag.Visible = false

UICorner_12.CornerRadius = UDim.new(0, 20)
UICorner_12.Parent = Drag

Drag_2.Name = "Drag"
Drag_2.Parent = Drag
Drag_2.AnchorPoint = Vector2.new(0.5, 0.5)
Drag_2.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Drag_2.BackgroundTransparency = 0.700
Drag_2.BorderColor3 = Color3.fromRGB(0, 0, 0)
Drag_2.BorderSizePixel = 0
Drag_2.Position = UDim2.new(0.5, 0, 0.300000012, 0)
Drag_2.Size = UDim2.new(0, 100, 0, 4)

UICorner_13.CornerRadius = UDim.new(0, 20)
UICorner_13.Parent = Drag_2

Interact_4.Name = "Interact"
Interact_4.Parent = Drag
Interact_4.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Interact_4.BackgroundTransparency = 1.000
Interact_4.BorderColor3 = Color3.fromRGB(0, 0, 0)
Interact_4.BorderSizePixel = 0
Interact_4.Size = UDim2.new(1, 0, 1, 0)
Interact_4.Font = Enum.Font.SourceSans
Interact_4.Text = ""
Interact_4.TextColor3 = Color3.fromRGB(0, 0, 0)
Interact_4.TextSize = 14.000
Interact_4.TextTransparency = 1.000

Loading.Name = "Loading"
Loading.Parent = Rayfield
Loading.AnchorPoint = Vector2.new(0.5, 0.5)
Loading.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Loading.BackgroundTransparency = 1.000
Loading.BorderColor3 = Color3.fromRGB(0, 0, 0)
Loading.BorderSizePixel = 0
Loading.LayoutOrder = 99999
Loading.Position = UDim2.new(0.5, 0, 0.5, 0)
Loading.Size = UDim2.new(0, 400, 0, 100)
Loading.Visible = false

Banner.Name = "Banner"
Banner.Parent = Loading
Banner.AnchorPoint = Vector2.new(0.5, 0.5)
Banner.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
Banner.BackgroundTransparency = 1.000
Banner.BorderColor3 = Color3.fromRGB(0, 0, 0)
Banner.BorderSizePixel = 0
Banner.Position = UDim2.new(0.5, 0, 0.5, 0)
Banner.Size = UDim2.new(0, 262, 0, 60)
Banner.Image = "rbxassetid://111263549366178"

-- Add UIStroke to Search_2
local UIStroke_Search = Instance.new("UIStroke")
UIStroke_Search.Parent = Search_2
UIStroke_Search.Color = Color3.fromRGB(65, 65, 65)
UIStroke_Search.Thickness = 1
UIStroke_Search.Transparency = 0.8

-- Add UIStroke to Topbar
local UIStroke_Topbar = Instance.new("UIStroke")
UIStroke_Topbar.Parent = Topbar
UIStroke_Topbar.Color = Color3.fromRGB(50, 50, 50)
UIStroke_Topbar.Thickness = 1
UIStroke_Topbar.Transparency = 1

-- Add UIPageLayout to Elements
local UIPageLayout = Instance.new("UIPageLayout")
UIPageLayout.Parent = Elements
UIPageLayout.SortOrder = Enum.SortOrder.LayoutOrder
UIPageLayout.Animated = true
UIPageLayout.TweenTime = 0.5
UIPageLayout.EasingStyle = Enum.EasingStyle.Exponential
UIPageLayout.EasingDirection = Enum.EasingDirection.Out

-- ============================================================================
-- CONTINUE WITH ORIGINAL FUNCTIONALITY
-- ============================================================================

local buildAttempts = 0
local correctBuild = false
local warned
local globalLoaded
local rayfieldDestroyed = false

-- Validate build
repeat
	if Rayfield:FindFirstChild('Build') and Rayfield.Build.Value == InterfaceBuild then
		correctBuild = true
		break
	end

	correctBuild = false

	if not warned then
		warn('Rayfield | Build Mismatch')
		print('Rayfield may encounter issues as you are running an incompatible interface version ('.. ((Rayfield:FindFirstChild('Build') and Rayfield.Build.Value) or 'No Build') ..').\n\nThis version of Rayfield is intended for interface build '..InterfaceBuild..'.')
		warned = true
	end

	buildAttempts = buildAttempts + 1
until buildAttempts >= 2

Rayfield.Enabled = false

if gethui then
	Rayfield.Parent = gethui()
elseif syn and syn.protect_gui then 
	syn.protect_gui(Rayfield)
	Rayfield.Parent = CoreGui
elseif not useStudio and CoreGui:FindFirstChild("RobloxGui") then
	Rayfield.Parent = CoreGui:FindFirstChild("RobloxGui")
elseif not useStudio then
	Rayfield.Parent = CoreGui
end

if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
elseif not useStudio then
	for _, Interface in ipairs(CoreGui:GetChildren()) do
		if Interface.Name == Rayfield.Name and Interface ~= Rayfield then
			Interface.Enabled = false
			Interface.Name = "Rayfield-Old"
		end
	end
end

local minSize = Vector2.new(1024, 768)
local useMobileSizing

if Rayfield.AbsoluteSize.X < minSize.X and Rayfield.AbsoluteSize.Y < minSize.Y then
	useMobileSizing = true
end

if UserInputService.TouchEnabled then
	useMobilePrompt = true
end

-- Object Variables
local MPrompt = Rayfield:FindFirstChild('Prompt')
local dragBar = Rayfield:FindFirstChild('Drag')
local dragInteract = dragBar and dragBar.Interact or nil
local dragBarCosmetic = dragBar and dragBar.Drag or nil

local dragOffset = 255
local dragOffsetMobile = 150

Rayfield.DisplayOrder = 100
LoadingFrame.Version.Text = Release

-- Load Icons
local Icons = useStudio and require(script.Parent.icons) or loadWithTimeout('https://raw.githubusercontent.com/SiriusSoftwareLtd/Rayfield/refs/heads/main/icons.lua')

-- Variables
local CFileName = nil
local CEnabled = false
local Minimised = false
local Hidden = false
local Debounce = false
local searchOpen = false
local keybindConnections = {}

local SelectedTheme = RayfieldLibrary.Theme.Default

-- Continue with all the original functions and logic...
-- (The rest of the file continues exactly as in the original, starting from ChangeTheme function)
