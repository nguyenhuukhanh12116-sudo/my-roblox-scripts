local SETTINGS_FILE = "JNHHGaming_Config.json"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local MySettings = {
    infiniteJumpEnabled = false, safeEnabled = false, tpNearestEnabled = false,
    espEnabled = false, tpaEnabled = false, moveEnabled = false, flingEnabled = false,
    showSafeSquare = true, tpSizeValue = 50, safeSizeValue = 50,
    tpSquareX_Scale = 0.5, tpSquareX_Offset = -55, tpSquareY_Scale = 0.5, tpSquareY_Offset = -25,
    safeSquareX_Scale = 0.5, safeSquareX_Offset = 5, safeSquareY_Scale = 0.5, safeSquareY_Offset = -25
}

local function SaveConfig()
    local s, e = pcall(function() return HttpService:JSONEncode(MySettings) end)
    if s and writefile then writefile(SETTINGS_FILE, e) end
end
local function LoadConfig()
    if readfile and isfile and isfile(SETTINGS_FILE) then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
        if s and type(d) == "table" then for k, v in pairs(d) do MySettings[k] = v end end
    end
end
LoadConfig()

local infiniteJumpEnabled, safeEnabled, tpNearestEnabled = MySettings.infiniteJumpEnabled, MySettings.safeEnabled, MySettings.tpNearestEnabled
local espEnabled, tpaEnabled, moveEnabled, flingEnabled = MySettings.espEnabled, MySettings.tpaEnabled, MySettings.moveEnabled, MySettings.flingEnabled
local showSafeSquare, tpSizeValue, safeSizeValue = MySettings.showSafeSquare, MySettings.tpSizeValue, MySettings.safeSizeValue
local safePart, espObjects, squareTpActive, isAttacking, oldCFrame = nil, {}, false, false, nil

local gui = Instance.new("ScreenGui")
gui.Name = "JNHHGamingCompact"; gui.ResetOnSpawn = false; gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "CompactFrame"; frame.Size = UDim2.new(0, 200, 0, 300); frame.Position = UDim2.new(0, 50, 0, 50) 
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35); frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0; frame.Active = true; frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"; openButton.Size = UDim2.new(0, 90, 0, 35); openButton.Position = UDim2.new(0, 50, 0, 50)
openButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255); openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Font = Enum.Font.SourceSansBold; openButton.TextSize = 14
openButton.Text = "Mở GUI"; openButton.Visible = false; openButton.Active = true; openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 6)

local function makeDraggable(uiInstance)
    local dragging = false; local dragInput, dragStart, startPos; local currentTouchObject = nil
    uiInstance.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragging then
            dragging = true; currentTouchObject = input; dragStart = input.Position; startPos = uiInstance.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false; currentTouchObject = nil end end)
        end
    end)
    uiInstance.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging then
            if input == currentTouchObject or input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            uiInstance.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame); makeDraggable(openButton)

local FONT = Enum.Font.SourceSansBold
local C_OFF = Color3.fromRGB(60, 60, 70)
local function createBtn(name, text, w, x, y, color, parent)
    local b = Instance.new("TextButton"); b.Name = name; b.Size = UDim2.new(0, w, 0, 30); b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.Font = FONT; b.TextSize = 13
    b.Text = text; b.Parent = parent; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

local jumpButton = createBtn("jumpBtn", infiniteJumpEnabled and "Inf: ON" or "Inf: OFF", 85, 10, 10, infiniteJumpEnabled and Color3.fromRGB(0, 200, 100) or C_OFF, frame)
local safeButton = createBtn("safeBtn", safeEnabled and "Safe: ON" or "Safe: OFF", 85, 105, 10, safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF, frame)
local tpButton = createBtn("tpBtn", tpNearestEnabled and "TP: ON" or "TP: OFF", 85, 10, 45, tpNearestEnabled and Color3.fromRGB(0, 200, 100) or C_OFF, frame)
local showSafeBtn = createBtn("showSfBtn", showSafeSquare and "BtnSF: ON" or "BtnSF: OFF", 85, 105, 45, showSafeSquare and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50), frame)
local espButton = createBtn("espBtn", espEnabled and "ESP: ON" or "ESP: OFF", 180, 10, 80, espEnabled and Color3.fromRGB(0, 180, 255) or C_OFF, frame)
local tpaButton = createBtn("tpaBtn", tpaEnabled and "TPA: ON" or "TPA: OFF", 85, 10, 115, tpaEnabled and Color3.fromRGB(150, 0, 255) or C_OFF, frame)
local moveButton = createBtn("moveBtn", moveEnabled and "Move: ON" or "Move: OFF", 85, 105, 115, moveEnabled and Color3.fromRGB(0, 200, 100) or C_OFF, frame)
local decreaseSizeButton = createBtn("decTpBtn", "TP Size: -", 85, 10, 150, Color3.fromRGB(180, 50, 50), frame)
local increaseSizeButton = createBtn("incTpBtn", "TP Size: +", 85, 105, 150, Color3.fromRGB(50, 180, 50), frame)
local decreaseSafeSizeBtn = createBtn("decSfBtn", "SF Size: -", 85, 10, 185, Color3.fromRGB(180, 100, 20), frame)
local increaseSafeSizeBtn = createBtn("incSfBtn", "SF Size: +", 85, 105, 185, Color3.fromRGB(180, 150, 20), frame)
local flingButton = createBtn("flingBtn", flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF", 180, 10, 220, flingEnabled and Color3.fromRGB(255, 0, 100) or C_OFF, frame)
local minimizeButton = createBtn("minBtn", "Thu nhỏ (-)", 180, 10, 255, Color3.fromRGB(200, 50, 50), frame)

local tpSquare = Instance.new("TextButton")
tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue)
tpSquare.Position = UDim2.new(MySettings.tpSquareX_Scale, MySettings.tpSquareX_Offset, MySettings.tpSquareY_Scale, MySettings.tpSquareY_Offset) 
tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50); tpSquare.Text = "TP"; tpSquare.TextColor3 = Color3.new(1,1,1)
tpSquare.Font = FONT; tpSquare.TextSize = 16; tpSquare.Visible = tpaEnabled; tpSquare.BorderSizePixel = 0; tpSquare.Parent = gui

local safeSquare = Instance.new("TextButton")
safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue)
safeSquare.Position = UDim2.new(MySettings.safeSquareX_Scale, MySettings.safeSquareX_Offset, MySettings.safeSquareY_Scale, MySettings.safeSquareY_Offset) 
safeSquare.BackgroundColor3 = safeEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 180, 0)
safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"; safeSquare.TextColor3 = Color3.new(0,0,0)
safeSquare.Font = FONT; safeSquare.TextSize = 14; safeSquare.Visible = showSafeSquare; safeSquare.BorderSizePixel = 0; safeSquare.Parent = gui

local function setupSquareDrag(targetUi, settingPrefix)
    local dragging = false; local dragInput, dragStart, startPos; local touchObject = nil
    targetUi.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and moveEnabled and not dragging then
            dragging = true; touchObject = input; dragStart = input.Position; startPos = targetUi.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false; touchObject = nil
                    MySettings[settingPrefix.."X_Scale"] = targetUi.Position.X.Scale; MySettings[settingPrefix.."X_Offset"] = targetUi.Position.X.Offset
                    MySettings[settingPrefix.."Y_Scale"] = targetUi.Position.Y.Scale; MySettings[settingPrefix.."Y_Offset"] = targetUi.Position.Y.Offset
                    SaveConfig()
                end
            end)
        end
    end)
    targetUi.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and dragging and moveEnabled then
            if input == touchObject or input.UserInputType == Enum.UserInputType.MouseMovement then dragInput = input end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging and moveEnabled then
            local delta = input.Position - dragStart
            targetUi.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
setupSquareDrag(tpSquare, "tpSquare"); setupSquareDrag(safeSquare, "safeSquare")
local C_ON_GRN = Color3.fromRGB(0, 200, 100)
local function getClosestPlayer()
    local closestPlayer = nil; local shortestDistance = math.huge
    local myChar = LocalPlayer.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myHrp then
        for _, v in pairs(Players:GetPlayers()) do
            if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then
                local distance = (myHrp.Position - v.Character.HumanoidRootPart.Position).Magnitude
                if distance < shortestDistance then shortestDistance = distance; closestPlayer = v end
            end
        end
    end
    return closestPlayer
end

jumpButton.MouseButton1Click:Connect(function() 
    infiniteJumpEnabled = not infiniteJumpEnabled; jumpButton.Text = infiniteJumpEnabled and "Inf: ON" or "Inf: OFF"
    jumpButton.BackgroundColor3 = infiniteJumpEnabled and C_ON_GRN or C_OFF
    MySettings.infiniteJumpEnabled = infiniteJumpEnabled; SaveConfig()
end)

decreaseSizeButton.MouseButton1Click:Connect(function()
    if tpSizeValue > 30 then tpSizeValue = tpSizeValue - 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end
end)
increaseSizeButton.MouseButton1Click:Connect(function()
    if tpSizeValue < 150 then tpSizeValue = tpSizeValue + 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end
end)
decreaseSafeSizeBtn.MouseButton1Click:Connect(function()
    if safeSizeValue > 30 then safeSizeValue = safeSizeValue - 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end
end)
increaseSafeSizeBtn.MouseButton1Click:Connect(function()
    if safeSizeValue < 150 then safeSizeValue = safeSizeValue + 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end
end)

local function checkSafePlatform()
    if safeEnabled then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (not safePart or not safePart.Parent) then
            safePart = Instance.new("Part"); safePart.Size = Vector3.new(20, 1, 20)
            safePart.Position = Vector3.new(hrp.Position.X, hrp.Position.Y + 300, hrp.Position.Z)
            safePart.Anchored = true; safePart.BrickColor = BrickColor.new("White"); safePart.Parent = workspace
            hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0))
        end
    else
        if safePart then safePart:Destroy(); safePart = nil end
    end
end

safeButton.MouseButton1Click:Connect(function()
    safeEnabled = not safeEnabled
    safeButton.Text = safeEnabled and "Safe: ON" or "Safe: OFF"
    safeButton.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF
    safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"
    safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0)
    MySettings.safeEnabled = safeEnabled; SaveConfig(); checkSafePlatform()
end)

showSafeBtn.MouseButton1Click:Connect(function()
    showSafeSquare = not showSafeSquare; showSafeBtn.Text = showSafeSquare and "BtnSF: ON" or "BtnSF: OFF"
    showSafeBtn.BackgroundColor3 = showSafeSquare and C_ON_GRN or Color3.fromRGB(200, 50, 50)
    safeSquare.Visible = showSafeSquare
    MySettings.showSafeSquare = showSafeSquare; SaveConfig()
end)

safeSquare.MouseButton1Click:Connect(function()
    safeEnabled = not safeEnabled
    safeButton.Text = safeEnabled and "Safe: ON" or "Safe: OFF"
    safeButton.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF
    safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"
    safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0)
    MySettings.safeEnabled = safeEnabled; SaveConfig(); checkSafePlatform()
    if safeEnabled then
        task.wait(0.05)
        if safePart then
            local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
            if hrp then hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if safeEnabled and safePart and safePart.Parent then
            local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
            if hrp and hrp.Position.Y < (safePart.Position.Y - 10) then hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end
        end
    end
end)

tpaButton.MouseButton1Click:Connect(function()
    tpaEnabled = not tpaEnabled; tpaButton.Text = tpaEnabled and "TPA: ON" or "TPA: OFF"
    tpaButton.BackgroundColor3 = tpaEnabled and Color3.fromRGB(150, 0, 255) or C_OFF; tpSquare.Visible = tpaEnabled
    if not tpaEnabled then squareTpActive = false; tpSquare.Text = "TP"; tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end
    MySettings.tpaEnabled = tpaEnabled; SaveConfig()
end)

moveButton.MouseButton1Click:Connect(function()
    moveEnabled = not moveEnabled; moveButton.Text = moveEnabled and "Move: ON" or "Move: OFF"
    moveButton.BackgroundColor3 = moveEnabled and C_ON_GRN or C_OFF
    MySettings.moveEnabled = moveEnabled; SaveConfig()
end)

tpSquare.MouseButton1Click:Connect(function()
    if tpaEnabled then 
        squareTpActive = not squareTpActive
        if squareTpActive then
            tpSquare.Text = "TP: ON"; tpSquare.BackgroundColor3 = C_ON_GRN 
        else
            tpSquare.Text = "TP"; tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        if tpaEnabled and squareTpActive then
            pcall(function()
                local targetPlayer = getClosestPlayer()
                local myChar = LocalPlayer.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if targetPlayer and myHrp then
                    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then myHrp.CFrame = targetHrp.CFrame end
                end
            end)
        end
    end
end)

local function triggerAttackBlink()
    if flingEnabled and not isAttacking then
        local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        local target = getClosestPlayer()
        if myHrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
            local targetHrp = target.Character.HumanoidRootPart
            if (myHrp.Position - targetHrp.Position).Magnitude < 25 then
                oldCFrame = myHrp.CFrame; isAttacking = true
                task.wait(0.2); isAttacking = false
                if oldCFrame then myHrp.CFrame = oldCFrame; myHrp.Velocity = Vector3.new(0, 0, 0); myHrp.RotVelocity = Vector3.new(0, 0, 0); oldCFrame = nil end
            end
        end
    end
end

local toolConnection = nil
local function trackWeapon(character)
    if toolConnection then toolConnection:Disconnect() end
    toolConnection = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then child.Activated:Connect(triggerAttackBlink) end
    end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and flingEnabled then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then triggerAttackBlink() end
    end
end)

flingButton.MouseButton1Click:Connect(function()
    flingEnabled = not flingEnabled; flingButton.Text = flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF"
    flingButton.BackgroundColor3 = flingEnabled and Color3.fromRGB(255, 0, 100) or C_OFF
    MySettings.flingEnabled = flingEnabled; SaveConfig()
end)

RunService.Heartbeat:Connect(function()
    local char = LocalPlayer.Character; local myHrp = char and char:FindFirstChild("HumanoidRootPart")
    if not myHrp then return end
    if flingEnabled and isAttacking then
        pcall(function()
            local target = getClosestPlayer()
            if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then
                local targetHrp = target.Character.HumanoidRootPart
                myHrp.CFrame = targetHrp.CFrame * CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), math.rad(math.random(0,360)))
                myHrp.Velocity = Vector3.new(99999, 99999, 99999); myHrp.RotVelocity = Vector3.new(99999, 99999, 99999)
            end
        end)
    else
        if flingEnabled then myHrp.Velocity = Vector3.new(0, 0, 0); myHrp.RotVelocity = Vector3.new(0, 0, 0) end
    end
end)

local function createESP(player)
    if player == LocalPlayer then return end
    local function applyESP(character)
        task.wait(0.5); if not espEnabled then return end
        local head = character:WaitForChild("Head", 5); if not head then return end
        local billboard = Instance.new("BillboardGui"); billboard.Name = "ESP_Billboard"; billboard.Size = UDim2.new(0, 200, 0, 50)
        billboard.AlwaysOnTop = true; billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.Parent = head
        local nameLabel = Instance.new("TextLabel"); nameLabel.Size = UDim2.new(1, 0, 1, 0); nameLabel.BackgroundTransparency = 1
        nameLabel.Text = player.Name; nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50); nameLabel.TextStrokeTransparency = 0
        nameLabel.Font = Enum.Font.SourceSansBold; nameLabel.TextSize = 18; nameLabel.Parent = billboard
        espObjects[player] = {Billboard = billboard}
    end
    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(applyESP)
end

local function removeESP()
    for player, objects in pairs(espObjects) do if objects.Billboard then objects.Billboard:Destroy() end end
    espObjects = {}
end

local function updateESPStatus()
    if espEnabled then for _, p in pairs(Players:GetPlayers()) do createESP(p) end else removeESP() end
end

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled; espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 180, 255) or C_OFF
    MySettings.espEnabled = espEnabled; SaveConfig(); updateESPStatus()
end)

Players.PlayerAdded:Connect(function(p) if espEnabled then createESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then if espObjects[p].Billboard then espObjects[p].Billboard:Destroy() end; espObjects[p] = nil end
end)

tpButton.MouseButton1Click:Connect(function()
    tpNearestEnabled = not tpNearestEnabled; tpButton.Text = tpNearestEnabled and "TP: ON" or "TP: OFF"
    tpButton.BackgroundColor3 = tpNearestEnabled and C_ON_GRN or C_OFF
    MySettings.tpNearestEnabled = tpNearestEnabled; SaveConfig()
end)

task.spawn(function()
    while true do
        task.wait(0.01)
        if tpNearestEnabled then
            pcall(function()
                local targetPlayer = getClosestPlayer()
                local myChar = LocalPlayer.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if targetPlayer and myHrp then
                    local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if targetHrp then myHrp.CFrame = targetHrp.CFrame end
                end
            end)
        end
    end
end)

LocalPlayer.CharacterAdded:Connect(function(char) 
    task.wait(0.5); checkSafePlatform(); updateESPStatus(); trackWeapon(char) 
end)

if LocalPlayer.Character then trackWeapon(LocalPlayer.Character) end

minimizeButton.MouseButton1Click:Connect(function() frame.Visible = false; openButton.Position = frame.Position; openButton.Visible = true end)
openButton.MouseButton1Click:Connect(function() openButton.Visible = false; frame.Position = openButton.Position; frame.Visible = true end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

checkSafePlatform(); updateESPStatus()
