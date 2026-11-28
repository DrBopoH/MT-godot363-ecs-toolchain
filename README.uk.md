# MT-godot363-ecs-toolchain

[English](README.md) · [Русский](README.ru.md) · [Українська](README.uk.md)

Фреймворк entity-component-system для Godot 3.6.3 від MorangTong creative studio.
Сутності — номери, дані компонентів лежать у простих масивах за цими номерами, а ноди — лише візуальний проксі.
Те саме ядро працює на сервері без нод і на клієнті, який їх малює.

Статус: альфа. Створений і використовується для вехікл-комбату Overlive.

## Встановлення

```
git submodule add https://github.com/DrBopoH/MT-godot363-ecs-toolchain addons/MT-godot363-ecs-toolchain
```

Класи реєструються через `class_name`; один раз відкрий проєкт у редакторі, щоб Godot їх підхопив.
Щоб файли `*.blueprint` потрапили в експорт, додай `*.blueprint` у фільтр non-resource files.

## Поняття

| Ім'я | Що це |
|---|---|
| сутність | номер |
| компонент | клас із типізованим `value`; клас — ключ, прості значення лежать у масивах за номером сутності |
| система | `Functor`; базовий клас сімейства оголошує `needs` (підписка), `owns` (параметри самої системи), `uses` (інші дані, яких вона торкається); реалізація пише лише поведінку |
| `Scheduler` | оркестрація: один пайплайн на фізичному тіку, `open` і гаряча заміна `swap` систем |
| `Composer` | склад сутностей: `spawn`, `add`, `remove`, `kill`; підписує сутності на системи за їхніми компонентами |
| `Requests` | черги, через які системи просять змін (`spawning`, `appearing`, `dying`); виконуються після фізичного тіку |
| `Link` | база для компонентів-посилань на іншу сутність; посилання знімаються до смерті цілі |
| `Event` | база для компонентів сутностей-подій, що живуть один тік |
| `Blueprint` | значення компонентів на диску (`*.blueprint`, усередині JSON), вантажаться через `preload` |

Ролі систем: providers приносять зовнішній світ у компоненти, drivers — чиста математика над компонентами, actuators переносять компоненти в ноди.

## Зерно

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

## Система

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

## Структура

```
source/        бібліотека: ядро і базовий набір (components/, systems/actuators|drivers)
content/       дані, blueprints
examples/      стенди (stand_motion, dispenser, grab) і тести (examples/tests/seed.tscn)
```

## Плани

Ввід шарами через наміри, мережа, касети (декларативне монтування систем і сутностей).

## Зміни

Див. [CHANGELOG.uk.md](CHANGELOG.uk.md).

## Ліцензія

[Mozilla Public License 2.0](LICENSE).
