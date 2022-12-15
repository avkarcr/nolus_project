#!/bin/bash
# written by avkar 15.12.2022
apt update && apt upgrade -y
apt install -y build-essential git curl gcc jq
go_version='1.19.4'
wget https://go.dev/dl/go${go_version}.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go${go_version}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
# echo "PATH=$PATH:/usr/local/go/bin" >> $HOME/.bashrc
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
nolus_version=$(curl -s "https://api.github.com/repos/Nolus-Protocol/nolus-core/releases/latest" | grep tag_name | sed 's/.*": "v\(.*\)".*/\1/')
git checkout v${nolus_version}
make install
export PATH=$PATH:$(go env GOPATH)/bin
echo "PATH=$PATH:$(go env GOPATH)/bin" >> $HOME/.bashrc
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
PEERS="$(curl -s "https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/persistent_peers.txt")"
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
echo "curl http://localhost:26657/status | jq .result.sync_info.catching_up" > ~/nolus_check_status.sh && chmod +x ~/nolus_check_status.sh
echo
echo "==================================================================================================="    
echo -e "\e[1;32m Готово! Проверить работает ли нода можно с помощью скрипта nolus_check_status.sh \e[0m"
echo "==================================================================================================="    
