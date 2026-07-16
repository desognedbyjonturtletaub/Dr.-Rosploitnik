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
						for key, value in pairs(core.globalConfigs.uiListLayoutTypes[value["UiListLayout"]]) do
							uiList[key] = value
						end
					end
					if value["GradientType"] then
						local gradient = Instance.new("UIGradient")
						gradient.Rotation = 90
						gradient.Color = core.globalConfigs.uiGradientTypes[value["GradientType"]]
						gradient.Parent = obj
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
	
	function core.InternalFrameConstructor(func, boxTitles, boxPlaceholders, title, desc)
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
			BackgroundColor3 = core.globalConfigs.uiSecondaryCol,
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
			Image = core:CreateFile("GlowRound.png", core.gitBranch.. "/Images/GlowRound.png", "rbxassetid://196969716"),
			ImageColor3 = core.globalConfigs.uiSecondaryCol,
		}
		core.ui[title.. "Toggle"] = {
			Self = nil,
			Type = "TextButton",
			BackgroundColor3 = core.globalConfigs.uiSecondaryCol,
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
			TextColor3 = core.globalConfigs.uiSecondaryCol,
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
			Parent = title.. "Inner",
			Name = title.. "Inputs",
			Position = UDim2.new(0.511, 0, 0.5, 0),
			Size = UDim2.new(0.462, 0, 1, 0),
			Misc = {
				UiListLayout = 2
			}
		}

		for i = 1, #boxTitles do
			core.ui[title.. boxTitles[i]] = {
				Self = nil,
				Name = title.. boxTitles[i],
				Parent = title.. "Inputs",
				Type = "Frame",
				BackgroundTransparency = 1,
				Size = UDim2.new(0.347, 0, 1, 0),
			}
			core.ui[title.. "Glow".. boxTitles[i]] = {
				Self = nil,
				Name = title.. "Glow".. boxTitles[i],
				Parent = title.. boxTitles[i],
				Type = "ImageLabel",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundTransparency = 1,
				Position = UDim2.new(0.497, 0, 0.67, 0),
				Size = UDim2.new(1.476, 0, 0.683, 0),
				Image = core:CreateFile("GlowSquare.png", core.gitBranch.. "/Images/GlowSquare.png", "rbxassetid://242292288"),
				ImageColor3 = core.globalConfigs.uiPrimaryCol,
			}
			core.ui[title.. "InputBorder".. boxTitles[i]] = {
				Self = nil,
				Name = title.. "InputBorder".. boxTitles[i],
				Parent = title.. "Glow".. boxTitles[i],
				Type = "Frame",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = core.globalConfigs.uiPrimaryCol,
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.6, 0, 0.6, 0),
				Misc = {
					CornerRadius = UDim.new(0, 5)
				}
			}
			core.ui[title.. "Input".. boxTitles[i]] = {
				Self = nil,
				Name = title.. "Input".. boxTitles[i],
				Parent = title.. "InputBorder".. boxTitles[i],
				Type = "TextBox",
				AnchorPoint = Vector2.new(0.5, 0.5),
				BackgroundColor3 = Color3.fromRGB(50, 50, 62),
				Position = UDim2.new(0.5, 0, 0.5, 0),
				Size = UDim2.new(0.95, 0, 0.9, 0),
				FontFace = Font.new("rbxasset://fonts/families/Arimo.json"),
				PlaceholderText = boxPlaceholders[i],
				PlaceholderColor3 = Color3.fromRGB(255, 255, 255),
				TextColor3 = Color3.fromRGB(255, 255, 255),
				Text = "",
				TextScaled = true,
				TextSize = 14,
				Misc = {
					GradientType = 2,
					CornerRadius = UDim.new(0, 4)
				}
			}
		end
	end
end