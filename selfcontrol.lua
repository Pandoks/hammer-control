local time = require("hammer-control/time")

local M = {}
local BLOCK_FILE = ""

local function isSelfControlRunning()
  local output =
    hs.execute("/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli is-running 2>&1")
  return string.match(output, "YES")
end

local function insertPassword()
  hs.timer.doUntil(isSelfControlRunning, function()
    local security_prompt = hs.application.get("com.apple.SecurityAgent")
    if security_prompt then
      local password =
        hs.execute("security find-generic-password -a $(whoami) -s hammer-control -w")
      hs.eventtap.keyStrokes(password, security_prompt)

      local press_ok = [[
        tell application "System Events"
          click button "Install Helper" of window 1 of application process "SecurityAgent"
        end tell
      ]]
      hs.osascript.applescript(press_ok)
    end
  end)
end

local function selfControlCallback(exit_code, _, std_error)
  if exit_code == 0 then
    print("SelfControl started")
    hs.alert.show("SelfControl started", 2)
  elseif string.match(std_error, "Blocklist is empty, or block does not end in the future") then
    local block_file_attributes = hs.fs.attributes(BLOCK_FILE)
    if not (block_file_attributes and block_file_attributes["mode"] == "file") then
      error("Blocklist file " .. BLOCK_FILE .. " does not exist")
    else
      error("End date ends in the past")
    end
  elseif string.match(std_error, "Blocklist could not be read from file") then
    error("Blocklist file " .. BLOCK_FILE .. " has an error in it. Save the blocklist again.")
  elseif string.match(std_error, "Block is already running") then
    error("SelfControl is already running")
  elseif string.match(std_error, "Authorization cancelled") then
    print("User tried to cancel. Restarting...")
    M.start()
  end
end

function M.start()
  if isSelfControlRunning() then
    return
  end

  local schedule = time.getSchedule()
  if not (schedule and schedule.end_time and schedule.blocklist) then
    return
  end

  local end_time = schedule.end_time
  BLOCK_FILE = schedule.blocklist
  if not (end_time and BLOCK_FILE) then
    return
  end

  local selfcontrol_command = "/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli"
  local selfcontrol_arguments = {
    "start",
    "--enddate",
    end_time,
    "--blocklist",
    hs.fs.pathToAbsolute(BLOCK_FILE),
  }

  local selfcontrol_task =
    hs.task.new(selfcontrol_command, selfControlCallback, selfcontrol_arguments)
  if not selfcontrol_task:start() then
    error("Couldn't start SelfControl task")
    return
  end

  insertPassword()
end

function M.run()
  time.incrementTime()
  M.start()
end

return M
