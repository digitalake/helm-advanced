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