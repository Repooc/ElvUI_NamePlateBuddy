local E = unpack(ElvUI)

E.Media.ArrowsBorder = {}
local MediaKey = {
	arrowborder	= 'ArrowsBorder',
}
local MediaPath = {
	arrowborder	= [[Interface\AddOns\ElvUI_NamePlateBuddy\Media\Borders\]],
}

local function AddMedia(Type, File)
	local path = MediaPath[Type]
	if path then
		local key = File:gsub('%.%w-$','')
		local file = path .. File

		local pathKey = MediaKey[Type]
		if pathKey then E.Media[pathKey][key] = file end
	end
end

for i = 0, 18, 1 do
	AddMedia('arrowborder', 'Arrow'..i)
end
AddMedia('arrowborder', 'Arrow27')
