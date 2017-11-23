# poc-nodejs [![Build Status](https://travis-ci.org/laurentgilly/poc-nodejs.svg?branch=master)](https://travis-ci.org/laurentgilly/poc-nodejs)
*Proof of concept - Build with TravisCi, push to DockerHub and deploy to K8S*

`poc-nodejs` is a cool and nice **hello world project** that will help you setup your pipeline CI/CD. The final goal 
is to have a worflow deploying to K8S after a commit. This application is written in javascript with NodeJs and Express. However with some little changes (inside Makefile, .travis.yml) you could make it works for any programming language.

## 1.DockerHub
Go to [DockerHub](https://hub.docker.com/) and create a public repository with __the same name of your GitHub project__.
If you want to use a private repository the section __Docker registry secret__ is mandatory.

## 2.Kubernetes [(documentation)](https://kubernetes.io/docs/home/)
Here I make the assumption that you already have a kubernetes cluster running and you got all the credentials (.kube/config) to interact with it / [kubectl install](https://kubernetes.io/docs/tasks/tools/install-kubectl/). If not you can follow the [Azure tutorial](https://docs.microsoft.com/en-us/azure/container-service/kubernetes/container-service-kubernetes-walkthrough), [mine](https://medium.com/@aboycandream/deploy-an-azure-k8s-cluster-in-30sec-c1eed1edd841) or use any other k8s cluster from AWS, Google Compute Engine, etc.

### 2.1.Nginx [(documentation)](https://www.nginx.com/resources/wiki/)
First thing first. To make our NodeJs app work on kubernetes we need to setup a reverse proxy. Nginx will then handle all the incoming calls from outside the cluster and, belive me, it will make things much more simple. Alternative, use [Traefik](https://docs.traefik.io/) but from my point of view much more complicate to setup.
```
kubectl apply -f _platform/nginx.yaml -n kube-system
```
That's it ! Inside _deployment/ingress.template.yaml you will see that we use the annotation __kubernetes.io/ingress.class: "nginx"__. It will tell kubernetes that our application is using nginx.

### 2.2.Namespaces [(documentation)](https://kubernetes.io/docs/concepts/overview/working-with-objects/namespaces/)
From my point of view it could be nice to create a dedicated namespace. It will isolate your work from kubernetes default namespaces.
```
kubectl create namespace my-namespace
```

### 2.3.Service account
First of all you should give TravisCI access to your k8s cluster. TravisCI will be able to interact with k8s API. The simple way is to define a [service account](https://kubernetes.io/docs/tasks/configure-pod-container/configure-service-account/). I know that there is many others ways to do that, but with service account I found that it's the easiest way to configure easily an access.
```
kubectl create serviceaccount travis -n my-namespace
```
The service account (travis) will be linked to the namespace and will interact only with that one.
This will automatically generates a secret that could be use to connect k8s-api.  
Username: system:serviceaccount:my-namespace:travis  
```
kubectl get secret travis-token-{id} -o yaml -n my-namespace
```
(id is generated by k8s) *token is encoded base64*  
note: you will need to decode the token to use it.

### Docker registry secret (optional)
In case you want to use private repository, kubernetes needs credentials to pull images from private docker-registry.  
```
kubectl create secret docker-registry dockerhub --docker-server=https://index.docker.io/v1/ --docker-username={dockerhub-id} --docker-password={dockerhub-password} --docker-email={dockerhub-email} -n my-namespace
```

### Kube-Lego [(documentation)](https://github.com/jetstack/kube-lego) (optional)
Https is great, but it's also awesome when it's free. Kube-lego and Let's Encrypt are there for you.
```
kubectl apply -f _platform/kube-lego.yaml -n my-namespace
```
*don't forget to change email contact inside kube-lego.yaml*
The only thing you need to do is uncomment __tls__ part inside ingress.template.yaml and make it correspond to your needs. More than one micro-service could use the same secret within the same namespace.

## 3.TravisCI [(documentation)](https://docs.travis-ci.com/)
Go to [TravisCI](https://travis-ci.org/) and sync your github account. Enable your project and you should be able to 
navigate through settings tab. Below there is some env vars that you have to add to your project.

| Name                         | Value (examples)                                  |
| ---------------------------- | ------------------------------------------------- |
| **DOCKER_HUB_USERNAME**      | `laurentgilly`                                    |
| **DOCKER_HUB_PASSWORD**      | `yourpasswordfromdockerhub`                       |
| **APP_PORT**                 | `3000`                                            |
| **K8S_HOST**                 | `https://mycluster.westeurope.cloudapp.azure.com` |
| **K8S_TOKEN**                | `yourtokenfromk8s`                                |
| **K8S_USERNAME**             | `system:serviceaccount:my-namespace:travis`       |
| **HOST**                     | `nodejs.laurentgilly.net`                         |

## License
poc-nodejs is licensed under the [MIT license](http://opensource.org/licenses/MIT).

## Contributing
Pull requests are the way to help me here. I apologise in advance if I'm not that reactive on pull requests and issues. 
For submitting a pull request please analyse my code and try to stay as close as possible of `my way` to code.