local love  = _G.love
local files = {}

local function get_files(path)
	local items = love.filesystem.getDirectoryItems(path)
	for _, item in ipairs(items) do
		local name, ext = item:match("^(.+)%.(.+)$")
		local filepath  = string.format("%s/%s", path, item)
		local info      = love.filesystem.getInfo(filepath)
		ext = ext and ext:lower() or nil

		if info.type == "file" and (ext == "bmp" or ext == "tga") then
			files[#files+1] = { path=path, name=name, ext=ext, filepath=filepath }
		elseif info.type == "directory" then
			get_files(filepath)
		end
	end
end
get_files("data")

for _, file in ipairs(files) do
	local image = love.image.newImageData(file.filepath)

	-- Convert black pixels to transparent
	if file.ext == "bmp" then
		for x=0, image:getWidth()-1 do
			for y=0, image:getHeight()-1 do
				local r, g, b = image:getPixel(x, y)
				if r==0 and g==0 and b==0 then
					image:setPixel(x, y, r, g, b, 0)
				end
			end
		end
	end

	love.filesystem.createDirectory(file.path)
	image:encode("png", string.format("%s/%s.png", file.path, file.name))
end

love.event.quit()
