# <h1 align="center">Kubernetes & Helm feat. Terraform</a>

### Short description

In this repo You can find:

  - Terraform code for deploying:
    -  `Digital Ocean Kubernetes Service`(DOKS)
    -  `Digital Ocean Managed Database` (In this case Postgres12)
    -  some additional resources (firewall, db-user, db etc.)
  - Helm Chart code for deploying:
    - application `Namespace`
    - application `ConfigMap`
    - application `Secret` (from Helm Secrets)
    - application `Deployment`
    - application `Service` (ClusterIP)
    - NginX ingress controller + NginX `Ingress`
    - CertManager + `Issuer`
    - `HorizontalPodAutoscaler`
  - `Helmfile` for deploying the environment
  - Some instructions and project description

### Terraform

Using Terraform is the best way of managing Cloud resources such as Kubernetes clusters. For this particular task I used Terraform for defining resources in DigitalOcean Cloud with the help of [digitalocean](https://registry.terraform.io/providers/digitalocean/digitalocean/latest/docs) Terraform provider. Instead of providing `secret access key` and `access key id` DigitalOcean gives an option to use `access token` which can be provided via env variable:

```
export DIGITALOCEAN_ACCESS_TOKEN=<token-value>
```

My Terraform configuration also uses `autoupgrade=true` option for the Kubernetes custer. All avaliable versions for the Kubernetes cluster can be described using the `doctl` CLI tool, for example,  woth Docker:

```
docker run -ti --rm -e DIGITALOCEAN_ACCESS_TOKEN  digitalocean/doctl:latest kubernetes options versions
```

> [!IMPORTANT]
>

> [!NOTE]
> The command works fine only if DIGITALOCEAN_ACCESS_TOKEN is exported as a local env var


### Helm

Final `helmchart` directory structure is:

```
.
├── django-demo
│   ├── Chart.lock
│   ├── charts
│   │   ├── cert-manager-v1.13.1.tgz
│   │   ├── ingress-nginx-4.8.1.tgz
│   │   └── metrics-server-3.11.0.tgz
│   ├── Chart.yaml
│   ├── templates
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   ├── hpa.yaml
│   │   ├── ingress.yaml
│   │   ├── issuer.yaml
│   │   ├── NOTES.txt
│   │   ├── ns.yaml
│   │   ├── secret.yaml
│   │   ├── serviceaccount.yaml
│   │   ├── service.yaml
│   │   └── tests
│   │       └── test-connection.yaml
│   └── values.yaml
├── helmfile.yaml
└── helm_secrets
    ├── django_config.yaml
    └── django_secret.yaml
```

In addition to standart values, `Chart.yaml` itself  defines dependencies for the Chart to be included:

```
...
dependencies:
- name: ingress-nginx
  version: "4.8.1"
  repository: "https://kubernetes.github.io/ingress-nginx"

- name: cert-manager
  version: "v1.13.1"
  repository: "https://charts.jetstack.io"
  
- name: metrics-server
  version: "3.11.0"
  repository: "https://kubernetes-sigs.github.io/metrics-server/"
```
  

Task definition requires  

      
1) Running doctl in the container to get avaliable k8s versions 

docker run -ti --rm -e DIGITALOCEAN_ACCESS_TOKEN  digitalocean/doctl:latest kubernetes options versions

DIGITALOCEAN_ACCESS_TOKEN is exported as a local env var

### Deploying resources:

Installing NginX ingress controller:

```
helm repo add ingress-nginx https://kubernetes.github.io/ingress-nginx
helm repo update
k create ns ingress-nginx
helm install ingress-nginx ingress-nginx/ingress-nginx -n ingress-nginx -f kubernetes/nginx-ingress/nginx-values.yml
```

Deploying application with service:

```
k create ns backend
k apply -f kubernetes/manifests/django/deployment.yml
```

Installing Cert-manager:

```
helm repo add jetstack https://charts.jetstack.io
helm repo update jetstack
k create ns cert-manager
helm install cert-manager --namespace cert-manager --version v1.13.1 jetstack/cert-manager -f kubernetes/helm-values/cert-manager/values.yml
```

Deploying issuer

```
k apply -f kubernetes/manifests/cert-manager/issuer.yml
```

Deploying ingress for Application:

```
k apply -f kubernetes/manifests/django/ingress.yml
```

Installing metric server

```
helm repo add metrics-server https://kubernetes-sigs.github.io/metrics-server/
upgrade metrics-server
helm upgrade --install metrics-server metrics-server/metrics-server
```

Deploying hpa for the Application:

```
k apply -f kubernetes/manifests/django/autoscaler.yml
```


helm secrets upgrade syndicate ./django-demo/ -f helm_secrets/django_secret.yaml  -f helm_secrets/django_config.yaml
