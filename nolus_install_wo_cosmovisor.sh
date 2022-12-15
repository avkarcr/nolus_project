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
PEERS="$(curl -s "https://raw.githubusercontent.com/Nolus-Protocol/nolus-networks/main/testnet/nolus-rila/persistent_peers.txt")"
sed -i.bak -e "s/^persistent_peers *=.*/persistent_peers = \"$PEERS\"/" ~/.nolus/config/config.toml
sed -i.bak -e "s/^minimum-gas-prices *=.*/minimum-gas-prices = \"0.0025unls\"/" ~/.nolus/config/app.toml
echo
echo "======================================"    
echo -e "\e[1;32m Full node настроена \e[0m"
echo "======================================"
echo
