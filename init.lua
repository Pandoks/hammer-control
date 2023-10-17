hs.application.enableSpotlightForNameSearches(true)
local selfcontrol = require("hammer-control/selfcontrol")
local time = require("hammer-control/time")

-- system event tracker
SYSTEM_WATCHER = hs.caffeinate.watcher.new(function(event_type)
  if event_type == hs.caffeinate.watcher.screensDidUnlock then
    print("unlocking") --remove
    time.getTime() -- reset time after wake
    selfcontrol.start() -- run Self Control after unlock
    SELFCONTROL_TIMER:start()
  end

  if event_type == hs.caffeinate.watcher.screensDidLock then
    print("locking") --remove
    SELFCONTROL_TIMER:stop() -- stop Self Control running on login screen
  end
end)
SYSTEM_WATCHER:start()

selfcontrol.start()
SELFCONTROL_TIMER = hs.timer.new(60, selfcontrol.run)
SELFCONTROL_TIMER:start()
