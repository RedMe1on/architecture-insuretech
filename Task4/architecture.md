# Task4: Архитектура сервиса Osago-Aggregator

## Решения по osago-aggregator

### Хранилище данных
**Да, требуется своё хранилище.** Причины:
- Хранение статуса заявок (pending/processing/completed)
- Кэширование промежуточных результатов от страховых компаний
- Агрегация предложений до возврата в core-app
- Хранение контекста polling для long-running операций

**Рекомендация:** Redis для кэша + PostgreSQL для персистентного хранения

### API osago-aggregator для core-app

```
POST   /api/v1/osago/applications          - создать заявку
GET    /api/v1/osago/applications/{id}      - получить статус/предложения
DELETE /api/v1/osago/applications/{id}      - отменить заявку
```

**Важно:** Для real-time обновлений использовать **WebSocket/SSE**:
```
WS /api/v1/osago/applications/{id}/stream  - stream предложений по мере поступления
```

### Средство интеграции core-app → osago-aggregator
**REST + Circuit Breaker** (Polly или аналог)

```
┌──────────┐      REST/GQL       ┌─────────────────┐
│ core-app │ ──────────────────► │ osago-aggregator │
└──────────┘                     └─────────────────┘
         ▲                               │
         │    WebSocket/SSE updates      │
         └───────────────────────────────┘
```

---

## API для веб-приложения (core-app)

```
POST   /api/osago/submit                    - создать заявку
GET    /api/osago/status/{id}               - получить статус
WS     /api/osago/ws/{id}                   - real-time предложения
```

### Средство интеграции веб-приложение → core-app
**WebSocket (WSS)** или **Server-Sent Events (SSE)**

Выбор: **WebSocket** - двунаправленная коммуникация, лучше для интерактивных UI

---

## Паттерны отказоустойчивости

### Rate Limiting
- На **API Gateway**: ограничение 2500 RPS (пиковая нагрузка)
- На **osago-aggregator**: лимит на партнёров страховых компаний

### Circuit Breaker
- На **osago-aggregator** при вызовах к страховым компаниям
- На **core-app** при вызовах к osago-aggregator

### Retry
- При вызовах к страховым компаниям: 3 попытки с exponential backoff
- При вызовах к osago-aggregator: 2 попытки

### Timeout
- Страховые компании: **60 секунд** (бизнес-требование)
- osago-aggregator → core-app: **5 секунд**

---

## Масштабирование (multi-instance)

Решения учитывают multi-instance деплой:

1. **osago-aggregator** - stateless, горизонтально масштабируется
2. **WebSocket** - sticky sessions через Redis pub/sub для broadcast
3. **Redis** - общий для всех инстансов (status sync)
4. **Circuit Breaker** - per-instance, но с shared state через Redis
5. **Rate Limiting** - централизованный через API Gateway или Redis

---

## Поток данных

```
Пользователь → Web App → core-app → osago-aggregator
                                     ↓
                              Страховые компании (5 шт)
                                     ↓
                              osago-aggregator (poll)
                                     ↓
                              WebSocket → Web App
                                     ↓
                              Пользователь видит предложение
```

**Примечание:** osago-aggregator использует polling к страховым компаниям, 
т.к. они предоставляют sync API. Максимум 60 сек на ответ.

---

## Диаграмма архитектуры

См. `osago_architecture.drawio`