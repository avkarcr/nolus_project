#!/bin/bash
# written by avkar 15.12.2022
apt update && apt upgrade -y
apt install -y build-essential git curl gcc
go_version='1.19.4'
wget https://go.dev/dl/go${go_version}.linux-amd64.tar.gz && rm -rf /usr/local/go && tar -C /usr/local -xzf go${go_version}.linux-amd64.tar.gz
export PATH=$PATH:/usr/local/go/bin
echo "PATH=$PATH:/usr/local/go/bin" >> $HOME/.bashrc
git clone https://github.com/Nolus-Protocol/nolus-core
cd nolus-core
nolus_version=$(curl -s "https://api.github.com/repos/Nolus-Protocol/nolus-core/releases/latest" | grep tag_name | sed 's/.*": "v\(.*\)".*/\1/')
git checkout v${nolus_version}
make install
export PATH=$PATH:$(go env GOPATH)/bin
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
