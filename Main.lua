local main = {}

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
local gitMain = "https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/v0.1.0"
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

print("Loading primary functions")
local mainFunctions = loadstring(game:HttpGet(gitMain.. "/Modules/MainFunctions.lua"))()

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
						Func = mainFunctions.uiCloseOpen,
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
								Func = mainFunctions.onSideBarButton,
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
								Func = mainFunctions.onSideBarButton,
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
								Func = mainFunctions.onFloat,
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
						value["Func"](obj, heartbeatFunctions)
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