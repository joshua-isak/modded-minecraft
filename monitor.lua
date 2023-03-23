print("Initializing Reaction Monitor v1.1")

local component = require("component")
local term = require("term")

update_interval = 5
battery = component.big_battery
output_meter = component.rfmeter
reactor = component.br_reactor
cutoff = component.redstone
gpu = component.gpu

bat_capacity = battery.getMaxEnergyStored()
last_message = "Init Success!"
current_row = 1

gpu.setResolution(30,15)

function draw_reactor_status(status)
    term.setCursor(1, current_row)
    term.write("Reactor Status: ")
    if (status == true) then
        gpu.setForeground(0x00FF00)
        term.write("Online  ")
        gpu.setForeground(0xFFFFFF)
    else
        term.write("Offline ")
    end
    current_row = current_row + 2
end


function draw_battery_charge()
    term.setCursor(1, current_row)
    term.write("Battery Charge: ")
    charge = (battery.getEnergyStored() / bat_capacity) * 100
    charge = math.floor(charge*100)/100
    if (charge < 50) then
        gpu.setForeground(0xFF0000)
        term.write(tostring(charge) .. "% ")
        gpu.setForeground(0xFFFFFF)
    else
        gpu.setForeground(0x00FF00)
        term.write(tostring(charge) .. "% ")
        gpu.setForeground(0xFFFFFF)
    end
    current_row = current_row + 1
end


function draw_energy_stored()
    term.setCursor(1, current_row)
    term.write("Energy Stored:  " .. tostring(battery.getEnergyStored()) .. " RF")
    current_row = current_row + 2
end


function draw_grid_usage()
    term.setCursor(1, current_row)
    term.write("Grid Usage:     ")
    term.write(tostring(output_meter.getAvg()) .. " RF/t      " )
    current_row = current_row + 1
end


function draw_power_flow()
    term.setCursor(1, current_row)
    term.write("Energy Delta:   ")
    power_delta = reactor.getEnergyProducedLastTick() - output_meter.getAvg()
    power_delta = math.floor(power_delta*100)/100
    if (power_delta < -500) then
        gpu.setForeground(0xFF0000)
        term.write(tostring(power_delta) .. " RF/t ")
        gpu.setForeground(0xFFFFFF)
    elseif (power_delta < 0) then
        gpu.setForeground(0xFFFF00)
        term.write(tostring(power_delta) .. " RF/t ")
        gpu.setForeground(0xFFFFFF)
    else
        gpu.setForeground(0x00FF00)
        term.write(tostring(power_delta) .. " RF/t ")
        gpu.setForeground(0xFFFFFF)
    end

    current_row = current_row + 1
end


function draw_power_cutoff()
    current_row = current_row + 2
    term.setCursor(1, current_row)
    term.write("Grid Cutoff:    ")
    if (cutoff.getInput()[2] > 0) then
        gpu.setForeground(0xFF0000)
        term.write("Enabled  ")
        gpu.setForeground(0xFFFFFF)
    else
        term.write("Disabled  ")
    end
    current_row = current_row + 1
end


function draw_last_message()
    current_row = current_row + 1
    term.setCursor(1, current_row)
    current_row = current_row + 1
    term.write("------------------------------")
    term.setCursor(1, current_row)
    term.write(last_message)
    current_row = current_row + 1
end


print("starting loop!")

term.clear()

while(true)
do

    battery_percent = battery.getEnergyStored() / bat_capacity

    if (battery_percent < 0.40 and reactor.getActive() == false)
    then
        last_message = "Battery percentage low,\n activating reactor..."
        reactor.setActive(true)
    end

    if (battery_percent > 0.99 and reactor.getActive() == true)
    then
        last_message = "Battery full,\n deactivating reactor..."
        reactor.setActive(false)
    end

    if (cutoff.getInput()[2] > 0) then
        battery.setElectrodeTransfer("Output", 0)
    else
        battery.setElectrodeTransfer("Output", 1000000)
    end


    draw_reactor_status(reactor.getActive())
    draw_battery_charge()
    draw_energy_stored()
    draw_grid_usage()
    draw_power_flow()
    draw_power_cutoff()
    draw_last_message()

    current_row = 1
    os.sleep(update_interval)

end