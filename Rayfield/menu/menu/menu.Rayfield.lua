-- Modern Orion Library - Enhanced UI Framework (FIXED)
-- Bug fixes applied

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local LocalPlayer = game:GetService("Players").LocalPlayer
local Mouse = LocalPlayer:GetMouse()
local HttpService = game:GetService("HttpService")

local ModernLib = {
	Elements = {},
	ThemeObjects = {},
	Connections = {},
	Flags = {},
	Themes = {
		Default = {
			Main = Color3.fromRGB(0, 0, 0),
			Second = Color3.fromRGB(0, 0, 0),
			Stroke = Color3.fromRGB(255, 0, 0),
			Divider = Color3.fromRGB(255, 0, 0),
			Text = Color3.fromRGB(255, 0, 0),
			TextDark = Color3.fromRGB(0, 0, 0),
			-- BUG FIX #1: Added missing theme colors
			Accent = Color3.fromRGB(255, 100, 100),
			Success = Color3.fromRGB(100, 255, 100),
			Warning = Color3.fromRGB(255, 200, 100),
			Error = Color3.fromRGB(255, 100, 100)
		}
	},
	SelectedTheme = "Default",
	Folder = nil,
	SaveCfg = false,
	AnimationSpeed = 0.3
}

-- Load Feather Icons
local Icons = {}
local Success, Response = pcall(function()
	Icons = HttpService:JSONDecode(game:HttpGetAsync("https://raw.githubusercontent.com/evoincorp/lucideblox/master/src/modules/util/icons.json")).icons
end)

if not Success then
	warn("\nModern Library - Failed to load icons. Error: " .. Response .. "\n")
end

local function GetIcon(IconName)
	return Icons[IconName] or nil
end

-- Create ScreenGui
local Orion = Instance.new("ScreenGui")
Orion.Name = "ModernOrion"
Orion.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

if syn then
	syn.protect_gui(Orion)
	Orion.Parent = game.CoreGui
else
	Orion.Parent = gethui() or game.CoreGui
end

-- Clean up existing instances
if gethui then
	for _, Interface in ipairs(gethui():GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
else
	for _, Interface in ipairs(game.CoreGui:GetChildren()) do
		if Interface.Name == Orion.Name and Interface ~= Orion then
			Interface:Destroy()
		end
	end
end

function ModernLib:IsRunning()
	if gethui then
		return Orion.Parent == gethui()
	else
		return Orion.Parent == game:GetService("CoreGui")
	end
end

local function AddConnection(Signal, Function)
	if not ModernLib:IsRunning() then return end
	local SignalConnect = Signal:Connect(Function)
	table.insert(ModernLib.Connections, SignalConnect)
	return SignalConnect
end

-- Cleanup task
task.spawn(function()
	while ModernLib:IsRunning() do
		task.wait()
	end
	for _, Connection in next, ModernLib.Connections do
		Connection:Disconnect()
	end
end)

-- Improved draggable system with smooth inertia
local function MakeDraggable(DragPoint, Main)
	pcall(function()
		local Dragging = false
		local DragInput, MousePos, FramePos
		local DragVelocity = Vector2.new(0, 0)
		local LastUpdateTime = tick()

		AddConnection(DragPoint.InputBegan, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseButton1 or Input.UserInputType == Enum.UserInputType.Touch then
				Dragging = true
				MousePos = Input.Position
				FramePos = Main.Position
				DragVelocity = Vector2.new(0, 0)
				LastUpdateTime = tick()

				Input.Changed:Connect(function()
					if Input.UserInputState == Enum.UserInputState.End then
						Dragging = false
						-- Apply inertia effect
						local InertiaTime = 0.5
						local StartVelocity = DragVelocity
						local StartTime = tick()
						
						spawn(function()
							while tick() - StartTime < InertiaTime do
								local Progress = (tick() - StartTime) / InertiaTime
								local Damping = 1 - Progress
								local CurrentVelocity = StartVelocity * Damping * 0.3
								
								Main.Position = UDim2.new(
									Main.Position.X.Scale,
									Main.Position.X.Offset + CurrentVelocity.X,
									Main.Position.Y.Scale,
									Main.Position.Y.Offset + CurrentVelocity.Y
								)
								
								RunService.RenderStepped:Wait()
							end
						end)
					end
				end)
			end
		end)

		AddConnection(DragPoint.InputChanged, function(Input)
			if Input.UserInputType == Enum.UserInputType.MouseMovement or Input.UserInputType == Enum.UserInputType.Touch then
				DragInput = Input
			end
		end)

		AddConnection(UserInputService.InputChanged, function(Input)
			if Input == DragInput and Dragging then
				local CurrentTime = tick()
				local DeltaTime = CurrentTime - LastUpdateTime
				local Delta = Input.Position - MousePos
				
				-- Calculate velocity for inertia
				if DeltaTime > 0 then
					DragVelocity = Delta / DeltaTime
				end
				
				Main.Position = UDim2.new(
					FramePos.X.Scale,
					FramePos.X.Offset + Delta.X,
					FramePos.Y.Scale,
					FramePos.Y.Offset + Delta.Y
				)
				
				LastUpdateTime = CurrentTime
			end
		end)
	end)
end

-- Utility Functions
local function Create(Name, Properties, Children)
	local Object = Instance.new(Name)
	for i, v in next, Properties or {} do
		Object[i] = v
	end
	for i, v in next, Children or {} do
		v.Parent = Object
	end
	return Object
end

local function CreateElement(ElementName, ElementFunction)
	ModernLib.Elements[ElementName] = function(...)
		return ElementFunction(...)
	end
end

local function MakeElement(ElementName, ...)
	return ModernLib.Elements[ElementName](...)
end

local function Round(Number, Factor)
	local Result = math.floor(Number / Factor + (math.sign(Number) * 0.5)) * Factor
	if Result < 0 then Result = Result + Factor end
	return Result
end

local function ReturnProperty(Object)
	if Object:IsA("Frame") or Object:IsA("TextButton") then
		return "BackgroundColor3"
	elseif Object:IsA("ScrollingFrame") then
		return "ScrollBarImageColor3"
	elseif Object:IsA("UIStroke") then
		return "Color"
	elseif Object:IsA("TextLabel") or Object:IsA("TextBox") then
		return "TextColor3"
	elseif Object:IsA("ImageLabel") or Object:IsA("ImageButton") then
		return "ImageColor3"
	end
end

local function AddThemeObject(Object, Type)
	if not ModernLib.ThemeObjects[Type] then
		ModernLib.ThemeObjects[Type] = {}
	end
	table.insert(ModernLib.ThemeObjects[Type], Object)
	Object[ReturnProperty(Object)] = ModernLib.Themes[ModernLib.SelectedTheme][Type]
	return Object
end

local function SetTheme(ThemeName)
	if not ModernLib.Themes[ThemeName] then return end
	ModernLib.SelectedTheme = ThemeName
	
	for Name, Type in pairs(ModernLib.ThemeObjects) do
		for _, Object in pairs(Type) do
			if Object and Object.Parent then
				TweenService:Create(Object, TweenInfo.new(ModernLib.AnimationSpeed, Enum.EasingStyle.Quint), {
					[ReturnProperty(Object)] = ModernLib.Themes[ModernLib.SelectedTheme][Name]
				}):Play()
			end
		end
	end
end

-- Element Creators
CreateElement("Corner", function(Scale, Offset)
	return Create("UICorner", {
		CornerRadius = UDim.new(Scale or 0, Offset or 8)
	})
end)

CreateElement("Stroke", function(Color, Thickness)
	return Create("UIStroke", {
		Color = Color or Color3.fromRGB(255, 255, 255),
		Thickness = Thickness or 1,
		ApplyStrokeMode = Enum.ApplyStrokeMode.Border
	})
end)

CreateElement("List", function(Scale, Offset)
	return Create("UIListLayout", {
		SortOrder = Enum.SortOrder.LayoutOrder,
		Padding = UDim.new(Scale or 0, Offset or 0)
	})
end)

CreateElement("Padding", function(All)
	All = All or 4
	return Create("UIPadding", {
		PaddingBottom = UDim.new(0, All),
		PaddingLeft = UDim.new(0, All),
		PaddingRight = UDim.new(0, All),
		PaddingTop = UDim.new(0, All)
	})
end)

CreateElement("TFrame", function()
	return Create("Frame", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
end)

CreateElement("Frame", function(Color)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	})
end)

CreateElement("RoundFrame", function(Color, Radius)
	return Create("Frame", {
		BackgroundColor3 = Color or Color3.fromRGB(255, 255, 255),
		BorderSizePixel = 0
	}, {
		MakeElement("Corner", 0, Radius or 8)
	})
end)

CreateElement("Button", function()
	return Create("TextButton", {
		Text = "",
		AutoButtonColor = false,
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
end)

CreateElement("ScrollFrame", function(Color, Width)
	return Create("ScrollingFrame", {
		BackgroundTransparency = 1,
		ScrollBarImageColor3 = Color,
		BorderSizePixel = 0,
		ScrollBarThickness = Width or 4,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		ScrollingDirection = Enum.ScrollingDirection.Y
	})
end)

CreateElement("Image", function(ImageID)
	local ImageNew = Create("ImageLabel", {
		Image = ImageID or "",
		BackgroundTransparency = 1,
		BorderSizePixel = 0
	})
	
	if GetIcon(ImageID) then
		ImageNew.Image = GetIcon(ImageID)
	end
	
	return ImageNew
end)

CreateElement("Label", function(Text, TextSize, Transparency)
	return Create("TextLabel", {
		Text = Text or "",
		TextColor3 = Color3.fromRGB(240, 240, 240),
		TextTransparency = Transparency or 0,
		TextSize = TextSize or 14,
		Font = Enum.Font.GothamMedium,
		RichText = true,
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		TextXAlignment = Enum.TextXAlignment.Left
	})
end)

-- Modern Notification System
local NotificationHolder = Create("Frame", {
	Position = UDim2.new(1, -20, 1, -20),
	Size = UDim2.new(0, 320, 1, -40),
	AnchorPoint = Vector2.new(1, 1),
	BackgroundTransparency = 1,
	Parent = Orion
}, {
	Create("UIListLayout", {
		HorizontalAlignment = Enum.HorizontalAlignment.Right,
		SortOrder = Enum.SortOrder.LayoutOrder,
		VerticalAlignment = Enum.VerticalAlignment.Bottom,
		Padding = UDim.new(0, 10)
	})
})

function ModernLib:MakeNotification(Config)
	spawn(function()
		Config.Name = Config.Name or "Notification"
		Config.Content = Config.Content or "Notification content"
		Config.Image = Config.Image or "bell"
		Config.Time = Config.Time or 5
		Config.Type = Config.Type or "Default" -- Default, Success, Warning, Error

		local TypeColors = {
			Default = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
			Success = ModernLib.Themes[ModernLib.SelectedTheme].Success,
			Warning = ModernLib.Themes[ModernLib.SelectedTheme].Warning,
			Error = ModernLib.Themes[ModernLib.SelectedTheme].Error
		}

		local NotifFrame = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			BackgroundTransparency = 1,
			Parent = NotificationHolder,
			AutomaticSize = Enum.AutomaticSize.Y
		})

		local NotifContent = Create("Frame", {
			Size = UDim2.new(1, 0, 0, 0),
			Position = UDim2.new(1, 20, 0, 0),
			BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
			BorderSizePixel = 0,
			AutomaticSize = Enum.AutomaticSize.Y,
			ClipsDescendants = true,
			Parent = NotifFrame
		}, {
			MakeElement("Corner", 0, 10),
			Create("UIStroke", {
				Color = TypeColors[Config.Type],
				Thickness = 1.5,
				Transparency = 0.5
			}),
			Create("Frame", {
				Size = UDim2.new(0, 3, 1, 0),
				BackgroundColor3 = TypeColors[Config.Type],
				BorderSizePixel = 0
			}, {
				MakeElement("Corner", 0, 10)
			}),
			MakeElement("Padding", 12),
			Create("ImageLabel", {
				Size = UDim2.new(0, 24, 0, 24),
				Position = UDim2.new(0, 12, 0, 12),
				Image = GetIcon(Config.Image) or "",
				ImageColor3 = TypeColors[Config.Type],
				BackgroundTransparency = 1
			}),
			Create("TextLabel", {
				Size = UDim2.new(1, -48, 0, 24),
				Position = UDim2.new(0, 48, 0, 12),
				Text = Config.Name,
				TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
				TextSize = 15,
				Font = Enum.Font.GothamBold,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			}),
			Create("TextLabel", {
				Size = UDim2.new(1, -48, 0, 0),
				Position = UDim2.new(0, 48, 0, 40),
				Text = Config.Content,
				TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].TextDark,
				TextSize = 13,
				Font = Enum.Font.Gotham,
				TextXAlignment = Enum.TextXAlignment.Left,
				TextWrapped = true,
				BackgroundTransparency = 1,
				AutomaticSize = Enum.AutomaticSize.Y
			})
		})

		-- Slide in animation
		TweenService:Create(NotifContent, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(0, 0, 0, 0)
		}):Play()

		-- Wait and slide out
		wait(Config.Time - 0.5)
		
		local FadeOut = TweenService:Create(NotifContent, TweenInfo.new(0.5, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {
			Position = UDim2.new(1, 20, 0, 0),
			BackgroundTransparency = 1
		})
		FadeOut:Play()
		
		FadeOut.Completed:Connect(function()
			NotifFrame:Destroy()
		end)
	end)
end

-- Save/Load Configuration
local function PackColor(Color)
	return {R = Color.R * 255, G = Color.G * 255, B = Color.B * 255}
end

local function UnpackColor(Color)
	-- BUG FIX #2: Added validation for color data
	if type(Color) ~= "table" or not Color.R or not Color.G or not Color.B then
		return Color3.fromRGB(255, 255, 255) -- Default color
	end
	return Color3.fromRGB(Color.R, Color.G, Color.B)
end

local function LoadCfg(Config)
	-- BUG FIX #3: Added pcall to handle corrupted configs
	local Success, Data = pcall(function()
		return HttpService:JSONDecode(Config)
	end)
	
	if not Success then
		warn("Failed to load config: Invalid JSON")
		return
	end
	
	for FlagName, FlagValue in pairs(Data) do
		if ModernLib.Flags[FlagName] then
			spawn(function()
				pcall(function()
					if ModernLib.Flags[FlagName].Type == "Colorpicker" then
						ModernLib.Flags[FlagName]:Set(UnpackColor(FlagValue))
					else
						ModernLib.Flags[FlagName]:Set(FlagValue)
					end
				end)
			end)
		end
	end
end

local function SaveCfg(Name)
	if not ModernLib.SaveCfg then return end
	
	-- BUG FIX #4: Added pcall for file operations
	pcall(function()
		local Data = {}
		for FlagName, Flag in pairs(ModernLib.Flags) do
			if Flag.Save then
				if Flag.Type == "Colorpicker" then
					Data[FlagName] = PackColor(Flag.Value)
				else
					Data[FlagName] = Flag.Value
				end
			end
		end
		
		writefile(ModernLib.Folder .. "/" .. Name .. ".json", HttpService:JSONEncode(Data))
	end)
end

function ModernLib:Init()
	if ModernLib.SaveCfg then
		pcall(function()
			local ConfigFile = ModernLib.Folder .. "/" .. game.GameId .. ".json"
			if isfile(ConfigFile) then
				LoadCfg(readfile(ConfigFile))
				ModernLib:MakeNotification({
					Name = "Config Loaded",
					Content = "Configuration loaded successfully",
					Type = "Success",
					Time = 3
				})
			end
		end)
	end
end

-- Main Window Creation
function ModernLib:MakeWindow(Config)
	Config = Config or {}
	Config.Name = Config.Name or "Modern UI"
	Config.ConfigFolder = Config.ConfigFolder or "ModernConfig"
	Config.SaveConfig = Config.SaveConfig or false
	Config.HidePremium = Config.HidePremium or true
	Config.IntroEnabled = Config.IntroEnabled ~= false
	Config.IntroText = Config.IntroText or "Modern UI"
	Config.CloseCallback = Config.CloseCallback or function() end
	Config.Icon = Config.Icon or "layout-dashboard"
	Config.Size = Config.Size or {615, 400}

	ModernLib.Folder = Config.ConfigFolder
	ModernLib.SaveCfg = Config.SaveConfig

	if Config.SaveConfig and not isfolder(Config.ConfigFolder) then
		makefolder(Config.ConfigFolder)
	end

	local FirstTab = true
	local Minimized = false
	local UIHidden = false

	-- Create main window structure
	local MainWindow = Create("Frame", {
		Parent = Orion,
		Position = UDim2.new(0.5, -Config.Size[1]/2, 0.5, -Config.Size[2]/2),
		Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2]),
		BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Main,
		BorderSizePixel = 0,
		ClipsDescendants = false
	}, {
		MakeElement("Corner", 0, 12),
		Create("UIStroke", {
			Color = ModernLib.Themes[ModernLib.SelectedTheme].Stroke,
			Thickness = 1,
			Transparency = 0.5
		}),
		-- Drop shadow effect
		Create("ImageLabel", {
			Size = UDim2.new(1, 40, 1, 40),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = "rbxassetid://5554236805",
			ImageColor3 = Color3.new(0, 0, 0),
			ImageTransparency = 0.7,
			BackgroundTransparency = 1,
			ZIndex = -1,
			ScaleType = Enum.ScaleType.Slice,
			SliceCenter = Rect.new(23, 23, 277, 277)
		})
	})

	AddThemeObject(MainWindow, "Main")

	-- Top bar
	local TopBar = Create("Frame", {
		Size = UDim2.new(1, 0, 0, 50),
		BackgroundTransparency = 1,
		Parent = MainWindow
	}, {
		Create("Frame", {
			Size = UDim2.new(1, 0, 0, 1),
			Position = UDim2.new(0, 0, 1, -1),
			BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Divider,
			BorderSizePixel = 0
		}),
		Create("ImageLabel", {
			Size = UDim2.new(0, 24, 0, 24),
			Position = UDim2.new(0, 15, 0, 13),
			Image = GetIcon(Config.Icon) or "",
			ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
			BackgroundTransparency = 1
		}),
		Create("TextLabel", {
			Size = UDim2.new(1, -120, 1, 0),
			Position = UDim2.new(0, 47, 0, 0),
			Text = Config.Name,
			TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
			TextSize = 16,
			Font = Enum.Font.GothamBold,
			TextXAlignment = Enum.TextXAlignment.Left,
			BackgroundTransparency = 1
		})
	})

	-- BUG FIX #5: Get children properly instead of using NextSibling
	local TopBarChildren = TopBar:GetChildren()
	for _, child in ipairs(TopBarChildren) do
		if child:IsA("Frame") and child.Size.Y.Offset == 1 then
			AddThemeObject(child, "Divider")
		elseif child:IsA("ImageLabel") then
			AddThemeObject(child, "Accent")
		elseif child:IsA("TextLabel") then
			AddThemeObject(child, "Text")
		end
	end

	-- Control buttons
	local ControlsFrame = Create("Frame", {
		Size = UDim2.new(0, 80, 0, 32),
		Position = UDim2.new(1, -90, 0, 9),
		BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
		BorderSizePixel = 0,
		Parent = TopBar
	}, {
		MakeElement("Corner", 0, 6),
		Create("UIStroke", {
			Color = ModernLib.Themes[ModernLib.SelectedTheme].Stroke,
			Thickness = 1
		})
	})

	AddThemeObject(ControlsFrame, "Second")
	AddThemeObject(ControlsFrame:FindFirstChildOfClass("UIStroke"), "Stroke")

	-- Minimize button
	local MinimizeBtn = Create("TextButton", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Text = "",
		BackgroundTransparency = 1,
		Parent = ControlsFrame
	}, {
		Create("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = GetIcon("minus") or "",
			ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
			BackgroundTransparency = 1
		})
	})

	AddThemeObject(MinimizeBtn:FindFirstChildOfClass("ImageLabel"), "Text")

	-- Close button
	local CloseBtn = Create("TextButton", {
		Size = UDim2.new(0.5, 0, 1, 0),
		Position = UDim2.new(0.5, 0, 0, 0),
		Text = "",
		BackgroundTransparency = 1,
		Parent = ControlsFrame
	}, {
		Create("ImageLabel", {
			Size = UDim2.new(0, 18, 0, 18),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			AnchorPoint = Vector2.new(0.5, 0.5),
			Image = GetIcon("x") or "",
			ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Error,
			BackgroundTransparency = 1
		})
	})

	AddThemeObject(CloseBtn:FindFirstChildOfClass("ImageLabel"), "Error")

	-- Separator line
	Create("Frame", {
		Size = UDim2.new(0, 1, 1, -6),
		Position = UDim2.new(0.5, 0, 0, 3),
		BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Stroke,
		BorderSizePixel = 0,
		Parent = ControlsFrame
	})

	-- Sidebar for tabs
	local Sidebar = Create("Frame", {
		Size = UDim2.new(0, 180, 1, -50),
		Position = UDim2.new(0, 0, 0, 50),
		BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
		BorderSizePixel = 0,
		Parent = MainWindow
	}, {
		Create("Frame", {
			Size = UDim2.new(0, 10, 1, 0),
			Position = UDim2.new(0, 0, 0, 0),
			BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
			BorderSizePixel = 0
		}),
		Create("Frame", {
			Size = UDim2.new(0, 1, 1, 0),
			Position = UDim2.new(1, -1, 0, 0),
			BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Divider,
			BorderSizePixel = 0
		})
	})

	AddThemeObject(Sidebar, "Second")
	
	-- BUG FIX #6: Get sidebar children properly
	local SidebarChildren = Sidebar:GetChildren()
	for _, child in ipairs(SidebarChildren) do
		if child:IsA("Frame") then
			if child.Size.X.Offset == 10 then
				AddThemeObject(child, "Second")
			elseif child.Size.X.Offset == 1 then
				AddThemeObject(child, "Divider")
			end
		end
	end

	local TabHolder = Create("ScrollingFrame", {
		Size = UDim2.new(1, 0, 1, -10),
		Position = UDim2.new(0, 0, 0, 10),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		ScrollBarThickness = 0,
		CanvasSize = UDim2.new(0, 0, 0, 0),
		Parent = Sidebar
	}, {
		MakeElement("List", 0, 8),
		MakeElement("Padding", 10)
	})

	TabHolder.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
		TabHolder.CanvasSize = UDim2.new(0, 0, 0, TabHolder.UIListLayout.AbsoluteContentSize.Y + 20)
	end)

	-- Make draggable
	MakeDraggable(TopBar, MainWindow)

	-- Button functionality
	CloseBtn.MouseButton1Click:Connect(function()
		MainWindow.Visible = false
		UIHidden = true
		ModernLib:MakeNotification({
			Name = "UI Hidden",
			Content = "Press RightShift to show again",
			Type = "Default",
			Time = 4
		})
		Config.CloseCallback()
	end)

	UserInputService.InputBegan:Connect(function(Input)
		if Input.KeyCode == Enum.KeyCode.RightShift and UIHidden then
			MainWindow.Visible = true
			UIHidden = false
		end
	end)

	MinimizeBtn.MouseButton1Click:Connect(function()
		Minimized = not Minimized
		if Minimized then
			TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				Size = UDim2.new(0, MainWindow.Size.X.Offset, 0, 50)
			}):Play()
			MinimizeBtn:FindFirstChildOfClass("ImageLabel").Image = GetIcon("plus") or ""
		else
			TweenService:Create(MainWindow, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2])
			}):Play()
			MinimizeBtn:FindFirstChildOfClass("ImageLabel").Image = GetIcon("minus") or ""
		end
	end)

	-- Intro animation
	if Config.IntroEnabled then
		spawn(function()
			MainWindow.Visible = false
			
			local IntroFrame = Create("Frame", {
				Size = UDim2.new(0, 300, 0, 150),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Main,
				BorderSizePixel = 0,
				Parent = Orion,
				BackgroundTransparency = 1
			}, {
				MakeElement("Corner", 0, 15),
				Create("UIStroke", {
					Color = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
					Thickness = 2,
					Transparency = 1
				}),
				Create("ImageLabel", {
					Size = UDim2.new(0, 48, 0, 48),
					Position = UDim2.new(0.5, 0, 0.35, 0),
					AnchorPoint = Vector2.new(0.5, 0.5),
					Image = GetIcon(Config.Icon) or "",
					ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
					BackgroundTransparency = 1,
					ImageTransparency = 1
				}),
				Create("TextLabel", {
					Size = UDim2.new(1, -40, 0, 30),
					Position = UDim2.new(0, 20, 0.65, 0),
					Text = Config.IntroText,
					TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
					TextSize = 18,
					Font = Enum.Font.GothamBold,
					BackgroundTransparency = 1,
					TextTransparency = 1
				})
			})

			-- Fade in
			TweenService:Create(IntroFrame, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				BackgroundTransparency = 0
			}):Play()
			
			TweenService:Create(IntroFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				Transparency = 0.3
			}):Play()
			
			TweenService:Create(IntroFrame:FindFirstChildOfClass("ImageLabel"), TweenInfo.new(0.6, Enum.EasingStyle.Quint), {
				ImageTransparency = 0
			}):Play()
			
			wait(0.3)
			
			TweenService:Create(IntroFrame:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				TextTransparency = 0
			}):Play()
			
			wait(1.5)
			
			-- Fade out
			TweenService:Create(IntroFrame, TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				BackgroundTransparency = 1
			}):Play()
			
			TweenService:Create(IntroFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				Transparency = 1
			}):Play()
			
			TweenService:Create(IntroFrame:FindFirstChildOfClass("ImageLabel"), TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				ImageTransparency = 1
			}):Play()
			
			TweenService:Create(IntroFrame:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.4, Enum.EasingStyle.Quint), {
				TextTransparency = 1
			}):Play()
			
			wait(0.5)
			
			IntroFrame:Destroy()
			MainWindow.Visible = true
			
			-- Window entrance animation
			MainWindow.Size = UDim2.new(0, Config.Size[1] * 0.8, 0, Config.Size[2] * 0.8)
			MainWindow.BackgroundTransparency = 1
			
			TweenService:Create(MainWindow, TweenInfo.new(0.5, Enum.EasingStyle.Quint), {
				Size = UDim2.new(0, Config.Size[1], 0, Config.Size[2]),
				BackgroundTransparency = 0
			}):Play()
		end)
	end

	local WindowFunctions = {}

	function WindowFunctions:MakeTab(TabConfig)
		TabConfig = TabConfig or {}
		TabConfig.Name = TabConfig.Name or "Tab"
		TabConfig.Icon = TabConfig.Icon or "file"
		
		-- Create tab button
		local TabButton = Create("TextButton", {
			Size = UDim2.new(1, 0, 0, 36),
			BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			Text = "",
			Parent = TabHolder
		}, {
			MakeElement("Corner", 0, 6),
			Create("ImageLabel", {
				Size = UDim2.new(0, 20, 0, 20),
				Position = UDim2.new(0, 10, 0.5, 0),
				AnchorPoint = Vector2.new(0, 0.5),
				Image = GetIcon(TabConfig.Icon) or "",
				ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].TextDark,
				BackgroundTransparency = 1
			}),
			Create("TextLabel", {
				Size = UDim2.new(1, -40, 1, 0),
				Position = UDim2.new(0, 38, 0, 0),
				Text = TabConfig.Name,
				TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].TextDark,
				TextSize = 14,
				Font = Enum.Font.GothamMedium,
				TextXAlignment = Enum.TextXAlignment.Left,
				BackgroundTransparency = 1
			})
		})

		AddThemeObject(TabButton:FindFirstChildOfClass("ImageLabel"), "TextDark")
		AddThemeObject(TabButton:FindFirstChildOfClass("TextLabel"), "TextDark")

		-- Create content container
		local TabContent = Create("ScrollingFrame", {
			Size = UDim2.new(1, -180, 1, -50),
			Position = UDim2.new(0, 180, 0, 50),
			BackgroundTransparency = 1,
			BorderSizePixel = 0,
			ScrollBarThickness = 4,
			ScrollBarImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Divider,
			CanvasSize = UDim2.new(0, 0, 0, 0),
			Visible = false,
			Parent = MainWindow
		}, {
			MakeElement("List", 0, 10),
			MakeElement("Padding", 15)
		})

		AddThemeObject(TabContent, "Divider")

		TabContent.UIListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
			TabContent.CanvasSize = UDim2.new(0, 0, 0, TabContent.UIListLayout.AbsoluteContentSize.Y + 30)
		end)

		-- First tab is selected by default
		if FirstTab then
			FirstTab = false
			TabButton.BackgroundTransparency = 0
			TabButton:FindFirstChildOfClass("ImageLabel").ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent
			TabButton:FindFirstChildOfClass("TextLabel").TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text
			TabButton:FindFirstChildOfClass("TextLabel").Font = Enum.Font.GothamBold
			TabContent.Visible = true
			
			AddThemeObject(TabButton, "Accent")
			AddThemeObject(TabButton:FindFirstChildOfClass("ImageLabel"), "Accent")
			AddThemeObject(TabButton:FindFirstChildOfClass("TextLabel"), "Text")
		end

		-- Tab switching
		TabButton.MouseButton1Click:Connect(function()
			-- Deselect all tabs
			for _, Tab in pairs(TabHolder:GetChildren()) do
				if Tab:IsA("TextButton") then
					TweenService:Create(Tab, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
						BackgroundTransparency = 1
					}):Play()
					
					-- BUG FIX #7: Check if ImageLabel exists
					local TabIcon = Tab:FindFirstChildOfClass("ImageLabel")
					if TabIcon then
						TweenService:Create(TabIcon, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].TextDark
						}):Play()
					end
					
					local TabLabel = Tab:FindFirstChildOfClass("TextLabel")
					if TabLabel then
						TweenService:Create(TabLabel, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].TextDark
						}):Play()
						TabLabel.Font = Enum.Font.GothamMedium
					end
				end
			end

			-- Hide all content
			for _, Content in pairs(MainWindow:GetChildren()) do
				if Content:IsA("ScrollingFrame") and Content ~= TabHolder then
					Content.Visible = false
				end
			end

			-- Select this tab
			TweenService:Create(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				BackgroundTransparency = 0
			}):Play()
			TweenService:Create(TabButton:FindFirstChildOfClass("ImageLabel"), TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent
			}):Play()
			TweenService:Create(TabButton:FindFirstChildOfClass("TextLabel"), TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
				TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text
			}):Play()
			TabButton:FindFirstChildOfClass("TextLabel").Font = Enum.Font.GothamBold
			TabContent.Visible = true
		end)

		-- Hover effects
		TabButton.MouseEnter:Connect(function()
			if TabButton.BackgroundTransparency == 1 then
				TweenService:Create(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 0.9
				}):Play()
			end
		end)

		TabButton.MouseLeave:Connect(function()
			if TabContent.Visible == false then
				TweenService:Create(TabButton, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
					BackgroundTransparency = 1
				}):Play()
			end
		end)

		local TabElements = {}

		function TabElements:AddSection(Name)
			local SectionFrame = Create("Frame", {
				Size = UDim2.new(1, 0, 0, 30),
				BackgroundTransparency = 1,
				Parent = TabContent
			}, {
				Create("TextLabel", {
					Size = UDim2.new(1, 0, 1, 0),
					Text = Name or "Section",
					TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
					TextSize = 16,
					Font = Enum.Font.GothamBold,
					TextXAlignment = Enum.TextXAlignment.Left,
					BackgroundTransparency = 1
				}),
				Create("Frame", {
					Size = UDim2.new(1, 0, 0, 2),
					Position = UDim2.new(0, 0, 1, -4),
					BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
					BorderSizePixel = 0
				}, {
					MakeElement("Corner", 0, 4)
				}),
				Create("Frame", {
					Size = UDim2.new(0, 0, 1, -10),
					Position = UDim2.new(0, 0, 0, 0),
					BackgroundTransparency = 1,
					AutomaticSize = Enum.AutomaticSize.Y
				}, {
					MakeElement("List", 0, 8)
				})
			})

			AddThemeObject(SectionFrame:FindFirstChildOfClass("TextLabel"), "Text")
			
			-- BUG FIX #8: Get children properly for section
			local SectionChildren = SectionFrame:GetChildren()
			for _, child in ipairs(SectionChildren) do
				if child:IsA("Frame") and child.Size.Y.Offset == 2 then
					AddThemeObject(child, "Accent")
					break
				end
			end

			local SectionContent = nil
			for _, child in ipairs(SectionChildren) do
				if child:IsA("Frame") and child:FindFirstChildOfClass("UIListLayout") then
					SectionContent = child
					break
				end
			end
			
			if not SectionContent then
				warn("Could not find SectionContent")
				return {}
			end
			
			SectionContent:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
				SectionFrame.Size = UDim2.new(1, 0, 0, SectionContent.UIListLayout.AbsoluteContentSize.Y + 40)
			end)

			local SectionElements = {}

			function SectionElements:AddButton(ButtonConfig)
				ButtonConfig = ButtonConfig or {}
				ButtonConfig.Name = ButtonConfig.Name or "Button"
				ButtonConfig.Callback = ButtonConfig.Callback or function() end

				local ButtonFrame = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
					BorderSizePixel = 0,
					Text = "",
					Parent = SectionContent,
					AutoButtonColor = false
				}, {
					MakeElement("Corner", 0, 8),
					Create("UIStroke", {
						Color = ModernLib.Themes[ModernLib.SelectedTheme].Stroke,
						Thickness = 1,
						-- BUG FIX #9: Set initial transparency
						Transparency = 0.5
					}),
					Create("TextLabel", {
						Size = UDim2.new(1, -20, 1, 0),
						Position = UDim2.new(0, 15, 0, 0),
						Text = ButtonConfig.Name,
						TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
						TextSize = 14,
						Font = Enum.Font.GothamMedium,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					}),
					Create("ImageLabel", {
						Size = UDim2.new(0, 18, 0, 18),
						Position = UDim2.new(1, -28, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						Image = GetIcon("chevron-right") or "",
						ImageColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
						BackgroundTransparency = 1
					})
				})

				AddThemeObject(ButtonFrame, "Second")
				AddThemeObject(ButtonFrame:FindFirstChildOfClass("UIStroke"), "Stroke")
				AddThemeObject(ButtonFrame:FindFirstChildOfClass("TextLabel"), "Text")
				AddThemeObject(ButtonFrame:FindFirstChildOfClass("ImageLabel"), "Accent")

				ButtonFrame.MouseEnter:Connect(function()
					TweenService:Create(ButtonFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {
						Transparency = 0
					}):Play()
				end)

				ButtonFrame.MouseLeave:Connect(function()
					TweenService:Create(ButtonFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {
						Transparency = 0.5
					}):Play()
				end)

				ButtonFrame.MouseButton1Click:Connect(function()
					-- Click animation
					TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
						Size = UDim2.new(1, -4, 0, 38)
					}):Play()
					
					wait(0.1)
					
					TweenService:Create(ButtonFrame, TweenInfo.new(0.1), {
						Size = UDim2.new(1, 0, 0, 40)
					}):Play()
					
					spawn(function()
						pcall(ButtonConfig.Callback)
					end)
				end)

				return {
					Set = function(self, NewText)
						ButtonFrame:FindFirstChildOfClass("TextLabel").Text = NewText
					end
				}
			end

			function SectionElements:AddToggle(ToggleConfig)
				ToggleConfig = ToggleConfig or {}
				ToggleConfig.Name = ToggleConfig.Name or "Toggle"
				ToggleConfig.Default = ToggleConfig.Default or false
				ToggleConfig.Callback = ToggleConfig.Callback or function() end
				ToggleConfig.Flag = ToggleConfig.Flag
				ToggleConfig.Save = ToggleConfig.Save or false

				local Toggle = {
					Value = ToggleConfig.Default,
					Type = "Toggle",
					Save = ToggleConfig.Save
				}

				local ToggleFrame = Create("TextButton", {
					Size = UDim2.new(1, 0, 0, 40),
					BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
					BorderSizePixel = 0,
					Text = "",
					Parent = SectionContent,
					AutoButtonColor = false
				}, {
					MakeElement("Corner", 0, 8),
					Create("UIStroke", {
						Color = ModernLib.Themes[ModernLib.SelectedTheme].Stroke,
						Thickness = 1,
						-- BUG FIX #10: Set initial transparency
						Transparency = 0.5
					}),
					Create("TextLabel", {
						Size = UDim2.new(1, -60, 1, 0),
						Position = UDim2.new(0, 15, 0, 0),
						Text = ToggleConfig.Name,
						TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
						TextSize = 14,
						Font = Enum.Font.GothamMedium,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					}),
					Create("Frame", {
						Size = UDim2.new(0, 44, 0, 24),
						Position = UDim2.new(1, -54, 0.5, 0),
						AnchorPoint = Vector2.new(0, 0.5),
						BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Divider,
						BorderSizePixel = 0
					}, {
						MakeElement("Corner", 0, 12),
						Create("Frame", {
							Size = UDim2.new(0, 20, 0, 20),
							Position = UDim2.new(0, 2, 0, 2),
							BackgroundColor3 = Color3.fromRGB(255, 255, 255),
							BorderSizePixel = 0
						}, {
							MakeElement("Corner", 0, 10)
						})
					})
				})

				AddThemeObject(ToggleFrame, "Second")
				AddThemeObject(ToggleFrame:FindFirstChildOfClass("UIStroke"), "Stroke")
				AddThemeObject(ToggleFrame:FindFirstChildOfClass("TextLabel"), "Text")
				
				local Switch = ToggleFrame:FindFirstChildOfClass("Frame")
				local Knob = Switch:FindFirstChildOfClass("Frame")

				function Toggle:Set(Value)
					Toggle.Value = Value
					
					if Value then
						TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent
						}):Play()
						TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							Position = UDim2.new(1, -22, 0, 2)
						}):Play()
					else
						TweenService:Create(Switch, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Divider
						}):Play()
						TweenService:Create(Knob, TweenInfo.new(0.2, Enum.EasingStyle.Quad), {
							Position = UDim2.new(0, 2, 0, 2)
						}):Play()
					end
					
					pcall(ToggleConfig.Callback, Value)
					
					if ToggleConfig.Save then
						SaveCfg(game.GameId)
					end
				end

				Toggle:Set(Toggle.Value)

				ToggleFrame.MouseButton1Click:Connect(function()
					Toggle:Set(not Toggle.Value)
				end)

				ToggleFrame.MouseEnter:Connect(function()
					TweenService:Create(ToggleFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {
						Transparency = 0
					}):Play()
				end)

				ToggleFrame.MouseLeave:Connect(function()
					TweenService:Create(ToggleFrame:FindFirstChildOfClass("UIStroke"), TweenInfo.new(0.2), {
						Transparency = 0.5
					}):Play()
				end)

				if ToggleConfig.Flag then
					ModernLib.Flags[ToggleConfig.Flag] = Toggle
				end

				return Toggle
			end

			function SectionElements:AddSlider(SliderConfig)
				SliderConfig = SliderConfig or {}
				SliderConfig.Name = SliderConfig.Name or "Slider"
				SliderConfig.Min = SliderConfig.Min or 0
				SliderConfig.Max = SliderConfig.Max or 100
				SliderConfig.Default = SliderConfig.Default or 50
				SliderConfig.Increment = SliderConfig.Increment or 1
				SliderConfig.Callback = SliderConfig.Callback or function() end
				SliderConfig.Flag = SliderConfig.Flag
				SliderConfig.Save = SliderConfig.Save or false

				local Slider = {
					Value = SliderConfig.Default,
					Type = "Slider",
					Save = SliderConfig.Save
				}

				local Dragging = false

				local SliderFrame = Create("Frame", {
					Size = UDim2.new(1, 0, 0, 60),
					BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Second,
					BorderSizePixel = 0,
					Parent = SectionContent
				}, {
					MakeElement("Corner", 0, 8),
					Create("UIStroke", {
						Color = ModernLib.Themes[ModernLib.SelectedTheme].Stroke,
						Thickness = 1,
						-- BUG FIX #11: Set initial transparency
						Transparency = 0.5
					}),
					Create("TextLabel", {
						Size = UDim2.new(1, -20, 0, 20),
						Position = UDim2.new(0, 15, 0, 10),
						Text = SliderConfig.Name,
						TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Text,
						TextSize = 14,
						Font = Enum.Font.GothamMedium,
						TextXAlignment = Enum.TextXAlignment.Left,
						BackgroundTransparency = 1
					}),
					Create("TextLabel", {
						Size = UDim2.new(0, 50, 0, 20),
						Position = UDim2.new(1, -65, 0, 10),
						Text = tostring(SliderConfig.Default),
						TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
						TextSize = 14,
						Font = Enum.Font.GothamBold,
						TextXAlignment = Enum.TextXAlignment.Right,
						BackgroundTransparency = 1
					}),
					Create("Frame", {
						Size = UDim2.new(1, -30, 0, 6),
						Position = UDim2.new(0, 15, 1, -20),
						BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Divider,
						BorderSizePixel = 0
					}, {
						MakeElement("Corner", 0, 3),
						Create("Frame", {
							Size = UDim2.new(0, 0, 1, 0),
							BackgroundColor3 = ModernLib.Themes[ModernLib.SelectedTheme].Accent,
							BorderSizePixel = 0
						}, {
							MakeElement("Corner", 0, 3)
						})
					})
				})

				AddThemeObject(SliderFrame, "Second")
				AddThemeObject(SliderFrame:FindFirstChildOfClass("UIStroke"), "Stroke")
				
				-- BUG FIX #12: Get labels properly
				local NameLabel = nil
				local ValueLabel = nil
				for _, child in ipairs(SliderFrame:GetChildren()) do
					if child:IsA("TextLabel") then
						if child.Position.X.Offset == 15 then
							NameLabel = child
							AddThemeObject(NameLabel, "Text")
						else
							ValueLabel = child
							AddThemeObject(ValueLabel, "Accent")
						end
					end
				end
				
				local Track = nil
				local Fill = nil
				for _, child in ipairs(SliderFrame:GetChildren()) do
					if child:IsA("Frame") and child:FindFirstChildOfClass("UICorner") then
						Track = child
						Fill = Track:FindFirstChildOfClass("Frame")
						break
					end
				end

				if not Track or not Fill or not ValueLabel then
					warn("Could not find slider components")
					return {}
				end

				AddThemeObject(Track, "Divider")
				AddThemeObject(Fill, "Accent")

				function Slider:Set(Value)
					self.Value = math.clamp(Round(Value, SliderConfig.Increment), SliderConfig.Min, SliderConfig.Max)
					
					local Percentage = (self.Value - SliderConfig.Min) / (SliderConfig.Max - SliderConfig.Min)
					
					TweenService:Create(Fill, TweenInfo.new(0.15, Enum.EasingStyle.Quad), {
						Size = UDim2.new(Percentage, 0, 1, 0)
					}):Play()
					
					ValueLabel.Text = tostring(self.Value)
					
					pcall(SliderConfig.Callback, self.Value)
					
					if SliderConfig.Save then
						SaveCfg(game.GameId)
					end
				end

				Track.InputBegan:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = true
					end
				end)

				Track.InputEnded:Connect(function(Input)
					if Input.UserInputType == Enum.UserInputType.MouseButton1 then
						Dragging = false
					end
				end)

				UserInputService.InputChanged:Connect(function(Input)
					if Dragging and Input.UserInputType == Enum.UserInputType.MouseMovement then
						local Percentage = math.clamp((Input.Position.X - Track.AbsolutePosition.X) / Track.AbsoluteSize.X, 0, 1)
						local Value = SliderConfig.Min + ((SliderConfig.Max - SliderConfig.Min) * Percentage)
						Slider:Set(Value)
					end
				end)

				Slider:Set(Slider.Value)

				if SliderConfig.Flag then
					ModernLib.Flags[SliderConfig.Flag] = Slider
				end

				return Slider
			end

			function SectionElements:AddLabel(Text)
				local Label = Create("TextLabel", {
					Size = UDim2.new(1, 0, 0, 30),
					Text = Text or "Label",
					TextColor3 = ModernLib.Themes[ModernLib.SelectedTheme].TextDark,
					TextSize = 13,
					Font = Enum.Font.Gotham,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextWrapped = true,
					BackgroundTransparency = 1,
					Parent = SectionContent,
					AutomaticSize = Enum.AutomaticSize.Y
				})

				AddThemeObject(Label, "TextDark")

				return {
					Set = function(self, NewText)
						Label.Text = NewText
					end
				}
			end

			return SectionElements
		end

		return TabElements
	end

	function WindowFunctions:SetTheme(ThemeName)
		SetTheme(ThemeName)
	end

	return WindowFunctions
end

function ModernLib:Destroy()
	Orion:Destroy()
end

return ModernLib
