local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")

local Gui = Instance.new("ScreenGui")
Gui.Name = "FE_Aggressive_Bring"
Gui.Parent = gethui()

local Main = Instance.new("Frame")
Main.Name = "Main"
Main.Parent = Gui
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
Main.Position = UDim2.new(0.3, 0, 0.5, 0)
Main.Size = UDim2.new(0.2, 0, 0.15, 0)
Main.Active = true
Main.Draggable = true

local Box = Instance.new("TextBox")
Box.Parent = Main
Box.Size = UDim2.new(0.8, 0, 0.3, 0)
Box.Position = UDim2.new(0.1, 0, 0.2, 0)
Box.PlaceholderText = "User Name"
Box.Text = ""
Box.TextScaled = true

local Button = Instance.new("TextButton")
Button.Parent = Main
Button.Size = UDim2.new(0.8, 0, 0.3, 0)
Button.Position = UDim2.new(0.1, 0, 0.6, 0)
Button.Text = "START"
Button.TextScaled = true

local targetPlayer = nil
local active = false
local CenterPart = Instance.new("Part", Workspace)
CenterPart.Anchored = true
CenterPart.Transparency = 1
CenterPart.CanCollide = false
local Attachment1 = Instance.new("Attachment", CenterPart)

RunService.Heartbeat:Connect(function()
    sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
    if active then
        for _, v in pairs(Workspace:GetDescendants()) do
            if v:IsA("BasePart") and not v.Anchored and not v:IsDescendantOf(LocalPlayer.Character) then
                v.AssemblyLinearVelocity = Vector3.new(0, 0.01, 0)
            end
        end
    end
end)

local function ApplyPhysics(v)
    if v:IsA("BasePart") and not v.Anchored and not v.Parent:FindFirstChildOfClass("Humanoid") then
        for _, obj in ipairs(v:GetChildren()) do
            if obj:IsA("BodyMover") or obj:IsA("Constraint") then obj:Destroy() end
        end
        v.CanCollide = false
        local att0 = Instance.new("Attachment", v)
        local torque = Instance.new("Torque", v)
        torque.Attachment0 = att0
        torque.Torque = Vector3.new(9e9, 9e9, 9e9)
        local alignPos = Instance.new("AlignPosition", v)
        alignPos.Attachment0 = att0
        alignPos.Attachment1 = Attachment1
        alignPos.MaxForce = math.huge
        alignPos.MaxVelocity = math.huge
        alignPos.Responsiveness = 200
    end
end

Button.MouseButton1Click:Connect(function()
    active = not active
    Button.Text = active and "ACTIVE" or "START"
    if active then
        for _, v in ipairs(Workspace:GetDescendants()) do ApplyPhysics(v) end
    end
end)

RunService.RenderStepped:Connect(function()
    if active and targetPlayer and targetPlayer.Character then
        local root = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
        if root then CenterPart.CFrame = root.CFrame end
    end
end)

Box.FocusLost:Connect(function(enter)
    if enter then
        local text = string.lower(Box.Text)
        for _, p in pairs(Players:GetPlayers()) do
            if string.find(string.lower(p.Name), text) or string.find(string.lower(p.DisplayName), text) then
                targetPlayer = p
                Box.Text = p.Name
                break
            end
        end
    end
end)

