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
		else
			button.Text = "OFF"
			button.BackgroundColor3 = core.globalConfigs.uiPrimaryCol
			button.TextColor3 = core.globalConfigs.uiBackgroundCol
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
		core.ButtonCosmetic(core.ui.antiGravityTextButton.Self, floatEnabled)
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
	return mainFunctions
end