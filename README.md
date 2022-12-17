# Отдельные скрипты по установке некоторых нод
## Порядок установки
1. До установки переустановить ОС на сервере. Ставим ноду на чистый сервер
2. До установки любого скрипта лучше использовать screen:
```
apt install -y screen curl
screen -S install
```
3. Копируем путь к файлу скрипта из [таблицы ниже](https://github.com/avkarcr/node_scripts/blob/main/README.md#%D0%BF%D0%B5%D1%80%D0%B5%D1%87%D0%B5%D0%BD%D1%8C-%D0%BD%D0%BE%D0%B4-%D0%B8-%D0%BD%D0%B0%D0%B7%D0%B2%D0%B0%D0%BD%D0%B8%D0%B9-%D1%84%D0%B0%D0%B9%D0%BB%D0%BE%D0%B2) в буфер обмена (например, файл называется NODE_INSTALL.sh)
4. Скачиваем скрипт командой (curl -sO ПУТЬ-К-ФАЙЛУ), где O - это большая буква O (Output)
```
curl -sO https://raw.githubusercontent.com/avkarcr/node_scripts/main/nolus_install.sh
```
5. Обновляем права доступа
```
chmod +x nolus_install.sh
```
6. Запускаем файл на сервере
```
cd ~ && ./nolus_install.sh
```
## Перечень нод и названий файлов:
| Название | Тип ноды (если применимо) | Файл скрипта |
| :--- | :--- | :--- |
| Nolus | Full Node | [nolus_install.sh](https://raw.githubusercontent.com/avkarcr/node_scripts/main/nolus_install.sh) |
| Nolus | Full Node | [nolus_install_wo_cosmovisor.sh](https://raw.githubusercontent.com/avkarcr/node_scripts/main/nolus_install_wo_cosmovisor.sh) |
