# Bitrix PHP Docker

Docker-окружение для разработки и деплоя Bitrix с поддержой нескольких версий PHP.

## Быстрый старт

```bash
cp .env_example .env
# При необходимости измените PHPVERSION в .env
docker-compose up -d
```

## Версии PHP

Выбирается через `PHPVERSION` в `.env`:

| Значение | PHP |
|----------|-----|
| php74 | 7.4 |
| php81 | 8.1 |
| php82 | 8.2 |
| php83 | 8.3 |
| php8337 | 8.3.37 |
| php84 | 8.4 |

## Локальная сборка

```bash
./build.sh
```

Соберёт образ версии из `.env`.

## Тестирование

```bash
./test.sh
```

Проверит Apache, PHP и необходимые расширения.

## Docker images

Образы публикуются в GHCR при создании тега:

```bash
docker pull ghcr.io/teranyu/bitrix_php:php8337
docker pull ghcr.io/teranyu/bitrix_php:latest
```

## Структура

```
bin/          # Dockerfile для каждой версии PHP
config/       # Конфигурация (php.ini, vhosts, mysql)
build.sh      # Скрипт сборки
test.sh       # Скрипт тестирования
```

## CI/CD

GitHub Actions автоматически:
- Собирает образ текущей версии из `.env`
- Тестирует (Apache, PHP, расширения, composer)
- Публикует в GHCR и создаёт Release при push тега `v*`
