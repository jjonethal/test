-- findshape.lua
-- find a shape in 2d image

-- 
ffi = require"ffi"

ffi.cdef[[
	typedef struct PIXEL_RGB_888 {
		uint8_t r;
		uint8_t g;
		uint8_t b;
	} PIXEL_RGB_888_T;
]]

TYPE_RGB_888 = "RGB_888"
TYPE_BW      = "BW"

function newImageRGB_888(w,h)
	local img={w = w, h = h, t = TYPE_RGB_888}
	local data=ffi.new("PIXEL_RGB_888_T[?]",w * h)
	for i = 0, w * h - 1 do
		data[i].r = 0
		data[i].g = 0
		data[i].b = 0
	end
	img.data = data
	return img
end

function newImageBW_1(w,h)
	local numBits = w*h
	local numu32  = math.floor(w*h+32/32)
	local data    = ffi.new("uint32_t[?]", numu32)
	local img     = {w=w, h=h, data=data, t=""}
end

function image(def)
end

imageLBw = image{
	type=BW,
	{0,0,0,0,0},
	{0,1,0,0,0},
	{0,1,0,0,0},
	{0,1,0,0,0},
	{0,1,1,1,0},
	{0,0,0,0,0},
}

function calcHistogram(imgRGB)
	local r, g, b = 0, 0, 0
	local w,h = imgRGB.w, imgRGB.h
	for i = 0, w*h-1 do
			r = r + imgRGB.data[i].r
			g = g + imgRGB.data[i].g
			b = b + imgRGB.data[i].b
	end
	return r,g,b
end

function testnewImageRGB_888()
	local rnd = math.random
	local img=newImageRGB_888(200, 200)
	local w=img.w
	for y=0,img.h-1 do
		for x=0,img.w-1 do
			img.data[w*y+x].r=rnd(256)
			img.data[w*y+x].g=rnd(256)
			img.data[w*y+x].b=rnd(256)
		end
	end
	print("calculate histogram")
	print(calcHistogram(img))
end

testnewImageRGB_888()

