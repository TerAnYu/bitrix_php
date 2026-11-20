#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
ENV_FILE="${SCRIPT_DIR}/.env"

if [ ! -f "$ENV_FILE" ]; then
    echo "Ошибка: файл .env не найден в ${SCRIPT_DIR}"
    echo "Скопируйте .env_example в .env и заполните настройки"
    exit 1
fi

source "$ENV_FILE"

PHPVERSION="${PHPVERSION:?Переменная PHPVERSION не задана в .env}"
DOCKERFILE_DIR="${SCRIPT_DIR}/bin/${PHPVERSION}"

if [ ! -d "$DOCKERFILE_DIR" ]; then
    echo "Ошибка: директория ${DOCKERFILE_DIR} не найдена"
    echo "Доступные версии:"
    ls -1 "${SCRIPT_DIR}/bin/"
    exit 1
fi

IMAGE_NAME="teranyu/bitrix_php"
IMAGE_TAG="${PHPVERSION}"

echo "========================================="
echo "Сборка образа: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "Dockerfile:    ${DOCKERFILE_DIR}/Dockerfile"
echo "========================================="

docker build -t "${IMAGE_NAME}:${IMAGE_TAG}" "$DOCKERFILE_DIR"

echo "========================================="
echo "Сборка завершена: ${IMAGE_NAME}:${IMAGE_TAG}"
echo "========================================="
docker images "${IMAGE_NAME}" --format "table {{.Repository}}\t{{.Tag}}\t{{.Size}}\t{{.CreatedAt}}"
