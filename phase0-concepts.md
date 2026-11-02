# 0. fázis – Koncepcióválasztás

Feltételezések (amíg nem adsz meg mást): 1 fejlesztő, közepes Luau-tudás, 8 hét az MVP-ig, 0 hirdetési keret, Rojo + Git, célközönség 9–15 év, mobil elsőként.

---

## A) „Szörnykeltető” (Monster Hatchery)

**Egy mondatban:** Tojásokat keltetsz a saját szigeteden, a kikelt szörnyek pénzt termelnek, és a többi játékos ellophatja az őrizetlen tojásaidat.

- **Bélyegkép:** egy repedő, izzó mitikus tojás egy vigyorgó gyerek-avatar kezében, a háttérben egy lopakodó játékos.
- **30 mp-es hurok:** pénzből tojást veszel, lerakod a fészekbe, a tojás valós időben kel ki, a szörny pénzt termel.
- **15 perces hurok:** jobb tojások a forgó boltban (5 percenként frissül), fészekbővítés, ellopsz egy tojást valakitől, vagy megvéded a sajátodat.
- **Többnapos hurok:** újjászületés (rebirth) állandó szorzóval, szörnygyűjtemény (index), heti limitált tojások, ritka mutációk.
- **Visszatérés:** D1-en kikeltek a tegnapi tojások (offline keltetés), és vár a napi jutalom. D7-en heti limitált tojás és a gyűjtemény kitöltése. D30-on rebirth-szintek, ranglista és cserekereskedés.
- **Virális pillanat:** szerverszintű bejelentés: „X kikeltett egy MITIKUS szörnyet!”. Ellopni egy mitikus tojást az utolsó másodpercben ideális TikTok-klip.
- **Monetizáció:** 2× pénz, gyorsabb keltetés, plusz fészekhelyek, 10 perces pajzs (lopás ellen), szerencse-boost, szerverszintű „szerencsevihar” esemény, amit egy vásárló indít el mindenkinek.
- **MVP terjedelme:** kb. 6–8 hét egy főnek (főleg adatvezérelt tartalom).
- **Kockázat:** a lopásos mechanika közel áll a jelenlegi slágerekhez. A különbséget a keltetés/mutáció-rendszer és a korlátozott lopás adja (pajzs, visszalopás, csak az értéked egy kis részét lehet elvinni), hogy az ingyenes játékosok ne frusztrálódjanak.

## B) „Viharvadászok” (Storm Chasers)

**Egy mondatban:** 10 percenként szerverszintű vihar söpör végig a térképen, és hálóval kell befognod a viharlényeket meg a repülő zsákmányt, mielőtt elszállnak.

- **Bélyegkép:** egy hatalmas lila tornádó, benne egy aranyló lény, alatta egy játékos hálóval.
- **30 mp-es hurok:** üldözöd a vihart, elkapod a zsákmányt, és eladod vagy kiállítod.
- **15 perces hurok:** két vihar között fejleszted a járművet, a hálót és a bázist. Ritka „mitikus vihar” jön visszaszámlálással.
- **Többnapos hurok:** új viharfajták és régiók, lénygyűjtemény, rebirth.
- **Visszatérés:** az időjárás-naptár (a „ma este 8-kor jön a jégvihar” típusú hírek), a gyűjtemény és a heti új viharok.
- **Virális pillanat:** a tornádó látványa és 20 játékos versenyfutása ugyanazért a mitikus lényért.
- **Monetizáció:** gyorsabb jármű, nagyobb háló, „vihar idézése” (Developer Product, mindenkinek látható), VIP-bázis, 2× pénz.
- **MVP terjedelme:** kb. 9–12 hét (fizika, VFX és járművek miatt nehezebb).
- **Kockázat:** gyenge mobilokon a teljesítmény, és egy főnek nagyobb a technikai teher.

## C) „Kincsásó part” (Treasure Beach)

**Egy mondatban:** Egy közös tengerparton ásol, az apály-dagály ciklus új kincseket hoz felszínre, a leleteidet pedig a múzeumodban állítod ki.

- **Bélyegkép:** egy ásó, egy gödörből kiáradó aranyfény és egy döbbent avatar.
- **30 mp-es hurok:** ásol, találsz valamit, és eladod vagy kiállítod.
- **15 perces hurok:** jobb ásók, mélyebb rétegek, és dagály után új zsákmány.
- **Többnapos hurok:** a múzeum kitöltése, ritka leletkészletek, rebirth.
- **Visszatérés:** dagálynaptár, napi jutalom és a gyűjtemény.
- **Virális pillanat:** egy legendás tárgy kiásása, elég gyenge.
- **Monetizáció:** jobb ásó, automatikus ásás, szerencse, plusz kiállítóhely.
- **MVP terjedelme:** kb. 5–6 hét (a legegyszerűbb).
- **Kockázat:** gyenge a társas súrlódás és a megkülönböztetés, sok hasonló „simulator” van már.

---

## Pontozás (1–10, saját becslés, nem mért adat)

| Szempont | A) Szörnykeltető | B) Viharvadászok | C) Kincsásó part |
|---|---|---|---|
| Kattinthatóság | 9 | 9 | 7 |
| Megtartás | 9 | 7 | 6 |
| Viralitás | 8 | 9 | 5 |
| Monetizáció | 9 | 7 | 6 |
| Megépíthetőség (1 fő) | 8 | 5 | 9 |
| Megkülönböztetés | 6 | 8 | 4 |
| **Összesen** | **49** | **45** | **37** |

## Javaslat: A) Szörnykeltető

Indoklás:
1. Ez a legerősebb megtartási motor: az offline keltetés és a forgó bolt valódi okot ad a másnapi visszatérésre.
2. A frissítések szinte csak adatok (új tojások, szörnyek, mutációk), ezért egy fővel is fenntartható a heti frissítés.
3. A monetizáció természetesen illeszkedik: idő, hely, szerencse és védelem, nem győzhetetlenség.

Hogy ne legyen klón, a következő csavarokat javaslom:
- **Mutációk:** a keltetés alatti időjárás/esemény módosítja a szörnyet (pl. „Lávás”, „Kristály”), ezek gyűjthető változatok.
- **Korlátozott lopás:** egyszerre csak 1 tojást vihetsz, a tulajdonos 10 másodpercig visszaszerezheti, ingyenes pajzs jár offline idő alatt, és az újoncok első 30 percben védettek.
- **Szörnyek a pályán:** a szörnyek látható módon járkálnak a szigeteden, így a többiek „megirigyelhetik” őket, ami mutogatás és közösségi motiváció.

---

## Következő lépések
1. Válaszd ki a koncepciót (vagy kérj módosítást), és jöhet az 1. fázis: a játéktervezési dokumentum (első 60 másodperc, gazdaság-táblázatok, drop-rátak).
2. Erősítsd meg vagy javítsd a fenti feltételezéseket (csapat, idő, keret).
