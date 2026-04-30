local E, L, _, P = unpack(ElvUI)
local NPB = E:GetModule('ElvUI_NamePlateBuddy')
local RRP = LibStub('RepoocReforged-1.0'):LoadMainCategory()
local NP = E.NamePlates
local ACH = E.Libs.ACH

local DONATORS = {
	'None to be displayed at this time.',
}

local DEVELOPERS = {
	'|cff0070DEAzilroka|r',
	'Blazeflack',
	'|cff9482c9Darth Predator|r',
	'|cffFF3333Elv|r',
	'|cffFFC44DHydra|r',
	E:TextGradient('Simpy but my name needs to be longer.', 0.27,0.72,0.86, 0.51,0.36,0.80, 0.69,0.28,0.94, 0.94,0.28,0.63, 1.00,0.51,0.00, 0.27,0.96,0.43),
	'|cffFF8000Tukz|r',
}

local TESTERS = {
	'Trenchy',
	'|cffeb9f24Tukui Community|r',
}

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end

sort(DONATORS, SortList)
sort(DEVELOPERS, SortList)
sort(TESTERS, SortList)

local DONATOR_STRING = table.concat(DONATORS, '|n')
local DEVELOPER_STRING = table.concat(DEVELOPERS, '|n')
local TESTER_STRING = table.concat(TESTERS, '|n')

local function RefreshArrows()
	local Arrows = E.Options.args.nameplates.args.targetGroup.args.arrows

	wipe(Arrows.values)
	for key, arrow in pairs(E.Media.Arrows) do
		Arrows.values[key] = E:TextureString(arrow, ':32:32')
		if E.db.npbuddy.nameplates.enabled and (not E.Media.ArrowsBorder[key] and Arrows.values[key]) then
			Arrows.values[key] = nil
		end
	end
end

local function configTable()
    --* Repooc Reforged Plugin section
    local rrp = E.Options.args.rrp
    if not rrp then print("Error Loading Repooc Reforged Plugin Library") return end
	RefreshArrows()

	--* Plugin Section
	local NameplateBuddy = ACH:Group(gsub(NPB.Title, "^.-|r%s", ""), nil, 6, 'tab', nil, nil, function() return not NP.Initialized end)
	rrp.args.npb = NameplateBuddy
	NameplateBuddy.args.version = ACH:Header(format('|cff99ff33%s|r', NPB.versionString), 1)

	--* General Tab
	local General = ACH:Group(L["General"], nil, 1, 'tab', function(info) if info.type == 'color' then local t, d = E.db.npbuddy.nameplates[info[#info]], P.npbuddy.nameplates[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b else return E.db.npbuddy.nameplates[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local t = E.db.npbuddy.nameplates[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a or 1 else local value = ... E.db.npbuddy.nameplates[info[#info]] = value end NP:ConfigureAll() end)
	NameplateBuddy.args.general = General

	local IndicatorBorder = ACH:Group(L["Indicator Border"], nil, 1)
	General.args.indicatorBorder = IndicatorBorder
	IndicatorBorder.args.enabled = ACH:Toggle(L["Enable"], nil, 1, nil, nil, nil, nil, function(info, value) E.db.npbuddy.nameplates[info[#info]] = value NP:ConfigureAll() RefreshArrows() E.Libs.AceConfigRegistry:NotifyChange('ElvUI') end)
	IndicatorBorder.args.spacer1 = ACH:Spacer(2, 'full')
	IndicatorBorder.args.color = ACH:Color(L["Border Color"], nil, 3)
	IndicatorBorder.args.spacer2 = ACH:Spacer(4, 'full')
	IndicatorBorder.args.colorByHealth = ACH:Toggle(L["Color by Health (Gradient)"], L["Enable smooth color transitions between good, average, and bad health colors based on health percentage."], 5)
	IndicatorBorder.args.colorByPlayerClass = ACH:Toggle(L["Color by Player Class"], L["Enable to color by your current class."], 6)

	IndicatorBorder.args.spacer3 = ACH:Spacer(10, 'full')

	local HealthBreak = ACH:Group(L["Health Breakpoint"], nil, nil, nil, function(info) if info.type == 'color' then local t, d = E.db.npbuddy.nameplates.colors.healthBreak[info[#info]], P.npbuddy.nameplates.colors.healthBreak[info[#info]] return t.r, t.g, t.b, t.a, d.r, d.g, d.b else return E.db.npbuddy.nameplates.colors.healthBreak[info[#info]] end end, function(info, ...) if info.type == 'color' then local r, g, b, a = ... local t = E.db.npbuddy.nameplates.colors.healthBreak[info[#info]] t.r, t.g, t.b, t.a = r, g, b, a or 1 else local value = ... E.db.npbuddy.nameplates.colors.healthBreak[info[#info]] = value end NP:ConfigureAll() end)
	IndicatorBorder.args.healthBreak = HealthBreak
	HealthBreak.inline = true
	HealthBreak.args.spacer1 = ACH:Spacer(2, 'full')
	HealthBreak.args.bad = ACH:Color(L["Bad"], nil, 3)
	HealthBreak.args.neutral = ACH:Color(L["Neutral"], nil, 4)
	HealthBreak.args.good = ACH:Color(L["Good"], nil, 5)
	HealthBreak.args.spacer2 = ACH:Spacer(10, 'full')
	HealthBreak.args.low = ACH:Range(L["Low"], L["Bad"], 11, { min = 0, max = 0.5, step = 0.01, isPercent = true })
	HealthBreak.args.high = ACH:Range(L["High"], L["Good"], 12, { min = 0.5, max = 1, step = 0.01, isPercent = true })
	HealthBreak.args.threshold = ACH:MultiSelect(L["Threshold"], nil, 20, { bad = L["Bad"], good = L["Good"], neutral = L["Neutral"] }, nil, nil, function(_, key) return E.db.npbuddy.nameplates.colors.healthBreak.threshold[key] end, function(_, key, value) E.db.npbuddy.nameplates.colors.healthBreak.threshold[key] = value NP:ConfigureAll() end)

	--* Help Tab
	local Help = ACH:Group(L["Help"], nil, 99, nil, nil, nil, false)
	NameplateBuddy.args.help = Help

	local Support = ACH:Group(L["Support"], nil, 1)
	Help.args.support = Support
	Support.inline = true
	Support.args.wago = ACH:Execute(L["Wago Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://addons.wago.io/addons/nameplate-buddy-elvui-plugin') end, nil, nil, 140)
	Support.args.curse = ACH:Execute(L["Curseforge Page"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://www.curseforge.com/wow/addons/nameplate-buddy-elvui-plugin') end, nil, nil, 140)
	Support.args.git = ACH:Execute(L["Ticket Tracker"], nil, 2, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://github.com/Repooc/ElvUI_NamePlateBuddy/issues') end, nil, nil, 140)
	Support.args.discord = ACH:Execute(L["Discord"], nil, 3, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://repoocreforged.dev/discord') end, nil, nil, 140)

	local Credits = ACH:Group(L["Credits"], nil, 5)
	Help.args.credits = Credits
	Credits.inline = true
	Credits.args.string = ACH:Description(E:TextGradient(L["NPB_CREDITS"], 0.27,0.72,0.86, 0.51,0.36,0.80, 0.69,0.28,0.94, 0.94,0.28,0.63, 1.00,0.51,0.00, 0.27,0.96,0.43), 1, 'medium')

	local Coding = ACH:Group(L["Coding"], nil, 6)
	Help.args.coding = Coding
	Coding.inline = true
	Coding.args.string = ACH:Description(DEVELOPER_STRING, 1, 'medium')

	local Testers = ACH:Group(L["Help Testing Development Versions"], nil, 7)
	Help.args.testers = Testers
	Testers.inline = true
	Testers.args.string = ACH:Description(TESTER_STRING, 1, 'medium')

	local Donators = ACH:Group(L["Donators"], nil, 8)
	Help.args.donators = Donators
	Donators.inline = true
	Donators.args.string = ACH:Description(DONATOR_STRING, 1, 'medium')

	--* ElvUI Nameplate Modification
	local Arrows = E.Options.args.nameplates.args.targetGroup.args.arrows
	Arrows.get = function(_, key)
		local db = E.db.npbuddy.nameplates
		local elvDB = E.db.nameplates.units.TARGET
		if db.enabled then
			if E.Media.ArrowsBorder[elvDB.arrow] then
				return elvDB.arrow == key
			else
				return key == 'Arrow9'
			end
		else
			return elvDB.arrow == key
		end
	end
end

tinsert(NPB.Configs, configTable)
