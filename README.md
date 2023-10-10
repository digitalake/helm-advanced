# <h1 align="center">Kubernetes & Helm feat. Terraform</a>

> [!IMPORTANT]
> Visit my Django-demo using [link](https://django.itsyndicate.dns.navy)

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

> [!NOTE]
> The command works fine only if DIGITALOCEAN_ACCESS_TOKEN is exported as a local env var

After the succesful `terraform apply`, Kubeconfig is copied into `.kube/config`, to use `kubectl`, You need to run:

```
export KUBECONFIG=<path-to-local-config>
```

### Helm

Final `helmcharts` directory structure is:

```
.
├── django-demo
│   ├── Chart.lock
│   ├── charts
│   │   ├── cert-manager-v1.13.1.tgz
│   │   ├── ingress-nginx-4.8.1.tgz
│   │   └── metrics-server-3.11.0.tgz
│   ├── Chart.yaml
│   ├── .helmignore
│   ├── templates
│   │   ├── configmap.yaml
│   │   ├── deployment.yaml
│   │   ├── _helpers.tpl
│   │   ├── hpa.yaml
│   │   ├── ingress.yaml
│   │   ├── issuer.yaml
│   │   ├── NOTES.txt
│   │   ├── ns.yaml
│   │   ├── secret.yaml
│   │   ├── serviceaccount.yaml
│   │   ├── service.yaml
│   │   └── tests
│   │       └── test-connection.yaml
│   └── values.yaml
├── helmfile.yaml
└── helm_secrets
    ├── django_config.yaml
    ├── django_secret.yaml
    └── .sops.yaml
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

`ingress-nginx` is the chart for deploying Nginx ingress controller + additional resources to be able to use Ingress

`cert-manager` is the chart for implementing SSL certificates and securing connections (in this case LetsEncrypt is used to issue certificates)

`metrics-server` is the chart for receiving metrics from Kubernetes resiurces (HPA implementation uses metrics for deployment's pods scaling control)

It's important to mention that `cert-manager` chart requires `crds`. [Official Chart Docs](https://artifacthub.io/packages/helm/cert-manager/cert-manager#installing-the-chart) say:

>_"Before installing the chart, you must first install the cert-manager CustomResourceDefinition resources. This is performed in a separate step to allow you to easily uninstall and reinstall
> cert-manager without deleting your installed custom resources."_ 

So it's not the best way to use `installCRDS=true` Chart value. `crds` can be installed via kubectl command:

```
kubectl apply -f https://github.com/cert-manager/cert-manager/releases/download/v1.13.1/cert-manager.crds.yaml
```

Install Helm Chart requires `ConfigMap` values and `Secret` values. You can define those values via editing personal `values.yaml` file or by using separate `.yaml` files. Values required:

```
databaseURL: <postgres db connection url>
djangoAllowedHosts: <example: "*">
djangoDebug: <"True"/"False">
```

### Helm Secrets

In my case Helm Secrets wrapper was used to decrypt encrypted values in flight.  I needed to generate `GPG` key-pair and create `.sops.yaml` file which points to the fingerpring of the GPG is used.

> [!NOTE]
> Using Helm Secrets requires: Helm Secrets wrapper itself, gpg, sops

To generate key-pair:

```
gpg --gen-key
```
To check avaliable keys:

```
gpg -k
```

Example of `.sops.yaml` file:

```
creation_rules:
  - pgp: <pub-key-fingerprint>
```

Now You can create a file with some secret data (in my case django_secret.yaml with my `databaseURL: <postgres db connection url>`) For encrypting with Helm Secrets:

```
helm secrets encrypt -i <path/to/file>
```

To decrypt:

```
helm secrets decrypt -i <path/to/file>
```

Now You have no need to decrypt a secretfile, just use `helm secrets` instead of `helm` and secret will be decrypted during the installation/upgrading process, for example:

```
cd helmcharts
helm secrets install syndicate django-demo -f helm_secrets/django_secrets.yaml -f helm_secrets/django_config.yaml
```

<img src="https://github.com/digitalake/do-terraform-k8s-helm/assets/109740456/7468565a-6d6a-4e86-add9-589b812b556a" width="450">


```
helm ls
```

![image](https://github.com/digitalake/do-terraform-k8s-helm/assets/109740456/d2c512a3-ff57-4981-8dd5-cd42e4eaacda)

### Helmfile 

For this task definition, Helmfile doesn't suit well (in case I defined all sidecharts via dependencies) but it's a powerful tool to configure several Helm installations.

To install Chart via Helmfile:

```
cd helmcharts
helmfile init
helmfile apply
```

### Results

![image](https://github.com/digitalake/do-terraform-k8s-helm/assets/109740456/289888ee-543f-474c-977b-22e7a92d6239)


