{{/*
Expand the name of the chart.
*/}}
{{- define "orion.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "orion.fullname" -}}
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
{{- define "orion.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "orion.labels" -}}
helm.sh/chart: {{ include "orion.chart" . }}
{{ include "orion.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "orion.selectorLabels" -}}
app.kubernetes.io/name: {{ include "orion.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "orion.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "orion.fullname" .) .Values.serviceAccount.name }}
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
  orion.postgres-hostname: 
    Generate the hostname of the postgresql service
    If a subchart is used, evaluate using its fullname function
      as {subchart.fullname}-{namespace}
    Otherwise, the configured external hostname will be returned
*/}}
{{- define "orion.postgres-hostname" -}}
{{- if .Values.postgresql.useSubChart -}}
  {{- $subchart_overrides := .Values.postgresql -}}
  {{- $name := include "postgresql.fullname" (dict "Values" $subchart_overrides "Chart" (dict "Name" "postgresql") "Release" .Release) -}}
  {{- printf "%s.%s" $name .Release.Namespace -}}
{{- else -}}
  {{- .Values.postgresql.externalHostname -}}
{{- end -}}
{{- end -}}
{{/* 
  orion.postgres-connstr:
    Generates the connection string for the postgresql service
    NOTE: Does not include password, which should be set via
      secret in PGPASSWORD on containers.
*/}}
{{- define "orion.postgres-connstr" -}}
{{- $user := .Values.postgresql.postgresqlUsername -}}
{{- $pass := .Values.postgresql.postgresqlPassword -}}
{{- $host := include "orion.postgres-hostname" . -}}
{{- $port := .Values.postgresql.servicePort | toString -}}
{{- $db := .Values.postgresql.postgresqlDatabase -}}
{{- printf "postgresql+asyncpg://%s:%s@%s:%s/%s" $user $pass $host $port $db -}}
{{- end -}}
{{/*
  orion.postgres-secret-name:
    Get the name of the secret to be used for the postgresql
    user password. Generates {release-name}-postgresql if
    an existing secret is not set.
*/}}
{{- define "orion.postgres-secret-name" -}}
{{- if .Values.postgresql.existingSecret -}}
  {{- .Values.postgresql.existingSecret -}}
{{- else -}}
  {{- printf "%s-%s" .Release.Name "postgresql" -}}
{{- end -}}
{{- end -}}
{{/*
  orion.postgres-secret-ref:
    Generates a reference to the postgreqsql connection-string password
    secret. 
*/}}
{{- define "orion.postgres-secret-ref" -}}
secretKeyRef:
  name: {{ include "orion.postgres-secret-name" . }}
  key: connection-string
{{- end -}}


{{/*
  orion.envConfig:
    Define environment variables for prefect config.
    Includes a constant set of common variables as well as 
    generated environment variables from .Values.prefectConfig 
    using "env-unwrap"
*/}}
{{- define "orion.envConfig" -}}
- name: PREFECT_DEBUG_MODE
  value: {{ .Values.api.debug_enabled | quote }}
- name: PREFECT_ORION_DATABASE_CONNECTION_URL
  valueFrom:
    {{- include "orion.postgres-secret-ref" . | nindent 4 }}
{{- $args := (dict "prefix" "PREFECT_SERVER" "map" .Values.prefectConfig) -}}
{{- include "env-unwrap" $args -}}
{{- end }}