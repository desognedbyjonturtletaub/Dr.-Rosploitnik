local players = game:GetService('Players')
local runService = game:GetService("RunService")

local player = players.LocalPlayer
local playerGui = player.PlayerGui
local character = player.Character or player.CharacterAdded:Wait()
local humanoid = character:WaitForChild("Humanoid")
local hrp = character:WaitForChild("HumanoidRootPart")
local currentPlayerList = {}
local allInitialPlayers = players:GetChildren()

local holderDefaultSize = UDim2.new(0.194, 0, 0.461, 0)

function UiSetup()
	local uiCorner = Instance.new("UICorner")
	uiCorner.CornerRadius = UDim.new(0, 8)
	
	local uiGradient = Instance.new("UIGradient")
	uiGradient.Color = ColorSequence.new{
		ColorSequenceKeypoint.new(0, Color3.fromRGB(255,255,255)),
		ColorSequenceKeypoint.new(1, Color3.fromRGB(97,101,135))
	}
	uiGradient.Rotation = 90
	
	local main = Instance.new("ScreenGui")
	main.Parent = playerGui
	main.Name = "Main"
	
	local frame = Instance.new("Frame")
	frame.Parent = main
	frame.Name = "Frame"
	frame.Position = UDim2.new(0, 0, 0, 0)
	frame.Size = UDim2.new(1, 0, 1, 0)
	frame.BackgroundColor3 = Color3.fromRGB(255,255,255)
	frame.BackgroundTransparency = 1
	
	-- Top bar section --
	local topBar = Instance.new("Frame")
	topBar.Parent = frame
	topBar.Name = "TopBar"
	topBar.Position = UDim2.new(0.385, 0, 0.272, 0)
	topBar.Size = UDim2.new(0.23, 0, 0.026, 0)
	topBar.BackgroundColor3 = Color3.fromRGB(95, 99, 118)
	topBar.BackgroundTransparency = 0.5
	topBar.BorderSizePixel = 0
	topBar.ZIndex =  2
	uiGradient:Clone().Parent = topBar

	local topBarMinButton = Instance.new("TextButton")
	topBarMinButton.BackgroundColor3 = Color3.fromRGB(53, 54, 67)
	topBarMinButton.BackgroundTransparency = 0
	topBarMinButton.Parent = topBar
	topBarMinButton.Position = UDim2.new(0.021, 0, 0.203, 0)
	topBarMinButton.Size = UDim2.new(0.048, 0, 0.557, 0)
	topBarMinButton.FontFace = Font.new("rbxasset://fonts/families/SourceSansPro.json")
	topBarMinButton.TextColor3 = Color3.fromRGB(255,255,255)
	topBarMinButton.TextSize = 14
	topBarMinButton.BorderSizePixel = 0
	topBarMinButton.Text = ">"
	topBarMinButton.ZIndex =  2
	uiCorner:Clone().Parent = topBarMinButton
	uiGradient:Clone().Parent = topBarMinButton

	local topBarText = Instance.new("TextLabel")
	topBarText.Parent = topBar
	topBarText.AnchorPoint = Vector2.new(0.5,0.5)
	topBarText.Position = UDim2.new(0.5,0,0.5,0)
	topBarText.Size = UDim2.new(1,0,1,0)
	topBarText.TextColor3 = Color3.fromRGB(255,255,255)
	topBarText.Text = "Dr Rosploitnik"
	topBarText.TextSize = 14
	topBarText.ZIndex =  2
	topBarText.FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold)
	topBarText.BackgroundTransparency = 1
	-- Top bar section --
	
	-- Holder section --
	local holder = Instance.new("Frame")
	holder.Parent = frame
	holder.Name = "Holder"
	holder.Position = UDim2.new(0.385, 0, 0.269, 0)
	holder.Size = UDim2.new(0.23, 0, 0.461, 0)
	holder.BackgroundColor3 = Color3.fromRGB(83, 82, 88)
	holder.BackgroundTransparency = 0
	holder.BorderSizePixel = 0
	uiCorner:Clone().Parent = holder
	uiGradient:Clone().Parent = holder
	
	local contents = Instance.new("ScrollingFrame")
	contents.Parent = holder
	contents.Name = "Contents"
	--contents
	-- Holder section --
end

UiSetup()

for i = 1, #allInitialPlayers do
	currentPlayerList[allInitialPlayers[i]] = true;
end

players.PlayerAdded:Connect(function(player)
	currentPlayerList[player] = true;
end)

players.PlayerRemoving:Connect(function(player)
	currentPlayerList[player] = nil;
end)

runService.Heartbeat:Connect(function(deltaTime)
	
end)
