local tweenService = game:GetService("TweenService")

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
			button.BackgroundColor3 = core.globalConfigs.uiSecondaryCol
			button.TextColor3 = core.globalConfigs.uiBackgroundCol
			button.Parent.ImageColor3 = core.globalConfigs.uiSecondaryCol
		else
			button.Text = "OFF"
			button.BackgroundColor3 = core.globalConfigs.uiPrimaryCol
			button.TextColor3 = core.globalConfigs.uiBackgroundCol
			button.Parent.ImageColor3 = core.globalConfigs.uiPrimaryCol
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
	
	function core.InternalFrames()
		core.BuildFunctionFrames(mainFunctions.OnFloat, {}, {}, "float", "Float around in zero gravity.")
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
	
	function core.BuildFunctionFrames(func, boxTitles, boxPlaceholders, title, desc)
		core.ui[title] = {
			Self = nil,
			Type = "Frame",
			Parent = "scroll",
			Name = title,
			BackgroundTransparency = 1,
			BorderColor3 = Color3.fromRGB(255, 255, 255),
			BorderSizePixel = 0,
			Size = UDim2.new(1, 0, 0.06, 0),
			ZIndex = 1,
			LayoutOrder = 0,
			ClipsDescendants = false,
		}
		core.ui[title.. "Border"] = {
			Self = nil,
			Type = "Frame",
			Parent = title,
			Name = title.. "Border",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = core.globalConfigs.uiPrimaryCol,
			BackgroundTransparency = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(1, 0, 1, 0),
			Misc = {
				CornerRadius = UDim.new(0, 4),
			}
		}
		core.ui[title.. "Inner"] = {
			Self = nil,
			Type = "Frame",
			Parent = title.. "Border",
			Name = title.. "Inner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundColor3 = core.globalConfigs.uiBackgroundCol,
			BackgroundTransparency = 0,
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.987, 0, 0.94, 0),
			Misc = {
				CornerRadius = UDim.new(0, 4),
				GradientType = 1,
			}
		}
		core.ui[title.. "ToggleGlow"] = {
			Self = nil,
			Type = "ImageLabel",
			Parent = title.. "Inner",
			Name = title.. "ToggleGlow",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			Position = UDim2.new(0.876, 0, 0.491, 0),
			Size = UDim2.new(0.273, 0, 0.585, 0),
			Image = core:CreateFile("Glow.png", core.gitBranch.. "/Images/GlowRound.png", "rbxassetid://196969716"),
			ImageColor3 = core.globalConfigs.uiPrimaryCol,
		}
		core.ui[title.. "Toggle"] = {
			Self = nil,
			Type = "TextButton",
			BackgroundColor3 = core.globalConfigs.uiPrimaryCol,
			BackgroundTransparency = 0,
			Parent = title.. "ToggleGlow",
			Name = title.. "Toggle",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.5, 0, 0.5, 0),
			Size = UDim2.new(0.7, 0, 0.6, 0),
			ZIndex = 1,
			FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold),
			Text = "OFF",
			TextColor3 = core.globalConfigs.uiBackgroundCol,
			TextSize = 14,
			TextScaled = false,
			Misc = {
				CornerRadius = UDim.new(0, 20),
				Func = func
			}
		}
		core.ui[title.. "Desc"] = {
			Self = nil,
			Type = "TextLabel",
			BackgroundTransparency = 1,
			Name = title.. "Desc",
			Parent = title.. "Inner",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Position = UDim2.new(0.163, 0, 0.693, 0),
			Size = UDim2.new(0.234, 0, 0.409, 0),
			FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold, Enum.FontStyle.Italic),
			Text = desc,
			TextColor3 = Color3.fromRGB(255, 255, 255),
			TextScaled = true,
			TextSize = 7,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
		core.ui[title.. "Title"] = {
			Self = nil,
			Type = "TextLabel",
			BackgroundTransparency = 1,
			Name = title.. "Title",
			AnchorPoint = Vector2.new(0.5, 0.5),
			Parent = title.. "Inner",
			Position = UDim2.new(0.176, 0, 0.17, 0),
			Size = UDim2.new(0.277, 0, 0.277, 0),
			FontFace = Font.new("rbxasset://fonts/families/Inconsolata.json", Enum.FontWeight.Bold),
			Text = title:gsub("^%l", string.upper),
			TextColor3 = core.globalConfigs.uiPrimaryCol,
			TextSize = 22,
			TextScaled = true,
			TextWrapped = true,
			TextXAlignment = Enum.TextXAlignment.Left,
		}
		core.ui[title.. "Inputs"] = {
			Self = nil,
			Type = "Frame",
			AnchorPoint = Vector2.new(0.5, 0.5),
			BackgroundTransparency = 1,
			
			Misc = {
				UiListLayout = true,
			}
		}
	end
	return mainFunctions
end