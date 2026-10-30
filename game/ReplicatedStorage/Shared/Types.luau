--!strict
-- Shared type definitions used by config modules, server services and client UI.

export type Currency = "Gems" | "Embers"
export type AnnounceLevel = "None" | "Server" | "Global"
export type NoticeKind = "Info" | "Success" | "Error"

export type RarityDef = {
	Id: string,
	DisplayName: string,
	Order: number,
	Color: Color3,
	BaseProduction: number,
	Announce: AnnounceLevel,
}

export type MutationDef = {
	Id: string,
	DisplayName: string,
	Multiplier: number,
	Color: Color3?,
	AlwaysAnnounce: boolean,
}

export type FixedResult = {
	Species: string,
	Mutation: string,
}

export type EggDef = {
	Id: string,
	DisplayName: string,
	Currency: Currency,
	Price: number,
	HatchSeconds: number,
	MaxTapReduction: number,
	UnlockNestLevel: number,
	UnlockRebirths: number,
	TierMultiplier: number,
	Color: Color3,
	Odds: { [string]: number },
	Species: { [string]: string },
	Fixed: FixedResult?,
	Purchasable: boolean,
}

export type DragonDef = {
	Id: string,
	DisplayName: string,
	Rarity: string,
	EggId: string,
	Color: Color3,
}

export type DragonRecord = {
	Species: string,
	Mutation: string,
	ObtainedAt: number,
}

export type IncubatingEgg = {
	EggId: string,
	StartedAt: number,
	Duration: number,
	Reduced: number,
}

export type PlayerStats = {
	EggsHatched: number,
	GemsEarned: number,
	MythicsHatched: number,
	WildEggsClaimed: number,
}

export type FtueState = {
	StarterGiven: boolean,
}

export type PlayerData = {
	SchemaVersion: number,
	Gems: number,
	Embers: number,
	NestLevel: number,
	Rebirths: number,
	NestSlots: number,
	Incubating: { [string]: IncubatingEgg },
	Dragons: { [string]: DragonRecord },
	NextDragonId: number,
	PileGems: number,
	PileUpdatedAt: number,
	Stats: PlayerStats,
	Ftue: FtueState,
	PurchaseIds: { string },
}

-- Everything the client UI needs, sent by the server after every change.
export type Snapshot = {
	Gems: number,
	Embers: number,
	NestLevel: number,
	NestMaxLevel: number,
	NextNestCost: number?,
	NestSlots: number,
	MaxGemSlots: number,
	NextSlotCost: number?,
	Rate: number,
	DragonCount: number,
	MaxDragons: number,
	Perches: number,
	Rebirths: number,
}

export type HatchResult = {
	Species: string,
	DragonName: string,
	Rarity: string,
	Mutation: string,
	Source: string,
	EmbersAwarded: number,
	OneIn: number,
}

export type Announcement = {
	Text: string,
	Color: Color3,
	Big: boolean,
}

export type Notice = {
	Text: string,
	Kind: NoticeKind,
}

export type Collected = {
	Amount: number,
}

return {}
