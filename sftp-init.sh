#!/bin/bash

# Проверка наличия параметра --config
if [ "$1" != "--config" ] || [ -z "$2" ]; then
  echo "Использование: $0 --config <путь_к_конфигурационному_файлу>"
  exit 1
fi

# Путь к файлу конфигурации
CONFIG_FILE="$2"

# Проверка существования файла конфигурации
if [ ! -f "$CONFIG_FILE" ]; then
  echo "Файл конфигурации $CONFIG_FILE не найден."
  exit 1
fi

# Чтение параметров из файла JSON
LOG_NAME=$(jq -r '.name' "$CONFIG_FILE")
RESTIC_PASSWORD=$(jq -r '.restic.password' "$CONFIG_FILE")
RESTIC_REPO=$(jq -r '.restic.repo' "$CONFIG_FILE")

# Создание папки logs, если она не существует
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

# Имя файла лога
LOG_FILE="$LOG_DIR/${LOG_NAME}.log"

# Проверка установленных зависимостей
if ! command -v jq &> /dev/null || ! command -v restic &> /dev/null; then
  echo "Требуемые зависимости jq или restic не установлены." | tee -a "$LOG_FILE"
  exit 1
fi

# Установка пароля для Restic
export RESTIC_PASSWORD="$RESTIC_PASSWORD"

# Инициализация репозитория Restic, если он ещё не существует
if ! restic -r "$RESTIC_REPO" snapshots &>> "$LOG_FILE"; then
  echo "Инициализация нового репозитория Restic..." | tee -a "$LOG_FILE"
  restic -r "$RESTIC_REPO" init &>> "$LOG_FILE"
  if [ $? -ne 0 ]; then
    echo "Ошибка при инициализации репозитория Restic." | tee -a "$LOG_FILE"
    exit 1
  fi
else
  echo "Репозиторий Restic уже существует." | tee -a "$LOG_FILE"
fi

echo "Скрипт завершен." | tee -a "$LOG_FILE"
