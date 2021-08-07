--[[
    @Code author: satan_
    @Created for gtao.pl
    @Licensed by MIT
    @Contact on kontaktthinks@gmail.com/satan_#4535
]]

local speedometer = {data={}}
local sx, sy = guiGetScreenSize()
local zoom = 1

if (sx < 1920) then
    if sx < 1600 and sy < 900 then
        zoom = math.min(1.2, 1920 / sx);
    end
end  

function scale_x(value)
    return value/zoom
end

function scale_y(value)
    return value/zoom
end

clientRender = {
    textures  = {
        background = dxCreateTexture('textures/background.png', 'dxt5', false, 'clamp');
        arrow      = dxCreateTexture('textures/arrow.png', 'dxt5', false, 'clamp');
    };
    fonts     = {
        italic     = dxCreateFont('fonts/italic.ttf', scale_x(70));
        gear       = dxCreateFont('fonts/italic.ttf', scale_x(38));
        mph       = dxCreateFont('fonts/italic.ttf', scale_x(19));
    };
    scale = {
        background = {scale_x(1579), scale_y(795), scale_x(300), scale_y(300)};
        arrow      = {scale_x(1579), scale_y(795), scale_x(300), scale_y(300)};
        gear       = {scale_x(1957), scale_y(890), scale_x(1500), scale_y(990)};
        velocity   = {scale_x(1957), scale_y(995), scale_x(1500), scale_y(1060)};
        mph       = {scale_x(1989), scale_y(890), scale_x(1600), scale_y(990)};
    };
}


function speedometer.getElementSpeed(theElement, unit)
    assert(isElement(theElement), "Bad argument 1 @ getElementSpeed (element expected, got " .. type(theElement) .. ")")
    local elementType = getElementType(theElement)
    assert(elementType == "player" or elementType == "ped" or elementType == "object" or elementType == "vehicle" or elementType == "projectile", "Invalid element type @ getElementSpeed (player/ped/object/vehicle/projectile expected, got " .. elementType .. ")")
    assert((unit == nil or type(unit) == "string" or type(unit) == "number") and (unit == nil or (tonumber(unit) and (tonumber(unit) == 0 or tonumber(unit) == 1 or tonumber(unit) == 2)) or unit == "m/s" or unit == "km/h" or unit == "mph"), "Bad argument 2 @ getElementSpeed (invalid speed unit)")
    unit = unit == nil and 0 or ((not tonumber(unit)) and unit or tonumber(unit))
    local mult = (unit == 0 or unit == "m/s") and 10 or ((unit == 1 or unit == "km/h") and 144 or 111.84681456)
    return (Vector3(getElementVelocity(theElement)) * mult).length
end

function speedometer.getVehicleRPM(vehicle)
    local vehicleRPM = 0
    if (vehicle) then
        if (getVehicleEngineState(vehicle) == true) then
            if getVehicleCurrentGear(vehicle) > 0 then
                vehicleRPM = math.floor(((speedometer.getElementSpeed(vehicle, "km/h") / getVehicleCurrentGear(vehicle)) * 160) + 0.5)
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9000) then
                    vehicleRPM = math.random(9000, 9900)
                end
            else
                vehicleRPM = math.floor((speedometer.getElementSpeed(vehicle, "km/h") * 160) + 0.5)
                if (vehicleRPM < 650) then
                    vehicleRPM = math.random(650, 750)
                elseif (vehicleRPM >= 9000) then
                    vehicleRPM = math.random(9000, 9900)
                end
            end
        else
            vehicleRPM = 0
        end

        return tonumber(vehicleRPM)
    else
        return 0
    end
end

function speedometer.draw()
    speedometer.data.vehicle = getPedOccupiedVehicle(localPlayer)
    if speedometer.data.vehicle then
        speedometer.data.velocity = speedometer.getElementSpeed(speedometer.data.vehicle, "km/h")
        speedometer.data.rpm = speedometer.getVehicleRPM(speedometer.data.vehicle)/12000 * 257
        dxDrawImage(clientRender.scale.arrow[1], clientRender.scale.arrow[2], clientRender.scale.arrow[3], clientRender.scale.arrow[4], clientRender.textures.arrow, speedometer.data.rpm, 0, 0)
        dxDrawImage(clientRender.scale.background[1], clientRender.scale.background[2], clientRender.scale.background[3], clientRender.scale.background[4], clientRender.textures.background)
        dxDrawText('MPH', clientRender.scale.mph[1], clientRender.scale.mph[2], clientRender.scale.mph[3], clientRender.scale.mph[4], tocolor(255, 255, 255, 140), 1.00, clientRender.fonts.mph, "center", "center")
        dxDrawText(getVehicleCurrentGear(speedometer.data.vehicle), clientRender.scale.gear[1], clientRender.scale.gear[2], clientRender.scale.gear[3], clientRender.scale.gear[4], tocolor(255, 255, 255, 140), 1.00, clientRender.fonts.gear, "center", "center")
    
        dxDrawText(string.format('%03d', speedometer.data.velocity), clientRender.scale.velocity[1], clientRender.scale.velocity[2], clientRender.scale.velocity[3], clientRender.scale.velocity[4], tocolor(255, 255, 255, 140), 1.00, clientRender.fonts.italic, "center", "center")
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if isPedInVehicle(localPlayer) then
		addEventHandler('onClientRender', root, speedometer.draw)
	end
	
	addEventHandler("onClientVehicleEnter", root, function(player, seat)
		if player == localPlayer and seat == 0 then
            addEventHandler('onClientRender', root, speedometer.draw)
		end
	end)

	addEventHandler("onClientVehicleExit", root, function(player, seat)
		if player == localPlayer and seat == 0 then
			removeEventHandler('onClientRender', root, speedometer.draw)
        end
	end)
end)


