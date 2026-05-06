local E = unpack(ElvUI)
local NP = E.NamePlates
local NPB = E:GetModule('ElvUI_NamePlateBuddy')

local targetIndicatorsBorder = {'TopIndicatorBorder', 'LeftIndicatorBorder', 'RightIndicatorBorder'}
function NPB:Construct_TargetIndicatorBorder(nameplate)
	if not nameplate then return end

	local TargetIndicatorBorder = CreateFrame('Frame', '$parentTargetIndicatorBorder', nameplate)

	for _, object in ipairs(targetIndicatorsBorder) do
		local indicator = TargetIndicatorBorder:CreateTexture(nil, 'BACKGROUND', nil, 1)
		indicator:Hide()

		TargetIndicatorBorder[object] = indicator
	end

	return TargetIndicatorBorder
end

function NPB:Update_TargetIndicatorBorder(nameplate)
	if not nameplate then return end

    local enabled = nameplate:IsElementEnabled('TargetIndicatorBorder')
	if nameplate.frameType == 'PLAYER' then
		if enabled then
			nameplate:DisableElement('TargetIndicatorBorder')
		end

		return
	elseif not enabled then
		nameplate:EnableElement('TargetIndicatorBorder')
	end

	local tdb = NP.db.units.TARGET
	local npbDB = E.db.npbuddy.nameplates
	local indicator = nameplate.TargetIndicatorBorder
	indicator:SetFrameLevel(0)

	indicator.arrow = E.Media.ArrowsBorder[NP.db.units.TARGET.arrow] or E.Media.ArrowsBorder[E.Media.Arrows.Arrow9] or nil
	indicator.style = tdb.glowStyle
	indicator.border = npbDB.enabled
	indicator.borderColor = npbDB.color
	indicator.colorByHealth = npbDB.colorByHealth
	indicator.colorByPlayerClass = npbDB.colorByPlayerClass
	indicator.badThreshold = npbDB.colors.healthBreak.threshold.bad
	indicator.neutralThreshold = npbDB.colors.healthBreak.threshold.neutral
	indicator.goodThreshold = npbDB.colors.healthBreak.threshold.good
	indicator.high = npbDB.colors.healthBreak.high
	indicator.low = npbDB.colors.healthBreak.low
	indicator.bad = indicator.badThreshold and npbDB.colors.healthBreak.bad or indicator.colorByPlayerClass and E.myClassColor or indicator.borderColor
	indicator.neutral = indicator.neutralThreshold and npbDB.colors.healthBreak.neutral or indicator.colorByPlayerClass and E.myClassColor or indicator.borderColor
	indicator.good = indicator.goodThreshold and npbDB.colors.healthBreak.good or indicator.colorByPlayerClass and E.myClassColor or indicator.borderColor

	if indicator.healthCurve then
		indicator.healthCurve:ClearPoints()
		indicator.healthCurve:AddPoint(0, {r = indicator.bad.r, g = indicator.bad.g, b = indicator.bad.b, a = 1})
		indicator.healthCurve:AddPoint(indicator.low, {r = indicator.neutral.r, g = indicator.neutral.g, b = indicator.neutral.b, a = 1})
		indicator.healthCurve:AddPoint(indicator.high, {r = indicator.neutral.r, g = indicator.neutral.g, b = indicator.neutral.b, a= 1})
		indicator.healthCurve:AddPoint(1, {r = indicator.good.r, g = indicator.good.g, b = indicator.good.b, a = 1})
	end

	if indicator.style ~= 'none' and indicator.border then
		local style, scale, spacing = tdb.glowStyle, tdb.arrowScale, tdb.arrowSpacing
		local bcolor = E.db.npbuddy.nameplates.color
		local r, g, b = bcolor.r, bcolor.g, bcolor.b
		local db = NP:PlateDB(nameplate)

		-- background glow is 2, 6, and 8; 2 is background glow only
		if not db.health.enable and (style ~= 'style2' and style ~= 'style6' and style ~= 'style8') then
			style = 'style2'
			indicator.style = style
		end

		-- top arrow is 3, 5, 6
		if indicator.TopIndicatorBorder and (style == 'style3' or style == 'style5' or style == 'style6') then
			indicator.TopIndicatorBorder:Point('BOTTOM', nameplate.Health, 'TOP', 0, spacing)
			indicator.TopIndicatorBorder:SetVertexColor(r, g, b, 1)
			indicator.TopIndicatorBorder:SetScale(scale)
		end

		-- side arrows are 4, 7, 8
		if indicator.LeftIndicatorBorder and indicator.RightIndicatorBorder and (style == 'style4' or style == 'style7' or style == 'style8') then
			indicator.LeftIndicatorBorder:Point('LEFT', nameplate.Health, 'RIGHT', spacing, 0)
			indicator.RightIndicatorBorder:Point('RIGHT', nameplate.Health, 'LEFT', -spacing, 0)
			indicator.LeftIndicatorBorder:SetVertexColor(r, g, b, 1)
			indicator.RightIndicatorBorder:SetVertexColor(r, g, b, 1)
			indicator.LeftIndicatorBorder:SetScale(scale)
			indicator.RightIndicatorBorder:SetScale(scale)
		end
	end
end
