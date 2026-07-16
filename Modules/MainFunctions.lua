local userInputService = game:GetService("UserInputService")
local tweenService = game:GetService("TweenService")
local players = game:GetService("Players")
local debris = game:GetService("Debris")

local dedicatedFunctions = {
	[142823291] = "mm2",
	[606849621] = "jailbreak",
	[6872265039] = "bedwars",
}

return function(core)
	local mainFunctions = {}
	function core.StopAnim(string)
		core.anims[string].Self:Stop()
	end
	
	function core.PlayAnim(string, speed)
		if core.anims[string].Self.IsPlaying == false then
			core.anims[string].Self:Play()
		elseif speed then
			if core.anims[string].Self.Speed ~= speed then
				core.anims[string].Self:AdjustSpeed(speed)
			end
		end
	end
	
	function core.ButtonCosmetic(button, bool)
		local pressSound = core.soundsFolder:FindFirstChild("Press")
		if pressSound then pressSound:Play() end
		if bool == true then
			button.Text = "ON"
			button.BackgroundColor3 = core.globalConfigs.uiPrimaryCol
			button.TextColor3 = core.globalConfigs.uiBackgroundCol
			button.Parent.ImageColor3 = core.globalConfigs.uiPrimaryCol
		else
			button.Text = "OFF"
			button.BackgroundColor3 = core.globalConfigs.uiSecondaryCol
			button.TextColor3 = core.globalConfigs.uiBackgroundCol
			button.Parent.ImageColor3 = core.globalConfigs.uiSecondaryCol
		end
	end
	
	function core.OnSideBarButton(button)
		if core.ui.selected.Self then
			local selectBox = core.ui.selected.Self
			tweenService:Create(selectBox, TweenInfo.new(0.2, Enum.EasingStyle.Quint, Enum.EasingDirection.Out), {Position = button.Position}):Play()
			core.soundsFolder:FindFirstChild("Page"):Play()
		end
	end
	
	local open = true
	function core.UiCloseOpen(button)
		if button == nil or not core.ui.holder.Self then
			return
		end
		local uiHolder = core.ui.holder.Self
		if open == true then
			open = false
			tweenService:Create(uiHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(uiHolder.Size.X.Scale, 0, 0, 0)}):Play()
			core.soundsFolder:FindFirstChild("Close"):Play()
		elseif open == false then
			open = true
			tweenService:Create(uiHolder, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {Size = UDim2.new(uiHolder.Size.X.Scale, 0, core.globalConfigs.holderDefaultSize.Y.Scale, 0)}):Play()
			core.soundsFolder:FindFirstChild("Open"):Play()
		end
	end
	
	function core.DisableAll()
		for i, v in pairs(mainFunctions) do
			v(false, true)
		end
	end
	
	local floatEnabled = false
	function mainFunctions.OnFloat(button, forceDeactivate)
		if floatEnabled == true or forceDeactivate then
			floatEnabled = false
			workspace.Gravity = core.defaultGravity
		elseif floatEnabled == false then
			floatEnabled = true	
			workspace.Gravity = .1
		end
		core.ButtonCosmetic(core.ui.floatToggle.Self, floatEnabled)
	end

	local spamEnabled = false
	local spamLoopStart = 0
	local spamCooldown = 0.5
	local spamMessage = "I LOVE ROSPLOITNIK!"
	function core.OnSpamHearbeat()
		local elapsed = tick() - spamLoopStart
		if elapsed > spamCooldown then
			elapsed = 0
			spamLoopStart = tick()
			core.generalChannel:SendAsync(spamMessage)
		end
	end
	
	function core.OnSpam(button, forceDeactivate)
		if spamEnabled == true or forceDeactivate then
			spamEnabled = false
			if core.heartbeatFunctions["Spam"] then
				heartbeatFunctions["Spam"] = nil
			end
		elseif spamEnabled == false then
			if type(tonumber(button.Parent.SpamInputCooldown.Text)) == "number" then
				spamCooldown = tonumber(button.Parent.SpamInputCooldown.Text)
			end
			if type(button.Parent.SpamInputMessage.Text) == "string" then
				spamMessage = button.Parent.SpamInputMessage.Text
			end
			spamEnabled = true
			if core.heartbeatFunctions["Spam"] == nil then
				spamLoopStart = tick()
				heartbeatFunctions["Spam"] = core.OnSpamHearbeat
			end
		end
		core.ButtonCosmetic(button, spamEnabled)
	end
	
	function core.OnPlayerTeleport(button, forceDeactivate)
		local text = ""
		if players:FindFirstChild(text) then
			local otherPlayer = players[text]
			if otherPlayer.Character then
				local otherCharacter = otherPlayer.Character
				
			end
		end
	end

	local musicEnabled = false
	function mainFunctions.OnMusic(button, forceDeactivate)
		if musicEnabled == true or forceDeactivate then
			musicEnabled = false
			core.soundsFolder.Music:Stop()
		elseif musicEnabled == false then
			musicEnabled = true
			core.soundsFolder.Music.SoundId = "rbxassetid://".. button.Parent.MusicInputId.Text
			core.soundsFolder.Music.Volume = button.Parent.MusicInputVolume.Text
			core.soundsFolder.Music:Play()
		end
		core.ButtonCosmetic(button, musicEnabled)
	end

	local spinEnabled = false
	function mainFunctions.OnSpin(button, forceDeactivate)
		if spinEnabled == true or forceDeactivate then
			spinEnabled = false
			core.StopAnim("spin")
		elseif spinEnabled == false then
			spinEnabled = true
			core.PlayAnim("spin", 5)
			anims["spin"].Self.Priority = Enum.AnimationPriority.Action4
		end
		core.ButtonCosmetic(button, spinEnabled)
	end

	local teleportEnabled = false
	local teleportClickFunc = nil
	function mainFunctions.OnTeleport(button, forceDeactivate)
		if teleportEnabled == true or forceDeactivate then
			teleportEnabled = false
			if teleportClickFunc ~= nil then
				teleportClickFunc:Disconnect()
				teleportClickFunc = nil
			end
		elseif teleportEnabled == false then
			teleportEnabled = true
			if teleportClickFunc == nil then
				teleportClickFunc = userInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end
					if input.UserInputType == Enum.UserInputType.MouseButton3 then
						if core.mouse.Target then
							local effectPart = Instance.new("Part")
							effectPart.Position = core.hrp.Position
							effectPart.Parent = workspace
							effectPart.Anchored = true
							effectPart.CanCollide = false
							effectPart.CanTouch = false
							effectPart.CanQuery = false
							effectPart.Size = Vector3.new(5,5,5)
							effectPart.Transparency = 1
							local teleportParticle1 = core.particlesFolder:FindFirstChild("Teleport1"):Clone()
							teleportParticle1.Parent = effectPart
							teleportParticle1:Emit(teleportParticle1:GetAttribute("emitCount"))

							local teleportSound = core.soundsFolder.Teleport:Clone()
							teleportSound.Parent = core.soundsFolder
							teleportSound:Play()
							debris:AddItem(teleportSound, 1)
							hrp.Position = core.mouse.Hit.Position
							local camType = Enum.CameraType.Custom
							workspace.CurrentCamera.CameraType = Enum.CameraType.Scriptable
							task.wait(.1)
							workspace.CurrentCamera.CameraType = camType
						end
					end
				end)
			end
		end
		core.ButtonCosmetic(button, teleportEnabled)
	end

	local explodeEnabled = false
	local explodeClickFunc = nil
	function mainFunctions.OnExplode(button, forceDeactivate)
		if explodeEnabled == true or forceDeactivate then
			explodeEnabled = false
			if explodeClickFunc ~= nil then
				explodeClickFunc:Disconnect()
				explodeClickFunc = nil
			end
		elseif explodeEnabled == false then
			explodeEnabled = true
			if explodeClickFunc == nil then
				explodeClickFunc = userInputService.InputBegan:Connect(function(input, gameProcessed)
					if gameProcessed then
						return
					end
					if input.UserInputType == Enum.UserInputType.MouseButton1 then
						if core.mouse.Target then
							local effectPart = Instance.new("Part")
							effectPart.Position = core.mouse.Hit.Position
							effectPart.Parent = workspace
							effectPart.Anchored = true
							effectPart.CanCollide = false
							effectPart.CanTouch = false
							effectPart.CanQuery = false
							effectPart.Size = Vector3.new(10,10,10)
							effectPart.Transparency = 1
							local explodeSound = core.soundsFolder.Explode:Clone()
							explodeSound.Parent = core.soundsFolder
							explodeSound:Play()
							debris:AddItem(explodeSound, 1)
							local explodeParticle1 = core.particlesFolder:FindFirstChild("Explosion1"):Clone()
							explodeParticle1.Parent = effectPart
							explodeParticle1:Emit(explodeParticle1:GetAttribute("emitCount"))
							local explodeParticle2 = core.particlesFolder:FindFirstChild("Explosion2"):Clone()
							explodeParticle2.Parent = effectPart
							explodeParticle2:Emit(explodeParticle2:GetAttribute("emitCount"))
							debris:AddItem(effectPart, 1)
							local explosion = Instance.new("Explosion")
							explosion.Position = core.mouse.Hit.Position
							explosion.Parent = workspace
							core.mouse.Target:Destroy()
						end
					end
				end)
			end
		end
		core.ButtonCosmetic(button, explodeEnabled)
	end

	local flightEnabled = false
	local flightMove = Vector3.zero
	local function OnFlightHeartbeat(deltaTime)
		local direction = workspace.CurrentCamera.CFrame:VectorToObjectSpace(core.humanoid.MoveDirection)
		flightMove = ((workspace.CurrentCamera.CFrame.RightVector * direction.X)  + (-workspace.CurrentCamera.CFrame.LookVector * direction.Z)).Unit
		humanoid.WalkSpeed = 0
		if flightMove.Magnitude > 0 then
			core.StopAnim("flyIdle")
			core.PlayAnim("flyMove", core.hrp.AssemblyLinearVelocity.Magnitude /100)
			core.hrp.CFrame = core.hrp.CFrame:Lerp(CFrame.lookAt(core.hrp.Position, core.hrp.Position + flightMove, workspace.CurrentCamera.CFrame.UpVector), 0.3 * (1 - deltaTime))
		else
			core.StopAnim("flyMove")
			core.PlayAnim("flyIdle", 3)
			hrp.CFrame = core.hrp.CFrame:Lerp( CFrame.lookAt(core.hrp.Position, core.hrp.Position + workspace.CurrentCamera.CFrame.LookVector, workspace.CurrentCamera.CFrame.UpVector), 0.05 * (1 - deltaTime))
		end
		if direction.Magnitude > 0 and speedEnabled == false then
			hrp.AssemblyLinearVelocity = flightMove * 25
		else
			hrp.AssemblyLinearVelocity /= 1 + (deltaTime * 5)
		end
		hrp.AssemblyAngularVelocity = Vector3.zero
	end

	function mainFunctions.OnFlight(button, forceDeactivate)
		if flightEnabled == true or forceDeactivate then
			flightEnabled = false
			if core.heartbeatFunctions["Flight"] then
				core.StopAnim("flyMove")
				core.StopAnim("flyIdle")
				heartbeatFunctions["Flight"] = nil
				core.humanoid.WalkSpeed = core.defaultWalkSpeed
				core.humanoid:ChangeState(Enum.HumanoidStateType.Freefall)
			end
		elseif flightEnabled == false then
			flightEnabled = true
			if core.heartbeatFunctions["Flight"] == nil then
				core.humanoid:ChangeState(Enum.HumanoidStateType.Physics)
				heartbeatFunctions["Flight"] = OnFlightHeartbeat
			end
		end
		core.ButtonCosmetic(button, flightEnabled)
	end

	speedEnabled = false
	local currentSpeed = nil
	local accel = 1000
	local maxSpeed = 250
	local function SpeedDestroyEffects()
		if core.hrp:FindFirstChild("RosploitnikSpeedAttachment") then
			tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = 70}):Play()
			core.soundsFolder.Wind:Pause()
			core.hrp.RosploitnikSpeedAttachment.Speed1.Enabled = false
			debris:AddItem(core.hrp.RosploitnikSpeedAttachment, 0.2)
			core.hrp.RosploitnikTrailAttachment1.Trail.Enabled = false
			core.hrp.RosploitnikTrailAttachment1.Trail2.Enabled = false
			debris:AddItem(core.hrp.RosploitnikTrailAttachment1, 0.2)
			debris:AddItem(core.hrp.RosploitnikTrailAttachment2, 0.2)
		end
	end

	local function OnSpeedHeartbeat(deltaTime)
		local moveDir = core.humanoid.MoveDirection
		if moveDir.Magnitude > 0 then
			tweenService:Create(workspace.CurrentCamera, TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {FieldOfView = 70 + math.clamp(core.hrp.AssemblyLinearVelocity.Magnitude/5, 0, 50)}):Play()
			if currentSpeed == nil  then
				core.soundsFolder.Wind:Resume()

				local particleAttachment = Instance.new("Attachment")
				particleAttachment.Parent = core.hrp
				particleAttachment.Name = "RosploitnikSpeedAttachment"
				local speedParticle = core.particlesFolder:FindFirstChild("Speed1"):Clone()
				speedParticle.Enabled = true
				speedParticle.Parent = particleAttachment
				core.soundsFolder.Boost:Play()

				local trailAttachment1 = Instance.new("Attachment")
				trailAttachment1.Parent = core.hrp
				trailAttachment1.Name = "RosploitnikTrailAttachment1"
				trailAttachment1.Position = Vector3.new(0,-3,0)
				local trailAttachment2 = Instance.new("Attachment")
				trailAttachment2.Parent = core.hrp
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
				for i, v in pairs(core.trails["trail1"]) do
					trail[i] = v
				end
				for i, v in pairs(core.trails["trail2"]) do
					trail2[i] = v
				end

				local shockwaveParticle = core.particlesFolder:FindFirstChild("Shockwave1"):Clone()
				shockwaveParticle:Emit(shockwaveParticle:GetAttribute("emitCount"))
				shockwaveParticle.Parent = core.hrp.RootRigAttachment
				debris:AddItem(shockwaveParticle, 0.3)
				if flightEnabled == false then
					currentSpeed = -core.hrp.CFrame:VectorToObjectSpace(core.hrp.AssemblyLinearVelocity).Z
				else
					local flightCFrame = core.hrp.CFrame + flightMove
					currentSpeed = -flightCFrame:VectorToObjectSpace(core.hrp.AssemblyLinearVelocity).Z
				end
			end
			if core.hrp:FindFirstChild("RosploitnikSpeedAttachment") then
				local factor = 0
				if flightEnabled == true then
					factor = 50
				else
					factor = 60
				end
				local velVector = core.hrp.AssemblyLinearVelocity / factor
				core.hrp.RosploitnikSpeedAttachment.WorldCFrame = core.hrp.RosploitnikSpeedAttachment.WorldCFrame:Lerp(CFrame.lookAt(core.hrp.Position + velVector, core.hrp.Position + core.hrp.AssemblyLinearVelocity), 0.1 * (1 - deltaTime))
			end
			if flightEnabled == false then
				core.PlayAnim("boost", core.hrp.AssemblyLinearVelocity.Magnitude / 75)
				currentSpeed = math.clamp(currentSpeed + (accel * deltaTime),  0, maxSpeed)
				local speedLocalSpace = core.hrp.CFrame:VectorToObjectSpace(core.hrp.AssemblyLinearVelocity)
				local speedLocalSpace = Vector3.new(speedLocalSpace.X / (1 + (1/deltaTime)), speedLocalSpace.Y, -currentSpeed)
				core.hrp.AssemblyLinearVelocity = core.hrp.CFrame:VectorToWorldSpace(speedLocalSpace)
			else
				core.StopAnim("boost")
				currentSpeed = math.clamp(currentSpeed + (accel * deltaTime),  0, maxSpeed)
				core.hrp.AssemblyLinearVelocity = flightMove * currentSpeed 
			end
		else
			core.StopAnim("boost")
			currentSpeed = nil
			SpeedDestroyEffects()
		end
	end

	function mainFunctions.OnSpeed(button, forceDeactivate)
		if speedEnabled == true or forceDeactivate then
			speedEnabled = false
			if core.heartbeatFunctions["Speed"] then
				core.StopAnim("boost")
				SpeedDestroyEffects()
				core.heartbeatFunctions["Speed"] = nil
			end
		elseif speedEnabled == false then
			if type(tonumber(core.ui["speed".. "Input".. "MaxSpeed"].Text)) == "number" then
				maxSpeed = core.ui["speed".. "Input".. "MaxSpeed"].Text
			end
			if type(tonumber(core.ui["speed".. "Input".. "Acceleration"].Text)) == "number" then
				accel = core.ui["speed".. "Input".. "Acceleration"].Text
			end
			speedEnabled = true
			if core.heartbeatFunctions["Speed"] == nil then
				core.heartbeatFunctions["Speed"] = OnSpeedHeartbeat
			end
		end
		core.ButtonCosmetic(button, speedEnabled)
	end

	local espEnabled = false
	local espLoopStart = 0
	local function OnEspHeartbeat()
		local elapsed = tick() - espLoopStart
		if elapsed > 0.5 then
			elapsed = 0
			espLoopStart = tick()
			for i,v in pairs(core.currentPlayerList) do
				if i.Character and i.Character ~= core.character and elapsed <= 0.5 then
					if not i.Character:FindFirstChild("ESPHighlight") then
						local highlight = Instance.new("Highlight")
						highlight.Parent = i.Character
						highlight.Name = "ESPHighlight"
						highlight.FillTransparency = 0.5
						highlight.DepthMode = Enum.HighlightDepthMode.AlwaysOnTop
						highlight.OutlineColor = core.globalConfigs.espFillCol
						highlight.FillColor = core.globalConfigs.espOutlineCol
					end
				end
			end
		end
	end

	function mainFunctions.OnEsp(button, forceDeactivate)
		if espEnabled == true or forceDeactivate then
			espEnabled = false
			for i,v in pairs(core.currentPlayerList) do
				if i.Character and i.Character ~= core.character then
					if i.Character:FindFirstChild("ESPHighlight") then
						i.Character.ESPHighlight:Destroy()
					end
				end
			end
			if core.heartbeatFunctions["Esp"] then
				core.heartbeatFunctions["Esp"] = nil
			end
		elseif espEnabled == false then
			espEnabled = true
			if core.heartbeatFunctions["Esp"] == nil then
				espLoopStart = tick()
				core.heartbeatFunctions["Esp"] = OnEspHeartbeat
			end
		end
		core.ButtonCosmetic(button, espEnabled)
	end
	
	function core.InternalFrames()
		core.InternalFrameConstructor(mainFunctions.OnFloat, {}, {}, "float", "Float around in zero gravity.")
		core.InternalFrameConstructor(mainFunctions.OnSpeed, {"MaxSpeed", "Acceleration"}, {250, 1000}, "speed", "Go really fast. Speed picker in box")
	end

	return mainFunctions
end