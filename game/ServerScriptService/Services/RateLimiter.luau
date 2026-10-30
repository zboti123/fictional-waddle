--!strict
-- Per-player token bucket. Each limiter allows bursts up to Capacity and
-- refills at RefillPerSecond. Buckets are dropped when a player leaves.

local Players = game:GetService("Players")

type Bucket = {
	Tokens: number,
	UpdatedAt: number,
}

local RateLimiter = {}
RateLimiter.__index = RateLimiter

export type RateLimiter = typeof(setmetatable(
	{} :: {
		Capacity: number,
		RefillPerSecond: number,
		Buckets: { [Player]: Bucket },
	},
	RateLimiter
))

local allLimiters: { RateLimiter } = {}

function RateLimiter.new(capacity: number, refillPerSecond: number): RateLimiter
	local self = setmetatable({
		Capacity = capacity,
		RefillPerSecond = refillPerSecond,
		Buckets = {},
	}, RateLimiter)
	table.insert(allLimiters, self)
	return self
end

-- Consumes one token. Returns false when the player is over the limit.
function RateLimiter.Allow(self: RateLimiter, player: Player): boolean
	local now = os.clock()
	local bucket = self.Buckets[player]
	if bucket == nil then
		bucket = { Tokens = self.Capacity, UpdatedAt = now }
		self.Buckets[player] = bucket
	end
	local elapsed = now - bucket.UpdatedAt
	bucket.Tokens = math.min(self.Capacity, bucket.Tokens + elapsed * self.RefillPerSecond)
	bucket.UpdatedAt = now
	if bucket.Tokens < 1 then
		return false
	end
	bucket.Tokens -= 1
	return true
end

Players.PlayerRemoving:Connect(function(player: Player)
	for _, limiter in allLimiters do
		limiter.Buckets[player] = nil
	end
end)

return RateLimiter
