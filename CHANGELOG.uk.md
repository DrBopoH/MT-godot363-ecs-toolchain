[English](CHANGELOG.md) · [Русский](CHANGELOG.ru.md) · [Українська](CHANGELOG.uk.md)

# Журнал змін

Версії за схемою sky `vR.sB.C`: `a` — альфа-збірка, `B` — номер збірки, `C` — кількість комітів.

## Не випущено

- README англійською, російською й українською; цей журнал змін.
- Mozilla Public License 2.0: `LICENSE` і ліцензійна шапка в кожному скрипті.

## Build 2 alpha — Життя сутностей і blueprints (v1.a2.17)

Додано
- `Requests`: системи просять змін через черги `spawning`, `appearing`, `dying`; composer виконує їх після фізичного тіку в цьому порядку.
- `Composer`: склад сутностей винесено з `Scheduler` (`spawn`, `add`, `remove`, `kill`, підписка).
- `uses()` у контракті системи: дані, яких система торкається, не підписуючись за ними.
- `Link`: компоненти-посилання на іншу сутність; посилання знімаються до смерті цілі.
- `Event`: сутності-події на один тік.
- Повторне використання звільнених номерів; масиви компонентів подвоюються, коли номери закінчуються.
- `Blueprint` і `BlueprintLoader`: файли `*.blueprint` (JSON) вантажаться через `preload` і передаються прямо в `spawn`, `open` або `Template`.
- Базовий набір у `source/`: компоненти `Position`, `Proxy`, `Scene`, `Root`, `Lifetime`, `Interval`, `Countdown`, `Template`, `Velocity`, `Offset`, `Target`; actuators `Translator`/`DirectTranslator`, `Embodiment`/`Instancer`; drivers `Aging`/`Expiry`, `Emission`/`Periodic`, `Movement`/`LinearMovement`, `Following`/`AnchorFollow`.
- Стенди `dispenser` і `grab`.

Змінено
- `kill` викликає всі `exit`, поки сутність ціла, і лише потім очищає її; `kill` уже звільненого номера нічого не робить.
- Системи без `needs` не мають підписників.
- Імена файлів у PascalCase за `class_name`; тести перенесено в `examples/tests/`.
- Ламаюче: `scheduler.spawn` і сусіди переїхали в `scheduler.composer`; системи пишуть `requests.dying` замість `dying`.

## Build 1 alpha — Ядро ECS (v1.a1.13)

Додано
- Ядро: `Scheduler`, `Components`, `Pipeline`, `Functor`.
- Сутності — номери, компоненти — класи з типізованим `value`, дані — масиви за номером сутності.
- Сімейства систем оголошують `needs`, `owns` і `rate`; системи — сутності, їхні параметри — компоненти за їхнім номером.
- Автопідписка за `needs` при `spawn`, `add` і `open`; `remove` з відпискою; гаряча заміна `swap` усередині сімейства.
- Черга смерті після фізичного тіку; гачки `enter` і `exit`.
- Стенд `stand_motion` і зерно тестів.
