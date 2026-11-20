#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [ -f "$ENV_FILE" ]; then
    source "$ENV_FILE"
fi

PHPVERSION="${PHPVERSION:?Переменная PHPVERSION не задана}"
IMAGE_NAME="teranyu/bitrix_php:${PHPVERSION}"
CONTAINER_NAME="bitrix-test-${PHPVERSION}-$$"

echo "========================================="
echo "Тестирование образа: ${IMAGE_NAME}"
echo "========================================="

cleanup() {
    echo "Остановка контейнера ${CONTAINER_NAME}..."
    docker rm -f "$CONTAINER_NAME" 2>/dev/null || true
}
trap cleanup EXIT

docker run -d --name "$CONTAINER_NAME" -p "18080:80" "$IMAGE_NAME"

echo "Ожидание запуска Apache..."
for i in $(seq 1 30); do
    if curl -s -o /dev/null -w "%{http_code}" "http://localhost:18080" 2>/dev/null | grep -qE "^[2345]"; then
        break
    fi
    sleep 1
done

echo "--- Проверка PHP ---"
PHP_VERSION=$(docker exec "$CONTAINER_NAME" php -v 2>&1 | head -1)
echo "PHP: ${PHP_VERSION}"

echo "--- Проверка Apache ---"
HTTP_CODE=$(curl -s -o /dev/null -w "%{http_code}" "http://localhost:18080" 2>/dev/null || echo "000")
echo "HTTP статус: ${HTTP_CODE}"

echo "--- Проверка расширений ---"
EXTENSIONS=$(docker exec "$CONTAINER_NAME" php -m 2>&1 | tr '\n' ', ')
echo "Модули: ${EXTENSIONS}"

echo "--- Проверка composer ---"
COMPOSER_VER=$(docker exec "$CONTAINER_NAME" composer --version 2>&1 | head -1)
echo "Composer: ${COMPOSER_VER}"

REQUIRED_EXTENSIONS="pdo_mysql mysqli curl zip intl mbstring gd"
MISSING=""
for ext in $REQUIRED_EXTENSIONS; do
    if ! docker exec "$CONTAINER_NAME" php -m 2>/dev/null | grep -qi "^${ext}$"; then
        MISSING="${MISSING} ${ext}"
    fi
done

if [ -n "$MISSING" ]; then
    echo "ОШИБКА: Отсутствуют расширения:${MISSING}"
    exit 1
fi

if [ "$HTTP_CODE" = "000" ]; then
    echo "ОШИБКА: Apache не отвечает"
    exit 1
fi

echo "========================================="
echo "Все проверки пройдены ✓"
echo "========================================="
