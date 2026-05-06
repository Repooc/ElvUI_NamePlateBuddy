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

local function HideBorder(castbar)
	if not castbar or castbar and not castbar.IsImportantBorder then return end
	if castbar.IsImportantBorder:IsShown() then
		castbar.IsImportantBorder:Hide()
		LCG.HideOverlayGlow(castbar.IsImportantBorder)
	end
end

local function ShowBorder(castbar)
	if not castbar or castbar and not castbar.IsImportantBorder then return end
	local db = E.db.npbuddy.castbar.isImportantBorder
	if db.enabled and not castbar.IsImportantBorder:IsShown() then
		castbar.IsImportantBorder:Show()
		castbar.IsImportantBorder:SetAlpha(1)
	else
		HideBorder(castbar)
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
	elseif isImportant then
		ShowBorder(castbar)
	else
		HideBorder(castbar)
	end
end

function NPB:SetupIsImportantBorder()
	if E.db.npbuddy.castbar.isImportantBorder.enabled then
		if not NPB:IsHooked(NP, 'Castbar_PostCastStart') then
			NPB:SecureHook(NP, 'Castbar_PostCastStart', function(castbar) NPB:Castbar_PostCastStart(castbar) end)
		end
		if not NPB:IsHooked(NP, 'Castbar_PostCastStop') then
			NPB:SecureHook(NP, 'Castbar_PostCastStop', function(castbar) HideBorder(castbar) end)
		end
		if not NPB:IsHooked(NP, 'Castbar_PostCastFail') then
			NPB:SecureHook(NP, 'Castbar_PostCastFail', function(castbar) HideBorder(castbar) end)
		end
		if not NPB:IsHooked(NP, 'Castbar_PostCastInterrupted') then
			NPB:SecureHook(NP, 'Castbar_PostCastInterrupted', function(castbar) HideBorder(castbar) end)
		end
	else
		if NPB:IsHooked(NP, 'Castbar_PostCastStart') then NPB:Unhook(NP, 'Castbar_PostCastStart') end
		if NPB:IsHooked(NP, 'Castbar_PostCastStop') then NPB:Unhook(NP, 'Castbar_PostCastStop') end
		if NPB:IsHooked(NP, 'Castbar_PostCastFail') then NPB:Unhook(NP, 'Castbar_PostCastFail') end
		if NPB:IsHooked(NP, 'Castbar_PostCastInterrupted') then NPB:Unhook(NP, 'Castbar_PostCastInterrupted') end
	end
end
