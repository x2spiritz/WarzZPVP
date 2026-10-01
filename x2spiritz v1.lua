if _G.__AimbotUnload then
	pcall(_G.__AimbotUnload)
end
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
local Workspace = game:GetService("Workspace")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LP = Players.LocalPlayer
local Camera = Workspace.CurrentCamera
local Cfg = {
	Aimbot = false,
	ESP = true,
	PartyCheck = true,
	WallCheck = true,
	ShowFOV = true,
	FOV = 150,       -- รัศมีวง (พิกเซล)
	Smooth = 20,     -- ยิ่งมากยิ่งล็อกเร็ว (1-100)
	MaxDist = 1000,  -- ระยะสูงสุด (studs)
	AimPart = "UpperTorso", -- หน้าอก (เปลี่ยนได้ที่ปุ่ม Aim Part ในเมนู)
	ESPBox = true,
	ESPName = true,
	ESPTextSize = 12,    -- ขนาดชื่อ
	ColorEnemy = 1,      -- ลำดับสีใน PALETTE
	ColorFriend = 2,
	ESPHealth = true,        -- แถบเลือด
	ESPHealthText = true,    -- ตัวเลขเลือด %
	HealthTextSize = 12,
	HealthTextColor = 0,     -- 0 = Auto (ตามสีศัตรู/เพื่อน), 1..N = สีใน PALETTE
	HealthTextX = 0,         -- เลื่อนตำแหน่ง (พิกเซล)
	HealthTextY = 0,
	ESPDist = true,
	DistTextSize = 12,
	DistTextColor = 0,
	DistTextX = 0,
	DistTextY = 0,
	ESPRGB = true,       -- สีรุ้งวิ่งทุกองค์ประกอบของ ESP
	ESPGlow = true,      -- เอฟเฟกต์เรืองแสง
	GlowPulse = true,    -- ให้แสงเต้นเป็นจังหวะ
	RGBSpeed = 0.5,      -- ความเร็วสีรุ้ง (รอบต่อวินาที)
	GlowSize = 2,        -- ความหนาของแสง
	RGBBarFill = false,  -- ให้แถบเลือด (ส่วนที่เติม) เป็นสีรุ้งด้วย (ปิด = ไล่สีแดง→เขียวตามเลือด)
	HoverInfo = true,
	HoverRadius = 45,    -- ระยะจากเมาส์ถึงตัวละครที่ถือว่า "ชี้อยู่" (พิกเซล)
	HoverWeapon = true,  -- อาวุธที่ถืออยู่
	HoverHelmet = true,
	HoverArmor = true,
	HoverTextSize = 13,
	AutoRun = true, -- Auto Execute หลังย้ายเซิร์ฟ/รีเกม (วางไฟล์ไว้ใน workspace/Aimbot/)
	Gain = 1.0,      -- ตัวคูณแรงเมาส์ เพิ่มถ้าเมาส์ตามเป้าไม่ทัน
	OffX = 0,        -- เลื่อนจุดเล็ง (พิกเซล) ให้ตรงกับศูนย์เล็งของเกม
	OffY = 0,
	Debug = false,   -- แสดงป้ายสถานะ/วินิจฉัยมุมซ้ายบน
	Mode = "Mouse",  -- "Mouse" = ขยับเมาส์จริง | "Camera" = หมุน Camera.CFrame
	AutoHeal = false,
	AutoHealMode = "Auto", -- Auto / BandagesDX / Medkit
	AutoHealHP = 40,
	AutoHealCheckDelay = 0.15,
	AutoHealWeaponDelay = 1,
	AutoHealMedkitThreshold = 25,
	AutoLoot = false,
	AutoLootHoldTime = 1.5,
	AutoLootCheckDelay = 0.05,
}
local mmr = mousemoverel
if not mmr then Cfg.Mode = "Camera" end
local AIM_PARTS = { "Head", "UpperTorso", "HumanoidRootPart" }
local PALETTE = {
	{ "Red", Color3.fromRGB(255, 70, 70) },
	{ "Green", Color3.fromRGB(80, 220, 120) },
	{ "Blue", Color3.fromRGB(70, 140, 255) },
	{ "Yellow", Color3.fromRGB(255, 220, 60) },
	{ "White", Color3.fromRGB(255, 255, 255) },
	{ "Cyan", Color3.fromRGB(60, 230, 230) },
	{ "Magenta", Color3.fromRGB(240, 90, 220) },
	{ "Orange", Color3.fromRGB(255, 150, 50) },
	{ "Purple", Color3.fromRGB(160, 110, 255) },
	{ "Pink", Color3.fromRGB(255, 140, 180) },
}
local HttpService = game:GetService("HttpService")
local CONFIG_DIR = "Aimbot"
local CONFIG_FILE = CONFIG_DIR .. "/config_warz.json"
local SCRIPT_FILE = CONFIG_DIR .. "/x2spiritz_v4.lua" -- ชื่อไฟล์ที่ใช้ Auto Execute
local canFile = (writefile and readfile and isfile) and true or false
local Defaults = {}
for k, v in pairs(Cfg) do Defaults[k] = v end
local function ensureDir()
	if isfolder and makefolder and not isfolder(CONFIG_DIR) then
		makefolder(CONFIG_DIR)
	end
end
local function saveConfig()
	if not canFile then return false end
	local ok = pcall(function()
		ensureDir()
		writefile(CONFIG_FILE, HttpService:JSONEncode(Cfg))
	end)
	return ok
end
local function loadConfig()
	if not canFile then return false end
	local ok, data = pcall(function()
		if not isfile(CONFIG_FILE) then return nil end
		return HttpService:JSONDecode(readfile(CONFIG_FILE))
	end)
	if not ok or type(data) ~= "table" then return false end
	for k, default in pairs(Defaults) do
		local v = data[k]
		if v ~= nil and type(v) == type(default) then
			Cfg[k] = v
		end
	end
	if not table.find(AIM_PARTS, Cfg.AimPart) then Cfg.AimPart = Defaults.AimPart end
	if Cfg.Mode ~= "Mouse" and Cfg.Mode ~= "Camera" then Cfg.Mode = Defaults.Mode end
	if Cfg.Mode == "Mouse" and not mmr then Cfg.Mode = "Camera" end
	Cfg.FOV = math.clamp(Cfg.FOV, 30, 600)
	Cfg.Smooth = math.clamp(Cfg.Smooth, 1, 100)
	Cfg.Gain = math.clamp(Cfg.Gain, 0.3, 3)
	Cfg.MaxDist = math.clamp(Cfg.MaxDist, 100, 3000)
	Cfg.OffX = math.clamp(Cfg.OffX, -600, 600)
	Cfg.OffY = math.clamp(Cfg.OffY, -600, 600)
	for _, key in ipairs({ "ESPTextSize", "HealthTextSize", "DistTextSize" }) do
		Cfg[key] = math.clamp(math.floor(Cfg[key]), 8, 24)
	end
	for _, key in ipairs({ "HealthTextX", "HealthTextY", "DistTextX", "DistTextY" }) do
		Cfg[key] = math.clamp(math.floor(Cfg[key]), -150, 150)
	end
	for _, key in ipairs({ "ColorEnemy", "ColorFriend" }) do
		Cfg[key] = math.clamp(math.floor(Cfg[key]), 1, #PALETTE)
	end
	for _, key in ipairs({ "HealthTextColor", "DistTextColor" }) do
		Cfg[key] = math.clamp(math.floor(Cfg[key]), 0, #PALETTE) -- 0 = Auto
	end
	Cfg.RGBSpeed = math.clamp(Cfg.RGBSpeed, 0.1, 3)
	Cfg.GlowSize = math.clamp(math.floor(Cfg.GlowSize), 1, 6)
	Cfg.HoverRadius = math.clamp(math.floor(Cfg.HoverRadius), 15, 150)
	Cfg.HoverTextSize = math.clamp(math.floor(Cfg.HoverTextSize), 10, 20)
	Cfg.AutoLootHoldTime = math.clamp(Cfg.AutoLootHoldTime, 0.1, 5)
	Cfg.AutoLootCheckDelay = math.clamp(Cfg.AutoLootCheckDelay, 0.01, 1)
	return true
end
local saveQueued = false
local function saveSoon()
	if saveQueued then return end
	saveQueued = true
	task.delay(0.5, function()
		saveQueued = false
		saveConfig()
	end)
end
local function setupAutoRun()
	if not Cfg.AutoRun then return end
	local q = queue_on_teleport
		or (syn and syn.queue_on_teleport)
		or (fluxus and fluxus.queue_on_teleport)
	if not q then
		warn("[Aimbot] executor ไม่รองรับ queue_on_teleport")
		return
	end
	if not (isfile and isfile(SCRIPT_FILE)) then
		warn("[Aimbot] ไม่พบไฟล์ " .. SCRIPT_FILE .. " ใน workspace ของ executor")
		return
	end
	q(string.format('loadstring(readfile("%s"))()', SCRIPT_FILE))
end
local hadConfig = loadConfig() -- โหลดค่าที่เซฟไว้ก่อนสร้างเมนู
if canFile and not hadConfig then
	saveConfig() -- สร้าง config เริ่มต้นอัตโนมัติ
end
local connections = {}
local function connect(signal, fn)
	local c = signal:Connect(fn)
	connections[#connections + 1] = c
	return c
end
local gui -- ScreenGui (กำหนดข้างล่าง)
local espFolder
local BIND_NAME = "AimbotAim"
local function unload()
	pcall(saveConfig) -- เซฟค่าล่าสุดก่อนปิด
	pcall(function() VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game) end)
	pcall(function() RunService:UnbindFromRenderStep(BIND_NAME) end)
	for _, c in ipairs(connections) do
		pcall(function() c:Disconnect() end)
	end
	table.clear(connections)
	if gui then pcall(function() gui:Destroy() end) end
	_G.__AimbotUnload = nil
end
_G.__AimbotUnload = unload
local function getGuiParent()
	local ok, h = pcall(function() return gethui and gethui() end)
	if ok and h then return h end
	local ok2, cg = pcall(function() return game:GetService("CoreGui") end)
	if ok2 and cg then
		local t = Instance.new("Folder")
		local writable = pcall(function() t.Parent = cg end)
		t:Destroy()
		if writable then return cg end
	end
	return LP:WaitForChild("PlayerGui")
end
gui = Instance.new("ScreenGui")
gui.Name = "Aimbot"
gui.ResetOnSpawn = false
gui.IgnoreGuiInset = true
gui.DisplayOrder = 9999
gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
gui.Parent = getGuiParent()
espFolder = Instance.new("Folder")
espFolder.Name = "ESP"
espFolder.Parent = gui
local function getAlive(plr)
	local char = plr.Character
	if not char then return nil end
	local hum = char:FindFirstChildOfClass("Humanoid")
	if not hum or hum.Health <= 0 then return nil end
	if char:GetAttribute("WarzDead") == true then return nil end
	return char, hum
end
local function isFriendly(plr)
	local mine = LP:GetAttribute("WarzPartyId")
	if type(mine) ~= "string" or mine == "" then return false end
	return plr:GetAttribute("WarzPartyId") == mine
end
local rayParams = RaycastParams.new()
rayParams.FilterType = Enum.RaycastFilterType.Exclude
rayParams.RespectCanCollide = true
local function isVisible(part, char)
	local origin = Camera.CFrame.Position
	rayParams.FilterDescendantsInstances = { LP.Character }
	local hit = Workspace:Raycast(origin, part.Position - origin, rayParams)
	return hit == nil or hit.Instance:IsDescendantOf(char)
end
local function getAimPart(char)
	return char:FindFirstChild(Cfg.AimPart) or char:FindFirstChild("HumanoidRootPart")
end
local function validate(plr, mouse, fovScale)
	if plr == LP or not plr.Parent then return nil end
	if Cfg.PartyCheck and isFriendly(plr) then return nil end
	local char = getAlive(plr)
	if not char then return nil end
	local part = getAimPart(char)
	if not part then return nil end
	if (Camera.CFrame.Position - part.Position).Magnitude > Cfg.MaxDist then return nil end
	local pos, onScreen = Camera:WorldToViewportPoint(part.Position)
	if not onScreen then return nil end
	local dist = (Vector2.new(pos.X, pos.Y) - mouse).Magnitude
	if dist > Cfg.FOV * fovScale then return nil end
	if Cfg.WallCheck and not isVisible(part, char) then return nil end
	return part, dist
end
local function findTarget(mouse)
	local bestPlr, bestDist = nil, math.huge
	for _, plr in ipairs(Players:GetPlayers()) do
		local part, dist = validate(plr, mouse, 1)
		if part and dist < bestDist then
			bestPlr, bestDist = plr, dist
		end
	end
	return bestPlr
end
local fovFrame = Instance.new("Frame")
fovFrame.Name = "FOV"
fovFrame.AnchorPoint = Vector2.new(0.5, 0.5)
fovFrame.BackgroundTransparency = 1
fovFrame.Visible = false
fovFrame.Parent = gui
do
	local corner = Instance.new("UICorner")
	corner.CornerRadius = UDim.new(1, 0)
	corner.Parent = fovFrame
	local stroke = Instance.new("UIStroke")
	stroke.Color = Color3.new(1, 1, 1)
	stroke.Thickness = 1.5
	stroke.Transparency = 0.25
	stroke.Parent = fovFrame
end
local statusLabel = Instance.new("TextLabel")
statusLabel.BackgroundTransparency = 1
statusLabel.Position = UDim2.fromOffset(10, 10)
statusLabel.Size = UDim2.fromOffset(520, 36)
statusLabel.TextYAlignment = Enum.TextYAlignment.Top
statusLabel.Font = Enum.Font.Code
statusLabel.TextSize = 13
statusLabel.TextXAlignment = Enum.TextXAlignment.Left
statusLabel.TextColor3 = Color3.new(1, 1, 1)
statusLabel.TextStrokeTransparency = 0.5
statusLabel.Text = ""
statusLabel.Parent = gui
local Holding = false
local lockedPlr = nil
local dbgText, dbgAcc = "", 0
local function scanReasons(mouse)
	local n = { total = 0, dead = 0, friend = 0, far = 0, off = 0, fov = 0, wall = 0, ok = 0 }
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			n.total += 1
			if Cfg.PartyCheck and isFriendly(plr) then
				n.friend += 1
				continue
			end
			local char = getAlive(plr)
			if not char then n.dead += 1 continue end
			local part = getAimPart(char)
			if not part then n.dead += 1 continue end
			if (Camera.CFrame.Position - part.Position).Magnitude > Cfg.MaxDist then n.far += 1 continue end
			local pos, on = Camera:WorldToViewportPoint(part.Position)
			if not on then n.off += 1 continue end
			if (Vector2.new(pos.X, pos.Y) - mouse).Magnitude > Cfg.FOV then n.fov += 1 continue end
			if Cfg.WallCheck and not isVisible(part, char) then n.wall += 1 continue end
			n.ok += 1
		end
	end
	local me = getAlive(LP) and "alive" or "DEAD"
	return string.format("me:%s | players:%d dead/none:%d party:%d far:%d offscreen:%d outFOV:%d wall:%d OK:%d | cross:%d,%d",
		me, n.total, n.dead, n.friend, n.far, n.off, n.fov, n.wall, n.ok, mouse.X, mouse.Y)
end
local remX, remY = 0, 0 -- เศษพิกเซลที่ค้างจากเฟรมก่อน (กันเมาส์ปัดเศษทิ้งจนช้า/กระตุก)
local function getCrosshair()
	local m = UIS:GetMouseLocation()
	return Vector2.new(m.X + Cfg.OffX, m.Y + Cfg.OffY)
end
local function aimStep(dt)
	Camera = Workspace.CurrentCamera
	if not Camera then return end
	local mouse = getCrosshair()
	statusLabel.Visible = Cfg.Debug
	if Cfg.Debug then
		dbgAcc += dt
		if dbgAcc > 0.2 then
			dbgAcc = 0
			local ok, txt = pcall(scanReasons, mouse)
			dbgText = ok and txt or ("scan error: " .. tostring(txt))
		end
		statusLabel.Text = string.format("[%s] aim:%s hold:%s target:%s\n%s", Cfg.Mode,
			tostring(Cfg.Aimbot), tostring(Holding), lockedPlr and lockedPlr.Name or "none", dbgText)
	end
	local show = Cfg.ShowFOV
	fovFrame.Visible = show
	if show then
		fovFrame.Position = UDim2.fromOffset(mouse.X, mouse.Y)
		fovFrame.Size = UDim2.fromOffset(Cfg.FOV * 2, Cfg.FOV * 2)
	end
	if not (Cfg.Aimbot and Holding) then
		lockedPlr = nil
		remX, remY = 0, 0
		return
	end
	if not getAlive(LP) then
		lockedPlr = nil
		return
	end
	local part
	if lockedPlr then
		part = validate(lockedPlr, mouse, 1.4)
		if not part then lockedPlr = nil end
	end
	if not lockedPlr then
		lockedPlr = findTarget(mouse)
		if lockedPlr then part = validate(lockedPlr, mouse, 1.4) end
	end
	if not part then return end
	local alpha = math.min(1, 1 - math.exp(-Cfg.Smooth * dt))
	if Cfg.Mode == "Mouse" and mmr then
		local pos = Camera:WorldToViewportPoint(part.Position)
		local dx = (pos.X - mouse.X) * alpha * Cfg.Gain + remX
		local dy = (pos.Y - mouse.Y) * alpha * Cfg.Gain + remY
		local ix = dx >= 0 and math.floor(dx) or math.ceil(dx)
		local iy = dy >= 0 and math.floor(dy) or math.ceil(dy)
		remX, remY = dx - ix, dy - iy
		if ix ~= 0 or iy ~= 0 then mmr(ix, iy) end
	else
		local cf = Camera.CFrame
		Camera.CFrame = cf:Lerp(CFrame.lookAt(cf.Position, part.Position), alpha)
	end
end
RunService:BindToRenderStep(BIND_NAME, Enum.RenderPriority.Camera.Value + 1, aimStep)
connect(UIS.InputBegan, function(input, processed)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Holding = true
	end
end)
connect(UIS.InputEnded, function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton2 then
		Holding = false
		lockedPlr = nil
	end
end)
local espObjects = {} -- [Player] = { ... }
local function newInfoLabel(parent)
	local t = Instance.new("TextLabel")
	t.BackgroundTransparency = 1
	t.Size = UDim2.fromOffset(116, 20)
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 12
	t.TextColor3 = Color3.new(1, 1, 1)
	t.TextStrokeTransparency = 0.4
	t.Text = ""
	t.Parent = parent
	local glow = Instance.new("UIStroke")
	glow.ApplyStrokeMode = Enum.ApplyStrokeMode.Contextual
	glow.Thickness = 2
	glow.Transparency = 0.5
	glow.Color = Color3.new(1, 1, 1)
	glow.Enabled = false
	glow.Parent = t
	return t, glow
end
local function createEsp(plr)
	if espObjects[plr] then return end
	local box = Instance.new("BillboardGui")
	box.Name = plr.Name .. "_box"
	box.AlwaysOnTop = true
	box.Size = UDim2.fromScale(4, 6)
	box.LightInfluence = 0
	box.Enabled = false
	box.ResetOnSpawn = false
	local frame = Instance.new("Frame")
	frame.BackgroundTransparency = 1
	frame.Size = UDim2.fromScale(1, 1)
	frame.Parent = box
	local boxGlow = Instance.new("UIStroke")
	boxGlow.Thickness = 4
	boxGlow.Transparency = 0.6
	boxGlow.Color = Color3.new(1, 1, 1)
	boxGlow.Enabled = false
	boxGlow.Parent = frame
	local boxStroke = Instance.new("UIStroke")
	boxStroke.Thickness = 1.5
	boxStroke.Color = Color3.new(1, 1, 1)
	boxStroke.Parent = frame
	box.Parent = espFolder
	local label = Instance.new("BillboardGui")
	label.Name = plr.Name .. "_label"
	label.AlwaysOnTop = true
	label.Size = UDim2.fromOffset(240, 76)
	label.StudsOffset = Vector3.new(0, 4.2, 0)
	label.LightInfluence = 0
	label.Enabled = false
	label.ResetOnSpawn = false
	local nameText, nameGlow = newInfoLabel(label)
	nameText.Size = UDim2.fromOffset(240, 22)
	nameText.TextXAlignment = Enum.TextXAlignment.Center
	local healthText, healthGlow = newInfoLabel(label)
	local distText, distGlow = newInfoLabel(label)
	label.Parent = espFolder
	local healthGui = Instance.new("BillboardGui")
	healthGui.Name = plr.Name .. "_health"
	healthGui.AlwaysOnTop = true
	healthGui.Size = UDim2.fromOffset(90, 8)
	healthGui.StudsOffset = Vector3.new(0, 3.15, 0)
	healthGui.LightInfluence = 0
	healthGui.Enabled = false
	healthGui.ResetOnSpawn = false
	healthGui.Parent = espFolder
	local healthBg = Instance.new("Frame")
	healthBg.Name = "HealthBarBG"
	healthBg.AnchorPoint = Vector2.new(0.5, 0.5)
	healthBg.Position = UDim2.fromScale(0.5, 0.5)
	healthBg.Size = UDim2.fromOffset(64, 4)
	healthBg.BackgroundColor3 = Color3.fromRGB(18, 18, 18)
	healthBg.BackgroundTransparency = 0.12
	healthBg.BorderSizePixel = 0
	healthBg.Parent = healthGui
	local bgCorner = Instance.new("UICorner")
	bgCorner.CornerRadius = UDim.new(1, 0)
	bgCorner.Parent = healthBg
	local barStroke = Instance.new("UIStroke")
	barStroke.Thickness = 0.6
	barStroke.Transparency = 0.65
	barStroke.Color = Color3.new(1, 1, 1)
	barStroke.Parent = healthBg
	local healthFill = Instance.new("Frame")
	healthFill.Name = "HealthBarFill"
	healthFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
	healthFill.BorderSizePixel = 0
	healthFill.Size = UDim2.fromScale(1, 1)
	healthFill.Parent = healthBg
	local fillCorner = Instance.new("UICorner")
	fillCorner.CornerRadius = UDim.new(1, 0)
	fillCorner.Parent = healthFill
	local healthShine = Instance.new("Frame")
	healthShine.Name = "HealthBarShine"
	healthShine.BackgroundColor3 = Color3.new(1, 1, 1)
	healthShine.BackgroundTransparency = 0.78
	healthShine.BorderSizePixel = 0
	healthShine.Size = UDim2.new(1, 0, 0, 1)
	healthShine.Position = UDim2.fromOffset(0, 0)
	healthShine.Parent = healthFill
	espObjects[plr] = {
		box = box,
		stroke = boxStroke,
		boxGlow = boxGlow,
		label = label,
		nameText = nameText,
		nameGlow = nameGlow,
		healthText = healthText,
		healthGlow = healthGlow,
		distText = distText,
		distGlow = distGlow,
		healthGui = healthGui,
		healthBg = healthBg,
		healthFill = healthFill,
		barStroke = barStroke,
		active = false,
		baseColor = Color3.new(1, 1, 1),
		healthColor = Color3.new(1, 1, 1),
		distColor = Color3.new(1, 1, 1),
		fillColor = Color3.fromRGB(0, 255, 0),
	}
end
local function removeEsp(plr)
	local o = espObjects[plr]
	if not o then return end
	pcall(function() o.box:Destroy() end)
	pcall(function() o.label:Destroy() end)
	pcall(function() o.healthGui:Destroy() end)
	espObjects[plr] = nil
end
local function pickColor(idx, autoColor)
	local entry = PALETTE[idx]
	return entry and entry[2] or autoColor
end
local function hsv(h)
	return Color3.fromHSV(h % 1, 0.9, 1)
end
local function applyEspColors(o, t)
	if not o.active then return end
	local rgb = Cfg.ESPRGB
	local glow = Cfg.ESPGlow
	local base = t * Cfg.RGBSpeed
	local pulse = Cfg.GlowPulse and (0.5 + 0.5 * math.sin(t * 3)) or 0.5
	local glowT = 0.75 - 0.4 * pulse -- ความโปร่งของแสง (ยิ่งต่ำยิ่งสว่าง)
	local th = Cfg.GlowSize
	local cBox = rgb and hsv(base) or o.baseColor
	local cName = rgb and hsv(base + 0.08) or o.baseColor
	local cHealth = rgb and hsv(base + 0.16) or o.healthColor
	local cDist = rgb and hsv(base + 0.24) or o.distColor
	local cBar = rgb and hsv(base + 0.32) or Color3.new(1, 1, 1)
	o.stroke.Color = cBox
	o.boxGlow.Enabled = glow
	if glow then
		o.boxGlow.Color = cBox
		o.boxGlow.Thickness = th * 2
		o.boxGlow.Transparency = glowT
	end
	local function paintText(label, strokeObj, color)
		label.TextColor3 = color
		strokeObj.Enabled = glow
		label.TextStrokeTransparency = glow and 1 or 0.4
		if glow then
			strokeObj.Color = color
			strokeObj.Thickness = th
			strokeObj.Transparency = glowT
		end
	end
	paintText(o.nameText, o.nameGlow, cName)
	paintText(o.healthText, o.healthGlow, cHealth)
	paintText(o.distText, o.distGlow, cDist)
	if glow then
		o.barStroke.Color = cBar
		o.barStroke.Thickness = th
		o.barStroke.Transparency = glowT
	elseif rgb then
		o.barStroke.Color = cBar
		o.barStroke.Thickness = 1
		o.barStroke.Transparency = 0.3
	else
		o.barStroke.Color = Color3.new(1, 1, 1)
		o.barStroke.Thickness = 0.6
		o.barStroke.Transparency = 0.65
	end
	o.healthFill.BackgroundColor3 = (rgb and Cfg.RGBBarFill) and hsv(base + 0.4) or o.fillColor
end
local HALF_W, GAP = 116, 8
local INFO_Y = 22 -- แถวของเลือด/ระยะอยู่ใต้ชื่อ
local function updateEsp()
	local enemyColor = PALETTE[Cfg.ColorEnemy][2]
	local friendColor = PALETTE[Cfg.ColorFriend][2]
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			createEsp(plr)
			local o = espObjects[plr]
			local char, hum = getAlive(plr)
			local root = char and char:FindFirstChild("HumanoidRootPart")
			if Cfg.ESP and char and root then
				local color = isFriendly(plr) and friendColor or enemyColor
				local dist = (Camera.CFrame.Position - root.Position).Magnitude
				o.active = true
				o.baseColor = color
				o.healthColor = pickColor(Cfg.HealthTextColor, color)
				o.distColor = pickColor(Cfg.DistTextColor, color)
				o.box.Adornee = root
				o.box.Enabled = Cfg.ESPBox
				o.label.Adornee = root
				o.nameText.Text = Cfg.ESPName and plr.Name or ""
				o.nameText.TextSize = Cfg.ESPTextSize
				local maxHealth = math.max(hum.MaxHealth, 1)
				local healthPct = math.clamp(hum.Health / maxHealth, 0, 1)
				local showH = Cfg.ESPHealthText
				local showD = Cfg.ESPDist
				local hx, hw, hAlign = 0, 240, Enum.TextXAlignment.Center
				local dx, dw, dAlign = 0, 240, Enum.TextXAlignment.Center
				if showH and showD then
					hx, hw, hAlign = 120 - GAP / 2 - HALF_W, HALF_W, Enum.TextXAlignment.Right
					dx, dw, dAlign = 120 + GAP / 2, HALF_W, Enum.TextXAlignment.Left
				end
				o.healthText.Visible = showH
				o.healthText.Text = string.format("%d%%", math.floor(healthPct * 100 + 0.5))
				o.healthText.TextSize = Cfg.HealthTextSize
				o.healthText.TextXAlignment = hAlign
				o.healthText.Size = UDim2.fromOffset(hw, 20)
				o.healthText.Position = UDim2.fromOffset(hx + Cfg.HealthTextX, INFO_Y + Cfg.HealthTextY)
				o.distText.Visible = showD
				o.distText.Text = math.floor(dist) .. "m"
				o.distText.TextSize = Cfg.DistTextSize
				o.distText.TextXAlignment = dAlign
				o.distText.Size = UDim2.fromOffset(dw, 20)
				o.distText.Position = UDim2.fromOffset(dx + Cfg.DistTextX, INFO_Y + Cfg.DistTextY)
				o.label.Enabled = Cfg.ESPName or showH or showD
				o.healthGui.Adornee = root
				o.healthFill.Size = UDim2.fromScale(healthPct, 1)
				o.fillColor = Color3.fromRGB(255, 0, 0):Lerp(Color3.fromRGB(0, 255, 0), healthPct)
				o.healthBg.Visible = Cfg.ESPHealth
				o.healthGui.Enabled = Cfg.ESPHealth
				applyEspColors(o, os.clock())
			else
				o.active = false
				o.box.Enabled = false
				o.label.Enabled = false
				o.healthBg.Visible = false
				o.healthGui.Enabled = false
			end
		end
	end
end
connect(Players.PlayerRemoving, removeEsp)
connect(RunService.RenderStepped, function()
	if not Cfg.ESP then return end
	if not (Cfg.ESPRGB or (Cfg.ESPGlow and Cfg.GlowPulse)) then return end
	local t = os.clock()
	for _, o in pairs(espObjects) do
		if o.active then
			applyEspColors(o, t)
		end
	end
end)
do
	local acc = 0
	connect(RunService.Heartbeat, function(dt)
		acc += dt
		if acc < 0.1 then return end
		acc = 0
		Camera = Workspace.CurrentCamera
		if Camera then
			pcall(updateEsp)
		end
	end)
end
--========================
-- PROTECT TIMER ESP (FIXED)
-- รองรับ Attribute ที่อยู่ทั้ง Player และ Character
--========================
local protectTags = {}

local function removeProtectTag(plr)
    local tag = protectTags[plr]
    if tag then
        pcall(function() tag:Destroy() end)
        protectTags[plr] = nil
    end
end

local function createProtectTag(plr)
    if plr == LP or protectTags[plr] then return end

    local tag = Instance.new("BillboardGui")
    tag.Name = plr.Name .. "_ProtectTimer"
    tag.Size = UDim2.fromOffset(220, 34)
    tag.StudsOffset = Vector3.new(0, 5.2, 0)
    tag.AlwaysOnTop = true
    tag.LightInfluence = 0
    tag.Enabled = false
    tag.ResetOnSpawn = false
    tag.Parent = espFolder

    local text = Instance.new("TextLabel")
    text.Name = "Text"
    text.Size = UDim2.fromScale(1, 1)
    text.BackgroundTransparency = 1
    text.Font = Enum.Font.GothamBold
    text.TextSize = 15
    text.TextColor3 = Color3.fromRGB(255, 220, 50)
    text.TextStrokeColor3 = Color3.new(0, 0, 0)
    text.TextStrokeTransparency = 0
    text.Text = ""
    text.Parent = tag

    protectTags[plr] = tag
end

local function getProtectUntil(plr, char)
    -- ชื่อหลักที่พบจากระบบเกม
    local v = plr:GetAttribute("WarzProtectUntil")
    if typeof(v) == "number" then return v, "Player.WarzProtectUntil" end

    if char then
        v = char:GetAttribute("WarzProtectUntil")
        if typeof(v) == "number" then return v, "Character.WarzProtectUntil" end
    end

    -- fallback: หา attribute ที่ชื่อมี protect และเป็นตัวเลข
    local function scan(inst, prefix)
        if not inst then return nil end
        for name, value in pairs(inst:GetAttributes()) do
            local low = string.lower(tostring(name))
            if typeof(value) == "number" and string.find(low, "protect", 1, true) then
                return value, prefix .. "." .. tostring(name)
            end
        end
    end

    local value, source = scan(plr, "Player")
    if value ~= nil then return value, source end
    return scan(char, "Character")
end

local function protectRemaining(value)
    if typeof(value) ~= "number" then return nil end

    -- เกมอาจเก็บเป็น timestamp ของ GetServerTimeNow หรือ Unix timestamp
    local serverNow = Workspace:GetServerTimeNow()
    local r = value - serverNow
    if r > -86400 and r < 86400 * 30 then
        return r
    end

    local unixNow = DateTime.now().UnixTimestampMillis / 1000
    return value - unixNow
end

local protectDebugPrinted = {}
local function updateProtectTag(plr)
    if plr == LP then return end
    createProtectTag(plr)

    local tag = protectTags[plr]
    if not tag then return end

    local char = plr.Character
    local adornee = char and (char:FindFirstChild("Head") or char:FindFirstChild("HumanoidRootPart"))
    if not adornee then
        tag.Enabled = false
        return
    end
    tag.Adornee = adornee

    local protectUntil, source = getProtectUntil(plr, char)
    if typeof(protectUntil) ~= "number" then
        tag.Enabled = false
        return
    end

    if not protectDebugPrinted[plr] then
        protectDebugPrinted[plr] = true
        print(string.format("[Protect Timer] %s | %s = %s", plr.Name, tostring(source), tostring(protectUntil)))
    end

    local remaining = protectRemaining(protectUntil)
    if remaining and remaining > 0 then
        tag.Enabled = true
        tag.Text.Text = string.format("PROTECT %.1fs", remaining)
    else
        tag.Enabled = false
    end
end

for _, plr in ipairs(Players:GetPlayers()) do
    createProtectTag(plr)
end

connect(Players.PlayerAdded, createProtectTag)
connect(Players.PlayerRemoving, function(plr)
    protectDebugPrinted[plr] = nil
    removeProtectTag(plr)
end)

-- ใช้ Heartbeat 10 ครั้ง/วินาที เพียงพอสำหรับ timer และเบากว่า RenderStepped
local protectAcc = 0
connect(RunService.Heartbeat, function(dt)
    protectAcc += dt
    if protectAcc < 0.1 then return end
    protectAcc = 0
    for _, plr in ipairs(Players:GetPlayers()) do
        pcall(updateProtectTag, plr)
    end
end)

print("[Protect Timer FIX] LOADED")

local ITEM_NAMES = {}
local function prettyItem(id)
	if type(id) ~= "string" or id == "" then return "-" end
	return ITEM_NAMES[id] or (id:gsub("_", " "))
end
local function readEquip(plr)
	local char = plr.Character
	if not char then return nil end
	local held = char:GetAttribute("WarzCatalogId")
	if type(held) ~= "string" or held == "" then
		held = plr:GetAttribute("CSGO_CatalogId")
	end
	return {
		held = held,
		class = char:GetAttribute("HeldWeapon"),
		primary = char:GetAttribute("WarzPrimarySlotId"),
		melee = char:GetAttribute("WarzMeleeSlotId"),
		helmet = char:GetAttribute("WarzHelmetId"),
		armor = char:GetAttribute("WarzArmorId"),
	}
end
local HOVER_PARTS = { "Head", "UpperTorso", "LowerTorso", "HumanoidRootPart" }
local function findHovered(cursor)
	local best, bestD = nil, Cfg.HoverRadius
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= LP then
			local char = getAlive(plr)
			if char then
				for _, name in ipairs(HOVER_PARTS) do
					local p = char:FindFirstChild(name)
					if p then
						local pos, on = Camera:WorldToViewportPoint(p.Position)
						if on then
							local d = (Vector2.new(pos.X, pos.Y) - cursor).Magnitude
							if d < bestD then best, bestD = plr, d end
						end
					end
				end
			end
		end
	end
	return best
end
local hoverFrame = Instance.new("Frame")
hoverFrame.Name = "HoverInfo"
hoverFrame.Active = false
hoverFrame.BackgroundColor3 = Color3.fromRGB(24, 24, 24)
hoverFrame.BackgroundTransparency = 0.1
hoverFrame.BorderSizePixel = 0
hoverFrame.AnchorPoint = Vector2.new(1, 0.5)
hoverFrame.Position = UDim2.new(1, -16, 0.5, 0) -- กลางจอด้านขวา
hoverFrame.Size = UDim2.fromOffset(220, 0)
hoverFrame.AutomaticSize = Enum.AutomaticSize.Y
hoverFrame.Visible = false
hoverFrame.ZIndex = 50
hoverFrame.Parent = gui
do
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, 6)
	c.Parent = hoverFrame
	local st = Instance.new("UIStroke")
	st.Color = Color3.fromRGB(90, 90, 90)
	st.Thickness = 1
	st.Transparency = 0.3
	st.Parent = hoverFrame
	local pad = Instance.new("UIPadding")
	pad.PaddingLeft = UDim.new(0, 8)
	pad.PaddingRight = UDim.new(0, 8)
	pad.PaddingTop = UDim.new(0, 6)
	pad.PaddingBottom = UDim.new(0, 6)
	pad.Parent = hoverFrame
	local lay = Instance.new("UIListLayout")
	lay.Padding = UDim.new(0, 2)
	lay.SortOrder = Enum.SortOrder.LayoutOrder
	lay.Parent = hoverFrame
end
local function newHoverRow(order, color)
	local t = Instance.new("TextLabel")
	t.Active = false
	t.BackgroundTransparency = 1
	t.Size = UDim2.new(1, 0, 0, 16)
	t.Font = Enum.Font.GothamMedium
	t.TextSize = 13
	t.TextColor3 = color
	t.TextXAlignment = Enum.TextXAlignment.Left
	t.TextTruncate = Enum.TextTruncate.AtEnd
	t.TextStrokeTransparency = 0.6
	t.LayoutOrder = order
	t.ZIndex = 51
	t.Text = ""
	t.Parent = hoverFrame
	return t
end
local hHeld = newHoverRow(1, Color3.fromRGB(255, 170, 60))
local hHelmet = newHoverRow(2, Color3.fromRGB(120, 200, 255))
local hArmor = newHoverRow(3, Color3.fromRGB(170, 140, 255))
local hoverPlr, hoverAcc = nil, 0
connect(RunService.RenderStepped, function(dt)
	Camera = Workspace.CurrentCamera
	if not (Cfg.HoverInfo and Camera) then
		hoverFrame.Visible = false
		return
	end
	hoverAcc += dt
	if hoverAcc >= 0.05 then
		hoverAcc = 0
		hoverPlr = findHovered(getCrosshair())
	end
	local plr = hoverPlr
	local char
	if plr and plr.Parent then char = getAlive(plr) end
	local eq = char and readEquip(plr)
	if not eq then
		hoverFrame.Visible = false
		return
	end
	local heldText = prettyItem(eq.held)
	if type(eq.class) == "string" and eq.class ~= "" and heldText ~= "-" then
		heldText = heldText .. " (" .. eq.class .. ")"
	end
	hHeld.Text = "Weapon: " .. heldText
	hHelmet.Text = "Helmet: " .. prettyItem(eq.helmet)
	hArmor.Text = "Armor: " .. prettyItem(eq.armor)
	hHeld.Visible = Cfg.HoverWeapon
	hHelmet.Visible = Cfg.HoverHelmet
	hArmor.Visible = Cfg.HoverArmor
	local size = Cfg.HoverTextSize
	for _, row in ipairs({ hHeld, hHelmet, hArmor }) do
		row.TextSize = size
		row.Size = UDim2.new(1, 0, 0, size + 4)
	end
	hoverFrame.Visible = Cfg.HoverWeapon or Cfg.HoverHelmet or Cfg.HoverArmor
end)
local AutoLootHoldingE = false
local AutoLootHoldStarted = 0
local AutoLootNextCheck = 0
local AutoLootStatusText = "Ready"
local AutoLootStatusLabel = nil
local function autoLootPressE()
	if AutoLootHoldingE then return end
	AutoLootHoldingE = true
	AutoLootHoldStarted = tick()
	pcall(function()
		VirtualInputManager:SendKeyEvent(true, Enum.KeyCode.E, false, game)
	end)
end
local function autoLootReleaseE()
	if not AutoLootHoldingE then return end
	AutoLootHoldingE = false
	pcall(function()
		VirtualInputManager:SendKeyEvent(false, Enum.KeyCode.E, false, game)
	end)
end
local function autoLootFindEPrompt()
	local playerGui = LP:FindFirstChild("PlayerGui")
	if not playerGui then return false end
	for _, obj in ipairs(playerGui:GetDescendants()) do
		if (obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox")) and obj.Visible then
			local text = tostring(obj.Text or ""):gsub("%s+", "")
			if text == "E" or text == "[E]" or text == "(E)" then
				return true
			end
		end
	end
	return false
end
connect(RunService.Heartbeat, function()
	if not Cfg.AutoLoot then
		autoLootReleaseE()
		AutoLootStatusText = "Disabled"
		if AutoLootStatusLabel and AutoLootStatusLabel.Parent then
			AutoLootStatusLabel.Text = "Status: " .. AutoLootStatusText
		end
		return
	end
	local now = tick()
	if AutoLootHoldingE then
		AutoLootStatusText = "Holding E..."
		if now - AutoLootHoldStarted >= Cfg.AutoLootHoldTime then
			autoLootReleaseE()
			AutoLootNextCheck = now + 0.15
			AutoLootStatusText = "Collected / waiting"
		end
	elseif now >= AutoLootNextCheck then
		AutoLootNextCheck = now + Cfg.AutoLootCheckDelay
		if autoLootFindEPrompt() then
			autoLootPressE()
			AutoLootStatusText = "E found - collecting"
		else
			AutoLootStatusText = "Waiting for E prompt"
		end
	end
	if AutoLootStatusLabel and AutoLootStatusLabel.Parent then
		AutoLootStatusLabel.Text = "Status: " .. AutoLootStatusText
	end
end)
local AutoHealHealing = false
local AutoHealStatusText = "Ready"
local AutoHealStatusLabel = nil
local AutoHealRemotes = ReplicatedStorage:FindFirstChild("Remotes")
local AutoHealUseItem = AutoHealRemotes and AutoHealRemotes:FindFirstChild("UseItem")
local AutoHealSwitchWeapon = AutoHealRemotes and AutoHealRemotes:FindFirstChild("SwitchWeaponRequest")
local function autoHealGetHumanoid()
	local char = LP.Character
	if not char then return nil end
	return char:FindFirstChildOfClass("Humanoid")
end
local function autoHealCanUse()
	local cd = LP:GetAttribute("WarzMedCdLeft")
	return not (typeof(cd) == "number" and cd > 0)
end
local function autoHealUseBandage()
	if not AutoHealUseItem or not autoHealCanUse() then return false end
	AutoHealUseItem:FireServer(3, "BandagesDX")
	return true
end
local function autoHealUseMedkit()
	if not AutoHealUseItem or not autoHealCanUse() then return false end
	AutoHealUseItem:FireServer(6, "Medkit")
	return true
end
local function autoHealUse(percent)
	if Cfg.AutoHealMode == "BandagesDX" then
		return autoHealUseBandage(), "BandagesDX"
	elseif Cfg.AutoHealMode == "Medkit" then
		return autoHealUseMedkit(), "Medkit"
	elseif percent <= Cfg.AutoHealMedkitThreshold then
		return autoHealUseMedkit(), "Medkit"
	else
		return autoHealUseBandage(), "BandagesDX"
	end
end
local function autoHealDo(percent)
	if AutoHealHealing or not autoHealCanUse() then return end
	AutoHealHealing = true
	AutoHealStatusText = "Healing..."
	local ok, used, itemName = pcall(function()
		local didUse, name = autoHealUse(percent)
		return true, didUse, name
	end)
	if ok and used then
		AutoHealStatusText = "Used: " .. tostring(itemName)
		task.wait(Cfg.AutoHealWeaponDelay)
		if LP.Character and AutoHealSwitchWeapon then
			AutoHealSwitchWeapon:FireServer(1)
		end
	else
		AutoHealStatusText = "Cooldown / item unavailable"
	end
	AutoHealHealing = false
end
do
	local acc = 0
	connect(RunService.Heartbeat, function(dt)
		acc += dt
		if acc < Cfg.AutoHealCheckDelay then return end
		acc = 0
		local hum = autoHealGetHumanoid()
	if not hum then
		AutoHealStatusText = "No character"
		return
	end
	local maxHp = hum.MaxHealth
	if maxHp <= 0 then return end
	local hp = hum.Health
	local percent = (hp / maxHp) * 100
	local cd = LP:GetAttribute("WarzMedCdLeft") or 0
	if AutoHealStatusLabel and AutoHealStatusLabel.Parent then
		AutoHealStatusLabel.Text = string.format(
			"HP: %.0f / %.0f (%.0f%%)\nCD: %.1f | %s",
			hp, maxHp, percent, cd, AutoHealStatusText
		)
	end
	if Cfg.AutoHeal
		and not AutoHealHealing
		and hp > 0
		and percent <= Cfg.AutoHealHP
	then
		task.spawn(autoHealDo, percent)
		end
	end)
end
local TweenService = game:GetService("TweenService")
local UI_FONT = Enum.Font.Gotham
local C_BG = Color3.fromRGB(29, 29, 29)
local C_TITLE = Color3.fromRGB(55, 55, 55)
local C_BTN = Color3.fromRGB(22, 22, 22)
local C_WHITE = Color3.new(1, 1, 1)
local C_STROKE = Color3.fromRGB(90, 90, 90)
local ASSET = "http://www.roblox.com/asset/?id="
local IMG = {
	blur = ASSET .. "6758962034",
}
local function make(class, props, parent)
	local o = Instance.new(class)
	for k, v in pairs(props) do
		pcall(function() o[k] = v end) -- ข้ามคุณสมบัติที่ไม่รองรับ จะได้ไม่หยุดสร้าง UI
	end
	o.Parent = parent
	return o
end
local function corner(parent, radius)
	local c = Instance.new("UICorner")
	c.CornerRadius = UDim.new(0, radius or 6)
	c.Parent = parent
	return c
end
local function stroke(parent, thickness, transparency)
	local s = Instance.new("UIStroke")
	s.Color = C_STROKE
	s.Thickness = thickness or 1
	s.Transparency = transparency or 0.5
	s.Parent = parent
	return s
end
local root = make("Frame", {
	Name = "UI",
	BackgroundTransparency = 1,
	BorderSizePixel = 0,
	Size = UDim2.fromScale(1, 1),
	Visible = true,
}, gui)
local hint = make("TextLabel", {
	Name = "Hint",
	BackgroundTransparency = 1,
	Position = UDim2.new(0.5, -150, 0, 12),
	Size = UDim2.fromOffset(300, 28),
	Font = UI_FONT,
	Text = "RightShift: Menu",
	TextColor3 = C_WHITE,
	TextSize = 14,
	TextTransparency = 1,
}, gui)
local PW, ROW = 190, 27
local function rowY(i)
	return 32 + (i - 1) * ROW
end
local uiRefresh = {}
local function refreshUI()
	for _, f in ipairs(uiRefresh) do
		pcall(f)
	end
end
local function makeDraggable(handle, target)
	local dragging = false
	local dragStart
	local startPos
	connect(handle.InputBegan, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = true
			dragStart = input.Position
			startPos = target.Position
		end
	end)
	connect(UIS.InputChanged, function(input)
		if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement
			or input.UserInputType == Enum.UserInputType.Touch) then
			local d = input.Position - dragStart
			target.Position = UDim2.new(
				startPos.X.Scale,
				startPos.X.Offset + d.X,
				startPos.Y.Scale,
				startPos.Y.Offset + d.Y
			)
		end
	end)
	connect(UIS.InputEnded, function(input)
		if input.UserInputType == Enum.UserInputType.MouseButton1
			or input.UserInputType == Enum.UserInputType.Touch then
			dragging = false
		end
	end)
end
local function makePanel(name, titleText, rows, pos)
	local panel = make("Frame", {
		Name = name,
		Active = true,
		BackgroundColor3 = C_BG,
		BackgroundTransparency = 0.08,
		BorderSizePixel = 0,
		Position = pos,
		Size = UDim2.fromOffset(PW, 34 + rows * ROW + 8),
	}, root)
	corner(panel, 6)
	stroke(panel, 1, 0.35)
	local bar = make("Frame", {
		Name = "Title",
		Active = true,
		BackgroundColor3 = C_TITLE,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		Size = UDim2.new(1, 0, 0, 24),
	}, panel)
	corner(bar, 6)
	make("TextLabel", {
		BackgroundTransparency = 1,
		Size = UDim2.new(1, -48, 1, 0),
		Position = UDim2.fromOffset(12, 0),
		Font = UI_FONT,
		Text = titleText,
		TextColor3 = C_WHITE,
		TextSize = 14,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, bar)
	makeDraggable(bar, panel)
	return panel, bar
end
local function addTitleButton(bar, text, rightOffset, onClick)
	local b = make("TextButton", {
		BackgroundColor3 = C_BTN,
		BackgroundTransparency = 0.15,
		BorderSizePixel = 0,
		AnchorPoint = Vector2.new(1, 0),
		Position = UDim2.new(1, rightOffset, 0, 4),
		Size = UDim2.fromOffset(16, 16),
		Text = text,
		Font = UI_FONT,
		TextColor3 = C_WHITE,
		TextSize = 11,
	}, bar)
	corner(b, 4)
	connect(b.MouseButton1Click, onClick)
	return b
end
local function cfgAccess(key)
	return function()
		return Cfg[key]
	end, function(v)
		Cfg[key] = v
	end
end
local function styleSmallButton(b)
	b.BackgroundColor3 = C_BTN
	b.BackgroundTransparency = 0.12
	b.BorderSizePixel = 0
	b.Font = UI_FONT
	b.TextColor3 = C_WHITE
	b.TextSize = 12
	b.AutoButtonColor = true
	corner(b, 5)
end
local function rowLabel(p, i, text, width)
	return make("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(14, rowY(i)),
		Size = UDim2.fromOffset(width, 20),
		Font = UI_FONT,
		Text = text,
		TextColor3 = C_WHITE,
		TextSize = 12,
		TextXAlignment = Enum.TextXAlignment.Left,
	}, p)
end
local function addCheckRow(p, i, text, get, set)
	rowLabel(p, i, text, 130)
	local box = make("TextButton", {
		BackgroundColor3 = C_BTN,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(PW - 32, rowY(i) + 1),
		Size = UDim2.fromOffset(18, 18),
		Text = get() and "✓" or "",
		Font = UI_FONT,
		TextColor3 = C_WHITE,
		TextSize = 12,
	}, p)
	corner(box, 4)
	local function refresh()
		box.Text = get() and "✓" or ""
	end
	uiRefresh[#uiRefresh + 1] = refresh
	connect(box.MouseButton1Click, function()
		set(not get())
		refresh()
		saveSoon()
	end)
end
local function addStepRow(p, i, textName, key, step, min, max)
	local lbl = rowLabel(p, i, "", 104)
	local function refresh()
		lbl.Text = textName .. ": " .. tostring(math.floor(Cfg[key] * 100 + 0.5) / 100)
	end
	refresh()
	uiRefresh[#uiRefresh + 1] = refresh
	local minus = make("TextButton", {
		Position = UDim2.fromOffset(PW - 62, rowY(i)),
		Size = UDim2.fromOffset(26, 20),
		Text = "-",
	}, p)
	styleSmallButton(minus)
	local plus = make("TextButton", {
		Position = UDim2.fromOffset(PW - 30, rowY(i)),
		Size = UDim2.fromOffset(26, 20),
		Text = "+",
	}, p)
	styleSmallButton(plus)
	connect(minus.MouseButton1Click, function()
		Cfg[key] = math.floor(math.clamp(Cfg[key] - step, min, max) * 100 + 0.5) / 100
		refresh()
		saveSoon()
	end)
	connect(plus.MouseButton1Click, function()
		Cfg[key] = math.floor(math.clamp(Cfg[key] + step, min, max) * 100 + 0.5) / 100
		refresh()
		saveSoon()
	end)
end
local function addButtonRow(p, i, text, onClick)
	local b = make("TextButton", {
		Position = UDim2.fromOffset(14, rowY(i)),
		Size = UDim2.fromOffset(PW - 28, 20),
		Text = text,
	}, p)
	styleSmallButton(b)
	connect(b.MouseButton1Click, function()
		onClick(b)
	end)
	return b
end
local function addColorRow(p, i, textName, key)
	local b
	local function refresh()
		local entry = PALETTE[Cfg[key]]
		b.Text = textName .. ": " .. entry[1]
		b.TextColor3 = entry[2]
	end
	b = addButtonRow(p, i, "", function()
		Cfg[key] = Cfg[key] % #PALETTE + 1
		refresh()
		saveSoon()
	end)
	refresh()
	uiRefresh[#uiRefresh + 1] = refresh
end
local function addAutoColorRow(p, i, textName, key)
	local b
	local function refresh()
		local entry = PALETTE[Cfg[key]]
		if entry then
			b.Text = textName .. ": " .. entry[1]
			b.TextColor3 = entry[2]
		else
			b.Text = textName .. ": Auto"
			b.TextColor3 = C_WHITE
		end
	end
	b = addButtonRow(p, i, "", function()
		Cfg[key] = (Cfg[key] + 1) % (#PALETTE + 1)
		refresh()
		saveSoon()
	end)
	refresh()
	uiRefresh[#uiRefresh + 1] = refresh
end
local function addResetRow(p, i, keys)
	addButtonRow(p, i, "Reset", function(b)
		for _, k in ipairs(keys) do
			Cfg[k] = Defaults[k]
		end
		refreshUI()
		saveSoon()
		b.Text = "Reset แล้ว"
		task.delay(1, function()
			if b.Parent then b.Text = "Reset" end
		end)
	end)
end
local main, mainBar = makePanel(
	"Basic",
	"x2spiritz",
	10,
	UDim2.new(1, -205, 1, -345)
)
addTitleButton(mainBar, "×", -8, unload)
addTitleButton(mainBar, "−", -30, function()
	root.Visible = false
	hint.TextTransparency = 0
	task.delay(2.5, function()
		if hint and hint.Parent then
			hint.TextTransparency = 1
		end
	end)
end)
addCheckRow(main, 1, "Player ESP", cfgAccess("ESP"))
addCheckRow(main, 2, "Draw FOV", cfgAccess("ShowFOV"))
addCheckRow(main, 3, "Wall Check", cfgAccess("WallCheck"))
addCheckRow(main, 4, "Aimbot (RMB)", cfgAccess("Aimbot"))
addCheckRow(main, 5, "Party Check", cfgAccess("PartyCheck"))
addCheckRow(main, 6, "Mouse Mode",
	function() return Cfg.Mode == "Mouse" and mmr ~= nil end,
	function(v) Cfg.Mode = (v and mmr) and "Mouse" or "Camera" end
)
addCheckRow(main, 7, "Auto Execute",
	function() return Cfg.AutoRun end,
	function(v)
		Cfg.AutoRun = v
		setupAutoRun()
	end
)
local espPanel, espBar = makePanel(
	"esp options",
	"esp options",
	9,
	UDim2.new(1, -410, 1, -345)
)
espPanel.Visible = false
addTitleButton(espBar, "×", -8, function()
	espPanel.Visible = false
end)
addCheckRow(espPanel, 1, "Box", cfgAccess("ESPBox"))
addCheckRow(espPanel, 2, "Name", cfgAccess("ESPName"))
addStepRow(espPanel, 3, "Name Size", "ESPTextSize", 1, 8, 24)
addColorRow(espPanel, 4, "Enemy", "ColorEnemy")
addColorRow(espPanel, 5, "Friend", "ColorFriend")
local healthPanel, healthBar = makePanel(
	"health options",
	"health options",
	8,
	UDim2.new(1, -820, 1, -345)
)
healthPanel.Visible = false
addTitleButton(healthBar, "×", -8, function()
	healthPanel.Visible = false
end)
addCheckRow(healthPanel, 1, "Health Bar", cfgAccess("ESPHealth"))
addCheckRow(healthPanel, 2, "Health Text", cfgAccess("ESPHealthText"))
addStepRow(healthPanel, 3, "Text Size", "HealthTextSize", 1, 8, 24)
addAutoColorRow(healthPanel, 4, "Text Color", "HealthTextColor")
addStepRow(healthPanel, 5, "Pos X", "HealthTextX", 2, -150, 150)
addStepRow(healthPanel, 6, "Pos Y", "HealthTextY", 2, -150, 150)
addResetRow(healthPanel, 7, { "HealthTextSize", "HealthTextColor", "HealthTextX", "HealthTextY" })
local distPanel, distBar = makePanel(
	"distance options",
	"distance options",
	7,
	UDim2.new(1, -1025, 1, -345)
)
distPanel.Visible = false
addTitleButton(distBar, "×", -8, function()
	distPanel.Visible = false
end)
addCheckRow(distPanel, 1, "Distance", cfgAccess("ESPDist"))
addStepRow(distPanel, 2, "Text Size", "DistTextSize", 1, 8, 24)
addAutoColorRow(distPanel, 3, "Text Color", "DistTextColor")
addStepRow(distPanel, 4, "Pos X", "DistTextX", 2, -150, 150)
addStepRow(distPanel, 5, "Pos Y", "DistTextY", 2, -150, 150)
addResetRow(distPanel, 6, { "DistTextSize", "DistTextColor", "DistTextX", "DistTextY" })
local rgbPanel, rgbBar = makePanel(
	"rgb options",
	"rgb / glow options",
	7,
	UDim2.new(1, -410, 1, -584)
)
rgbPanel.Visible = false
addTitleButton(rgbBar, "×", -8, function()
	rgbPanel.Visible = false
end)
addCheckRow(rgbPanel, 1, "RGB ESP", cfgAccess("ESPRGB"))
addCheckRow(rgbPanel, 2, "Glow", cfgAccess("ESPGlow"))
addCheckRow(rgbPanel, 3, "Glow Pulse", cfgAccess("GlowPulse"))
addStepRow(rgbPanel, 4, "RGB Speed", "RGBSpeed", 0.1, 0.1, 3)
addStepRow(rgbPanel, 5, "Glow Size", "GlowSize", 1, 1, 6)
addCheckRow(rgbPanel, 6, "RGB Bar Fill", cfgAccess("RGBBarFill"))
addResetRow(rgbPanel, 7, { "ESPRGB", "ESPGlow", "GlowPulse", "RGBSpeed", "GlowSize", "RGBBarFill" })
local hoverPanel, hoverBar = makePanel(
	"hover options",
	"hover info options",
	7,
	UDim2.new(1, -820, 1, -560)
)
hoverPanel.Visible = false
addTitleButton(hoverBar, "×", -8, function()
	hoverPanel.Visible = false
end)
addCheckRow(hoverPanel, 1, "Hover Info", cfgAccess("HoverInfo"))
addStepRow(hoverPanel, 2, "Radius", "HoverRadius", 5, 15, 150)
addCheckRow(hoverPanel, 3, "Weapon", cfgAccess("HoverWeapon"))
addCheckRow(hoverPanel, 4, "Helmet", cfgAccess("HoverHelmet"))
addCheckRow(hoverPanel, 5, "Armor", cfgAccess("HoverArmor"))
addStepRow(hoverPanel, 6, "Text Size", "HoverTextSize", 1, 10, 20)
addResetRow(hoverPanel, 7, {
	"HoverInfo", "HoverRadius", "HoverWeapon",
	"HoverHelmet", "HoverArmor", "HoverTextSize",
})
addButtonRow(espPanel, 6, "Health Options", function()
	healthPanel.Visible = not healthPanel.Visible
end)
addButtonRow(espPanel, 7, "Distance Options", function()
	distPanel.Visible = not distPanel.Visible
end)
addButtonRow(espPanel, 8, "RGB / Glow Options", function()
	rgbPanel.Visible = not rgbPanel.Visible
end)
addButtonRow(espPanel, 9, "Hover Info Options", function()
	hoverPanel.Visible = not hoverPanel.Visible
end)
local setPanel, setBar = makePanel(
	"Settings",
	"Settings",
	11,
	UDim2.new(1, -615, 1, -345)
)
setPanel.Visible = false
addTitleButton(setBar, "×", -8, function()
	setPanel.Visible = false
end)
addStepRow(setPanel, 1, "FOV", "FOV", 10, 30, 600)
addStepRow(setPanel, 2, "Speed", "Smooth", 2, 1, 100)
addStepRow(setPanel, 3, "Gain", "Gain", 0.1, 0.3, 3)
addStepRow(setPanel, 4, "Max Dist", "MaxDist", 100, 100, 3000)
addStepRow(setPanel, 5, "Cross X", "OffX", 10, -600, 600)
addStepRow(setPanel, 6, "Cross Y", "OffY", 10, -600, 600)
do
	local aimBtn
	aimBtn = addButtonRow(setPanel, 7, "", function()
		local idx = table.find(AIM_PARTS, Cfg.AimPart) or 1
		Cfg.AimPart = AIM_PARTS[idx % #AIM_PARTS + 1]
		aimBtn.Text = "Aim Part: " .. Cfg.AimPart
		lockedPlr = nil
		saveSoon()
	end)
	aimBtn.Text = "Aim Part: " .. Cfg.AimPart
	uiRefresh[#uiRefresh + 1] = function()
		aimBtn.Text = "Aim Part: " .. Cfg.AimPart
	end
end
addCheckRow(setPanel, 8, "Debug Info", cfgAccess("Debug"))
addButtonRow(setPanel, 9, canFile and "Save Config" or "Save Config (ไม่รองรับ)", function(b)
	local ok = saveConfig()
	b.Text = ok and "Saved!" or "Save failed"
	task.delay(1.2, function()
		if b.Parent then b.Text = "Save Config" end
	end)
end)
addButtonRow(setPanel, 10, canFile and "Load Config" or "Load Config (ไม่รองรับ)", function(b)
	local ok = loadConfig()
	if ok then refreshUI() end -- อัปเดตเครื่องหมาย ✓ / ตัวเลข / สี ให้ตรงค่าที่โหลด
	b.Text = ok and "Loaded!" or "Load failed"
	task.delay(1.2, function()
		if b.Parent then b.Text = "Load Config" end
	end)
end)
addButtonRow(setPanel, 11, "Reset Config", function(b)
	if canFile and delfile and isfile and isfile(CONFIG_FILE) then
		pcall(delfile, CONFIG_FILE)
	end
	b.Text = "Reset แล้ว - รันใหม่"
	task.delay(2, function()
		if b.Parent then b.Text = "Reset Config" end
	end)
end)
addButtonRow(main, 8, "ESP Options", function()
	espPanel.Visible = not espPanel.Visible
end)
addButtonRow(main, 9, "Settings", function()
	setPanel.Visible = not setPanel.Visible
end)
local autoHealPanel, autoHealBar = makePanel(
	"AutoHeal",
	"AUTO HEAL",
	10,
	UDim2.new(1, -410, 1, -345)
)
autoHealPanel.Visible = false
addTitleButton(autoHealBar, "×", -8, function()
	autoHealPanel.Visible = false
end)
addCheckRow(autoHealPanel, 1, "Enable Auto Heal", cfgAccess("AutoHeal"))
do
	local modeBtn
	local function refreshMode()
		modeBtn.Text = "Mode: " .. Cfg.AutoHealMode
	end
	modeBtn = addButtonRow(autoHealPanel, 2, "", function()
		if Cfg.AutoHealMode == "Auto" then
			Cfg.AutoHealMode = "BandagesDX"
		elseif Cfg.AutoHealMode == "BandagesDX" then
			Cfg.AutoHealMode = "Medkit"
		else
			Cfg.AutoHealMode = "Auto"
		end
		refreshMode()
		saveSoon()
	end)
	refreshMode()
	uiRefresh[#uiRefresh + 1] = refreshMode
end
addStepRow(autoHealPanel, 3, "Heal HP", "AutoHealHP", 5, 1, 99)
addStepRow(autoHealPanel, 4, "Check Delay", "AutoHealCheckDelay", 0.05, 0.05, 1)
addStepRow(autoHealPanel, 5, "Weapon Delay", "AutoHealWeaponDelay", 0.1, 0, 5)
addStepRow(autoHealPanel, 6, "Medkit At", "AutoHealMedkitThreshold", 5, 1, 99)
AutoHealStatusLabel = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, rowY(7)),
	Size = UDim2.fromOffset(PW - 28, 42),
	Font = UI_FONT,
	Text = "HP: --\nCD: -- | Ready",
	TextColor3 = C_WHITE,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, autoHealPanel)
addButtonRow(autoHealPanel, 9, "Reset Auto Heal", function(b)
	Cfg.AutoHeal = Defaults.AutoHeal
	Cfg.AutoHealMode = Defaults.AutoHealMode
	Cfg.AutoHealHP = Defaults.AutoHealHP
	Cfg.AutoHealCheckDelay = Defaults.AutoHealCheckDelay
	Cfg.AutoHealWeaponDelay = Defaults.AutoHealWeaponDelay
	Cfg.AutoHealMedkitThreshold = Defaults.AutoHealMedkitThreshold
	refreshUI()
	saveSoon()
	b.Text = "Reset แล้ว"
	task.delay(1, function()
		if b.Parent then b.Text = "Reset Auto Heal" end
	end)
end)
local autoLootPanel, autoLootBar = makePanel(
	"AutoLoot",
	"AUTO LOOT",
	7,
	UDim2.new(1, -205, 1, -345)
)
autoLootPanel.Visible = false
addTitleButton(autoLootBar, "×", -8, function()
	autoLootPanel.Visible = false
end)
addCheckRow(autoLootPanel, 1, "Enable Auto Loot", cfgAccess("AutoLoot"))
addStepRow(autoLootPanel, 2, "Hold Time", "AutoLootHoldTime", 0.1, 0.1, 5)
addStepRow(autoLootPanel, 3, "Check Delay", "AutoLootCheckDelay", 0.01, 0.01, 1)
AutoLootStatusLabel = make("TextLabel", {
	BackgroundTransparency = 1,
	Position = UDim2.fromOffset(14, rowY(4)),
	Size = UDim2.fromOffset(PW - 28, 32),
	Font = UI_FONT,
	Text = "Status: Ready",
	TextColor3 = C_WHITE,
	TextSize = 11,
	TextWrapped = true,
	TextXAlignment = Enum.TextXAlignment.Left,
	TextYAlignment = Enum.TextYAlignment.Top,
}, autoLootPanel)
addButtonRow(autoLootPanel, 5, "Reset Auto Loot", function(b)
	Cfg.AutoLoot = Defaults.AutoLoot
	Cfg.AutoLootHoldTime = Defaults.AutoLootHoldTime
	Cfg.AutoLootCheckDelay = Defaults.AutoLootCheckDelay
	autoLootReleaseE()
	refreshUI()
	saveSoon()
	b.Text = "Reset แล้ว"
	task.delay(1, function()
		if b.Parent then b.Text = "Reset Auto Loot" end
	end)
end)
local miscPanel, miscBar = makePanel(
	"Misc",
	"MISC",
	5,
	UDim2.new(1, -615, 1, -345)
)
miscPanel.Visible = false
addTitleButton(miscBar, "×", -8, function()
	miscPanel.Visible = false
end)
addButtonRow(miscPanel, 1, "Auto Heal", function()
	autoHealPanel.Visible = not autoHealPanel.Visible
end)
addButtonRow(miscPanel, 2, "Auto Loot", function()
	autoLootPanel.Visible = not autoLootPanel.Visible
end)
addButtonRow(main, 10, "MISC", function()
	miscPanel.Visible = not miscPanel.Visible
end)
local uiReady = false
root.Visible = false
local function addBlur(parent)
	local b = make("ImageLabel", {
		Name = "Blur",
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Size = UDim2.fromScale(1, 1),
		Image = IMG.blur,
		ImageTransparency = 0.55,
	}, parent)
	corner(b, 6)
	return b
end
local loaderAlive = true
task.spawn(function()
	local function alive()
		return loaderAlive and gui and gui.Parent ~= nil
	end
	local loader = make("Frame", {
		Name = "Loader",
		Active = true,
		AnchorPoint = Vector2.new(0.5, 0.5),
		BackgroundColor3 = C_BG,
		BackgroundTransparency = 0.2,
		BorderSizePixel = 0,
		Position = UDim2.fromScale(0.5, 0.5),
		Size = UDim2.fromOffset(0, 76),
	}, gui)
	corner(loader, 6)
	local blur = addBlur(loader)
	local label = make("TextLabel", {
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(26, 12),
		Size = UDim2.fromOffset(154, 39),
		Font = Enum.Font.JosefinSans,
		Text = "x2spiritz",
		TextColor3 = C_WHITE,
		TextSize = 15,
		TextTransparency = 1,
		TextWrapped = true,
	}, loader)
	local bar = make("Frame", {
		BackgroundColor3 = Color3.fromRGB(84, 84, 84),
		BackgroundTransparency = 1,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(26, 57),
		Size = UDim2.fromOffset(154, 6),
	}, loader)
	corner(bar, 6)
	local fill = make("Frame", {
		BackgroundColor3 = C_WHITE,
		BorderSizePixel = 0,
		Position = UDim2.fromOffset(0, 0),
		Size = UDim2.fromOffset(0, 6),
	}, bar)
	corner(fill, 6)
	local function tween(obj, time, props)
		pcall(function()
			TweenService:Create(obj, TweenInfo.new(time), props):Play()
		end)
	end
	tween(loader, 0.7, { Size = UDim2.fromOffset(207, 76) })
	task.wait(0.7)
	if not alive() then return end
	tween(label, 0.4, { TextTransparency = 0 })
	tween(bar, 0.4, { BackgroundTransparency = 0 })
	task.wait(0.2)
	tween(fill, 1.6, { Size = UDim2.fromOffset(154, 6) })
	task.wait(1.8)
	if not alive() then return end
	tween(blur, 0.4, { ImageTransparency = 1 })
	tween(loader, 0.4, { BackgroundTransparency = 1 })
	tween(bar, 0.4, { BackgroundTransparency = 1 })
	tween(fill, 0.4, { BackgroundTransparency = 1 })
	tween(label, 0.4, { TextTransparency = 1 })
	task.wait(0.45)
	if loader.Parent then loader:Destroy() end
	if not alive() then return end
	root.Visible = true
	uiReady = true
end)
local function showHint()
	if not hint or not hint.Parent then return end
	hint.TextTransparency = 0
	task.delay(3, function()
		if hint and hint.Parent then
			TweenService:Create(hint, TweenInfo.new(0.6), { TextTransparency = 1 }):Play()
		end
	end)
end
connect(UIS.InputBegan, function(input, processed)
	if processed then return end
	if input.KeyCode == Enum.KeyCode.RightShift then
		if uiReady then
			root.Visible = not root.Visible
			if not root.Visible then showHint() end
		end
	elseif input.KeyCode == Enum.KeyCode.End then
		loaderAlive = false
		unload()
	end
end)
pcall(saveConfig)
setupAutoRun()
