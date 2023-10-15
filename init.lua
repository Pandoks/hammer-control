local schedule = hs.json.read("./hammer-control/schedule.json")
local days = { "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday" }

-- initiate time
local DAY, TIME
local function getTime()
  local url = "http://worldtimeapi.org/api/ip"
  local status, body = hs.http.get(url)

  if status == 200 then
    local json = hs.json.decode(body)

    DAY = days[json.day_of_week + 1]
    local hour, minute = json.datetime:match("T(%d%d):(%d%d):")
    TIME = hour .. ":" .. minute
  else
    DAY = string.lower(os.date("%A"))
    TIME = os.date("%H:%M")
  end
end
getTime()

local function incrementTime()
  if string.match(TIME, "23:59") then
    local day_index
    for index, value in ipairs(days) do
      if string.match(DAY, value) then
        day_index = index
      end
    end
    if day_index == 7 then
      DAY = days[1] -- reminder that lua has cancer indexing starting at 1
    else
      DAY = days[day_index + 1]
    end
    TIME = "00:00"
  else
    local hour, minute = string.match(TIME, "(%d%d):(%d%d)")
    hour, minute = tonumber(hour), tonumber(minute)
    minute = minute + 1
    if minute == 60 then
      minute = 0
      hour = hour + 1
    end
    TIME = string.format("%02d:%02d", hour, minute)
  end
end

-- initiate system sleep tracker
local sleep_watcher = hs.caffeinate.watcher.new(function(event_type)
  if event_type == hs.caffeinate.watcher.systemDidWake then
    getTime() -- reset time after wake
  end
end)
sleep_watcher:start()

local function convertToMinute(time_string)
  local hour, minute = string.match(time_string, "(%d%d):(%d%d)")
  if not hour or not minute then
    error("Time format is incorrect. Needs two digits for both hour and minute: 01:00 not 1:00")
  end
  return tonumber(hour) * 60 + tonumber(minute)
end

local function compareTime(time1, time2)
  -- equivalencies:
  -- compareTime(time1, time2) > 0 === time1 > time2
  -- compareTime(time1, time2) <= 0 === time1 <= time2
  -- etc

  local minutes1 = convertToMinute(time1)
  local minutes2 = convertToMinute(time2)

  if minutes1 < minutes2 then
    return -1
  elseif minutes1 == minutes2 then
    return 0
  else
    return 1
  end
end

local function selfControl()
  incrementTime()
  local output =
    hs.execute("/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli is-running 2>&1")
  if string.match(output, "YES") then
    return
  end

  local block
  for _, timeblock in pairs(schedule[DAY]) do
    local start_time = timeblock["start"]
    local end_time = timeblock["end"]

    if compareTime(TIME, end_time) >= 0 then
      goto continue
    end
    if compareTime(TIME, start_time) >= 0 then
      block = timeblock
      break
    end

    ::continue::
  end
  if block == nil then
    return
  end

  local block_time = convertToMinute(block["end"]) - convertToMinute(TIME)
  if block_time < 0 then
    return
  end
  local end_time = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time(os.date("*t")) + block_time * 60)

  local selfcontrol_command = "/Applications/SelfControl.app/Contents/MacOS/selfcontrol-cli"
  local block_file = hs.fs.pathToAbsolute(block["blocklist"])
  local selfcontrol_arguments = {
    "start",
    "--enddate",
    end_time,
    "--blocklist",
    block_file,
  }

  local startSelfControl
  local function selfcontrol_callback(exit_code, _, std_error)
    if exit_code == 0 then
      print("SelfControl started")
    elseif string.match(std_error, "Blocklist is empty, or block does not end in the future") then
      local block_file_attributes = hs.fs.attributes(block_file)
      if not (block_file_attributes and block_file_attributes["mode"] == "file") then
        error("Blocklist file " .. block_file .. "does not exist or has an error")
      else
        error("End date ends in the past")
      end
    elseif string.match(std_error, "Block is already running") then
      error("SelfControl is already running")
    elseif string.match(std_error, "Authorization cancelled") then
      print("User tried to cancel. Restarting...")
      startSelfControl()
    end
  end

  startSelfControl = function()
    local selfcontrol_task =
      hs.task.new(selfcontrol_command, selfcontrol_callback, selfcontrol_arguments)
    if not selfcontrol_task:start() then
      error("Couldn't start SelfControl task")
      return
    end

    local prompt_timer
    prompt_timer = hs.timer.doEvery(0.1, function()
      local security_prompt = hs.application.get("SecurityAgent")
      if security_prompt then
        local password =
          hs.execute("security find-generic-password -a $(whoami) -s hammer-control -w")
        security_prompt:activate(true)
        hs.eventtap.keyStrokes(password)
        hs.eventtap.keyStroke({}, "return")
        hs.alert.show("SelfControl started")
        prompt_timer:stop()
        return
      end
    end)
  end
  startSelfControl()
end

selfControl()
local selfcontrol_timer = hs.timer.new(60, selfControl)
selfcontrol_timer:start()
