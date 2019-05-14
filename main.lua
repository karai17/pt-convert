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

	-- If first pixel is not black, we don't want transparency
	local r, g, b = image:getPixel(0, 0)
	if r+g+b > 0 then
		return image:encode("png", string.format("%s/%s.png", file.path, file.name))
	end

	-- Convert black pixels to transparent
	image:mapPixel(function(_, _, r, g, b, a)
		if r+g+b == 0 then
			return r, g, b, 0
		end

		return r, g, b, a
	end)
	image:encode("png", string.format("%s/%s.png", file.path, file.name))
end

-- Convert TGA to PNG
local function tga(file)
	local image = love.image.newImageData(file.filepath)
	image:encode("png", string.format("%s/%s.png", file.path, file.name))
end

-- Fix texture paths
local function ase(file)
	local model = {{}}

	local f = love.filesystem.read(file.filepath)
	for line in f:gmatch("[^\r\n]+") do
		local new_line = line

		if line:find("*BITMAP ") then
			local white, name = line:match([[(%s*)*BITMAP ".+\(.+)%.]])
			new_line = string.format('%s*BITMAP "textures/%s.png"', white, name)
		end

		-- Chunks to stop huge tables from killing GC
		if #model[#model] == 200000 then
			model[#model+1] = {}
		end

		-- Don't worry about this
		model[#model][#model[#model]+1] = new_line
	end

	-- Write to file one chunk at a time
	love.filesystem.write(file.filepath, "")
	for _, chunk in ipairs(model) do
		love.filesystem.append(file.filepath, table.concat(chunk, "\n"))
	end
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
