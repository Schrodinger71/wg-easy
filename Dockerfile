FROM docker.io/library/node:18-alpine AS build_node_modules

# Copy Web UI
COPY src/ /app/
WORKDIR /app
RUN npm ci --production

FROM docker.io/library/node:18-alpine

# Установка необходимых пакетов: iptables, wireguard-tools, dumb-init и iproute2 (для tc)
RUN apk add -U --no-cache \
  iptables \
  wireguard-tools \
  dumb-init \
  iproute2

COPY --from=build_node_modules /app /app

RUN mv /app/node_modules /node_modules

WORKDIR /app

# Добавляем скрипт с настройкой tc
COPY apply_tc.sh /usr/local/bin/apply_tc.sh
RUN chmod +x /usr/local/bin/apply_tc.sh

# Запускаем скрипт настройки трафика в фоне и затем сервер wg-easy
CMD /usr/local/bin/apply_tc.sh & /usr/bin/dumb-init node server.js

EXPOSE 51820/udp
EXPOSE 51821/tcp

ENV DEBUG=Server,WireGuard
