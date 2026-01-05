local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Gui = Instance.new("ScreenGui")
local Main = Instance.new("Frame")
local Box = Instance.new("TextBox")
local UITextSizeConstraint = Instance.new("UITextSizeConstraint")
local Label = Instance.new("TextLabel")
local UITextSizeConstraint_2 = Instance.new("UITextSizeConstraint")
local Button = Instance.new("TextButton")
local UITextSizeConstraint_3 = Instance.new("UITextSizeConstraint")

Gui.Name = "Gui"
Gui.Parent = game:GetService("CoreGui")
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

Main.Name = "Main"
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.335954279, 0, 0.542361975, 0)
Main.Size = UDim2.new(0.240350261, 0, 0.166880623, 0)
Main.Active = true
Main.Draggable = true

Box.Name = "Box"
Box.Parent = Main
Box.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
Box.BorderSizePixel = 0
Box.Position = UDim2.new(0.0980926454, 0, 0.218712583, 0)
Box.Size = UDim2.new(0.801089942, 0, 0.364963502, 0)
Box.FontFace = Font.new("rbxasset://fonts/families/SourceSansSemibold.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Box.PlaceholderText = "Player here"
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.TextScaled = true
Box.TextWrapped = true

UITextSizeConstraint.Parent = Box
UITextSizeConstraint.MaxTextSize = 31

Label.Name = "Label"
Label.Parent = Main
Label.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
Label.BorderSizePixel = 0
Label.Size = UDim2.new(1, 0, 0.160583943, 0)
Label.FontFace = Font.new("rbxasset://fonts/families/Nunito.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Label.Text = "Bring Parts"
Label.TextColor3 = Color3.fromRGB(255, 255, 255)
Label.TextScaled = true
Label.TextWrapped = true

UITextSizeConstraint_2.Parent = Label
UITextSizeConstraint_2.MaxTextSize = 21

Button.Name = "Button"
Button.Parent = Main
Button.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
Button.BorderSizePixel = 0
Button.Position = UDim2.new(0.183284417, 0, 0.656760991, 0)
Button.Size = UDim2.new(0.629427791, 0, 0.277372271, 0)
Button.Font = Enum.Font.Nunito
Button.Text = "Bring Off"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextScaled = true
Button.TextWrapped = true

UITextSizeConstraint_3.Parent = Button
UITextSizeConstraint_3.MaxTextSize = 28

local LocalPlayer = Players.LocalPlayer
local character
local humanoidRootPart
local mainStatus = true

UserInputService.InputBegan:Connect(function(input, gameProcessedEvent)
    if input.KeyCode == Enum.KeyCode.RightControl and not gameProcessedEvent then
        mainStatus = not mainStatus
        Main.Visible = mainStatus
    end
end)

local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46262424, 14.46262424, 14.46262424)
    }

    local function EnablePartControl()
        LocalPlayer.ReplicationFocus = Workspace
        RunService.Heartbeat:Connect(function()
            pcall(function()
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            end)
            for _, v in pairs(getgenv().Network.BaseParts) do
                if v:IsDescendantOf(Workspace) then
                    v.Velocity = getgenv().Network.Velocity
                end
            end
        end)
    end
    EnablePartControl()
end

local function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") and not v.Parent:FindFirstChild("Head") and v.Name ~= "Handle" then
        for _, x in ipairs(v:GetChildren()) do
            if x:IsA("BodyMover") or x:IsA("RocketPropulsion") or x:IsA("AlignPosition") or x:IsA("Torque") then
                x:Destroy()
            end
        end
        v.CanCollide = false
        local Torque = Instance.new("Torque", v)
        Torque.Torque = Vector3.new(100000, 100000, 100000)
        local AlignPosition = Instance.new("AlignPosition", v)
        local Attachment2 = Instance.new("Attachment", v)
        Torque.Attachment0 = Attachment2
        AlignPosition.MaxForce = math.huge
        AlignPosition.MaxVelocity = math.huge
        AlignPosition.Responsiveness = 200
        AlignPosition.Attachment0 = Attachment2
        AlignPosition.Attachment1 = Attachment1
        table.insert(getgenv().Network.BaseParts, v)
    end
end

local blackHoleActive = false
local DescendantAddedConnection

local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        Button.Text = "Bring On"
        for _, v in ipairs(Workspace:GetDescendants()) do
            ForcePart(v)
        end
        DescendantAddedConnection = Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then
                ForcePart(v)
            end
        end)
        task.spawn(function()
            while blackHoleActive and RunService.RenderStepped:Wait() do
                if humanoidRootPart then
                    Attachment1.WorldCFrame = humanoidRootPart.CFrame
                end
            end
        end)
    else
        Button.Text = "Bring Off"
        if DescendantAddedConnection then
            DescendantAddedConnection:Disconnect()
        end
        table.clear(getgenv().Network.BaseParts)
    end
end

local function getPlayer(name)
    local lowerName = string.lower(name)
    for _, p in pairs(Players:GetPlayers()) do
        if string.find(string.lower(p.Name), lowerName) or string.find(string.lower(p.DisplayName), lowerName) then
            return p
        end
    end
end

local player = nil

Box.FocusLost:Connect(function(enterPressed)
    if enterPressed then
        player = getPlayer(Box.Text)
        if player then
            Box.Text = player.DisplayName
        end
    end
end)

Button.MouseButton1Click:Connect(function()
    if player and player.Character then
        character = player.Character
        humanoidRootPart = character:FindFirstChild("HumanoidRootPart")
        toggleBlackHole()
    end
end)

