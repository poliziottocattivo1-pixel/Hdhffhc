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
Main.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Main.BorderSizePixel = 0
Main.Position = UDim2.new(0.335, 0, 0.542, 0)
Main.Size = UDim2.new(0.24, 0, 0.166, 0)
Main.Active = true
Main.Draggable = true

Box.Name = "Box"
Box.Parent = Main
Box.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Box.BorderSizePixel = 0
Box.Position = UDim2.new(0.1, 0, 0.25, 0)
Box.Size = UDim2.new(0.8, 0, 0.35, 0)
Box.FontFace = Font.new("rbxasset://fonts/families/SourceSansSemibold.json", Enum.FontWeight.Bold, Enum.FontStyle.Normal)
Box.PlaceholderText = "Target Name"
Box.Text = ""
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.TextScaled = true

Label.Name = "Label"
Label.Parent = Main
Label.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Label.Size = UDim2.new(1, 0, 0.2, 0)
Label.Text = "Hostile Part Bringer"
Label.TextColor3 = Color3.fromRGB(255, 0, 0)
Label.TextScaled = true

Button.Name = "Button"
Button.Parent = Main
Button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Button.Position = UDim2.new(0.15, 0, 0.65, 0)
Button.Size = UDim2.new(0.7, 0, 0.3, 0)
Button.Text = "ACTIVATE"
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextScaled = true

local LocalPlayer = Players.LocalPlayer
local character
local humanoidRootPart
local mainStatus = true

UserInputService.InputBegan:Connect(function(input, gpe)
    if input.KeyCode == Enum.KeyCode.RightControl and not gpe then
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
        Velocity = Vector3.new(50, 50, 50)
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
    if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LocalPlayer.Character) then
        if not v.Parent:FindFirstChildOfClass("Humanoid") then
            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyMover") or x:IsA("AlignPosition") or x:IsA("Attachment") or x:IsA("Torque") then
                    x:Destroy()
                end
            end
            
            v.CanCollide = false
            v.CustomPhysicalProperties = PhysicalProperties.new(0, 0, 0, 0, 0)
            
            local Attachment2 = Instance.new("Attachment", v)
            local AlignPosition = Instance.new("AlignPosition", v)
            local Torque = Instance.new("Torque", v)
            
            Torque.Attachment0 = Attachment2
            Torque.Torque = Vector3.new(500000, 500000, 500000)
            
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 300
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = Attachment1
            
            table.insert(getgenv().Network.BaseParts, v)
        end
    end
end

local blackHoleActive = false
local Connection

local function toggle()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        Button.Text = "DEACTIVATE"
        Button.TextColor3 = Color3.fromRGB(255, 0, 0)
        for _, v in ipairs(Workspace:GetDescendants()) do
            ForcePart(v)
        end
        Connection = Workspace.DescendantAdded:Connect(function(v)
            if blackHoleActive then ForcePart(v) end
        end)
        task.spawn(function()
            while blackHoleActive and RunService.RenderStepped:Wait() do
                if humanoidRootPart then
                    Attachment1.WorldCFrame = humanoidRootPart.CFrame * CFrame.Angles(0, tick() * 5, 0)
                end
            end
        end)
    else
        Button.Text = "ACTIVATE"
        Button.TextColor3 = Color3.fromRGB(255, 255, 255)
        if Connection then Connection:Disconnect() end
        table.clear(getgenv().Network.BaseParts)
    end
end

local function getPlayer(name)
    name = name:lower()
    for _, p in pairs(Players:GetPlayers()) do
        if p.Name:lower():find(name) or p.DisplayName:lower():find(name) then
            return p
        end
    end
end

local targetPlayer = nil

Box.FocusLost:Connect(function(enter)
    if enter then
        targetPlayer = getPlayer(Box.Text)
        if targetPlayer then Box.Text = targetPlayer.DisplayName end
    end
end)

Button.MouseButton1Click:Connect(function()
    if targetPlayer and targetPlayer.Character then
        humanoidRootPart = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        toggle()
    end
end)


