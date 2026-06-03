-- Fix toàn bộ lỗi crash, tối ưu hóa bộ nhớ cho Executor điện thoại
local SETTINGS_FILE = "JNHHGaming_Config.json"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

local MySettings = {
    speedValue = 50, infiniteJumpEnabled = false, safeEnabled = false,
    tpNearestEnabled = false, espEnabled = false, tpaEnabled = false,
    moveEnabled = false, showSafeSquare = true, chamsEnabled = false,
    hitboxEnabled = false, tpSizeValue = 50, safeSizeValue = 50,
    tpSquareX_Scale = 0.5, tpSquareX_Offset = -55, tpSquareY_Scale = 0.5, tpSquareY_Offset = -25,
    safeSquareX_Scale = 0.5, safeSquareX_Offset = 5, safeSquareY_Scale = 0.5, safeSquareY_Offset = -25
}

local function SaveConfig()
    pcall(function() if writefile then writefile(SETTINGS_FILE, HttpService:JSONEncode(MySettings)) end end)
end
pcall(function()
    if readfile and isfile and isfile(SETTINGS_FILE) then
        local decoded = HttpService:JSONDecode(readfile(SETTINGS_FILE))
        if type(decoded) == "table" then for k, v in pairs(decoded) do MySettings[k] = v end end
    end
end)

local speedValue = MySettings.speedValue
local infiniteJumpEnabled = MySettings.infiniteJumpEnabled
local safeEnabled = MySettings.safeEnabled
local tpNearestEnabled = MySettings.tpNearestEnabled
local espEnabled = MySettings.espEnabled
local tpaEnabled = MySettings.tpaEnabled
local moveEnabled = MySettings.moveEnabled
local showSafeSquare = MySettings.showSafeSquare
local chamsEnabled = MySettings.chamsEnabled
local hitboxEnabled = MySettings.hitboxEnabled
local tpSizeValue = MySettings.tpSizeValue
local safeSizeValue = MySettings.safeSizeValue
local safePart, espObjects, chamsObjects = nil, {}, {}

local gui = Instance.new("ScreenGui")
gui.Name = "JNHHGamingCompact"
gui.ResetOnSpawn = false
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "CompactFrame"
frame.Size = UDim2.new(0, 160, 0, 290)
frame.Position = UDim2.new(0, 50, 0, 50)
frame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
frame.BackgroundTransparency = 0.3
frame.BorderSizePixel = 0
frame.Active = true
frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 80, 0, 30)
openButton.Position = UDim2.new(0, 50, 0, 50)
openButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "Mở GUI"
openButton.Visible = false
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 4)

local function makeDraggable(uiInstance)
    local dragging, dragInput, dragStart, startPos, currentTouchObject = false, nil, nil, nil, nil
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
makeDraggable(frame)
makeDraggable(openButton)

local decreaseButton = Instance.new("TextButton")
decreaseButton.Size = UDim2.new(0, 30, 0, 25)
decreaseButton.Position = UDim2.new(0, 5, 0, 10)
decreaseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
decreaseButton.Text = "-"
decreaseButton.TextColor3 = Color3.new(1, 1, 1)
decreaseButton.Parent = frame
Instance.new("UICorner", decreaseButton).CornerRadius = UDim.new(0, 4)

local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 80, 0, 25)
speedLabel.Position = UDim2.new(0, 40, 0, 10)
speedLabel.BackgroundTransparency = 1
speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Text = "Speed: " .. speedValue
speedLabel.Parent = frame

local increaseButton = Instance.new("TextButton")
increaseButton.Size = UDim2.new(0, 30, 0, 25)
increaseButton.Position = UDim2.new(0, 125, 0, 10)
increaseButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50)
increaseButton.Text = "+"
increaseButton.TextColor3 = Color3.new(1, 1, 1)
increaseButton.Parent = frame
Instance.new("UICorner", increaseButton).CornerRadius = UDim.new(0, 4)

local function createBtn(text, pos, bg)
    local b = Instance.new("TextButton")
    b.Size = UDim2.new(0, 72, 0, 25)
    b.Position = pos
    b.BackgroundColor3 = bg
    b.TextColor3 = Color3.new(1, 1, 1)
    b.Font = Enum.Font.SourceSansBold
    b.TextSize = 12
    b.Text = text
    b.Parent = frame
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 4)
    return b
end

local jumpButton = createBtn(infiniteJumpEnabled and "Inf: ON" or "Inf: OFF", UDim2.new(0, 5, 0, 45), infiniteJumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 120, 255))
local safeButton = createBtn(safeEnabled and "Safe: ON" or "Safe: OFF", UDim2.new(0, 83, 0, 45), safeEnabled and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 255, 0))
safeButton.TextColor3 = Color3.new(0, 0, 0)
local tpButton = createBtn(tpNearestEnabled and "TP: ON" or "TP: OFF", UDim2.new(0, 5, 0, 75), tpNearestEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 100, 0))
local showSafeBtn = createBtn(showSafeSquare and "BtnSF:ON" or "BtnSF:OFF", UDim2.new(0, 83, 0, 75), showSafeSquare and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50))
local espButton = createBtn(espEnabled and "ESP: ON" or "ESP: OFF", UDim2.new(0, 5, 0, 105), espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 150, 255))
local chamsButton = createBtn(chamsEnabled and "Chams:ON" or "Chams:OFF", UDim2.new(0, 83, 0, 105), chamsEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 0, 255))
local tpaButton = createBtn(tpaEnabled and "TPA: ON" or "TPA: OFF", UDim2.new(0, 5, 0, 135), tpaEnabled and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(0, 0, 0))
local hitboxButton = createBtn(hitboxEnabled and "Box: ON" or "Box: OFF", UDim2.new(0, 83, 0, 135), hitboxEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 100))

local moveButton = Instance.new("TextButton")
moveButton.Size = UDim2.new(0, 150, 0, 25)
moveButton.Position = UDim2.new(0, 5, 0, 165)
moveButton.BackgroundColor3 = moveEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(130, 130, 130)
moveButton.TextColor3 = Color3.new(1, 1, 1)
moveButton.Font = Enum.Font.SourceSansBold
moveButton.Text = moveEnabled and "Move: ON" or "Move: OFF"
moveButton.Parent = frame
Instance.new("UICorner", moveButton).CornerRadius = UDim.new(0, 4)

local decreaseSizeButton = createBtn("TP Size:-", UDim2.new(0, 5, 0, 195), Color3.fromRGB(80, 20, 20))
local increaseSizeButton = createBtn("TP Size:+", UDim2.new(0, 83, 0, 195), Color3.fromRGB(20, 80, 20))
local decreaseSafeSizeBtn = createBtn("SF Size:-", UDim2.new(0, 5, 0, 225), Color3.fromRGB(100, 60, 0))
local increaseSafeSizeBtn = createBtn("SF Size:+", UDim2.new(0, 83, 0, 225), Color3.fromRGB(150, 100, 0))

local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 150, 0, 25)
minimizeButton.Position = UDim2.new(0, 5, 0, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Text = "Thu nhỏ (-)"
minimizeButton.Parent = frame
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 4)

local tpSquare = Instance.new("TextButton")
tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue)
tpSquare.Position = UDim2.new(MySettings.tpSquareX_Scale, MySettings.tpSquareX_Offset, MySettings.tpSquareY_Scale, MySettings.tpSquareY_Offset)
tpSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
tpSquare.Text = "TP"; tpSquare.TextColor3 = Color3.new(1, 1, 1)
tpSquare.Font = Enum.Font.SourceSansBold; tpSquare.TextSize = 16
tpSquare.Visible = tpaEnabled; tpSquare.Active = true; tpSquare.BorderSizePixel = 0; tpSquare.Parent = gui

local safeSquare = Instance.new("TextButton")
safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue)
safeSquare.Position = UDim2.new(MySettings.safeSquareX_Scale, MySettings.safeSquareX_Offset, MySettings.safeSquareY_Scale, MySettings.safeSquareY_Offset)
safeSquare.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
safeSquare.Text = "SAFE"; safeSquare.TextColor3 = Color3.new(0, 0, 0)
safeSquare.Font = Enum.Font.SourceSansBold; safeSquare.TextSize = 14
safeSquare.Visible = (safeEnabled and showSafeSquare); safeSquare.Active = true; safeSquare.BorderSizePixel = 0; safeSquare.Parent = gui
local function setupSquareDrag(targetUi, settingPrefix)
    local dragging, dragInput, dragStart, startPos, touchObject = false, nil, nil, nil, nil
    targetUi.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and moveEnabled and not dragging then
            dragging = true; touchObject = input; dragStart = input.Position; startPos = targetUi.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false; touchObject = nil
                    MySettings[settingPrefix.."X_Scale"] = targetUi.Position.X.Scale
                    MySettings[settingPrefix.."X_Offset"] = targetUi.Position.X.Offset
                    MySettings[settingPrefix.."Y_Scale"] = targetUi.Position.Y.Scale
                    MySettings[settingPrefix.."Y_Offset"] = targetUi.Position.Y.Offset
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
setupSquareDrag(tpSquare, "tpSquare")
setupSquareDrag(safeSquare, "safeSquare")

local function getClosestPlayer()
    local closestPlayer, shortestDistance = nil, math.huge
    local myChar = LocalPlayer.Character
    local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
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

decreaseButton.MouseButton1Click:Connect(function() if speedValue > 16 then speedValue = speedValue - 5; speedLabel.Text = "Speed: "..speedValue; MySettings.speedValue = speedValue; SaveConfig() end end)
increaseButton.MouseButton1Click:Connect(function() if speedValue < 500 then speedValue = speedValue + 5; speedLabel.Text = "Speed: "..speedValue; MySettings.speedValue = speedValue; SaveConfig() end end)
jumpButton.MouseButton1Click:Connect(function() infiniteJumpEnabled = not infiniteJumpEnabled; jumpButton.Text = infiniteJumpEnabled and "Inf: ON" or "Inf: OFF"; jumpButton.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 120, 255); MySettings.infiniteJumpEnabled = infiniteJumpEnabled; SaveConfig() end)
decreaseSizeButton.MouseButton1Click:Connect(function() if tpSizeValue > 30 then tpSizeValue = tpSizeValue - 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end end)
increaseSizeButton.MouseButton1Click:Connect(function() if tpSizeValue < 150 then tpSizeValue = tpSizeValue + 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end end)
decreaseSafeSizeBtn.MouseButton1Click:Connect(function() if safeSizeValue > 30 then safeSizeValue = safeSizeValue - 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end end)
increaseSafeSizeBtn.MouseButton1Click:Connect(function() if safeSizeValue < 150 then safeSizeValue = safeSizeValue + 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end end)

local function checkSafePlatform()
    if safeEnabled then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and (not safePart or not safePart.Parent) then
            safePart = Instance.new("Part"); safePart.Size = Vector3.new(20, 1, 20)
            safePart.Position = Vector3.new(hrp.Position.X, hrp.Position.Y + 300, hrp.Position.Z)
            safePart.Anchored = true; safePart.BrickColor = BrickColor.new("White"); safePart.Parent = workspace
            hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0))
        end
    else if safePart then safePart:Destroy(); safePart = nil end end
end

safeButton.MouseButton1Click:Connect(function() safeEnabled = not safeEnabled; safeButton.Text = safeEnabled and "Safe: ON" or "Safe: OFF"; safeButton.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 255, 0); safeSquare.Visible = (safeEnabled and showSafeSquare); MySettings.safeEnabled = safeEnabled; SaveConfig(); checkSafePlatform() end)
showSafeBtn.MouseButton1Click:Connect(function() showSafeSquare = not showSafeSquare; showSafeBtn.Text = showSafeSquare and "BtnSF:ON" or "BtnSF:OFF"; showSafeBtn.BackgroundColor3 = showSafeSquare and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50); safeSquare.Visible = (safeEnabled and showSafeSquare); MySettings.showSafeSquare = showSafeSquare; SaveConfig() end)
safeSquare.MouseButton1Click:Connect(function() if safeEnabled and safePart then local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp then hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end end end)
tpaButton.MouseButton1Click:Connect(function() tpaEnabled = not tpaEnabled; tpaButton.Text = tpaEnabled and "TPA: ON" or "TPA: OFF"; tpaButton.BackgroundColor3 = tpaEnabled and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(0, 0, 0); tpSquare.Visible = tpaEnabled; MySettings.tpaEnabled = tpaEnabled; SaveConfig() end)
moveButton.MouseButton1Click:Connect(function() moveEnabled = not moveEnabled; moveButton.Text = moveEnabled and "Move: ON" or "Move: OFF"; moveButton.BackgroundColor3 = moveEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(130, 130, 130); MySettings.moveEnabled = moveEnabled; SaveConfig() end)
tpSquare.MouseButton1Click:Connect(function() if tpaEnabled then pcall(function() local targetPlayer = getClosestPlayer(); local myChar = LocalPlayer.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart"); if targetPlayer and myHrp then local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart"); if targetHrp then myHrp.CFrame = targetHrp.CFrame end end end) end end)

local function createESP(player)
    if player == LocalPlayer then return end
    local function applyESP(character)
        task.wait(0.5); if not espEnabled then return end
        local head = character:WaitForChild("Head", 5); if not head or head:FindFirstChild("ESP_Billboard") then return end
        local billboard = Instance.new("BillboardGui"); billboard.Name = "ESP_Billboard"; billboard.Size = UDim2.new(0, 200, 0, 50); billboard.AlwaysOnTop = true; billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.Parent = head
        local nameLabel = Instance.new("TextLabel"); nameLabel.Size = UDim2.new(1, 0, 1, 0); nameLabel.BackgroundTransparency = 1; nameLabel.Text = player.Name; nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0); nameLabel.TextStrokeTransparency = 0; nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0); nameLabel.Font = Enum.Font.SourceSansBold; nameLabel.TextSize = 18; nameLabel.Parent = billboard
        espObjects[player] = {Billboard = billboard}
    end
    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(applyESP)
end
local function removeESP() for p, o in pairs(espObjects) do if o.Billboard then o.Billboard:Destroy() end end; espObjects = {} end
local function updateESPStatus() if espEnabled then for _, p in pairs(Players:GetPlayers()) do createESP(p) end else removeESP() end end
espButton.MouseButton1Click:Connect(function() espEnabled = not espEnabled; espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"; espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 150, 255); MySettings.espEnabled = espEnabled; SaveConfig(); updateESPStatus() end)

local function createChams(player)
    if player == LocalPlayer then return end
    local function applyChams(character)
        task.wait(0.5); if not chamsEnabled then return end
        if character:FindFirstChild("Chams_Highlight") then return end
        local h = Instance.new("Highlight"); h.Name = "Chams_Highlight"; h.FillColor = Color3.fromRGB(255, 0, 0); h.OutlineColor = Color3.fromRGB(255, 255, 255); h.FillTransparency = 0.5; h.OutlineTransparency = 0; h.Adornee = character; h.Parent = character
        chamsObjects[player] = h
    end
    if player.Character then applyChams(player.Character) end
    player.CharacterAdded:Connect(applyChams)
end
local function removeChams() for p, h in pairs(chamsObjects) do if h and h.Parent then h:Destroy() end end; chamsObjects = {} end
local function updateChamsStatus() if chamsEnabled then for _, p in pairs(Players:GetPlayers()) do createChams(p) end else removeChams() end end
chamsButton.MouseButton1Click:Connect(function() chamsEnabled = not chamsEnabled; chamsButton.Text = chamsEnabled and "Chams:ON" or "Chams:OFF"; chamsButton.BackgroundColor3 = chamsEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(150, 0, 255); MySettings.chamsEnabled = chamsEnabled; SaveConfig(); updateChamsStatus() end)

hitboxButton.MouseButton1Click:Connect(function() hitboxEnabled = not hitboxEnabled; hitboxButton.Text = hitboxEnabled and "Box: ON" or "Box: OFF"; hitboxButton.BackgroundColor3 = hitboxEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 0, 100); MySettings.hitboxEnabled = hitboxEnabled; SaveConfig() end)
tpButton.MouseButton1Click:Connect(function() tpNearestEnabled = not tpNearestEnabled; tpButton.Text = tpNearestEnabled and "TP: ON" or "TP: OFF"; tpButton.BackgroundColor3 = tpNearestEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 100, 0); MySettings.tpNearestEnabled = tpNearestEnabled; SaveConfig() end)

task.spawn(function()
    while true do
        task.wait(0.1)
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local hrp = p.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then
                        if hitboxEnabled then
                            hrp.Size = Vector3.new(10, 10, 10)
                            hrp.Transparency = 0.7; hrp.BrickColor = BrickColor.new("Really red")
                            hrp.Material = Enum.Material.ForceField; hrp.CanCollide = false
                        else
                            hrp.Size = Vector3.new(2, 2, 1); hrp.Transparency = 1; hrp.CanCollide = false
                        end
                    end
                end
            end
        end)
        if tpNearestEnabled then
            pcall(function()
                local targetPlayer = getClosestPlayer(); local myChar = LocalPlayer.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
                if targetPlayer and myHrp then local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart"); if targetHrp then myHrp.CFrame = targetHrp.CFrame end end
            end)
        end
    end
end)

task.spawn(function()
    while true do
        task.wait(0.5)
        if safeEnabled and safePart and safePart.Parent then
            pcall(function()
                local char = LocalPlayer.Character; local hrp = char and char:FindFirstChild("HumanoidRootPart")
                if hrp and hrp.Position.Y < (safePart.Position.Y - 10) then hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end
            end)
        end
    end
end)

Players.PlayerAdded:Connect(function(p) if espEnabled then createESP(p) end; if chamsEnabled then createChams(p) end end)
Players.PlayerRemoving:Connect(function(p) pcall(function() if espObjects[p] and espObjects[p].Billboard then espObjects[p].Billboard:Destroy() end; espObjects[p] = nil; if chamsObjects[p] then chamsObjects[p]:Destroy(); chamsObjects[p] = nil end end) end)
LocalPlayer.CharacterAdded:Connect(function() task.wait(0.5); checkSafePlatform(); updateESPStatus(); updateChamsStatus() end)
minimizeButton.MouseButton1Click:Connect(function() frame.Visible = false; openButton.Position = frame.Position; openButton.Visible = true end)
openButton.MouseButton1Click:Connect(function() openButton.Visible = false; frame.Position = openButton.Position; frame.Visible = true end)
UserInputService.JumpRequest:Connect(function() if infiniteJumpEnabled then pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end)
task.spawn(function() while true do pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = speedValue end); task.wait(0.1) end end)

checkSafePlatform(); updateESPStatus(); updateChamsStatus()
    
