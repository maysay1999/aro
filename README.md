# Azure Redhat OpenShift Hands-on Session: Dynamic Provisioning with Trident interact Ubuntu VM

K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

### **Procedure of ARO deployment.  Note: difference between Static Provisioning and Dynamic Provisioning**
### **Static Provisioning** ==> 1) pv 2) pvc 3) pod
### **Dynamic Provisioning** ==> 1) sc 2) pvc 3) pod

Examples)\
kubectl get no\
kubectl get nodes -o wide\
kubectl describe node\
kubectl get po -o wide\
kubectl get namespaces -o wide\
kubectl get ns {name}\
kubectl get deploy\
kubectl get pv\
kubectl get pvc\
kubectl get sc\
kubectl get svc\
kubectl apply -f {name}.yaml\
kubectl delete -f {name}.yaml

Use this command to create a clone of this site locally\
`git clone https://github.com/maysay1999/aro.git AroDemo01`


## 1. Create Ubuntu VM for Trident
- Create a new resource group (anf-demo-aks-prework.azcli)  `az group create -n arotest-rg -l japaneast`
- Create Ubuntu VM [ARM for Ubuntu](https://github.com/maysay1999/aro/tree/main/ubuntu)

## 2. Create VNet and Subnets (create-subnet.azcli)
`git clone https://github.com/maysay1999/aro.git AroDemo01`
- Resource group: arodemo-rg
- VNet name: aro-vnet
- Master Node subnet: master-subnet
- Worker Node subnet: worker-subnet
- Register the Microsoft.RedHatOpenShift resource provider:  <br /> `az provider register -n Microsoft.RedHatOpenShift --wait`<br />
*Running shell*<br />
`chmod 711 create-subnet.sh`<br />
`./create-subnet.sh`

## 3. Create ARO cluster
- Resource group: arodemo-rg
- Cluster name: AroCluster01
<pre>
az aro create \
  --resource-group arodemo-rg \
  --name AroCluster01 \
  --vnet aro-vnet \
  --master-subnet master-subnet \
  --worker-subnet worker-subnet
</pre>
**</p>Note: It takes about ***35 minutes***. </p>**

## 4. Install kubectl, helm, az cli and git on Ubuntu
- Install kubectl, helm, az cli and git
<pre>
sudo apt update && 
sudo snap install kubectl --classic && \
sudo snap install helm --classic && \
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
sudo apt install git-all -y
</pre>

## 5. az login to Azure on Trident VM
- `az login --use-device-code`
- `https://microsoft.com/devicelogin`
- Verify with this command `kubectl get deployments --all-namespaces=true`
- Set as default account `az account set -s SUBSCRIPTION_ID`

## 6. Connect to an Azure Red Hat OpenShift cluster
- Obtain password of "kubeadmin": 
<pre>
az aro list-credentials \
  --name AroCluster01 \
  --resource-group arodemo-rg
</pre>

## 7. Login
- Obtain URL and login on OpenShift console
<pre>
az aro show \
  --name AroCluster01 \
  --resource-group arodemo-rg \
  --query "consoleProfile.url" -o tsv
</pre>

## 8. Install the OpenShift CLI
- Home directory: `cd` 
- Download OpenShift CLI: `curl -L -O -C - https://mirror.openshift.com/pub/openshift-v4/clients/ocp/latest/openshift-client-linux.tar.gz`
- Make a new dierctory: `mkdir openshift`
- CD to openshift and Extract: `cd openshift` and `tar ../xzvf openshift-client-linux.tar.gz`
- Edit .bashrc: `echo 'export PATH=$PATH:~/openshift' >> ~/.bashrc && source ~/.bashrc`

## 9. Connect using the OpenShift CLI
- Retrieve API server: `apiServer=$(az aro show -g arodemo-rg -n AroCluster01 --query apiserverProfile.url -o tsv)`
- Login to the OpenShift cluster's API server: `oc login $apiServer -u kubeadmin -p <password>`

---