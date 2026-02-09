-- Orion Library Compatible - Full Working Version
-- Matches Orion API for script compatibility

local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer

local OrionLib = {}
OrionLib.Flags = {}

-- Red & Black Theme (Vyzen Style)
local Theme = {
    Background = Color3.fromRGB(15, 15, 15),
    Secondary = Color3.fromRGB(20, 20, 20),
    Tertiary = Color3.fromRGB(25, 25, 25),
    Accent = Color3.fromRGB(220, 20, 20),
    AccentDark = Color3.fromRGB(180, 15, 15),
    Text = Color3.fromRGB(255, 255, 255),
    TextDark = Color3.fromRGB(200, 200, 200),
    Border = Color3.fromRGB(40, 40, 40),
    Hover = Color3.fromRGB(30, 30, 30)
}

-- Create ScreenGui
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "OrionLib_" .. tostring(math.random(1000, 9999))
ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
ScreenGui.ResetOnSpawn = false

pcall(function()
    if syn and syn.protect_gui then
        syn.protect_gui(ScreenGui)
    end
end)

if gethui then
    ScreenGui.Parent = gethui()
elseif syn then
    ScreenGui.Parent = game:GetService("CoreGui")
else
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
end

-- Utility Functions
local function Tween(obj, props, duration)
    TweenService:Create(obj, TweenInfo.new(duration or 0.2, Enum.EasingStyle.Quad), props):Play()
end

local function CreateElement(className, properties)
    local element = Instance.new(className)
    for prop, value in pairs(properties or {}) do
        element[prop] = value
    end
    return element
end

local function AddCorner(element, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 6)
    corner.Parent = element
    return corner
end

local function MakeDraggable(frame, dragFrame)
    dragFrame = dragFrame or frame
    local dragging, dragInput, mousePos, framePos

    dragFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    dragFrame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            frame.Position = UDim2.new(
                framePos.X.Scale,
                framePos.X.Offset + delta.X,
                framePos.Y.Scale,
                framePos.Y.Offset + delta.Y
            )
        end
    end)
end

-- Main Window Creation
function OrionLib:MakeWindow(config)
    config = config or {}
    config.Name = config.Name or "Orion Library"
    config.HidePremium = config.HidePremium == nil and true or config.HidePremium
    config.IntroEnabled = config.IntroEnabled == nil and false or config.IntroEnabled
    config.IntroText = config.IntroText or config.Name
    
    local Window = {}
    local Tabs = {}
    local CurrentTab = nil

    -- Main Frame
    local Main = CreateElement("Frame", {
        Parent = ScreenGui,
        Position = UDim2.new(0.5, -350, 0.5, -250),
        Size = UDim2.new(0, 700, 0, 500),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0,
        ClipsDescendants = true
    })
    AddCorner(Main, 8)

    -- Shadow
    local shadow = CreateElement("ImageLabel", {
        Parent = Main,
        Size = UDim2.new(1, 30, 1, 30),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://5554236805",
        ImageColor3 = Color3.new(0, 0, 0),
        ImageTransparency = 0.3,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(23, 23, 277, 277),
        ZIndex = 0
    })

    -- Top Bar
    local TopBar = CreateElement("Frame", {
        Parent = Main,
        Size = UDim2.new(1, 0, 0, 50),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    })
    AddCorner(TopBar, 8)

    local TopBarCover = CreateElement("Frame", {
        Parent = TopBar,
        Position = UDim2.new(0, 0, 1, -8),
        Size = UDim2.new(1, 0, 0, 8),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    })

    local Title = CreateElement("TextLabel", {
        Parent = TopBar,
        Position = UDim2.new(0, 15, 0, 0),
        Size = UDim2.new(1, -80, 1, 0),
        BackgroundTransparency = 1,
        Text = config.Name,
        TextColor3 = Theme.Text,
        TextSize = 18,
        Font = Enum.Font.GothamBold,
        TextXAlignment = Enum.TextXAlignment.Left
    })

    -- Close Button
    local CloseBtn = CreateElement("TextButton", {
        Parent = TopBar,
        Position = UDim2.new(1, -40, 0, 10),
        Size = UDim2.new(0, 30, 0, 30),
        BackgroundColor3 = Theme.Accent,
        Text = "×",
        TextColor3 = Theme.Text,
        TextSize = 24,
        Font = Enum.Font.GothamBold,
        AutoButtonColor = false
    })
    AddCorner(CloseBtn, 6)

    CloseBtn.MouseButton1Click:Connect(function()
        ScreenGui:Destroy()
    end)

    CloseBtn.MouseEnter:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.AccentDark})
    end)

    CloseBtn.MouseLeave:Connect(function()
        Tween(CloseBtn, {BackgroundColor3 = Theme.Accent})
    end)

    -- Sidebar
    local Sidebar = CreateElement("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 0, 0, 50),
        Size = UDim2.new(0, 180, 1, -50),
        BackgroundColor3 = Theme.Secondary,
        BorderSizePixel = 0
    })

    local TabContainer = CreateElement("ScrollingFrame", {
        Parent = Sidebar,
        Position = UDim2.new(0, 10, 0, 10),
        Size = UDim2.new(1, -20, 1, -20),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = Theme.Accent,
        CanvasSize = UDim2.new(0, 0, 0, 0)
    })

    local TabLayout = Instance.new("UIListLayout")
    TabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    TabLayout.Padding = UDim.new(0, 6)
    TabLayout.Parent = TabContainer

    TabLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
        TabContainer.CanvasSize = UDim2.new(0, 0, 0, TabLayout.AbsoluteContentSize.Y + 20)
    end)

    -- Content Area
    local ContentArea = CreateElement("Frame", {
        Parent = Main,
        Position = UDim2.new(0, 180, 0, 50),
        Size = UDim2.new(1, -180, 1, -50),
        BackgroundColor3 = Theme.Background,
        BorderSizePixel = 0
    })

    MakeDraggable(Main, TopBar)

    -- Create Tab Function
    function Window:MakeTab(tabConfig)
        tabConfig = tabConfig or {}
        tabConfig.Name = tabConfig.Name or "Tab"
        tabConfig.Icon = tabConfig.Icon or ""
        tabConfig.PremiumOnly = tabConfig.PremiumOnly or false
        
        local Tab = {}

        -- Tab Button
        local TabButton = CreateElement("TextButton", {
            Parent = TabContainer,
            Size = UDim2.new(1, 0, 0, 40),
            BackgroundColor3 = Theme.Tertiary,
            BackgroundTransparency = 1,
            Text = "",
            AutoButtonColor = false
        })
        AddCorner(TabButton, 6)

        local TabLabel = CreateElement("TextLabel", {
            Parent = TabButton,
            Position = UDim2.new(0, 10, 0, 0),
            Size = UDim2.new(1, -20, 1, 0),
            BackgroundTransparency = 1,
            Text = tabConfig.Name,
            TextColor3 = Theme.TextDark,
            TextSize = 14,
            Font = Enum.Font.GothamMedium,
            TextXAlignment = Enum.TextXAlignment.Left
        })

        -- Tab Content
        local TabContent = CreateElement("ScrollingFrame", {
            Parent = ContentArea,
            Size = UDim2.new(1, 0, 1, 0),
            BackgroundTransparency = 1,
            BorderSizePixel = 0,
            ScrollBarThickness = 4,
            ScrollBarImageColor3 = Theme.Accent,
            CanvasSize = UDim2.new(0, 0, 0, 0),
            Visible = false
        })

        local ContentLayout = Instance.new("UIListLayout")
        ContentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        ContentLayout.Padding = UDim.new(0, 10)
        ContentLayout.Parent = TabContent

        local ContentPadding = Instance.new("UIPadding")
        ContentPadding.PaddingLeft = UDim.new(0, 15)
        ContentPadding.PaddingRight = UDim.new(0, 15)
        ContentPadding.PaddingTop = UDim.new(0, 15)
        ContentPadding.PaddingBottom = UDim.new(0, 15)
        ContentPadding.Parent = TabContent

        ContentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            TabContent.CanvasSize = UDim2.new(0, 0, 0, ContentLayout.AbsoluteContentSize.Y + 30)
        end)

        -- Tab Selection
        local function SelectTab()
            for _, tab in pairs(Tabs) do
                tab.Button.BackgroundTransparency = 1
                tab.Label.TextColor3 = Theme.TextDark
                tab.Content.Visible = false
            end

            TabButton.BackgroundTransparency = 0
            TabLabel.TextColor3 = Theme.Text
            TabContent.Visible = true
            CurrentTab = Tab
        end

        TabButton.MouseButton1Click:Connect(SelectTab)

        TabButton.MouseEnter:Connect(function()
            if TabContent.Visible == false then
                Tween(TabButton, {BackgroundTransparency = 0.5})
            end
        end)

        TabButton.MouseLeave:Connect(function()
            if TabContent.Visible == false then
                Tween(TabButton, {BackgroundTransparency = 1})
            end
        end)

        table.insert(Tabs, {
            Button = TabButton,
            Label = TabLabel,
            Content = TabContent,
            Tab = Tab
        })

        if #Tabs == 1 then
            SelectTab()
        end

        -- Section
        function Tab:AddSection(sectionConfig)
            sectionConfig = sectionConfig or {}
            sectionConfig.Name = sectionConfig.Name or "Section"

            local SectionFrame = CreateElement("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 30),
                BackgroundTransparency = 1
            })

            local SectionLabel = CreateElement("TextLabel", {
                Parent = SectionFrame,
                Size = UDim2.new(1, 0, 1, 0),
                BackgroundTransparency = 1,
                Text = sectionConfig.Name,
                TextColor3 = Theme.Accent,
                TextSize = 16,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Divider = CreateElement("Frame", {
                Parent = SectionFrame,
                Position = UDim2.new(0, 0, 1, -2),
                Size = UDim2.new(1, 0, 0, 2),
                BackgroundColor3 = Theme.Accent,
                BorderSizePixel = 0
            })
        end

        -- Paragraph
        function Tab:AddParagraph(title, content)
            local ParagraphFrame = CreateElement("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                AutomaticSize = Enum.AutomaticSize.Y
            })
            AddCorner(ParagraphFrame, 6)

            local ParagraphPadding = Instance.new("UIPadding")
            ParagraphPadding.PaddingLeft = UDim.new(0, 12)
            ParagraphPadding.PaddingRight = UDim.new(0, 12)
            ParagraphPadding.PaddingTop = UDim.new(0, 12)
            ParagraphPadding.PaddingBottom = UDim.new(0, 12)
            ParagraphPadding.Parent = ParagraphFrame

            local TitleLabel = CreateElement("TextLabel", {
                Parent = ParagraphFrame,
                Size = UDim2.new(1, -24, 0, 20),
                BackgroundTransparency = 1,
                Text = title,
                TextColor3 = Theme.Text,
                TextSize = 15,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ContentLabel = CreateElement("TextLabel", {
                Parent = ParagraphFrame,
                Position = UDim2.new(0, 0, 0, 24),
                Size = UDim2.new(1, -24, 0, 0),
                BackgroundTransparency = 1,
                Text = content,
                TextColor3 = Theme.TextDark,
                TextSize = 13,
                Font = Enum.Font.Gotham,
                TextXAlignment = Enum.TextXAlignment.Left,
                TextWrapped = true,
                AutomaticSize = Enum.AutomaticSize.Y
            })
        end

        -- Button
        function Tab:AddButton(buttonConfig)
            buttonConfig = buttonConfig or {}
            buttonConfig.Name = buttonConfig.Name or "Button"
            buttonConfig.Callback = buttonConfig.Callback or function() end

            local ButtonFrame = CreateElement("TextButton", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.Secondary,
                Text = "",
                AutoButtonColor = false
            })
            AddCorner(ButtonFrame, 6)

            local ButtonLabel = CreateElement("TextLabel", {
                Parent = ButtonFrame,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -24, 1, 0),
                BackgroundTransparency = 1,
                Text = buttonConfig.Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            ButtonFrame.MouseButton1Click:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Accent}, 0.1)
                task.wait(0.1)
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Secondary}, 0.1)
                pcall(buttonConfig.Callback)
            end)

            ButtonFrame.MouseEnter:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Hover})
            end)

            ButtonFrame.MouseLeave:Connect(function()
                Tween(ButtonFrame, {BackgroundColor3 = Theme.Secondary})
            end)
        end

        -- Toggle
        function Tab:AddToggle(toggleConfig)
            toggleConfig = toggleConfig or {}
            toggleConfig.Name = toggleConfig.Name or "Toggle"
            toggleConfig.Default = toggleConfig.Default or false
            toggleConfig.Callback = toggleConfig.Callback or function() end
            toggleConfig.Flag = toggleConfig.Flag
            toggleConfig.Color = toggleConfig.Color or Theme.Accent

            local toggled = toggleConfig.Default

            local ToggleFrame = CreateElement("TextButton", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.Secondary,
                Text = "",
                AutoButtonColor = false
            })
            AddCorner(ToggleFrame, 6)

            local ToggleLabel = CreateElement("TextLabel", {
                Parent = ToggleFrame,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -70, 1, 0),
                BackgroundTransparency = 1,
                Text = toggleConfig.Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local ToggleOuter = CreateElement("Frame", {
                Parent = ToggleFrame,
                Position = UDim2.new(1, -50, 0.5, 0),
                Size = UDim2.new(0, 44, 0, 24),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0
            })
            AddCorner(ToggleOuter, 12)

            local ToggleInner = CreateElement("Frame", {
                Parent = ToggleOuter,
                Position = UDim2.new(0, 2, 0.5, 0),
                Size = UDim2.new(0, 20, 0, 20),
                AnchorPoint = Vector2.new(0, 0.5),
                BackgroundColor3 = Theme.Text,
                BorderSizePixel = 0
            })
            AddCorner(ToggleInner, 10)

            local function SetToggle(value)
                toggled = value
                
                if toggled then
                    Tween(ToggleOuter, {BackgroundColor3 = toggleConfig.Color})
                    Tween(ToggleInner, {Position = UDim2.new(1, -22, 0.5, 0)})
                else
                    Tween(ToggleOuter, {BackgroundColor3 = Theme.Border})
                    Tween(ToggleInner, {Position = UDim2.new(0, 2, 0.5, 0)})
                end
                
                pcall(toggleConfig.Callback, toggled)
            end

            SetToggle(toggled)

            ToggleFrame.MouseButton1Click:Connect(function()
                SetToggle(not toggled)
            end)

            ToggleFrame.MouseEnter:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.Hover})
            end)

            ToggleFrame.MouseLeave:Connect(function()
                Tween(ToggleFrame, {BackgroundColor3 = Theme.Secondary})
            end)

            if toggleConfig.Flag then
                OrionLib.Flags[toggleConfig.Flag] = {
                    Value = toggled,
                    Set = SetToggle
                }
            end

            return {
                Set = SetToggle
            }
        end

        -- Slider
        function Tab:AddSlider(sliderConfig)
            sliderConfig = sliderConfig or {}
            sliderConfig.Name = sliderConfig.Name or "Slider"
            sliderConfig.Min = sliderConfig.Min or 0
            sliderConfig.Max = sliderConfig.Max or 100
            sliderConfig.Default = sliderConfig.Default or 50
            sliderConfig.Increment = sliderConfig.Increment or 1
            sliderConfig.ValueName = sliderConfig.ValueName or ""
            sliderConfig.Callback = sliderConfig.Callback or function() end
            sliderConfig.Flag = sliderConfig.Flag
            sliderConfig.Color = sliderConfig.Color or Theme.Accent

            local value = sliderConfig.Default
            local dragging = false

            local SliderFrame = CreateElement("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 55),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0
            })
            AddCorner(SliderFrame, 6)

            local SliderLabel = CreateElement("TextLabel", {
                Parent = SliderFrame,
                Position = UDim2.new(0, 12, 0, 8),
                Size = UDim2.new(1, -80, 0, 18),
                BackgroundTransparency = 1,
                Text = sliderConfig.Name,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local SliderValue = CreateElement("TextLabel", {
                Parent = SliderFrame,
                Position = UDim2.new(1, -65, 0, 8),
                Size = UDim2.new(0, 55, 0, 18),
                BackgroundTransparency = 1,
                Text = tostring(value) .. sliderConfig.ValueName,
                TextColor3 = sliderConfig.Color,
                TextSize = 14,
                Font = Enum.Font.GothamBold,
                TextXAlignment = Enum.TextXAlignment.Right
            })

            local SliderTrack = CreateElement("Frame", {
                Parent = SliderFrame,
                Position = UDim2.new(0, 12, 1, -18),
                Size = UDim2.new(1, -24, 0, 4),
                BackgroundColor3 = Theme.Border,
                BorderSizePixel = 0
            })
            AddCorner(SliderTrack, 2)

            local SliderFill = CreateElement("Frame", {
                Parent = SliderTrack,
                Size = UDim2.new(0, 0, 1, 0),
                BackgroundColor3 = sliderConfig.Color,
                BorderSizePixel = 0
            })
            AddCorner(SliderFill, 2)

            local function SetValue(val)
                val = math.floor((val - sliderConfig.Min) / sliderConfig.Increment + 0.5) * sliderConfig.Increment + sliderConfig.Min
                val = math.clamp(val, sliderConfig.Min, sliderConfig.Max)
                value = val
                
                local percent = (value - sliderConfig.Min) / (sliderConfig.Max - sliderConfig.Min)
                Tween(SliderFill, {Size = UDim2.new(percent, 0, 1, 0)}, 0.1)
                SliderValue.Text = tostring(value) .. sliderConfig.ValueName
                
                pcall(sliderConfig.Callback, value)
            end

            SetValue(value)

            SliderTrack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = true
                    local percent = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    SetValue(sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * percent)
                end
            end)

            SliderTrack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 then
                    dragging = false
                end
            end)

            UserInputService.InputChanged:Connect(function(input)
                if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
                    local percent = math.clamp((input.Position.X - SliderTrack.AbsolutePosition.X) / SliderTrack.AbsoluteSize.X, 0, 1)
                    SetValue(sliderConfig.Min + (sliderConfig.Max - sliderConfig.Min) * percent)
                end
            end)

            if sliderConfig.Flag then
                OrionLib.Flags[sliderConfig.Flag] = {
                    Value = value,
                    Set = SetValue
                }
            end

            return {
                Set = SetValue
            }
        end

        -- Dropdown
        function Tab:AddDropdown(dropdownConfig)
            dropdownConfig = dropdownConfig or {}
            dropdownConfig.Name = dropdownConfig.Name or "Dropdown"
            dropdownConfig.Default = dropdownConfig.Default or ""
            dropdownConfig.Options = dropdownConfig.Options or {}
            dropdownConfig.Callback = dropdownConfig.Callback or function() end
            dropdownConfig.Flag = dropdownConfig.Flag

            local selectedOption = dropdownConfig.Default
            local opened = false

            local DropdownFrame = CreateElement("Frame", {
                Parent = TabContent,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundColor3 = Theme.Secondary,
                BorderSizePixel = 0,
                ClipsDescendants = true
            })
            AddCorner(DropdownFrame, 6)

            local DropdownButton = CreateElement("TextButton", {
                Parent = DropdownFrame,
                Size = UDim2.new(1, 0, 0, 40),
                BackgroundTransparency = 1,
                Text = "",
                AutoButtonColor = false
            })

            local DropdownLabel = CreateElement("TextLabel", {
                Parent = DropdownButton,
                Position = UDim2.new(0, 12, 0, 0),
                Size = UDim2.new(1, -40, 1, 0),
                BackgroundTransparency = 1,
                Text = dropdownConfig.Name .. ": " .. selectedOption,
                TextColor3 = Theme.Text,
                TextSize = 14,
                Font = Enum.Font.GothamMedium,
                TextXAlignment = Enum.TextXAlignment.Left
            })

            local Arrow = CreateElement("TextLabel", {
                Parent = DropdownButton,
                Position = UDim2.new(1, -30, 0, 0),
                Size = UDim2.new(0, 20, 1, 0),
                BackgroundTransparency = 1,
                Text = "▼",
                TextColor3 = Theme.TextDark,
                TextSize = 12,
                Font = Enum.Font.GothamBold
            })

            local OptionsFrame = CreateElement("Frame", {
                Parent = DropdownFrame,
                Position = UDim2.new(0, 0, 0, 45),
                Size = UDim2.new(1, 0, 0, 0),
                BackgroundTransparency = 1
            })

            local OptionsLayout = Instance.new("UIListLayout")
            OptionsLayout.SortOrder = Enum.SortOrder.LayoutOrder
            OptionsLayout.Padding = UDim.new(0, 2)
            OptionsLayout.Parent = OptionsFrame

            local function CreateOption(optionName)
                local OptionButton = CreateElement("TextButton", {
                    Parent = OptionsFrame,
                    Size = UDim2.new(1, 0, 0, 30),
                    BackgroundColor3 = Theme.Tertiary,
                    Text = "",
                    AutoButtonColor = false
                })

                local OptionLabel = CreateElement("TextLabel", {
                    Parent = OptionButton,
                    Position = UDim2.new(0, 12, 0, 0),
                    Size = UDim2.new(1, -24, 1, 0),
                    BackgroundTransparency = 1,
                    Text = optionName,
                    TextColor3 = Theme.TextDark,
                    TextSize = 13,
                    Font = Enum.Font.Gotham,
                    TextXAlignment = Enum.TextXAlignment.Left
                })

                OptionButton.MouseButton1Click:Connect(function()
                    selectedOption = optionName
                    DropdownLabel.Text = dropdownConfig.Name .. ": " .. selectedOption
                    opened = false
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)})
                    Tween(Arrow, {Rotation = 0})
                    pcall(dropdownConfig.Callback, selectedOption)
                end)

                OptionButton.MouseEnter:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Theme.Hover})
                end)

                OptionButton.MouseLeave:Connect(function()
                    Tween(OptionButton, {BackgroundColor3 = Theme.Tertiary})
                end)
            end

            for _, option in ipairs(dropdownConfig.Options) do
                CreateOption(option)
            end

            OptionsLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
                OptionsFrame.Size = UDim2.new(1, 0, 0, OptionsLayout.AbsoluteContentSize.Y)
            end)

            DropdownButton.MouseButton1Click:Connect(function()
                opened = not opened
                if opened then
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 45 + OptionsLayout.AbsoluteContentSize.Y)})
                    Tween(Arrow, {Rotation = 180})
                else
                    Tween(DropdownFrame, {Size = UDim2.new(1, 0, 0, 40)})
                    Tween(Arrow, {Rotation = 0})
                end
            end)

            DropdownButton.MouseEnter:Connect(function()
                Tween(DropdownFrame, {BackgroundColor3 = Theme.Hover})
            end)

            DropdownButton.MouseLeave:Connect(function()
                Tween(DropdownFrame, {BackgroundColor3 = Theme.Secondary})
            end)

            if dropdownConfig.Flag then
                OrionLib.Flags[dropdownConfig.Flag] = {
                    Value = selectedOption,
                    Set = function(val)
                        selectedOption = val
                        DropdownLabel.Text = dropdownConfig.Name .. ": " .. selectedOption
                        pcall(dropdownConfig.Callback, selectedOption)
                    end
                }
            end

            return {
                Refresh = function(self, newOptions)
                    for _, child in ipairs(OptionsFrame:GetChildren()) do
                        if child:IsA("TextButton") then
                            child:Destroy()
                        end
                    end
                    for _, option in ipairs(newOptions) do
                        CreateOption(option)
                    end
                end
            }
        end

        return Tab
    end

    -- Toggle UI Function
    function Window:ToggleUI()
        ScreenGui.Enabled = not ScreenGui.Enabled
    end

    return Window
end

-- Init Function
function OrionLib:Init()
    -- Nothing needed for init
end

-- Destroy Function
function OrionLib:Destroy()
    ScreenGui:Destroy()
end

-- Toggle UI Function
function OrionLib:ToggleUI()
    ScreenGui.Enabled = not ScreenGui.Enabled
end

return OrionLib
