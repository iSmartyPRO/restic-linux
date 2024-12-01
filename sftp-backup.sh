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
BACKUP_SOURCE=$(jq -r '.backup_source' "$CONFIG_FILE")
RESTIC_PASSWORD=$(jq -r '.restic.password' "$CONFIG_FILE")
RESTIC_REPO=$(jq -r '.restic.repo' "$CONFIG_FILE")
KEEP_LAST=$(jq -r '.restic.RetentionPolicy.KeepLast' "$CONFIG_FILE")
KEEP_DAILY=$(jq -r '.restic.RetentionPolicy.KeepDaily' "$CONFIG_FILE")
KEEP_WEEKLY=$(jq -r '.restic.RetentionPolicy.KeepWeekly' "$CONFIG_FILE")
KEEP_MONTHLY=$(jq -r '.restic.RetentionPolicy.KeepMonthly' "$CONFIG_FILE")
KEEP_YEARLY=$(jq -r '.restic.RetentionPolicy.KeepYearly' "$CONFIG_FILE")

# Создание папки logs, если она не существует
LOG_DIR="./logs"
mkdir -p "$LOG_DIR"

# Имя файла лога и статуса
LOG_FILE="$LOG_DIR/${LOG_NAME}.log"
STATUS_FILE="$LOG_DIR/${LOG_NAME}_status.log"

# Функция для логирования с датой и временем
log() {
  echo "$(date '+%Y-%m-%d %H:%M:%S') $1" | tee -a "$LOG_FILE"
}

# Проверка установленных зависимостей
if ! command -v jq &> /dev/null || ! command -v restic &> /dev/null; then
  log "Требуемые зависимости jq или restic не установлены."
  echo "Bad" > "$STATUS_FILE"
  exit 1
fi

# Установка пароля для Restic
export RESTIC_PASSWORD="$RESTIC_PASSWORD"

# Логирование начала скрипта
START_TIME=$(date +%s)
log "Начало выполнения скрипта."

# Выполнение резервного копирования
log "Выполнение резервного копирования из $BACKUP_SOURCE..."
restic -r "$RESTIC_REPO" backup "$BACKUP_SOURCE" &>> "$LOG_FILE"

if [ $? -ne 0 ]; then
  log "Ошибка при выполнении резервного копирования."
  echo "Bad" > "$STATUS_FILE"
  exit 1
else
  log "Резервное копирование выполнено успешно."
fi

# Применение политики хранения
log "Применение политики хранения..."
restic -r "$RESTIC_REPO" forget \
  --keep-last "$KEEP_LAST" \
  --keep-daily "$KEEP_DAILY" \
  --keep-weekly "$KEEP_WEEKLY" \
  --keep-monthly "$KEEP_MONTHLY" \
  --keep-yearly "$KEEP_YEARLY" \
  --prune &>> "$LOG_FILE"

if [ $? -ne 0 ]; then
  log "Ошибка при применении политики хранения."
  echo "Bad" > "$STATUS_FILE"
  exit 1
else
  log "Политика хранения применена успешно."
fi

# Проверка целостности репозитория
log "Проверка целостности репозитория..."
restic -r "$RESTIC_REPO" check &>> "$LOG_FILE"

if [ $? -ne 0 ]; then
  log "Ошибка при проверке репозитория."
  echo "Bad" > "$STATUS_FILE"
  exit 1
else
  log "Проверка репозитория выполнена успешно."
fi

# Логирование окончания скрипта
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))
log "Скрипт завершен."
log "Длительность выполнения: ${DURATION} секунд."

# Запись статуса OK при успешном выполнении
echo "OK" > "$STATUS_FILE"
