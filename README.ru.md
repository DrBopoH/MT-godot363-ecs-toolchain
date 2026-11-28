# MT-godot363-ecs-toolchain

[English](README.md) · [Русский](README.ru.md) · [Українська](README.uk.md)

Фреймворк entity-component-system для Godot 3.6.3 от MorangTong creative studio.
Сущности — номера, данные компонентов лежат в простых массивах по этим номерам, а ноды — только визуальный прокси.
Одно и то же ядро работает на сервере без нод и на клиенте, который их рисует.

Статус: альфа. Создан и используется для вехикл-комбата Overlive.

## Установка

```
git submodule add https://github.com/DrBopoH/MT-godot363-ecs-toolchain addons/MT-godot363-ecs-toolchain
```

Классы регистрируются через `class_name`; один раз открой проект в редакторе, чтобы Godot их подхватил.
Чтобы файлы `*.blueprint` попали в экспорт, добавь `*.blueprint` в фильтр non-resource files.

## Понятия

| Имя | Что это |
|---|---|
| сущность | номер |
| компонент | класс с типизированным `value`; класс — ключ, простые значения лежат в массивах по номеру сущности |
| система | `Functor`; базовый класс семейства объявляет `needs` (подписка), `owns` (параметры самой системы), `uses` (другие данные, которые она трогает); реализация пишет только поведение |
| `Scheduler` | оркестрация: один пайплайн на физическом тике, `open` и горячий `swap` систем |
| `Composer` | состав сущностей: `spawn`, `add`, `remove`, `kill`; подписывает сущности на системы по их компонентам |
| `Requests` | очереди, через которые системы просят изменений (`spawning`, `appearing`, `dying`); выполняются после физического тика |
| `Link` | база для компонентов-ссылок на другую сущность; ссылки снимаются до смерти цели |
| `Event` | база для компонентов сущностей-событий, живущих один тик |
| `Blueprint` | значения компонентов на диске (`*.blueprint`, внутри JSON), грузятся через `preload` |

Роли систем: providers приносят внешний мир в компоненты, drivers — чистая математика над компонентами, actuators переносят компоненты в ноды.

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

## Раскладка

```
source/        библиотека: ядро и базовый набор (components/, systems/actuators|drivers)
content/       данные, blueprints
examples/      стенды (stand_motion, dispenser, grab) и тесты (examples/tests/seed.tscn)
```

## Планы

Ввод слоями через намерения, сеть, кассеты (декларативное монтирование систем и сущностей).

## Изменения

См. [CHANGELOG.ru.md](CHANGELOG.ru.md).

## Лицензия

[Mozilla Public License 2.0](LICENSE).
