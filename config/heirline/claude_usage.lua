-- Claude Usage Data Fetcher with Caching
-- Mirrors the TypeScript statusline.ts logic

local M = {}

-- ============================================================================
-- Constants
-- ============================================================================

local CONFIG_PATH = vim.fn.expand("~/.claude/statusline.json")
local CACHE_PATH = vim.fn.expand("~/.claude/statusline-cache.json")
local CACHE_TTL_MS = 5 * 60 * 1000 -- 5 minutes in ms
local SEVEN_DAY_PERIOD_MS = 7 * 24 * 60 * 60 * 1000

-- Work schedule configuration (matches TypeScript)
local WORK_SCHEDULE = {
	-- Expected usage per day of week (0 = Sunday, 6 = Saturday)
	-- Should sum to 100
	daily_expected = { 7, 18, 18, 18, 18, 14, 7 }, -- index 1=Sun, 7=Sat (Lua 1-indexed)
	start_hour = 9,
	end_hour = 18,
	work_days = { [2] = true, [3] = true, [4] = true, [5] = true, [6] = true }, -- Mon=2 to Fri=6 in Lua wday
}

local THRESHOLDS = {
	WARNING = 70,
	DANGER = 90,
}

-- In-memory cache to avoid file reads on every statusline update
local memory_cache = {
	data = nil,
	timestamp = 0,
}

-- ============================================================================
-- File I/O Helpers
-- ============================================================================

local function read_json_file(path)
	local file = io.open(path, "r")
	if not file then
		return nil
	end
	local content = file:read("*a")
	file:close()
	if content == "" then
		return nil
	end
	local ok, data = pcall(vim.json.decode, content)
	if ok then
		return data
	end
	return nil
end

local function write_json_file(path, data)
	local ok, encoded = pcall(vim.json.encode, data)
	if not ok then
		return false
	end
	local file = io.open(path, "w")
	if not file then
		return false
	end
	file:write(encoded)
	file:close()
	return true
end

-- ============================================================================
-- Config Loading
-- ============================================================================

local function load_config()
	return read_json_file(CONFIG_PATH)
end

-- ============================================================================
-- Cache Management
-- ============================================================================

local function read_cache()
	local now = vim.loop.now() -- ms since Neovim started, but we need wall clock
	local now_ms = os.time() * 1000

	-- Check memory cache first
	if memory_cache.data and (now_ms - memory_cache.timestamp) < CACHE_TTL_MS then
		return memory_cache.data
	end

	-- Check file cache
	local cached = read_json_file(CACHE_PATH)
	if cached and cached.timestamp then
		local age = now_ms - cached.timestamp
		if age < CACHE_TTL_MS then
			-- Update memory cache
			memory_cache.data = cached.data
			memory_cache.timestamp = cached.timestamp
			return cached.data
		end
	end

	return nil
end

local function write_cache(data)
	local now_ms = os.time() * 1000
	local cached = {
		timestamp = now_ms,
		data = data,
	}
	-- Update memory cache
	memory_cache.data = data
	memory_cache.timestamp = now_ms
	-- Write to file
	write_json_file(CACHE_PATH, cached)
end

-- ============================================================================
-- API Fetching (async via jobstart)
-- ============================================================================

-- Pending fetch state to avoid concurrent requests
local fetch_in_progress = false

local function fetch_rate_limits_async(config, callback)
	if fetch_in_progress then
		return
	end
	fetch_in_progress = true

	local url = string.format("https://claude.ai/api/organizations/%s/usage", config.organization_id)

	local cmd = {
		"curl",
		"-s",
		"--compressed",
		url,
		"-H",
		"User-Agent: Mozilla/5.0 (X11; Linux x86_64; rv:144.0) Gecko/20100101 Firefox/144.0",
		"-H",
		"Accept: */*",
		"-H",
		"Accept-Language: en-US,en;q=0.5",
		"-H",
		"Accept-Encoding: gzip, deflate, br, zstd",
		"-H",
		"Referer: https://claude.ai/settings/usage",
		"-H",
		string.format("anthropic-anonymous-id: %s", config.anonymous_id),
		"-H",
		"anthropic-client-platform: web_claude_ai",
		"-H",
		"anthropic-client-version: 1.0.0",
		"-H",
		string.format("anthropic-device-id: %s", config.device_id),
		"-H",
		"content-type: application/json",
		"-H",
		"Alt-Used: claude.ai",
		"-H",
		"Connection: keep-alive",
		"-H",
		string.format(
			"Cookie: sessionKey=%s; anthropic-device-id=%s; ajs_anonymous_id=%s",
			config.session_key,
			config.device_id,
			config.anonymous_id
		),
		"-H",
		"Sec-Fetch-Dest: empty",
		"-H",
		"Sec-Fetch-Mode: cors",
		"-H",
		"Sec-Fetch-Site: same-origin",
		"-H",
		"Priority: u=4",
		"-H",
		"TE: trailers",
	}

	local stdout_chunks = {}

	vim.fn.jobstart(cmd, {
		stdout_buffered = true,
		on_stdout = function(_, data)
			if data then
				for _, line in ipairs(data) do
					if line ~= "" then
						table.insert(stdout_chunks, line)
					end
				end
			end
		end,
		on_exit = function(_, exit_code)
			fetch_in_progress = false
			if exit_code ~= 0 then
				if callback then
					callback(nil)
				end
				return
			end

			local output = table.concat(stdout_chunks, "")
			local ok, data = pcall(vim.json.decode, output)
			if ok and data then
				write_cache(data)
				-- Fire the User event so Heirline components re-evaluate
				vim.schedule(function()
					vim.api.nvim_exec_autocmds("User", { pattern = "ClaudeUsageUpdated" })
				end)
				if callback then
					callback(data)
				end
			else
				if callback then
					callback(nil)
				end
			end
		end,
	})
end

-- ============================================================================
-- Main Data Getter
-- ============================================================================

-- Get cached data (synchronous, returns cached data or nil)
function M.get_usage_data()
	-- Try cache first
	local cached = read_cache()
	if cached then
		return cached
	end

	-- Cache miss - trigger async fetch but return nil for now
	local config = load_config()
	if config then
		fetch_rate_limits_async(config, function(data)
			-- Data will be available on next statusline update
			if data then
				vim.cmd("redrawtabline")
			end
		end)
	end

	return nil
end

-- ============================================================================
-- Calculations (mirrors TypeScript logic)
-- ============================================================================

function M.calculate_projected_usage(utilization, resets_at)
	local now = os.time() * 1000
	local reset_time = M.parse_iso_date(resets_at)
	if not reset_time then
		return utilization
	end

	local time_remaining = reset_time - now

	-- If reset is in the past or very soon, just return current usage
	if time_remaining <= 0 then
		return utilization
	end

	local time_elapsed = SEVEN_DAY_PERIOD_MS - time_remaining

	-- Avoid division by zero
	if time_elapsed <= 0 then
		return utilization
	end

	-- Calculate burn rate and project to end of period
	local burn_rate = utilization / time_elapsed
	local projected = burn_rate * SEVEN_DAY_PERIOD_MS

	-- Time-decay: blend projection with current usage based on week progress
	local week_progress = time_elapsed / SEVEN_DAY_PERIOD_MS
	local projection_weight = math.min(1, week_progress * 2)

	return utilization * (1 - projection_weight) + projected * projection_weight
end

function M.get_expected_usage_at_time(period_start, current_time)
	local expected = 0
	local current = period_start

	while current < current_time do
		local date = os.date("*t", current / 1000)
		local day_of_week = date.wday -- 1=Sun, 2=Mon, ..., 7=Sat
		local hour = date.hour

		local is_work_day = WORK_SCHEDULE.work_days[day_of_week] or false
		local is_work_hour = hour >= WORK_SCHEDULE.start_hour and hour < WORK_SCHEDULE.end_hour

		if is_work_day and is_work_hour then
			local work_hours_per_day = WORK_SCHEDULE.end_hour - WORK_SCHEDULE.start_hour
			local hourly_expected = WORK_SCHEDULE.daily_expected[day_of_week] / work_hours_per_day
			expected = expected + hourly_expected
		elseif not is_work_day then
			-- Weekend: distribute across all hours
			local hourly_expected = WORK_SCHEDULE.daily_expected[day_of_week] / 24
			expected = expected + hourly_expected
		end
		-- Non-work hours on work days: no expected usage

		current = current + (60 * 60 * 1000) -- +1 hour in ms
	end

	return math.min(100, expected)
end

function M.get_remaining_work_hours(current_time, reset_time)
	local work_hours = 0
	local current = current_time

	while current < reset_time do
		local date = os.date("*t", current / 1000)
		local day_of_week = date.wday
		local hour = date.hour

		local is_work_day = WORK_SCHEDULE.work_days[day_of_week] or false
		local is_work_hour = hour >= WORK_SCHEDULE.start_hour and hour < WORK_SCHEDULE.end_hour

		if is_work_day and is_work_hour then
			work_hours = work_hours + 1
		end

		current = current + (60 * 60 * 1000) -- +1 hour in ms
	end

	return work_hours
end

function M.calculate_pace(utilization, resets_at)
	local now = os.time() * 1000
	local reset_time = M.parse_iso_date(resets_at)
	if not reset_time then
		return 0
	end

	local period_start = reset_time - SEVEN_DAY_PERIOD_MS
	local expected_utilization = M.get_expected_usage_at_time(period_start, now)

	-- Pace: positive = under budget (good), negative = over budget (bad)
	return expected_utilization - utilization
end

function M.calculate_daily_budget(utilization, resets_at)
	local now = os.time() * 1000
	local reset_time = M.parse_iso_date(resets_at)
	if not reset_time then
		return 0
	end

	local remaining_budget = 100 - utilization
	local remaining_work_hours = M.get_remaining_work_hours(now, reset_time)

	-- Convert to "per work day"
	local work_hours_per_day = WORK_SCHEDULE.end_hour - WORK_SCHEDULE.start_hour
	local remaining_work_days = remaining_work_hours / work_hours_per_day

	-- Minimum to avoid division issues
	local effective_remaining_days = math.max(0.1, remaining_work_days)

	return math.max(0, remaining_budget / effective_remaining_days)
end

-- ============================================================================
-- Helpers
-- ============================================================================

-- Parse ISO 8601 date string to Unix timestamp in ms
function M.parse_iso_date(iso_string)
	if not iso_string then
		return nil
	end
	-- Format: 2025-01-15T00:00:00.000Z
	local pattern = "(%d+)-(%d+)-(%d+)T(%d+):(%d+):(%d+)"
	local year, month, day, hour, min, sec = iso_string:match(pattern)
	if not year then
		return nil
	end

	local time = os.time({
		year = tonumber(year),
		month = tonumber(month),
		day = tonumber(day),
		hour = tonumber(hour),
		min = tonumber(min),
		sec = tonumber(sec),
	})

	return time * 1000 -- Convert to ms
end

-- Get color based on projected usage
function M.get_weekly_severity(utilization, resets_at)
	local projected = M.calculate_projected_usage(utilization, resets_at)
	if projected >= THRESHOLDS.DANGER then
		return "danger"
	elseif projected >= THRESHOLDS.WARNING then
		return "warning"
	end
	return "normal"
end

-- Get color based on pace
function M.get_pace_severity(pace)
	if pace <= -10 then
		return "danger"
	elseif pace <= -5 then
		return "warning"
	end
	return "normal"
end

return M
