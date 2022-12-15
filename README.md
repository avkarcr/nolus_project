# Отдельные скрипты по установке некоторых нод
## Порядок установки
1. До установки переустановить ОС на сервере. Ставим ноду на чистый сервер
2. До установки любого скрипта лучше использовать screen:
```
apt install -y screen curl
screen -S install
```
3. Копируем путь к файлу скрипта из таблицы ниже в буфер обмена (например, файл называется NODE_INSTALL.sh)
4. Скачиваем скрипт командой (curl -sO ПУТЬ-К-ФАЙЛУ), где O - это большая буква O (Output)
```
curl -sO https://raw.githubusercontent.com/avkarcr/node_scripts/main/NODE_INSTALL.sh
```
5. Обновляем права доступа
```
chmod +x NODE_INSTALL.sh
```
6. Запускаем файл на сервере из домашней папки
```
cd ~ && ./NODE_INSTALL.sh
```
## Перечень нод и названий файлов:
| Название | Тип ноды (если применимо) | Файл скрипта |
| :--- | :--- | :--- |
| Nolus | Full Node | [nolus_node_install.sh](https://raw.githubusercontent.com/avkarcr/node_scripts/main/nolus_install.sh) |
