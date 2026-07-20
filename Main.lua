local metaTable = {}
local metaRules = {}
local core = setmetatable(metaTable, metaRules)

local players = game:GetService('Players')
local runService = game:GetService("RunService")
local replicatedStorage = game:GetService("ReplicatedStorage")
local tweenService = game:GetService("TweenService")
local userInputService = game:GetService("UserInputService")
local textChatService = game:GetService("TextChatService")
local debris = game:GetService("Debris")
local player = players.LocalPlayer
local playerGui = player.PlayerGui
local mouse = player:GetMouse()

local images = {}
local ui = {}
local particles = {}
local trails = {}
local sounds = {}

local function SetGlobals()
	core.env = getfenv()
	core.isFileFunc = core.env.isfile
	core.writeFileFunc = core.env.writefile
	core.getCustomAssetFunc = core.env.getcustomasset
	core.isStudio = runService:IsStudio()
	if not core.isStudio then -- REMOVE WHEN UPLOADING TO GITHUB!!!! REMEMBER THIS PLEEEAASSEE!!!
		core.globalConfigs = loadstring(game:HttpGet(core.gitBranch.. "/Modules/Data/GlobalConfigDefaults.lua"))()
	else
		core.globalConfigs = require(script.Data:WaitForChild("GlobalConfigDefaults"))
	end
end

local function GrabPlayers(allInitialPlayers)
	local currentPlayerList = {}
	for i = 1, #allInitialPlayers do
		currentPlayerList[allInitialPlayers[i]] = true
	end
	return currentPlayerList
end

function core:CreateFile(name, path, alternate)
	if self.isFileFunc and self.writeFileFunc and self.getCustomAssetFunc and not self.isStudio then
		if not self.isFileFunc(name) then
			local success, data = pcall(function()
				return game:HttpGet(path)
			end)
			if success and data then
				self.writeFileFunc(name, data)
			end
		end
		if self.isFileFunc(name) then
			print("Retrieved file: "..name)
			return self.getCustomAssetFunc(name)
		end
	elseif alternate then
		print("Error occured retrieving file: ".. name.. ", Using backup asset id...")
		return alternate
	end
end

local function Startup()
	core.gitBranch = "https://raw.githubusercontent.com/desognedbyjonturtletaub/Dr.-Rosploitnik/v0.1.0"
	core.player = players.LocalPlayer
	core.playerGui = player.PlayerGui
	core.character = core.player.Character or core.player.CharacterAdded:Wait()
	core.humanoid = core.character:WaitForChild("Humanoid")
	core.hrp = core.character:WaitForChild("HumanoidRootPart")
	core.cam = workspace.CurrentCamera
	core.textChannels = textChatService:WaitForChild("TextChannels")
	core.generalChannel = core.textChannels:WaitForChild("RBXGeneral")
	core.mouse = player:GetMouse()

	core.heartbeatFunctions = {}
	core.currentPlayerList = GrabPlayers(players:GetChildren())

	core.defaultWalkSpeed = core.humanoid.WalkSpeed
	core.defaultJumpPower = core.humanoid.JumpPower
	core.defaultGravity = workspace.Gravity

	core.debugMenu = true
	core.uiAssignedPrimary = {}
	core.uiAssignedSecondary = {}
	core.uiAssignedBackground = {}
	
	SetGlobals()
	
	if not core.isStudio then -- REMOVE WHEN UPLOADING TO GITHUB!!!! REMEMBER THIS PLEEEAASSEE!!!
		loadstring(game:HttpGet(core.gitBranch.. "/Constructors.lua"))(core)
		core.mainFunctions = loadstring(game:HttpGet(core.gitBranch.. "/Modules/MainFunctions.lua"))(core)
		core.sounds = loadstring(game:HttpGet(core.gitBranch.. "/Modules/Data/Sounds.lua"))(core)
		core.trails = loadstring(game:HttpGet(core.gitBranch.. "/Modules/Data/Trails.lua"))(core)
		core.particles = loadstring(game:HttpGet(core.gitBranch.. "/Modules/Data/Particles.lua"))(core)
		core.ui = loadstring(game:HttpGet(core.gitBranch.. "/Modules/Data/Ui.lua"))(core)
		core.anims = core.AnimationConstructor(loadstring(game:HttpGet(core.gitBranch.. "/Modules/Data/core.anims.lua"))())
	else
		require(script:WaitForChild("Constructors"))(core)
		core.mainFunctions = require(script:WaitForChild("MainFunctions"))(core)
		core.sounds = require(script.Data:WaitForChild("Sounds"))(core)
		core.trails = require(script.Data:WaitForChild("Trails"))(core)
		core.particles = require(script.Data:WaitForChild("Particles"))(core)
		core.ui = require(script.Data:WaitForChild("Ui"))(core)
		core.anims = core.AnimationConstructor(require(script.Data:WaitForChild("Anims")))
	end
	
	core.InternalFrames()
end

player.CharacterAdded:Connect(function(char)
	core.character = char
	core.humanoid = char:WaitForChild("Humanoid")
	core.hrp = char:WaitForChild("HumanoidRootPart")
	core.defaultWalkSpeed = core.humanoid.WalkSpeed
	core.defaultJumpPower = core.humanoid.JumpPower
	if not core.isStudio then -- REMOVE WHEN UPLOADING TO GITHUB!!!! REMEMBER THIS PLEEEAASSEE!!!
		core.anims = core.AnimationConstructor(loadstring(game:HttpGet(core.gitBranch.. "/Modules/Data/core.anims.lua"))())
	else
		core.anims = core.AnimationConstructor(require(script.Data:WaitForChild("Anims")))
	end
end)

players.PlayerAdded:Connect(function(player)
	core.currentPlayerList[player] = true
end)

players.PlayerRemoving:Connect(function(player)
	core.currentPlayerList[player] = nil
end)

runService.Heartbeat:Connect(function(deltaTime)
	if core.heartbeatFunctions then
		for i, v in pairs(core.heartbeatFunctions) do
			v(deltaTime)
		end
	end
	--[[
	local fps = 1 / deltaTime
	config["fpsText"].Self.Text = string.format("FPS: %03d", math.floor(fps))
	local speed = core.hrp.CFrame:VectorToObjectSpace(core.hrp.AssemblyLinearVelocity)
	config["speedText"].Self.Text = "Speed: (Local) = ".. string.format("%.0f, %.0f, %.0f", speed.X, speed.Y, -speed.Z)
	]]--
end)


function ScriptSetup()
	core.UiConstructor()
	core.soundsFolder = core.SoundConstructor()
	core.particlesFolder = core.ParticleConstructor()
end

game.StarterGui:SetCore("SendNotification", {
	Title = "Dr. Rosploitnik",
	Icon = "rbxassetid://105076512076789",
	Text = "Loading Dr. Rosploitnik Now",
})
Startup()
ScriptSetup()