local time = require("hammer-control/time")

local M = {}
local BLOCK_FILE = ""

local function isSelfControlRunning()
  local output =
    hs.execute("/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli is-running 2>&1")
  return string.match(output, "YES")
end

local function insertPassword()
  local prompt_timer
  prompt_timer = hs.timer.new(0.1, function()
    local security_prompt = hs.application.get("SecurityAgent")
    if security_prompt then
      print("inserting") --remove
      local password =
        hs.execute("security find-generic-password -a $(whoami) -s hammer-control -w")

      security_prompt:activate(true)
      hs.timer.waitUntil(function()
        local front_app = hs.application.frontmostApplication()

        local focused = front_app and front_app:name() == "SecurityAgent"
        if not focused then
          security_prompt:activate(true)
        end

        return focused
      end, function(timer)
        timer:stop()

        hs.eventtap.keyStrokes(password)
        hs.eventtap.keyStroke({}, "return")
        hs.alert.show("SelfControl started")

        prompt_timer:stop()
      end, 0.05)

      return
    end
    print("after") --remove
  end)
  prompt_timer:start()
end

local function selfControlCallback(exit_code, _, std_error)
  if exit_code == 0 then
    print("SelfControl started")
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
