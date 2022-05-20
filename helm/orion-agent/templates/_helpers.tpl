{{/*
Expand the name of the chart.
*/}}
{{- define "prefect-agent.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "prefect-agent.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "prefect-agent.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "prefect-agent.labels" -}}
helm.sh/chart: {{ include "prefect-agent.chart" . }}
{{ include "prefect-agent.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "prefect-agent.selectorLabels" -}}
app.kubernetes.io/name: {{ include "prefect-agent.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "prefect-agent.apiUrl" -}}
{{- if not .Values.serviceAccount.create }}
{{- default (include "prefect-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}
#  "https://api-beta.prefect.io/api/accounts/{{ .Values.agent.prefectCloudAccountId }}/workspaces/{{ .Values.agent.prefectWorkspaceId }}"

{{/*
Create the name of the service account to use
*/}}
{{- define "prefect-agent.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "prefect-agent.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
  env-unrap: 
    Converts a nested dictionary with keys `prefix` and `map`
    into a list of environment variable definitions, where each
    variable name is an uppercased concatenation of keys in the map
    starting with the original prefix and descending to each leaf.
    The variable value is then the quoted value of each leaf key.
*/}}
{{- define "env-unwrap" -}}
{{- $prefix := .prefix -}}
{{/* Iterate through all keys in the current map level */}}
{{- range $key, $val := .map -}}
{{- $key := upper $key -}}
{{/* Create an environment variable if this is a leaf */}}
{{- if ne (typeOf $val | toString) "map[string]interface {}" }}
- name: {{ printf "%s__%s" $prefix $key }}
  value: {{ $val | quote }}
{{/* Otherwise, recurse into each child key with an updated prefix */}}
{{- else -}}
{{- $prefix := (printf "%s__%s" $prefix $key) -}}
{{- $args := (dict "prefix" $prefix "map" $val)  -}}
{{- include "env-unwrap" $args -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
  prefect-agent.envConfig:
    Define environment variables for prefect config.
    Includes a constant set of common variables as well as 
    generated environment variables from .Values.prefectConfig 
    using "env-unwrap"
*/}}
{{- define "prefect-agent.envConfig" -}}
- name: PREFECT_DEBUG_MODE
  value: {{ .Values.agent.debug_enabled | quote }}
- name: PREFECT_ORION_DATABASE_CONNECTION_URL
  valueFrom:
    {{- include "prefect-agent.postgres-secret-ref" . | nindent 4 }}
{{- $args := (dict "prefix" "PREFECT_SERVER" "map" .Values.prefectConfig) -}}
{{- include "env-unwrap" $args -}}
{{- end }}