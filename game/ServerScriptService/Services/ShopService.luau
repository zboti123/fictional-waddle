--!strict
-- Egg shop. The client sends only the egg id; price, unlocks, free slot and
-- balance are all checked here. The player is never charged without a slot.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Remotes = require(Shared.Remotes)
local Format = require(Shared.Format)
local Eggs = require(Shared.Config.Eggs)

local Services = script.Parent
local DataService = require(Services.DataService)
local EconomyService = require(Services.EconomyService)
local IncubationService = require(Services.IncubationService)
local AnnounceService = require(Services.AnnounceService)
local RateLimiter = require(Services.RateLimiter)
local Validate = require(Services.Validate)

local ShopService = {}

local MAX_ID_LENGTH = 32
local buyLimiter = RateLimiter.new(4, 2)

local function onBuyEgg(player: Player, eggIdArg: unknown, ...: unknown)
	if not Validate.NoArgs(...) then
		return
	end
	if not buyLimiter:Allow(player) then
		return
	end
	local eggId = Validate.Id(eggIdArg, MAX_ID_LENGTH)
	if eggId == nil then
		return
	end
	local egg = Eggs.Defs[eggId]
	if egg == nil or not egg.Purchasable then
		return
	end
	local data = DataService.Get(player)
	if data == nil then
		return
	end

	if data.NestLevel < egg.UnlockNestLevel then
		AnnounceService.Notify(player, `Reach nest level {egg.UnlockNestLevel} to unlock the {egg.DisplayName}.`, "Error")
		return
	end
	if data.Rebirths < egg.UnlockRebirths then
		AnnounceService.Notify(player, `Rebirth {egg.UnlockRebirths} unlocks the {egg.DisplayName}.`, "Error")
		return
	end
	if not IncubationService.HasFreeSlot(player) then
		AnnounceService.Notify(player, "Your nest is full! Hatch an egg first.", "Error")
		return
	end
	local symbol = if egg.Currency == "Gems" then "💎" else "🔥"
	if not EconomyService.Spend(player, egg.Currency, egg.Price, `Egg:{eggId}`) then
		AnnounceService.Notify(player, `You need {symbol} {Format.Number(egg.Price)}.`, "Error")
		return
	end
	if not IncubationService.PlaceEgg(player, eggId) then
		EconomyService.Add(player, egg.Currency, egg.Price, `Refund:{eggId}`)
		return
	end
	AnnounceService.Notify(player, `{egg.DisplayName} placed in your nest!`, "Success")
end

function ShopService.Start()
	Remotes.Get("BuyEgg").OnServerEvent:Connect(onBuyEgg)
end

return ShopService
