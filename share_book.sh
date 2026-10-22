#!/bin/bash
# Download one book, uploads it to a private bucket and prints a URL
set -euo pipefail

# check for the three arguments
if [ "$#" -lt 3 ]; then
    echo "Usage: $0 BOOK_URL BUCKET EXPIRES_SECONDS"
    exit 1
fi

URL="$1"
BUCKET="$2"
EXPIRES="$3"
FILE="$(basename "$URL")"

# download the book into books/
mkdir -p books
curl -fsSL "$URL" -o "books/$FILE"

if ! aws s3 ls "s3://$BUCKET" > /dev/null 2>&1; then
    aws s3 mb "s3://$BUCKET"
fi

# upload the book
aws s3 cp "books/$FILE" "s3://$BUCKET/$FILE" --content-type "text/plain; charset=utf-8"

# presign a url that expires after given time, and print it
aws s3 presign "s3://$BUCKET/$FILE" --expires-in "$EXPIRES"
