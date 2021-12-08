# register provider
az provider register -n Microsoft.RedHatOpenShift
az provider register -n Microsoft.Compute

# Vnet with 2 x empty subnets
LOCATION=japaneast
RESOURCEGROUP=arodemo-rg
CLUSTER=Arocluster01

#
az group create \
  --name $RESOURCEGROUP \
  --location $LOCATION

#
az network vnet create \
   --resource-group $RESOURCEGROUP \
   --name aro-vnet \
   --address-prefixes 172.22.0.0/16

#
az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name master-subnet \
  --address-prefixes 172.22.0.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

#
az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name worker-subnet \
  --address-prefixes 172.22.2.0/23 \
  --service-endpoints Microsoft.ContainerRegistry

#
az network vnet subnet create \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --name netapp-subnet \
  --delegations "Microsoft.NetApp/volumes" \
  --address-prefixes 172.22.4.0/26

# Netapp account
az netappfiles account create \
  -g $RESOURCEGROUP \
  --name aroac01 -l japaneast

# ANF Pool
az netappfiles pool create \
  -g $RESOURCEGROUP \
  --location japaneast \
  --account-name aroac01 \
  --pool-name mypool1 \
  --size 4 \
  --service-level Standard

# ANF volume
az netappfiles volume create \
  --resource-group $RESOURCEGROUP \
  --location japaneast \
  --account-name aroac01 \
  --pool-name mypool1 \
  --name myvol1 \
  --service-level Standard \
  --vnet aro-vnet \
  --subnet netapp-subnet \
  --usage-threshold 100 \
  --file-path nfspath01 \
  --protocol-types NFSv3

# Disable subnet private endpoint policies on the master subnet
az network vnet subnet update \
  --name master-subnet \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --disable-private-link-service-network-policies true