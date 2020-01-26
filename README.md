### Otus Operations Take Home

## Practical

### Prerequisites

```
aws-cli
aws-iam-authenticator
terraform
kubectl
helm (v3.0.0)
```

### Installing

- Clone this repo
- Update values in main.tf for your environment
```
module "eks" {
  source          = "./modules/eks/"
  cluster_name    = "jcd"
  eks-version     = "1.14"
  number_of_node_groups = 2
  vpc_id          = "vpc-6b5bfd11"
  subnet_ids      = ["subnet-16cb5d4a", "subnet-260b4429", "subnet-3b547171"]
  instance_types  = "t3.medium"
  desired_capacity = "4"
  max_size         = "10"
  min_size         = "4"
}
```
- Run terraform 
```
terraform apply
```
- Add the cluster to your kubectl config 
```
aws eks --region REGION update-kubeconfig --name CLUSTER_NAME
```
- Install nginx ingress controller
```
helm repo add nginx-stable https://helm.nginx.com/stable
helm repo update
helm install nginx-ingress nginx-stable/nginx-ingress
```
- Get the DNS name for the nginx endpoint (load balancer)
```
kubectl get svc
```
- Add a DNS record for the domain name of your service pointing to the load balancer
- Install cert-manager into cert-manager namespace
```
kubectl apply --validate=false -f https://raw.githubusercontent.com/jetstack/cert-manager/v0.13.0/deploy/manifests/00-crds.yaml
kubectl create namespace cert-manager
helm repo add jetstack https://charts.jetstack.io
helm repo update
helm install cert-manager --namespace cert-manager --version v0.13.0 jetstack/cert-manager
```
- Check pods for cert manager (the webhook takes some time to come up)
```
kubectl get pods -n cert-manager
```
- Update the letsencrypt issuer email field
```
   apiVersion: cert-manager.io/v1alpha2
   kind: ClusterIssuer
   metadata:
     name: letsencrypt
   spec:
     acme:
       # The ACME server URL
       server: https://acme-staging-v02.api.letsencrypt.org/directory
       # Email address used for ACME registration
       email: YOUR_EMAIL_HERE
       # Name of a secret used to store the ACME account private key
       privateKeySecretRef:
         name: letsencrypt
       # Enable the HTTP-01 challenge provider
       solvers:
       - http01:
           ingress:
             class:  nginx
```
- Create the letsencrypt issuer resource
```
kubectl apply -f letsencrypt/letsencrypt.yaml
```
- Create the k8s resources (deployment, service) 
```
kubectl apply -f hello-k8s/hello-k8s.yaml
```
- Update the ingress host fields
```
apiVersion: extensions/v1beta1
kind: Ingress
metadata:
  name: hello-kubernetes
  annotations:
    kubernetes.io/ingress.class: "nginx"    
    cert-manager.io/issuer: "letsencrypt"
spec:
  tls:
  - hosts:
    - hello.hello-k8s.com
    secretName: hello-kubernetes-tls
  rules:
  - host: hello.hello-k8s.com
    http:
      paths:
      - path: /
        backend:
          serviceName: hello-kubernetes
          servicePort: 80
```
- Create the ingress
```
kubectl apply -f hello-k8s/ingress.yaml
```

## Test

- Go to https://YOUR_DNS that you set up previously. You should get a valid cert.

## Written

### Site Reliability
**You start a job at Otus and I ask you to show how we are doing in terms of platform
performance and reliability. How are you going to do this? Please be specific.**

I would first get both current and historical data from APM and analze that data. Some metrics that I would look at include apdex (if available), errors, and transaction duration. 

I would also look at past platform issues that had been reported and documented to see what types of issues have come up in the past and how they were resolved. 

Lastly I would be interested in looking at how the k8s clusters are holding up against load. I would look in both promethus and cloudwatch metrics for this info.


### Security
**Explain what sort of initial security sweep you would make of the prod infra during your
first month? Explain how you would prioritize the work and go after it.**

One tool that I am very fond of for AWS account related security is cloudsploit. This tool does periodic scans of the account and reports on security best practices that aren't being met. Using this info I would update Terraform and apply to the account/environment with the corrections.

To go along with this I would have a look at IAM users, policies and roles to see who has what access and the type of access they have.

To get an idea of platform security I would setup and run owasp zap attack proxy against a dev/preprod instance of the platform. I've had good luck with this tool in the past.



### Ramping up
**Explain what an ideal 30/60/90 day plan looks like for you as you start a new role with
Otus. This is important since we are small and you will need to self-direct most days.**

*30 Day Plan:
Gather as much info as I can around processes, infrastructure overview, support issues, CICD process, development workflow, people and their roles, more detailed info on the 2020 roadmap, etc... 

Given our conversation I think I could provide some help with Terraform right out of the gate.

*60 Day Plan:
I would like to have a good understanding of the platform and potentially run through the process of deploying the platform to a seperate k8s cluster or namespace.

Also, decide on what some of the higher priority items are on the roadmap. One that caught my eye that I would consider higher priority (given my current understanding) would be way of handling secrets (vault). 

Another task that was brought up was the certificate experiation issue. This to me seems like a higher priority item and I think I could contribute to the project.

*90 Day Plan:
I'm also very much interested in the China POC and if that is a higher priority issue I would love to be involved with that.

Beyond this I would like to continue working through the roadmap as well as gather and work through any pain points that developers might have involving infrastructure/devops.


