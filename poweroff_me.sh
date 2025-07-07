#!/bin/sh

# Проверяем, передан ли аргумент
if [ $# -eq 0 ]; then
    echo "Usage: $0 [white|black]"
    exit 1
fi

# Определяем id и key в зависимости от аргумента
case "$1" in
    white)
        DEVICE_ID='device_id'
        DEVICE_KEY='device_key'
        ;;
    black)
        # Здесь укажите правильные id и key для "black" устройства
        DEVICE_ID='another_device_id'
        DEVICE_KEY='another_device_key'
        ;;
    *)
        echo "Unknown device: $1"
        echo "Available options: white, black"
        exit 1
        ;;
esac

echo "Waiting before powering off $1 ..."
sleep 120

# Функция для отправки команды с повторами
send_command() {
    retries=10
    delay=5
    attempt=1

    while [ $attempt -le $retries ]; do
        echo "Attempt $attempt of $retries..."
        output=$(tuya-cli set --id "$DEVICE_ID" --key "$DEVICE_KEY" --dps 1 --set false 2>&1)
# --dps1 - по сути выполнение изменение параметра 1, который для моей розетки является switch_1, присваиваю ему значение false - выключено. 
        if echo "$output" | grep -q "Set succeeded"; then
            echo "Command succeeded!"
            return 0
        else
            echo "Error detected, retrying in $delay seconds..."
            echo "$output"
            sleep $delay
            attempt=$((attempt + 1))  # Совместимый с sh способ инкремента
        fi
    done

    echo "Failed after $retries attempts"
    return 1
}

# Выполняем команду с повторами
send_command
