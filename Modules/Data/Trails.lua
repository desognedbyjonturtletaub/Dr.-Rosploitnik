return function(core)
	return {
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
end