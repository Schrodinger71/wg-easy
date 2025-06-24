#!/bin/sh
# Ждём, пока интерфейс wg0 появится (до 10 секунд)
for i in $(seq 1 10); do
  if ip link show wg0 >/dev/null 2>&1; then
    break
  fi
  sleep 1
done

# Удаляем старые qdisc если есть
tc qdisc del dev wg0 root 2>/dev/null

# Добавляем новый qdisc с ограничением
tc qdisc add dev wg0 root handle 1: htb default 30
tc class add dev wg0 parent 1: classid 1:1 htb rate 5mbit ceil 10mbit
tc filter add dev wg0 protocol ip parent 1: prio 1 u32 match ip dst 0.0.0.0/0 flowid 1:1
