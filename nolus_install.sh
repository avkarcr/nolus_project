#!/bin/bash
# written by avkar 15.12.2022
apt update && apt upgrade -y
apt install -y build-essential git curl gcc jq
go_version='1.19.4'
wget https://go.dev/dl/go${go_version}.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go${go_version}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
nolus_version=$(curl -s "https://api.github.com/repos/Nolus-Protocol/nolus-core/releases/latest" | grep tag_name | sed 's/.*": "v\(.*\)".*/\1/')
git checkout v${nolus_version}
export PATH=$PATH:$(go env GOPATH)/bin
echo "PATH=$PATH:$(go env GOPATH)/bin" >> $HOME/.bashrc
make install
check_install=$(nolusd version --long | grep $nolus_version | wc -l)
echo
echo
if [ ${check_install} > 0 ]; then
    echo "======================================"    
    echo -e "\e[1;32m Full node успешно установлена! \e[0m"
    echo "======================================"
else
    echo "======================================"    
    echo -e "\e[1;31m Установка завершилась с ошибками \e[0m"
    echo "======================================"    
fi
echo
read -p "Input your Node moniker: " moniker
nolusd init $moniker
wget https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/genesis.json
mv ./genesis.json ~/.nolus/config/genesis.json
# PEERS="$(curl -s "https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/persistent_peers.txt")"
PEERS="17cc34fc4a5c91e67bc7e11b9c15cad10dd11336@138.201.221.94:26656,fd13b67b442e1798c4fc3ecc8a81513de149552e@213.239.215.77:34656,785789b6574c45b8cfefff08344fdfeda345c7e1@135.125.5.34:55666,33d485f51f413fd4bf83ef8a971c10228a39cffb@62.171.161.172:26656,3c4f8aa4bf226c331b32d93f51f089e47e753279@194.163.155.84:36656,3043450abbb1026c2e73d8a2549ee2e395ea5454@65.108.78.41:36656,b6c8dc38a5dba19a3f10d23b3572065db9265fa3@65.109.85.225:9000,d5519e378247dfb61dfe90652d1fe3e2b3005a5b@65.109.68.190:43656,1a5f37caaa5dd174bc2797bf2a70b804e71bc632@162.55.42.27:26656,5a14113ec66a739f2a5b5beeb4f65859793d4f88@38.242.133.24:26656"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.nolus/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025unls\"/" ~/.nolus/config/app.toml
go install github.com/cosmos/cosmos-sdk/cosmovisor/cmd/cosmovisor@latest
tee <<EOF >> ~/.bashrc
export DAEMON_NAME=nolusd
export DAEMON_HOME=$HOME/.nolus
export MONIKER_NAME=$moniker
EOF
. ~/.bashrc
mkdir -p $DAEMON_HOME/cosmovisor/genesis/bin
mkdir -p $DAEMON_HOME/cosmovisor/upgrades
cp ~/go/bin/nolusd $DAEMON_HOME/cosmovisor/genesis/bin
tee <<EOF > /etc/systemd/system/cosmovisor.service
[Unit]
Description=cosmovisor
After=network-online.target

[Service]
User=root
ExecStart=/root/go/bin/cosmovisor run
Restart=always
RestartSec=3
LimitNOFILE=4096
Environment="DAEMON_NAME=nolusd"
Environment="DAEMON_HOME=/root/.nolus"
Environment="DAEMON_ALLOW_DOWNLOAD_BINARIES=false"
Environment="DAEMON_RESTART_AFTER_UPGRADE=true"
Environment="DAEMON_LOG_BUFFER_SIZE=512"

[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable cosmovisor
systemctl start cosmovisor
# echo "curl http://localhost:26657/status | jq .result.sync_info.catching_up" > ~/nolus_check_status.sh && chmod +x ~/nolus_check_status.sh
echo
echo "========================"    
echo -e "\e[1;32m Готово! \e[0m"
echo "========================"    
