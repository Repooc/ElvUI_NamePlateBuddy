local E = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local NPB = E:GetModule('ElvUI_NamePlateBuddy')
local LSM = E.Libs.LSM

function NPB:Construct_IsFocusOverlay(nameplate)
	if not nameplate then return end
	-- if nameplate.TUI_FocusOverlay then
	-- 	return nameplate.TUI_FocusOverlay, nameplate.TUI_FocusOverlayTex
	-- end

	local holder = CreateFrame('Frame', nil, nameplate.Health)
	holder:SetAllPoints(nameplate.Health)
	holder:SetFrameLevel(9)

	local overlay = holder:CreateTexture(nil, 'OVERLAY')
	overlay:SetAllPoints(holder)
	overlay:SetBlendMode('BLEND')
	holder:Hide()

	nameplate.TUI_FocusOverlay = holder
	nameplate.TUI_FocusOverlayTex = overlay
	return holder, overlay
end

function NPB:Update_IsFocus()
	local db = E.db.npbuddy.isFocus
	-- if not db.enabled then return end
	local defaultTex = LSM:Fetch('statusbar', NP.db.statusbar) or E.media.normTex
	local focusPlate = db.enabled and C_NamePlate.GetNamePlateForUnit('focus')
	local focusUF = focusPlate and focusPlate.unitFrame
	local focusTex = (focusUF and (LSM:Fetch('statusbar', db.statusbar) or defaultTex)) or defaultTex
	if focusUF then
		if focusUF.Health then
			focusUF.Health:SetStatusBarTexture(focusTex)
		end
		-- focusUF.healthbar:SetStatusBarTexture(focusTex)
		-- focusUF.castbar:SetStatusBarTexture(focusTex)
	end
end

function NPB:SetupIsFocus()
	-- NPB:SecureHook(NP, 'Update_Health', function(_, nameplate)

	-- end)
	local f = CreateFrame('Frame')
	f:RegisterEvent('PLAYER_FOCUS_CHANGED')
	f:SetScript('OnEvent', NPB.Update_IsFocus)
end
