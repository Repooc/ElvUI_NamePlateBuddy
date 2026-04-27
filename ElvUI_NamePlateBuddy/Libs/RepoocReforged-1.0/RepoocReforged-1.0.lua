local MAJOR, MINOR = 'RepoocReforged-1.0', 4
local lib, oldminor = LibStub:NewLibrary(MAJOR, MINOR)
assert(LibStub, MAJOR.." requires LibStub")

if not lib then return end
if not ElvUI then return end

local E, L, _, P, _ = unpack(ElvUI)
local ACH = E.Libs.ACH

local SUPPORTERS = {
	'|cFF08E8DEBotanica|r',
	E:TextGradient('Eltreum', 0.50, 0.70, 1, 0.67, 0.95, 1),
	'Jiberish',
	E:TextGradient('Simpy but my name needs to be longer.', 0.18,1.00,0.49, 0.32,0.85,1.00, 0.55,0.38,0.85, 1.00,0.55,0.71, 1.00,0.68,0.32),
	'|cFFb8bb26Thurin|r',
	'Tsxy',
}

local function SortList(a, b)
	return E:StripString(a) < E:StripString(b)
end
sort(SUPPORTERS, SortList)

local SUPPORTER_STRING = table.concat(SUPPORTERS, '|n')
SUPPORTER_STRING = '|cff00FF98Repooc Reforged|r |cffA330C9Community|r|n'..SUPPORTER_STRING

function lib:LoadMainCategory()
	--* Repooc Reforged Plugin section
	local rrp = E.Options.args.rrp
	if not rrp then
		rrp = ACH:Group('|cff00FF98Repooc Reforged|r |cffA330C9Plugins|r', nil, 6)
		E.Options.args.rrp = rrp

		--* Healer Only Power Section
		local RRPHelp = ACH:Group(L["Help"], nil, 99)
		rrp.args.help = RRPHelp

		local Support = ACH:Group(L["Support"], nil, 1)
		RRPHelp.args.support = Support
		Support.inline = true
		Support.args.wago = ACH:Execute(L["AddOns on Wago"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://addons.wago.io/user/Repooc') end, nil, nil, 140)
		Support.args.curse = ACH:Execute(L["AddOns on Curseforge"], nil, 1, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://legacy.curseforge.com/members/repooc/projects') end, nil, nil, 140)
		Support.args.discord = ACH:Execute(L["Discord"], nil, 3, function() E:StaticPopup_Show('ELVUI_EDITBOX', nil, nil, 'https://repoocreforged.dev/discord') end, nil, nil, 140)

		local Supporters = ACH:Group(L["Supporters"], nil, 8)
		RRPHelp.args.supporters = Supporters
		Supporters.inline = true
		Supporters.args.string = ACH:Description(SUPPORTER_STRING, 1, 'medium')
	end
end
