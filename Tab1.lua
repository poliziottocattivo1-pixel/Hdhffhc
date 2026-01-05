local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

-- Configuration
local OFFSET_Y = -10000000 -- The void teleport distance

local State = {
    Enabled = false,
    Parts = {},
    Connections = {},
    OriginalTransparencies = {},
    Dragging = false,
    DragStart = nil,
    StartPos = nil
}

--// UTILITY FUNCTIONS

local function CacheCharacter(character)
    State.Parts = {}
    State.OriginalTransparencies = {}
    
    for _, part in ipairs(character:GetDescendants()) do
        if part:IsA("BasePart") and part.Transparency < 1 then
            State.OriginalTransparencies[part] = part.Transparency
            table.insert(State.Parts, part)
        end
    end
end

local function UpdateVisuals()
    if not LocalPlayer.Character then return end
    
    for _, part in ipairs(State.Parts) do
        if part and part.Parent then
            if State.Enabled then
                part.Transparency = 0.5 -- Visual indicator only (Local)
            else
                part.Transparency = State.OriginalTransparencies[part] or 0
            end
        end
    end
end

local function ToggleInvisibility(uiLabel)
    State.Enabled = not State.Enabled
    
    UpdateVisuals()
    
    if uiLabel then
        uiLabel.Text = State.Enabled and "STATUS: HIDDEN" or "STATUS: VISIBLE"
        uiLabel.TextColor3 = State.Enabled and Color3.fromRGB(0, 255, 127) or Color3.fromRGB(255, 85, 85)
    end

    -- ANTI-SHAKE FIX (Physics Based, No Noclip)
    -- We set MaxSlopeAngle to ~90 deg so the game doesn't try to slide you on hills
    if State.Enabled and LocalPlayer.Character then
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then 
            hum.MaxSlopeAngle = 89.5 
        end
    elseif not State.Enabled and LocalPlayer.Character then
        -- Optional: Reset to default when disabled
        local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
        if hum then hum.MaxSlopeAngle = 45 end 
    end
end

--// UI CONSTRUCTION

local function CreateModernUI()
    local existing = LocalPlayer:WaitForChild("PlayerGui"):FindFirstChild("InvisUtility")
    if existing then existing:Destroy() end

    local screenGui = Instance.new("ScreenGui", LocalPlayer:WaitForChild("PlayerGui"))
    screenGui.Name = "InvisUtility"
    screenGui.ResetOnSpawn = false
    
    local frame = Instance.new("Frame", screenGui)
    frame.Size = UDim2.new(0, 220, 0, 90)
    frame.Position = UDim2.new(0.5, -110, 0.15, 0)
    frame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    frame.BorderSizePixel = 0
    
    local corner = Instance.new("UICorner", frame)
    corner.CornerRadius = UDim.new(0, 10)
    
    local stroke = Instance.new("UIStroke", frame)
    stroke.Color = Color3.fromRGB(60, 60, 60)
    stroke.Thickness = 2

    local statusLabel = Instance.new("TextLabel", frame)
    statusLabel.Size = UDim2.new(1, 0, 0.4, 0)
    statusLabel.BackgroundTransparency = 1
    statusLabel.Text = "STATUS: VISIBLE"
    statusLabel.TextColor3 = Color3.fromRGB(255, 85, 85)
    statusLabel.Font = Enum.Font.GothamBlack
    statusLabel.TextSize = 16

    local button = Instance.new("TextButton", frame)
    button.Size = UDim2.new(0.9, 0, 0.45, 0)
    button.Position = UDim2.new(0.05, 0, 0.45, 0)
    button.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    button.Text = "Toggle Invis (Key: G)"
    button.TextColor3 = Color3.fromRGB(255, 255, 255)
    button.Font = Enum.Font.GothamBold
    button.TextSize = 14
    button.BorderSizePixel = 0
    button.AutoButtonColor = true
    
    local btnCorner = Instance.new("UICorner", button)
    btnCorner.CornerRadius = UDim.new(0, 6)

    -- Mobile/PC Drag Logic
    local function InputBegan(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            State.Dragging = true
            State.DragStart = input.Position
            State.StartPos = frame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    State.Dragging = false
                end
            end)
        end
    end

    local function InputChanged(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            if State.Dragging then
                local delta = input.Position - State.DragStart
                frame.Position = UDim2.new(
                    State.StartPos.X.Scale, 
                    State.StartPos.X.Offset + delta.X, 
                    State.StartPos.Y.Scale, 
                    State.StartPos.Y.Offset + delta.Y
                )
            end
        end
    end

    frame.InputBegan:Connect(InputBegan)
    UIS.InputChanged:Connect(InputChanged)

    button.MouseButton1Click:Connect(function() ToggleInvisibility(statusLabel) end)
    
    return statusLabel
end

local statusRef = CreateModernUI()

--// MAIN LOOP

local function StartLoops()
    if State.Connections.Heartbeat then State.Connections.Heartbeat:Disconnect() end

    State.Connections.Heartbeat = RunService.Heartbeat:Connect(function()
        if State.Enabled and LocalPlayer.Character then
            local root = LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            local hum = LocalPlayer.Character:FindFirstChild("Humanoid")
            
            if root and hum then
                local oldCF = root.CFrame
                local oldCamOffset = hum.CameraOffset
                
                -- Teleport Down
                local newCF = oldCF * CFrame.new(0, OFFSET_Y, 0)
                root.CFrame = newCF
                
                -- Adjust Camera to look normal
                local offsetFix = newCF:ToObjectSpace(CFrame.new(oldCF.Position)).Position
                hum.CameraOffset = offsetFix
                
                RunService.RenderStepped:Wait()
                
                -- Restore Position
                root.CFrame = oldCF
                hum.CameraOffset = oldCamOffset
            end
        end
    end)
end

--// INITIALIZATION

LocalPlayer.CharacterAdded:Connect(function(char)
    State.Enabled = false
    if statusRef then
        statusRef.Text = "STATUS: VISIBLE"
        statusRef.TextColor3 = Color3.fromRGB(255, 85, 85)
    end
    task.wait(1)
    CacheCharacter(char)
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

