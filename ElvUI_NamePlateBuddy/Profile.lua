local _, _, _, P = unpack(ElvUI)

P.npbuddy = {
	nameplates = {
		enabled = true,
		color = { r = 0, g = 0, b = 0 },
		colorByHealth = true,
		colorByPlayerClass = true,
		colors = {
			healthBreak = {
				bad = { r = 0.8, g = 0.2, b = 0.2, a = 1 },
				neutral = { r = 0.85, g = 0.85, b = 0.15, a = 1 },
				good = { r = 0.2, g = 0.8, b = 0.2, a = 1 },
				high = 0.7,
				low = 0.3,
				threshold = {
					bad = true,
					neutral = true,
					good = true
				}
			}
		}
	}
}
