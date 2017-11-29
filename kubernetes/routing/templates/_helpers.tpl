{{/* Expand the name of the chart.*/}}
{{- define "env.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create a default fully qualified app name. */}}
{{- define "env.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "env.domainSuffix" -}}
{{- printf "%s.%s" .Values.envName .Values.baseDomain -}}
{{- end -}}