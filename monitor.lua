print("Initializing Reaction Monitor v1.1")

local component = require("component")
local term = require("term")

update_interval = 5
battery = component.big_battery
output_meter = component.rfmeter
reactor = component.br_reactor
cutoff = component.redstone

bat_capacity = battery.getMaxEnergyStored()
last_message = ""
current_row = 1

component.gpu.setResolution(30,30)

function draw_reactor_status(status)
    string = "Reactor Status: "
    if (status == true) then
        string = string .. "Online"
    else
        string = string .. "Offline"
    end

    term.setCursor(1, current_row)
    term.write(string)
    current_row = current_row + 1
end


print("starting loop!")

while(true)
do

    battery_percent = battery.getEnergyStored() / bat_capacity
    print("Battery percentage: " .. tostring(battery_percent))

    if (battery_percent < 0.5 and reactor.getActive() == false)
    then
        print("Battery percentage low, activating reactor...")
        reactor.setActive(true)
    end

    if (battery_percent > 0.99 and reactor.getActive() == true)
    then
        print("Battery full, deactivating reactor...")
        reactor.setActive(false)
    end

    term.clear()
    draw_reactor_status(reactor.getActive())


    os.sleep(update_interval)

end