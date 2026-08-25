local E = unpack(ElvUI)
local EP = LibStub('LibElvUIPlugin-1.0')
local NP = E.NamePlates
local AddOnName, Engine = ...

local NPB = E:NewModule(AddOnName, 'AceHook-3.0', 'AceEvent-3.0')
_G[AddOnName] = Engine

local GetAddOnMetadata = C_AddOns.GetAddOnMetadata

NPB.Title = GetAddOnMetadata(AddOnName, 'Title')

NPB.Configs = {}

function NPB:Print(...)
	(E.db and _G[E.db.general.messageRedirect] or _G.DEFAULT_CHAT_FRAME):AddMessage(strjoin('', E.media.hexvaluecolor or '|cff00b3ff', 'Nameplate Buddy:|r ', ...)) -- I put DEFAULT_CHAT_FRAME as a fail safe.
end

function NPB:ParseVersionString()
	local version = GetAddOnMetadata(AddOnName, 'Version')
	local prevVersion = GetAddOnMetadata(AddOnName, 'X-PreviousVersion')
	if strfind(version, 'project%-version') then
		return prevVersion, prevVersion..'-git', nil, true
	else
		local release, extra = strmatch(version, '^v?([%d.]+)(.*)')
		return tonumber(release), release..extra, extra ~= ''
	end
end

NPB.version, NPB.versionString, NPB.versionDev, NPB.versionGit = NPB:ParseVersionString()

local function GetOptions()
	for _, func in pairs(NPB.Configs) do
		func()
	end
end

function NPB:UpdateOptions()

end

function NPB:Initialize()
	EP:RegisterPlugin(AddOnName, GetOptions, nil, NPB.versionString)
	print(1)
	if not NP.Initialized then return end
	print(2)

	NPB:SetupTargetIndicatorBorder()
	NPB:SetupIsFocus()
	NPB:SetupIsImportantBorder()
	NPB:SecureHook(NP, 'StylePlate', function(_, nameplate)
		--* Target Indicator Border
		nameplate.TargetIndicatorBorder = NPB:Construct_TargetIndicatorBorder(nameplate)

		--* IsImportant CastBar Indicator Border
		NPB:Construct_IsImportantBorder(nameplate.Castbar)
	end)
	NPB:SecureHook(NP, 'UpdatePlate', function(a, nameplate, updateBase)
		local db = NP:PlateDB(nameplate)
		if updateBase and db.enable then
			NPB:Update_TargetIndicatorBorder(nameplate)

			NPB:Update_IsImportantBorderStyle(nameplate.Castbar)
		end
	end)
end
print('ElvUI_NamePlateBuddy v'..NPB.versionString..' Initialized')

E.Libs.EP:HookInitialize(NPB, NPB.Initialize)
