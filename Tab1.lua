local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local State = {
    Enabled = false,
    Parts = {},
    Connections = {},
    OriginalTransparencies = {}
}

local function CacheCharacter(character)
    State.Parts = {}
    State.OriginalTransparencies = {}
    
    local descendants = character:GetDescendants()
    for i = 1, #descendants do
        local part = descendants[i]
        if part:IsA("BasePart") then
            State.OriginalTransparencies[part] = part.Transparency
            table.insert(State.Parts, part)
        end
    end
end

local function ToggleInvisibility(uiLabel)
    State.Enabled = not State.Enabled
    
    for i = 1, #State.Parts do
        local part = State.Parts[i]
        if part and part.Parent then
            if State.Enabled then
                part.Transparency = 0.5
            else
                part.Transparency = State.OriginalTransparencies[part] or 0
            end
        end
    end
    
    if uiLabel then
        if State.Enabled then
            uiLabel.Text = "STATUS: HIDDEN"
            uiLabel.TextColor3 = Color3.fromRGB(0, 255, 127)
        else
            uiLabel.Text = "STATUS: VISIBLE"
            uiLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
        end
    end
end

local function CreateModernUI()
    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.Name = "InvisUtility"
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 200, 0, 80)
    frame.Position = UDim2.new(0.5, -100, 0.1, 0)
    frame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    frame.BorderSizePixel = 0
    frame.Active = true
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 8)

    local statusLabel = Instance.new("TextLabel", frame)
    statusLabel.Size = UDim2.new(1, 0, 0.4, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: VISIBLE"
    statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
    statusLabel.Font = Enum.Font.GothamBold
    statusLabel.TextSize = 14

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.9, 0, 0.4, 0)
    button.Position = UDim2.new(0.05, 0, 0.5, 0)
    button.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    button.Text = "Toggle Invisibility (G)"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.Gotham
    button.TextSize = 12
    button.BorderSizePixel = 0
    Instance.new("UICorner", button)

    local dragging, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        frame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if dragging then
                update(input)
            end
        end
    end)

    button.MouseButton1Click:Connect(function() 
        ToggleInvisibility(statusLabel)
    end)
    
    return statusLabel
end

local statusRef = CreateModernUI()

local function StartLoops()
    for i, conn in pairs(State.Connections) do 
        conn:Disconnect()
    end

    State.Connections.Heartbeat = RunService.Heartbeat:Connect(function()
        if State.Enabled and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            
            if root and hum then
                local oldCF = root.CFrame
                local oldOffset = hum.CameraOffset
                
                local hiddenCFrame = oldCF * CFrame.new(0, -200000, 0)
                root.CFrame = hiddenCFrame
                
                local localCamPos = hiddenCFrame:ToObjectSpace(CFrame.new(oldCF.Position)).Position
                hum.CameraOffset = localCamPos
                
                RunService.RenderStepped:Wait()
                
                root.CFrame = oldCF
                hum.CameraOffset = oldOffset
            end
        end
    end)
end

LocalPlayer.CharacterAdded:Connect(function(char)
    task.wait(1)
    CacheCharacter(char)
    State.Enabled = false
    statusRef.Text = "STATUS: VISIBLE"
    statusRef.TextColor3 = Color3.fromRGB(255, 85, 85)
end)

UIS.InputBegan:Connect(function(input, processed)
    if not processed and input.KeyCode == Enum.KeyCode.G then
        ToggleInvisibility(statusRef)
    end
end)

if LocalPlayer.Character then 
    CacheCharacter(LocalPlayer.Character)
end

StartLoops()
