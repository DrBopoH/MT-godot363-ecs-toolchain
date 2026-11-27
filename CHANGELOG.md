[English](CHANGELOG.md) · [Русский](CHANGELOG.ru.md) · [Українська](CHANGELOG.uk.md)

# Changelog

Versions follow the sky scheme `vR.sB.C`: `a` marks an alpha build, `B` is the build number, `C` the commit count.

## Unreleased

- README in English, Russian and Ukrainian; this changelog.
- Mozilla Public License 2.0: `LICENSE` and a license header in every script.

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
