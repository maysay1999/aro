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

# Disable subnet private endpoint policies on the master subnet
az network vnet subnet update \
  --name master-subnet \
  --resource-group $RESOURCEGROUP \
  --vnet-name aro-vnet \
  --disable-private-link-service-network-policies true