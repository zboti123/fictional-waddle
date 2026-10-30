# Phase 3, 1. mérföldkő: Core loop

**Benne van:** fészek-parcellák, Starter Egg, tojásbolt (esélyekkel), koppintós kelés, sárkányok a pihenőkön, drágakő-termelés és gyűjtés, fészekszint és extra slot, szerverszintű kitörés vadtojásokkal és mutációkkal, ritka-kelés bejelentés, mobil-first HUD.

**Nincs benne (a következő mérföldkövekben jön):**
- Mentés: az adat kilépéskor elveszik. A 2. mérföldkő a ProfileStore.
- FTUE-nyilak, Robux-termékek, hangok, poolozott VFX, retenció, admin, analytics.

---

## Mappafa (Studio-hierarchia)

```
ReplicatedStorage
└─ Shared (Folder)
   ├─ Types            (ModuleScript)
   ├─ Formulas         (ModuleScript)
   ├─ Format           (ModuleScript)
   ├─ Clock            (ModuleScript)
   ├─ Remotes          (ModuleScript)
   └─ Config (Folder)
      ├─ Eggs          (ModuleScript)
      ├─ Dragons       (ModuleScript)
      ├─ Rarities      (ModuleScript)
      ├─ Mutations     (ModuleScript)
      ├─ Economy       (ModuleScript)
      ├─ Eruption      (ModuleScript)
      └─ World         (ModuleScript)

ServerScriptService
├─ Main                (Script, az egyetlen szerver-bootstrap)
└─ Services (Folder)
   ├─ ConfigValidator, DataTemplate, DataService, RateLimiter, Validate
   ├─ StateSync, EconomyService, AnnounceService
   ├─ WorldService, PlotService
   ├─ ProductionService, DragonService, HatchRoller, HatchService
   ├─ IncubationService, EruptionService
   └─ ShopService, NestService            (mind ModuleScript)

StarterPlayer
└─ StarterPlayerScripts
   ├─ ClientMain       (LocalScript, az egyetlen kliens-bootstrap)
   └─ Client (Folder)
      ├─ UiKit, UIRoot, ClientState
      ├─ Hud, ShopPanel, NestPanel
      └─ Feedback, WorldFx                 (mind ModuleScript)
```

A repóban a `game/` mappa pontosan ezt tükrözi. Elnevezés: `.server.luau` = Script, `.client.luau` = LocalScript, a többi `.luau` = ModuleScript.

---

## Telepítés Studióba (csak Studio, Rojo nélkül)

1. **Új place:** File → New → **Baseplate**. Töröld a `Workspace.Baseplate`-et és a `Workspace.SpawnLocation`-t, mert a kód saját talajt és vulkánt épít.
2. **Fájlok letöltése** a GitHub-ról a `claude/admiring-hawking-dh9rq0` ágról, a `build/` mappából: `ReplicatedStorage.rbxmx`, `ServerScriptService.rbxmx`, `StarterPlayerScripts.rbxmx`.
3. **Beillesztés:**
   - Explorerben jobb klikk a **ReplicatedStorage**-en → *Insert from File…* → `ReplicatedStorage.rbxmx`
   - Jobb klikk a **ServerScriptService**-en → *Insert from File…* → `ServerScriptService.rbxmx`
   - Jobb klikk a **StarterPlayer → StarterPlayerScripts**-en → *Insert from File…* → `StarterPlayerScripts.rbxmx`
4. **Workspace beállítások** (Properties):
   - `StreamingEnabled` = ✅
   - `StreamingTargetRadius` = 384
   - `StreamingMinRadius` = 128
5. **Max players** = 8 (Game Settings → Places, vagy a place beállításai a Creator Dashboardon) **[E]**. 8 parcella van, a 9. játékos „server full” üzenetet kap.
6. **Gyors teszthez:** `ReplicatedStorage.Shared.Config.Eruption` → `FirstDelaySeconds = 20`. Élesítés előtt állítsd vissza 180-ra.
7. **Típusellenőrzés:** View → **Script Analysis**. Strict módban ne legyen piros hiba. Ha van, másold be nekem a pontos üzenetet. Itt nem tudtam Luau-típusellenőrzőt futtatni, csak saját szerkezeti ellenőrzést.

Ha a repóban módosítod a kódot: `python3 tools/build_rbxmx.py` újragenerálja a `build/` fájlokat.

**Saját sárkánymodell:** hozz létre egy `ReplicatedStorage.Assets.Dragons` mappát, és tegyél bele egy Modelt a sárkány Id-jével (pl. `MagmaDragon`). Ha nincs modell, színes gömb jelenik meg.

---

## Tesztlista (Studio)

### A) Egyjátékos (Play, F5)
- [ ] Indításkor az Outputban **nincs** `[ConfigValidator]` hiba.
- [ ] A saját fészkeden spawnolsz, a táblán „<neved>'s Nest” felirat.
- [ ] Az 1. slotban egy Starter Egg látszik visszaszámlálóval. Koppintásonként −1 mp, és a tojás megremeg.
- [ ] 0-nál „TAP TO HATCH!”, koppintásra **Ember Drake** kel ki, megjelenik a reveal-kártya, és a sárkány felül egy pihenőre.
- [ ] A drágakőkupacon a felirat nő („💎 N, TAP TO COLLECT”). Koppintásra „+N 💎” popup jön, és a számláló felpörög.
- [ ] EGGS → Ember Egg vásárlás: a tojás a 2. slotba kerül, a 💎 csökken. Minden kártyán látszanak az esélyek.
- [ ] Lava Egg: „🔒 Nest Lv 8”, LOCKED gomb.
- [ ] NEST → UPGRADE: nő a szint, a „Production ×” érték nő, a 💎/s nő.
- [ ] 3 tojással tele fészeknél a vásárlás „Your nest is full!” üzenetet ad, és **nem** von le pénzt.
- [ ] Kitörés (20 mp után, ha átállítottad): narancs banner, tűz a vulkánon, vadtojások hullanak. Max. 2-t vehetsz fel, utána üzenet jön. Mindegyik azonnal kikel, és 5–15 🔥-t ad.
- [ ] Egy kész tojás kitörés alatt: „🌋 HATCH NOW!” felirat.
- [ ] Mobil nézet: **Test → Device emulator**, iPhone SE / iPad / 1080p. A gombok nagyok, semmi nem lóg ki, a boltpanel görgethető.

### B) 2 játékos (Test → Clients and Servers → 2 Players → Start)
- [ ] Mindkét játékos külön parcellát kap.
- [ ] Az 1. játékos **nem** tud koppintani a 2. játékos tojására vagy kupacára (nem történik semmi).
- [ ] Kitöréskor mindkettő látja a vadtojásokat. Egy tojást csak az egyikük kaphat meg.
- [ ] Epic+ kelésnél vagy Rainbow mutációnál **mindkét** kliensen megjelenik a banner (ritka, ezért teszthez ideiglenesen állítsd az `EmberEgg` Epic esélyét magasra, a többit csökkentve 100-ra).
- [ ] Az egyik játékos kilép: a parcellája „Free Nest” lesz, a tojásai és sárkányai eltűnnek.

### C) Exploit-tesztek (Studio Command Bar, **kliens** kontextusban)
Teszt közben az Explorer tetején válts a kliens nézetre, és a Command Barba írd:
- [ ] `game.ReplicatedStorage.Remotes.BuyEgg:FireServer("LavaEgg")` 8-as szint alatt → elutasítva, nem von le pénzt.
- [ ] `game.ReplicatedStorage.Remotes.BuyEgg:FireServer(string.rep("A", 5000))` → nincs hiba, nincs hatás.
- [ ] `game.ReplicatedStorage.Remotes.BuyEgg:FireServer({})` és `(1/0)` → nincs hiba, nincs hatás.
- [ ] `for i=1,200 do game.ReplicatedStorage.Remotes.UpgradeNest:FireServer() end` → legfeljebb néhány upgrade fut le (rate limit), a 💎 nem megy negatívba.
- [ ] `game.ReplicatedStorage.Remotes.BuyEgg:FireServer("StarterEgg")` → elutasítva (nem vásárolható).

### D) Teljesítmény
- [ ] View → **MicroProfiler** / **Stats** 2 játékossal: nincs folyamatos szerver-oldali per-frame terhelés (kitörés nélkül a szerver szinte tétlen).
- [ ] Parts count a Workspace-ben < 400 teli szerverrel is.

### Ami **még nem** tesztelhető
Mentés és szerver-kill teszt (2. mérföldkő), vásárlások (4. mérföldkő).
