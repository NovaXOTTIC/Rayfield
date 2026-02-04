local Rayfield = loadstring(game:HttpGet('https://sirius.menu/rayfield'))()

local RedTheme = {
    TextColor = Color3.fromRGB(240, 240, 240),
    Background = Color3.fromRGB(15, 15, 15),
    Topbar = Color3.fromRGB(20, 20, 20),
    Shadow = Color3.fromRGB(10, 10, 10),
    NotificationBackground = Color3.fromRGB(20, 20, 20),
    NotificationActionsBackground = Color3.fromRGB(230, 230, 230),
    TabBackground = Color3.fromRGB(25, 25, 25),
    TabStroke = Color3.fromRGB(255, 50, 50),
    TabBackgroundSelected = Color3.fromRGB(35, 35, 35),
    TabTextColor = Color3.fromRGB(200, 200, 200),
    SelectedTabTextColor = Color3.fromRGB(255, 50, 50),
    ElementBackground = Color3.fromRGB(30, 30, 30),
    ElementBackgroundHover = Color3.fromRGB(35, 35, 35),
    SecondaryElementBackground = Color3.fromRGB(25, 25, 25),
    ElementStroke = Color3.fromRGB(255, 50, 50),
    SecondaryElementStroke = Color3.fromRGB(200, 30, 30),
    SliderBackground = Color3.fromRGB(35, 35, 35),
    SliderProgress = Color3.fromRGB(255, 50, 50),
    SliderStroke = Color3.fromRGB(255, 80, 80),
    ToggleBackground = Color3.fromRGB(30, 30, 30),
    ToggleEnabled = Color3.fromRGB(255, 50, 50),
    ToggleDisabled = Color3.fromRGB(60, 60, 60),
    ToggleEnabledStroke = Color3.fromRGB(255, 80, 80),
    ToggleDisabledStroke = Color3.fromRGB(80, 80, 80),
    ToggleEnabledOuterStroke = Color3.fromRGB(200, 40, 40),
    ToggleDisabledOuterStroke = Color3.fromRGB(50, 50, 50),
    DropdownSelected = Color3.fromRGB(35, 35, 35),
    DropdownUnselected = Color3.fromRGB(28, 28, 28),
    InputBackground = Color3.fromRGB(30, 30, 30),
    InputStroke = Color3.fromRGB(255, 50, 50),
    PlaceholderColor = Color3.fromRGB(150, 150, 150)
}

local Window = Rayfield:CreateWindow({
    Name = "The Chosen One [Version 145]",
    LoadingTitle = "The Chosen One",
    LoadingSubtitle = "Loading Interface",
    ConfigurationSaving = {
        Enabled = true,
        FolderName = "TheChosenOne",
        FileName = "Config"
    },
    Discord = {
        Enabled = false,
    },
    KeySystem = false,
    Theme = RedTheme
})

task.spawn(function()
    task.wait(1)
    
    local PlayerGui = game:GetService("Players").LocalPlayer.PlayerGui
    local RayfieldGui = PlayerGui:WaitForChild("Rayfield")
    local Main = RayfieldGui:WaitForChild("Main")
    Main.Size = UDim2.new(0, 589, 0, 372)
    Main.Topbar.Size = UDim2.new(0, 589, 0, 45)
end)

    Rayfield:Notify({
    Title = "VyzenHub Loaded",
    Content = "Ftap script loaded",
    Duration = 5,
    Image = "check-circle",
})

Rayfield:LoadConfiguration()
