--!strict
-- Player notices (toasts) and server-wide announcement banners.

local ReplicatedStorage = game:GetService("ReplicatedStorage")

local Shared = ReplicatedStorage.Shared
local Types = require(Shared.Types)
local Remotes = require(Shared.Remotes)
local Format = require(Shared.Format)
local Rarities = require(Shared.Config.Rarities)
local Mutations = require(Shared.Config.Mutations)

local AnnounceService = {}

local announceRemote = Remotes.Get("Announce")
local notifyRemote = Remotes.Get("Notify")

function AnnounceService.Notify(player: Player, text: string, kind: Types.NoticeKind)
	local notice: Types.Notice = { Text = text, Kind = kind }
	notifyRemote:FireClient(player, notice)
end

function AnnounceService.Broadcast(text: string, color: Color3, big: boolean)
	local announcement: Types.Announcement = { Text = text, Color = color, Big = big }
	announceRemote:FireAllClients(announcement)
end

-- Rare hatches become server-wide moments.
function AnnounceService.OnHatch(player: Player, result: Types.HatchResult)
	local rarity = Rarities.Defs[result.Rarity]
	if rarity == nil then
		return
	end
	local mutation = Mutations.Defs[result.Mutation]
	local mutationAnnounces = mutation ~= nil and mutation.AlwaysAnnounce
	if rarity.Announce == "None" and not mutationAnnounces then
		return
	end
	local big = rarity.Announce == "Global" or mutationAnnounces
	local odds = if result.OneIn >= 2 then ` (1 in {Format.Number(result.OneIn)})` else ""
	local article = if string.match(result.DragonName, "^[AEIOUaeiou]") then "an" else "a"
	local text = `🌋 {player.DisplayName} hatched {article} {string.upper(result.DragonName)}!{odds}`
	AnnounceService.Broadcast(text, rarity.Color, big)
end

return AnnounceService
