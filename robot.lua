-- robot.lua

actors = {
	motorLeft,
	motorRight,
	HeadStepper,
}

sensors = {
	ultrasonicSensor,
	camera,
	batteryVoltage,
	batteryCurrent,
	batteryCharge,
	motorPositionLeft,
	motorPositionRight,
	motorCurrentLeft,
	motorCurrentRight,
}

function vision()
	local img = camera.image()
	objectDetector(img)
	motionDetector(img)
end

function onEvent_BatteryVoltageLow()
end

function onEvent_BatteryVoltageHigh()
end

function onEvent_BatteryChargeLow()
end

function monitor_BatteryCharge()
	if requiredChargeForMoveToCharger > batteryCharge then
		fireEvent(chargeRangeExeeded)
	end
end

function monitor_DistanceToCharger()
	requiredChargeForMoveToCharger = distanceToCharger * maximumChargePerMeter * CHARGE_MOVEMENT_UNCERTAINITY
end

function objectDetector(image)
	
end


function compareImages(img1, img2)
	local i1,i2=sameSize(img1, img2)
	
end

--- get a prixel from image wrapping around

function getPrixelWrap(img,x,y)
	while x > img.w do x = x - img.w end      -- wrap x from right to left
	while x < 0     do x = x + img.w end      -- wrap x from left to right
	while y > img.h do y = y - img.h end      -- wrap y from high to low
	while y < 0     do y = y + img.h end      -- wrap y from low to high
	return img[y][x]
end

--- get a prixel from image wrapping around

function getPrixelClip(img,x,y)
	while x > img.w do x = img.w end      -- wrap x from right to left
	while x < 0     do x = 0     end      -- wrap x from left to right
	while y > img.h do y = img.h end      -- wrap y from high to low
	while y < 0     do y = 0     end      -- wrap y from low to high
	return img[y][x]
end


function diffImage(img1, img2)
	local img3={w=img1.w,h=img1.h,}
	for y=1,img1.h do
		for x=1,img.w do
			img3[y]=img3[y] or {}
			img3[y][x]=img1[y][x]-img2[y][x]
		end
	end
	return img3
end


--[[
objectives 
onLowBattery:
	destination = nextCharger
	motionMode  = mostEfficientMotion
	travelToDestination
onBatteryFull:
	- stopCharging
	- exploreEnvironment
exploreEnvironment
	explore moving objects

Actor.set(value)
Actor.inputType(boolean, integer(a..b), float(a..b), double(a..b))
Actor.range.min	
Actor.range.max
Actor.unit
Actor.off

selfCalibration
	turnOffActors()
]]