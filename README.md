# <h1 align="center">Kubernetes & Helm feat. Terraform</a>

### Helm | implementing testing

I have a simple Django application in my Chart so the most common target for testing is the Endpoint testing. For this purpose `test-connection.yaml` test template under `/tests` directory was added. The content of my testing template is:

```
apiVersion: v1
kind: Pod
metadata:
  namespace: {{ include "django-demo.namespace" . }}
  name: "{{ include "django-demo.fullname" . }}-test-connection"
  labels:
    {{- include "django-demo.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['{{ include "django-demo.fullname" . }}:{{ .Values.service.port }}']
  restartPolicy: Never
```

The `args value` for the `wget` command inside the `busybox` container will match with the `service name` and `service port number` of the application.

The rendered variant after running `helm secrets template` looks like:

```
---
# Source: django-demo/templates/tests/test-connection.yaml
apiVersion: v1
kind: Pod
metadata:
  namespace: application
  name: "syndicate-django-demo-test-connection"
  labels:
    helm.sh/chart: django-demo-0.1.4
    app.kubernetes.io/name: django-demo
    app.kubernetes.io/instance: syndicate
    app.kubernetes.io/version: "1.1-stable-nonroot"
    app.kubernetes.io/managed-by: Helm
  annotations:
    "helm.sh/hook": test
spec:
  containers:
    - name: wget
      image: busybox
      command: ['wget']
      args: ['syndicate-django-demo:8080']
  restartPolicy: Never
```
For getting the result `helm test <release-name>` command is used:

![image](https://github.com/digitalake/helm-advanced/assets/109740456/8052cb34-4d3d-4009-a204-2f450da546de)

### Helm | about hooks 

Hooks can be used in different time depending on the hook type for performing some actions. In my case i had no special options, but can give an example of `pre-install` job for testing application database.
```
apiVersion: batch/v1
kind: Job
metadata:
  name: {{ include "django-demo.fullname" . }}
  labels:
    {{- include "django-demo.labels" . | nindent 4 }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-5"
    "helm.sh/hook-delete-policy": hook-succeeded
spec:
  template:
    metadata:
      name: {{ include "django-demo.fullname" . }}
      namespace: {{ include "django-demo.namespace" . }}
    spec:
      restartPolicy: Never
      containers:
      - name: db-connection-test
        image: postgres:latest
        command: ["sh", "-c", "psql $DATABASE_URL -c \"SELECT version();\""]
        envFrom:
          - secretRef:
              name: {{ include "django-demo.fullname" . }}
```

Also the secret will be needed:

```
apiVersion: v1
kind: Secret
metadata:
  name: {{ include "django-demo.fullname" . }}
  namespace: {{ include "django-demo.namespace" . }}
  annotations:
    "helm.sh/hook": pre-install
    "helm.sh/hook-weight": "-10"
    "helm.sh/hook-delete-policy": hook-succeeded
data:
  DATABASE_URL: {{ .Values.databaseURL | b64enc | quote }}
```

The `helm.sh/hook-weight` defines the order for hooks executing (ascending order).



 



