[English](CHANGELOG.md) · [Русский](CHANGELOG.ru.md) · [Українська](CHANGELOG.uk.md)

# Журнал изменений

Версии по схеме sky `vR.sB.C`: `a` — альфа-сборка, `B` — номер сборки, `C` — число коммитов.

## Не выпущено

- README на английском, русском и украинском; этот журнал изменений.
- Mozilla Public License 2.0: `LICENSE` и лицензионная шапка в каждом скрипте.

## Build 2 alpha — Жизнь сущностей и blueprints (v1.a2.17)

Добавлено
- `Requests`: системы просят изменений через очереди `spawning`, `appearing`, `dying`; composer выполняет их после физического тика в этом порядке.
- `Composer`: состав сущностей вынесен из `Scheduler` (`spawn`, `add`, `remove`, `kill`, подписка).
- `uses()` в контракте системы: данные, которые система трогает, не подписываясь по ним.
- `Link`: компоненты-ссылки на другую сущность; ссылки снимаются до смерти цели.
- `Event`: сущности-события на один тик.
- Переиспользование освобождённых номеров; массивы компонентов удваиваются, когда номера кончаются.
- `Blueprint` и `BlueprintLoader`: файлы `*.blueprint` (JSON) грузятся через `preload` и передаются прямо в `spawn`, `open` или `Template`.
- Базовый набор в `source/`: компоненты `Position`, `Proxy`, `Scene`, `Root`, `Lifetime`, `Interval`, `Countdown`, `Template`, `Velocity`, `Offset`, `Target`; actuators `Translator`/`DirectTranslator`, `Embodiment`/`Instancer`; drivers `Aging`/`Expiry`, `Emission`/`Periodic`, `Movement`/`LinearMovement`, `Following`/`AnchorFollow`.
- Стенды `dispenser` и `grab`.

Изменено
- `kill` вызывает все `exit`, пока сущность целая, и только потом очищает её; `kill` уже освобождённого номера ничего не делает.
- У систем без `needs` нет подписчиков.
- Имена файлов в PascalCase по `class_name`; тесты перенесены в `examples/tests/`.
- Ломающее: `scheduler.spawn` и соседи переехали в `scheduler.composer`; системы пишут `requests.dying` вместо `dying`.

## Build 1 alpha — Ядро ECS (v1.a1.13)

Добавлено
- Ядро: `Scheduler`, `Components`, `Pipeline`, `Functor`.
- Сущности — номера, компоненты — классы с типизированным `value`, данные — массивы по номеру сущности.
- Семейства систем объявляют `needs`, `owns` и `rate`; системы — сущности, их параметры — компоненты по их номеру.
- Автоподписка по `needs` при `spawn`, `add` и `open`; `remove` с отпиской; горячая замена `swap` внутри семейства.
- Очередь смерти после физического тика; крючки `enter` и `exit`.
- Стенд `stand_motion` и зерно тестов.
