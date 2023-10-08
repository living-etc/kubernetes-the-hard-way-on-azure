#! /usr/bin/env bash

RESOURCE_GROUP="Kubernetes-The-Hard-Way"

INSTANCE_DETAILS=$( az vm list -g ${RESOURCE_GROUP} --query "[].{Name:name, NicId:networkProfile.networkInterfaces[0].id}" --output json )
NIC_DETAILS=$( az network nic list --resource-group ${RESOURCE_GROUP} --query "[].{NicId:id, PrivateIP:ipConfigurations[0].privateIPAddress, PublicIPId:ipConfigurations[0].publicIPAddress.id}" --output json )
PUBLIC_IP_DETAILS=$( az network public-ip list --resource-group ${RESOURCE_GROUP} --query "[].{PublicIPId:id, PublicIPAddress:ipAddress}" --output json )

result=$(jq -n --argjson instance_details "${INSTANCE_DETAILS}" --argjson nic_details "${NIC_DETAILS}" --argjson public_ip_details "${PUBLIC_IP_DETAILS}" '
reduce $instance_details[] as $instance ([];
    ($nic_details[] | select(.NicId == $instance.NicId) | del(.NicId) | . + {Name: $instance.Name}) as $nicWithInstance |
    ($public_ip_details[] | select(.PublicIPId == $nicWithInstance.PublicIPId) | del(.PublicIPId) + {Name: $nicWithInstance.Name, PrivateIP: $nicWithInstance.PrivateIP}) as $mergedData |
    . + [$mergedData]
  )'
)

echo "$result"
