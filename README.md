# police_job

A standalone police job for FiveM. No framework (ESX/QBCore/etc.) and no
inventory resource needed: who counts as police comes straight from
FXServer's own ACE permission groups, and every police action requires being
clocked on duty.

## Features

- **Duty system**: clock on/off at a duty ped (`ox_target`) or with
  `/policeduty`. Holding the ACE group only lets you clock on; every action
  below needs you to actually be on duty, and is re-checked server-side.
- **Handcuffs and zipties**: normal cuffing when the target has their hands
  up, aggressive cuffing (with a skill check for the target to break free)
  otherwise. Hands up is on `X` (tap to raise, hold to kneel).
- **Escort**: drag a cuffed player, place them in a vehicle, take them out.
- **Search**: reports whether a cuffed or hands-up player is armed.
- **GSR test**: firing a gun leaves residue that fades after
  `clearGSR` minutes, or sooner in water.
- **Evidence**: shots drop casings and projectiles that on-duty officers
  can collect.
- **Spikestrips**: a per-officer allowance issued at clock-on
  (`maxSpikestrips`), deployed with a keybind (unbound by default, set it
  under Settings > Key Bindings > FiveM) and picked back up with `ox_target`.
- **Impound**: removes a vehicle from the world.
- **Jail**: sentence a cuffed player for a number of minutes. Sentences
  persist in MySQL, survive reconnects and resource restarts, and leaving
  the prison grounds teleports the prisoner back.
- **Callsigns and officer blips**: `/callsign 1-Adam-12` sets a persistent
  callsign; on-duty officers see each other on the map with a blip that
  changes for foot/car/bike/helicopter.

## Requirements

- [ox_lib](https://github.com/overextended/ox_lib)
- [ox_target](https://github.com/overextended/ox_target)
- [oxmysql](https://github.com/overextended/oxmysql) (with
  `mysql_connection_string` set in `server.cfg`)
- OneSync enabled

## Installation

1. Put the folder in your `resources` directory. Keep the name `police_job`
   (exports and the ACE line below use it).
2. Add to `server.cfg`, after the requirements:

   ```cfg
   ensure police_job

   # lets the resource register its own ACE rules on start; add this if
   # officers holding the right group still can't clock on
   add_ace resource.police_job command.add_ace allow
   ```

3. Give your officers one of the groups listed in `data/config.lua`, e.g.:

   ```cfg
   add_principal identifier.discord:123456789012345678 group.leo
   ```

   A Discord role sync resource that assigns principals works the same way.

4. Edit the files in `data/` to taste (see below).

The `police_callsigns` and `police_jail` tables are created automatically on
first start.

## Configuration

| File                    | What it controls                                                                                                                                       |
| ----------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------ |
| `data/config.lua`       | Police ACE groups, duty command name, `/jail` and `/unjail` groups, GSR timers, impound price range, spikestrip allowance, permission refresh interval |
| `data/dutyPeds.lua`     | Model and position of each duty ped                                                                                                                    |
| `data/jail.lua`         | Prison/release coordinates, maximum sentence, escape zone, optional Discord webhook log                                                                |
| `data/officerBlips.lua` | Blip sprites, colour, update interval, who else receives officer positions                                                                             |
| `data/weaponAmmo.lua`   | Which weapons leave evidence, and of what calibre (add your add-on weapons here)                                                                       |
| `data/evidence.lua`     | Labels for each ammo type                                                                                                                              |
| `locales/en.json`       | All player-facing text                                                                                                                                 |

ACE groups are re-checked every `permissionRefreshInterval` seconds, so a
promotion or demotion applies without a reconnect. Losing the group while on
duty clocks you off automatically.

## Commands

| Command                | Who                                           | What                                 |
| ---------------------- | --------------------------------------------- | ------------------------------------ |
| `/policeduty`          | police groups                                 | Toggle duty from anywhere            |
| `/callsign [text]`     | police groups                                 | Set your callsign; no text clears it |
| `/jail [id] [minutes]` | `jailCommandGroups` (default `group.admin`)   | Jail a player from anywhere          |
| `/unjail [id]`         | `unjailCommandGroups` (default `group.admin`) | Release a jailed player              |

## For developers

**Exports**

```lua
-- server
exports.police_job:isOnDuty(src)                  -- boolean
exports.police_job:getCallsign(src)               -- callsign, or player name if unset
exports.police_job:refreshPolicePermissions(src)  -- re-check ACE groups right now

-- client
exports.police_job:isOnDuty()                     -- boolean, for UI only
exports.police_job:cuff()                         -- cuff / ziptie / uncuff the closest player
exports.police_job:ziptie()
exports.police_job:uncuff()
exports.police_job:deploySpikestrip()
```

The client-side `isOnDuty` is fine for hiding a button, but always check
server-side before letting anything actually happen.

**Server events** (listen with `AddEventHandler`)

| Event                          | Arguments                         |
| ------------------------------ | --------------------------------- |
| `police_job:dutyChanged`       | `src, onDuty`                     |
| `police_job:evidenceCollected` | `src, item, ammoType, count`      |
| `police_job:searchedPlayer`    | `officerSrc, targetSrc`           |
| `police_job:vehicleImpounded`  | `src, plate, reclaimPrice, model` |

**State bags** on each player: `onDuty`, `isCuffed`, `cuffType`,
`isEscorted`, `handsUp`, `jailed` (minutes remaining), `shot` (has GSR).

**Optional integrations**

- If a resource named `hud` exports `setLeoDuty(src)` / `clearDuty(src)`,
  they're called on duty changes. Skipped silently otherwise.
- `shareWithStates` in `data/officerBlips.lua` lists extra player state bag
  keys (e.g. an EMS resource's own on-duty flag) whose holders also receive
  officer positions.

## Limitations

- There's no inventory, so collected evidence and search results aren't
  stored anywhere; hook the events above into an MDT if you want that.
- Impounded vehicles are deleted, not stored. Hook
  `police_job:vehicleImpounded` into a garage resource for a real impound lot.
- Cuff and GSR state is held in client-replicated state bags, so pair this
  with an anti-cheat if that matters on your server.
- English locale only.

## Credits and licence

Licensed under the GNU General Public License v3.0 (see `LICENSE.md`).

This is a modified version of
[ND_Police](https://github.com/ND-Framework/ND_Police) by ND-Framework,
which is itself based on
[ox_police](https://github.com/overextended/ox_police) by Overextended, with
contributions credited there to Testaross, Hakko and Florek. The jail
feature is adapted from ND-Framework's ND_Jailing.

Changes in this version: removed the framework and inventory dependencies in
favour of ACE permissions and a duty system, and added jailing, callsigns
and officer blips. See `difference.md` for the full list.

## AI use

AI assistance was used.
