local SETTINGS_FILE = "JNHHGaming_ConfigV2.json"
local Players = game:GetService("Players")
local LocalPlayer = Players.LocalPlayer
local UserInputService = game:GetService("UserInputService")
local RunService = game:GetService("RunService")
local HttpService = game:GetService("HttpService")
local Lighting = game:GetService("Lighting")
local CoreGui = game:GetService("CoreGui")

local MySettings = {
    infiniteJumpEnabled = false, safeEnabled = false, tpNearestEnabled = false,
    espEnabled = false, tpaEnabled = false, moveEnabled = false, flingEnabled = false,
    noclipEnabled = false, showSafeSquare = true, tpSizeValue = 50, safeSizeValue = 50,
    fpsBoostEnabled = false, noFogEnabled = false, clickTpEnabled = false, floatTpSizeValue = 80,
    tpSquareX_Scale = 0.5, tpSquareX_Offset = -55, tpSquareY_Scale = 0.5, tpSquareY_Offset = -25,
    safeSquareX_Scale = 0.5, safeSquareX_Offset = 5, safeSquareY_Scale = 0.5, safeSquareY_Offset = -25,
    autoRollEnabled = false, tpManagerData = {}
}

local function SaveConfig() pcall(function() if writefile then writefile(SETTINGS_FILE, HttpService:JSONEncode(MySettings)) end end) end
local function LoadConfig()
    if readfile and isfile and isfile(SETTINGS_FILE) then
        local s, d = pcall(function() return HttpService:JSONDecode(readfile(SETTINGS_FILE)) end)
        if s and type(d) == "table" then for k, v in pairs(d) do MySettings[k] = v end end
    end
end
LoadConfig()

local infiniteJumpEnabled, safeEnabled, tpNearestEnabled = MySettings.infiniteJumpEnabled, MySettings.safeEnabled, MySettings.tpNearestEnabled
local espEnabled, tpaEnabled, moveEnabled, flingEnabled = MySettings.espEnabled, MySettings.tpaEnabled, MySettings.moveEnabled, MySettings.flingEnabled
local noclipEnabled, showSafeSquare, autoRollEnabled = MySettings.noclipEnabled, MySettings.showSafeSquare, MySettings.autoRollEnabled
local fpsBoostEnabled, noFogEnabled, clickTpEnabled = MySettings.fpsBoostEnabled, MySettings.noFogEnabled, MySettings.clickTpEnabled
local tpSizeValue, safeSizeValue = MySettings.tpSizeValue, MySettings.safeSizeValue
local safePart, espObjects, squareTpActive, isAttacking, oldCFrame = nil, {}, false, false, nil

local guiParent = pcall(function() return gethui() end) and gethui() or (CoreGui:FindFirstChild("RobloxGui") or LocalPlayer:WaitForChild("PlayerGui"))
local gui = Instance.new("ScreenGui"); gui.Name = "JNHHGamingCompact"; gui.ResetOnSpawn = false; gui.Parent = guiParent

local frame = Instance.new("Frame"); frame.Name = "CompactFrame"; frame.Size = UDim2.new(0, 360, 0, 360); frame.Position = UDim2.new(0, 50, 0, 50) 
frame.BackgroundColor3 = Color3.fromRGB(25, 25, 35); frame.BackgroundTransparency = 0.15; frame.BorderSizePixel = 0; frame.Active = true; frame.Parent = gui
Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 8)

local openButton = Instance.new("TextButton"); openButton.Name = "OpenButton"; openButton.Size = UDim2.new(0, 50, 0, 30); openButton.Position = UDim2.new(0, 15, 0, 15)
openButton.BackgroundColor3 = Color3.fromRGB(0, 150, 255); openButton.TextColor3 = Color3.new(1, 1, 1); openButton.Font = Enum.Font.SourceSansBold; openButton.TextSize = 12
openButton.Text = "Mở"; openButton.Visible = false; openButton.Active = true; openButton.Parent = gui
Instance.new("UICorner", openButton).CornerRadius = UDim.new(0, 6)

local function makeDraggable(ui)
    local drag, dragStart, startPos, touchObj = false, nil, nil, nil
    ui.InputBegan:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then drag = true; touchObj = input; dragStart = input.Position; startPos = ui.Position end end)
    ui.InputEnded:Connect(function(input) if input == touchObj then drag = false; touchObj = nil end end)
    UserInputService.InputChanged:Connect(function(input) if drag and (input == touchObj or input.UserInputType == Enum.UserInputType.MouseMovement) then local delta = input.Position - dragStart; ui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
makeDraggable(frame); makeDraggable(openButton)

local FONT, C_OFF, C_ON_GRN = Enum.Font.SourceSansBold, Color3.fromRGB(60, 60, 70), Color3.fromRGB(0, 200, 100)
local function createBtn(name, text, w, x, y, color, parent)
    local b = Instance.new("TextButton"); b.Name = name; b.Size = UDim2.new(0, w, 0, 30); b.Position = UDim2.new(0, x, 0, y)
    b.BackgroundColor3 = color; b.TextColor3 = Color3.new(1, 1, 1); b.Font = FONT; b.TextSize = 13; b.Text = text; b.Parent = parent
    Instance.new("UICorner", b).CornerRadius = UDim.new(0, 6); return b
end

-- CÁC NÚT CỘT TRÁI
local jumpBtn = createBtn("jumpBtn", infiniteJumpEnabled and "Inf: ON" or "Inf: OFF", 150, 10, 10, infiniteJumpEnabled and C_ON_GRN or C_OFF, frame)
local noclipBtn = createBtn("noclipBtn", noclipEnabled and "Noclip: ON" or "Noclip: OFF", 150, 10, 45, noclipEnabled and C_ON_GRN or C_OFF, frame)
local espBtn = createBtn("espBtn", espEnabled and "ESP: ON" or "ESP: OFF", 150, 10, 80, espEnabled and Color3.fromRGB(0, 180, 255) or C_OFF, frame)
local flingBtn = createBtn("flingBtn", flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF", 150, 10, 115, flingEnabled and Color3.fromRGB(255, 0, 100) or C_OFF, frame)
local moveBtn = createBtn("moveBtn", moveEnabled and "Move: ON" or "Move: OFF", 150, 10, 150, moveEnabled and C_ON_GRN or C_OFF, frame)
local fpsBtn = createBtn("fpsBtn", fpsBoostEnabled and "FPS: ON" or "FPS: OFF", 150, 10, 185, fpsBoostEnabled and C_ON_GRN or C_OFF, frame)
local fogBtn = createBtn("fogBtn", noFogEnabled and "NoFog: ON" or "NoFog: OFF", 150, 10, 220, noFogEnabled and C_ON_GRN or C_OFF, frame)
local clickTpBtn = createBtn("clickTpBtn", clickTpEnabled and "ClickTP: ON" or "ClickTP: OFF", 150, 10, 255, clickTpEnabled and C_ON_GRN or C_OFF, frame)
local autoRollBtn = createBtn("aRollBtn", autoRollEnabled and "Auto Cuộn: ON" or "Auto Cuộn: OFF", 150, 10, 290, autoRollEnabled and Color3.fromRGB(255, 100, 0) or C_OFF, frame)
local minBtn = createBtn("minBtn", "Thu nhỏ (-)", 150, 10, 325, Color3.fromRGB(200, 50, 50), frame)
minBtn.MouseButton1Click:Connect(function() frame.Visible = false; openButton.Visible = true end)
openButton.MouseButton1Click:Connect(function() openButton.Visible = false; frame.Visible = true end)

-- CỘT PHẢI & GIAO DIỆN (ĐÃ CHUẨN HÓA LẠI LAYOUT NÚT MÀU/FULLBRIGHT)
local col2 = Instance.new("Frame", frame); col2.Size = UDim2.new(0, 180, 1, -20); col2.Position = UDim2.new(0, 170, 0, 10); col2.BackgroundTransparency = 1
local col2List = Instance.new("UIListLayout", col2); col2List.Padding = UDim.new(0, 5); col2List.SortOrder = Enum.SortOrder.LayoutOrder

local safeMenuBtn = createBtn("sMenuBtn", "▶ Menu SAFE", 180, 0, 0, Color3.fromRGB(80, 80, 90), col2); safeMenuBtn.LayoutOrder = 1
local safeFrame = Instance.new("Frame", col2); safeFrame.BackgroundTransparency = 1; safeFrame.Size = UDim2.new(0, 180, 0, 65); safeFrame.Visible = false; safeFrame.LayoutOrder = 2
local safeBtn = createBtn("safeBtn", safeEnabled and "Safe: ON" or "Safe: OFF", 85, 0, 0, safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF, safeFrame)
local showSafeBtn = createBtn("showSfBtn", showSafeSquare and "BtnSF: ON" or "BtnSF: OFF", 85, 95, 0, showSafeSquare and C_ON_GRN or Color3.fromRGB(200, 50, 50), safeFrame)
local decSfBtn = createBtn("decSfBtn", "SF Size -", 85, 0, 35, Color3.fromRGB(180, 100, 20), safeFrame)
local incSfBtn = createBtn("incSfBtn", "SF Size +", 85, 95, 35, Color3.fromRGB(180, 150, 20), safeFrame)

local tpMenuBtn = createBtn("tMenuBtn", "▶ Menu TP (Nút Vuông)", 180, 0, 0, Color3.fromRGB(80, 80, 90), col2); tpMenuBtn.LayoutOrder = 3
local tpFrame = Instance.new("Frame", col2); tpFrame.BackgroundTransparency = 1; tpFrame.Size = UDim2.new(0, 180, 0, 100); tpFrame.Visible = false; tpFrame.LayoutOrder = 4
local tpNearestBtn = createBtn("tpNBtn", tpNearestEnabled and "TP Nrs: ON" or "TP Nrs: OFF", 180, 0, 0, tpNearestEnabled and C_ON_GRN or C_OFF, tpFrame)
local tpaBtn = createBtn("tpaBtn", tpaEnabled and "TPA: ON" or "TPA: OFF", 180, 0, 35, tpaEnabled and Color3.fromRGB(150, 0, 255) or C_OFF, tpFrame)
local decTpBtn = createBtn("decTpBtn", "TP Size -", 85, 0, 70, Color3.fromRGB(180, 50, 50), tpFrame)
local incTpBtn = createBtn("incTpBtn", "TP Size +", 85, 95, 70, Color3.fromRGB(50, 180, 50), tpFrame)

local floatTpMenuBtn = createBtn("fTpMenuBtn", "▶ Quản Lý TP (Cài Đặt)", 180, 0, 0, Color3.fromRGB(80, 80, 90), col2); floatTpMenuBtn.LayoutOrder = 5
local floatTpFrame = Instance.new("Frame", col2); floatTpFrame.BackgroundTransparency = 1; floatTpFrame.Size = UDim2.new(0, 180, 0, 235); floatTpFrame.Visible = false; floatTpFrame.LayoutOrder = 6
local addTpManagerBtn = createBtn("addTpmBtn", "+ Thêm Điểm Mới", 180, 0, 0, Color3.fromRGB(0, 150, 255), floatTpFrame)
local decFloatBtn = createBtn("decFlBtn", "Size -", 45, 0, 35, Color3.fromRGB(200, 50, 50), floatTpFrame)
local floatSizeLbl = createBtn("flSzLbl", "Size: "..(MySettings.floatTpSizeValue or 80), 80, 50, 35, Color3.fromRGB(80, 80, 90), floatTpFrame)
local incFloatBtn = createBtn("incFlBtn", "Size +", 45, 135, 35, Color3.fromRGB(50, 200, 50), floatTpFrame)
local scrollList = Instance.new("ScrollingFrame", floatTpFrame)
scrollList.Size = UDim2.new(1, 0, 1, -70); scrollList.Position = UDim2.new(0, 0, 0, 70); scrollList.BackgroundTransparency = 1; scrollList.ScrollBarThickness = 4; scrollList.CanvasSize = UDim2.new(0, 0, 0, 0)
local scrollLayout = Instance.new("UIListLayout", scrollList); scrollLayout.Padding = UDim.new(0, 5)

local colorBtn = createBtn("colorBtn", "Màu Menu: Mặc định", 180, 0, 0, Color3.fromRGB(50, 50, 60), col2); colorBtn.LayoutOrder = 7
local fullbrightBtn = createBtn("fbBtn", "Fullbright: OFF", 180, 0, 0, Color3.fromRGB(40, 40, 40), col2); fullbrightBtn.LayoutOrder = 8
local isSafeOpen, isTpOpen, isFloatTpOpen = false, false, false
local function updateMainFrameSize()
    local baseHeight = 450
    -- Đã cập nhật phép tính cho 5 nút trong col2
    local col2Height = 10 + (35 * 5) + (isSafeOpen and 70 or 0) + (isTpOpen and 105 or 0) + (isFloatTpOpen and 240 or 0)
    frame.Size = UDim2.new(0, 360, 0, math.max(baseHeight, col2Height))
end

safeMenuBtn.MouseButton1Click:Connect(function() isSafeOpen = not isSafeOpen; safeFrame.Visible = isSafeOpen; safeMenuBtn.Text = isSafeOpen and "▼ Thu gọn SAFE" or "▶ Menu SAFE"; updateMainFrameSize() end)
tpMenuBtn.MouseButton1Click:Connect(function() isTpOpen = not isTpOpen; tpFrame.Visible = isTpOpen; tpMenuBtn.Text = isTpOpen and "▼ Thu gọn Menu TP" or "▶ Menu TP (Nút Vuông)"; updateMainFrameSize() end)
floatTpMenuBtn.MouseButton1Click:Connect(function() isFloatTpOpen = not isFloatTpOpen; floatTpFrame.Visible = isFloatTpOpen; floatTpMenuBtn.Text = isFloatTpOpen and "▼ Thu gọn Quản Lý TP" or "▶ Quản Lý TP (Cài Đặt)"; updateMainFrameSize() end)

local floatingUIs = {}
local function RenderFloatScreenButtons()
    for _, ui in pairs(floatingUIs) do ui:Destroy() end; floatingUIs = {}
    local sizeV = MySettings.floatTpSizeValue or 80
    for i, data in ipairs(MySettings.tpManagerData) do
        if data.show then
            local f = Instance.new("Frame", gui)
            f.Size = UDim2.new(0, sizeV, 0, sizeV / 2)
            if data.pos then f.Position = UDim2.new(data.pos[1], data.pos[2], data.pos[3], data.pos[4])
            else f.Position = UDim2.new(0.2 + (i%3)*0.1, 0, 0.2 + math.floor(i/3)*0.1, 0) end
            f.BackgroundColor3 = Color3.new(0,0,0); f.BorderColor3 = Color3.new(1,0,0); f.BorderSizePixel = 2; f.Active = true
            local numLbl = Instance.new("TextLabel", f); numLbl.Size = UDim2.new(0.3, 0, 1, 0); numLbl.BackgroundTransparency = 1; numLbl.Text = tostring(i); numLbl.TextColor3 = Color3.new(1,1,1); numLbl.Font = FONT; numLbl.TextSize = 16
            local tpBtn = Instance.new("TextButton", f); tpBtn.Size = UDim2.new(0.7, 0, 1, 0); tpBtn.Position = UDim2.new(0.3, 0, 0, 0); tpBtn.BackgroundColor3 = Color3.new(1,0,0); tpBtn.BorderColor3 = Color3.new(0.5,0,0); tpBtn.BorderSizePixel = 1; tpBtn.Text = "TP"; tpBtn.TextColor3 = Color3.new(0,0,0); tpBtn.Font = FONT; tpBtn.TextSize = 18
            local drag, dragStart, startPos, touchObj = false, nil, nil, nil
            f.InputBegan:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then drag = true; dragStart = input.Position; startPos = f.Position; touchObj = input end end)
            f.InputEnded:Connect(function(input) if input == touchObj then drag = false; touchObj = nil; data.pos = {f.Position.X.Scale, f.Position.X.Offset, f.Position.Y.Scale, f.Position.Y.Offset}; SaveConfig() end end)
            UserInputService.InputChanged:Connect(function(input) if drag and (input == touchObj or input.UserInputType == Enum.UserInputType.MouseMovement) then local delta = input.Position - dragStart; f.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
            tpBtn.MouseButton1Click:Connect(function() local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp and data.cframe then pcall(function() hrp.CFrame = CFrame.new(unpack(data.cframe)) end) end end)
            table.insert(floatingUIs, f)
        end
    end
end

local function RenderTPManagerList()
    for _, v in pairs(scrollList:GetChildren()) do if v:IsA("Frame") then v:Destroy() end end; local totalHeight = 0
    for i, data in ipairs(MySettings.tpManagerData) do
        local item = Instance.new("Frame", scrollList); item.Size = UDim2.new(1, -10, 0, 60); item.BackgroundTransparency = 1
        local nameBox = Instance.new("TextBox", item); nameBox.Size = UDim2.new(1, 0, 0, 25); nameBox.Position = UDim2.new(0, 0, 0, 0); nameBox.BackgroundColor3 = Color3.fromRGB(40, 40, 50); nameBox.TextColor3 = Color3.new(1,1,1); nameBox.Font = FONT; nameBox.TextSize = 14; nameBox.Text = data.name or ("Set " .. i); nameBox.ClearTextOnFocus = false; Instance.new("UICorner", nameBox).CornerRadius = UDim.new(0, 4)
        nameBox.FocusLost:Connect(function() data.name = nameBox.Text; SaveConfig() end)
        local btnW = 38
        local setBtn = createBtn("setB", "Set", btnW, 0, 30, Color3.fromRGB(0, 150, 200), item)
        local tpBtn = createBtn("tpB", "TP", btnW, btnW + 4, 30, Color3.fromRGB(0, 200, 100), item)
        local showBtn = createBtn("shwB", data.show and "Mắt:ON" or "Mắt:OFF", btnW+12, (btnW*2) + 8, 30, data.show and C_ON_GRN or C_OFF, item)
        local delBtn = createBtn("delB", "Xóa", btnW-6, (btnW*3) + 24, 30, Color3.fromRGB(200, 50, 50), item)
        showBtn.TextSize = 12; delBtn.TextSize = 12
        setBtn.MouseButton1Click:Connect(function() local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp then data.cframe = {hrp.CFrame:GetComponents()}; SaveConfig(); setBtn.Text = "OK"; task.delay(1, function() setBtn.Text = "Set" end) end end)
        tpBtn.MouseButton1Click:Connect(function() local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp and data.cframe then pcall(function() hrp.CFrame = CFrame.new(unpack(data.cframe)) end) end end)
        showBtn.MouseButton1Click:Connect(function() data.show = not data.show; showBtn.Text = data.show and "Mắt:ON" or "Mắt:OFF"; showBtn.BackgroundColor3 = data.show and C_ON_GRN or C_OFF; SaveConfig(); RenderFloatScreenButtons() end)
        delBtn.MouseButton1Click:Connect(function() table.remove(MySettings.tpManagerData, i); SaveConfig(); RenderTPManagerList(); RenderFloatScreenButtons() end)
        totalHeight = totalHeight + 65
    end
    scrollList.CanvasSize = UDim2.new(0, 0, 0, totalHeight)
end

addTpManagerBtn.MouseButton1Click:Connect(function() table.insert(MySettings.tpManagerData, { name = "Set " .. (#MySettings.tpManagerData + 1), cframe = nil, show = true, pos = nil }); SaveConfig(); RenderTPManagerList(); RenderFloatScreenButtons() end)
decFloatBtn.MouseButton1Click:Connect(function() local cur = MySettings.floatTpSizeValue or 80; if cur > 40 then MySettings.floatTpSizeValue = cur - 10; floatSizeLbl.Text = "Size: " .. MySettings.floatTpSizeValue; SaveConfig(); RenderFloatScreenButtons() end end)
incFloatBtn.MouseButton1Click:Connect(function() local cur = MySettings.floatTpSizeValue or 80; if cur < 150 then MySettings.floatTpSizeValue = cur + 10; floatSizeLbl.Text = "Size: " .. MySettings.floatTpSizeValue; SaveConfig(); RenderFloatScreenButtons() end end)
RenderTPManagerList(); RenderFloatScreenButtons()

local function isRollReady(text)
    if not text then return false end
    local t = string.lower(text)
    if not (string.find(t, "cuộn") or string.find(t, "roll")) then return false end
    local secMatch = string.match(t, "(%d+)s")
    if secMatch and tonumber(secMatch) > 0 then return false end
    local m, s = string.match(t, "(%d+):(%d+)")
    if m and s and (tonumber(m) > 0 or tonumber(s) > 0) then return false end
    if string.find(t, "cooldown") or string.find(t, "wait") then return false end
    return true
end

autoRollBtn.MouseButton1Click:Connect(function() autoRollEnabled = not autoRollEnabled; autoRollBtn.Text = autoRollEnabled and "Auto Cuộn: ON" or "Auto Cuộn: OFF"; autoRollBtn.BackgroundColor3 = autoRollEnabled and Color3.fromRGB(255, 100, 0) or C_OFF; MySettings.autoRollEnabled = autoRollEnabled; SaveConfig() end)
task.spawn(function()
    while true do
        task.wait(0.2)
        if autoRollEnabled then
            local pGui = LocalPlayer:FindFirstChild("PlayerGui")
            if pGui then
                for _, element in pairs(pGui:GetDescendants()) do
                    if (element:IsA("TextButton") or element:IsA("ImageButton")) and element.Visible then
                        local readyToClick = false
                        if element:IsA("TextButton") then readyToClick = isRollReady(element.Text) end
                        if not readyToClick then local txtLabel = element:FindFirstChildOfClass("TextLabel"); if txtLabel then readyToClick = isRollReady(txtLabel.Text) end end
                        if readyToClick then pcall(function() for _, snd in pairs(element:GetDescendants()) do if snd:IsA("Sound") then snd.Volume = 0; snd.Playing = false end end; if firesignal then firesignal(element.MouseButton1Click); firesignal(element.Activated) else for _, conn in pairs(getconnections(element.Activated) or {}) do conn:Fire() end; for _, conn in pairs(getconnections(element.MouseButton1Click) or {}) do conn:Fire() end end end) end
                    end
                end
            end
        end
    end
end)
local tpSquare = Instance.new("TextButton"); tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); tpSquare.Position = UDim2.new(MySettings.tpSquareX_Scale, MySettings.tpSquareX_Offset, MySettings.tpSquareY_Scale, MySettings.tpSquareY_Offset); tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50); tpSquare.Text = "TP"; tpSquare.TextColor3 = Color3.new(1,1,1); tpSquare.Font = FONT; tpSquare.TextSize = 16; tpSquare.Visible = tpaEnabled; tpSquare.BorderSizePixel = 0; tpSquare.Parent = gui
local safeSquare = Instance.new("TextButton"); safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); safeSquare.Position = UDim2.new(MySettings.safeSquareX_Scale, MySettings.safeSquareX_Offset, MySettings.safeSquareY_Scale, MySettings.safeSquareY_Offset); safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0); safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"; safeSquare.TextColor3 = Color3.new(0,0,0); safeSquare.Font = FONT; safeSquare.TextSize = 14; safeSquare.Visible = showSafeSquare; safeSquare.BorderSizePixel = 0; safeSquare.Parent = gui

local function setupSquareDrag(targetUi, settingPrefix)
    local drag, dragStart, startPos, touchObj = false, nil, nil, nil
    targetUi.InputBegan:Connect(function(input) if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) and moveEnabled then drag = true; touchObj = input; dragStart = input.Position; startPos = targetUi.Position end end)
    targetUi.InputEnded:Connect(function(input) if input == touchObj then drag = false; touchObj = nil; MySettings[settingPrefix.."X_Scale"] = targetUi.Position.X.Scale; MySettings[settingPrefix.."X_Offset"] = targetUi.Position.X.Offset; MySettings[settingPrefix.."Y_Scale"] = targetUi.Position.Y.Scale; MySettings[settingPrefix.."Y_Offset"] = targetUi.Position.Y.Offset; SaveConfig() end end)
    UserInputService.InputChanged:Connect(function(input) if drag and moveEnabled and (input == touchObj or input.UserInputType == Enum.UserInputType.MouseMovement) then local delta = input.Position - dragStart; targetUi.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y) end end)
end
setupSquareDrag(tpSquare, "tpSquare"); setupSquareDrag(safeSquare, "safeSquare")

local function getClosestPlayer()
    local closestPlayer = nil; local shortestDistance = math.huge; local myChar = LocalPlayer.Character; local myHrp = myChar and myChar:FindFirstChild("HumanoidRootPart")
    if myHrp then for _, v in pairs(Players:GetPlayers()) do if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") then local distance = (myHrp.Position - v.Character.HumanoidRootPart.Position).Magnitude; if distance < shortestDistance then shortestDistance = distance; closestPlayer = v end end end end
    return closestPlayer
end

noclipBtn.MouseButton1Click:Connect(function() noclipEnabled = not noclipEnabled; noclipBtn.Text = noclipEnabled and "Noclip: ON" or "Noclip: OFF"; noclipBtn.BackgroundColor3 = noclipEnabled and C_ON_GRN or C_OFF; MySettings.noclipEnabled = noclipEnabled; SaveConfig() end)
RunService.Stepped:Connect(function() if noclipEnabled and LocalPlayer.Character then local hum = LocalPlayer.Character:FindFirstChildOfClass("Humanoid"); if hum then hum.AutoJumpEnabled = false end; for _, part in pairs(LocalPlayer.Character:GetDescendants()) do if part:IsA("BasePart") then local pName = part.Name:lower(); if not (string.find(pName, "leg") or string.find(pName, "foot") or string.find(pName, "shoe")) then part.CanCollide = false end end end end end)
fpsBtn.MouseButton1Click:Connect(function() fpsBoostEnabled = not fpsBoostEnabled; fpsBtn.Text = fpsBoostEnabled and "FPS: ON" or "FPS: OFF"; fpsBtn.BackgroundColor3 = fpsBoostEnabled and C_ON_GRN or C_OFF; MySettings.fpsBoostEnabled = fpsBoostEnabled; SaveConfig(); if fpsBoostEnabled then for _, v in pairs(workspace:GetDescendants()) do if v:IsA("BasePart") then v.Material = Enum.Material.SmoothPlastic; v.Color = Color3.new(1,1,1); v.CastShadow = false elseif v:IsA("Decal") or v:IsA("Texture") then v.Transparency = 1 end end end end)
fogBtn.MouseButton1Click:Connect(function() noFogEnabled = not noFogEnabled; fogBtn.Text = noFogEnabled and "NoFog: ON" or "NoFog: OFF"; fogBtn.BackgroundColor3 = noFogEnabled and C_ON_GRN or C_OFF; MySettings.noFogEnabled = noFogEnabled; SaveConfig(); if noFogEnabled then Lighting.FogEnd = 100000; for _, v in pairs(Lighting:GetDescendants()) do if v:IsA("Atmosphere") then v:Destroy() end end end end)

local clickTpTool = nil
clickTpBtn.MouseButton1Click:Connect(function() clickTpEnabled = not clickTpEnabled; clickTpBtn.Text = clickTpEnabled and "ClickTP: ON" or "ClickTP: OFF"; clickTpBtn.BackgroundColor3 = clickTpEnabled and C_ON_GRN or C_OFF; MySettings.clickTpEnabled = clickTpEnabled; SaveConfig(); if clickTpEnabled then if not clickTpTool then clickTpTool = Instance.new("Tool"); clickTpTool.Name = "Click To TP"; clickTpTool.RequiresHandle = false; clickTpTool.Parent = LocalPlayer.Backpack; clickTpTool.Activated:Connect(function() local mouse = LocalPlayer:GetMouse(); if mouse.Target and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(mouse.Hit.Position + Vector3.new(0, 3, 0)) end end) end else if clickTpTool then clickTpTool:Destroy(); clickTpTool = nil end end end)
jumpBtn.MouseButton1Click:Connect(function() infiniteJumpEnabled = not infiniteJumpEnabled; jumpBtn.Text = infiniteJumpEnabled and "Inf: ON" or "Inf: OFF"; jumpBtn.BackgroundColor3 = infiniteJumpEnabled and C_ON_GRN or C_OFF; MySettings.infiniteJumpEnabled = infiniteJumpEnabled; SaveConfig() end)
UserInputService.JumpRequest:Connect(function() if infiniteJumpEnabled then pcall(function() LocalPlayer.Character.Humanoid:ChangeState(Enum.HumanoidStateType.Jumping) end) end end)

decTpBtn.MouseButton1Click:Connect(function() if tpSizeValue > 30 then tpSizeValue = tpSizeValue - 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end end)
incTpBtn.MouseButton1Click:Connect(function() if tpSizeValue < 150 then tpSizeValue = tpSizeValue + 10; tpSquare.Size = UDim2.new(0, tpSizeValue, 0, tpSizeValue); MySettings.tpSizeValue = tpSizeValue; SaveConfig() end end)
decSfBtn.MouseButton1Click:Connect(function() if safeSizeValue > 30 then safeSizeValue = safeSizeValue - 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end end)
incSfBtn.MouseButton1Click:Connect(function() if safeSizeValue < 150 then safeSizeValue = safeSizeValue + 10; safeSquare.Size = UDim2.new(0, safeSizeValue, 0, safeSizeValue); MySettings.safeSizeValue = safeSizeValue; SaveConfig() end end)

local function checkSafePlatform() if safeEnabled then local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp and (not safePart or not safePart.Parent) then safePart = Instance.new("Part"); safePart.Size = Vector3.new(20, 1, 20); safePart.Position = Vector3.new(hrp.Position.X, hrp.Position.Y + 300, hrp.Position.Z); safePart.Anchored = true; safePart.BrickColor = BrickColor.new("White"); safePart.Parent = workspace; hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end else if safePart then safePart:Destroy(); safePart = nil end end end
safeBtn.MouseButton1Click:Connect(function() safeEnabled = not safeEnabled; safeBtn.Text = safeEnabled and "Safe: ON" or "Safe: OFF"; safeBtn.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF; safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"; safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0); MySettings.safeEnabled = safeEnabled; SaveConfig(); checkSafePlatform() end)
showSafeBtn.MouseButton1Click:Connect(function() showSafeSquare = not showSafeSquare; showSafeBtn.Text = showSafeSquare and "BtnSF: ON" or "BtnSF: OFF"; showSafeBtn.BackgroundColor3 = showSafeSquare and C_ON_GRN or Color3.fromRGB(200, 50, 50); safeSquare.Visible = showSafeSquare; MySettings.showSafeSquare = showSafeSquare; SaveConfig() end)
safeSquare.MouseButton1Click:Connect(function() safeEnabled = not safeEnabled; safeBtn.Text = safeEnabled and "Safe: ON" or "Safe: OFF"; safeBtn.BackgroundColor3 = safeEnabled and Color3.fromRGB(255, 150, 0) or C_OFF; safeSquare.Text = safeEnabled and "SF: ON" or "SAFE"; safeSquare.BackgroundColor3 = safeEnabled and C_ON_GRN or Color3.fromRGB(255, 180, 0); MySettings.safeEnabled = safeEnabled; SaveConfig(); checkSafePlatform(); if safeEnabled then task.wait(0.05); if safePart and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then LocalPlayer.Character.HumanoidRootPart.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end end end)
task.spawn(function() while true do task.wait(0.5); if safeEnabled and safePart and safePart.Parent then local hrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if hrp and hrp.Position.Y < (safePart.Position.Y - 10) then hrp.CFrame = CFrame.new(safePart.Position + Vector3.new(0, 3, 0)) end end end end)

tpaBtn.MouseButton1Click:Connect(function() tpaEnabled = not tpaEnabled; tpaBtn.Text = tpaEnabled and "TPA: ON" or "TPA: OFF"; tpaBtn.BackgroundColor3 = tpaEnabled and Color3.fromRGB(150, 0, 255) or C_OFF; tpSquare.Visible = tpaEnabled; if not tpaEnabled then squareTpActive = false; tpSquare.Text = "TP"; tpSquare.BackgroundColor3 = Color3.fromRGB(255, 50, 50) end; MySettings.tpaEnabled = tpaEnabled; SaveConfig() end)
moveBtn.MouseButton1Click:Connect(function() moveEnabled = not moveEnabled; moveBtn.Text = moveEnabled and "Move: ON" or "Move: OFF"; moveBtn.BackgroundColor3 = moveEnabled and C_ON_GRN or C_OFF; MySettings.moveEnabled = moveEnabled; SaveConfig() end)
tpSquare.MouseButton1Click:Connect(function() if tpaEnabled then squareTpActive = not squareTpActive; tpSquare.Text = squareTpActive and "TP: ON" or "TP"; tpSquare.BackgroundColor3 = squareTpActive and C_ON_GRN or Color3.fromRGB(255, 50, 50) end end)
task.spawn(function() while true do task.wait(0.01); if tpaEnabled and squareTpActive then pcall(function() local targetPlayer = getClosestPlayer(); local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if targetPlayer and myHrp then local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart"); if targetHrp then myHrp.CFrame = targetHrp.CFrame end end end) end end end)

local function triggerAttackBlink() if flingEnabled and not isAttacking then local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); local target = getClosestPlayer(); if myHrp and target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then if (myHrp.Position - target.Character.HumanoidRootPart.Position).Magnitude < 25 then oldCFrame = myHrp.CFrame; isAttacking = true; task.wait(0.2); isAttacking = false; if oldCFrame then myHrp.CFrame = oldCFrame; myHrp.Velocity = Vector3.new(0,0,0); myHrp.RotVelocity = Vector3.new(0,0,0); oldCFrame = nil end end end end end
local toolConnection = nil; local function trackWeapon(char) if toolConnection then toolConnection:Disconnect() end; toolConnection = char.ChildAdded:Connect(function(child) if child:IsA("Tool") then child.Activated:Connect(triggerAttackBlink) end end) end
UserInputService.InputBegan:Connect(function(input, gameProcessed) if not gameProcessed and flingEnabled and (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then triggerAttackBlink() end end)
flingBtn.MouseButton1Click:Connect(function() flingEnabled = not flingEnabled; flingBtn.Text = flingEnabled and "Atk Fling: ON" or "Atk Fling: OFF"; flingBtn.BackgroundColor3 = flingEnabled and Color3.fromRGB(255, 0, 100) or C_OFF; MySettings.flingEnabled = flingEnabled; SaveConfig() end)
RunService.Heartbeat:Connect(function() local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if not myHrp then return end; if flingEnabled and isAttacking then pcall(function() local target = getClosestPlayer(); if target and target.Character and target.Character:FindFirstChild("HumanoidRootPart") then myHrp.CFrame = target.Character.HumanoidRootPart.CFrame * CFrame.Angles(math.rad(math.random(0,360)), math.rad(math.random(0,360)), math.rad(math.random(0,360))); myHrp.Velocity = Vector3.new(99999,99999,99999); myHrp.RotVelocity = Vector3.new(99999,99999,99999) end end) elseif flingEnabled then myHrp.Velocity = Vector3.new(0,0,0); myHrp.RotVelocity = Vector3.new(0,0,0) end end)

local function createESP(player)
    if player == LocalPlayer then return end
    local function applyESP(character)
        task.wait(0.5); if not espEnabled then return end
        local head = character:WaitForChild("Head", 5); if not head then return end
        local billboard = Instance.new("BillboardGui"); billboard.Name = "ESP_Billboard"; billboard.Size = UDim2.new(0, 200, 0, 50); billboard.AlwaysOnTop = true; billboard.StudsOffset = Vector3.new(0, 3, 0); billboard.Parent = head
        local nameLabel = Instance.new("TextLabel"); nameLabel.Size = UDim2.new(1, 0, 1, 0); nameLabel.BackgroundTransparency = 1; nameLabel.Text = player.Name; nameLabel.TextColor3 = Color3.fromRGB(255, 50, 50); nameLabel.TextStrokeTransparency = 0; nameLabel.Font = Enum.Font.SourceSansBold; nameLabel.TextSize = 18; nameLabel.Parent = billboard
        espObjects[player] = {Billboard = billboard}
    end
    if player.Character then applyESP(player.Character) end; player.CharacterAdded:Connect(applyESP)
end
local function removeESP() for player, objects in pairs(espObjects) do if objects.Billboard then objects.Billboard:Destroy() end end; espObjects = {} end
local function updateESPStatus() if espEnabled then for _, p in pairs(Players:GetPlayers()) do createESP(p) end else removeESP() end end
espBtn.MouseButton1Click:Connect(function() espEnabled = not espEnabled; espBtn.Text = espEnabled and "ESP: ON" or "ESP: OFF"; espBtn.BackgroundColor3 = espEnabled and Color3.fromRGB(0, 180, 255) or C_OFF; MySettings.espEnabled = espEnabled; SaveConfig(); updateESPStatus() end)
Players.PlayerAdded:Connect(function(p) if espEnabled then createESP(p) end end)
Players.PlayerRemoving:Connect(function(p) if espObjects[p] then if espObjects[p].Billboard then espObjects[p].Billboard:Destroy() end; espObjects[p] = nil end end)
tpNearestBtn.MouseButton1Click:Connect(function() tpNearestEnabled = not tpNearestEnabled; tpNearestBtn.Text = tpNearestEnabled and "TP Nrs: ON" or "TP Nrs: OFF"; tpNearestBtn.BackgroundColor3 = tpNearestEnabled and C_ON_GRN or C_OFF; MySettings.tpNearestEnabled = tpNearestEnabled; SaveConfig() end)
task.spawn(function() while true do task.wait(0.01); if tpNearestEnabled then pcall(function() local targetPlayer = getClosestPlayer(); local myHrp = LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart"); if targetPlayer and myHrp then local targetHrp = targetPlayer.Character:FindFirstChild("HumanoidRootPart"); if targetHrp then myHrp.CFrame = targetHrp.CFrame end end end) end end end)

LocalPlayer.CharacterAdded:Connect(function(char) task.wait(0.5); checkSafePlatform(); updateESPStatus(); trackWeapon(char) end)
if LocalPlayer.Character then trackWeapon(LocalPlayer.Character) end
checkSafePlatform(); updateESPStatus()

-- LOGIC ĐỔI MÀU MENU
local themes = {
    {name = "Mặc định (Đen)", color = Color3.fromRGB(30, 30, 35)},
    {name = "Đỏ Huyết", color = Color3.fromRGB(150, 0, 0)},
    {name = "Xanh Nước", color = Color3.fromRGB(0, 50, 150)},
    {name = "Lục Bảo", color = Color3.fromRGB(0, 100, 50)},
    {name = "Tím Mộng", color = Color3.fromRGB(100, 0, 150)},
    {name = "Hồng Ne-on", color = Color3.fromRGB(200, 50, 100)},
    {name = "CẦU VỒNG", color = "Rainbow"}
}
local currentThemeIdx, rainbowConn = 1, nil
colorBtn.MouseButton1Click:Connect(function()
    currentThemeIdx = currentThemeIdx + 1
    if currentThemeIdx > #themes then currentThemeIdx = 1 end
    local theme = themes[currentThemeIdx]
    colorBtn.Text = "Màu Menu: " .. theme.name
    
    if rainbowConn then rainbowConn:Disconnect(); rainbowConn = nil end
    if theme.color == "Rainbow" then
        rainbowConn = RunService.RenderStepped:Connect(function()
            local rbColor = Color3.fromHSV((tick() % 5 / 5), 1, 1)
            frame.BackgroundColor3 = rbColor; openButton.BackgroundColor3 = rbColor
        end)
    else
        frame.BackgroundColor3 = theme.color; openButton.BackgroundColor3 = theme.color
    end
end)

-- LOGIC FULLBRIGHT
local isFullbright = false
local origLight = {
    Amb = Lighting.Ambient, Out = Lighting.OutdoorAmbient,
    Brt = Lighting.Brightness, Clk = Lighting.ClockTime,
    Fog = Lighting.FogEnd, GShad = Lighting.GlobalShadows
}
fullbrightBtn.MouseButton1Click:Connect(function()
    isFullbright = not isFullbright
    fullbrightBtn.Text = isFullbright and "Fullbright: ON" or "Fullbright: OFF"
    fullbrightBtn.BackgroundColor3 = isFullbright and Color3.fromRGB(0, 200, 100) or Color3.fromRGB(40, 40, 40)
    if not isFullbright then
        Lighting.Ambient = origLight.Amb; Lighting.OutdoorAmbient = origLight.Out
        Lighting.Brightness = origLight.Brt; Lighting.ClockTime = origLight.Clk
        Lighting.FogEnd = origLight.Fog; Lighting.GlobalShadows = origLight.GShad
    end
end)
task.spawn(function()
    while task.wait(0.5) do
        if isFullbright then
            Lighting.Ambient = Color3.new(1, 1, 1); Lighting.OutdoorAmbient = Color3.new(1, 1, 1)
            Lighting.Brightness = 2; Lighting.ClockTime = 14
            Lighting.FogEnd = 100000; Lighting.GlobalShadows = false
        end
    end
end)
