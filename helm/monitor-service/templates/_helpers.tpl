{{/*
Имя chart и его версия для лейбла helm.sh/chart.
*/}}
{{- define "monitor-service.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Общие лейблы компонента.
Вызов: include "monitor-service.labels" (dict "component" "gateway" "root" .)
*/}}
{{- define "monitor-service.labels" -}}
app.kubernetes.io/name: {{ .component }}
app.kubernetes.io/part-of: site-monitor
app.kubernetes.io/instance: {{ .root.Release.Name }}
app.kubernetes.io/managed-by: {{ .root.Release.Service }}
helm.sh/chart: {{ include "monitor-service.chart" .root }}
{{- end }}

{{/*
Лейблы селектора. Только name: так же, как в текущих Deployment.
*/}}
{{- define "monitor-service.selectorLabels" -}}
app.kubernetes.io/name: {{ .component }}
{{- end }}
