local replicatedStorage = game:GetService("ReplicatedStorage")
local userInputService = game:GetService("UserInputService")

return function(core)
	function core.AnimationConstructor(animTable)
		for i, v in pairs(animTable) do
			local animation = Instance.new("Animation")
			animation.AnimationId = v["Id"]
			v["Self"] = core.humanoid:LoadAnimation(animation)
		end
	end

	function core.ParticleConstructor()
		local folder = Instance.new("Folder")
		folder.Parent = replicatedStorage
		folder.Name = "RosploitnikParticles"
		for i, v in pairs(core.particles) do
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

	function core.SoundConstructor()
		local folder = Instance.new("Folder")
		folder.Parent = replicatedStorage
		folder.Name = "RosploitnikSound"
		for i, v in pairs(core.sounds) do
			local sound = Instance.new("Sound")
			for key, value in pairs(v) do
				sound[key] = value
			end
			sound.Parent = folder
		end
		return folder
	end

	function core.TopBarConstructor(key, bar)
		core.mouse.Move:Connect(function()
			if key["Misc"].held == true then
				local mousePos = userInputService:GetMouseLocation()
				bar.Parent.Position = UDim2.new(0, mousePos.X, 0.24, mousePos.Y)
			end
		end)
		bar.MouseButton1Down:Connect(function()
			key["Misc"].held = true
		end)
		core.mouse.Button1Up:Connect(function()
			key["Misc"].held = false
		end)
		bar.MouseButton1Up:Connect(function()
			key["Misc"].held = false
		end)
	end

	function core.UiConstructor()
		for i, v in pairs(core.ui) do
			local obj = Instance.new(v["Type"])
			v["Self"] = obj
			for key, value in pairs(v) do
				if key ~= "Type" and key ~= "Misc" and key ~= "Parent" and key ~= "Self" then
					obj[key] = value 
					if typeof(value) == "Color3" then
						if value == core.globalConfigs.uiPrimaryCol then
							core.uiAssignedPrimary[key] = value
						elseif value == core.globalConfigs.uiSecondaryCol then
							core.uiAssignedSecondary[key] = value
						elseif value == core.globalConfigs.uiBackgroundCol then
							core.uiAssignedBackground[key] = value
						end
					end
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
						gradient.Color = core.globalConfigs.uiGradientTypes[value["GradientType"] - 1]
					end
					if value["CornerRadius"] then
						local corner = Instance.new("UICorner")
						corner.CornerRadius = value["CornerRadius"]
						corner.Parent = obj
					end
					if value["Grabbable"] then
						core.TopBarConstructor(v, obj)
					end
				end
			end
		end
		core.UiParent()
	end

	function core.UiParent()
		for i, v in pairs(core.ui) do
			if v["Parent"] == "PlayerGui" then
				v["Self"].Parent = core.playerGui
			else
				v["Self"].Parent = core.ui[v["Parent"]]["Self"]
			end
		end
	end
end