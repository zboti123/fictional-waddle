--!strict
-- Number, time and percentage formatting for UI text.

local Format = {}

local SUFFIXES = { "", "K", "M", "B", "T", "Qa", "Qi", "Sx", "Sp", "Oc", "No", "Dc" }

local function trimZeros(text: string): string
	if string.find(text, ".", 1, true) == nil then
		return text
	end
	local trimmed = string.gsub(text, "0+$", "")
	trimmed = string.gsub(trimmed, "%.$", "")
	return trimmed
end

-- 1234 -> "1.23K", 15 -> "15", 2.5 -> "2.5"
function Format.Number(value: number): string
	if value ~= value then
		return "0"
	end
	local negative = value < 0
	local n = math.abs(value)
	local text: string
	if n < 1000 then
		if n < 10 and n % 1 ~= 0 then
			text = trimZeros(string.format("%.1f", n))
		else
			text = tostring(math.floor(n))
		end
	else
		local index = math.min(math.floor(math.log10(n) / 3), #SUFFIXES - 1)
		local scaled = n / 1000 ^ index
		if scaled >= 999.5 and index < #SUFFIXES - 1 then
			index += 1
			scaled = n / 1000 ^ index
		end
		local pattern = if scaled < 10 then "%.2f" elseif scaled < 100 then "%.1f" else "%.0f"
		text = trimZeros(string.format(pattern, scaled)) .. SUFFIXES[index + 1]
	end
	return if negative then "-" .. text else text
end

-- 75 -> "1:15", 4000 -> "1h 6m"
function Format.Duration(seconds: number): string
	local total = math.max(0, math.ceil(seconds))
	if total >= 3600 then
		local hours = math.floor(total / 3600)
		local minutes = math.floor((total % 3600) / 60)
		return string.format("%dh %dm", hours, minutes)
	end
	local minutes = math.floor(total / 60)
	return string.format("%d:%02d", minutes, total % 60)
end

-- 65 -> "65%", 1.8 -> "1.8%", 0.01 -> "0.01%"
function Format.Percent(percent: number): string
	local pattern = if percent >= 10 then "%.0f" elseif percent >= 1 then "%.1f" else "%.3f"
	return trimZeros(string.format(pattern, percent)) .. "%"
end

return Format
