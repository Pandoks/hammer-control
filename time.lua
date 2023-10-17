local M = {}

local DAYS = { "sunday", "monday", "tuesday", "wednesday", "thursday", "friday", "saturday" }
M.DAY = ""
M.TIME = ""
local SCHEDULE = hs.json.read("./hammer-control/schedule.json")

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

function M.getTime()
  local url = "http://worldtimeapi.org/api/ip"
  local status, body = hs.http.get(url)

  if status == 200 then
    local json = hs.json.decode(body)

    M.DAY = DAYS[json.day_of_week + 1]
    local hour, minute = json.datetime:match("T(%d%d):(%d%d):")
    M.TIME = hour .. ":" .. minute
  else
    M.DAY = string.lower(os.date("%A"))
    M.TIME = os.date("%H:%M")
  end
end

function M.incrementTime()
  if string.match(M.TIME, "23:59") then
    local day_index
    for index, value in ipairs(DAYS) do
      if string.match(M.DAY, value) then
        day_index = index
      end
    end
    if day_index == 7 then
      M.DAY = DAYS[1] -- reminder that lua has cancer indexing starting at 1
    else
      M.DAY = DAYS[day_index + 1]
    end
    M.TIME = "00:00"
  else
    local hour, minute = string.match(M.TIME, "(%d%d):(%d%d)")
    hour, minute = tonumber(hour), tonumber(minute)
    minute = minute + 1
    if minute == 60 then
      minute = 0
      hour = hour + 1
    end
    M.TIME = string.format("%02d:%02d", hour, minute)
  end
end

function M.getSchedule()
  if not SCHEDULE then
    error(
      "No schedule file found. Schedule should be in ~/.hammerspoon/hammer-control/schedule.json"
    )
    return
  end

  local block
  for _, timeblock in pairs(SCHEDULE[M.DAY]) do
    local start_time = timeblock["start"]
    local end_time = timeblock["end"]
    print(M.TIME)

    if compareTime(M.TIME, end_time) >= 0 then
      goto continue
    end
    if compareTime(M.TIME, start_time) >= 0 then
      block = timeblock
      break
    end

    ::continue::
  end
  if block == nil then
    print("block") --remove
    return
  end

  local block_time = convertToMinute(block["end"]) - convertToMinute(M.TIME)
  if block_time < 0 then
    print("time < 0") --remove
    return
  end
  local end_time = os.date("!%Y-%m-%dT%H:%M:%SZ", os.time(os.date("*t")) + block_time * 60)
  return {
    end_time = end_time,
    blocklist = block["blocklist"],
  }
end

M.getTime()
return M
