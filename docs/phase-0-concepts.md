# Phase 0: Concept Selection

## Assumed context (the `[BRACKETS]` were not filled in)

| Field | Default chosen |
|---|---|
| Team | Solo, intermediate scripter, basic building/UI, little art (uses free/licensed models + simple low-poly) |
| Time | ~15 h/week, launch target 8 weeks |
| Budget | 0 at start; ads only after soft-launch metrics hit targets |
| Tooling | Rojo + Git (this repo exists). Studio-only placement map provided if not |
| Audience | Ages 9–15, mobile-first, global |

## Concept 1: 🐉 Dragon Hatchery (working title "Hatch a Dragon")

**Pitch:** Incubate eggs on your volcano nest; they hatch in real time into dragons that mine gems for you, and during eruptions they can mutate into legendaries.

**Thumbnail/icon:** A shocked avatar beside a cracked, glowing egg with a rainbow dragon bursting out, lava behind it.

| Loop | Content |
|---|---|
| Core (30 s) | Buy an egg from the rotating shop → place it in a nest slot → tap to warm it (speeds the hatch) → collect gems from your dragons |
| Session (15 min) | Fill slots, catch the server-wide **Eruption** (mutation chance plus wild eggs raining onto the central volcano for everyone to race to), fuse duplicates, buy slot upgrades, check the 5-min restock |
| Meta (days) | Rarer egg tiers, new nest islands (zones), rebirth (reset gems for a permanent multiplier and a new egg tier), dragon index (collection book), show-off pedestals |

**Returns:** D1: eggs with 1–12 h hatch timers, capped offline gems, login streak. D7: a new species each weekly update, index rewards, weekly quests. D30: rebirth tiers, trading mutated dragons, leaderboards.

**Viral moment:** During an eruption the server sees "🌋 Alex hatched a 1-in-50,000 RAINBOW MAGMA DRAGON!" and a giant dragon flies a lap over the whole map.

**Monetization hooks:** extra nest slots (pass), 2× gems (pass), instant-hatch (product), timed luck boost (product), buyer-triggered server Eruption (product, socially visible), starter pack after the first rare hatch.

**MVP scope (estimate):** 6–8 weeks solo.

**Main risk:** The pattern (timed growth + weather mutations + rotating stock) is close to Grow a Garden-style hits. It is differentiated by dragons as active producers, the eruption scramble, and flight show-off. Verify the current top 50 before committing.

## Concept 2: ☄️ Meteor Rush

**Pitch:** Meteors crash into the map every few minutes. Race other players to the crater, grab the crystals, and refine them at your base into riches.

**Thumbnail/icon:** A flaming meteor about to hit, three avatars sprinting toward it, one huge glowing purple crystal.

| Loop | Content |
|---|---|
| Core (30 s) | Siren → sprint/glide to the crater → tap-mine contested crystals → carry them back (backpack cap) → deposit in your refinery |
| Session (15 min) | A shower every 2–3 min; upgrade backpack, pickaxe, and speed; unlock zones (Moon, Mars) |
| Meta (days) | Refinery runs offline (capped), rebirth, rare meteor types tied to "space weather", crystal index, base decoration |

**Returns:** D1: refinery output waiting, streak. D7: a new meteor type weekly, quests. D30: rebirth, leaderboards, full index.

**Viral moment:** "☄️ MYTHIC GALAXY METEOR INBOUND, 0:30". The whole server stampedes to one crater and one player gets it.

**Monetization hooks:** bigger backpack, glide/speed pass, refinery speed boost, buyer-triggered meteor shower, starter pack.

**MVP scope (estimate):** 7–9 weeks solo.

**Main risks:** Resources are contested, so paid speed or capacity is pay-to-win against free players, and balancing that is hard. It needs good touch movement and more physics/replication work. Async progress is weaker (only the refinery).

## Concept 3: 🦖 Grow a Kaiju

**Pitch:** Feed your tiny monster until it is skyscraper-sized, then stomp the city for coins.

**Thumbnail/icon:** An enormous kaiju over a city, a tiny avatar riding its head, a "10,000 FT" counter.

| Loop | Content |
|---|---|
| Core (30 s) | Collect or buy food → feed → the monster visibly grows → stomp buildings for coins |
| Session (15 min) | Evolve forms at size thresholds, unlock bigger cities, co-op "Kaiju Boss" server raid |
| Meta (days) | Digests food offline (growth), rebirth shrinks you for a permanent growth multiplier, species/skin collection |

**Returns:** D1: offline growth, streak. D7: new species and cities. D30: rebirth ladder, size leaderboard.

**Viral moment:** The biggest kaiju in the server literally towers over everyone. A "Kaiju Clash" event.

**Monetization hooks:** 2× growth, auto-feed, food packs, evolution skins, buyer-triggered "Mega Meal" event.

**MVP scope (estimate):** 6–8 weeks solo.

**Main risks:** Giant scaled models hurt low-end mobile (camera, collisions, streaming). "Eat and grow" is an older, crowded sim genre. Weaker scarcity and timing.

## Scores (1–10, my judgment, estimates)

| Concept | Click | Retention | Virality | Monetization | Buildability | Differentiation | **Total /60** |
|---|---|---|---|---|---|---|---|
| 🐉 Dragon Hatchery | 8 | 8 | 7 | 8 | 8 | 5 | **44** |
| ☄️ Meteor Rush | 7 | 6 | 9 | 7 | 6 | 8 | **43** |
| 🦖 Grow a Kaiju | 8 | 6 | 7 | 7 | 6 | 5 | **39** |
| **🐉 + ☄️ hybrid (recommended)** | 8 | 8 | 8 | 8 | 7 | 7 | **46** |

## Recommendation

**Build Dragon Hatchery with Meteor Rush's scramble grafted on as the Eruption event.** The strong async loop (hatch timers, offline gems) drives retention, which comes first. The eruption scramble adds the social friction and clip moment *without* theft, so free players never lose progress to other players. Everything weekly is data: new eggs, dragons, mutations, and islands.

Why not theft (Steal a Brainrot-style)? It is proven for virality, but it is the closest to a current #1 clone and it punishes the youngest players hardest. It can be revisited later as an opt-in "Raid Island".

## Facts vs. items to verify

- **Fact:** Paid random items must disclose odds, and `PolicyService:GetPolicyInfoForPlayerAsync()` exposes `ArePaidRandomItemsRestricted`. **Verify in current Roblox docs.**
- **Recommendation:** Eggs cost **soft currency only**. Robux buys slots, speed, and timed luck. Whether a Robux luck boost on a soft-currency egg counts as a "paid random item" in some regions is unclear. **Verify in current Roblox docs/policy before Phase 2.**
- **Unverified:** The current top-50 composition. My knowledge stops mid-2026. Check the Roblox Charts before picking.
