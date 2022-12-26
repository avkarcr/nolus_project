echo
echo "=========================================================================================="
echo "Установку ноды необходимо делать через screen. Если не уверены, нажмите ctrl+c для выхода"
echo "=========================================================================================="
echo
read -p "Input your Node moniker: " MONIKER

apt update
apt install curl git jq lz4 build-essential -y
rm -rf /usr/local/go
curl -Ls https://go.dev/dl/go1.19.linux-amd64.tar.gz | sudo tar -C /usr/local -xz
tee -a $HOME/.profile > /dev/null << EOF
export PATH=$PATH:/usr/local/go/bin:$HOME/go/bin
EOF
source $HOME/.profile

# Clone project repository
cd $HOME
rm -rf nolus-core
git clone https://github.com/Nolus-Protocol/nolus-core.git
cd nolus-core

# Build binaries
nolus_version=$(curl -s "https://api.github.com/repos/Nolus-Protocol/nolus-core/releases/latest" | grep tag_name | sed 's/.*": "v\(.*\)".*/\1/')
git checkout v${nolus_version}
make build
mkdir -p $HOME/.nolus/cosmovisor/genesis/bin
mv target/release/nolusd $HOME/.nolus/cosmovisor/genesis/bin/
rm -rf build

# Download and install Cosmovisor
curl -Ls https://github.com/cosmos/cosmos-sdk/releases/download/cosmovisor%2Fv1.3.0/cosmovisor-v1.3.0-linux-amd64.tar.gz | tar xz
chmod 755 cosmovisor
mv cosmovisor /usr/bin/cosmovisor

# Create service
tee /etc/systemd/system/nolusd.service > /dev/null << EOF
[Unit]
Description=nolus-testnet node service
After=network-online.target
[Service]
User=$USER
ExecStart=/usr/bin/cosmovisor run start
Restart=on-failure
RestartSec=10
LimitNOFILE=65535
Environment="DAEMON_HOME=$HOME/.nolus"
Environment="DAEMON_NAME=nolusd"
Environment="UNSAFE_SKIP_BACKUP=true"
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable nolusd

# Create application symlinks
ln -s $HOME/.nolus/cosmovisor/genesis $HOME/.nolus/cosmovisor/current
ln -s $HOME/.nolus/cosmovisor/current/bin/nolusd /usr/local/bin/nolusd

# Set node configuration
nolusd config chain-id nolus-rila
nolusd config keyring-backend test
nolusd config node tcp://localhost:43657

# Initialize the node
nolusd init $MONIKER --chain-id nolus-rila

# Download genesis and addrbook
curl -Ls https://snapshots.kjnodes.com/nolus-testnet/genesis.json > $HOME/.nolus/config/genesis.json
curl -Ls https://snapshots.kjnodes.com/nolus-testnet/addrbook.json > $HOME/.nolus/config/addrbook.json

# Add seeds
sed -i -e "s|^seeds *=.*|seeds = \"3f472746f46493309650e5a033076689996c8881@nolus-testnet.rpc.kjnodes.com:43659\"|" $HOME/.nolus/config/config.toml

# Set minimum gas price
sed -i -e "s|^minimum-gas-prices *=.*|minimum-gas-prices = \"0.0025unls\"|" $HOME/.nolus/config/app.toml

# Set pruning
sed -i -e "s|^pruning *=.*|pruning = \"custom\"|" $HOME/.nolus/config/app.toml
sed -i -e "s|^pruning-keep-recent *=.*|pruning-keep-recent = \"100\"|" $HOME/.nolus/config/app.toml
sed -i -e "s|^pruning-keep-every *=.*|pruning-keep-every = \"0\"|" $HOME/.nolus/config/app.toml
sed -i -e "s|^pruning-interval *=.*|pruning-interval = \"19\"|" $HOME/.nolus/config/app.toml

# Set custom ports
# sed -i.bak -e "s%^proxy_app = \"tcp://127.0.0.1:26658\"%proxy_app = \"tcp://127.0.0.1:43658\"%; s%^laddr = \"tcp://127.0.0.1:26657\"%laddr = \"tcp://127.0.0.1:43657\"%; s%^pprof_laddr = \"localhost:6060\"%pprof_laddr = \"localhost:43060\"%; s%^laddr = \"tcp://0.0.0.0:26656\"%laddr = \"tcp://0.0.0.0:43656\"%; s%^prometheus_listen_addr = \":26660\"%prometheus_listen_addr = \":43660\"%" $HOME/.nolus/config/config.toml
# sed -i.bak -e "s%^address = \"tcp://0.0.0.0:1317\"%address = \"tcp://0.0.0.0:43317\"%; s%^address = \":8080\"%address = \":43080\"%; s%^address = \"0.0.0.0:9090\"%address = \"0.0.0.0:43090\"%; s%^address = \"0.0.0.0:9091\"%address = \"0.0.0.0:43091\"%; s%^address = \"0.0.0.0:8545\"%address = \"0.0.0.0:43545\"%; s%^ws-address = \"0.0.0.0:8546\"%ws-address = \"0.0.0.0:43546\"%" $HOME/.nolus/config/app.toml

# Download latest chain snapshot
curl -L https://snapshots.kjnodes.com/nolus-testnet/snapshot_latest.tar.lz4 | lz4 -dc - | tar -xf - -C $HOME/.nolus

# Start the node and show logs
systemctl start nolusd && journalctl -u nolusd -f --no-hostname -o cat
