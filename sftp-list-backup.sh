#!/bin/bash

# Проверка наличия параметра --config
if [ "$1" != "--config" ] || [ -z "$2" ]; then
  echo "Использование: $0 --config <путь_к_конфигурационному_файлу> <snapshot_id>"
  exit 1
fi

# Путь к файлу конфигурации
CONFIG_FILE="$2"

# Проверка наличия ID снимка
if [ -z "$3" ]; then
  echo "Укажите ID снимка."
  exit 1
fi

# Чтение параметров из файла JSON
RESTIC_PASSWORD=$(jq -r '.restic.password' "$CONFIG_FILE")
RESTIC_REPO=$(jq -r '.restic.repo' "$CONFIG_FILE")
SNAPSHOT_ID="$3"

# Проверка установленных зависимостей
if ! command -v jq &> /dev/null || ! command -v restic &> /dev/null; then
  echo "Требуемые зависимости jq или restic не установлены."
  exit 1
fi

# Установка пароля для Restic
export RESTIC_PASSWORD="$RESTIC_PASSWORD"

# Просмотр содержимого снимка
restic -r "$RESTIC_REPO" ls "$SNAPSHOT_ID"
