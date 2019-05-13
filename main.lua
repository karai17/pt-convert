local love  = _G.love
local files = {}

-- Collect list of files
local function get_files(path)
	local items = love.filesystem.getDirectoryItems(path)
	for _, item in ipairs(items) do
		local name, ext = item:match("^(.+)%.(.+)$")
		local filepath  = string.format("%s/%s", path, item)
		local info      = love.filesystem.getInfo(filepath)
		ext = ext and ext:lower() or nil

		if info.type == "file" and (ext == "bmp" or ext == "tga" or ext == "ase") then
			files[#files+1] = { path=path, name=name, ext=ext, filepath=filepath }
		elseif info.type == "directory" then
			get_files(filepath)
		end
	end
end

-- Convert BMP to PNG
local function bmp(file)
	local image = love.image.newImageData(file.filepath)

	-- Convert black pixels to transparent
	for x=0, image:getWidth()-1 do
		for y=0, image:getHeight()-1 do
			local r, g, b = image:getPixel(x, y)
			if r==0 and g==0 and b==0 then
				image:setPixel(x, y, r, g, b, 0)
			end
		end
	end

	image:encode("png", string.format("%s/%s.png", file.path, file.name))
end

-- Convert TGA to PNG
local function tga(file)
	local image = love.image.newImageData(file.filepath)
	image:encode("png", string.format("%s/%s.png", file.path, file.name))
end

-- Fix texture paths
local function ase(file)
	local model = {}

	for line in love.filesystem.lines(file.filepath) do
		local new_line = line

		if line:find("*BITMAP ") then
			local white, name = line:match([[(%s*)*BITMAP ".+\(.+)%.]])
			new_line = string.format('%s*BITMAP "textures/%s.png"', white, name)
		end

		model[#model+1] = new_line
	end

	love.filesystem.write(file.filepath, table.concat(model, "\n"))
end

function love.load()
	get_files("data")

	for _, file in ipairs(files) do
		love.filesystem.createDirectory(file.path)
		if file.ext == "bmp" then bmp(file) end
		if file.ext == "tga" then tga(file) end
		if file.ext == "ase" then ase(file) end
	end

	love.event.quit()
end
