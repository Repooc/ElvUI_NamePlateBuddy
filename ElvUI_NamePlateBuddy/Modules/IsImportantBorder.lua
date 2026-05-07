local E = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local NPB = E:GetModule('ElvUI_NamePlateBuddy')
local LCG = E.Libs.CustomGlow
local IsSpellImportant = C_Spell and C_Spell.IsSpellImportant

local EDGE_FILE = [[Interface\BUTTONS\WHITE8X8]]

function NPB:Construct_IsImportantBorder(castbar)
	if not castbar then return end
	local border = CreateFrame('Frame', '$parentImportantIndicator', castbar, 'BackdropTemplate')
	border:SetFrameLevel(castbar:GetFrameLevel() + 5)
	border:Hide()
	castbar.IsImportantBorder = border

	return border
end

function NPB:Update_IsImportantBorderStyle(castbar)
	if not castbar or not castbar.IsImportantBorder then return end
	local db = E.db.npbuddy.castbar.isImportantBorder
	local color = db.color
	local thickness = db.thickness or 2
	local backdropInfo = { edgeFile = EDGE_FILE, edgeSize = thickness }

	local border = castbar.IsImportantBorder
	border:ClearAllPoints()
	border:SetPoint('TOPLEFT', castbar, 'TOPLEFT', -thickness, thickness)
	border:SetPoint('BOTTOMRIGHT', castbar, 'BOTTOMRIGHT', thickness, -thickness)
	border:SetBackdrop(backdropInfo)

	local r, g, b, a
	if db.colorByPlayerClass then
		local classColor = E.myClassColor
		r, g, b = classColor.r, classColor.g, classColor.b
		a = color.a
	else
		r, g, b, a = color.r, color.g, color.b, color.a
	end
	border:SetBackdropBorderColor(r, g, b, a)
end

local function SetBorderVisibility(castbar, visible)
	if not castbar or not castbar.IsImportantBorder then return end

	if visible then
		local db = E.db.npbuddy.castbar.isImportantBorder
		if db.enabled and not castbar.IsImportantBorder:IsShown() then
			castbar.IsImportantBorder:Show()
			castbar.IsImportantBorder:SetAlpha(1)
			LCG.ShowOverlayGlow(castbar.IsImportantBorder, db.customGlow)
		end
	else
		if castbar.IsImportantBorder:IsShown() then
			castbar.IsImportantBorder:Hide()
			LCG.HideOverlayGlow(castbar.IsImportantBorder)
		end
	end
end

function NPB:Castbar_PostCastStart(castbar)
	if not castbar then return end
	local db = E.db.npbuddy.castbar.isImportantBorder
	if not db.enabled then return end

	local border = castbar.IsImportantBorder or NPB:Construct_IsImportantBorder(castbar)
	if not border then return end

	local spellID = castbar.spellID
	if not spellID then return end

	local isImportant = IsSpellImportant and IsSpellImportant(spellID)
	if E:IsSecretValue(isImportant) then
		border:Show()
		border:SetAlphaFromBoolean(isImportant, 1, 0)
		LCG.ShowOverlayGlow(border, db.customGlow)
	elseif isImportant then
		SetBorderVisibility(castbar, true)
	else
		SetBorderVisibility(castbar, false)
	end
end

local function SecureHookIfNeeded(method, callback)
	if not NPB:IsHooked(NP, method) then
		NPB:SecureHook(NP, method, callback)
	end
end

local function UnhookIfNeeded(method)
	if NPB:IsHooked(NP, method) then
		NPB:Unhook(NP, method)
	end
end

function NPB:SetupIsImportantBorder()
	local methods = {
		'Castbar_PostCastStop',
		'Castbar_PostCastFail',
		'Castbar_PostCastInterrupted',
	}

	if E.db.npbuddy.castbar.isImportantBorder.enabled then
		SecureHookIfNeeded('Castbar_PostCastStart', function(castbar) NPB:Castbar_PostCastStart(castbar) end)
		for _, method in ipairs(methods) do
			SecureHookIfNeeded(method, function(castbar) SetBorderVisibility(castbar, false) end)
		end
	else
		UnhookIfNeeded('Castbar_PostCastStart')
		for _, method in ipairs(methods) do
			UnhookIfNeeded(method)
		end
	end
end
