local E = unpack(ElvUI)
local LSM = E.Libs.LSM

E.Media.ArrowsBorder = {}
local MediaKey = {
	arrowborder	= 'ArrowsBorder',
	texture = 'Textures',
}
local MediaPath = {
	arrowborder	= [[Interface\AddOns\ElvUI_NamePlateBuddy\Media\Borders\]],
	texture =  [[Interface\AddOns\ElvUI_NamePlateBuddy\Media\Textures\]],
}

local function AddMedia(Type, File, Name, CustomType, Mask)
	local path = MediaPath[Type]
	if path then
		local key = File:gsub('%.%w-$','')
		local file = path .. File

		local pathKey = MediaKey[Type]
		if pathKey then E.Media[pathKey][key] = file end

		if Name then -- Register to LSM
			local nameKey = (Name == true and key) or Name
			if type(CustomType) == 'table' then
				for _, name in ipairs(CustomType) do
					LSM:Register(name, nameKey, file, Mask)
				end
			else
				LSM:Register(CustomType or Type, nameKey, file, Mask)
			end
		end
	end
end

for i = 0, 19, 1 do
	AddMedia('arrowborder', 'Arrow'..i)
end
for i = 21, 22, 1 do
	AddMedia('arrowborder', 'Arrow'..i)
end
AddMedia('arrowborder', 'Arrow27')
AddMedia('texture', 'TrenchyFocus', 'Trenchy Focus', 'statusbar')
