local players = game:GetService('Players')
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local textChatService = game:GetService("TextChatService")
local debris = game:GetService("Debris")
local player = players.LocalPlayer
local mouse = player:GetMouse()
local playerGui = player.PlayerGui
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")

local generalChannel = textChatService.TextChannels:WaitForChild("RBXGeneral")

local holderDefaultSize = UDim2.new(0.253, 0,0.501, 0)
local defaultWalkSpeed = humanoid.WalkSpeed

local heartbeatFunctions = {}
local currentPlayerList = {}
local allInitialPlayers = players:GetChildren()
local soundsFolder = nil
local particlesFolder = nil
local currentCustomAnim = nil

local uiPrimaryCol = Color3.fromRGB(255, 255, 255)
local uiSecondaryCol = Color3.fromRGB(190, 90, 177)
local uiBackgroundCol = Color3.fromRGB(12, 37, 56)

local espOutlineCol = Color3.fromRGB(255, 255, 255)
local espFillCol =  Color3.fromRGB(0,255,0)

local uiGradientTypes = {
	ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.7, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(255, 255, 255))
	},
	
	ColorSequence.new{
		ColorSequenceKeypoint.new(0.00, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.07, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.15, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.20, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.25, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.30, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.35, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.40, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.45, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.50, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.55, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.60, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.65, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.70, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.75, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.80, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.85, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(0.90, Color3.fromRGB(255, 255, 255)),
		ColorSequenceKeypoint.new(0.95, Color3.fromRGB(117, 117, 117)),
		ColorSequenceKeypoint.new(1.00, Color3.fromRGB(255, 255, 255)),
	},
}

local env = getfenv()
local isFileFunc, writeFileFunc, getCustomAssetFunc = env.isfile, env.writefile, env.getcustomasset
local gitMain = "https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/0.1.0"
local isStudio = game:GetService("RunService"):IsStudio()

local images = {}
local anims = {}
local config = {}
local particles = {}
local trails = {}
local sounds = {}

for i = 1, #allInitialPlayers do
	currentPlayerList[allInitialPlayers[i]] = true;
end

function CreateFile(name, path, alternate)
	if isFileFunc and writeFileFunc and getCustomAssetFunc and not isStudio then
		if not isFileFunc(name) then
			local success, data = pcall(function()
				return game:HttpGet(path)
			end)
			if success and data then
				writeFileFunc(name, data)
			end
		end

		if isFileFunc(name) then
			print("Retrieved file: "..name)
			return getCustomAssetFunc(name)
		end
	elseif alternate then
		print("Error occured retrieving file: ".. name.. ", Using backup asset id...")
		return alternate
	end
end

player.CharacterAdded:Connect(function(char)
	character = char
	humanoid = character:WaitForChild("Humanoid")
	hrp = character:WaitForChild("HumanoidRootPart")
	defaultWalkSpeed = humanoid.WalkSpeed
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

if not isStudio then
	print("Loading primary functions")
	loadstring(game:HttpGet("https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/refs/heads/v0.1.0/Modules/MainFunctions.lua"))()
else
	function OnSidebarButton(button)
		if button == nil then
			return
		end
		if config["selected"].Self then
			local selectBox = config["selected"].Self
			tweenService:Create(selectBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = button.Position}):Play()
			soundsFolder:FindFirstChild("Page"):Play()
		end
	end

	function ButtonCosmetic(button, bool)
		local pressSound = soundsFolder:FindFirstChild("Press")
		if pressSound then pressSound:Play() end
		if bool == true then
			button.Text = "ON"
			button.BackgroundColor3 = uiSecondaryCol
			button.TextColor3 = uiBackgroundCol
		else
			button.Text = "OFF"
			button.BackgroundColor3 = uiPrimaryCol
			button.TextColor3 = uiBackgroundCol
		end
	end

	local open = true
	function UiCloseOpen(button)
		if button == nil or not config["holder"].Self then
			return
		end
		local uiHolder = config["holder"].Self
		if open == true then
			open = false
			tweenService:Create(uiHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(uiHolder.Size.X.Scale, 0, 0, 0)}):Play()
			soundsFolder:FindFirstChild("Close"):Play()
		elseif open == false then
			open = true
			tweenService:Create(uiHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(uiHolder.Size.X.Scale, 0, holderDefaultSize.Y.Scale, 0)}):Play()
			soundsFolder:FindFirstChild("Open"):Play()
		end
	end

	local spamEnabled = false
	local spamLoopStart = 0
	local spamCooldown = 0.5
	local spamMessage = "I LOVE ROSPLOITNIK!"
	function OnSpamHearbeat()
		local elapsed = tick() - spamLoopStart
		if elapsed > spamCooldown then
			elapsed = 0
			spamLoopStart = tick()
			generalChannel:SendAsync(spamMessage)
		end
	end

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
			if heartbeatFunctions["Spam"] == nil then
				spamLoopStart = tick()
				heartbeatFunctions["Spam"] = OnSpamHearbeat
			end
		elseif spamEnabled == true then
			spamEnabled = false
			if heartbeatFunctions["Spam"] then
				heartbeatFunctions["Spam"] = nil
			end
		end
		ButtonCosmetic(button, spamEnabled)
	end

	local playerTPEnabled = false
	function OnPlayerTeleport(button)
		local text = ""
		if button == nil then
			return
		end
		if playerTPEnabled == false then
			playerTPEnabled = true
			local otherPlayer = players:FindFirstChild(text)
			if otherPlayer.Character then
				local otherCharacter = otherPlayer.Character
				
			end
		else
			playerTPEnabled = false
		end
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

	spinEnabled = false
	local rotation = 0
	local rotSpeed = 50

	function OnSpinHearbeat()
		if hrp.Parent:FindFirstChild("LowerTorso") then
			PlayAnim("spin", 5)
			anims["spin"].Self.Priority = Enum.AnimationPriority.Action4
		end
	end

	function OnSpin(button)
		if button == nil then
			return
		end
		if spinEnabled == false then
			spinEnabled = true
			if heartbeatFunctions["Spin"] == nil then
				heartbeatFunctions["Spin"] = OnSpinHearbeat
			end
		elseif spinEnabled == true then
			spinEnabled = false
			if heartbeatFunctions["Spin"] then
				StopAnim("spin")
				heartbeatFunctions["Spin"] = nil
			end
		end
		ButtonCosmetic(button, spinEnabled)
	end

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
							hrp.Position = mouse.Hit.Position
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

	flightEnabled = false
	local flightMove = Vector3.zero

	function OnFlightHeartbeat(deltaTime)
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
	end

	function OnFlight(button)
		if button == nil then
			return
		end
		if flightEnabled == false then
			flightEnabled = true
			if heartbeatFunctions["Flight"] == nil then
				humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				heartbeatFunctions["Flight"] = OnFlightHeartbeat
			end
		elseif flightEnabled == true then
			flightEnabled = false
			if heartbeatFunctions["Flight"] then
				StopAnim("flyMove")
				StopAnim("flyIdle")
				heartbeatFunctions["Flight"] = nil
				humanoid.WalkSpeed = defaultWalkSpeed
				humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		end
		ButtonCosmetic(button, flightEnabled)
	end

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

	speedEnabled = false
	currentSpeed = nil
	local accel = 1000
	local maxSpeed = 250

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

	function OnSpeedHeartbeat(deltaTime)
		local moveDir = humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = 70 + math.clamp(hrp.AssemblyLinearVelocity.Magnitude/5, 0, 50)}):Play()
			if currentSpeed == nil  then
				soundsFolder.Wind:Resume()

				local particleAttachment = Instance.new("Attachment")
				particleAttachment.Parent = hrp
				particleAttachment.Name = "RosploitnikSpeedAttachment"
				local speedParticle = particlesFolder:FindFirstChild("Speed1"):Clone()
				speedParticle.Enabled = true
				speedParticle.Parent = particleAttachment
				soundsFolder.Boost:Play()
				
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

				local shockwaveParticle = particlesFolder:FindFirstChild("Shockwave1"):Clone()
				shockwaveParticle:Emit(shockwaveParticle:GetAttribute("emitCount"))
				shockwaveParticle.Parent = hrp.RootRigAttachment
				debris:AddItem(shockwaveParticle, 0.3)
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
			if heartbeatFunctions["Speed"] == nil then
				heartbeatFunctions["Speed"] = OnSpeedHeartbeat
			end
		elseif speedEnabled == true then
			speedEnabled = false
			if heartbeatFunctions["Speed"] then
				StopAnim("boost")
				SpeedDestroyEffects()
				heartbeatFunctions["Speed"] = nil
			end
		end
		ButtonCosmetic(button, speedEnabled)
	end

	local espEnabled = false
	local espLoopStart = 0

	function OnEspHeartbeat()
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
						highlight.OutlineColor = espFillCol
						highlight.FillColor = espOutlineCol
					end
				end
			end
		end
	end

	function OnEsp(button)
		if button == nil then
			return
		end
		if espEnabled == false then
			espEnabled = true
			if heartbeatFunctions["Esp"] == nil then
				espLoopStart = tick()
				heartbeatFunctions["Esp"] = OnEspHeartbeat
			end
		elseif espEnabled == true then
			espEnabled = false
			for i,v in pairs(currentPlayerList) do
				if i.Character and i.Character ~= character then
					if i.Character:FindFirstChild("ESPHighlight") then
						i.Character.ESPHighlight:Destroy()
					end
				end
			end
			if heartbeatFunctions["Esp"] then
				heartbeatFunctions["Esp"] = nil
			end
		end
		ButtonCosmetic(button, espEnabled)
	end
end

runService.Heartbeat:Connect(function(deltaTime)
	for i, v in pairs(heartbeatFunctions) do
		v(deltaTime)
	end
	local fps = 1 / deltaTime
	config["fpsText"].Self.Text = string.format("FPS: %03d", math.floor(fps))
	local speed = hrp.CFrame:VectorToObjectSpace(hrp.AssemblyLinearVelocity)
	config["speedText"].Self.Text = "Speed: (Local) = ".. string.format("%.0f, %.0f, %.0f", speed.X, speed.Y, -speed.Z)
end)

anims = {
	flyIdle = {
		Self = nil,
		Id = "rbxassetid://77529400769588"
	},
	flyMove = {
		Self = nil,
		Id = "rbxassetid://132105268936736"
	},
	boost = {
		Self = nil,
		Id = "rbxassetid://123393210843929"
	},
	spin = {
		Self = nil,
		Id = "rbxassetid://110792133024438"
	}
}

sounds = {
	closeSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://71159461717880"),
		Name = "Close",
		Looped = false,
		Volume = 1.5,
	},
	openSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://139977888272326"),
		Name = "Open",
		Looped = false,
		Volume = 0.2,
	},
	pressSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://8919449656"),
		Name = "Press",
		Looped = false,
		Volume = 1.5,
	},
	pageSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://8919449656"),
		Name = "Page",
		Looped = false,
		Volume = 1.5,
	},
	explodeSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://140615626179933"),
		Name = "Explode",
		Looped = false,
		Volume = 0.5,
	},
	teleportSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://128943714557220"),
		Name = "Teleport",
		Looped = false,
		Volume = 0.5,
	},
	typeSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://70396624145217"),
		Name = "Type",
		Looped = false,
		Volume = 0.1,
	},
	boostSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://136634896824223"),
		Name = "Boost",
		Looped = false,
		Volume = 0.5,
	},
	windSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://100031000096655"),
		Name = "Wind",
		Looped = true,
		Volume = 0.1,
	},
	jumpSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://129715310162737"),
		Name = "Jump",
		Looped = false,
		Volume = 0.5,
	},
	dashSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://6606602837"),
		Name = "Dash",
		Looped = false,
		Volume = 0.5,
	},
	musicSound = {
		SoundId = CreateFile("LoadingDrRosploitnikNow.mp3", gitMain.. "/Sounds/LoadingDrRosploitnikNow.mp3", "rbxassetid://71159461717880"),
		Name = "Music",
		Looped = true,
		Volume = 0.5,
	}
}

trails = {
	trail1 = {
		Name = "Trail",
		FaceCamera = true,
		Lifetime = 0.1,
		Brightness = 1,
		LightEmission = 1,
		LightInfluence = 0,
		WidthScale = NumberSequence.new(1),
		Texture = "rbxassetid://5059527230",
		TextureMode = Enum.TextureMode.Static,
		TextureLength = 50,
		Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.4), NumberSequenceKeypoint.new(1, 1)}
	},
	trail2 = {
		Name = "Trail2",
		FaceCamera = true,
		Lifetime = 0.1,
		Brightness = 1,
		LightEmission = 1,
		LightInfluence = 0,
		WidthScale = NumberSequence.new(1),
		Texture = "rbxassetid://8089452023",
		TextureMode = Enum.TextureMode.Static,
		TextureLength = 200,
		Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.3, 0.4), NumberSequenceKeypoint.new(1, 1)}
	}
}

particles = {
	explosion1 = {
		Name = "Explosion1",
		Brightness = 1,
		Size = NumberSequence.new(5),
		LightEmission = 0,
		Orientation = Enum.ParticleOrientation.FacingCamera,
		Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(135,135,135)), 
			ColorSequenceKeypoint.new(0.49, Color3.fromRGB(135,135,135)), ColorSequenceKeypoint.new(0.51, Color3.fromRGB(255,255,255)),  ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))},
		Texture = "rbxassetid://8734114950",
		Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(0.387, 0), NumberSequenceKeypoint.new(1, 1)},
		Lifetime = NumberRange.new(0.5),
		Speed = NumberRange.new(3),
		Rate = 35,
		EmissionDirection = Enum.NormalId.Top,
		Rotation = NumberRange.new(5),
		FlipbookLayout = Enum.ParticleFlipbookLayout.Grid8x8,
		FlipbookBlendFrames = true,
		FlipbookMode = Enum.ParticleFlipbookMode.OneShot,
		FlipbookStartRandom = false,
		Misc = {
			parentedType = "Part",
			partSize = Vector3.new(18, 18, 18),
			emitCount = 8,
		}
	},
	explosion2 = {
		Name = "Explosion2",
		Brightness = 1,
		Size = NumberSequence.new(1),
		LightEmission = 0,
		Color = ColorSequence.new{ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
			ColorSequenceKeypoint.new(0.49, Color3.fromRGB(255,255,255)), ColorSequenceKeypoint.new(0.51, Color3.fromRGB(84,84,84)), ColorSequenceKeypoint.new(1, Color3.fromRGB(255,255,255))},
		Orientation = Enum.ParticleOrientation.FacingCamera,
		Texture = "rbxassetid://8733226116",
		Lifetime = NumberRange.new(0.75),
		Rate = 50,
		Speed = NumberRange.new(3),
		EmissionDirection = Enum.NormalId.Top,
		Rotation = NumberRange.new(0),
		FlipbookLayout = Enum.ParticleFlipbookLayout.Grid4x4,
		FlipbookBlendFrames = true,
		FlipbookMode = Enum.ParticleFlipbookMode.OneShot,
		FlipbookStartRandom = false,
		Misc = {
			parentedType = "Part",
			partSize = Vector3.new(18, 18, 18),
			emitCount = 8,
		}
	},
	speed1 = {
		Name = "Speed1",
		Brightness = .8,
		LightEmission = 1,
		LightInfluence = 0,
		Orientation = Enum.ParticleOrientation.VelocityParallel,
		Size = NumberSequence.new(0.75),
		Squash = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, -2.2)},
		Texture = "rbxassetid://14196884170",
		Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 1), NumberSequenceKeypoint.new(0.31, 1), NumberSequenceKeypoint.new(0.52, 0.712), NumberSequenceKeypoint.new(1, 1)},
		ZOffset = 0,
		Lifetime = NumberRange.new(0.25),
		EmissionDirection = Enum.NormalId.Top,
		Rate = 1000,
		Rotation = NumberRange.new(0),
		Speed = NumberRange.new(20),
		SpreadAngle = Vector2.new(0, 360),
		Acceleration = Vector3.new(0, 0, 150),
		LockedToPart = true,
		Misc = {
			parentedType = "Attachment",
			attachmentParent = "Hrp",
		}
	},
	shockwave1 = {
		Name = "Shockwave1",
		Brightness = 1,
		LightEmission = 1,
		LightInfluence = 0,
		Orientation = Enum.ParticleOrientation.VelocityPerpendicular,
		Size = NumberSequence.new{NumberSequenceKeypoint.new(0,0), NumberSequenceKeypoint.new(0.62, 10), NumberSequenceKeypoint.new(1, 17)},
		Texture = "rbxassetid://12363806228",
		Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(.8, .7), NumberSequenceKeypoint.new(1, 1)},
		Lifetime = NumberRange.new(0.25),
		Speed = NumberRange.new(0.1),
		EmissionDirection = Enum.NormalId.Front,
		Misc = {
			emitCount = 1
		}
	},
	teleport1 = {
		Name = "Teleport1",
		Brightness = 25,
		LightEmission = 0,
		LightInfluence = 0,
		Color = ColorSequence.new(Color3.fromRGB(0,0,0)),
		Orientation = Enum.ParticleOrientation.FacingCamera,
		Squash = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1.5)},
		Size = NumberSequence.new(2),
		Texture = "rbxassetid://12363816837",
		Transparency = NumberSequence.new{NumberSequenceKeypoint.new(0, 0), NumberSequenceKeypoint.new(1, 1)},
		Lifetime = NumberRange.new(0.1),
		Speed = NumberRange.new(0.01),
		Rotation = NumberRange.new(0),
		EmissionDirection = Enum.NormalId.Front,
		LockedToPart = false,
		Misc = {
			emitCount = 8
		}
	},
}

config = { -- indented so I can remember this fuckin absurd hierarc hy - lelogint
	main = {
		Self = nil,
		Type = "ScreenGui",
		Parent = "PlayerGui",
		Name = "main",
		IgnoreGuiInset = true,
	},
		frame = {
			Self = nil,
			Type = "Frame",
			Parent = "main",
			Name = "frame",
			AnchorPoint = Vector2.new(0.5,0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			BackgroundColor3 = Color3.fromRGB(255,255,255),
			BackgroundTransparency = 1,
			Misc = nil
		},
			topBar = {
				Self = nil,
				Type = "TextButton",
				Text = "",
				Name =  "topBar",
				Parent = "frame",
				BackgroundTransparency = 1,
				ZIndex = 2,
				Position = UDim2.new(0.37, 0, 0.239, 0),
				Size = UDim2.new(0.253, 0, 0.036),
				ClipsDescendants = true,
				Misc = {
					Grabbable = true,
				}
			},
				topBarButton = {
					Self = nil,
					Type = "ImageButton",
					Parent = "topBar",
					Name = "topBarButton",
					BackgroundColor3 = uiPrimaryCol,
					BackgroundTransparency = 0.5,
					AnchorPoint = Vector2.new(0.5,0.5),
					Position = UDim2.new(0.954, 0, 0.52, 0),
					Size = UDim2.new(0.063, 0, 0.774, 0),
					Image = CreateFile("Subtract.png", gitMain.. "/Images/Subtract.png", "rbxassetid://71194643269584"),
					ZIndex = 3,
					Misc = {
						CornerRadius = UDim.new(0, 8),
						Func = UiCloseOpen,
					}
				},
				logo = {
					Self = nil,
					Type = "ImageLabel",
					Parent = "topBar",
					Name = "logo",
					BackgroundTransparency = 1,
					Position = UDim2.new(0.011, 0, 0.1, 0),
					Size = UDim2.new(1, 0, 0.849, 0),
					SizeConstraint = Enum.SizeConstraint.RelativeYY,
					ZIndex = 1,
					Image = CreateFile("DrRosploitnikSmall.png", gitMain.. "/Images/DrRosploitnikSmall.png", "rbxassetid://85950986420145"),
					ImageColor3 = Color3.fromRGB(197, 245, 255),
				},
				textLabelName = {
					Self = nil,
					Type = "TextLabel",
					Parent = "topBar",
					Name = "textLabelName",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.475, 0, 0.517, 0),
					Size = UDim2.new(0.724, 0, 0.724, 0),
					TextScaled = true,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
					TextSize = 22,
					Text = "DR. ROSPLOITNIK",
					TextColor3 = uiPrimaryCol,
					ZIndex = 2,
					FontFace = Font.new(CreateFile("Orbitron-VariableFont_wght.ttf", gitMain.. "/Fonts/Orbitron-VariableFont_wght.ttf", "rbxasset://fonts/families/Michroma.json"),  Enum.FontWeight.Bold),
				},
				topBackgroundImage = {
					Self = nil,
					Type = "ImageLabel",
					Parent = "topBar",
					Name = "topBackgroundImage",
					BackgroundColor3 = uiBackgroundCol,
					BackgroundTransparency = 0,
					Position = UDim2.new(-0.159, 0, -0.569, 0),
					Size = UDim2.new(1.27, 0, 1.916, 0),
					ZIndex = 0,
					Image = CreateFile("MainBackground.png", gitMain.. "/Images/MainBackground.png", "rbxassetid://99688603698464"),
					ImageColor3 = Color3.fromRGB(182, 98, 255),
					ImageTransparency = 0.8,
				},
			stats = {
				Self = nil,
				Type = "Frame",
				Parent = "frame",
				BackgroundTransparency = 1,
				Name = "stats",
				AnchorPoint = Vector2.new(0.5, 0.5),
				Position = UDim2.new(0.421, 0, 0.187, 0),
				Size = UDim2.new(0.111, 0, 0.067, 0),
				ZIndex = 0,
			},
				fpsText = {
					Self = nil,
					Type = "TextLabel",
					Parent = "stats",
					Name = "fpsText",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.176, 0,  0.679, 0),
					Size = UDim2.new(0.284, 0, 0.284, 0),
					ZIndex = 1,
					Text = "FPS: 000",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold),
					TextScaled = true,
					TextSize = 22,
					TextStrokeColor3 = uiPrimaryCol,
					TextStrokeTransparency = 0.5,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				},
				speedText = {
					Self = nil,
					Type = "TextLabel",
					Parent = "stats",
					Name = "speedText",
					BackgroundTransparency = 1,
					AnchorPoint = Vector2.new(0.5, 0.5),
					Position = UDim2.new(0.651, 0,  0.942, 0),
					Size = UDim2.new(1.234, 0, 0.284, 0),
					ZIndex = 1,
					Text = "Speed: (Local) =  0, 0, 0",
					TextColor3 = Color3.fromRGB(0, 0, 0),
					FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold),
					TextScaled = true,
					TextSize = 22,
					TextStrokeColor3 = uiPrimaryCol,
					TextStrokeTransparency = 0.5,
					TextWrapped = true,
					TextXAlignment = Enum.TextXAlignment.Left,
					TextYAlignment = Enum.TextYAlignment.Center,
				},
			holder = {
				Self = nil,
				Type = "Frame",
				Parent = "frame",
				Name = "holder",
				BackgroundTransparency = 1,
				Position = UDim2.new(0.37, 0, 0.239, 0),
				Size = UDim2.new(0.253, 0, 0.501, 0),
				ZIndex = 0,
				ClipsDescendants = true,
			},
				backgroundImage = {
					Self = nil,
					Type = "ImageLabel",
					Parent = "holder",
					Name = "backgroundImage",
					BackgroundColor3 = uiBackgroundCol,
					BackgroundTransparency = 0,
					Position = UDim2.new(-0.159, 0, -0.589, 0),
					Size = UDim2.new(1.27, 0, 1.916, 0),
					ZIndex = 0,
					Image = CreateFile("MainBackground.png", gitMain.. "/Images/MainBackground.png", "rbxassetid://99688603698464"),
					ImageColor3 = Color3.fromRGB(182, 98, 255),
					ImageTransparency = 0.8,
				},
				sideBar = {
					Self = nil,
					Type = "Frame",
					Parent = "holder",
					Name = "sideBar",
					BackgroundTransparency = 1,
					Position = UDim2.new(0, 0, 0.071, 0),
					Size = UDim2.new(0.086, 0, 0.929, 0),
					ZIndex = 1,
					ClipsDescendants = true,
				},
					selected = {
						Self = nil,
						Type = "Frame",
						Parent = "sideBar",
						Name = "selected",
						BackgroundColor3 = Color3.fromRGB(255, 255, 255),
						BackgroundTransparency = 0.8,
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 0.086, 0),
						ZIndex = 2,
						ClipsDescendants = true,
					},
						selectedHighlight = {
							Self = nil,
							Type = "Frame",
							Parent = "selected",
							Name = "selectedHighlight",
							BackgroundColor3 = uiSecondaryCol,
							BackgroundTransparency = 0,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(0.13, 0, 1, 0),
							ZIndex = 1,
							ClipsDescendants = true,
						},
					sideBarInner = {
						Self = nil,
						Type = "Frame",
						Parent = "sideBar",
						Name = "sideBarInner",
						BackgroundTransparency = 1,
						Position = UDim2.new(0, 0, 0, 0),
						Size = UDim2.new(1, 0, 1, 0),
						ZIndex = 1,
						ClipsDescendants = false,
						Misc = {
							UiListLayout = true
						}
					},
						barMain = {
							Self = nil,
							Type = "ImageButton",
							Parent = "sideBarInner",
							Name = "barMain",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 0, 0),
							Size = UDim2.new(1, 0, 0.086, 0),
							Image = CreateFile("SidebarScript.png", gitMain.. "/Images/SidebarScript.png", "rbxassetid://73795180567127"),
							ImageColor3 = Color3.fromRGB(255, 255, 255),
							ImageTransparency = 0,
							ScaleType = Enum.ScaleType.Fit,
							Misc = {
								Func = OnSidebarButton,
							}
						},
						barContacts = {
							Self = nil,
							Type = "ImageButton",
							Parent = "sideBarInner",
							Name = "barContacts",
							BackgroundTransparency = 1,
							Position = UDim2.new(0, 0, 0.1, 0),
							Size = UDim2.new(1, 0, 0.086, 0),
							Image = CreateFile("SidebarGuy.png", gitMain.. "/Images/SidebarGuy.png", "rbxassetid://129062443433297"),
							ImageColor3 = Color3.fromRGB(255, 255, 255),
							ImageTransparency = 0,
							ScaleType = Enum.ScaleType.Fit,
							Misc = {
								Func = OnSidebarButton,
							}
						},
				scroll = {
					Self = nil,
					Type = "ScrollingFrame",
					Parent = "holder",
					Name = "scroll",
					BackgroundTransparency = 1,
					Position = UDim2.new(0.086, 0, 0.071, 0),
					Size = UDim2.new(0.914, 0, 0.929, 0),
					ZIndex = 2,
					ClipsDescendants = false,
					CanvasPosition = Vector2.new(0, 0),
					CanvasSize = UDim2.new(0, 0, 4, 0),
					HorizontalScrollBarInset = Enum.ScrollBarInset.None,
					ScrollBarImageColor3 = uiPrimaryCol,
					ScrollBarThickness = 8,
					ScrollBarImageTransparency = 0,
					ScrollingDirection = Enum.ScrollingDirection.Y,
					ScrollingEnabled = true,
					VerticalScrollBarInset = Enum.ScrollBarInset.Always,
					VerticalScrollBarPosition = Enum.VerticalScrollBarPosition.Right,
					Misc = {
						UiListLayout = true
					}
				},
					antiGravity = {
						Self = nil,
						Type = "Frame",
						Parent = "scroll",
						Name = "antiGravity",
						BackgroundTransparency = 1,
						BorderColor3 = Color3.fromRGB(255, 255, 255),
						BorderSizePixel = 0,
						Size = UDim2.new(1, 0, 0.06, 0),
						ZIndex = 1,
						LayoutOrder = 0,
						ClipsDescendants = false,
					},
						antiGravityBorder = {
							Self = nil,
							Type = "Frame",
							Parent = "antiGravity",
							Name = "antiGravityBorder",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = uiPrimaryCol,
							BackgroundTransparency = 0,
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(1, 0, 1, 0),
							Misc = {
								CornerRadius = UDim.new(0, 4),
							}
						},
						antiGravityInner = {
							Self = nil,
							Type = "Frame",
							Parent = "antiGravity",
							Name = "antiGravityInner",
							AnchorPoint = Vector2.new(0.5, 0.5),
							BackgroundColor3 = uiBackgroundCol,
							BackgroundTransparency = 0,
							Position = UDim2.new(0.5, 0, 0.5, 0),
							Size = UDim2.new(0.987, 0, 0.94, 0),
							Misc = {
								CornerRadius = UDim.new(0, 4),
							}
						},
						antiGravityTextButton = {
							Self = nil,
							Type = "TextButton",
							Name = "antiGravityTextButton",
							Parent = "antiGravity",
							BackgroundColor3 = uiPrimaryCol,
							BackgroundTransparency = 0,
							Position = UDim2.new(0.784, 0, 0.314, 0),
							Size = UDim2.new(0.187, 0, 0.342, 0),
							Text = "OFF",
							FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold),
							TextColor3 = uiBackgroundCol,
							TextScaled = false,
							TextSize = 14,
							TextWrapped = false,
							Misc = {
								CornerRadius = UDim.new(0, 20),
								Func = OnFloat,
							}
						},
}

function AnimationConstructor()
	for i, v in pairs(anims) do
		local animation = Instance.new("Animation")
		animation.AnimationId = v["Id"]
		v["Self"] = humanoid:LoadAnimation(animation)
	end
end

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
					particle:SetAttribute(key2, value2)
				end
			end
			particle.Parent = folder
			particle.Enabled = false
		end
	end
	return folder
end

function SoundConstructor()
	local soundsPath = gitMain.. "/Sounds/"
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
			bar.Parent.Position = UDim2.new(0, mousePos.X, 0.24, mousePos.Y)
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
				obj[key] = value 
			elseif key == "Misc" then
				if value["Func"] then
					obj.MouseButton1Click:Connect(function()
						value["Func"](obj)
					end)
				end
				if value["UiListLayout"] then
					local uiList = Instance.new("UIListLayout")
					uiList.Parent = obj
					uiList.Padding = UDim.new(0,5)
					uiList.HorizontalFlex = Enum.UIFlexAlignment.None
					uiList.FillDirection = Enum.FillDirection.Vertical
					uiList.SortOrder = Enum.SortOrder.LayoutOrder
					uiList.VerticalAlignment = Enum.VerticalAlignment.Top
					uiList.HorizontalAlignment = Enum.HorizontalAlignment.Left
				end
				if value["GradientType"] == 1 then
					local gradient = Instance.new("UIGradient")
					gradient.Color = uiGradientTypes[value["GradientType"] - 1]
				end
				if value["CornerRadius"] then
					local corner = Instance.new("UICorner")
					corner.CornerRadius = value["CornerRadius"]
					corner.Parent = obj
				end
				if value["Grabbable"] then
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