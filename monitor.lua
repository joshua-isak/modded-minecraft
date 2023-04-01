print("Initializing Reaction Monitor v1.1")

local component = require("component")
local term = require("term")

update_interval = 5
battery = component.big_battery
output_meter = component.rfmeter
reactor = component.br_reactor
cutoff = component.redstone
gpu = component.gpu
turbine = component.br_turbine

bat_capacity = battery.getMaxEnergyStored()
min_capacity = 0.10
last_message = "Init Success!"
current_row = 1

gpu.setResolution(30,15)

function draw_space()
    current_row = current_row + 1
end

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
    current_row = current_row + 1
end


function draw_turbine_status()
    term.setCursor(1, current_row)
    rotor_speed  = turbine.getRotorSpeed()
    term.write("Turbine Status: ")

    if (reactor.getActive()) == false then
        term.write("Idle        ")
    elseif (rotor_speed < 1800) then
        gpu.setForeground(0xFFFF00)
        term.write("Spooling   ")
        gpu.setForeground(0xFFFFFF)
    elseif (rotor_speed > 1800) then
        gpu.setForeground(0x00FF00)
        term.write("Engaged      ")
        gpu.setForeground(0xFFFFFF)
    end
    current_row = current_row + 1
    term.setCursor(1, current_row)
    term.write("Turbine Speed:  ")
    term.write(tostring(math.floor(turbine.getRotorSpeed())) .. " RPM")
    current_row = current_row + 1
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
    term.write("Energy Stored:  " .. tostring(math.floor(battery.getEnergyStored())) .. " RF")
    current_row = current_row + 2
end


function draw_grid_usage()
    term.setCursor(1, current_row)
    term.write("Grid Usage:     ")
    term.write(tostring(output_meter.getAvg()) .. " RF/t      " )
    current_row = current_row + 1
end

function draw_energy_produced()
    term.setCursor(1, current_row)
    term.write("Generation:     ")
    generation = math.floor(turbine.getEnergyProducedLastTick()*100)/100
    term.write(tostring(generation) .. " RF/t           ")
    current_row = current_row + 1
end


function draw_power_flow()
    term.setCursor(1, current_row)
    term.write("Energy Delta:   ")
    power_delta = turbine.getEnergyProducedLastTick() - output_meter.getAvg()
    power_delta = math.floor(power_delta*100)/100
    if (power_delta < -500) then
        gpu.setForeground(0xFF0000)
        term.write(tostring(power_delta) .. " RF/t     ")
        gpu.setForeground(0xFFFFFF)
    elseif (power_delta < 0) then
        gpu.setForeground(0xFFFF00)
        term.write(tostring(power_delta) .. " RF/t     ")
        gpu.setForeground(0xFFFFFF)
    else
        gpu.setForeground(0x00FF00)
        term.write(tostring(power_delta) .. " RF/t     ")
        gpu.setForeground(0xFFFFFF)
    end

    current_row = current_row + 1
end


function draw_runtime()
    term.setCursor(1, current_row)

    power_delta = turbine.getEnergyProducedLastTick() - output_meter.getAvg()
    unit = ""
    if (power_delta > 0) then
        term.write("Charge Time:    ")
        runtime = ((bat_capacity - battery.getEnergyStored()) / power_delta) / 20 / 60 -- minutes
        if (runtime > 60) then  -- display as hours
            runtime = runtime / 60
            runtime = math.floor(runtime*100)/100
            unit = "hours            "
        else    -- display as minutes
            runtime = math.floor(runtime*100)/100
            unit = "minutes          "
        end
    else
        term.write("Runtime:        ")
        runtime = -1*(battery.getEnergyStored() / power_delta) / 20 / 60 -- minutes
        if (runtime > 60) then  -- display as hours
            runtime = runtime / 60
            runtime = math.floor(runtime*100)/100
            unit = "hours            "
        else    -- display as minutes
            runtime = math.floor(runtime*100)/100
            unit = "minutes          "
        end
    end
    term.write(tostring(runtime) .. " " .. unit)
    current_row = current_row + 1
end


function draw_power_cutoff()
    current_row = current_row + 1
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

    if (battery_percent < min_capacity and reactor.getActive() == false)
    then
        last_message = "Battery percentage low, \nactivating reactor...   "
        reactor.setActive(true)

    end

    if (battery_percent > 0.99 and reactor.getActive() == true)
    then
        last_message = "Battery full,           \ndeactivating reactor...  "
        reactor.setActive(false)
    end

    if (cutoff.getInput()[2] > 0) then
        last_message = "Override enabled,        \nactivating reactor...    "
        reactor.setActive(true)
    else
        ;
    end

    if (reactor.getActive() == true) then
        if (turbine.getRotorSpeed() < 1800) then
            turbine.setInductorEngaged(false)
        else
            turbine.setInductorEngaged(true)
        end
    end


    draw_reactor_status(reactor.getActive())
    draw_turbine_status()
    draw_space()

    draw_battery_charge()
    draw_energy_stored()
    draw_grid_usage()
    draw_energy_produced()
    draw_power_flow()
    draw_runtime()
    -- draw_power_cutoff()
    draw_last_message()

    current_row = 1
    os.sleep(update_interval)

end