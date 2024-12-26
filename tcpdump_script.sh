#!/bin/bash

OUTPUT_DIR="/mnt/tcpdump"      # Каталог для сохранения логов
FILE_PREFIX="vm-261224-tcpdump_log"          # Префикс для файлов
MAX_DISK_USAGE=90                 # Максимальный объем диска для логов (в ГБ)
FILE_SIZE=100                     # Максимальный размер файла (в МБ)
INTERFACE="ens192"                   # Интерфейс для прослушивания
PORT="51773"                       # Порт для прослушивания


# Функция для проверки и очистки места
clean_old_files() {
    local total_size
    total_size=$(du -sm "$OUTPUT_DIR" | awk '{print $1}') # Текущий объем в МБ

    while [ "$total_size" -gt $((MAX_DISK_USAGE * 1024)) ]; do
        oldest_file=$(ls -1t "$OUTPUT_DIR" | tail -1) # Находим самый старый файл
        echo "Удаляем старый файл: $OUTPUT_DIR/$oldest_file"
        rm -f "$OUTPUT_DIR/$oldest_file"
        total_size=$(du -sm "$OUTPUT_DIR" | awk '{print $1}')
    done
}

generate_filename() {
    echo "$OUTPUT_DIR/${FILE_PREFIX}_$(date '+%Y%m%d%H%M%S').pcap"
}

while true; do
    FILENAME=$(generate_filename)
    echo "Начинается запись в файл $FILENAME"
    tcpdump -i "$INTERFACE" -w "$FILENAME" -C "$FILE_SIZE" port "$PORT" -tttt -Z root &
    TCPDUMP_PID=$!

    # Ожидаем завершения записи одного файла
    wait $TCPDUMP_PID

    # Проверяем и очищаем старые файлы
    clean_old_files
done


