# MT-godot363-ecs-toolchain

[English](README.md) · [Русский](README.ru.md) · [Українська](README.uk.md)

An entity-component-system framework for Godot 3.6.3 by MorangTong creative studio.
Entities are numbers, component data lives in plain arrays indexed by those numbers, and nodes are only visual proxies.
The same core runs on a server without nodes and on a client that draws them.

Status: alpha. Built and used for the vehicle-combat game Overlive.

## Install

```
git submodule add https://github.com/DrBopoH/MT-godot363-ecs-toolchain addons/MT-godot363-ecs-toolchain
```

Classes register through `class_name`; open the project once in the editor so Godot picks them up.
To export `*.blueprint` files, add `*.blueprint` to the export filter for non-resource files.

## Concepts

| Name | What it is |
|---|---|
| entity | a number |
| component | a class with a typed `value`; the class is the key, plain values live in arrays by entity number |
| system | a `Functor`; a family base class declares `needs` (subscription), `owns` (the system's own parameters), `uses` (other data it touches); an implementation only writes behaviour |
| `Scheduler` | orchestration: one pipeline run on the physics tick, `open` and hot `swap` of systems |
| `Composer` | entity composition: `spawn`, `add`, `remove`, `kill`; subscribes entities to systems by their components |
| `Requests` | queues systems use to ask for changes (`spawning`, `appearing`, `dying`); applied after the physics tick |
| `Link` | base for components that reference another entity; links are cut before the target dies |
| `Event` | base for components of one-tick event entities |
| `Blueprint` | component values on disk (`*.blueprint`, JSON inside), loaded with `preload` |

Roles of systems: providers bring the outside world into components, drivers are pure math over components, actuators write components into nodes.

## A seed

```gdscript
extends Spatial

const CRATE = preload("res://content/blueprints/crate.blueprint")

var scheduler: Scheduler = Scheduler.new()


func _ready() -> void:
	scheduler.open(Translator, DirectTranslator.new(), [])
	scheduler.open(Embodiment, Instancer.new(), [Root.new(self)])
	scheduler.open(Aging, Expiry.new(), [])
	scheduler.composer.spawn(CRATE)

func _physics_process(delta: float) -> void: scheduler.update(delta)
```

```json
{
	"Position": [0, 0, -5],
	"Scene": "res://crate.tscn",
	"Lifetime": 0.8
}
```

## A system

```gdscript
class_name Aging
extends Functor


func needs() -> Array: return [Lifetime]
```

```gdscript
class_name Expiry
extends Aging


func update(delta: float) -> void:
	var lifetimes: Array = tables[Lifetime]
	for subscriber in subscribers:
		lifetimes[subscriber]-= delta
		if lifetimes[subscriber] <= 0.0: requests.dying.append(subscriber)
```

## Layout

```
source/        the library: core and the base set (components/, systems/actuators|drivers)
content/       data, blueprints
examples/      stands (stand_motion, dispenser, grab) and tests (examples/tests/seed.tscn)
```

## Roadmap

Layered input with intents, networking, cassettes (declarative mounting of systems and entities).

## Changes

See [CHANGELOG.md](CHANGELOG.md).

## License

[Mozilla Public License 2.0](LICENSE).
