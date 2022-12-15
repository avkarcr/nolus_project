# Отдельные скрипты по установке некоторых нод
## Порядок установки
1. До установки переустановить ОС на сервере. Ставим ноду на чистый сервер
2. До установки любого скрипта лучше использовать screen:
```
apt install -y screen curl
screen -S install
```
3. Находим нужный нам скрипт, копируем название файла (допустим это NODE_INSTALL.sh)
4. Скачиваем скрипт командой
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
| Project Name | Node Type | Script Name           |
| ------------ | --------- | --------------------- |
| Nolus        | Full Node | nolus_node_install.sh |
