[English](CHANGELOG.md) · [Русский](CHANGELOG.ru.md) · [Українська](CHANGELOG.uk.md)

# Журнал изменений

Версии по схеме sky `vR.sB.C`: `a` — альфа-сборка, `B` — номер сборки, `C` — число коммитов.

## Не выпущено

Добавлено
- Ввод слоями: адаптер `IntentInputs` принимает весь поток событий Godot и переводит клавиши в намерения по биндам; `Scheduler.input(channel, intent, value)` ставит их в очередь; `Controlled` связывает сущность с каналом управления (игрок, сеть, ИИ — одинаково).
- Provider `Latch`: маски `Held`, `Pressed`, `Released` и суммированные за тик `Axes`; отпуск в том же тике, что и нажатие, переносится на следующий.
- `Resolver`: клик или зажим по маске намерений (`Mask`, `Threshold`, `Durations`, `Clicked`, `Holding`).
- Converter `DirectionFromIntents`, `Thrust`/`DirectThrust` со `Speed`.
- Бинды как blueprints со слоями: заводские в `res://`, изменения игрока в `user://`; `BlueprintSaver` записывает blueprints; компоненты `Trigger` и `Bindings`.
- Стенд `keyboard`: куб через всю цепочку ввода.
- Обзор мышью: `Orientation`, `Looking`/`RelativeEuler` с `Sensitivity` и `PitchLimits` (градусы), `Rotator`/`DirectRotator`; `LocalThrust` двигает в осях взгляда без вертикали. Стенд `look`.
- События как обычные сущности: компонент `Transient` и `Transience`/`OneTick`, убивающая подписчиков в конце тика; ставится последней в пайплайне.
- Захват по курсору: хват — сущность со ссылками `Holder` и `Holds`, `Grip`, `Reach` и `Position`. `Picking`/`RaycastPicker` пускает луч через курсор, `Pointing`/`CursorAnchor` держит хват на луче курсора, `Springing` тянет тело пружиной с критическим демпфированием (`Strength`): `SpringFollow` силой, `ImpulseSpringFollow` импульсом. Стенд `grab`.
- README на английском, русском и украинском; этот журнал изменений.
- Mozilla Public License 2.0: `LICENSE` и лицензионная шапка в каждом скрипте.

Изменено
- Actuators работают на физическом тике, ноды двигаются только там; для плавного отображения включи в проекте `physics/common/physics_interpolation`. `DirectTranslator` ставит новое тело на место и сбрасывает его интерполяцию в `enter`.
- `BlueprintLoader` и `BlueprintSaver` — скрипты `tool`, работают в редакторе.
- `Scheduler.physic` теперь `Scheduler.update`.

Удалено
- Частота `RENDER`, `rate()` в контракте системы и `Scheduler.render`: один пайплайн на физическом тике; плавность отображения даёт интерполяция физики (проверка обзора: 20 тиков с интерполяцией лучше 60 без неё). Ломающее: семейства без `rate()`, зёрна без `_process`.
- Базовый класс `Event`: событие — сущность с `Transient`.

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
