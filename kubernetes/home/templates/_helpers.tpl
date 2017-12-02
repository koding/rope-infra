{{/* Expand the name of the chart.*/}}
{{- define "home.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create a default fully qualified app name. */}}
{{- define "home.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "home.ropeServer" -}}
{{- $ropeAdrr := printf "home-home.%s.%s" .Values.envName .Values.baseDomain -}}
{{- default $ropeAdrr .Values.ropeServer -}}
{{- end -}}