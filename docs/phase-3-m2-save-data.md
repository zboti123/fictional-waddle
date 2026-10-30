# Phase 3, 2. mérföldkő: Mentés (save data)

## Mi változott
| Fájl | Változás |
|---|---|
| `ServerScriptService/Packages/ProfileStore` | **Új.** A loleris-féle ProfileStore, változtatás nélkül, Apache-2.0 licenccel (`third_party/ProfileStore/`) |
| `Services/DataService` | **Újraírva** ProfileStore-ra, ugyanazzal a publikus API-val, plusz `SaveSoon` |
| `Services/Migrations` | **Új.** Sémaverzió-migrációk másolaton futtatva, és adat-javítás (NaN, negatív, tartományon kívüli értékek) |
| `Services/DataTemplate` | Csak komment |
| `Main` | Legendary+ és Rainbow kelés után azonnali mentés |

## Hogyan védi az adatot
| Kockázat | Védelem |
|---|---|
| Két szerver egyszerre írja ugyanazt a mentést (duplikálás, felülírás) | **Session lock**: egyszerre csak egy szerver birtokolja a profilt. A másik szerveren a játékost kidobja. |
| Kilépés | `PlayerRemoving` → előbb a végső értékek (pl. kupac) beíródnak a profilba, utána `EndSession` ment |
| Szerverleállás vagy frissítés | A ProfileStore saját `BindToClose`-a megvárja az összes mentést. Előtte a mi `BindToClose`-unk beírja a végső értékeket. |
| DataStore-hiba vagy kiesés | A ProfileStore újrapróbál és autosave-el (5 percenként). A betöltést mi is újrapróbáljuk exponenciális várakozással (1, 2, 4, 8 mp). |
| Sikertelen betöltés | A játékost **kidobjuk** üzenettel, és **nem** engedjük üres adattal játszani. Így az üres adat sosem írja felül a régit. |
| Régi szerver új formátumú mentést tölt be | A migráció elutasítja, és a mentés érintetlen marad |
| Hibás vagy sérült érték | A `Sanitize` javítja és naplózza. Sárkányt vagy tojást soha nem töröl. |
| Kemény szervercrash (áramszünet, Roblox-hiba) | **Max. az utolsó mentés óta eltelt rész vész el** (≤5 perc, de a ritka kelés azonnal mentődik). Ez minden DataStore-alapú játék korlátja. A ProfileStore ~40 mp-en belül felszabadítja a zárat. |

**Őszintén:** a „soha ne vesszen el adat” a gyakorlatban így teljesül: nincs duplikálás, nincs felülírás és nincs üres mentés, kemény crashnél pedig legfeljebb néhány perc vész el. A Robux-vásárlások (4. mérföldkő) mentés-előbb logikával mennek, ott 0 a veszteség.

**Offline is telik:** a tojás-időzítők időbélyegek, így a tojás kilépés után is kel. Ez a D1-horog. A drágakő-termelés offline nem nő, az offline bevétel a retenció-mérföldkőben jön.

---

## Telepítés
A Command Barba **ebben a sorrendben**:
1. `install_4_Packages.lua`: ProfileStore (új, nagy fájl). Várt kimenet: `[Installer] Packages: 1 scripts installed`
2. `install_2_ServerScriptService.lua`: frissített szerverkód. Várt kimenet: `22 scripts installed`

Az 1-es és 3-as telepítőt nem kell újra futtatni, azok nem változtak.

**Ellenőrzés az Explorerben:** `ServerScriptService > Packages > ProfileStore` és `ServerScriptService > Services > Migrations` létezik.

---

## Tesztlista

### A) Alap mentés (Studio, F5)
- [ ] Play után az Outputban **nincs** ilyen sor: `DataStore state is NoAccess`. Ha van, a játék nincs publikálva, vagy nincs bekapcsolva az API-hozzáférés.
- [ ] Szerezz drágakövet, vegyél tojást, fejleszd a fészket, kelj ki pár sárkányt. **Jegyezd fel:** 💎, 🔥, fészekszint, sárkányszám.
- [ ] **Stop**, majd újra **Play**: minden érték ugyanaz, a sárkányok a pihenőkön vannak, és **nincs** új Starter Egg.

### B) Offline idő
- [ ] Vegyél egy Ember Egget (1 perc), és **ne** koppintsd. Stop.
- [ ] Várj 70 mp-et, Play: a tojás „TAP TO HATCH!” állapotban vár.

### C) Szerver „megölése” játék közben (2 játékos)
1. Test → Clients and Servers → **2 Players** → Start.
2. Mindkét kliensen szerezz haladást, és jegyezd fel az értékeket.
3. A **Server** ablakban nyomj **Stop**-ot (ez a szerverleállás = `BindToClose`).
4. Az Outputban (Server) várd meg, hogy hiba nélkül leálljon.
5. Indítsd újra (2 Players → Start): **mindkét** játékos értékei megvannak.

### D) Kemény kill (opcionális, a legdurvább eset)
1. F5, szerezz haladást, és **kelj ki egy Legendary+ sárkányt**. Ehhez ideiglenesen emeld meg a Legendary esélyt az `Eggs` configban; a Legendary+ kelés azonnal ment. Utána **várj 5 mp-et**.
2. Studio **bezárása Task Managerből** (End task).
3. Nyisd meg újra, és F5. Ha „We couldn't load your data” üzenetet kapsz, várj ~40 mp-et és próbáld újra (a ProfileStore ekkor veszi át a beragadt zárat).
4. ✅ A Legendary sárkány megvan. ⚠️ Ami az utolsó mentés **után** történt, az elveszhet. Ez várt viselkedés.
5. Állítsd vissza az esélyeket!

### E) Session lock (élő teszt, opcionális)
- [ ] Publish, majd lépj be a játékba **telefonon**, és közben **PC-n is** ugyanazzal a fiókkal (másik szerverre). Az elsőként belépett eszközt „Your save was opened on another server” üzenettel kidobja, és az adat nem duplázódik.

### Teszt-adat törlése (csak ha tiszta lappal akarsz kezdeni)
⚠️ **Véglegesen törli** a mentésedet. Csak fejlesztés közben használd!
Futó Play alatt, **Server** nézetben, Command Barba:
```lua
require(game.ServerScriptService.Packages.ProfileStore).New("PlayerData"):RemoveAsync("Player_1403634211")
```
Utána Stop, Play.

**Studio-tipp:** ha a Studio-tesztek ne érintsék az éles mentést, a `DataService` tetején állítsd `USE_MOCK_IN_STUDIO = true`-ra. A C) és D) teszthez viszont `false` kell.
