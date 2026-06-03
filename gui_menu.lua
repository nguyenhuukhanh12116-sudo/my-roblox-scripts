-- Tên file lưu trữ trong thư mục workspace của Exploit
local SETTINGS_FILE = "JNHHGaming_Config.json"

-- Các dịch vụ hệ thống cần dùng
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")

-- Khởi tạo bảng Settings mặc định
local MySettings = {
    speedValue = 50,
    infiniteJumpEnabled = false,
    safeEnabled = false,
    tpNearestEnabled = false,
    espEnabled = false,
    tpaEnabled = false,
    moveEnabled = false,
    flingEnabled = false,
    showSafeSquare = true,
    tpSizeValue = 50,
    safeSizeValue = 50,
    tpSquareX_Scale = 0.5, tpSquareX_Offset = -55,
    tpSquareY_Scale = 0.5, tpSquareY_Offset = -25,
    safeSquareX_Scale = 0.5, safeSquareX_Offset = 5,
    safeSquareY_Scale = 0.5, safeSquareY_Offset = -25
}

-- HÀM LƯU CONFIG
local function SaveConfig()
    local success, encoded = pcall(function() return HttpService:JSONEncode(MySettings) end)
    if success and writefile then writefile(SETTINGS_FILE, encoded) end
end

-- HÀM TẢI CONFIG
local function LoadConfig()
    if readfile and isfile and isfile(SETTINGS_FILE) then
        local success, decoded = pcall(function() return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
        if success and type(decoded) == "table" then
            for k, v in pairs(decoded) do MySettings[k] = v end
        end
    end
end

LoadConfig()

local speedValue = MySettings.speedValue
local infiniteJumpEnabled = MySettings.infiniteJumpEnabled
local safeEnabled = MySettings.safeEnabled
local tpNearestEnabled = MySettings.tpNearestEnabled
local espEnabled = MySettings.espEnabled
local tpaEnabled = MySettings.tpaEnabled
local moveEnabled = MySettings.moveEnabled
local flingEnabled = MySettings.flingEnabled
local showSafeSquare = MySettings.showSafeSquare
local tpSizeValue = MySettings.tpSizeValue
local safeSizeValue = MySettings.safeSizeValue
local safePart = nil 
local espObjects = {}
local squareTpActive = false 
local isAttacking = false -- Biến kiểm tra trạng thái đang vung đòn tấn công

-- Create GUI
local gui = Instance.new("ScreenGui")
gui.Name = "JNHHGamingCompact"
gui.ResetOnSpawn = false 
gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

-- Bảng Main
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

-- Nút Mở GUI
local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"
openButton.Size = UDim2.new(0, 80, 0, 30)
openButton.Position = UDim2.new(0, 50, 0, 50)
openButton.BackgroundColor3 = Color3.fromRGB(0, 120, 255)
openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Text = "Mở GUI"
openButton.Visible = false 
openButton.Active = true
openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 4)

-- HỆ THỐNG DRAG MENU
local function makeDraggable(uiInstance)
    local dragging = false; local dragInput, dragStart, startPos; local currentTouchObject = nil
    uiInstance.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not dragging then
            dragging = true; currentTouchObject = input; dragStart = input.Position; startPos = uiInstance.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false; currentTouchObject = nil end
            end)
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

-- Nút giảm WalkSpeed (-)
local decreaseButton = Instance.new("TextButton")
decreaseButton.Size = UDim2.new(0, 30, 0, 25); decreaseButton.Position = UDim2.new(0, 5, 0, 10)
decreaseButton.BackgroundColor3 = Color3.fromRGB(255, 50, 50); decreaseButton.TextColor3 = Color3.new(1, 1, 1)
decreaseButton.Text = "-"; decreaseButton.Parent = frame
Instance.new("UICorner", decreaseButton).CornerRadius = UDim.new(0, 4)

-- Label Tốc độ WalkSpeed
local speedLabel = Instance.new("TextLabel")
speedLabel.Size = UDim2.new(0, 80, 0, 25); speedLabel.Position = UDim2.new(0, 40, 0, 10)
speedLabel.BackgroundTransparency = 1; speedLabel.TextColor3 = Color3.new(1, 1, 1)
speedLabel.Text = "Speed: " .. speedValue; speedLabel.Parent = frame

-- Nút tăng WalkSpeed (+)
local increaseButton = Instance.new("TextButton")
increaseButton.Size = UDim2.new(0, 30, 0, 25); increaseButton.Position = UDim2.new(0, 125, 0, 10)
increaseButton.BackgroundColor3 = Color3.fromRGB(50, 255, 50); increaseButton.TextColor3 = Color3.new(1, 1, 1)
increaseButton.Text = "+"; increaseButton.Parent = frame
Instance.new("UICorner", increaseButton).CornerRadius = UDim.new(0, 4)

-- HÀNG 1: Inf Jump & Safe Base
local jumpButton = Instance.new("TextButton")
jumpButton.Size = UDim2.new(0, 72, 0, 25); jumpButton.Position = UDim2.new(0, 5, 0, 45)
jumpButton.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 120, 255)
jumpButton.TextColor3 = Color3.new(1, 1, 1); jumpButton.Font = Enum.Font.SourceSansBold; jumpButton.TextSize = 13
jumpButton.Text = infiniteJumpEnabled and "Inf: ON" or "Inf: OFF"; jumpButton.Parent = frame
Instance.new("UICorner", jumpButton).CornerRadius = UDim.new(0, 4)

local safeButton = Instance.new("TextButton")
safeButton.Size = UDim2.new(0, 72, 0, 25); safeButton.Position = UDim2.new(0, 83, 0, 45)
safeButton.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 255, 0)
safeButton.TextColor3 = Color3.new(0, 0, 0); safeButton.Font = Enum.Font.SourceSansBold; safeButton.TextSize = 13
safeButton.Text = safeEnabled and "Safe: ON" or "Safe: OFF"; safeButton.Parent = frame
Instance.new("UICorner", safeButton).CornerRadius = UDim.new(0, 4)

-- HÀNG 2: TP & Nút bật/tắt nút Safe
local tpButton = Instance.new("TextButton")
tpButton.Size = UDim2.new(0, 72, 0, 25); tpButton.Position = UDim2.new(0, 5, 0, 75)
tpButton.BackgroundColor3 = tpNearestEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 100, 0)
tpButton.TextColor3 = Color3.new(1, 1, 1); tpButton.Font = Enum.Font.SourceSansBold; tpButton.TextSize = 13
tpButton.Text = tpNearestEnabled and "TP: ON" or "TP: OFF"; tpButton.Parent = frame
Instance.new("UICorner", tpButton).CornerRadius = UDim.new(0, 4)

local showSafeBtn = Instance.new("TextButton")
showSafeBtn.Size = UDim2.new(0, 72, 0, 25); showSafeBtn.Position = UDim2.new(0, 83, 0, 75)
showSafeBtn.BackgroundColor3 = showSafeSquare and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
showSafeBtn.TextColor3 = Color3.new(1, 1, 1); showSafeBtn.Font = Enum.Font.SourceSansBold; showSafeBtn.TextSize = 11
showSafeBtn.Text = showSafeSquare and "BtnSF:ON" or "BtnSF:OFF"; showSafeBtn.Parent = frame
Instance.new("UICorner", showSafeBtn).CornerRadius = UDim.new(0, 4)

-- HÀNG 3: ESP
local espButton = Instance.new("TextButton")
espButton.Size = UDim2.new(0, 150, 0, 25); espButton.Position = UDim2.new(0, 5, 0, 105)
espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 150, 255)
espButton.TextColor3 = Color3.new(1, 1, 1); espButton.Font = Enum.Font.SourceSansBold; espButton.TextSize = 14
espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"; espButton.Parent = frame
Instance.new("UICorner", espButton).CornerRadius = UDim.new(0, 4)

-- HÀNG 4: TPA & Move
local tpaButton = Instance.new("TextButton")
tpaButton.Size = UDim2.new(0, 72, 0, 25); tpaButton.Position = UDim2.new(0, 5, 0, 135)
tpaButton.BackgroundColor3 = tpaEnabled and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(0, 0, 0)
tpaButton.TextColor3 = Color3.new(1, 1, 1); tpaButton.Font = Enum.Font.SourceSansBold; tpaButton.TextSize = 13
tpaButton.Text = tpaEnabled and "TPA: ON" or "TPA: OFF"; tpaButton.Parent = frame
Instance.new("UICorner", tpaButton).CornerRadius = UDim.new(0, 4)

local moveButton = Instance.new("TextButton")
moveButton.Size = UDim2.new(0, 72, 0, 25); moveButton.Position = UDim2.new(0, 83, 0, 135)
moveButton.BackgroundColor3 = moveEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(130, 130, 130)
moveButton.TextColor3 = Color3.new(1, 1, 1); moveButton.Font = Enum.Font.SourceSansBold; moveButton.TextSize = 13
moveButton.Text = moveEnabled and "Move: ON" or "Move: OFF"; moveButton.Parent = frame
Instance.new("UICorner", moveButton).CornerRadius = UDim.new(0, 4)

-- HÀNG 5: Chỉnh Size TP
local decreaseSizeButton = Instance.new("TextButton")
decreaseSizeButton.Size = UDim2.new(0, 72, 0, 25); decreaseSizeButton.Position = UDim2.new(0, 5, 0, 165)
decreaseSizeButton.BackgroundColor3 = Color3.fromRGB(80, 20, 20); decreaseSizeButton.TextColor3 = Color3.new(1, 1, 1)
decreaseSizeButton.Font = Enum.Font.SourceSansBold; decreaseSizeButton.Text = "TP Size:-"; decreaseSizeButton.Parent = frame
Instance.new("UICorner", decreaseSizeButton).CornerRadius = UDim.new(0, 4)

local increaseSizeButton = Instance.new("TextButton")
increaseSizeButton.Size = UDim2.new(0, 72, 0, 25); increaseSizeButton.Position = UDim2.new(0, 83, 0, 165)
increaseSizeButton.BackgroundColor3 = Color3.fromRGB(20, 80, 20); increaseSizeButton.TextColor3 = Color3.new(1, 1, 1)
increaseSizeButton.Font = Enum.Font.SourceSansBold; increaseSizeButton.Text = "TP Size:+"; increaseSizeButton.Parent = frame
Instance.new("UICorner", increaseSizeButton).CornerRadius = UDim.new(0, 4)

-- HÀNG 6: Chỉnh Size SAFE
local decreaseSafeSizeBtn = Instance.new("TextButton")
decreaseSafeSizeBtn.Size = UDim2.new(0, 72, 0, 25); decreaseSafeSizeBtn.Position = UDim2.new(0, 5, 0, 195)
decreaseSafeSizeBtn.BackgroundColor3 = Color3.fromRGB(100, 60, 0); decreaseSafeSizeBtn.TextColor3 = Color3.new(1, 1, 1)
decreaseSafeSizeBtn.Font = Enum.Font.SourceSansBold; decreaseSafeSizeBtn.Text = "SF Size:-"; decreaseSafeSizeBtn.Parent = frame
Instance.new("UICorner", decreaseSafeSizeBtn).CornerRadius = UDim.new(0, 4)

local increaseSafeSizeBtn = Instance.new("TextButton")
increaseSafeSizeBtn.Size = UDim2.new(0, 72, 0, 25); increaseSafeSizeBtn.Position = UDim2.new(0, 83, 0, 195)
increaseSafeSizeBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 0); increaseSafeSizeBtn.TextColor3 = Color3.new(1, 1, 1)
increaseSafeSizeBtn.Font = Enum.Font.SourceSansBold; increaseSafeSizeBtn.Text = "SF Size:+"; increaseSafeSizeBtn.Parent = frame
Instance.new("UICorner", increaseSafeSizeBtn).CornerRadius = UDim.new(0, 4)

-- HÀNG 7: NÚT ATK FLING (Tấn công hất tung)
local flingButton = Instance.new("TextButton")
flingButton.Size = UDim2.new(0, 150, 0, 25); flingButton.Position = UDim2.new(0, 5, 0, 225)
flingButton.BackgroundColor3 = flingEnabled and Color3.fromRGB(200, 0, 200) or Color3.fromRGB(100, 0, 100)
flingButton.TextColor3 = Color3.new(1, 1, 1); flingButton.Font = Enum.Font.SourceSansBold; flingButton.TextSize = 14
flingButton.Text = flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF"; flingButton.Parent = frame
Instance.new("UICorner", flingButton).CornerRadius = UDim.new(0, 4)

-- HÀNG 8: Nút Thu nhỏ
local minimizeButton = Instance.new("TextButton")
minimizeButton.Size = UDim2.new(0, 150, 0, 25); minimizeButton.Position = UDim2.new(0, 5, 0, 255)
minimizeButton.BackgroundColor3 = Color3.fromRGB(200, 50, 50); minimizeButton.TextColor3 = Color3.new(1, 1, 1)
minimizeButton.Text = "Thu nhỏ (-)"; minimizeButton.Parent = frame
Instance.new("UICorner", minimizeButton).CornerRadius = UDim.new(0, 4)

-- TẠO NÚT VUÔNG TP
local tpSquare = Instance.new("TextButton")
tpSquare.Name = "TPSquareButton"; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue)
tpSquare.Position = UDim2.new(MySettings.tpSquareX_Scale, MySettings.tpSquareX_Offset, MySettings.tpSquareY_Scale, MySettings.tpSquareY_Offset) 
tpSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0); tpSquare.Text = "TP"
tpSquare.TextColor3 = Color3.new(1, 1, 1); tpSquare.Font = Enum.Font.SourceSansBold; tpSquare.TextSize = 16
tpSquare.Visible = tpaEnabled; tpSquare.Active = true; tpSquare.BorderSizePixel = 0; tpSquare.Parent = gui

-- TẠO NÚT VUÔNG SAFE
local safeSquare = Instance.new("TextButton")
safeSquare.Name = "SafeSquareButton"; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue)
safeSquare.Position = UDim2.new(MySettings.safeSquareX_Scale, MySettings.safeSquareX_Offset, MySettings.safeSquareY_Scale, MySettings.safeSquareY_Offset) 
safeSquare.BackgroundColor3 = Color3.fromRGB(255, 200, 0); safeSquare.Text = "SAFE"
safeSquare.TextColor3 = Color3.new(0, 0, 0); safeSquare.Font = Enum.Font.SourceSansBold; safeSquare.TextSize = 14
safeSquare.Visible = (safeEnabled and showSafeSquare); safeSquare.Active = true; safeSquare.BorderSizePixel = 0; safeSquare.Parent = gui

-- HỆ THỐNG KÉO THẢ NÚT VUÔNG
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

decreaseButton.MouseButton1Click:Connect(function() 
    if speedValue > 16 then speedValue = speedValue - 5; speedLabel.Text = "Speed: "..speedValue; MySettings.speedValue = speedValue; SaveConfig() end 
end)

increaseButton.MouseButton1Click:Connect(function() 
    if speedValue < 500 then speedValue = speedValue + 5; speedLabel.Text = "Speed: "..speedValue; MySettings.speedValue = speedValue; SaveConfig() end 
end)

jumpButton.MouseButton1Click:Connect(function() 
    infiniteJumpEnabled = not infiniteJumpEnabled; jumpButton.Text = infiniteJumpEnabled and "Inf: ON" or "Inf: OFF"
    jumpButton.BackgroundColor3 = infiniteJumpEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 120, 255)
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
    safeEnabled = not safeEnabled; safeButton.Text = safeEnabled and "Safe: ON" or "Safe: OFF"
    safeButton.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 200, 0) or Color3.fromRGB(255, 255, 0)
    safeSquare.Visible = (safeEnabled and showSafeSquare)
    MySettings.safeEnabled = safeEnabled; SaveConfig(); checkSafePlatform()
end)

showSafeBtn.MouseButton1Click:Connect(function()
    showSafeSquare = not showSafeSquare; showSafeBtn.Text = showSafeSquare and "BtnSF:ON" or "BtnSF:OFF"
    showSafeBtn.BackgroundColor3 = showSafeSquare and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(200, 50, 50)
    safeSquare.Visible = (safeEnabled and showSafeSquare); MySettings.showSafeSquare = showSafeSquare; SaveConfig()
end)

safeSquare.MouseButton1Click:Connect(function()
    if safeEnabled and safePart then
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end
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
    tpaButton.BackgroundColor3 = tpaEnabled and Color3.fromRGB(50, 50, 50) or Color3.fromRGB(0, 0, 0); tpSquare.Visible = tpaEnabled
    if not tpaEnabled then squareTpActive = false; tpSquare.Text = "TP"; tpSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0) end
    MySettings.tpaEnabled = tpaEnabled; SaveConfig()
end)

moveButton.MouseButton1Click:Connect(function()
    moveEnabled = not moveEnabled; moveButton.Text = moveEnabled and "Move: ON" or "Move: OFF"
    moveButton.BackgroundColor3 = moveEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(130, 130, 130)
    MySettings.moveEnabled = moveEnabled; SaveConfig()
end)

tpSquare.MouseButton1Click:Connect(function()
    if tpaEnabled then 
        squareTpActive = not squareTpActive
        if squareTpActive then
            tpSquare.Text = "TP: ON"; tpSquare.BackgroundColor3 = Color3.fromRGB(0, 200, 100) 
        else
            tpSquare.Text = "TP"; tpSquare.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
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

-- LOGIC KIỂM TRA CLICK CHUỘT / VUNG VŨ KHÍ ĐỂ FLING
local toolConnection = nil
local function trackWeapon(character)
    if toolConnection then toolConnection:Disconnect() end
    toolConnection = character.ChildAdded:Connect(function(child)
        if child:IsA("Tool") then
            child.Activated:Connect(function()
                if flingEnabled and not isAttacking then
                    isAttacking = true
                    task.wait(0.3) -- Duy trì lực hất tung trong 0.3 giây khi vung vũ khí
                    isAttacking = false
                end
            end)
        end
    end)
end

-- Lắng nghe cả hành động click chuột tự do từ người chơi (Phòng trường hợp vũ khí dạng Script ẩn)
UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and flingEnabled then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            if not isAttacking then
                isAttacking = true
                task.wait(0.3)
                isAttacking = false
            end
        end
    end
end)

flingButton.MouseButton1Click:Connect(function()
    flingEnabled = not flingEnabled
    flingButton.Text = flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF"
    flingButton.BackgroundColor3 = flingEnabled and Color3.fromRGB(200, 0, 200) or Color3.fromRGB(100, 0, 100)
    MySettings.flingEnabled = flingEnabled; SaveConfig()
end)

-- VÒNG LẶP ĐẨY LỰC KHI ĐANG TẤN CÔNG (CanCollide bypass)
RunService.Stepped:Connect(function()
    if flingEnabled and isAttacking then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                for _, v in pairs(char:GetChildren()) do
                    if v:IsA("BasePart") then v.CanCollide = true end
                end
                -- Tạo vận tốc hất văng cực mạnh lên cao
                char.HumanoidRootPart.Velocity = Vector3.new(0, 60000, 0)
                char.HumanoidRootPart.RotVelocity = Vector3.new(60000, 60000, 60000)
            end
        end)
    end
end)

RunService.Heartbeat:Connect(function()
    if flingEnabled then
        pcall(function()
            local char = LocalPlayer.Character
            if char and char:FindFirstChild("HumanoidRootPart") then
                -- Nếu không trong trạng thái vung đòn, ghim cơ thể đứng yên ổn định
                if not isAttacking then
                    char.HumanoidRootPart.Velocity = Vector3.new(0, 0, 0)
                    char.HumanoidRootPart.RotVelocity = Vector3.new(0, 0, 0)
                end
            end
        end)
    end
end)

local function createESP(player)
    if player == LocalPlayer then return end
    local function applyESP(character)
        task.wait(0.5); if not espEnabled then return end
        local head = character:WaitForChild("Head", 5); if not head then return end
        local billboard = Instance.new("BillboardGui"); billboard.Name = "ESP_Billboard"
        billboard.Size = UDim2.new(0, 200, 0, 50); billboard.AlwaysOnTop = true
        billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.Parent = head
        local nameLabel = Instance.new("TextLabel"); nameLabel.Size = UDim2.new(1, 0, 1, 0)
        nameLabel.BackgroundTransparency = 1; nameLabel.Text = player.Name
        nameLabel.TextColor3 = Color3.fromRGB(255, 0, 0); nameLabel.TextStrokeTransparency = 0; nameLabel.TextStrokeColor3 = Color3.new(0, 0, 0)
        nameLabel.Font = Enum.Font.SourceSansBold; nameLabel.TextSize = 18; nameLabel.Parent = billboard
        espObjects[player] = {Billboard = billboard}
    end
    if player.Character then applyESP(player.Character) end
    player.CharacterAdded:Connect(applyESP)
end

local function removeESP()
    for player, objects in pairs(espObjects) do
        if objects.Billboard then objects.Billboard:Destroy() end
    end
    espObjects = {}
end

local function updateESPStatus()
    if espEnabled then for _, p in pairs(Players:GetPlayers()) do createESP(p) end else removeESP() end
end

espButton.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled; espButton.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espButton.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(0, 150, 255)
    MySettings.espEnabled = espEnabled; SaveConfig(); updateESPStatus()
end)

Players.PlayerAdded:Connect(function(p) if espEnabled then createESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then
        if espObjects[p].Billboard then espObjects[p].Billboard:Destroy() end; espObjects[p] = nil
    end
end)

tpButton.MouseButton1Click:Connect(function()
    tpNearestEnabled = not tpNearestEnabled; tpButton.Text = tpNearestEnabled and "TP: ON" or "TP: OFF"
    tpButton.BackgroundColor3 = tpNearestEnabled and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(255, 100, 0)
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

game:GetService("UserInputService").JumpRequest:Connect(function()
    if infiniteJumpEnabled then pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

task.spawn(function()
    while true do
        pcall(function() LocalPlayer.Character.Humanoid.WalkSpeed = speedValue end)
        task.wait(0.1)
    end
end)

checkSafePlatform(); updateESPStatus()
