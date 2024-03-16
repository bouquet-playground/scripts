#!/bin/bash

TOKEN=" "
CHAT_ID=" "
file_path=" "

send_telegram_message() {
    local message="$1"
    curl -s -X POST \
        https://api.telegram.org/bot$TOKEN/sendMessage \
        -d chat_id=$CHAT_ID \
        -d text="$message" \
        -d parse_mode="Markdown"
}

upload_logs() {
    local response=$(cat build_logs.txt | curl -F 'sprunge=<-' http://sprunge.us)
    local url=$(echo "$response" | grep -oP 'https?://\S+')
    send_telegram_message "Fail: Build failed.%0ALogs uploaded successfully.%0ALog URL: $url"
}

# Function to upload file and get download link
upload_file() {
    local file_path="$1"
    # Execute upload.sh with file path as argument and capture its output
    download_link=$(bash upload.sh "$file_path")
    if [ -n "$download_link" ]; then
        send_telegram_message "%0A$download_link"
    fi
}


send_telegram_message "Your Build has been started!"

bash build.sh > build_logs.txt 2>&1

if [ $? -eq 0 ]; then
    echo "Build completed, notifying on Telegram"
    send_telegram_message "Your Build is successfully completed!"
    echo "Uploading Build!"
    upload_file "$file_path"
else
    upload_logs
fi
