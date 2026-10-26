#!/bin/sh
# Проверяем, передан ли аргумент
if [ $# -eq 0 ]; then
    echo "Usage: $0 [white|black]"
    exit 1
fi

case "$1" in
    white)
        DEVICE_ID='device_id'
        DEVICE_KEY='device_key'
        DEVICE_IP='device_IP'
        ;;
    black)
        DEVICE_ID='another_device_id'
        DEVICE_KEY='another_device_key'
        DEVICE_IP='another_device_IP'
        ;;
    *)
        echo "Unknown device: $1"
        echo "Available options: white, black"
        exit 1
        ;;
esac

echo "Waiting before powering off $1 ($DEVICE_IP) ..."
sleep 12

send_command() {
    retries=5
    delay=5
    attempt=1

    while [ $attempt -le $retries ]; do
        echo "Attempt $attempt of $retries..."

        # На последней попытке включаем отладку, чтобы увидеть причину сбоя
        if [ "$attempt" -eq "$retries" ]; then
            echo "Last attempt, enabling DEBUG output..."
            output=$(DEBUG='*' tuya-cli set \
                --id "$DEVICE_ID" \
                --key "$DEVICE_KEY" \
                --ip "$DEVICE_IP" \
                --protocol-version 3.4 \
                --dps 1 \
                --set false 2>&1)
        else
            output=$(tuya-cli set \
                --id "$DEVICE_ID" \
                --key "$DEVICE_KEY" \
                --ip "$DEVICE_IP" \
                --protocol-version 3.4 \
                --dps 1 \
                --set false 2>&1)
        fi

        if echo "$output" | grep -q "Set succeeded"; then
            echo "Command succeeded!"
            return 0
        else
            echo "Error detected:"
            echo "$output"
            if [ "$attempt" -lt "$retries" ]; then
                echo "Retrying in $delay seconds..."
                sleep $delay
            fi
            attempt=$((attempt + 1))
        fi
    done

    echo "Failed after $retries attempts."
    return 1
}

send_command
