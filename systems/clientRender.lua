--[[
    @Code author: satan_
    @Created for gtao.pl
    @Licensed by MIT
    @Contact on kontaktthinks@gmail.com/satan_#4535
]]

local speedometer = {data={}};
local sx, sy = guiGetScreenSize();
local zoom = 1;

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

function createTexture(file)
    return dxCreateTexture(file, "dxt5", false, "clamp")
end

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
        dxDrawImage(clientRender.var._positions.arrow[1], clientRender.var._positions.arrow[2], clientRender.var._positions.arrow[3], clientRender.var._positions.arrow[4], clientRender.var._textures.arrow, speedometer.data.rpm, 0, 0)
        dxDrawImage(clientRender.var._positions.background[1], clientRender.var._positions.background[2], clientRender.var._positions.background[3], clientRender.var._positions.background[4], clientRender.var._textures.background)
        dxDrawText('MPH', clientRender.var._positions.mph[1], clientRender.var._positions.mph[2], clientRender.var._positions.mph[3], clientRender.var._positions.mph[4], tocolor(255, 255, 255, 140), 1.00, clientRender.var._fonts.mph, "center", "center")
        dxDrawText(getVehicleCurrentGear(speedometer.data.vehicle), clientRender.var._positions.gear[1], clientRender.var._positions.gear[2], clientRender.var._positions.gear[3], clientRender.var._positions.gear[4], tocolor(255, 255, 255, 140), 1.00, clientRender.var._fonts.gear, "center", "center")
    
        dxDrawText(string.format('%03d', speedometer.data.velocity), clientRender.var._positions.velocity[1], clientRender.var._positions.velocity[2], clientRender.var._positions.velocity[3], clientRender.var._positions.velocity[4], tocolor(255, 255, 255, 140), 1.00, clientRender.var._fonts.italic, "center", "center")
    end
end

addEventHandler("onClientResourceStart", resourceRoot, function()
	if isPedInVehicle(localPlayer) then
        clientRender = {
            var = {
                _textures  = {
                    background = createTexture('textures/background.png');
                    arrow      = createTexture('textures/arrow.png');
                };
                _fonts     = {
                    italic     = dxCreateFont('fonts/italic.ttf', scale_x(70));
                    gear       = dxCreateFont('fonts/italic.ttf', scale_x(38));
                    mph       = dxCreateFont('fonts/italic.ttf', scale_x(19));
                };
                _positions = {
                    background = {scale_x(1579), scale_y(795), scale_x(300), scale_y(300)};
                    arrow      = {scale_x(1579), scale_y(795), scale_x(300), scale_y(300)};
                    gear       = {scale_x(1957), scale_y(890), scale_x(1500), scale_y(990)};
                    velocity   = {scale_x(1957), scale_y(995), scale_x(1500), scale_y(1060)};
                    mph       = {scale_x(1989), scale_y(890), scale_x(1600), scale_y(990)};
                };
            }
        }
		addEventHandler('onClientRender', root, speedometer.draw)
	end
	
	addEventHandler("onClientVehicleEnter", root, function(player, seat)
		if player == localPlayer and seat == 0 then
            clientRender = {
                var = {
                    _textures  = {
                        background = createTexture('textures/background.png');
                        arrow      = createTexture('textures/arrow.png');
                    };
                    _fonts     = {
                        italic     = dxCreateFont('fonts/italic.ttf', scale_x(70));
                        gear       = dxCreateFont('fonts/italic.ttf', scale_x(38));
                        mph       = dxCreateFont('fonts/italic.ttf', scale_x(19));
                    };
                    _positions = {
                        background = {scale_x(1579), scale_y(795), scale_x(300), scale_y(300)};
                        arrow      = {scale_x(1579), scale_y(795), scale_x(300), scale_y(300)};
                        gear       = {scale_x(1957), scale_y(890), scale_x(1500), scale_y(990)};
                        velocity   = {scale_x(1957), scale_y(995), scale_x(1500), scale_y(1060)};
                        mph       = {scale_x(1989), scale_y(890), scale_x(1600), scale_y(990)};
                    };
                }
            }
            addEventHandler('onClientRender', root, speedometer.draw)
		end
	end)

	addEventHandler("onClientVehicleExit", root, function(player, seat)
		if player == localPlayer and seat == 0 then
			removeEventHandler('onClientRender', root, speedometer.draw)
            for k, texture in pairs(clientRender.var._textures) do 
                if isElement(texture) then 
                    destroyElement(texture)
                end
            end
            clientRender.var._textures = {}
            for k, font in pairs(clientRender.var._fonts) do 
                if isElement(font) then 
                    destroyElement(font)
                end
            end
            clientRender.var._fonts = {}
		end
	end)
end)


