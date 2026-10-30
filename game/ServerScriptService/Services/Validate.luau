--!strict
-- Argument validation for RemoteEvent payloads. Every client value is
-- untrusted: check type, length and range before using it.

local Validate = {}

-- Identifier made of letters, digits and underscores, e.g. an egg id.
function Validate.Id(value: unknown, maxLength: number): string?
	if typeof(value) ~= "string" then
		return nil
	end
	local text = value :: string
	if #text == 0 or #text > maxLength then
		return nil
	end
	if string.match(text, "^[%w_]+$") == nil then
		return nil
	end
	return text
end

-- Whole number within [min, max]. Rejects NaN, infinity and fractions.
function Validate.Integer(value: unknown, min: number, max: number): number?
	if typeof(value) ~= "number" then
		return nil
	end
	local n = value :: number
	if n ~= n or n % 1 ~= 0 or n < min or n > max then
		return nil
	end
	return n
end

-- True when a remote fired with no extra arguments.
function Validate.NoArgs(...: unknown): boolean
	return select("#", ...) == 0
end

return Validate
