
local mainFunctions = {}

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

mainFunctions.onSideBarButton = function OnSidebarButton(button)
	if button == nil then
		return
	end
	if config["selected"].Self then
		local selectBox = config["selected"].Self
		tweenService:Create(selectBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = button.Position}):Play()
		soundsFolder:FindFirstChild("Page"):Play()
	end
end

local open = true
mainFunctions.uiCloseOpen = function UiCloseOpen(button)
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

mainFunctions.onSpam = function OnSpam(button, heartbeatFunctions)
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
mainFunctions.onPlayerTeleport = function OnPlayerTeleport(button)
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
mainFunctions.onMusic = function OnMusic(button)
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

mainFunctions.onSpin = function OnSpin(button, heartbeatFunctions)
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
mainFunctions.onTeleport = function OnTeleport(button)
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
mainFunctions.onExplode = function OnExplode(button)
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

mainFunctions.onFlight = function OnFlight(button, heartbeatFunctions)
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

mainFunctions.onSpeed = function OnSpeed(button, heartbeatFunctions)
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

mainFunctions.onEsp = function OnEsp(button, heartbeatFunctions)
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

return mainFunctions