# Azure Redhat OpenShift Hands-on Session: Dynamic Provisioning with Trident interact Ubuntu VM

K8s cheatsheet(https://kubernetes.io/docs/reference/kubectl/cheatsheet/)

**Diagram**\
![ARO dynamic provisioning](https://techcommunity.microsoft.com/t5/image/serverpage/image-id/313111i6BC6DAC97ADC480F/image-dimensions/583x274?v=v2) 

Examples)\
kubectl/oc get no\
kubectl/oc kubectl get nodes -o wide\
kubectl/oc describe node\
kubectl/oc get po -o wide\
kubectl/oc get namespaces -o wide\
kubectl/oc get ns {name}\
kubectl/oc get deploy\
kubectl/oc get pv\
kubectl/oc get pvc\
kubectl/oc get sc\
kubectl/oc get svc\
kubectl/oc apply -f {name}.yaml\
kubectl/oc delete -f {name}.yaml

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
sudo apt update && \
sudo snap install kubectl --classic && \
sudo snap install helm --classic && \
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash && \
sudo apt install git-all -y
</pre>

## 5. az login to Azure on Trident VM
- `az login --use-device-code`
- `https://microsoft.com/devicelogin`
- Verify with this command `kubectl get deployments --all-namespaces=true`
- Set as default account if necessary `az account set -s SUBSCRIPTION_ID`

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
- CD to openshift and Extract: `cd openshift && tar xzvf ../openshift-client-linux.tar.gz`
- Edit .bashrc: `echo 'export PATH=$PATH:~/openshift' >> ~/.bashrc && source ~/.bashrc`

## 9. Connect using the OpenShift CLI
- Retrieve API server: `apiServer=$(az aro show -g arodemo-rg -n AroCluster01 --query apiserverProfile.url -o tsv)`
- Login to the OpenShift cluster's API server: `oc login $apiServer -u kubeadmin -p xGU3N-33F3a-j7H3n-Nfake`
- Verify that you are a Kubernetes cluster administrator: `oc auth can-i '*' '*' -A`

## 10. Install Trident 
- Back to home direcotory: `cd`
- Download Trident `curl -L -O -C - https://github.com/NetApp/trident/releases/download/v21.10.0/trident-installer-21.10.0.tar.gz`
- Extract tar `tar xzvf trident-installer-21.10.0.tar.gz`
- Copy tridentctl to /usr/bin/  `cd trident-installer && sudo cp tridentctl /usr/local/bin/`
- Create a Trident Namespace `oc create ns trident`
- Install trident with helm `cd helm && helm install trident trident-operator-21.10.0.tgz -n trident`

## 11. Create Service Principal
- Creaete a new SP named "http://netapptridentaroxxx" `az ad sp create-for-rbac --name "http://netapptridentaroxxx"`
- Gain Subection ID `az account show --query id -o tsv`
- Gain NetApp Account ID: `az netappfiles account show -n $anf_name -g arodemo-rg --query id -o tsv`

## 12. Create role assignment
<pre>
anfac=$(az netappfiles account show -n $anf_name -g arodemo-rg --query id -o tsv)
appid=xxxxxxxxxxxxxxxx

az role assignment create --scope $anfac --assignee $appid --role contributor
</pre>


---