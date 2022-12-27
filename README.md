# Nolus Project install scripts
## Procedure:
1. You need a new server with Ubuntu 20+ on server to install the node
2. Before you proceed with installation please run these commands:
```
apt install -y screen curl
screen -S install
```
3. Install the Full node and wait for a full synchronisation (you'll see how to check it after installation)
```
curl -sO https://raw.githubusercontent.com/avkarcr/node_scripts/main/1_nolus_install_fullnode.sh && chmod +x 1_nolus_install_fullnode.sh
./1_nolus_install_fullnode.sh
```
4. Add your wallet and (manually) backup the data
```
curl -sO https://raw.githubusercontent.com/avkarcr/node_scripts/main/2_nolus_add_wallet.sh && chmod +x 2_nolus_add_wallet.sh
./2_nolus_add_wallet.sh
```
3. After Fullnode synchronisation create a Validator node
```
curl -sO https://raw.githubusercontent.com/avkarcr/node_scripts/main/3_nolus_create_validator.sh && chmod +x 3_nolus_create_validator.sh
./3_nolus_create_validator.sh
```
## That's it! Enjoy )
