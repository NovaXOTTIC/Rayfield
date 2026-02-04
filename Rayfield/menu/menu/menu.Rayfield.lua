--[[
    Vyzen Custom UI Library
    Dark Gray / Black / Red Theme
]]

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")

local LocalPlayer = Players.LocalPlayer

-- Theme Colors
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    TopBar = Color3.fromRGB(20, 20, 20),
    TabBackground = Color3.fromRGB(25, 25, 25),
    TabSelected = Color3.fromRGB(35, 35, 35),
    ElementBackground = Color3.fromRGB(30, 30, 30),
    ElementHover = Color3.fromRGB(40, 40, 40),
    
    RedAccent = Color3.fromRGB(220, 50, 50),
    RedAccentDark = Color3.fromRGB(180, 30, 30),
    RedGlow = Color3.fromRGB(255, 80, 80),
    
    TextPrimary = Color3.fromRGB(240, 240, 240),
    TextSecondary = Color3.fromRGB(180, 180, 180),
    TextDark = Color3.fromRGB(120, 120, 120),
    
    Stroke = Color3.fromRGB(50, 50, 50),
    StrokeRed = Color3.fromRGB(180, 40, 40),
}

local VyzenUI = {}
VyzenUI.Flags = {}

-- Create ScreenGui
local function CreateUI()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "VyzenUI"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.ResetOnSpawn = false
    
    if gethui then
        ScreenGui.Parent = gethui()
    elseif syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
        ScreenGui.Parent = CoreGui
    else
        ScreenGui.Parent = CoreGui
    end
    
    return ScreenGui
end

-- Create Main Window
function VyzenUI:CreateWindow(config)
    local ScreenGui = CreateUI()
    
    -- Main Frame
    local Main = Instance.new("Frame")
    Main.Name = "Main"
    Main.Size = UDim2.new(0, 550, 0, 400)
    Main.Position = UDim2.new(0.5, 0, 0.5, 0)
    Main.AnchorPoint = Vector2.new(0.5, 0.5)
    Main.BackgroundColor3 = Theme.Background
    Main.BorderSizePixel = 0
    Main.Parent = ScreenGui
    
    local MainCorner = Instance.new("UICorner")
    MainCorner.CornerRadius = UDim.new(0, 8)
    MainCorner.Parent = Main
    
    local MainStroke = Instance.new("UIStroke")
    MainStroke.Color = Theme.StrokeRed
    MainStroke.Thickness = 1
    MainStroke.Transparency = 0.5
    MainStroke.Parent = Main
    
    -- Glow Effect
    local Glow = Instance.new("ImageLabel")
    Glow.Name = "Glow"
    Glow.Size = UDim2.new(1, 30, 1, 30)
    Glow.Position = UDim2.new(0.5, 0, 0.5, 0)
    Glow.AnchorPoint = Vector2.new(0.5, 0.5)
    Glow.BackgroundTransparency = 1
    Glow.Image = "rbxassetid://5028857084"
    Glow.ImageColor3 = Theme.RedGlow
    Glow.ImageTransparency = 0.8
    Glow.ZIndex = 0
    Glow.Parent = Main
    
    -- Top Bar
    local TopBar = Instance.new("Frame")
    TopBar.Name = "TopBar"
    TopBar.Size = UDim2.new(1, 0, 0, 40)
    TopBar.BackgroundColor3 = Theme.TopBar
    TopBar.BorderSizePixel = 0
    TopBar.Parent = Main
    
    local TopBarCorner = Instance.new("UICorner")
    TopBarCorner.CornerRadius = UDim.new(0, 8)
    TopBarCorner.Parent = TopBar
    
    local TopBarFix = Instance.new("Frame")
    TopBarFix.Size = UDim2.new(1, 0, 0, 8)
    TopBarFix.Position = UDim2.new(0, 0, 1, -8)
    TopBarFix.BackgroundColor3 = Theme.TopBar
    TopBarFix.BorderSizePixel = 0
    TopBarFix.Parent = TopBar
    
    -- Title
    local Title = Instance.new("TextLabel")
    Title.Name = "Title"
    Title.Size = UDim2.new(1, -100, 1, 0)
    Title.Position = UDim2.new(0, 15, 0, 0)
    Title.BackgroundTransparency = 1
    Title.Text = config.Name or "Vyzen Hub"
    Title.TextColor3 = Theme.TextPrimary
    Title.TextSize = 16
    Title.Font = Enum.Font.GothamBold
    Title.TextXAlignment = Enum.TextXAlignment.Left
    Title.Parent = TopBar
    
    -- Red Line Under TopBar
    local RedLine = Instance.new("Frame")
    RedLine.Name = "RedLine"
    RedLine.Size = UDim2.new(1, 0, 0, 2)
    RedLine.Position = UDim2.new(0, 0, 0, 40)
    RedLine.BackgroundColor3 = Theme.RedAccent
    RedLine.BorderSizePixel = 0
    RedLine.Parent = Main
    
    -- Close Button
    local CloseBtn = Instance.new("TextButton")
    CloseBtn.Name = "Close"
    CloseBtn.Size = UDim2.new(0, 30, 0, 30)
    CloseBtn.Position = UDim2.new(1, -35, 0, 5)
    CloseBtn.BackgroundColor3 = Theme.ElementBackground
    CloseBtn.BorderSizePixel = 0
    CloseBtn.Text = "×"
    CloseBtn.TextColor3 = Theme.RedAccent
    CloseBtn.TextSize = 20
    CloseBtn.Font = Enum.Font.GothamBold
    CloseBtn.Parent = TopBar
    
    local CloseBtnCorner = Instance.new("UICorner")
    CloseBtnCorner.CornerRadius = UDim.new(0, 6)
    CloseBtnCorner.Parent = CloseBtn
    
    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)
    
    CloseBtn.MouseEnter:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.RedAccentDark}):Play()
    end)
    
    CloseBtn.MouseLeave:Connect(function()
        TweenService:Create(CloseBtn, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
    end)
    
    -- Tab Container
    local TabContainer = Instance.new("Frame")
    TabContainer.Name = "TabContainer"
    TabContainer.Size = UDim2.new(0, 140, 1, -52)
    TabContainer.Position = UDim2.new(0, 10, 0, 52)
    TabContainer.BackgroundTransparency = 1
    TabContainer.Parent = Main
    
    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 5)
    TabLayout.Parent = TabContainer
    
    -- Content Container
    local ContentContainer = Instance.new("Frame")
    ContentContainer.Name = "ContentContainer"
    ContentContainer.Size = UDim2.new(1, -170, 1, -62)
    ContentContainer.Position = UDim2.new(0, 160, 0, 52)
    ContentContainer.BackgroundTransparency = 1
    ContentContainer.Parent = Main
    
    -- Make draggable
    local dragging, dragInput, dragStart, startPos
    
    TopBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = Main.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    TopBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            Main.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    local Window = {}
    Window.CurrentTab = nil
    Window.Tabs = {}
    
    function Window:CreateTab(name, icon)
        local TabButton = Instance.new("TextButton")
        TabButton.Name = name
        TabButton.Size = UDim2.new(1, 0, 0, 35)
        TabButton.BackgroundColor3 = Theme.TabBackground
        TabButton.BorderSizePixel = 0
        TabButton.Text = ""
        TabButton.Parent = TabContainer
        
        local TabCorner = Instance.new("UICorner")
        TabCorner.CornerRadius = UDim.new(0, 6)
        TabCorner.Parent = TabButton
        
        local TabStroke = Instance.new("UIStroke")
        TabStroke.Color = Theme.Stroke
        TabStroke.Thickness = 1
        TabStroke.Transparency = 0.7
        TabStroke.Parent = TabButton
        
        local TabTitle = Instance.new("TextLabel")
        TabTitle.Name = "Title"
        TabTitle.Size = UDim2.new(1, -40, 1, 0)
        TabTitle.Position = UDim2.new(0, 35, 0, 0)
        TabTitle.BackgroundTransparency = 1
        TabTitle.Text = name
        TabTitle.TextColor3 = Theme.TextSecondary
        TabTitle.TextSize = 13
        TabTitle.Font = Enum.Font.Gotham
        TabTitle.TextXAlignment = Enum.TextXAlignment.Left
        TabTitle.Parent = TabButton
        
        local TabIcon = Instance.new("ImageLabel")
        TabIcon.Name = "Icon"
        TabIcon.Size = UDim2.new(0, 18, 0, 18)
        TabIcon.Position = UDim2.new(0, 10, 0.5, 0)
        TabIcon.AnchorPoint = Vector2.new(0, 0.5)
        TabIcon.BackgroundTransparency = 1
        TabIcon.Image = "rbxassetid://" .. (icon or 4483362458)
        TabIcon.ImageColor3 = Theme.TextSecondary
        TabIcon.Parent = TabButton
        
        -- Tab Content
        local TabContent = Instance.new("ScrollingFrame")
        TabContent.Name = name .. "Content"
        TabContent.Size = UDim2.new(1, 0, 1, 0)
        TabContent.BackgroundTransparency = 1
        TabContent.BorderSizePixel = 0
        TabContent.ScrollBarThickness = 4
        TabContent.ScrollBarImageColor3 = Theme.RedAccent
        TabContent.Visible = false
        TabContent.Parent = ContentContainer
        
        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 8)
        ContentLayout.Parent = TabContent
        
        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingTop = UDim.new(0, 5)
        ContentPadding.PaddingRight = UDim.new(0, 5)
        ContentPadding.Parent = TabContent
        
        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 10)
        end)
        
        TabButton.MouseButton1Click:Connect(function()
            for _, tab in pairs(Window.Tabs) do
                tab.Button.BackgroundColor3 = Theme.TabBackground
                tab.Title.TextColor3 = Theme.TextSecondary
                tab.Icon.ImageColor3 = Theme.TextSecondary
                tab.Stroke.Color = Theme.Stroke
                tab.Content.Visible = false
            end
            
            TabButton.BackgroundColor3 = Theme.TabSelected
            TabTitle.TextColor3 = Theme.TextPrimary
            TabIcon.ImageColor3 = Theme.RedAccent
            TabStroke.Color = Theme.StrokeRed
            TabContent.Visible = true
            Window.CurrentTab = TabContent
        end)
        
        TabButton.MouseEnter:Connect(function()
            if TabContent ~= Window.CurrentTab then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
            end
        end)
        
        TabButton.MouseLeave:Connect(function()
            if TabContent ~= Window.CurrentTab then
                TweenService:Create(TabButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackground}):Play()
            end
        end)
        
        if not Window.CurrentTab then
            TabButton.BackgroundColor3 = Theme.TabSelected
            TabTitle.TextColor3 = Theme.TextPrimary
            TabIcon.ImageColor3 = Theme.RedAccent
            TabStroke.Color = Theme.StrokeRed
            TabContent.Visible = true
            Window.CurrentTab = TabContent
        end
        
        local Tab = {}
        Tab.Button = TabButton
        Tab.Title = TabTitle
        Tab.Icon = TabIcon
        Tab.Stroke = TabStroke
        Tab.Content = TabContent
        
        table.insert(Window.Tabs, Tab)
        
        -- Tab Functions
        function Tab:CreateSection(text)
            local Section = Instance.new("TextLabel")
            Section.Name = "Section"
            Section.Size = UDim2.new(1, 0, 0, 25)
            Section.BackgroundTransparency = 1
            Section.Text = text
            Section.TextColor3 = Theme.RedAccent
            Section.TextSize = 14
            Section.Font = Enum.Font.GothamBold
            Section.TextXAlignment = Enum.TextXAlignment.Left
            Section.Parent = TabContent
            
            return Section
        end
        
        function Tab:CreateButton(config)
            local Button = Instance.new("TextButton")
            Button.Name = config.Name
            Button.Size = UDim2.new(1, -5, 0, 35)
            Button.BackgroundColor3 = Theme.ElementBackground
            Button.BorderSizePixel = 0
            Button.Text = ""
            Button.Parent = TabContent
            
            local ButtonCorner = Instance.new("UICorner")
            ButtonCorner.CornerRadius = UDim.new(0, 6)
            ButtonCorner.Parent = Button
            
            local ButtonStroke = Instance.new("UIStroke")
            ButtonStroke.Color = Theme.Stroke
            ButtonStroke.Thickness = 1
            ButtonStroke.Transparency = 0.5
            ButtonStroke.Parent = Button
            
            local ButtonTitle = Instance.new("TextLabel")
            ButtonTitle.Size = UDim2.new(1, -10, 1, 0)
            ButtonTitle.Position = UDim2.new(0, 10, 0, 0)
            ButtonTitle.BackgroundTransparency = 1
            ButtonTitle.Text = config.Name
            ButtonTitle.TextColor3 = Theme.TextPrimary
            ButtonTitle.TextSize = 13
            ButtonTitle.Font = Enum.Font.Gotham
            ButtonTitle.TextXAlignment = Enum.TextXAlignment.Left
            ButtonTitle.Parent = Button
            
            Button.MouseButton1Click:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.RedAccentDark}):Play()
                wait(0.1)
                TweenService:Create(Button, TweenInfo.new(0.1), {BackgroundColor3 = Theme.ElementHover}):Play()
                
                pcall(config.Callback)
            end)
            
            Button.MouseEnter:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
                TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Theme.StrokeRed}):Play()
            end)
            
            Button.MouseLeave:Connect(function()
                TweenService:Create(Button, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
                TweenService:Create(ButtonStroke, TweenInfo.new(0.2), {Color = Theme.Stroke}):Play()
            end)
            
            return Button
        end
        
        function Tab:CreateToggle(config)
            local Toggle = Instance.new("Frame")
            Toggle.Name = config.Name
            Toggle.Size = UDim2.new(1, -5, 0, 35)
            Toggle.BackgroundColor3 = Theme.ElementBackground
            Toggle.BorderSizePixel = 0
            Toggle.Parent = TabContent
            
            local ToggleCorner = Instance.new("UICorner")
            ToggleCorner.CornerRadius = UDim.new(0, 6)
            ToggleCorner.Parent = Toggle
            
            local ToggleStroke = Instance.new("UIStroke")
            ToggleStroke.Color = Theme.Stroke
            ToggleStroke.Thickness = 1
            ToggleStroke.Transparency = 0.5
            ToggleStroke.Parent = Toggle
            
            local ToggleTitle = Instance.new("TextLabel")
            ToggleTitle.Size = UDim2.new(1, -60, 1, 0)
            ToggleTitle.Position = UDim2.new(0, 10, 0, 0)
            ToggleTitle.BackgroundTransparency = 1
            ToggleTitle.Text = config.Name
            ToggleTitle.TextColor3 = Theme.TextPrimary
            ToggleTitle.TextSize = 13
            ToggleTitle.Font = Enum.Font.Gotham
            ToggleTitle.TextXAlignment = Enum.TextXAlignment.Left
            ToggleTitle.Parent = Toggle
            
            local ToggleButton = Instance.new("TextButton")
            ToggleButton.Size = UDim2.new(0, 40, 0, 20)
            ToggleButton.Position = UDim2.new(1, -50, 0.5, 0)
            ToggleButton.AnchorPoint = Vector2.new(0, 0.5)
            ToggleButton.BackgroundColor3 = Theme.TabBackground
            ToggleButton.BorderSizePixel = 0
            ToggleButton.Text = ""
            ToggleButton.Parent = Toggle
            
            local ToggleBtnCorner = Instance.new("UICorner")
            ToggleBtnCorner.CornerRadius = UDim.new(1, 0)
            ToggleBtnCorner.Parent = ToggleButton
            
            local ToggleCircle = Instance.new("Frame")
            ToggleCircle.Size = UDim2.new(0, 16, 0, 16)
            ToggleCircle.Position = config.CurrentValue and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
            ToggleCircle.AnchorPoint = Vector2.new(0, 0.5)
            ToggleCircle.BackgroundColor3 = config.CurrentValue and Theme.RedAccent or Theme.TextDark
            ToggleCircle.BorderSizePixel = 0
            ToggleCircle.Parent = ToggleButton
            
            local CircleCorner = Instance.new("UICorner")
            CircleCorner.CornerRadius = UDim.new(1, 0)
            CircleCorner.Parent = ToggleCircle
            
            local toggled = config.CurrentValue or false
            
            ToggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                if toggled then
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(1, -18, 0.5, 0),
                        BackgroundColor3 = Theme.RedAccent
                    }):Play()
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.RedAccentDark}):Play()
                else
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = Theme.TextDark
                    }):Play()
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackground}):Play()
                end
                
                pcall(config.Callback, toggled)
            end)
            
            Toggle.MouseEnter:Connect(function()
                TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
                TweenService:Create(ToggleStroke, TweenInfo.new(0.2), {Color = Theme.StrokeRed}):Play()
            end)
            
            Toggle.MouseLeave:Connect(function()
                TweenService:Create(Toggle, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
                TweenService:Create(ToggleStroke, TweenInfo.new(0.2), {Color = Theme.Stroke}):Play()
            end)
            
            local ToggleObj = {}
            function ToggleObj:Set(value)
                toggled = value
                if toggled then
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(1, -18, 0.5, 0),
                        BackgroundColor3 = Theme.RedAccent
                    }):Play()
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.RedAccentDark}):Play()
                else
                    TweenService:Create(ToggleCircle, TweenInfo.new(0.2), {
                        Position = UDim2.new(0, 2, 0.5, 0),
                        BackgroundColor3 = Theme.TextDark
                    }):Play()
                    TweenService:Create(ToggleButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackground}):Play()
                end
                pcall(config.Callback, toggled)
            end
            
            if config.Flag then
                VyzenUI.Flags[config.Flag] = ToggleObj
            end
            
            return ToggleObj
        end
        
        function Tab:CreateSlider(config)
            local Slider = Instance.new("Frame")
            Slider.Name = config.Name
            Slider.Size = UDim2.new(1, -5, 0, 50)
            Slider.BackgroundColor3 = Theme.ElementBackground
            Slider.BorderSizePixel = 0
            Slider.Parent = TabContent
            
            local SliderCorner = Instance.new("UICorner")
            SliderCorner.CornerRadius = UDim.new(0, 6)
            SliderCorner.Parent = Slider
            
            local SliderStroke = Instance.new("UIStroke")
            SliderStroke.Color = Theme.Stroke
            SliderStroke.Thickness = 1
            SliderStroke.Transparency = 0.5
            SliderStroke.Parent = Slider
            
            local SliderTitle = Instance.new("TextLabel")
            SliderTitle.Size = UDim2.new(0.7, 0, 0, 20)
            SliderTitle.Position = UDim2.new(0, 10, 0, 5)
            SliderTitle.BackgroundTransparency = 1
            SliderTitle.Text = config.Name
            SliderTitle.TextColor3 = Theme.TextPrimary
            SliderTitle.TextSize = 13
            SliderTitle.Font = Enum.Font.Gotham
            SliderTitle.TextXAlignment = Enum.TextXAlignment.Left
            SliderTitle.Parent = Slider
            
            local SliderValue = Instance.new("TextLabel")
            SliderValue.Size = UDim2.new(0.3, -10, 0, 20)
            SliderValue.Position = UDim2.new(0.7, 0, 0, 5)
            SliderValue.BackgroundTransparency = 1
            SliderValue.Text = tostring(config.CurrentValue) .. (config.Suffix or "")
            SliderValue.TextColor3 = Theme.RedAccent
            SliderValue.TextSize = 13
            SliderValue.Font = Enum.Font.GothamBold
            SliderValue.TextXAlignment = Enum.TextXAlignment.Right
            SliderValue.Parent = Slider
            
            local SliderBar = Instance.new("Frame")
            SliderBar.Name = "SliderBar"
            SliderBar.Size = UDim2.new(1, -20, 0, 4)
            SliderBar.Position = UDim2.new(0, 10, 1, -15)
            SliderBar.BackgroundColor3 = Theme.TabBackground
            SliderBar.BorderSizePixel = 0
            SliderBar.Parent = Slider
            
            local SliderBarCorner = Instance.new("UICorner")
            SliderBarCorner.CornerRadius = UDim.new(1, 0)
            SliderBarCorner.Parent = SliderBar
            
            local SliderFill = Instance.new("Frame")
            SliderFill.Name = "Fill"
            SliderFill.Size = UDim2.new((config.CurrentValue - config.Range[1]) / (config.Range[2] - config.Range[1]), 0, 1, 0)
            SliderFill.BackgroundColor3 = Theme.RedAccent
            SliderFill.BorderSizePixel = 0
            SliderFill.Parent = SliderBar
            
            local SliderFillCorner = Instance.new("UICorner")
            SliderFillCorner.CornerRadius = UDim.new(1, 0)
            SliderFillCorner.Parent = SliderFill
            
            local dragging = false
            
            SliderBar.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                end
            end)
            
            SliderBar.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local mousePos = UserInputService:GetMouseLocation().X
                    local barPos = SliderBar.AbsolutePosition.X
                    local barSize = SliderBar.AbsoluteSize.X
                    
                    local percent = math.clamp((mousePos - barPos) / barSize, 0, 1)
                    local value = math.floor(config.Range[1] + (config.Range[2] - config.Range[1]) * percent)
                    
                    value = math.floor(value / config.Increment + 0.5) * config.Increment
                    
                    SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                    SliderValue.Text = tostring(value) .. (config.Suffix or "")
                    
                    pcall(config.Callback, value)
                end
            end)
            
            Slider.MouseEnter:Connect(function()
                TweenService:Create(Slider, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
                TweenService:Create(SliderStroke, TweenInfo.new(0.2), {Color = Theme.StrokeRed}):Play()
            end)
            
            Slider.MouseLeave:Connect(function()
                TweenService:Create(Slider, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
                TweenService:Create(SliderStroke, TweenInfo.new(0.2), {Color = Theme.Stroke}):Play()
            end)
            
            local SliderObj = {}
            function SliderObj:Set(value)
                value = math.clamp(value, config.Range[1], config.Range[2])
                local percent = (value - config.Range[1]) / (config.Range[2] - config.Range[1])
                SliderFill.Size = UDim2.new(percent, 0, 1, 0)
                SliderValue.Text = tostring(value) .. (config.Suffix or "")
                pcall(config.Callback, value)
            end
            
            if config.Flag then
                VyzenUI.Flags[config.Flag] = SliderObj
            end
            
            return SliderObj
        end
        
        function Tab:CreateLabel(text)
            local Label = Instance.new("TextLabel")
            Label.Name = "Label"
            Label.Size = UDim2.new(1, -5, 0, 30)
            Label.BackgroundColor3 = Theme.ElementBackground
            Label.BorderSizePixel = 0
            Label.Text = text
            Label.TextColor3 = Theme.TextPrimary
            Label.TextSize = 13
            Label.Font = Enum.Font.Gotham
            Label.TextXAlignment = Enum.TextXAlignment.Left
            Label.Parent = TabContent
            
            local LabelCorner = Instance.new("UICorner")
            LabelCorner.CornerRadius = UDim.new(0, 6)
            LabelCorner.Parent = Label
            
            local LabelPadding = Instance.new("UIPadding")
            LabelPadding.PaddingLeft = UDim.new(0, 10)
            LabelPadding.Parent = Label
            
            local LabelStroke = Instance.new("UIStroke")
            LabelStroke.Color = Theme.Stroke
            LabelStroke.Thickness = 1
            LabelStroke.Transparency = 0.5
            LabelStroke.Parent = Label
            
            local LabelObj = {}
            function LabelObj:Set(text)
                Label.Text = text
            end
            
            return LabelObj
        end
        
        function Tab:CreateDropdown(config)
            local Dropdown = Instance.new("Frame")
            Dropdown.Name = config.Name
            Dropdown.Size = UDim2.new(1, -5, 0, 35)
            Dropdown.BackgroundColor3 = Theme.ElementBackground
            Dropdown.BorderSizePixel = 0
            Dropdown.ClipsDescendants = true
            Dropdown.Parent = TabContent
            
            local DropdownCorner = Instance.new("UICorner")
            DropdownCorner.CornerRadius = UDim.new(0, 6)
            DropdownCorner.Parent = Dropdown
            
            local DropdownStroke = Instance.new("UIStroke")
            DropdownStroke.Color = Theme.Stroke
            DropdownStroke.Thickness = 1
            DropdownStroke.Transparency = 0.5
            DropdownStroke.Parent = Dropdown
            
            local DropdownButton = Instance.new("TextButton")
            DropdownButton.Size = UDim2.new(1, 0, 0, 35)
            DropdownButton.BackgroundTransparency = 1
            DropdownButton.Text = ""
            DropdownButton.Parent = Dropdown
            
            local DropdownTitle = Instance.new("TextLabel")
            DropdownTitle.Size = UDim2.new(1, -30, 1, 0)
            DropdownTitle.Position = UDim2.new(0, 10, 0, 0)
            DropdownTitle.BackgroundTransparency = 1
            DropdownTitle.Text = config.CurrentOption or "None"
            DropdownTitle.TextColor3 = Theme.TextPrimary
            DropdownTitle.TextSize = 13
            DropdownTitle.Font = Enum.Font.Gotham
            DropdownTitle.TextXAlignment = Enum.TextXAlignment.Left
            DropdownTitle.Parent = DropdownButton
            
            local DropdownArrow = Instance.new("TextLabel")
            DropdownArrow.Size = UDim2.new(0, 20, 1, 0)
            DropdownArrow.Position = UDim2.new(1, -25, 0, 0)
            DropdownArrow.BackgroundTransparency = 1
            DropdownArrow.Text = "▼"
            DropdownArrow.TextColor3 = Theme.RedAccent
            DropdownArrow.TextSize = 10
            DropdownArrow.Font = Enum.Font.Gotham
            DropdownArrow.Parent = DropdownButton
            
            local DropdownList = Instance.new("ScrollingFrame")
            DropdownList.Size = UDim2.new(1, 0, 0, 0)
            DropdownList.Position = UDim2.new(0, 0, 0, 35)
            DropdownList.BackgroundTransparency = 1
            DropdownList.BorderSizePixel = 0
            DropdownList.ScrollBarThickness = 2
            DropdownList.ScrollBarImageColor3 = Theme.RedAccent
            DropdownList.CanvasSize = UDim2.new(0, 0, 0, 0)
            DropdownList.Parent = Dropdown
            
            local ListLayout = Instance.new("UIListLayout")
            ListLayout.SortOrder = Enum.SortOrder.LayoutOrder
            ListLayout.Padding = UDim.new(0, 2)
            ListLayout.Parent = DropdownList
            
            local expanded = false
            
            for _, option in ipairs(config.Options) do
                local OptionButton = Instance.new("TextButton")
                OptionButton.Size = UDim2.new(1, -4, 0, 25)
                OptionButton.BackgroundColor3 = Theme.TabBackground
                OptionButton.BorderSizePixel = 0
                OptionButton.Text = option
                OptionButton.TextColor3 = Theme.TextSecondary
                OptionButton.TextSize = 12
                OptionButton.Font = Enum.Font.Gotham
                OptionButton.Parent = DropdownList
                
                local OptionCorner = Instance.new("UICorner")
                OptionCorner.CornerRadius = UDim.new(0, 4)
                OptionCorner.Parent = OptionButton
                
                OptionButton.MouseButton1Click:Connect(function()
                    DropdownTitle.Text = option
                    pcall(config.Callback, option)
                    
                    expanded = false
                    TweenService:Create(Dropdown, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 35)}):Play()
                    TweenService:Create(DropdownList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    TweenService:Create(DropdownArrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                end)
                
                OptionButton.MouseEnter:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.RedAccentDark}):Play()
                    TweenService:Create(OptionButton, TweenInfo.new(0.2), {TextColor3 = Theme.TextPrimary}):Play()
                end)
                
                OptionButton.MouseLeave:Connect(function()
                    TweenService:Create(OptionButton, TweenInfo.new(0.2), {BackgroundColor3 = Theme.TabBackground}):Play()
                    TweenService:Create(OptionButton, TweenInfo.new(0.2), {TextColor3 = Theme.TextSecondary}):Play()
                end)
            end
            
            ListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                DropdownList.CanvasSize = UDim2.new(0, 0, 0, ListLayout.AbsoluteContentSize.Y)
            end)
            
            DropdownButton.MouseButton1Click:Connect(function()
                expanded = not expanded
                if expanded then
                    local contentHeight = math.min(ListLayout.AbsoluteContentSize.Y, 100)
                    TweenService:Create(Dropdown, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 35 + contentHeight + 5)}):Play()
                    TweenService:Create(DropdownList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, contentHeight)}):Play()
                    TweenService:Create(DropdownArrow, TweenInfo.new(0.3), {Rotation = 180}):Play()
                else
                    TweenService:Create(Dropdown, TweenInfo.new(0.3), {Size = UDim2.new(1, -5, 0, 35)}):Play()
                    TweenService:Create(DropdownList, TweenInfo.new(0.3), {Size = UDim2.new(1, 0, 0, 0)}):Play()
                    TweenService:Create(DropdownArrow, TweenInfo.new(0.3), {Rotation = 0}):Play()
                end
            end)
            
            Dropdown.MouseEnter:Connect(function()
                TweenService:Create(Dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementHover}):Play()
                TweenService:Create(DropdownStroke, TweenInfo.new(0.2), {Color = Theme.StrokeRed}):Play()
            end)
            
            Dropdown.MouseLeave:Connect(function()
                TweenService:Create(Dropdown, TweenInfo.new(0.2), {BackgroundColor3 = Theme.ElementBackground}):Play()
                TweenService:Create(DropdownStroke, TweenInfo.new(0.2), {Color = Theme.Stroke}):Play()
            end)
            
            local DropdownObj = {}
            function DropdownObj:Set(option)
                DropdownTitle.Text = option
                pcall(config.Callback, option)
            end
            
            if config.Flag then
                VyzenUI.Flags[config.Flag] = DropdownObj
            end
            
            return DropdownObj
        end
        
        return Tab
    end
    
    function Window:Notify(config)
        local Notification = Instance.new("Frame")
        Notification.Name = "Notification"
        Notification.Size = UDim2.new(0, 0, 0, 60)
        Notification.Position = UDim2.new(1, 10, 1, -70)
        Notification.BackgroundColor3 = Theme.Background
        Notification.BorderSizePixel = 0
        Notification.Parent = ScreenGui
        
        local NotifCorner = Instance.new("UICorner")
        NotifCorner.CornerRadius = UDim.new(0, 8)
        NotifCorner.Parent = Notification
        
        local NotifStroke = Instance.new("UIStroke")
        NotifStroke.Color = Theme.StrokeRed
        NotifStroke.Thickness = 1
        NotifStroke.Parent = Notification
        
        local NotifTitle = Instance.new("TextLabel")
        NotifTitle.Size = UDim2.new(1, -15, 0, 20)
        NotifTitle.Position = UDim2.new(0, 10, 0, 5)
        NotifTitle.BackgroundTransparency = 1
        NotifTitle.Text = config.Title or "Notification"
        NotifTitle.TextColor3 = Theme.RedAccent
        NotifTitle.TextSize = 14
        NotifTitle.Font = Enum.Font.GothamBold
        NotifTitle.TextXAlignment = Enum.TextXAlignment.Left
        NotifTitle.TextTransparency = 1
        NotifTitle.Parent = Notification
        
        local NotifContent = Instance.new("TextLabel")
        NotifContent.Size = UDim2.new(1, -15, 0, 30)
        NotifContent.Position = UDim2.new(0, 10, 0, 25)
        NotifContent.BackgroundTransparency = 1
        NotifContent.Text = config.Content or ""
        NotifContent.TextColor3 = Theme.TextPrimary
        NotifContent.TextSize = 12
        NotifContent.Font = Enum.Font.Gotham
        NotifContent.TextXAlignment = Enum.TextXAlignment.Left
        NotifContent.TextYAlignment = Enum.TextYAlignment.Top
        NotifContent.TextWrapped = true
        NotifContent.TextTransparency = 1
        NotifContent.Parent = Notification
        
        TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 300, 0, 60),
            Position = UDim2.new(1, -310, 1, -70)
        }):Play()
        
        TweenService:Create(NotifTitle, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(NotifContent, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        
        task.wait(config.Duration or 3)
        
        TweenService:Create(Notification, TweenInfo.new(0.5, Enum.EasingStyle.Back), {
            Size = UDim2.new(0, 0, 0, 60),
            Position = UDim2.new(1, 10, 1, -70)
        }):Play()
        
        TweenService:Create(NotifTitle, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(NotifContent, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        
        task.wait(0.5)
        Notification:Destroy()
    end
    
    return Window
end

return VyzenUI
