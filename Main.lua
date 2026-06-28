local players = cloneref(game:GetService('Players'))
local runService = cloneref(game:GetService("RunService"))
local httpService = cloneref(game:GetService("HttpService"))
local replicatedStorage = cloneref(game:GetService("ReplicatedStorage"))
local tweenService = cloneref(game:GetService("TweenService"))
local userInputService = cloneref(game:GetService("UserInputService"))
local textChatService = cloneref(game:GetService("TextChatService"))
local debris = cloneref(game:GetService("Debris"))
local player = players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player.PlayerGui
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local gitMain = "v0.0.8"
local generalChannel = textChatService.TextChannels:WaitForChild("RBXGeneral")

local holderDefaultSize = UDim2.new(0.194, 0, 0.461, 0)
local defaultWalkSpeed = humanoid.WalkSpeed
local currentPlayerList = {}
local allInitialPlayers = players:GetChildren()
local soundsFolder = nil
local particlesFolder = nil
local currentCustomAnim = nil

local anims = {}
local config = {}
local particles = {}
local trails = {}
local sounds = {}

print("I AM LOADING ROSPLOITNIK")

for i = 1, #allInitialPlayers do
	currentPlayerList[allInitialPlayers[i]] = true;
end

function AnimationConstructor()
	for i, v in pairs(anims) do
		local animation = Instance.new("Animation")
		animation.AnimationId = v["Id"]
		v["Self"] = humanoid:LoadAnimation(animation)
	end
end

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
	defaultWalkSpeed = humanoid.WalkSpeed
	AnimationConstructor()
end)

players.PlayerAdded:Connect(function(player)
	currentPlayerList[player] = true;
end)

players.PlayerRemoving:Connect(function(player)
	currentPlayerList[player] = nil;
end)

humanoid.StateChanged:Connect(function(oldState, newState)
	if newState == Enum.HumanoidStateType.Jumping then
		soundsFolder:FindFirstChild("Jump"):Play()
	end
end)

function StopAnim(string) 
	anims[string].Self:Stop()
end


function PlayAnim(string, speed) 
	if anims[string].Self.IsPlaying == false then
		anims[string].Self:Play()
	elseif speed then
		if anims[string].Self.Speed ~= speed then
			anims[string].Self:AdjustSpeed(speed)
		end
	end
end

function ButtonCosmetic(button, bool)
	soundsFolder:FindFirstChild("Press"):Play()
	if bool == true then
		button.TextColor3 = Color3.fromRGB(0,255,0)
	else
		button.TextColor3 = Color3.fromRGB(255,0,0)
	end
end

local open = true
function uiCloseOpen(button)
	if button == nil then
		return
	end
	if open == true then
		open = false
		tweenService:Create(button.Parent.Parent.Holder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(button.Parent.Parent.Holder.Size.X.Scale, 0, 0, 0)}):Play()
		soundsFolder:FindFirstChild("Close"):Play()
	elseif open == false then
		open = true
		tweenService:Create(button.Parent.Parent.Holder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(button.Parent.Parent.Holder.Size.X.Scale, 0, holderDefaultSize.Y.Scale, 0)}):Play()
		soundsFolder:FindFirstChild("Open"):Play()
	end
end

local spamEnabled = false
local spamLoop = nil
local spamLoopStart = 0
local spamCooldown = 0.5
local spamMessage = "Dr. Rosploitnik On top!"

function OnSpam(button)
	if button == nil then
		return
	end
	if spamEnabled == false then
		if type(tonumber(button.Parent.SpamInputCooldown.Text)) == "number" then
			spamCooldown = tonumber(button.Parent.SpamInputCooldown.Text)
		end
		if type(button.Parent.SpamInputMessage.Text) == "string" then
			spamMessage = button.Parent.SpamInputMessage.Text
		end
		spamEnabled = true
		if spamLoop ~= nil then
			spamLoop:Disconnect()
		end
		spamLoopStart = tick()
		spamLoop = runService.RenderStepped:Connect(function()
			local elapsed = tick() - spamLoopStart
			if elapsed > spamCooldown then
				elapsed = 0
				spamLoopStart = tick()
				generalChannel:SendAsync(spamMessage)
			end
		end)
	elseif spamEnabled == true then
		spamEnabled = false
		if spamLoop ~= nil then
			spamLoop:Disconnect()
			spamLoop = nil
		end
	end
	ButtonCosmetic(button, spamEnabled)
end



local musicEnabled = false
function OnMusic(button)
	if button == nil then
		return
	end
	if musicEnabled == false then
		musicEnabled = true
		soundsFolder.Music.SoundId = "rbxassetid://".. button.Parent.MusicInputId.Text
		soundsFolder.Music.Volume = button.Parent.MusicInputVolume.Text
		soundsFolder.Music:Play()
	elseif musicEnabled == true then
		musicEnabled = false
		soundsFolder.Music:Stop()
	end
	ButtonCosmetic(button, musicEnabled)
end

-- Teleport script --
local teleportEnabled = false
local teleportClickFunc = nil
function OnTeleport(button)
	if button == nil then
		return
	end
	if teleportEnabled == false then
		teleportEnabled = true
		if teleportClickFunc == nil then
			teleportClickFunc = userInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end
				if input.UserInputType == Enum.UserInputType.MouseButton3 then
					if mouse.Target then
						local effectPart = Instance.new("Part")
						effectPart.Position = hrp.Position
						effectPart.Parent = workspace
						effectPart.Anchored = true
						effectPart.CanCollide = false
						effectPart.CanTouch = false
						effectPart.CanQuery = false
						effectPart.Size = Vector3.new(5,5,5)
						effectPart.Transparency = 1
						local teleportParticle1 = particlesFolder:FindFirstChild("Teleport1"):Clone()
						teleportParticle1.Parent = effectPart
						teleportParticle1:Emit(teleportParticle1:GetAttribute("emitCount"))
						
						local teleportSound = soundsFolder.Teleport:Clone()
						teleportSound.Parent = soundsFolder
						teleportSound:Play()
						debris:AddItem(teleportSound, 1)
						hrp.CFrame = CFrame.new(mouse.Hit.Position) * hrp.CFrame.Rotation
						local camType = Enum.CameraType.Custom
						workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
						task.wait(.1)
						workspace.CurrentCamera.CameraType = camType
					end
				end
			end)
		end
	elseif teleportEnabled == true then
		teleportEnabled = false
		if teleportClickFunc ~= nil then
			teleportClickFunc:Disconnect()
			teleportClickFunc = nil
		end
	end
	ButtonCosmetic(button, teleportEnabled)
end

-- Explosion script --
local explodeEnabled = false
local explodeClickFunc = nil
function OnExplode(button)
	if button == nil then
		return
	end
	if explodeEnabled == false then
		explodeEnabled = true
		if explodeClickFunc == nil then
			explodeClickFunc = userInputService.InputBegan:Connect(function(input, gameProcessed)
				if gameProcessed then
					return
				end
				if input.UserInputType == Enum.UserInputType.MouseButton1 then
					if mouse.Target then
						local effectPart = Instance.new("Part")
						effectPart.Position = mouse.Hit.Position
						effectPart.Parent = workspace
						effectPart.Anchored = true
						effectPart.CanCollide = false
						effectPart.CanTouch = false
						effectPart.CanQuery = false
						effectPart.Size = Vector3.new(10,10,10)
						effectPart.Transparency = 1
						local explodeSound = soundsFolder.Explode:Clone()
						explodeSound.Parent = soundsFolder
						explodeSound:Play()
						debris:AddItem(explodeSound, 1)
						local explodeParticle1 = particlesFolder:FindFirstChild("Explosion1"):Clone()
						explodeParticle1.Parent = effectPart
						explodeParticle1:Emit(explodeParticle1:GetAttribute("emitCount"))
						local explodeParticle2 = particlesFolder:FindFirstChild("Explosion2"):Clone()
						explodeParticle2.Parent = effectPart
						explodeParticle2:Emit(explodeParticle2:GetAttribute("emitCount"))
						debris:AddItem(effectPart, 1)
						local explosion = Instance.new("Explosion")
						explosion.Position = mouse.Hit.Position
						explosion.Parent = workspace
						mouse.Target:Destroy()
					end
				end
			end)
		end
	elseif explodeEnabled == true then
		explodeEnabled = false
		if explodeClickFunc ~= nil then
			explodeClickFunc:Disconnect()
			explodeClickFunc = nil
		end
	end
	ButtonCosmetic(button, explodeEnabled)
end
--

--
flightEnabled = false
local flightLoop = nil
local flightMove = Vector3.zero

function OnFlight(button)
	if button == nil then
		return
	end
	if flightEnabled == false then
		flightEnabled = true
		if flightLoop == nil then
			humanoid:ChangeState(Enum.HumanoidStateType.Physics)
			flightLoop = runService.Heartbeat:Connect(function(deltaTime)
				local direction = workspace.CurrentCamera.CFrame:VectorToObjectSpace(humanoid.MoveDirection)
				flightMove = ((workspace.CurrentCamera.CFrame.RightVector * direction.X)  + (-workspace.CurrentCamera.CFrame.LookVector * direction.Z)).Unit
				humanoid.WalkSpeed = 0
				if flightMove.Magnitude > 0 then
					StopAnim("flyIdle")
					PlayAnim("flyMove", hrp.AssemblyLinearVelocity.Magnitude /100)
					hrp.CFrame = hrp.CFrame:Lerp(CFrame.lookAt(hrp.Position, hrp.Position + flightMove, workspace.CurrentCamera.CFrame.UpVector), 0.3 * (1 - deltaTime))
				else
					StopAnim("flyMove")
					PlayAnim("flyIdle", 3)
					hrp.CFrame = hrp.CFrame:Lerp( CFrame.lookAt(hrp.Position, hrp.Position + workspace.CurrentCamera.CFrame.LookVector, workspace.CurrentCamera.CFrame.UpVector), 0.05 * (1 - deltaTime))
				end
				if direction.Magnitude > 0 and speedEnabled == false then
					hrp.AssemblyLinearVelocity = flightMove * 25
				else
					hrp.AssemblyLinearVelocity /= 1 + (deltaTime * 5)
				end
				hrp.AssemblyAngularVelocity = Vector3.zero
			end)
		end
	elseif flightEnabled == true then
		flightEnabled = false
		if flightLoop then
			StopAnim("flyMove")
			StopAnim("flyIdle")
			flightLoop:Disconnect()
			flightLoop = nil
			humanoid.WalkSpeed = defaultWalkSpeed
			humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
		end
	end
	ButtonCosmetic(button, flightEnabled)
end


-- Float script, using workspace gravity --
local floatEnabled = false
local defaultWorkspaceGravity = workspace.Gravity
function OnFloat(button)
	if button == nil then
		return
	end
	if floatEnabled == false then
		floatEnabled = true	
		workspace.Gravity = .1
	elseif floatEnabled == true then
		floatEnabled = false
		workspace.Gravity = defaultWorkspaceGravity
	end
	ButtonCosmetic(button, floatEnabled)
end

-- Speed script, via button, with effects --
speedEnabled = false
currentSpeed = nil
local accel = 1000
local maxSpeed = 250
local speedLoop = nil

function SpeedDestroyEffects()
	if hrp:FindFirstChild("RosploitnikSpeedAttachment") then
		tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = 70}):Play()
		soundsFolder.Wind:Pause()
		hrp.RosploitnikSpeedAttachment.Speed1.Enabled = false
		debris:AddItem(hrp.RosploitnikSpeedAttachment, 0.2)
		hrp.RosploitnikTrailAttachment1.Trail.Enabled = false
		hrp.RosploitnikTrailAttachment1.Trail2.Enabled = false
		debris:AddItem(hrp.RosploitnikTrailAttachment1, 0.2)
		debris:AddItem(hrp.RosploitnikTrailAttachment2, 0.2)
	end
end

function OnSpeed(button)
	if button == nil then
		return
	end
	if speedEnabled == false then
		if type(tonumber(button.Parent.SpeedInputTopSpeed.Text)) == "number" then
			maxSpeed = button.Parent.SpeedInputTopSpeed.Text
		end
		if type(tonumber(button.Parent.SpeedInputAcceleration.Text)) == "number" then
			accel = button.Parent.SpeedInputAcceleration.Text
		end
		speedEnabled = true
		if speedLoop == nil then
			speedLoop = runService.Heartbeat:Connect(function(deltaTime)
				local moveDir = humanoid.MoveDirection
				if moveDir.Magnitude > 0 then
						tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = 70 + math.clamp(hrp.AssemblyLinearVelocity.Magnitude/5, 0, 50)}):Play()
					if currentSpeed == nil  then
						soundsFolder.Wind:Resume()
						-- Particle --
							local particleAttachment = Instance.new("Attachment")
							particleAttachment.Parent = hrp
							particleAttachment.Name = "RosploitnikSpeedAttachment"
							local speedParticle = particlesFolder:FindFirstChild("Speed1"):Clone()
							speedParticle.Enabled = true
							speedParticle.Parent = particleAttachment
							soundsFolder.Boost:Play()
							-- Trail --
							local trailAttachment1 = Instance.new("Attachment")
							trailAttachment1.Parent = hrp
							trailAttachment1.Name = "RosploitnikTrailAttachment1"
							trailAttachment1.Position = Vector3.new(0,-3,0)
							local trailAttachment2 = Instance.new("Attachment")
							trailAttachment2.Parent = hrp
							trailAttachment2.Name = "RosploitnikTrailAttachment2"
							trailAttachment2.Position = Vector3.new(0,3,0)
							local trail = Instance.new("Trail")
							trail.Parent = trailAttachment1
							trail.Attachment0 = trailAttachment1
							trail.Attachment1 = trailAttachment2
							local trail2 = Instance.new("Trail")
							trail2.Parent = trailAttachment1
							trail2.Attachment0 = trailAttachment1
							trail2.Attachment1 = trailAttachment2
							for i, v in pairs(trails["trail1"]) do
								trail[i] = v
							end
							for i, v in pairs(trails["trail2"]) do
								trail2[i] = v
							end
							-- Shockwave --
							local attachment = Instance.new("Attachment")
							attachment.Parent = hrp
							local shockwaveParticle = particlesFolder:FindFirstChild("Shockwave1"):Clone()
							shockwaveParticle:Emit(shockwaveParticle:GetAttribute("emitCount"))
							shockwaveParticle.Parent = attachment
							debris:AddItem(attachment, 0.3)
						if flightEnabled == false then
							currentSpeed = -hrp.CFrame:VectorToObjectSpace(hrp.AssemblyLinearVelocity).Z
						else
							local flightCFrame = hrp.CFrame + flightMove
							currentSpeed = -flightCFrame:VectorToObjectSpace(hrp.AssemblyLinearVelocity).Z
						end
					end
					if hrp:FindFirstChild("RosploitnikSpeedAttachment") then
						local factor = 0
						if flightEnabled == true then
							factor = 50
						else
							factor = 60
						end
						local velVector = hrp.AssemblyLinearVelocity / factor
						hrp.RosploitnikSpeedAttachment.WorldCFrame = hrp.RosploitnikSpeedAttachment.WorldCFrame:Lerp(CFrame.lookAt(hrp.Position + velVector, hrp.Position + hrp.AssemblyLinearVelocity), 0.1 * (1 - deltaTime))
					end
					if flightEnabled == false then
						PlayAnim("boost", hrp.AssemblyLinearVelocity.Magnitude / 75)
						currentSpeed = math.clamp(currentSpeed + (accel * deltaTime),  0, maxSpeed)
						local speedLocalSpace = hrp.CFrame:VectorToObjectSpace(hrp.AssemblyLinearVelocity)
						local speedLocalSpace = Vector3.new(speedLocalSpace.X / (1 + (1/deltaTime)), speedLocalSpace.Y, -currentSpeed)
						hrp.AssemblyLinearVelocity = hrp.CFrame:VectorToWorldSpace(speedLocalSpace)
					else
						StopAnim("boost")
						currentSpeed = math.clamp(currentSpeed + (accel * deltaTime),  0, maxSpeed)
						hrp.AssemblyLinearVelocity = flightMove * currentSpeed 
					end
				else
					StopAnim("boost")
					currentSpeed = nil
					SpeedDestroyEffects()
				end
			end)
		end
	elseif speedEnabled == true then
		speedEnabled = false
		if speedLoop then
			StopAnim("boost")
			SpeedDestroyEffects()
			speedLoop:Disconnect()
			speedLoop = nil
		end
	end
	ButtonCosmetic(button, speedEnabled)
end

-- ESP, make sure to not check elasped time in too short of ticks or will cause lag --
local espEnabled = false
local espLoop = nil
local espLoopStart = 0
function OnEsp(button)
	if button == nil then
		return
	end
	if espEnabled == false then
		espEnabled = true
		if espLoop ~= nil then
			espLoop:Disconnect()
		end
		espLoopStart = tick()
		espLoop = runService.RenderStepped:Connect(function()
			local elapsed = tick() - espLoopStart
			if elapsed > 0.5 then
				elapsed = 0
				espLoopStart = tick()
				for i,v in pairs(currentPlayerList) do
					if i.Character and i.Character ~= character and elapsed <= 0.5 then
						if not i.Character:FindFirstChild("ESPHighlight") then
							local highlight = Instance.new("Highlight")
							highlight.Parent = i.Character
							highlight.Name = "ESPHighlight"
							highlight.FillTransparency = 0.5
							highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
							highlight.OutlineColor = Color3.fromRGB(222, 170, 255)
							highlight.FillColor = Color3.fromRGB(131, 55, 138)
						end
					end
				end
			end
		end)
	elseif espEnabled == true then
		espEnabled = false
		for i,v in pairs(currentPlayerList) do
			if i.Character and i.Character ~= character then
				if i.Character:FindFirstChild("ESPHighlight") then
					i.Character.ESPHighlight:Destroy()
				end
			end
		end
		if espLoop then
			espLoop:Disconnect()
			espLoop = nil
		end
	end
	ButtonCosmetic(button, espEnabled)
end

-- Anim table, .Self = the :LoadAnimation()
anims = loadstring(game:HttpGet("https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/refs/heads/main/Modules/Anims.lua"))()
-- Sounds table
sounds = loadstring(game:HttpGet("https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/refs/heads/main/Modules/Sounds.lua"))()
-- Trails table to be instantiated later --
trails = loadstring(game:HttpGet("https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/refs/heads/main/Modules/Trails.lua"))()
-- Particles table to be instantiated later --
particles = loadstring(game:HttpGet("https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/refs/heads/main/Modules/Particles.lua"))()
-- Ui config table, edit properties in here and assign func to button functions --
config = loadstring(game:HttpGet("https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/refs/heads/main/Modules/UiConfig.lua"))()

function ParticleConstructor()
	local folder = Instance.new("Folder")
	folder.Parent = replicatedStorage
	folder.Name = "RosploitnikParticles"
	for i, v in pairs(particles) do
		local particle = Instance.new("ParticleEmitter")
		for key, value in pairs(v) do
			if key ~= "Misc" then
				particle[key] = value
			else
				for key2, value2 in pairs(value) do
					particle:SetAttribute(key2, value2) -- Assign any misc values as attributes so we can read them later
				end
			end
			particle.Parent = folder
			particle.Enabled = false
		end
	end
	return folder
end

function SoundConstructor()
	local folder = Instance.new("Folder")
	folder.Parent = replicatedStorage
	folder.Name = "RosploitnikSound"
	for i, v in pairs(sounds) do
		local sound = Instance.new("Sound")
		for key, value in pairs(v) do
			sound[key] = value
		end
		sound.Parent = folder
	end
	return folder
end

function TopBarConstructor(key, bar)
	mouse.Move:Connect(function()
		if key["Misc"].held == true then
			local mousePos = userInputService:GetMouseLocation()
			bar.Parent.Position = UDim2.new(0, mousePos.X, 0.22, mousePos.Y)
		end
	end)
	bar.MouseButton1Down:Connect(function()
		key["Misc"].held = true
	end)
	mouse.Button1Up:Connect(function()
		key["Misc"].held = false
	end)
	bar.MouseButton1Up:Connect(function()
		key["Misc"].held = false
	end)
end

function UiConstructor()
	for i, v in pairs(config) do
		local obj = Instance.new(v["Type"])
		v["Self"] = obj
		for key, value in pairs(v) do
			if key ~= "Type" and key ~= "Misc" and key ~= "Parent" and key ~= "Self" then
				obj[key] = value -- Set property of the instanced object
			elseif key == "Misc" then
				if value["func"] then
					obj.MouseButton1Click:Connect(function()
						value["func"](obj)
					end)
				end
				if value["uiListLayout"] then
					local uiList = Instance.new("UIListLayout")
					uiList.Parent = obj
					uiList.Padding = UDim.new(0,4)
					uiList.FillDirection = Enum.FillDirection.Vertical
					uiList.SortOrder = Enum.SortOrder.LayoutOrder
					uiList.VerticalAlignment = Enum.VerticalAlignment.Top
					uiList.HorizontalAlignment = Enum.HorizontalAlignment.Left
				end
				if value["gradientType"] == 1 then
					local gradient = Instance.new("UIGradient")
					gradient.Color = ColorSequence.new{
						ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
						ColorSequenceKeypoint.new(1, Color3.fromRGB(124, 198, 211))
					}
					gradient.Rotation = 90
					gradient.Parent = obj
				end
				if value["cornerType"] == 1 then
					local corner = Instance.new("UICorner")
					corner.CornerRadius = UDim.new(0, 8)
					corner.Parent = obj
				elseif value["cornerType"] == 2 then
					local corner = Instance.new("UICorner")
					corner.CornerRadius = UDim.new(0, 200)
					corner.Parent = obj
				end
				if value["grabbable"] then
					TopBarConstructor(v, obj)
				end
			end
		end
	end
	UiParent()
end

function UiParent()
	for i, v in pairs(config) do
		if v["Parent"] == "PlayerGui" then
			v["Self"].Parent = playerGui
		else
			v["Self"].Parent = config[v["Parent"]]["Self"]
		end
	end
end

-- Script ui setup --
function ScriptSetup()
	game.StarterGui:SetCore("SendNotification", {
		Title = "Dr Rosploitnic",
		Icon = "rbxassetid://105076512076789",
		Text = "Loading Dr Rosploitnic Now",
	})
	UiConstructor()
	soundsFolder = SoundConstructor()
	particlesFolder = ParticleConstructor()
	AnimationConstructor()
end

ScriptSetup()
--
