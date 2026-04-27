local E = unpack(ElvUI)
local NP = E:GetModule('NamePlates')
local ElvUF = E.oUF

local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax

--[[ Target Glow Style Option Variables
	style1:'Border',
	style2:'Background',
	style3:'Top Arrow Only',
	style4:'Side Arrows Only',
	style5:'Border + Top Arrow',
	style6:'Background + Top Arrow',
	style7:'Border + Side Arrows',
	style8:'Background + Side Arrows'
]]

local function HideIndicators(element)
	if element.TopIndicatorBorder then element.TopIndicatorBorder:Hide() end
	if element.LeftIndicatorBorder then element.LeftIndicatorBorder:Hide() end
	if element.RightIndicatorBorder then element.RightIndicatorBorder:Hide() end
end

local function ShowIndicators(element, isTarget, color)
	if isTarget then
		if element.TopIndicatorBorder and (element.style == 'style3' or element.style == 'style5' or element.style == 'style6') then
			element.TopIndicatorBorder:SetVertexColor(color.r, color.g, color.b)
			element.TopIndicatorBorder:SetTexture(element.arrow)
			element.TopIndicatorBorder:Show()
		end

		if element.LeftIndicatorBorder and element.RightIndicatorBorder and (element.style == 'style4' or element.style == 'style7' or element.style == 'style8') then
			element.LeftIndicatorBorder:SetVertexColor(color.r, color.g, color.b)
			element.RightIndicatorBorder:SetVertexColor(color.r, color.g, color.b)
			element.LeftIndicatorBorder:SetTexture(element.arrow)
			element.RightIndicatorBorder:SetTexture(element.arrow)
			element.RightIndicatorBorder:Show()
			element.LeftIndicatorBorder:Show()
		end
	end
end

local function LerpColor(a, b, t)
	return {
		r = a.r + (b.r - a.r) * t,
		g = a.g + (b.g - a.g) * t,
		b = a.b + (b.b - a.b) * t
	}
end

local function GetBorderColor(element, unit)
	if element.colorByHealth then
		if element.healthCurve then
			local ok, colorObj = pcall(UnitHealthPercent, unit, true, element.healthCurve)
			if ok and colorObj then
				local r, g, b = colorObj:GetRGB()
				return { r = r, g = g, b = b }
			end
		end

		-- fallback to manual calculation
		local health, maxHealth = UnitHealth(unit), UnitHealthMax(unit)
		local perc = (maxHealth > 0 and health/maxHealth) or 0
		if perc >= element.high then
			return element.good
		elseif perc >= element.low then
			local t = (perc - element.low) / (element.high - element.low)
			return LerpColor(element.neutral, element.good, t)
		else
			local t = perc / element.low
			return LerpColor(element.bad, element.neutral, t)
		end
	elseif element.colorByPlayerClass and E.myclass and E.myClassColor then
		local classColor = E.myClassColor
		return { r = classColor.r, g = classColor.g, b = classColor.b }
	else
		return element.borderColor
	end
end

local function Update(self)
	local element = self.TargetIndicatorBorder
	if element.PreUpdate then
		element:PreUpdate()
	end

	HideIndicators(element)

	if element.style ~= 'none' and element.border then
		local isTarget = E:UnitIsUnit(self.unit, 'target')

		if isTarget then
			if element.colorByHealth or element.colorByPlayerClass then
				local color = GetBorderColor(element, self.unit)
				ShowIndicators(element, isTarget, color)
			else
				ShowIndicators(element, isTarget, element.borderColor)
			end
		else
			ShowIndicators(element, isTarget, element.borderColor)
		end
	end

	if element.PostUpdate then
		return element:PostUpdate(self.unit)
	end
end

local function Path(self, ...)
	return (self.TargetIndicatorBorder.Override or Update) (self, ...)
end

local function ForceUpdate(element)
	return Path(element.__owner, 'ForceUpdate', element.__owner.unit)
end

local function Enable(self)
	local element = self.TargetIndicatorBorder
	if element then
		element.__owner = self
		element.ForceUpdate = ForceUpdate

		if not element.border then element.border = true end
		if not element.style then element.style = 'style1' end
		if not element.colorByHealth then element.colorByHealth = false end
		if not element.healthColors then element.healthColors = { good = {r = 0.2, g = 0.8, b = 0.2, a = 1}, neutral = {r = 0.85, g = 0.85, b = 0.15, a = 1}, bad = {r = 0.8, g = 0.2, b = 0.2, a = 1} } end
		if not element.high then element.high = 0.6 end
		if not element.low then element.low = 0.3 end
		if not element.healthCurve then element.healthCurve = E:CreateColorCurve(Enum.LuaCurveType.Linear or 0) end

		if element.TopIndicatorBorder and element.TopIndicatorBorder:IsObjectType('Texture') and not element.TopIndicatorBorder:GetTexture() then
			element.TopIndicatorBorder:SetTexture(E.Media.Textures.ArrowUp)
			element.TopIndicatorBorder:SetTexCoord(1, 1, 1, 0, 0, 1, 0, 0) --Rotates texture 180 degress (Up arrow to face down)
		end

		if element.LeftIndicatorBorder and element.LeftIndicatorBorder:IsObjectType('Texture') and not element.LeftIndicatorBorder:GetTexture() then
			element.LeftIndicatorBorder:SetTexture(E.Media.Textures.ArrowUp)
			element.LeftIndicatorBorder:SetTexCoord(1, 0, 0, 0, 1, 1, 0, 1) --Rotates texture 90 degrees clockwise (Up arrow to face right)
		end

		if element.RightIndicatorBorder and element.RightIndicatorBorder:IsObjectType('Texture') and not element.RightIndicatorBorder:GetTexture() then
			element.RightIndicatorBorder:SetTexture(E.Media.Textures.ArrowUp)
			element.RightIndicatorBorder:SetTexCoord(1, 1, 0, 1, 1, 0, 0, 0) --Flips texture horizontally (Right facing arrow to face left)
		end

		if E.Classic then
			self:RegisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		self:RegisterEvent('UNIT_HEALTH', Path)
		self:RegisterEvent('UNIT_MAXHEALTH', Path)
		self:RegisterEvent('PLAYER_TARGET_CHANGED', Path, true)

		return true
	end
end

local function Disable(self)
	local element = self.TargetIndicatorBorder
	if element then
		HideIndicators(element)

		if E.Classic then
			self:UnregisterEvent('UNIT_HEALTH_FREQUENT', Path)
		end

		self:UnregisterEvent('UNIT_HEALTH', Path)
		self:UnregisterEvent('UNIT_MAXHEALTH', Path)
		self:UnregisterEvent('PLAYER_TARGET_CHANGED', Path)
	end
end

ElvUF:AddElement('TargetIndicatorBorder', Path, Enable, Disable)
