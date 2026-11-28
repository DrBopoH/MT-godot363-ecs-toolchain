[English](CHANGELOG.md) · [Русский](CHANGELOG.ru.md) · [Українська](CHANGELOG.uk.md)

# Changelog

Versions follow the sky scheme `vR.sB.C`: `a` marks an alpha build, `B` is the build number, `C` the commit count.

## Unreleased

Added
- Networking: `NetId` marks an entity for replication; `NetSend`/`NetSnapshotSend` and `NetReceive`/`NetSnapshotReceive` replicate the components listed in `NetFields` through the `NetWire` boundary (appearance and removal reliable, values unreliable, links translated, late joiners get everything).
- Network adapters: `NetLink` pumps a `NetworkedMultiplayerPeer` (ENet, WebSocket…), `NetHost` admits peers by ticket and turns their intents into `Scheduler.input`, releasing held keys on disconnect; `NetGuest` sends intents and the ticket. `NetTicket` contract and `HMACTicket` (HMAC-SHA256).
- Stand `net`: one server and several clients on one machine.

Changed
- `IntentInputs` writes into any sink with `input(channel, intent, value)` — `Scheduler` or `NetGuest`.
- `Scheduler.open` sets a system's parameters before binding, so its contract can depend on them.

Fixed
- Adding a component an entity already has no longer subscribes systems twice.
- Entities spawned from one blueprint no longer share mutable values.

## Build 3 alpha — Layered input and grabbing (v1.a3.18)

Added
- Layered input: `IntentInputs` adapter takes the whole Godot event stream and turns keys into intents by bindings; `Scheduler.input(channel, intent, value)` queues them; `Controlled` ties an entity to a control channel (player, network, AI alike).
- `Latch` provider: `Held`, `Pressed`, `Released` bit masks and summed `Axes` per tick; a release in the same tick as its press is deferred.
- `Resolver`: click or hold per intent mask (`Mask`, `Threshold`, `Durations`, `Clicked`, `Holding`).
- `DirectionFromIntents` converter, `Thrust`/`DirectThrust` with `Speed`.
- Bindings as layered blueprints: factory defaults in `res://`, player changes in `user://`; `BlueprintSaver` writes blueprints; `Trigger` and `Bindings` components.
- Stand `keyboard`: the cube driven through the whole input chain.
- Mouse look: `Orientation`, `Looking`/`RelativeEuler` with `Sensitivity` and `PitchLimits` (degrees), `Rotator`/`DirectRotator`; `LocalThrust` moves in the view axes without the vertical. Stand `look`.
- Events as ordinary entities: `Transient` component and `Transience`/`OneTick`, which kills its subscribers at the end of the tick; put it last in the pipeline.
- Grabbing by cursor: a grip is an entity with `Holder` and `Holds` links, `Grip`, `Reach` and `Position`. `Picking`/`RaycastPicker` casts a ray through the cursor, `Pointing`/`CursorAnchor` keeps the grip on the cursor ray, `Springing` pulls the body with a critically damped spring (`Strength`): `SpringFollow` by force, `ImpulseSpringFollow` by impulse. Stand `grab`.
- README in English, Russian and Ukrainian; this changelog.
- Mozilla Public License 2.0: `LICENSE` and a license header in every script.

Changed
- Actuators run on the physics tick, so nodes move only there; turn on `physics/common/physics_interpolation` in the project for smooth display. `DirectTranslator` places a new body and resets its interpolation on `enter`.
- `BlueprintLoader` and `BlueprintSaver` are `tool` scripts and work in the editor.
- `Scheduler.physic` is now `Scheduler.update`.

Removed
- The `RENDER` rate, `rate()` in the system contract and `Scheduler.render`: one pipeline on the physics tick; smooth display comes from physics interpolation (a look test showed 20 ticks with interpolation beat 60 without). Breaking: families drop `rate()`, seeds drop `_process`.
- `Event` base class: an event is an entity with `Transient`.

## Build 2 alpha — Entity lifecycle and blueprints (v1.a2.17)

Added
- `Requests`: systems ask for changes through queues `spawning`, `appearing`, `dying`; the composer applies them after the physics tick, in that order.
- `Composer`: entity composition moved out of `Scheduler` (`spawn`, `add`, `remove`, `kill`, subscription).
- `uses()` in the system contract: data a system touches without subscribing by it.
- `Link`: components referencing another entity; links are cut before the target dies.
- `Event`: one-tick event entities.
- Reuse of freed entity numbers; component tables double when numbers run out.
- `Blueprint` and `BlueprintLoader`: `*.blueprint` files (JSON) loaded with `preload` and passed straight to `spawn`, `open` or `Template`.
- Base set in `source/`: components `Position`, `Proxy`, `Scene`, `Root`, `Lifetime`, `Interval`, `Countdown`, `Template`, `Velocity`, `Offset`, `Target`; actuators `Translator`/`DirectTranslator`, `Embodiment`/`Instancer`; drivers `Aging`/`Expiry`, `Emission`/`Periodic`, `Movement`/`LinearMovement`, `Following`/`AnchorFollow`.
- Stands `dispenser` and `grab`.

Changed
- `kill` calls every `exit` while the entity is whole, then clears it; killing an already freed number does nothing.
- Systems without `needs` have no subscribers.
- File names in PascalCase after `class_name`; tests moved to `examples/tests/`.
- Breaking: `scheduler.spawn` and friends moved to `scheduler.composer`; systems write `requests.dying` instead of `dying`.

## Build 1 alpha — ECS core (v1.a1.13)

Added
- Core: `Scheduler`, `Components`, `Pipeline`, `Functor`.
- Entities as numbers, components as classes with a typed `value`, data in arrays by entity number.
- System families declare `needs`, `owns` and `rate`; systems are entities, their parameters are components at their own number.
- Automatic subscription by `needs` on `spawn`, `add` and `open`; `remove` with unsubscription; hot `swap` within a family.
- Death queue applied after the physics tick; `enter` and `exit` hooks.
- Stand `stand_motion` and the test seed.
