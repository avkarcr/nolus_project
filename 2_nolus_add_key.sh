#!/bin/bash
# written by avkar 15.12.2022
nolusd keys add wallet
echo "export ADDRESS=$(nolusd keys show wallet -a)" >> ~/.profile
source ~/.profile
nolusd keys export wallet > wallet
echo
echo "Go to Discord and run this script in the Testnet-faucet channel:"
echo
echo "==================================="
echo -e "\e[1;32m \$request $ADDRESS nolus-rila \e[0m"
echo "==================================="
echo
echo "Save the seed phrase, address and files: $HOME/wallet and $HOME/.nolus/config/priv_validator_key.json"
echo "And wait for catching up (catching_up: false)"
echo
echo "==================================="
echo -e "\e[1;32m nolusd status | jq \e[0m"
echo "==================================="
echo
