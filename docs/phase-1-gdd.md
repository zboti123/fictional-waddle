# Phase 1: Játéktervezési dokumentum (GDD), Hatch a Dragon 🌋

**Koncepció:** Dragon Hatchery + Eruption Rush hibrid (Phase 0 ajánlás).
**Munkacím:** *Hatch a Dragon 🌋* (a játékon belüli szöveg angol, globális közönség).
**Feltételezések:** egyedül fejlesztesz, heti ~15 óra, 8 hét a launchig, Rojo + Git, 9–15 éves célközönség, mobil az első.

Jelölések: **[T]** = tény, **[B]** = becslés / tervezési feltevés (playtesten hangolandó), **[J]** = javaslat, **[E]** = ellenőrizd a jelenlegi Roblox dokumentációban.

---

## 1. Az első 60 másodperc (FTUE)

Szabály: nincs szövegfal. Minden lépést egy pulzáló nyíl, egy kéz-ikon és egy kiemelés vezet.

| Idő | Mit lát / csinál a játékos | Visszajelzés | Funnel lépés |
|---|---|---|---|
| 0–3 mp | A saját fészkén spawnol (a csatlakozáskor kiosztott parcellán). A kamera egy izzó **Starter Egg**-re néz, ami már a fészekben van. | Halk lávazúgás, a tojás lüktet | 1 `Spawned` |
| 3–5 mp | Nagy kéz-ikon a tojáson: „TAP!” | — | — |
| 5–10 mp | **Első akció:** koppint, és a tojás inog meg reped. Minden koppintás −1 mp a 12 mp-es FTUE kelési időből. | Rázkódás, szikrák, telő gyűrű, „pop” hang | 2 `FirstTap` |
| 10–15 mp | **Kikel:** a garantált *Ember Drake* (Uncommon) kirepül. Ez rögzített ajándék, nem sorsolás. | Fényrobbanás, kis képernyőrázás, fanfár | 3 `FirstHatch` |
| 15–25 mp | A sárkány leül a pihenőre, és **+1 💎** számok kezdenek kipattogni. A nyíl a drágakőkupacra mutat: „tap to collect”. | Számpopup, a számláló tweenel | 4 `FirstCollect` |
| 25–30 mp | **Első jutalom:** a 25 💎 begyűlik, a számláló pörög, és a bolt felé egy világító ösvény mutat. | Pénztárhang | — |
| 30–40 mp | Ember Egg vásárlás (20 💎), ami automatikusan a 2. fészekhelyre kerül. | Tojás-landolás animáció | 5 `FirstEggBought` |
| 40–50 mp | A **Nest Upgrade** gomb pulzál (15 💎). Megveszi, a fészek felizzik, a bevétel nő. | „Level up” hang, +% popup | 6 `FirstUpgrade` |
| 50–60 mp | Megmordul a vulkán, és felül egy banner jelenik meg: „🌋 ERUPTION in 3:12 — wild eggs!”. Megjelenik a **célsáv:** „Hatch 3 dragons → unlock Lava Egg”. | Halk földrengés, visszaszámláló | — |

A további funnel lépések: 7 `ThreeDragonsHatched` → 8 `FirstEruptionJoined` → 9 `LavaEggUnlocked` (8-as fészekszint) → 10 `ReturnedSession2`.

**[J]** Új szervereken az első kitörés 3 perc után jön, utána 15 percenként. Így minden új játékos az első 5 percben látja a látványelemet.

---

## 2. Alaprendszerek

| Rendszer | Bemenet | Kimenet | Kapcsolódik |
|---|---|---|---|
| **Plot/Nest** | Csatlakozás | Saját parcella, fészekhelyek (3 → 12), pihenők | Incubation, Production, Social |
| **Egg Shop** | 💎/🔥, a restock időzítő | Tojás a készletben | Incubation, Economy, LiveConfig |
| **Incubation** | Tojás, koppintások (rate-limitelt), `os.time()` | Kelésre kész tojás. Offline is telik az idő. | Hatch, Retention |
| **Hatch/Roll** | Tojás + kitörés-állapot + szerencse-boostok | Sárkány (faj, ritkaság, mutáció). Minden dobás a szerveren történik. | Inventory, Announce, Index, Analytics |
| **Dragons/Inventory** | Kikelt sárkányok | Felszerelt (pihenőn) vagy tárolt sárkány, eladás, fúzió | Production, Trading (W4) |
| **Production** | Felszerelt sárkányok × szorzók | 💎/mp. Lusta számítás időbélyeggel, nincs per-frame szerverloop. | Economy, Offline |
| **Nest Upgrade** | 💎 | Fészekszint → +termelés, új tojások feloldása | Progression, Rebirth |
| **Eruption** | Szerver-ütemező + LiveConfig + vásárolt trigger | Vadtojások a központi vulkánon, mutációs ablak | Hatch, Social, Juice, Monetization |
| **Rebirth** | Fészekszint 25 + 💎 | Reset, permanens szorzó, feloldások | Progression, Leaderboard |
| **Index** | Felfedezett fajok és mutációk | Mérföldkő-jutalmak (🔥, pihenő) | Retention |
| **Economy** | Minden forrás és nyelő | Egyenlegek, naplózás | Analytics |
| **Retention** | Login, játékidő, küldetések | Jutalmak | Economy |
| **Leaderboards** | Statok | Szerver- (leaderstats) és globális (OrderedDataStore) lista | Social |
| **Social** | Barátok a szerveren, látogatás | +termelés boost, mutogatás (pedestal) | Production |
| **Announce/Juice** | Ritka kelés | Szerverszintű banner + VFX (poolozott) | Hatch |
| **Data** | Profil (session-locked) | Mentés, migrációk | Minden |
| **Monetization** | Robux | Passok és termékek (Phase 2) | Economy |
| **LiveConfig/Admin** | Admin UI, MessagingService | Esemény-kapcsolók, restock, bejelentések | Eruption, Shop |
| **Analytics** | Minden fenti | Funnel-, economy- és custom eventek | — |

---

## 3. Gazdaság

### 3.1 Valuták

| Valuta | Típus | Szerep |
|---|---|---|
| 💎 **Gems** | Fő soft | Tojások, fészekszint, fészekhelyek, rebirth |
| 🔥 **Embers** | Másodlagos soft (szűkös) | Celestial tojás, Luck Totem, fúzió, kozmetikumok |
| Robux | Prémium | Csak passok és termékek (Phase 2). **Robuxért nincs közvetlen tojás.** |

### 3.2 Források és nyelők

| | 💎 Gems | 🔥 Embers |
|---|---|---|
| **Források** | Sárkánytermelés, offline (30%, max. 4 óra), sárkányeladás, napi streak, játékidő-ajándék, küldetések, kódok | Kitörésben felszedett vadtojás-szilánk, napi és heti küldetés, streak (2. és 5. nap), index-mérföldkő, kódok, csoporttagság (egyszeri) |
| **Nyelők** | Tojások, fészekszint, extra fészekhelyek (5k / 50k / 500k / 5M …), rebirth-küszöb, pihenőhely | Celestial Egg (150), Luck Totem (40, 10 perc, saját), fúzió díja (25), fészek-kozmetikum (100–500) |

**[J]** A rebirth az összes 💎-et nullázza. Ez a fő infláció-fék.

### 3.3 Progressziós görbe (fészekszint)

- **Ár:** `cost(L) = 15 × 1.66^(L−1)` 💎
- **Tipikus bevétel [B]:** `income(L) ≈ 1.0 × 1.35^(L−1)` 💎/mp. A növekedés kb. fele a fészekszorzóból jön (`1.15^(L−1)`), a többi a jobb sárkányokból.
- **Időmodell [B]:** a játékos a 💎 50%-át költi szintre, a másik felét tojásra. Az idő **aktív játékidő**, offline bevétel nélkül. A „light spender” itt = 2× Gems pass (az ára Phase 2-ben).

| Szint | Ár (💎) | Bevétel (💎/mp) | Free (kumulált) | 2× Gems |
|---|---|---|---|---|
| 1 | 15 | 1.0 | 0 | 0 |
| 2 | 25 | 1.4 | 1 perc | <1 perc |
| 3 | 41 | 1.8 | 2 perc | 1 perc |
| 4 | 69 | 2.5 | 3 perc | 2 perc |
| 5 | 114 | 3.3 | 5 perc | 2 perc |
| 6 | 189 | 4.5 | 7 perc | 3 perc |
| 7 | 314 | 6.1 | 9 perc | 4 perc |
| 8 | 521 | 8.2 | 12 perc | 6 perc |
| 9 | 865 | 11 | 15 perc | 8 perc |
| 10 | 1 436 | 15 | 20 perc | 10 perc |
| 11 | 2 383 | 20 | 25 perc | 12 perc |
| 12 | 3 956 | 27 | 32 perc | 16 perc |
| 13 | 6 567 | 37 | 40 perc | 20 perc |
| 14 | 10 902 | 49 | 49 perc | 25 perc |
| 15 | 18 097 | 67 | 1.0 óra | 31 perc |
| 16 | 30 041 | 90 | 1.3 óra | 38 perc |
| 17 | 49 868 | 122 | 1.6 óra | 48 perc |
| 18 | 82 781 | 164 | 2.0 óra | 59 perc |
| 19 | 137 416 | 222 | 2.4 óra | 1.2 óra |
| 20 | 228 110 | 299 | 3.0 óra | 1.5 óra |
| 21 | 378 663 | 404 | 3.7 óra | 1.9 óra |
| 22 | 628 581 | 546 | 4.6 óra | 2.3 óra |
| 23 | 1 043 444 | 737 | 5.6 óra | 2.8 óra |
| 24 | 1 732 117 | 995 | 6.9 óra | 3.5 óra |
| 25 | 2 875 315 | 1 343 | 8.5 óra | 4.3 óra |
| 26 | 4 773 022 | 1 813 | 10.5 óra | 5.3 óra |
| 27 | 7 923 217 | 2 447 | 12.9 óra | 6.5 óra |
| 28 | 13 152 540 | 3 304 | 15.9 óra | 8.0 óra |
| 29 | 21 833 217 | 4 460 | 19.6 óra | 9.8 óra |
| 30 | 36 243 140 | 6 021 | 24.1 óra | 12.1 óra |

**Cél [B]:** a 10. szint az első munkamenetben (~20 perc), az első rebirth (25. szint) napi ~30 perc játékkal kb. a 7–10. napon. Ez D7 meta-célt ad.

### 3.4 Tojások és ritkasági esélyek (játékon belül, vásárlás előtt kiírva)

| Tojás | Ár | Kelési idő | Feloldás | Common | Uncommon | Rare | Epic | Legendary | Mythic |
|---|---|---|---|---|---|---|---|---|---|
| Ember Egg | 20 💎 | 1 perc | Start | 65% | 25% | 8% | 1.8% | 0.19% | 0.01% |
| Lava Egg | 2 500 💎 | 10 perc | Fészekszint 8 | 55% | 28% | 12% | 4% | 0.9% | 0.1% |
| Obsidian Egg | 150 000 💎 | 1 óra | Fészekszint 16 | 45% | 30% | 16% | 7% | 1.8% | 0.2% |
| Celestial Egg | 150 🔥 | 4 óra | Rebirth 1 | 30% | 32% | 22% | 12% | 3.5% | 0.5% |

Minden sor összege 100%. Tojásonként 6 faj van (ritkaságonként 1), a launchon tehát 24 faj.

**Alaptermelés (💎/mp):** Common 1 · Uncommon 2 · Rare 5 · Epic 12 · Legendary 30 · Mythic 100. Ezt szorozza a tojás-szint (Ember ×1, Lava ×5, Obsidian ×25, Celestial ×100), a fészekszint, a rebirth és a mutáció.

### 3.5 Mutációk (a kelés pillanatában dobva)

| Mutáció | Normál esély | Kitörés alatt | Termelés |
|---|---|---|---|
| Golden ✨ | 1% | 2% | ×3 |
| Magma 🔥 | — | 10% | ×2 |
| Rainbow 🌈 | — | 2% | ×10 |

A vírusos pillanat ebből adódik: **Mythic (Lava Egg, 0.1%) × Rainbow (2%) = 1 a 50 000-hez**, és ez szerverszintű bejelentést meg sárkány-repülést kap. Az Epic vagy jobb kelés és minden Rainbow mutáció szerverbannert kap, a Mythic és a Rainbow Legendary+ pedig cross-server bannert (MessagingService).

**Kitörés:** 2 percig tart. A központi vulkánra `játékosok × 1.5` vadtojás hull, egy játékos legfeljebb 2-t vehet fel kitörésenként, így az erősebbek nem söprik le az egészet. A vadtojás mindig a kitörés-táblával dob, és 5–15 🔥-t ad. **[J]** Ez hozza a tolongást anélkül, hogy bárki bármit elveszítene.

### 3.6 Fúzió és eladás

- **Fúzió:** 5 azonos sárkány (faj + mutáció) + 25 🔥 → 1 **Shiny** (×2.5 termelés). Ez a duplikátumok nyelője.
- **Eladás:** a sárkány 💎-ért eladható, az ára 10 percnyi termelése.

### 3.7 Rebirth

| Rebirth | Feltétel | Permanens 💎 szorzó | Feloldás |
|---|---|---|---|
| 1 | Szint 25 + 5M 💎 | ×1.5 | Celestial Egg, +1 pihenő |
| 2 | Szint 25 + 20M 💎 | ×2.0 | Rebirth-aura kozmetikum |
| 3 | Szint 25 + 80M 💎 | ×2.5 | +1 pihenő, Celestial Isle 2. rész (W8) |
| 4 | Szint 25 + 320M 💎 | ×3.0 | +1 fészekhely |
| 5 | Szint 25 + 1.28B 💎 | ×3.5 | +1 pihenő, rang-cím |

A szorzó additív: `1 + 0.5n`, a küszöb ×4 rebirth-enként. **Megmarad:** sárkányok, 🔥, index, kozmetikumok. **Nullázódik:** 💎, fészekszint, fészekhelyek.

### 3.8 Kereskedés (W4 frissítés, nem a launchon)

Infláció és visszaélés elleni szabályok **[J]**:
- Csak Rare vagy jobb sárkány cserélhető. 💎 és 🔥 **nem**, így nincs valuta-feketepiac.
- Feltétel: legalább 2 óra játékidő és `Player.AccountAge ≥ 7` nap **[T: létező property]**.
- Napi 10 csere. Egy frissen szerzett Mythic 24 óráig nem cserélhető.
- Kétlépcsős megerősítés 5 mp-es visszaszámlálással, a szerver ellenőriz, és minden csere naplózva van a visszagörgetéshez.
- **[E]** Nézd meg a Roblox kereskedésre és fiatal felhasználókra vonatkozó aktuális szabályait.

---

## 4. Közösségi rendszerek

| Rendszer | Terv |
|---|---|
| Baráti boost | Szerveren lévő barátonként +10% 💎, max. +30%. `Player:IsFriendsWith` **[T]**, csatlakozáskor cache-elve. |
| Szerveresemény | Kitörés 15 percenként, plusz **Mega Eruption** minden páros UTC órában (minden szerveren egyszerre, ez a „gyere vissza X-kor” horog). Lehet vásárolt trigger is (Phase 2). |
| Ranglisták | Szerver: leaderstats (💎, Rebirths). Globális: OrderedDataStore (összes keresett 💎, Mythic-ek száma, rebirth-ök), 5–10 percenként kötegelve frissítve. **[E]** DataStore rate limitek. |
| Mutogatás | Pedestal a fészeknél a legjobb sárkánnyal és a játékos által adott névvel (TextService-szűrve). „Visit” gomb mások fészkéhez. A kitörésnél a ritka sárkány körberepüli a mapot. |
| Meghívás | `SocialService:PromptGameInvite` **[T]**. A jutalom nem a meghívásért jár (azzal vissza lehet élni), hanem „Play with a friend”: 10 perc egy szerveren egy baráttal = 50 🔥, naponta egyszer. **[E]** Referral/meghívás-jutalom szabályai. |

---

## 5. Retenciós rendszerek

| Rendszer | Terv |
|---|---|
| Napi login streak | 7 napos, egyre jobb: 1) 5 percnyi bevétel 💎 · 2) 30 🔥 · 3) Lava Egg · 4) 10 percnyi bevétel · 5) 60 🔥 · 6) 15 perces Luck boost · 7) Obsidian Egg + heti kozmetikum. **Grace day:** hetente egy kihagyott nap nem nullázza a streaket. |
| Időzített ajándékok | Játékidő szerint 2/5/10/15/25/40/60 percnél, „Claim in 4:59” visszaszámlálóval |
| Küldetések | Napi 3 (pl. „Hatch 5 eggs”, „Join an eruption”, „Collect 10k 💎”) és heti 5. A jutalom 🔥 és tojás. |
| Offline bevétel | 30% termelés, max. 4 óra. **A tojások offline teljes sebességgel kelnek**, ez a fő D1 horog. |
| Forgó bolt | Restock 5 percenként, UTC-hez szinkronizálva (minden szerveren egyszerre). Játékosonkénti készlet restockonként: Ember ∞, Lava 3, Obsidian 1, Celestial 1 / 30 perc. A boltban látszik a „Restock in 3:12”. |
| „Gyere vissza X-kor” | Hosszú kelési idők (1–4 óra, később 8–12 óra), Mega Eruption páros UTC órákban, hétvégi Volcano Weekend (2× mutáció). **[E]** Experience Notifications („a tojásod kikelt”) elérhetősége és szabályai. |
| Csoport-jutalom | `Player:IsInGroup` **[T]** → egyszer 1 Lava Egg + 100 🔥, és permanens +5% 💎 |

---

## 6. Tartalom-ütemterv (launch + 8 heti frissítés)

Fix frissítési időpont **[J]:** **szombat 15:00 UTC**. Ez Európában délutánra, az USA-ban reggelre esik; a játékosok megtanulják.

| Hét | Frissítés | Tartalom | Csak adat? |
|---|---|---|---|
| Launch | 🌋 Hatch a Dragon | 4 sziget (Ember, Lava Ridge, Obsidian Peak, Celestial Rift), 4 tojás, 24 faj, 3 mutáció, kitörés, rebirth 1–5 | — |
| W1 | ❄️ Frost Egg (limitált, 7 nap) | 1 tojás + 6 faj, Frost mutáció, visszaszámláló a lobbyban | ✅ |
| W2 | 💎 Crystal mutáció + Mega Eruption hétvége | Új mutáció, eseménykapcsoló LiveConfigban | ✅ |
| W3 | ⛈️ Storm Coast | Új sziget + tojás + 6 faj | ✅ (+ a pálya buildje) |
| W4 | 🤝 Trading | Új rendszer (a kivétel) + index-jutalmak | ❌ |
| W5 | 🎨 Dragon Skins | 10 kozmetikus skin, index-oldal | ✅ |
| W6 | 🔁 Rebirth 6–10 | Új küszöbök, címek, aurák | ✅ |
| W7 | 🌑 Shadow Egg (limitált) + Void mutáció | 1 tojás + 6 faj + mutáció | ✅ |
| W8 | ☁️ Sky Archipelago + globális ranglista-szezon | Új sziget, Celestial II tojás, szezon-reset | ✅ (+ a pálya buildje) |

Minden héten új kód is jön a like/látogatás-mérföldkövekhez (Phase 4).

---

## Kockázatok és nyitott kérdések

- **[B]** A görbe és a ritkasági esélyek elméletiek. Az első playtest után a valós 💎/mp alapján újrahangolom őket. A konfig adatmodulban lesz, kódváltozás nem kell hozzá.
- **[E]** Ha a Robux luck boost soft-valutás tojásra hat, az egyes régiókban „paid random item”-nek minősülhet. Phase 2-ben `PolicyService` alapján kapcsoljuk.
- **[J]** A kitörés 15 perces ritmusát a soft launch session-length adata alapján hangoljuk.
