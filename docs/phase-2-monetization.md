# Phase 2: Monetizációs terv, Hatch a Dragon 🌋

Jelölések: **[T]** tény · **[B]** becslés · **[J]** javaslat · **[E]** ellenőrizd a jelenlegi Roblox dokumentációban.

**Alapelv:** a fizetős előny = sebesség, kényelem, kozmetikum, szerencse. A kitörésnél felvehető tojások limitjét (2/fő) **semmilyen fizetős termék nem növeli**, így a versengő részben nincs pay-to-win.

---

## 0. Kritikus szabálypont: paid random items

- **[T/E]** A Roblox „paid random item”-nek tekinti a Robuxért **vagy Robuxért vehető játékon belüli valutáért** szerzett véletlenszerű tárgyat. A 💎 Robuxért is vehető (gem packok), így **a tojásrendszer egésze paid random itemnek számít**. Ellenőrizd a pontos megfogalmazást a jelenlegi irányelvekben.
- **Ebből következik [J]:**
  1. Az esélyek **mindig** láthatók a tojás UI-ban, a szerencse-boostokkal **módosított** esélyekkel együtt.
  2. Ahol `PolicyService:GetPolicyInfoForPlayerAsync().ArePaidRandomItemsRestricted == true`, ott **a játékos a véletlenhez kapcsolódó Robux-termékeket nem látja és nem veheti meg**: gem pack, luck, instant hatch, instant restock, eruption trigger, Lucky Nest pass. A tojásokat ott csak megkeresett 💎-ért veheti, és **minden tojásvásárlás megjelöli a játékos 💎-ét**, ld. lent.
  3. **Egyszerűbb, biztonságos megoldás [J]:** korlátozott régióban a játékos sosem tud Robuxért 💎-et szerezni, így minden 💎-je „earned”. Ehhez nem kell külön „paid gems” könyvelés.
  4. A 🔥 Embers **soha nem vehető Robuxért** (a Celestial tojás ára).
  5. **A Robux-prompt mindig a szerverről indul.** A kliens csak szándékot küld, a szerver ellenőrzi a policyt, és csak utána hívja a `PromptProductPurchase`-t. Egy már kifizetett vásárlást a `ProcessReceipt` **mindig** jóváír, akkor is, ha közben a policy megváltozott.

---

## 1. Game Passok (egyszeri, permanens)

| Pass | Ár (R$) | Mit ad | Miért ennyi |
|---|---|---|---|
| ⚡ Quick Hatch | 49 | A tojás-koppintás −2 mp (alapból −1) | Belépő impulzusvásárlás. A legnehezebb lépés az *első* fizetés. |
| 🎒 Dragon Storage+ | 99 | +60 tárhely, auto-sell Common kapcsoló | Akkor kell, amikor betelik a tárhely (természetes súrlódási pont) |
| 💎 2× Gems | 249 | ×2 💎 termelés | A fő érték-pass. A sim-műfajban ez a referencia-ár sáv **[B]**. |
| 👑 VIP | 299 | +10% 💎, offline limit 4 → 8 óra, VIP lounge a vulkán peremén, chat-tag, arany névtábla | Státusz + kényelem, a többiek láthatják |
| 🍀 Lucky Nest | 399 | ×1.25 súly a Rare+ ritkaságokra (újranormalizálva, az UI-ban kiírva) | **Policy-kapus.** Korlátozott régióban nem jelenik meg. |
| 🪺 +3 Nest Slots | 499 | +3 fészekhely, +1 pihenő | Hosszú távú termelés, a 3–4. hét körüli elköteleződéshez |
| 🤖 Dragon Keeper | 799 | Auto-collect + a tárolt tojásokat automatikusan lerakja az üres helyre | Bálna/grinder szint. Kényelem, nem erő. |

A létra 49 → 799 R$. Az olcsó belépő után a középső sávban (249–499) van a fő érték, a teteje pedig a kényelem a sokat játszóknak.

---

## 2. Developer Productok (ismételhető)

### 2.1 💎 Gem packok (bevétel-arányos, policy-kapus)
A mennyiség = a játékos **aktuális** 💎/mp bevétele × perc, minimum 500 💎. Így a pack értéke a 30. szinten sem lesz nevetséges.

| Ár (R$) | Bevétel-percek | Bónusz a 49 R$-hez képest |
|---|---|---|
| 49 | 20 perc | — |
| 99 | 45 perc | ~+11% |
| 199 | 100 perc | ~+23% |
| 499 | 280 perc | ~+37% |
| 999 | 600 perc | ~+47% |

### 2.2 Időzítő-, szerencse- és eseménytermékek

| Termék | Ár (R$) | Hatás | Policy-kapus? |
|---|---|---|---|
| ⏩ Instant Hatch | 19 / 49 / 99 | Azonnal kikelti a tojást (hátralévő idő: <10 perc / <1 óra / <4 óra) | Igen |
| 🔄 Instant Restock (saját) | 29 | Feltölti a saját bolti készletet | Igen |
| 🍀 Luck Boost 15 perc | 99 | ×2 Rare+ súly magadnak | Igen |
| 🌟 **Server Luck** 15 perc | 299 | ×1.5 Rare+ súly **mindenkinek** a szerveren. Banner: „Alex activated SERVER LUCK!” | Igen |
| 🌋 **Trigger Eruption** | 199 | Azonnali kitörés a szerveren mindenkinek. Szerverenként 10 perc cooldown, a vásárlások sorba állnak. | Igen |
| 🎁 **Starter Pack** (egyszeri) | 99 | Fix tartalom, **nincs benne véletlen**: *Baby Lava Dragon* (Rare, Lava-szint) + 30 perc 2× 💎 + 200 🔥. Érték-cél ≥5× az árhoz képest **[B]**. | Nem (fix tartalom) |

- **Revive/second chance:** a játékban nincs bukás-állapot, ezért **nincs ilyen termék**. Kitalálni sem fogok, mert fölösleges nyomás lenne.
- **A Server Luck és a Trigger Eruption marketing is:** mindenki látja, ki vette, és mindenki profitál belőle.

---

## 3. Egyéb bevétel

| Forrás | Terv | Megjegyzés |
|---|---|---|
| Premium Payouts | Premium tagnak +10% 💎, napi Premium-láda (50 🔥), Premium jelvény. Időt jutalmaz, nem pénzt. | **[E]** A kifizetési modell és a Premium-előnyök szabályai. A bevétel a Premium-tagok játékidejétől függ **[T/E]**. |
| Experience Subscription | „Dragon Keeper Club” havidíjas: napi 50 🔥, havi exkluzív skin, +2 óra offline limit | **[J]** Csak a W6 után, ha a D7 retenció jó. **[E]** Elérhetőség, ársávok, jogosultság. |
| Rewarded video ads | Opt-in gomb az offline-bevétel begyűjtésénél: „Watch ad → ×2 offline”, napi max. 3 | **[E]** Elérhetőség, korhatár és régiók. Ha nem elérhető, a gomb nem jelenik meg. |
| Privát szerver | 99 R$/hó | A grinderek és a tartalomgyártók miatt fontos. A YouTubereknek ingyen adunk (Phase 4). |
| UGC (később) | Achievement-hez kötött UGC kiegészítő (pl. Rainbow-sárkány vállpet) | **[E]** UGC program jogosultság. Legkorábban a W8 után. |

---

## 4. Elhelyezési térkép

**Szabály:** munkamenetenként **max. 1 nem a játékos által indított popup**. Ez a Starter Pack, egyszer, az első Rare+ kelés után. Bezárható, **nincs hamis visszaszámláló**, és utána is mindig elérhető a boltban.

| Ajánlat | Hol | Mikor | Kéretlen popup? |
|---|---|---|---|
| Starter Pack | Középre ugró kártya, utána a Store fül teteje | Az első Rare+ kelés után (pozitív pillanat), játékosonként egyszer | **Igen (az egyetlen)** |
| Gem packok | „+” gomb a 💎 számláló mellett. Ha nincs elég 💎, a bolti gomb mellett egy „Get more” link. | A játékos kattint | Nem |
| Instant Hatch | A tojás időzítő-buborékában „⚡ 49” gomb | Ha a játékos a tojásra koppint | Nem |
| Luck Boost / Lucky Nest | A tojásbolt panel alján, a boostolt esélyek előnézetével | A bolt megnyitásakor (nem popup) | Nem |
| Server Luck / Trigger Eruption | Kioszk a vulkán tetején + a „Next eruption 8:20” banneren egy kis gomb | Mindig ott van | Nem |
| Dragon Storage+ | A „Storage full” értesítésben egy gomb | Amikor betelik a tárhely (valós súrlódás) | Nem (inline) |
| +3 Nest Slots | Az üres, lakatos fészekhelyre koppintva | A játékos kattint | Nem |
| VIP | A VIP lounge ajtaja a mapon + a Store | Mindig | Nem |
| Dragon Keeper | Store + a gyűjtés gomb mellett egy kis 🤖 ikon | 20+ perc játékidő után jelenik meg | Nem |
| Rewarded ad | Az offline-bevétel begyűjtő kártyáján | Visszatéréskor | Nem |

**Visszajelzés a promptra [J]:** a „near-miss után ajánlj” mintát **nem** javaslom. Gyerekeknél a mesterséges near-miss kijelzés („majdnem Legendary lett!”) szerencsejáték-pszichológia. Ez etikailag és policy-szempontból is kockázatos. Helyette valódi pozitív pillanatokban ajánlunk (első ritka kelés, betelt tárhely).

### Tiltott sötét minták (kódszinten is betartva)
- Nincs hamis időkorlát, és nincs „csak most” ár, ami nem igaz.
- Az ár mindig R$-ben és egyértelműen látszik, nincs köztes „gyémánt-a-gyémántért” trükk Robux-termékeknél.
- Nincs „mindent elveszítesz” nyomás, és nincs vásárlásra kényszerítő blokkolás.
- Az esélyek a vásárlás **előtt** látszanak, a boostok hatásával együtt.

---

## 5. `ProcessReceipt`: idempotens, mentés-előbb

Ez a modul a Phase 3 fájlstruktúrájába kerül (`src/server/Services/ReceiptService.luau`), ProfileStore-ral.

**Mi a lényeg:**
1. A jóváírás és a `PurchaseId` **ugyanabba** a `profile.Data`-ba kerül, így egyetlen mentésben, atomikusan íródnak ki.
2. `PurchaseGranted` csak akkor megy vissza, ha a `PurchaseId` **már a lementett adatban** (`LastSavedData`) van.
3. Ha a játékos kilépett, vagy a mentés nem sikerült időben, `NotProcessedYet` a válasz. A Roblox később újrapróbálja, és mivel a `PurchaseId` már a profilban van, **nem lesz dupla jóváírás**.
4. A szerveren kívüli mellékhatás (pl. szerverszintű kitörés) csak az első, ténylegesen lementett jóváírás után fut le.

**[E]** A ProfileStore API-t (`LastSavedData`, `Save`, `IsActive`) ellenőrizd a ténylegesen telepített verzió README-jében.

```lua
--!strict
-- ReceiptService
-- Idempotent developer-product processing on top of ProfileStore.
-- A grant and its PurchaseId are written into the same profile.Data table,
-- so they are persisted atomically by the same save.

local MarketplaceService = game:GetService("MarketplaceService")
local Players = game:GetService("Players")

local PURCHASE_HISTORY_SIZE = 100
local PROFILE_WAIT_SECONDS = 30
local SAVE_WAIT_SECONDS = 30
local POLL_INTERVAL = 0.2

export type ReceiptInfo = {
	PlayerId: number,
	PlaceIdWherePurchased: number,
	PurchaseId: string,
	ProductId: number,
	CurrencySpent: number,
	CurrencyType: Enum.CurrencyType,
}

-- Minimal structural type for the ProfileStore profile fields this module uses.
export type Profile = {
	Data: { [string]: any },
	LastSavedData: { [string]: any }?,
	IsActive: (self: Profile) -> boolean,
	Save: (self: Profile) -> (),
}

-- Grant must validate first and only then mutate `data`.
-- Return true when the grant was applied, false to refuse (receipt retried later).
export type GrantFn = (player: Player, data: { [string]: any }, receipt: ReceiptInfo) -> boolean

-- Optional side effect outside player data (e.g. start a server-wide eruption).
-- Runs once, only after the grant is confirmed saved.
export type AfterGrantFn = (player: Player, receipt: ReceiptInfo) -> ()

export type ProductHandler = {
	Grant: GrantFn,
	AfterGrant: AfterGrantFn?,
}

local ReceiptService = {}

local getProfile: ((Player) -> Profile?)? = nil
local handlers: { [number]: ProductHandler } = {}

local function waitForProfile(player: Player): Profile?
	local getter = getProfile
	if getter == nil then
		return nil
	end
	local deadline = os.clock() + PROFILE_WAIT_SECONDS
	while player.Parent == Players and os.clock() < deadline do
		local profile = getter(player)
		if profile ~= nil then
			return profile
		end
		task.wait(POLL_INTERVAL)
	end
	return nil
end

local function getHistory(data: { [string]: any }): { string }
	local history = data.PurchaseIds
	if typeof(history) ~= "table" then
		history = {}
		data.PurchaseIds = history
	end
	return history :: { string }
end

local function isSaved(profile: Profile, purchaseId: string): boolean
	local saved = profile.LastSavedData
	if saved == nil then
		return false
	end
	local savedHistory = saved.PurchaseIds
	return typeof(savedHistory) == "table" and table.find(savedHistory :: { string }, purchaseId) ~= nil
end

local function processReceipt(receipt: ReceiptInfo): Enum.ProductPurchaseDecision
	local handler = handlers[receipt.ProductId]
	if handler == nil then
		warn(`[ReceiptService] No handler for product {receipt.ProductId}`)
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	-- Player not in this server: Roblox retries the receipt when they join again.
	local player = Players:GetPlayerByUserId(receipt.PlayerId)
	if player == nil then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local profile = waitForProfile(player)
	if profile == nil or not profile:IsActive() then
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	local history = getHistory(profile.Data)
	local newlyGranted = false

	if table.find(history, receipt.PurchaseId) == nil then
		local ok, result = pcall(handler.Grant, player, profile.Data, receipt)
		if not ok then
			warn(`[ReceiptService] Grant failed for {receipt.PurchaseId}: {result}`)
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		if result ~= true then
			return Enum.ProductPurchaseDecision.NotProcessedYet
		end
		table.insert(history, receipt.PurchaseId)
		while #history > PURCHASE_HISTORY_SIZE do
			table.remove(history, 1)
		end
		newlyGranted = true
	end

	-- Only report success once the PurchaseId is in persisted data.
	if not isSaved(profile, receipt.PurchaseId) then
		profile:Save()
		local deadline = os.clock() + SAVE_WAIT_SECONDS
		while profile:IsActive() and os.clock() < deadline and not isSaved(profile, receipt.PurchaseId) do
			task.wait(POLL_INTERVAL)
		end
	end

	if not isSaved(profile, receipt.PurchaseId) then
		-- Grant stays in profile.Data and is written by the next save or session end;
		-- the retry then sees the PurchaseId and does not grant twice.
		return Enum.ProductPurchaseDecision.NotProcessedYet
	end

	if newlyGranted and handler.AfterGrant ~= nil then
		task.spawn(handler.AfterGrant, player, receipt)
	end
	return Enum.ProductPurchaseDecision.PurchaseGranted
end

function ReceiptService.Init(profileGetter: (Player) -> Profile?, productHandlers: { [number]: ProductHandler })
	getProfile = profileGetter
	handlers = productHandlers
	MarketplaceService.ProcessReceipt = processReceipt
end

return ReceiptService
```

### Policy-kapu (prompt előtt, szerveroldalon)

```lua
--!strict
-- MonetizationPolicy
-- Fails closed: if the policy lookup errors, the player is treated as restricted
-- and the lookup is retried on the next call instead of being cached.

local Players = game:GetService("Players")
local PolicyService = game:GetService("PolicyService")

local MonetizationPolicy = {}

local restrictedCache: { [Player]: boolean } = {}

function MonetizationPolicy.ArePaidRandomItemsRestricted(player: Player): boolean
	local cached = restrictedCache[player]
	if cached ~= nil then
		return cached
	end
	local ok, info = pcall(PolicyService.GetPolicyInfoForPlayerAsync, PolicyService, player)
	if not ok or typeof(info) ~= "table" then
		return true
	end
	local restricted = (info :: any).ArePaidRandomItemsRestricted == true
	restrictedCache[player] = restricted
	return restricted
end

Players.PlayerRemoving:Connect(function(player: Player)
	restrictedCache[player] = nil
end)

return MonetizationPolicy
```

---

## 6. Bevételi becslés **[B]** (nem garancia)

**Feltevések:**
- Napi fizető-konverzió 0.5–2% a DAU-ból (középérték 1%).
- ARPPU fizető naponként 150–400 R$ (középérték 250 R$).
- A fejlesztőhöz a Robux-költés ~70%-a jut **[E]**.
- DevEx árfolyam ~0.0038 USD/R$ **[E: aktuális DevEx ráta]**.

| Mutató | Alacsony | Közép | Magas |
|---|---|---|---|
| ARPDAU (R$, bruttó elköltve) | 0.75 | 2.5 | 8 |
| ARPDAU (R$, fejlesztőnek) | 0.53 | 1.75 | 5.6 |
| ARPDAU (USD, DevEx után) | ~$0.002 | ~$0.0067 | ~$0.021 |
| 1 000 DAU, havi USD | ~$60 | ~$200 | ~$640 |
| 10 000 DAU, havi USD | ~$600 | ~$2 000 | ~$6 400 |

Ebben nincsenek benne a Premium Payouts és a privát szerverek. **Következtetés:** a bevételt a DAU skálázza, nem a monetizáció finomhangolása. Ezért retenció > viralitás > monetizáció.
