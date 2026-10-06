# site-monitor-infrastructure

[![CD](https://github.com/VictorNikolaevichD/site-monitor-infrastructure/actions/workflows/cd.yaml/badge.svg)](https://github.com/VictorNikolaevichD/site-monitor-infrastructure/actions/workflows/cd.yaml)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-326CE5?logo=kubernetes&logoColor=white)](#)
[![Helm](https://img.shields.io/badge/Helm-0F1689?logo=helm&logoColor=white)](#)
[![kind](https://img.shields.io/badge/kind-326CE5?logo=kubernetes&logoColor=white)](#)
[![Docker](https://img.shields.io/badge/Docker-2496ED?logo=docker&logoColor=white)](#)
[![NGINX](https://img.shields.io/badge/ingress--nginx-009639?logo=nginx&logoColor=white)](#)

Манифесты Kubernetes и Helm chart для [site-monitor](https://github.com/ViktorNikolaevichD/site-monitor). Локальный кластер kind.

Стек целиком: gateway, monitor, notification, PostgreSQL, Kafka, миграции. Снаружи — Ingress на `site-monitor.local`. Конфиг в ConfigMap, пароли в Secret, смена конфига перезапускает поды через Reloader. У monitor пробы liveness и readiness. HPA масштабирует gateway от 1 до 3 реплик по CPU и памяти. Установка — один релиз Helm, с отдельными values для dev и prod.

Monitor остаётся в одной реплике: планировщик проверок без выбора лидера.

---

## Запуск

Docker, kubectl, Helm, kind. Образы приложения собираются в репозитории [site-monitor](https://github.com/ViktorNikolaevichD/site-monitor) и загружаются в узел. Postgres и Kafka кластер скачивает сам.

```bash
docker build -t site-monitor:dev -f Dockerfile .
docker build -t site-monitor-gateway:dev -f Dockerfile.gateway .
docker build -t site-monitor-notification:dev -f Dockerfile.notification .
docker build -t site-monitor-migrate:dev -f Dockerfile.migrate .
```

```bash
kind create cluster --config kind/cluster.yaml
kind load docker-image \
  site-monitor:dev \
  site-monitor-gateway:dev \
  site-monitor-notification:dev \
  site-monitor-migrate:dev \
  --name site-monitor
```

```bash
kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/main/deploy/static/provider/kind/deploy.yaml
kubectl apply -f https://raw.githubusercontent.com/stakater/Reloader/master/deployments/kubernetes/reloader.yaml
kubectl apply -f https://github.com/kubernetes-sigs/metrics-server/releases/latest/download/components.yaml
kubectl -n kube-system patch deployment metrics-server --type='json' \
  -p='[{"op":"add","path":"/spec/template/spec/containers/0/args/-","value":"--kubelet-insecure-tls"}]'
```

В `/etc/hosts`: `127.0.0.1 site-monitor.local`.

```bash
cp helm/monitor-service/values-secrets.example.yaml helm/monitor-service/values-secrets.yaml
helm install monitor helm/monitor-service \
  --namespace site-monitor \
  --create-namespace \
  -f helm/monitor-service/values-dev.yaml \
  -f helm/monitor-service/values-secrets.yaml
```

```bash
curl -sS http://site-monitor.local/health
```

Сырые манифесты — каталог `k8s/`. Секреты для них: `k8s/*/secret.example.yaml`. Chart эти файлы не читает.

---

## Структура

```text
kind/cluster.yaml            — кластер kind, порты 80 и 443
k8s/                         — манифесты kubectl
helm/monitor-service/        — chart
```

---

## Лицензия

[MIT](LICENSE)
