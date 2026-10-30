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

## 1. Game Passok (egyszeri, permanens), v2: ambiciózus létra

**Logika [J]:** egy olcsó belépő marad (az *első* fizetés a legnehezebb konverzió). A fő értéket a 399–699 sávba toltam, és két prémium „horgonyt” tettem a tetejére. A horgony a középső passokat olcsónak mutatja, és megfogja a sokat költőket.

| Pass | Ár (R$) | Mit ad | Szerep |
|---|---|---|---|
| ⚡ Quick Hatch | 49 | Tojás-koppintás −2 mp (alap −1) | **Belépő**: az első vásárlás |
| 🎒 Dragon Storage+ | 149 | +60 tárhely, auto-sell Common | Súrlódás-oldó (betelt tárhely) |
| 👑 VIP | 399 | +15% 💎, offline limit 4 → 8 óra, VIP lounge, chat-tag, arany névtábla | Státusz, a többiek látják |
| 💎 2× Gems | 449 | ×2 💎 termelés | **Fő érték-pass** |
| 🍀 Lucky Nest | 599 | ×1.25 súly a Rare+ ritkaságokra (újranormalizálva, kiírva) | Policy-kapus |
| 🪺 +3 Nest Slots | 699 | +3 fészekhely, +1 pihenő | Hosszú távú termelés |
| 🤖 Dragon Keeper | 999 | Auto-collect + auto-lerakás a tárolt tojásokból | Kényelem a grindereknek |
| 🌈 **Mythic Hunter** | 1 999 | ×1.5 Mythic-súly, Rainbow-aura a sárkányaidon, egyedi kitörés-hang a bejelentésnél | **Horgony 1**: státusz + szerencse, policy-kapus |
| 🐉 **Dragon Lord** | 3 499 | Minden fenti pass hatása + egyedi „Dragon Lord” cím. A már megvett passok árát a bolt **kiírja**: „you already own 3 of 8 perks”. | **Horgony 2**: bundle a bálnáknak, policy-kapus elemekkel régiónként csökkentve |

**Kockázat [B]:** a magasabb árak 15–30%-kal csökkenthetik a pass-konverziót, de az ARPPU-t várhatóan jobban emelik. **A 2× Gems és a VIP árát A/B-teszteld** (449 vs 299, 399 vs 249). Két szerver-cohort, 2 hét, a fizetőnkénti bevétel alapján dönts. Az A/B-teszt keretét a Phase 3 analytics mérföldkövében építjük be.

---

## 2. Developer Productok (ismételhető), v2

### 2.1 💎 Gem packok (bevétel-arányos, policy-kapus)
A mennyiség = a játékos **aktuális** 💎/mp bevétele × perc, minimum 500 💎.

| Ár (R$) | Bevétel-percek | Bónusz a 49 R$-hez képest | Címke |
|---|---|---|---|
| 49 | 20 perc | — | |
| 149 | 70 perc | ~+15% | |
| 399 | 210 perc | ~+29% | **Most popular** (valóban a leggyakoribb? Az analytics alapján frissítjük, addig nincs címke) |
| 999 | 600 perc | ~+47% | |
| 2 499 | 1 800 perc | ~+76% | **Best value** (matematikailag igaz) |

**Szabály:** a „Most popular” címke csak valós adat alapján kerülhet ki. Hamis címke sötét minta.

### 2.2 Időzítő-, szerencse- és eseménytermékek

| Termék | Ár (R$) | Hatás | Policy-kapus? |
|---|---|---|---|
| ⏩ Instant Hatch | 25 / 59 / 129 / 249 | Azonnali kelés (hátralévő idő: <10 perc / <1 óra / <4 óra / <12 óra) | Igen |
| ⏩ Hatch All | a fenti árak összege −20% | Az összes tojás azonnal | Igen |
| 🔄 Instant Restock (saját) | 49 | Feltölti a saját bolti készletet | Igen |
| 🍀 Luck Boost | 99 (15 perc ×2) / 249 (1 óra ×2) / 599 (3 óra ×3) | Saját Rare+ súly | Igen |
| 🌟 **Server Luck** | 399 (15 perc ×1.5) / 999 (30 perc ×3) | **Mindenkinek** a szerveren, név szerinti bannerrel | Igen |
| 🌋 **Trigger Eruption** | 249 | Azonnali kitörés mindenkinek (szerver-cooldown 10 perc, sorba áll) | Igen |
| 🌋💥 **Mega Eruption** | 999 | Dupla vadtojás, ×2 Rainbow-esély mindenkinek, 3 perc | Igen |
| 🎁 **Starter Pack** (egyszeri) | 99 | Fix: *Baby Lava Dragon* (Rare) + 30 perc 2× 💎 + 200 🔥. Érték-cél ≥5× **[B]** | Nem (fix tartalom) |
| 🎁 **Rebirth Pack** (egyszeri) | 399 | Fix: *Obsidian Guardian* (Epic) + 1 óra 2× 💎 + 500 🔥. Az első rebirth után jelenik meg. | Nem (fix tartalom) |

---

## 3. Egyéb bevétel

| Forrás | Terv | Megjegyzés |
|---|---|---|
| Premium Payouts | Premium tagnak +10% 💎, napi Premium-láda (50 🔥), Premium-jelvény | **[E]** A kifizetési modell és a Premium-előnyök szabályai |
| Experience Subscription | „Dragon Keeper Club” havidíjas: napi 75 🔥, havi exkluzív skin, +2 óra offline limit, havi 1 ingyenes Server Luck | **[J]** A W6 után. **[E]** Elérhetőség, ársávok. |
| Rewarded video ads | Opt-in: „Watch ad → ×2 offline”, napi max. 3 | **[E]** Elérhetőség, korhatár |
| Privát szerver | 149 R$/hó | A tartalomgyártók ingyen kapják (Phase 4) |
| UGC (később) | Achievement-hez kötött vállpet | **[E]** UGC program |

---

## 4. Elhelyezési térkép, v2 (konverzió-optimalizált)

**Szabály változatlan:** munkamenetenként **max. 1 kéretlen popup**. A többi ajánlat **kontextuális, inline**, és mindig a játékos mozdulatára vagy egy valós játékhelyzetre reagál.

| Ajánlat | Hol | Kiváltó pillanat | Miért konvertál |
|---|---|---|---|
| Starter Pack | Középső kártya (az egyetlen popup), utána a Store teteje | Az első Rare+ kelés után | Érzelmi csúcs, magas érték |
| Rebirth Pack | Inline kártya a rebirth-képernyőn | Az első rebirth után | Új körnél újra kell építkezni, itt nő a fizetési hajlandóság |
| Gem pack, **hiány-alapú** | „Get more” gomb a megvehetetlen tételnél, **a hiányt fedező legkisebb packot** ajánlja | A játékos rányom egy megfizethetetlen tojásra vagy fejlesztésre | Konkrét cél, pontos összeg |
| Instant Hatch | „⚡” gomb az időzítő-buborékban, + **„Hatch now for the eruption bonus!”**, ha kitörés van és a tojás >1 percre van | A játékos a tojásra koppint, vagy kitörés zajlik | Valós időkényszer (a kitörés tényleg véget ér) |
| Luck / Lucky Nest / Mythic Hunter | A tojásbolt alján, **a boostolt esélyek élő előnézetével** | Bolt-megnyitás | Átlátható, a fizetés hatása látszik |
| Server Luck / Trigger / Mega Eruption | Vulkán-kioszk + a kitörés-visszaszámláló banner gombja + a kitörés vége után 10 mp-ig: „Start the next one for everyone” | A kitörés vége (közösségi érzelmi csúcs) | Közösségi hős-szerep, mindenki látja |
| „Server Heroes” tábla | Fizikai tábla a vulkán mellett a mai Server Luck/Eruption vásárlók neveivel | Folyamatos | Társas bizonyíték (social proof), ingyenes marketing |
| Dragon Storage+ | Inline gomb a „Storage full” értesítésben | Betelt tárhely | Valódi súrlódás |
| +3 Nest Slots | Az üres, lakatos fészekhelyre koppintva | Mind a 7 gem-slot megvan | Természetes plafon |
| VIP | A lounge ajtaja a mapon; a VIP-ek arany névtáblát kapnak | Folyamatos | Látható státusz |
| 2× Gems | A 💎/mp kijelző mellett egy kis „×2?” jelvény (a játékos rákoppint) | Folyamatos | A fő számhoz kötve |
| Dragon Keeper | A gyűjtés gombnál egy 🤖 ikon | 20+ perc játékidő után | A grinder fájdalompontja |
| Dragon Lord | A Store „Passes” fül teteje, a már megvett perkek kiírásával | Legalább 2 pass megvétele után kiemelve | Horgony + bundle |
| Rewarded ad | Az offline-bevétel kártyáján | Visszatéréskor | Ingyenes a játékosnak |

**Visszajelzés a promptra [J]:** a „near-miss után ajánlj” mintát **nem** építem be. Gyerekeknél a mesterséges „majdnem Legendary lett!” kijelzés szerencsejáték-pszichológia, ami policy- és hírnév-kockázat. A fenti valós pillanatok ugyanezt az érzelmi csúcsot fogják meg, manipuláció nélkül.

### Tiltott sötét minták (kódszinten is betartva)
- Nincs hamis időkorlát, „csak most” ár vagy hamis „Most popular” címke.
- Az ár mindig R$-ben látszik, köztes valuta-trükk nélkül.
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

## 6. Bevételi becslés **[B]** (nem garancia), v2 árakkal

**Feltevések:**
- Napi fizető-konverzió 0.4–1.8% (középérték 0.9%; a magasabb árak miatt kicsit alacsonyabb).
- ARPPU fizető naponként 200–600 R$ (középérték 350 R$).
- A fejlesztőhöz a Robux-költés ~70%-a jut **[E]**.
- DevEx árfolyam ~0.0038 USD/R$ **[E]**.

| Mutató | Alacsony | Közép | Magas |
|---|---|---|---|
| ARPDAU (R$, bruttó) | 0.8 | 3.15 | 10.8 |
| ARPDAU (USD, DevEx után) | ~$0.0021 | ~$0.0084 | ~$0.029 |
| 1 000 DAU, havi USD | ~$65 | ~$250 | ~$860 |
| 10 000 DAU, havi USD | ~$650 | ~$2 500 | ~$8 600 |

A v1-hez képest a középérték ~+25% **[B]**. Ez csak akkor igaz, ha a konverzió nem esik a feltételezettnél jobban, ezt az A/B-teszt dönti el. Ebben nincsenek benne a Premium Payouts, a privát szerverek és az előfizetés. **Következtetés változatlan:** a bevételt a DAU skálázza, ezért a retenció az első.
