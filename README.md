# DXXR Test

This repository is divided in three main parts.
- `do-k8scluster.tf`: Terraform to create the Kubernetes Cluster on DigitalOcean (Cloud Provider);
- `src/rottenpotatoes-web`: Web python application used as example to be deployed in the cluster;
- `charts/rottenpotatoes`: Application's Helm chart, contains deployment for the web app and its database (mongodb).

All development and tests were done on Ubuntu 20.04

## Requeriments
- [Docker](hhttps://docs.docker.com/get-docker/);
- [Kubectl](https://kubernetes.io/docs/tasks/tools/#kubectl);
- [Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli);
- [Helm](https://helm.sh/docs/intro/install/);
- DigitalOcean account and a [API token](https://docs.digitalocean.com/reference/api/api-reference/#section/Introduction/Curl-Examples) with READ/WRITE access.

___
# Setting up the environment
## 1. **Downloading the repository:**

```
$ wget https://github.com/carlos2beserra/dxxr-test/archive/refs/heads/main.zip
$ unzip dxxr-test-main.zip
$ cd dxxr-test-main/
```


## 2. **Running Terraform code:**
First, run the following terrafom commands to download providers and validate and plan the infraestructure provisioning.

```
$ terraform init
$ terraform apply
```

You'll be promped by this message. Here you need to put the DigitalOcean API Token, then press enter.
```
var.do_token     
  Enter a value: <PUT THE TOKEN HERE>
```

After Terraform calculated all the modifications, you'll be prompted to accept the planned modifications and perform the actions.
```
Do you want to perform these actions?
  Terraform will perform the actions described above.
  Only 'yes' will be accepted to approve.

  Enter a value: <WRITE YES>
```
The Kubernetes cluster deployment will take about 10 minutes to complete.
After completing, Terraform CLI will show _"Apply complete!"_ message and how many resources did it changed.

You can get the created cluster's kubeconfig by using this command.
```
terraform output kubeconfig | awk '/EOT/{found=0} {if(found) print} /-EOT/{found=1}' > ~/.kube/config
```

## 3. **Building and pushing the docker image:**
The folder `src/rottenpotatoes-web` has the files from our application. It's a python web application that shows a movie catalog. Inside the folder, it already has a Dockerfile to build the docker image. It's just necessary to run some commands.
First, it's necessary to login into docker to push the image to a public repository.

```
$ docker login
```

Next step is to build the docker image and tagging it. We are going to tag it using our docker username and a repository name to it and a 1.0 tag.
```
$ docker build src/rottenpotatoes-web/ -t 2blume/rottenpotatoes:1.0
```

After that, just push the image to the repo
```
$ docker push 2blume/rottenpotatoes:1.0
```

## 4. **Installing the Helm Chart:**
Edit the file `charts/rottenpotatoes/values.yaml`. The main setting to be modified is the image repository and tag. In this example we are using the `2blume/rottenpotatoes` repository and `1.0` tag.

```yaml
image:
  repository: 2blume/rottenpotatoes
  pullPolicy: Always
  tag: "1.0"
```

While still in the root directory from the project, the command below is going to install the chart into the Kubernetes Cluster that is accessible from `kubectl`, and give it the name of `rottenpotatoes`.

```
$ helm install rottenpotatoes charts/rottenpotatoes/
```

Use this command to keep watching the kubernetes resources until it's all running.

```
$ watch kubectl get all -n default
```

```
NAME                                  READY   STATUS    RESTARTS   AGE
pod/mongodb-89dddc46-r9rwz            1/1     Running   0          48m
pod/rottenpotatoes-59b9c48897-5fjxd   1/1     Running   0          48m

NAME                     TYPE           CLUSTER-IP      EXTERNAL-IP      PORT(S)        AGE  
service/kubernetes       ClusterIP      10.245.0.1      <none>           443/TCP        3h58m
service/mongo-service    ClusterIP      10.245.70.37    <none>           27017/TCP      48m  
service/rottenpotatoes   LoadBalancer   10.245.46.247   138.197.59.252   80:30735/TCP   48m  

NAME                             READY   UP-TO-DATE   AVAILABLE   AGE
deployment.apps/mongodb          1/1     1            1           48m
deployment.apps/rottenpotatoes   1/1     1            1           48m

NAME                                        DESIRED   CURRENT   READY   AGE
replicaset.apps/mongodb-89dddc46            1         1         1       48m
replicaset.apps/rottenpotatoes-59b9c48897   1         1         1       48m
```

To test the deployed application, run these commands and access the gotten address through the browser.

```
$ export SERVICE_IP=$(kubectl get svc --namespace default rottenpotatoes --template "{{ range (index .status.loadBalancer.ingress 0) }}{{.}}{{ end }}")
$ echo http://$SERVICE_IP:80
```
___
# Results<br />
In this results example, I used _ecsys.io_ domain. So I ended up with two web links: <br />
**ecsys.io** (for the main hello-world page) and <br />
**graf.ecsys.io** (for the grafana web page).
1. **Hello-world web page:**<br />

![Hostname changes everytime you refresh the page (LoadBalacing).](/results/hello-world.png "hello-world result.")<br />

Hostname changes due to the LoadBalacing everytime you refresh the page.<br /><br /><br />
2. **Grafana web page:**<br />
Default login username: __admin__<br />
Default password: __prom-operator__<br /><br />
![Grafana login page.](/results/grafana-login.png "Grafana login page.")<br /><br />

![Grafana dashboard example.](/results/grafana-dashboard.png "Grafana dashboard example.")<br />
Grafana dashboard example<br />
