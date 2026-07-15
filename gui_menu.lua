local SETTINGS_FILE = "JNHHGaming_Config.json"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")

local MySettings = {
    infiniteJumpEnabled = false, safeEnabled = false, tpNearestEnabled = false,
    espEnabled = false, tpaEnabled = false, moveEnabled = false, flingEnabled = false,
    noclipEnabled = false, showSafeSquare = true, tpSizeValue = 50, safeSizeValue = 50,
    fpsBoostEnabled = false, noFogEnabled = false, clickTpEnabled = false,
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
local noclipEnabled, showSafeSquare = MySettings.noclipEnabled, MySettings.showSafeSquare
local fpsBoostEnabled, noFogEnabled, clickTpEnabled = MySettings.fpsBoostEnabled, MySettings.noFogEnabled, MySettings.clickTpEnabled
local tpSizeValue, safeSizeValue = MySettings.tpSizeValue, MySettings.safeSizeValue
local safePart, espObjects, squareTpActive, isAttacking, oldCFrame = nil, {}, false, false, nil

local gui = Instance.new("ScreenGui")
gui.Name = "JNHHGamingCompact"; gui.ResetOnSpawn = false; gui.Parent = LocalPlayer:WaitForChild("PlayerGui")

local frame = Instance.new("Frame")
frame.Name = "CompactFrame"; frame.Size = UDim2.new(0, 340, 0, 330); frame.Position = UDim2.new(0, 50, 0, 50) 
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35); frame.BackgroundTransparency = 0.15
frame.BorderSizePixel = 0; frame.Active = true; frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local openButton = Instance.new("TextButton")
openButton.Name = "OpenButton"; openButton.Size = UDim2.new(0, 90, 0, 35); openButton.Position = UDim2.new(0, 50, 0, 50)
openButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255); openButton.TextColor3 = Color3.new(1, 1, 1)
openButton.Font = Enum.Font.SourceSansBold; openButton.TextSize = 14
openButton.Text = "Mở GUI"; openButton.Visible = false; openButton.Active = true; openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 6)

local function makeDraggable(ui)
    local drag, dragInp, dragStart, startPos, touchObj = false, nil, nil, nil, nil
    ui.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and not drag then
            drag = true; touchObj = input; dragStart = input.Position; startPos = ui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then drag = false; touchObj = nil end end)
        end
    end)
    ui.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and drag then
            if input == touchObj or input.UserInputType == Enum.UserInputType.MouseMovement then dragInp = input end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInp and drag then
            local delta = input.Position - dragStart
            ui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end
makeDraggable(frame); makeDraggable(openButton)

local FONT = Enum.Font.SourceSansBold
local C_OFF = Color3.fromRGB(60, 60, 70)
local C_ON_GRN = Color3.fromRGB(0, 200, 100)

local function createBtn(name, text, w, x, y, color, parent)
    local b = Instance.new("TextButton"); b.Name = name; b.Size = UDim2.new(0, w, 0, 30); b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.Font = FONT; b.TextSize = 13
    b.Text = text; b.Parent = parent; Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6)
    return b
end

-- CỘT 1: CÁC TÍNH NĂNG CHUNG (Mở rộng Y offset để chứa các nút mới)
local jumpBtn = createBtn("jumpBtn", infiniteJumpEnabled and "Inf: ON" or "Inf: OFF", 150, 10, 10, infiniteJumpEnabled and C_ON_GRN or C_OFF, frame)
local noclipBtn = createBtn("noclipBtn", noclipEnabled and "Noclip: ON" or "Noclip: OFF", 150, 10, 45, noclipEnabled and C_ON_GRN or C_OFF, frame)
local espBtn = createBtn("espBtn", espEnabled and "ESP: ON" or "ESP: OFF", 150, 10, 80, espEnabled and Color3.fromRGB(0, 180, 255) or C_OFF, frame)
local flingBtn = createBtn("flingBtn", flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF", 150, 10, 115, flingEnabled and Color3.fromRGB(255, 0, 100) or C_OFF, frame)
local moveBtn = createBtn("moveBtn", moveEnabled and "Move: ON" or "Move: OFF", 150, 10, 150, moveEnabled and C_ON_GRN or C_OFF, frame)
local fpsBtn = createBtn("fpsBtn", fpsBoostEnabled and "FPS: ON" or "FPS: OFF", 150, 10, 185, fpsBoostEnabled and C_ON_GRN or C_OFF, frame)
local fogBtn = createBtn("fogBtn", noFogEnabled and "NoFog: ON" or "NoFog: OFF", 150, 10, 220, noFogEnabled and C_ON_GRN or C_OFF, frame)
local clickTpBtn = createBtn("clickTpBtn", clickTpEnabled and "ClickTP: ON" or "ClickTP: OFF", 150, 10, 255, clickTpEnabled and C_ON_GRN or C_OFF, frame)
local minBtn = createBtn("minBtn", "Thu nhỏ (-)", 150, 10, 290, Color3.fromRGB(200, 50, 50), frame)
-- CỘT 2: HỆ THỐNG MENU THU GỌN 
local col2 = Instance.new("Frame", frame)
col2.Size = UDim2.new(0, 160, 1, -20); col2.Position = UDim2.new(0, 170, 0, 10); col2.BackgroundTransparency = 1
local col2List = Instance.new("UIListLayout", col2); col2List.Padding = UDim.new(0, 5); col2List.SortOrder = Enum.SortOrder.LayoutOrder

local safeMenuBtn = createBtn("sMenuBtn", "▶ Menu SAFE", 160, 0, 0, Color3.fromRGB(80, 80, 90), col2); safeMenuBtn.LayoutOrder = 1
local safeFrame = Instance.new("Frame", col2); safeFrame.BackgroundTransparency = 1; safeFrame.Size = UDim2.new(0, 160, 0, 65); safeFrame.Visible = false; safeFrame.LayoutOrder = 2
local safeBtn = createBtn("safeBtn", safeEnabled and "Safe: ON" or "Safe: OFF", 75, 0, 0, safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF, safeFrame)
local showSafeBtn = createBtn("showSfBtn", showSafeSquare and "BtnSF: ON" or "BtnSF: OFF", 75, 85, 0, showSafeSquare and C_ON_GRN or Color3.fromRGB(200, 50, 50), safeFrame)
local decSfBtn = createBtn("decSfBtn", "SF Size: -", 75, 0, 35, Color3.fromRGB(180, 100, 20), safeFrame)
local incSfBtn = createBtn("incSfBtn", "SF Size: +", 75, 85, 35, Color3.fromRGB(180, 150, 20), safeFrame)

local tpMenuBtn = createBtn("tMenuBtn", "▶ Menu TP", 160, 0, 0, Color3.fromRGB(80, 80, 90), col2); tpMenuBtn.LayoutOrder = 3
local tpFrame = Instance.new("Frame", col2); tpFrame.BackgroundTransparency = 1; tpFrame.Size = UDim2.new(0, 160, 0, 100); tpFrame.Visible = false; tpFrame.LayoutOrder = 4
local tpNearestBtn = createBtn("tpNBtn", tpNearestEnabled and "TP Nrs: ON" or "TP Nrs: OFF", 160, 0, 0, tpNearestEnabled and C_ON_GRN or C_OFF, tpFrame)
local tpaBtn = createBtn("tpaBtn", tpaEnabled and "TPA: ON" or "TPA: OFF", 160, 0, 35, tpaEnabled and Color3.fromRGB(150, 0, 255) or C_OFF, tpFrame)
local decTpBtn = createBtn("decTpBtn", "TP Size: -", 75, 0, 70, Color3.fromRGB(180, 50, 50), tpFrame)
local incTpBtn = createBtn("incTpBtn", "TP Size: +", 75, 85, 70, Color3.fromRGB(50, 180, 50), tpFrame)

-- MENU CUSTOM TP (MỚI)
local customTpMenuBtn = createBtn("cTpMenuBtn", "▶ Menu Cust TP", 160, 0, 0, Color3.fromRGB(80, 80, 90), col2); customTpMenuBtn.LayoutOrder = 5
local customTpFrame = Instance.new("Frame", col2); customTpFrame.BackgroundTransparency = 1; customTpFrame.Size = UDim2.new(0, 160, 0, 180); customTpFrame.Visible = false; customTpFrame.LayoutOrder = 6

local addTpLocBtn = createBtn("addTpLocBtn", "Thêm TP", 75, 0, 0, Color3.fromRGB(0, 150, 255), customTpFrame)
local delTpLocBtn = createBtn("delTpLocBtn", "Xóa TP", 75, 85, 0, Color3.fromRGB(200, 50, 50), customTpFrame)
local decLocBtn = createBtn("decLocBtn", "Size -", 75, 0, 35, Color3.fromRGB(180, 100, 20), customTpFrame)
local incLocBtn = createBtn("incLocBtn", "Size +", 75, 85, 35, Color3.fromRGB(180, 150, 20), customTpFrame)

local tpScroll = Instance.new("ScrollingFrame", customTpFrame)
tpScroll.Size = UDim2.new(0, 160, 0, 105); tpScroll.Position = UDim2.new(0, 0, 0, 70)
tpScroll.BackgroundTransparency = 1; tpScroll.ScrollBarThickness = 4
local tpListLayout = Instance.new("UIListLayout", tpScroll); tpListLayout.Padding = UDim.new(0, 5)

-- LOGIC MỞ RỘNG / THU GỌN MENU CỘT 2 TỰ ĐỘNG CĂN CHỈNH CHIỀU CAO
local isSafeOpen, isTpOpen, isCustomTpOpen = false, false, false
local function updateMainFrameSize()
    local baseHeight = 330
    local col2Height = 10 + 35 + (isSafeOpen and 70 or 0) + 35 + (isTpOpen and 105 or 0) + 35 + (isCustomTpOpen and 185 or 0)
    frame.Size = UDim2.new(0, 340, 0, math.max(baseHeight, col2Height))
end

safeMenuBtn.MouseButton1Click:Connect(function()
    isSafeOpen = not isSafeOpen; safeFrame.Visible = isSafeOpen
    safeMenuBtn.Text = isSafeOpen and "▼ Thu gọn SAFE" or "▶ Menu SAFE"
    safeMenuBtn.BackgroundColor3 = isSafeOpen and Color3.fromRGB(120, 120, 130) or Color3.fromRGB(80, 80, 90)
    updateMainFrameSize()
end)
tpMenuBtn.MouseButton1Click:Connect(function()
    isTpOpen = not isTpOpen; tpFrame.Visible = isTpOpen
    tpMenuBtn.Text = isTpOpen and "▼ Thu gọn TP" or "▶ Menu TP"
    tpMenuBtn.BackgroundColor3 = isTpOpen and Color3.fromRGB(120, 120, 130) or Color3.fromRGB(80, 80, 90)
    updateMainFrameSize()
end)
customTpMenuBtn.MouseButton1Click:Connect(function()
    isCustomTpOpen = not isCustomTpOpen; customTpFrame.Visible = isCustomTpOpen
    customTpMenuBtn.Text = isCustomTpOpen and "▼ Thu gọn C.TP" or "▶ Menu Cust TP"
    customTpMenuBtn.BackgroundColor3 = isCustomTpOpen and Color3.fromRGB(120, 120, 130) or Color3.fromRGB(80, 80, 90)
    updateMainFrameSize()
end)

-- NÚT VUÔNG TP VÀ SAFE
local tpSquare = Instance.new("TextButton"); tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); tpSquare.Position = UDim2.new(MySettings.tpSquareX_Scale, MySettings.tpSquareX_Offset, MySettings.tpSquareY_Scale, MySettings.tpSquareY_Offset) 
tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50); tpSquare.Text = "TP"; tpSquare.TextColor3 = Color3.new(1,1,1); tpSquare.Font = FONT; tpSquare.TextSize = 16; tpSquare.Visible = tpaEnabled; tpSquare.BorderSizePixel = 0; tpSquare.Parent = gui

local safeSquare = Instance.new("TextButton"); safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); safeSquare.Position = UDim2.new(MySettings.safeSquareX_Scale, MySettings.safeSquareX_Offset, MySettings.safeSquareY_Scale, MySettings.safeSquareY_Offset) 
safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0); safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"; safeSquare.TextColor3 = Color3.new(0,0,0); safeSquare.Font = FONT; safeSquare.TextSize = 14; safeSquare.Visible = showSafeSquare; safeSquare.BorderSizePixel = 0; safeSquare.Parent = gui

local function setupSquareDrag(targetUi, settingPrefix)
    local drag, dragInp, dragStart, startPos, touchObj = false, nil, nil, nil, nil
    targetUi.InputBegan:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and moveEnabled and not drag then
            drag = true; touchObj = input; dragStart = input.Position; startPos = targetUi.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    drag = false; touchObj = nil; MySettings[settingPrefix.."X_Scale"] = targetUi.Position.X.Scale; MySettings[settingPrefix.."X_Offset"] = targetUi.Position.X.Offset
                    MySettings[settingPrefix.."Y_Scale"] = targetUi.Position.Y.Scale; MySettings[settingPrefix.."Y_Offset"] = targetUi.Position.Y.Offset; SaveConfig()
                end
            end)
        end
    end)
    targetUi.InputChanged:Connect(function(input)
        if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) and drag and moveEnabled then
            if input == touchObj or input.UserInputType == Enum.UserInputType.MouseMovement then dragInp = input end
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInp and drag and moveEnabled then
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

-- LOGIC TÍNH NĂNG MỚI: CUST TP MENU
local customTpPoints = {}
local miniMenuSize = 30

local function updateScrollCanvas()
    tpScroll.CanvasSize = UDim2.new(0, 0, 0, tpListLayout.AbsoluteContentSize.Y)
end
tpListLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(updateScrollCanvas)

local function updateMiniMenuSizes()
    for _, data in ipairs(customTpPoints) do
        data.Frame.Size = UDim2.new(1, -10, 0, miniMenuSize)
    end
end

decLocBtn.MouseButton1Click:Connect(function() if miniMenuSize > 25 then miniMenuSize = miniMenuSize - 5; updateMiniMenuSizes() end end)
incLocBtn.MouseButton1Click:Connect(function() if miniMenuSize < 50 then miniMenuSize = miniMenuSize + 5; updateMiniMenuSizes() end end)

addTpLocBtn.MouseButton1Click:Connect(function()
    local idx = #customTpPoints + 1
    local pointData = {CFrame = nil}
    
    local miniFrame = Instance.new("Frame", tpScroll)
    miniFrame.Size = UDim2.new(1, -10, 0, miniMenuSize); miniFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    Instance.new("UICorner", miniFrame).CornerRadius = UDim.new(0, 4)
    
    local lbl = Instance.new("TextLabel", miniFrame)
    lbl.Size = UDim2.new(0, 25, 1, 0); lbl.BackgroundTransparency = 1
    lbl.Text = tostring(idx); lbl.TextColor3 = Color3.new(1,1,1); lbl.Font = FONT
    
    local setBtn = createBtn("setBtn", "Set", 55, 30, 0, Color3.fromRGB(0, 150, 200), miniFrame)
    setBtn.Size = UDim2.new(0, 55, 1, 0); Instance.new("UICorner", setBtn).CornerRadius = UDim.new(0, 4)
    
    local tpBtn = createBtn("tpBtn", "TP", 55, 90, 0, Color3.fromRGB(0, 200, 100), miniFrame)
    tpBtn.Size = UDim2.new(0, 55, 1, 0); Instance.new("UICorner", tpBtn).CornerRadius = UDim.new(0, 4)
    
    setBtn.MouseButton1Click:Connect(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp then pointData.CFrame = hrp.CFrame; setBtn.Text = "Đã Set" end
    end)
    
    tpBtn.MouseButton1Click:Connect(function()
        local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
        if hrp and pointData.CFrame then hrp.CFrame = pointData.CFrame end
    end)
    
    pointData.Frame = miniFrame
    table.insert(customTpPoints, pointData)
end)

delTpLocBtn.MouseButton1Click:Connect(function()
    if #customTpPoints > 0 then
        local last = table.remove(customTpPoints, #customTpPoints)
        last.Frame:Destroy()
    end
end)
-- LOGIC TÍNH NĂNG MỚI: FPS BOOST
local function applyFPSBoost(obj)
    if obj:IsA("BasePart") then
        obj.Material = Enum.Material.SmoothPlastic
        obj.Color = Color3.new(1, 1, 1)
        obj.CastShadow = false
    elseif obj:IsA("Decal") or obj:IsA("Texture") then
        obj.Transparency = 1
    end
end

fpsBtn.MouseButton1Click:Connect(function()
    fpsBoostEnabled = not fpsBoostEnabled; fpsBtn.Text = fpsBoostEnabled and "FPS: ON" or "FPS: OFF"
    fpsBtn.BackgroundColor3 = fpsBoostEnabled and C_ON_GRN or C_OFF; MySettings.fpsBoostEnabled = fpsBoostEnabled; SaveConfig()
    
    if fpsBoostEnabled then
        for _, v in pairs(workspace:GetDescendants()) do applyFPSBoost(v) end
        workspace.DescendantAdded:Connect(function(v) if fpsBoostEnabled then applyFPSBoost(v) end end)
    end
end)

-- LOGIC TÍNH NĂNG MỚI: NO FOG
fogBtn.MouseButton1Click:Connect(function()
    noFogEnabled = not noFogEnabled; fogBtn.Text = noFogEnabled and "NoFog: ON" or "NoFog: OFF"
    fogBtn.BackgroundColor3 = noFogEnabled and C_ON_GRN or C_OFF; MySettings.noFogEnabled = noFogEnabled; SaveConfig()
    
    if noFogEnabled then
        Lighting.FogEnd = 100000
        for _, v in pairs(Lighting:GetDescendants()) do if v:IsA("Atmosphere") then v:Destroy() end end
    end
end)

-- LOGIC TÍNH NĂNG MỚI: CLICK TP
local clickTpTool = nil
clickTpBtn.MouseButton1Click:Connect(function()
    clickTpEnabled = not clickTpEnabled; clickTpBtn.Text = clickTpEnabled and "ClickTP: ON" or "ClickTP: OFF"
    clickTpBtn.BackgroundColor3 = clickTpEnabled and C_ON_GRN or C_OFF; MySettings.clickTpEnabled = clickTpEnabled; SaveConfig()
    
    if clickTpEnabled then
        if not clickTpTool then
            clickTpTool = Instance.new("Tool"); clickTpTool.Name = "Click To TP"
            clickTpTool.RequiresHandle = false; clickTpTool.Parent = LocalPlayer.Backpack
            clickTpTool.Activated:Connect(function()
                local mouse = LocalPlayer:GetMouse()
                if mouse.Target then
                    local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                    if hrp then hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
                end
            end)
        end
    else
        if clickTpTool then clickTpTool:Destroy(); clickTpTool = nil end
    end
end)

-- LOGIC ĐI XUYÊN TƯỜNG (NOCLIP) & TÍNH NĂNG CHUNG CÒN LẠI
noclipBtn.MouseButton1Click:Connect(function()
    noclipEnabled = not noclipEnabled; noclipBtn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"
    noclipBtn.BackgroundColor3 = noclipEnabled and C_ON_GRN or C_OFF; MySettings.noclipEnabled = noclipEnabled; SaveConfig()
end)

RunService.Stepped:Connect(function()
    if noclipEnabled and LocalPlayer.Character then
        for _, v in pairs(LocalPlayer.Character:GetDescendants()) do
            if v:IsA("BasePart") and v.CanCollide then v.CanCollide = false end
        end
    end
end)

jumpBtn.MouseButton1Click:Connect(function() 
    infiniteJumpEnabled = not infiniteJumpEnabled; jumpBtn.Text = infiniteJumpEnabled and "Inf: ON" or "Inf: OFF"
    jumpBtn.BackgroundColor3 = infiniteJumpEnabled and C_ON_GRN or C_OFF; MySettings.infiniteJumpEnabled = infiniteJumpEnabled; SaveConfig()
end)

decTpBtn.MouseButton1Click:Connect(function() if tpSizeValue > 30 then tpSizeValue = tpSizeValue - 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end end)
incTpBtn.MouseButton1Click:Connect(function() if tpSizeValue < 150 then tpSizeValue = tpSizeValue + 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end end)
decSfBtn.MouseButton1Click:Connect(function() if safeSizeValue > 30 then safeSizeValue = safeSizeValue - 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end end)
incSfBtn.MouseButton1Click:Connect(function() if safeSizeValue < 150 then safeSizeValue = safeSizeValue + 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end end)

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

safeBtn.MouseButton1Click:Connect(function()
    safeEnabled = not safeEnabled; safeBtn.Text = safeEnabled and "Safe: ON" or "Safe: OFF"
    safeBtn.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF
    safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"; safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0)
    MySettings.safeEnabled = safeEnabled; SaveConfig(); checkSafePlatform()
end)

showSafeBtn.MouseButton1Click:Connect(function()
    showSafeSquare = not showSafeSquare; showSafeBtn.Text = showSafeSquare and "BtnSF: ON" or "BtnSF: OFF"
    showSafeBtn.BackgroundColor3 = showSafeSquare and C_ON_GRN or Color3.fromRGB(200, 50, 50); safeSquare.Visible = showSafeSquare
    MySettings.showSafeSquare = showSafeSquare; SaveConfig()
end)

safeSquare.MouseButton1Click:Connect(function()
    safeEnabled = not safeEnabled; safeBtn.Text = safeEnabled and "Safe: ON" or "Safe: OFF"
    safeBtn.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF
    safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"; safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0)
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

tpaBtn.MouseButton1Click:Connect(function()
    tpaEnabled = not tpaEnabled; tpaBtn.Text = tpaEnabled and "TPA: ON" or "TPA: OFF"
    tpaBtn.BackgroundColor3 = tpaEnabled and Color3.fromRGB(150, 0, 255) or C_OFF; tpSquare.Visible = tpaEnabled
    if not tpaEnabled then squareTpActive = false; tpSquare.Text = "TP"; tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end
    MySettings.tpaEnabled = tpaEnabled; SaveConfig()
end)

moveBtn.MouseButton1Click:Connect(function()
    moveEnabled = not moveEnabled; moveBtn.Text = moveEnabled and "Move: ON" or "Move: OFF"
    moveBtn.BackgroundColor3 = moveEnabled and C_ON_GRN or C_OFF; MySettings.moveEnabled = moveEnabled; SaveConfig()
end)

tpSquare.MouseButton1Click:Connect(function()
    if tpaEnabled then 
        squareTpActive = not squareTpActive
        if squareTpActive then tpSquare.Text = "TP: ON"; tpSquare.BackgroundColor3 = C_ON_GRN else tpSquare.Text = "TP"; tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end
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
                oldCFrame = myHrp.CFrame; isAttacking = true; task.wait(0.2); isAttacking = false
                if oldCFrame then myHrp.CFrame = oldCFrame; myHrp.Velocity = Vector3.new(0, 0, 0); myHrp.RotVelocity = Vector3.new(0, 0, 0); oldCFrame = nil end
            end
        end
    end
end

local toolConnection = nil
local function trackWeapon(character)
    if toolConnection then toolConnection:Disconnect() end
    toolConnection = character.ChildAdded:Connect(function(child) if child:IsA("Tool") then child.Activated:Connect(triggerAttackBlink) end end)
end

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if not gameProcessed and flingEnabled then
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then triggerAttackBlink() end
    end
end)

flingBtn.MouseButton1Click:Connect(function()
    flingEnabled = not flingEnabled; flingBtn.Text = flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF"
    flingBtn.BackgroundColor3 = flingEnabled and Color3.fromRGB(255, 0, 100) or C_OFF; MySettings.flingEnabled = flingEnabled; SaveConfig()
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

espBtn.MouseButton1Click:Connect(function()
    espEnabled = not espEnabled; espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"
    espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 180, 255) or C_OFF
    MySettings.espEnabled = espEnabled; SaveConfig(); updateESPStatus()
end)

Players.PlayerAdded:Connect(function(p) if espEnabled then createESP(p) end end)
Players.PlayerRemoving:Connect(function(p)
    if espObjects[p] then if espObjects[p].Billboard then espObjects[p].Billboard:Destroy() end; espObjects[p] = nil end
end)

tpNearestBtn.MouseButton1Click:Connect(function()
    tpNearestEnabled = not tpNearestEnabled; tpNearestBtn.Text = tpNearestEnabled and "TP Nrs: ON" or "TP Nrs: OFF"
    tpNearestBtn.BackgroundColor3 = tpNearestEnabled and C_ON_GRN or C_OFF; MySettings.tpNearestEnabled = tpNearestEnabled; SaveConfig()
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
    if clickTpEnabled then
        clickTpTool = Instance.new("Tool"); clickTpTool.Name = "Click To TP"
        clickTpTool.RequiresHandle = false; clickTpTool.Parent = LocalPlayer.Backpack
        clickTpTool.Activated:Connect(function()
            local mouse = LocalPlayer:GetMouse()
            if mouse.Target then
                local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
                if hrp then hrp.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end
            end
        end)
    end
end)
if LocalPlayer.Character then trackWeapon(LocalPlayer.Character) end

minBtn.MouseButton1Click:Connect(function() frame.Visible = false; openButton.Position = frame.Position; openButton.Visible = true end)
openButton.MouseButton1Click:Connect(function() openButton.Visible = false; frame.Position = openButton.Position; frame.Visible = true end)

UserInputService.JumpRequest:Connect(function()
    if infiniteJumpEnabled then pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end
end)

checkSafePlatform(); updateESPStatus()
