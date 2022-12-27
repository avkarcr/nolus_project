#!/bin/bash
# written by avkar 27.12.2022
echo
echo "Before creating the Validator node you SHOULD wait until the Node is syncronized"
echo "Please check that the Node catching up status is FALSE"
echo "To exit press ctrl+c"
echo "To continue just wait for 5 sec"
echo
sleep 5
nolusd tx staking create-validator \
--amount=1000000unls \
--pubkey=$(nolusd tendermint show-validator) \
--moniker=$MONIKER \
--chain-id=nolus-rila \
--commission-rate=0.05 \
--commission-max-rate=0.20 \
--commission-max-change-rate=0.01 \
--min-self-delegation=1 \
--from=wallet \
--gas-adjustment=1.4 \
--gas=auto \
--fees=1000unls \
-y