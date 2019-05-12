#Login
 az login
#CreateGroup
 az group create --name testing --location westeurope
wait
#VM details
 pubIP=$(az vm create --resource-group testing \
  --name test1\
  --image UbuntuLTS \
  --admin-username maga \
  --generate-ssh-keys \
  --output json \
  --verbose             )
wait

#Open Ports
 az vm open-port --resource-group testing --name test1 --port 8080
 echo "VM created"

#Query server,capture public IP
NIC_ID=$(az vm show -n test1 -g testing \
  --query 'networkProfile.networkInterfaces[].id' \
  -o tsv)

az network nic show --ids $NIC_ID \
  --query '{IP:ipConfigurations[].publicIpAddress.id, Subnet:ipConfigurations[].subnet.id}' \
  -o json

read -d '' IP_ID SUBNET_ID <<< $(az network nic show \
  --ids $NIC_ID \
  --query '[ipConfigurations[].publicIpAddress.id, ipConfigurations[].subnet.id]' \
  -o tsv)

VM1_IP_ADDR=$(az network public-ip show --ids $IP_ID \
  --query ipAddress \
  -o tsv)

#SSH + Flask install
#echo "SSH connection " $IP_address
ssh -o "StrictHostKeyChecking no" $VM1_IP_ADDR <<EOF
echo "Server Setup"
sudo apt-get update
sudo apt-get --assume-yes install python3-venv
git clone https://github.com/Maros-Sle/Cloud2.git
cd Cloud2
python3 -m venv venv
. venv/bin/activate
pip install --upgrade pip
pip install flask
# pip install psutil
echo "Starting Flask Application"
python3 main.py
echo "...setup finished."
EOF
