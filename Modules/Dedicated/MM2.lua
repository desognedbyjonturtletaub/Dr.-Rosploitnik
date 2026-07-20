local players = game:GetService("Players")

return function(core)
	function core.mainFunctions.OnRevealNonInnocent(forceDeactivate)
		local allPlayers = players:GetChildren()
		for i = 1, #allPlayers do
			local player = allPlayers[i]
			if player.Character then
				local character = player.Character
				if character:FindFirstChild("Gun") then
					character:SetAttribute("ESPOverrideColour", Color3.fromRGB(75, 120, 255))
				elseif character:FindFirstChild("Knife") then
					character:SetAttribute("ESPOverrideColour", Color3.fromRGB(255, 0, 0))
				end
			end
		end
	end
	core.InternalFrameConstructor(core.mainFunctions.OnRevealNonInnocent, {}, {}, "revealInnocent", "Recommended use with ESP - ON.", 100)
end