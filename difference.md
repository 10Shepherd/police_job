# Differences from the original script

`police_job` is a modified version of
[ND_Police](https://github.com/ND-Framework/ND_Police) by ND-Framework, which
is itself based on [ox_police](https://github.com/overextended/ox_police) by
Overextended. The jail feature is adapted from ND-Framework's separate
ND_Jailing resource.

This file lists what this version changes relative to ND_Police. It was
written from the modification notes kept while the changes were made, not
from a line-by-line diff, so treat it as a summary rather than a complete
changelog.

Last updated: 2026-11-15

## Summary

| Area                                           | Original                        | This version                                    |
| ---------------------------------------------- | ------------------------------- | ----------------------------------------------- |
| Framework                                      | Requires ND_Core, ESX or QBCore | None; standalone only                           |
| Inventory                                      | Requires ox_inventory           | None                                            |
| Who is police                                  | Job/group from the framework    | FXServer ACE groups, plus being clocked on duty |
| Cuffs, zipties, GSR kit                        | Inventory items                 | No items; gated on duty status                  |
| Jail                                           | Separate resource               | Built in, stored in MySQL                       |
| Callsigns and officer blips                    | Not present                     | Added                                           |
| Locker rooms, shotspotter, shield, spikestrips | Present                         | Removed                                         |

## Removed

- **Framework bridges** for ND_Core, ESX and QBCore. Only a standalone
  bridge remains (`bridge/standalone/`).
- **ox_inventory dependency**, and with it every item check and item hand-out.
- **Locker rooms** (the uniform/outfit menu) and their locale strings.
- **Shotspotter** (zone-based gunfire alerts). A dispatch resource covers
  this better and running both produced duplicate calls.
- **Riot shield** (`client/shield.lua`) and the gun-animation resource it
  depended on. Use a separate shield script and gate it with the
  `isOnDuty` export.
- **Spikestrips** (`client/spikes.lua`, the two `police_job:*Spikestrip`
  server events, the per-officer allowance and its locale strings). The
  `p_ld_stinger_s` prop is no longer registered with `ox_target` and the
  "Deploy spikestrip" keybind is gone. Use a dedicated spikestrip resource
  and gate it with the `isOnDuty` export.
- **Swedish locale.** English only.
- **Character-specific logic** (clearing state on character switch, saving
  outfits to a character). There is no character system here.

## Changed

### Permissions

- Police status comes from ACE groups listed in `data/config.lua`
  (`policeGroups`) instead of a framework job.
- The server checks every player's groups on join, on resource start and
  every `permissionRefreshInterval` seconds, and syncs the result to the
  client as a `policeGroups` state bag.
- The resource registers the `add_ace <group> <group> allow` rule for each
  configured group itself on start.
- New export `refreshPolicePermissions(src)` forces an immediate re-check.

### Items replaced by duty status

- Cuffing, zipties, uncuffing, escorting, searching, GSR testing,
  collecting evidence and impounding all require the officer to be on duty.
  None of them need an item.
- **Evidence** no longer becomes an inventory item. Collecting it shows
  what was found and fires the server event `police_job:evidenceCollected`.
- **Searching a player** no longer opens their inventory. It reports whether
  they are armed and fires `police_job:searchedPlayer`.
- **Impound** deletes the vehicle and fires `police_job:vehicleImpounded`
  (plate, reclaim price, model). Nothing is stored.

### Shot detection

- The original listened for ox_inventory's current-weapon event. This
  version reads the held weapon from ox_lib's cache and maps the weapon
  hash to an ammo type through the new `data/weaponAmmo.lua`.

## Added

- **Duty system.** Duty peds (`data/dutyPeds.lua`) and a `/policeduty`
  command toggle an `onDuty` state bag. The server re-checks the ACE group
  before clocking anyone on, and clocks an officer off automatically if they
  lose the group. Fires `police_job:dutyChanged`.
- **`isOnDuty` exports**, server-side and client-side, so other resources
  can restrict themselves to on-duty police.
- **Jail** (adapted from ND_Jailing). An `ox_target` option on cuffed
  players plus `/jail` and `/unjail` commands, whose allowed groups are set
  in `data/config.lua`. Sentences are stored in a `police_jail` MySQL table,
  re-applied on reconnect and after a resource restart, and an escape zone
  teleports prisoners back. Optional Discord webhook log.
- **Callsigns.** `/callsign` stores a callsign in a `police_callsigns` MySQL
  table. `getCallsign(src)` export for dispatch resources.
- **Officer blips.** On-duty officers see each other on the map, with the
  sprite changing for foot, car, bike and helicopter. Positions are sent
  only to on-duty officers and to holders of the extra state bag keys in
  `data/officerBlips.lua` (`shareWithStates`).
- **Evidence sync on join.** A client asks for the full evidence set when
  the resource starts, so evidence placed before a player joined is still
  visible to them.
- **Optional integrations.** Duty changes are forwarded to a `hud` resource
  if one exports `setLeoDuty`/`clearDuty`, and on-duty police can show a
  companion EMS resource's on-duty blips.
- **oxmysql dependency**, for jail sentences and callsigns.

## Fixes and hardening

Problems found in the original code or introduced while porting, and fixed:

- `impoundVehicle` called the notify function without the player id in four
  places, so its error messages never reached the officer.
- The GSR test had no server-side permission check; it was only hidden in
  the UI. It now checks duty status, that the target exists, and distance.
- The cuff check's condition grouping let a player with their hands up be
  cuffed again while already cuffed or mid-cuff.
- "Take out of vehicle" used the wrong seat index for the rear-left seat, so
  the option never appeared for a prisoner sitting there.
- Escort, release, place-in-vehicle and take-out options were shown to
  everyone; they now require being on duty.
- Impound now checks the entity is actually a vehicle.
- Evidence submitted by a client is validated (shape, known ammo type,
  distance from the player) and capped per update. Collecting evidence
  checks the officer is within range of each node.
- Jailing through the `ox_target` option re-checks server-side that the
  target is cuffed and not already jailed, and releases any active escort
  first.
- `/unjail` on a player who is not jailed no longer teleports them.
- Cuff, escort and GSR events validate that the target player exists.

## Known limitations compared with the original

- No inventory integration at all: no physical evidence items, no
  searchable inventories, no item-based equipment.
- No impound lot; vehicles are deleted.
- No locker rooms, shotspotter or shield.
- One locale.
