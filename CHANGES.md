# Список изменений относительно ванили
## Данный список очень сильно отстаёт от последних версий!
## Рекомендуется спрашивать у самих разработчиков актуальные изменения (пока что)!

## Капитанская система
- Администраторы могут назначать/убирать двух игроков капитанами команд;
- Капитаны могут брать людей в команды путём открытия таблицы игроков, зажатия сочетания клавиш Shift + Ctrl и нажатия на кнопки команд;
- Администраторы/Капитаны могут отправлять людей в наблюдатели через таблицу игроков;
- Администраторы могут отправить всех игроков в наблюдатели;
- Администраторы могут заблокировать/разблокировать набор в команду;
- Администраторы могут назначать лимит строителей и лучников командами alim и blim;
- Администраторы/капитаны имеют функционал анонсов: при написании сообщения вида "!<текст>", на экран команде будет выводится огромный текст этого сообщения без восклицательного знака в начале;
- Администраторы могут разрешать/запрещать менять классы в магазинах при помощи специальных команд.

## Добавлено
- Добавлены груши, восстанавливающие 2 сердца и стоящие 15 монет;
- Кастомные головы для некоторых игроков;
- Карты с различных мест, таких как: официальный дискорд KAG (map-submissions), из EU Captains, с форума, собственные карты и модификации некоторых карт;
- Добавлена золотая груша в качестве достижения разработчикам мода;
- Два новых виджета для таблицы очков: панель с текстом и кнопка перехода на вебсайт;
- Свой пак эмоций;
- Система меток для сокомандников/наблюдателей;
- В начале каждого раунда командам даётся ящик с ресурсами (2500 дерева и 2000 камня);
- Строители (кроме капитана) автоматически меняют класс на рыцарей за пять секунд до окончания предподготовки;
- Добавлены звуковые команды aka вокалайзы;
- Отдельный тип анонса *offi, который будет виден всем (звук для offi взят из Quake 3 Arena);
- Киллстрики от четырёх убийств и более имеют собственные звуки (звуки анонсера взяты из Unreal Tournament 2004).

## Изменения в балансе
- Батуты сохраняют импульс игрока и перенаправляют его в противоположную от лицевой части батута сторону;
- На батутах повышен кулдаун перед следующим использованием (исправляет "рэйлган");
- Батуты покупаются за 50 монет и 100 дерева;
- Деревянные двери разрушаются с двух-трёх обычных бомб;
- Каменные двери разрушаются с трёх обычных бомб;
- Рыцари наносят в полтора раза (относительно ванильного значения в 0.125) больше урона деревянным дверям;
- Повышены цены на стрелы: водные - 15 монет, бомбовые 65 монет;
- Лучники получают в 1.25 раз больше монет за определённые действия;
- Чуть-чуть повышено количество получаемых монет за различные действия;
- Увеличена сила отброса от взрыва обычных бомб;
- Строителям разрешено поджигать кеги;
- Рыцарям разрешено использовать дрели в конкретных зонах;
- Теперь невозможно взять больше одной дрели в инвентарь;
- Дрели с наименьшим значением перегрева имеют наивысший приоритет при подборе;
- Время респауна теперь динамическое и зависит от количества игроков;
- Яйцо стоит 40 монет, бургер 25 монет;
- Игроки при смерти теряют 25% монет;
- Невозможно взять больше одной единицы еды в инвентарь;
- Дрели можно покупать и в рыцарском магазине;
- Дрели покупаются за 30 монет;
- Рыцарь больше не получает материалы в свой инвентарь при копании дрелью.

## Функциональные изменения
- Менять класс в магазинах разрешено, если не была включена специальная переменная;
- Добавлен автоматический сброс материалов при респауне/нахождении в зоне тента, зависящий от количества игроков на сервере;
- Можно посмотреть счёт прошлого матча путём открытия таблицы и зажатия клавиши Shift;
- Отключён AFK-пенальти;
- Открыта верхняя граница карты для игроков;
- Добавлено второе колесо эмоций для собственного пака;
- Система кастомных биндингов, вызывается через /bindings;
- Система переводов конкретно для мода.

## Визуальные изменения
- Наблюдатели имеют полноценную табличку;
- У наблюдателей отображается голова в таблице (кроме случаев, если используется голова из DLC или стандартного пака);
- Добавлены груши к табличке с информацией об сервере :);
- Игроки могут иметь кастомную голову без прописывания их в accolade_data.cfg;
- Путём хардкода, игрокам можно присваивать кастомное тело, менять цвета у никнейма и клантега;
- Когда рыцарь держит дрель, у него меняется курсор, при попытке дрелить в зоне вражеской базы курсор заменяется на перечёркнутую версию;
- Если у человека установлен определённый клантег, то после числа КДР у него будет отображаться иконка этого клана.

## Фиксы
- Пофикшены бомбджампы, как обычные, так и с кегой.

