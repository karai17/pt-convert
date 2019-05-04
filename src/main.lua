package.path  = "/root/.luarocks/share/lua/5.1/?.lua;/root/.luarocks/share/lua/5.1/?/init.lua;/usr/share/lua/5.1/?.lua;/usr/share/lua/5.1/?/init.lua;./?.lua;/usr/share/luajit-2.0.4/?.lua;/usr/local/share/lua/5.1/?.lua;/usr/local/share/lua/5.1/?/init.lua"
package.cpath = "/root/.luarocks/lib/lua/5.1/?.so;/usr/lib/lua/5.1/?.so;./?.so;/usr/local/lib/lua/5.1/?.so;/usr/lib64/lua/5.1/?.so;/usr/local/lib/lua/5.1/loadall.so"
local lfs     = require "lfs"
local magick  = require "magick"
local files   = {}

local function get_files(path)
	for file in lfs.dir(path) do
		if file ~= "." and file ~= ".." then
			local name, ext = file:match("^(.+)%.(.+)$")
			local filepath  = string.format("%s/%s", path, file)
			local attr      = lfs.attributes(filepath)

			if attr.mode == "file" and (ext:lower() == "bmp" or ext:lower() == "tga") then
				files[#files+1] = { path=path, name=name, fpath=filepath }
			elseif attr.mode == "directory" then
				get_files(filepath)
			end
		end
	end
end
get_files("/var/data")

for _, file in ipairs(files) do
	local image = magick.load_image(file.fpath)

	-- Convert black pixels to transparent
	if image:get_format() == "bmp" then
		for x=1, image:get_width() do
			for y=1, image:get_height() do
				local r, g, b = image:get_pixel(x, y)
				if r==0 and g==0 and b==0 then
					image:set_pixel(x, y, r, g, b, 0)
				end
			end
		end
	end

	image:set_format("png")
	image:write(string.format("%s/%s.png", file.path, file.name))
end
