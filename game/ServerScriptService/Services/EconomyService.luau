--!strict
-- The only place currency balances change. Every change is reported to
-- transaction listeners (used by analytics and quests in later milestones).

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Types = require(ReplicatedStorage.Shared.Types)
local DataService = require(script.Parent.DataService)
local StateSync = require(script.Parent.StateSync)

export type Flow = "Source" | "Sink"
type Listener = (player: Player, currency: Types.Currency, amount: number, flow: Flow, reason: string, balance: number) -> ()

local EconomyService = {}

local listeners: { Listener } = {}

local function isValidAmount(amount: number): boolean
	return amount == amount and amount > 0 and amount < math.huge
end

local function notify(player: Player, currency: Types.Currency, amount: number, flow: Flow, reason: string, balance: number)
	for _, listener in listeners do
		task.spawn(listener, player, currency, amount, flow, reason, balance)
	end
end

function EconomyService.OnTransaction(listener: Listener)
	table.insert(listeners, listener)
end

function EconomyService.Get(player: Player, currency: Types.Currency): number
	local data = DataService.Get(player)
	if data == nil then
		return 0
	end
	return if currency == "Gems" then data.Gems else data.Embers
end

function EconomyService.Add(player: Player, currency: Types.Currency, amount: number, reason: string): boolean
	local data = DataService.Get(player)
	if data == nil or not isValidAmount(amount) then
		return false
	end
	local whole = math.floor(amount)
	if whole <= 0 then
		return false
	end
	local balance: number
	if currency == "Gems" then
		data.Gems += whole
		data.Stats.GemsEarned += whole
		balance = data.Gems
	else
		data.Embers += whole
		balance = data.Embers
	end
	StateSync.MarkDirty(player)
	notify(player, currency, whole, "Source", reason, balance)
	return true
end

-- Returns false (and changes nothing) when the player cannot afford it.
function EconomyService.Spend(player: Player, currency: Types.Currency, amount: number, reason: string): boolean
	local data = DataService.Get(player)
	if data == nil or not isValidAmount(amount) then
		return false
	end
	local whole = math.floor(amount)
	local balance: number
	if currency == "Gems" then
		if data.Gems < whole then
			return false
		end
		data.Gems -= whole
		balance = data.Gems
	else
		if data.Embers < whole then
			return false
		end
		data.Embers -= whole
		balance = data.Embers
	end
	StateSync.MarkDirty(player)
	notify(player, currency, whole, "Sink", reason, balance)
	return true
end

return EconomyService
