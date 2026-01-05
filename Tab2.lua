-- Services
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local LocalPlayer = Players.LocalPlayer
local character, humanoidRootPart
local player = nil
local blackHoleActive = false
local DescendantAddedConnection

-[span_5](start_span)- UI Setup (References from[span_5](end_span))
local Gui = Instance.new("ScreenGui")
Gui.Name = "ImprovedBringGui"
Gui.Parent = gethui()
Gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(75, 75, 75)
Main.Position = UDim2.new(0.335, 0, 0.542, 0)
Main.Size = UDim2.new(0.24, 0, 0.166, 0)
Main.Active = true
Main.Draggable = true

local Box = Instance.new("TextBox")
Box.Parent = Main
Box.Name = "Box"
Box.PlaceholderText = "Target Player Name"
Box.Size = UDim2.new(0.8, 0, 0.36, 0)
Box.Position = UDim2.new(0.1, 0, 0.22, 0)
Box.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
Box.TextColor3 = Color3.fromRGB(255, 255, 255)
Box.TextScaled = true

local Button = Instance.new("TextButton")
Button.Parent = Main
Button.Name = "Toggle"
Button.Text = "Bring: OFF"
Button.Size = UDim2.new(0.63, 0, 0.28, 0)
Button.Position = UDim2.new(0.18, 0, 0.65, 0)
Button.BackgroundColor3 = Color3.fromRGB(95, 95, 95)
Button.TextColor3 = Color3.fromRGB(255, 255, 255)
Button.TextScaled = true

-[span_6](start_span)- Hidden Part Setup[span_6](end_span)
local Folder = Instance.new("Folder", Workspace)
local Part = Instance.new("Part", Folder)
local Attachment1 = Instance.new("Attachment", Part)
Part.Anchored = true
Part.CanCollide = false
Part.Transparency = 1

-[span_7](start_span)- Network Ownership Handling[span_7](end_span)
if not getgenv().Network then
    getgenv().Network = {
        BaseParts = {},
        Velocity = Vector3.new(14.46, 14.46, 14.46)
    }
    
    RunService.Heartbeat:Connect(function()
        settings().Physics.AllowSleep = false
        sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
        for _, p in pairs(getgenv().Network.BaseParts) do
            if p:IsDescendantOf(Workspace) then
                p.Velocity = getgenv().Network.Velocity
            end
        end
    end)
end

-[span_8](start_span)[span_9](start_span)- Function to apply physics to parts[span_8](end_span)[span_9](end_span)
local function ForcePart(v)
    if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LocalPlayer.Character) then
        if not v.Parent:FindFirstChildOfClass("Humanoid") then
            -- Remove existing movers to prevent conflicts
            for _, x in ipairs(v:GetChildren()) do
                if x:IsA("BodyMover") or x:IsA("AlignPosition") or x:IsA("Attachment") then
                    x:Destroy()
                end
            end
            
            local Attachment2 = Instance.new("Attachment", v)
            local AlignPosition = Instance.new("AlignPosition", v)
            AlignPosition.MaxForce = math.huge
            AlignPosition.MaxVelocity = math.huge
            AlignPosition.Responsiveness = 200
            AlignPosition.Attachment0 = Attachment2
            AlignPosition.Attachment1 = Attachment1
            
            table.insert(getgenv().Network.BaseParts, v)
        end
    end
end

-[span_10](start_span)- Toggle Logic[span_10](end_span)
local function toggleBlackHole()
    blackHoleActive = not blackHoleActive
    if blackHoleActive then
        Button.Text = "Bring: ON"
        for _, v in ipairs(Workspace:GetDescendants()) do
            ForcePart(v)
        end
        DescendantAddedConnection = Workspace.DescendantAdded:Connect(ForcePart)
        
        task.spawn(function()
            while blackHoleActive do
                if humanoidRootPart then
                    Attachment1.WorldCFrame = humanoidRootPart.CFrame
                end
                RunService.RenderStepped:Wait()
            end
        end)
    else
        Button.Text = "Bring: OFF"
        if DescendantAddedConnection then DescendantAddedConnection:Disconnect() end
        table.clear(getgenv().Network.BaseParts)
    end
end

-[span_11](start_span)- Player Search[span_11](end_span)
Box.FocusLost:Connect(function(enter)
    if enter then
        local target = Box.Text:lower()
        for _, p in pairs(Players:GetPlayers()) do
            if p.Name:lower():find(target) or p.DisplayName:lower():find(target) then
                player = p
                Box.Text = p.DisplayName
                break
            end
        end
    end
end)

Button.MouseButton1Click:Connect(function()
    if player and player.Character then
        humanoidRootPart = player.Character:FindFirstChild("HumanoidRootPart")
        toggleBlackHole()
    end
end)

-[span_12](start_span)- UI Toggle (Right Control)[span_12](end_span)
UserInputService.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.RightControl then
        Main.Visible = not Main.Visible
    end
end)
    
