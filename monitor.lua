print("Initializing Reaction Monitor v1.1")

local component = require("component")

update_interval = 5
battery = component.big_battery
output_meter = component.rfmeter
reactor = component.br_reactor
cutoff = component.redstone

bat_capacity = battery.getMaxEnergyStored()


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


    os.sleep(update_interval)

end