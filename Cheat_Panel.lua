-- Name: AdminPanelManager
-- Location: StarterGui
-- Type: LocalScript

local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local Player = Players.LocalPlayer
local Character = Player.Character or Player.CharacterAdded:Wait()
local Humanoid = Character:WaitForChild("Humanoid")

-- State
local IsOpen = false
local GodModeEnabled = false
local Flying = false
local FlySpeed = 50
local Noclip = false
local NoclipConnection
local Freecam = false
local FreecamSpeed = 2
local FreecamPos
local FreecamConnection
local ESPEnabled = false
local Freecam = false
local FreecamSpeed = 2

local yaw = 0
local pitch = 0
local sensitivity = 0.002

local FreecamConnection
local mouse

-- UI Construction
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "A.br1 Cheat Panel"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = Player:WaitForChild("PlayerGui")

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 300, 0, 450)
MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 40)
MainFrame.BorderSizePixel = 0
MainFrame.Visible = false
MainFrame.Active = true -- Required for dragging
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

local UIStroke = Instance.new("UIStroke")
UIStroke.Color = Color3.fromRGB(60, 60, 75)
UIStroke.Thickness = 2
UIStroke.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundTransparency = 1
Title.Text = "A.br1's Cheat Panel"
Title.Font = Enum.Font.GothamBold
Title.TextColor3 = Color3.fromRGB(255, 0, 4)
Title.TextSize = 18
Title.Parent = MainFrame

local Container = Instance.new("ScrollingFrame")
Container.Size = UDim2.new(1, -20, 1, -60)
Container.Position = UDim2.new(0, 10, 0, 50)
Container.BackgroundTransparency = 1
Container.ScrollBarThickness = 2
Container.CanvasSize = UDim2.new(0, 0, 0, 800)
Container.Parent = MainFrame

local Layout = Instance.new("UIListLayout")
Layout.Padding = UDim.new(0, 10)
Layout.HorizontalAlignment = Enum.HorizontalAlignment.Center
Layout.Parent = Container

-- Draggable Logic implementation
local dragging, dragInput, dragStart, startPos

local function update(input)
	local delta = input.Position - dragStart
	MainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
end

MainFrame.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
		dragging = true
		dragStart = input.Position
		startPos = MainFrame.Position

		input.Changed:Connect(function()
			if input.UserInputState == Enum.UserInputState.End then
				dragging = false
			end
		end)
	end
end)

MainFrame.InputChanged:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
		dragInput = input
	end
end)

UserInputService.InputChanged:Connect(function(input)
	if input == dragInput and dragging then
		update(input)
	end
end)

-- Fly Logic
local bv, bg
local function toggleFly()
	Flying = not Flying
	if Flying then
		local root = Character:FindFirstChild("HumanoidRootPart")
		if not root then return end

		bv = Instance.new("BodyVelocity")
		bv.MaxForce = Vector3.new(1e9, 1e9, 1e9)
		bv.Velocity = Vector3.new(0, 0, 0)
		bv.Parent = root

		bg = Instance.new("BodyGyro")
		bg.MaxTorque = Vector3.new(1e9, 1e9, 1e9)
		bg.CFrame = root.CFrame
		bg.Parent = root

		task.spawn(function()
			while Flying and Character and root do
				local cam = workspace.CurrentCamera
				local dir = Vector3.new(0,0,0)
				if UserInputService:IsKeyDown(Enum.KeyCode.W) then dir += cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.S) then dir -= cam.CFrame.LookVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.A) then dir -= cam.CFrame.RightVector end
				if UserInputService:IsKeyDown(Enum.KeyCode.D) then dir += cam.CFrame.RightVector end

				bv.Velocity = dir * FlySpeed
				bg.CFrame = cam.CFrame
				RunService.RenderStepped:Wait()
			end
			if bv then bv:Destroy() end
			if bg then bg:Destroy() end
		end)
	end
end

-- UI Helpers
local function CreateSlider(name, min, max, default, callback)
	local Frame = Instance.new("Frame")
	Frame.Size = UDim2.new(1, -10, 0, 60)
	Frame.BackgroundTransparency = 1
	Frame.Parent = Container

	local Label = Instance.new("TextLabel")
	Label.Size = UDim2.new(1, 0, 0, 20)
	Label.BackgroundTransparency = 1
	Label.Text = name .. ": " .. default
	Label.TextColor3 = Color3.fromRGB(180, 180, 190)
	Label.Font = Enum.Font.GothamMedium
	Label.TextSize = 14
	Label.Parent = Frame

	local SliderBG = Instance.new("Frame")
	SliderBG.Size = UDim2.new(0.9, 0, 0, 6)
	SliderBG.Position = UDim2.new(0.5, 0, 0.7, 0)
	SliderBG.AnchorPoint = Vector2.new(0.5, 0.5)
	SliderBG.BackgroundColor3 = Color3.fromRGB(50, 50, 65)
	SliderBG.Parent = Frame

	local Fill = Instance.new("Frame")
	Fill.Size = UDim2.new((default - min)/(max - min), 0, 1, 0)
	Fill.BackgroundColor3 = Color3.fromRGB(90, 130, 255)
	Fill.BorderSizePixel = 0
	Fill.Parent = SliderBG

	local Knob = Instance.new("ImageButton")
	Knob.Size = UDim2.new(0, 16, 0, 16)
	Knob.Position = UDim2.new(1, 0, 0.5, 0)
	Knob.AnchorPoint = Vector2.new(0.5, 0.5)
	Knob.Parent = Fill
	Instance.new("UICorner", Knob).CornerRadius = UDim.new(1, 0)

	local draggingSlider = false
	local function updateSlider(input)
		local pos = math.clamp((input.Position.X - SliderBG.AbsolutePosition.X) / SliderBG.AbsoluteSize.X, 0, 1)
		Fill.Size = UDim2.new(pos, 0, 1, 0)
		local val = math.floor(min + (pos * (max - min)))
		Label.Text = name .. ": " .. val
		callback(val)
	end

	Knob.InputBegan:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = true end end)
	UserInputService.InputEnded:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseButton1 then draggingSlider = false end end)
	UserInputService.InputChanged:Connect(function(input) if draggingSlider and input.UserInputType == Enum.UserInputType.MouseMovement then updateSlider(input) end end)
end

local function CreateButton(name, callback)
	local Button = Instance.new("TextButton")
	Button.Size = UDim2.new(1, -10, 0, 35)
	Button.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	Button.Text = name
	Button.Font = Enum.Font.GothamMedium
	Button.TextColor3 = Color3.fromRGB(240, 240, 245)
	Button.TextSize = 14
	Button.Parent = Container
	Instance.new("UICorner", Button).CornerRadius = UDim.new(0, 6)
	Button.MouseButton1Click:Connect(callback)
end

local function CreateInput(placeholder, callback)
	local Input = Instance.new("TextBox")
	Input.Size = UDim2.new(1, -10, 0, 35)
	Input.BackgroundColor3 = Color3.fromRGB(45, 45, 60)
	Input.PlaceholderText = placeholder
	Input.Text = ""
	Input.Font = Enum.Font.GothamMedium
	Input.TextColor3 = Color3.fromRGB(240, 240, 245)
	Input.TextSize = 14
	Input.Parent = Container
	Instance.new("UICorner", Input).CornerRadius = UDim.new(0, 6)
	Input.FocusLost:Connect(function(enter)
		if enter then callback(Input.Text) Input.Text = "" end
	end)
end

-- Functionality
CreateSlider("WalkSpeed", 16, 200, 16, function(val) Humanoid.WalkSpeed = val end)
CreateSlider("JumpPower", 50, 500, 50, function(val) Humanoid.UseJumpPower = true; Humanoid.JumpPower = val end)
CreateSlider("Fly Speed", 10, 300, 50, function(val) FlySpeed = val end)
CreateButton("Toggle Fly", toggleFly)

CreateButton("Toggle God Mode -NOT WORKING-", function()
	GodModeEnabled = not GodModeEnabled
	if GodModeEnabled then
		task.spawn(function()
			while GodModeEnabled and Humanoid do
				Humanoid.Health = Humanoid.MaxHealth
				task.wait()
			end
		end)
	end
end)

CreateButton("Toggle ESP", function()
	ESPEnabled = not ESPEnabled
	print("ESP:", ESPEnabled)

	for _, plr in pairs(Players:GetPlayers()) do
		if plr ~= Player and plr.Character then
			local char = plr.Character

			local highlight = char:FindFirstChild("AdminESP")

			if ESPEnabled then
				if not highlight then
					local h = Instance.new("Highlight")
					h.Name = "AdminESP"
					h.FillColor = Color3.fromRGB(255, 0, 0)
					h.OutlineColor = Color3.fromRGB(255, 255, 255)
					h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
					h.Parent = char
				end
			else
				if highlight then
					highlight:Destroy()
				end
			end
		end
	end
end)

Players.PlayerAdded:Connect(function(plr)
	plr.CharacterAdded:Connect(function(char)
		task.wait(1)

		if ESPEnabled and plr ~= Player then
			local h = Instance.new("Highlight")
			h.Name = "AdminESP"
			h.FillColor = Color3.fromRGB(255, 0, 0)
			h.OutlineColor = Color3.fromRGB(255, 255, 255)
			h.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
			h.Parent = char
		end
	end)
end)

CreateButton("Toggle Freecam", function()
	Freecam = not Freecam
	print("Freecam:", Freecam)

	local camera = workspace.CurrentCamera
	local humanoid = Character and Character:FindFirstChild("Humanoid")
	local root = Character and Character:FindFirstChild("HumanoidRootPart")

	if Freecam then
		-- IMPORTANT: fully detach camera
		camera.CameraType = Enum.CameraType.Scriptable

		-- freeze character
		if humanoid then
			humanoid.WalkSpeed = 0
			humanoid.JumpPower = 0
			humanoid.AutoRotate = false
		end

		-- start position
		local pos = root and root.CFrame.Position or camera.CFrame.Position

		-- movement loop
		FreecamConnection = RunService.RenderStepped:Connect(function()
			local move = Vector3.new()
			local cf = camera.CFrame

			-- WASD movement relative to camera direction
			if UserInputService:IsKeyDown(Enum.KeyCode.W) then move += cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.S) then move -= cf.LookVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.A) then move -= cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.D) then move += cf.RightVector end
			if UserInputService:IsKeyDown(Enum.KeyCode.Space) then move += Vector3.new(0,1,0) end
			if UserInputService:IsKeyDown(Enum.KeyCode.LeftShift) then move -= Vector3.new(0,1,0) end

			pos += move * FreecamSpeed
			camera.CFrame = CFrame.new(pos, pos + cf.LookVector)
		end)

	else
		if FreecamConnection then
			FreecamConnection:Disconnect()
		end

		-- restore character
		if humanoid then
			humanoid.WalkSpeed = 16
			humanoid.JumpPower = 50
			humanoid.AutoRotate = true
		end

		camera.CameraType = Enum.CameraType.Custom
		camera.CameraSubject = humanoid
	end
end)

CreateButton("Toggle Noclip", function()
	Noclip = not Noclip
	print("Noclip:", Noclip)

	if not Noclip and Character then
		-- restore collisions when turning off
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = true
			end
		end
	end
end)

RunService.Stepped:Connect(function()
	if Character and Noclip then
		for _, v in pairs(Character:GetDescendants()) do
			if v:IsA("BasePart") then
				v.CanCollide = false
			end
		end
	end
end)

CreateInput("Teleport to (User)", function(txt)
	for _, v in pairs(Players:GetPlayers()) do
		if v.Name:lower():sub(1, #txt) == txt:lower() and v.Character then
			Character:MoveTo(v.Character.PrimaryPart.Position)
			break
		end
	end
end)



Player.CharacterAdded:Connect(function(char)
	Character = char
	Humanoid = char:WaitForChild("Humanoid")
	Flying = false
	Noclip = false

	for _, v in pairs(Character:GetDescendants()) do
		if v:IsA("BasePart") then
			v.CanCollide = true
		end
	end
end)

UserInputService.InputBegan:Connect(function(input, processed)
	if not processed and input.KeyCode == Enum.KeyCode.K then
		IsOpen = not IsOpen
		MainFrame.Visible = IsOpen
		if IsOpen then
			MainFrame.Size = UDim2.new(0, 300, 0, 0)
			TweenService:Create(MainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(0, 300, 0, 450)}):Play()
		end
	end
end)