# !/bin/bash

set -e

ONCHAIN_ISSUER_CONTRACT_ADDRESS=
URL_MUMBAI_NODE=
URL_POLYGON_NODE=
ONCHAIN_CONTRACT_OWNER=
MUMBAI_CONTRACT_STATE_ADDRESS=0x134B1BE34911E39A8397ec6289782989729807a4
MAIN_CONTRACT_STATE_ADDRESS=0xdc2A724E6bd60144Cde9DEC0A38a26C619d84B90
ONCHAIN_ISSUER_CONTRACT_BLOCKCHAIN="<eth|polygon>"
ONCHAIN_ISSUER_CONTRACT_NETWORK="<main|mumbai|goerli>"

if [ ! -d "./onchain-issuer-demo" ]; then
    git clone https://github.com/0xPolygonID/onchain-issuer-demo/
fi

# Build onchain-issuer.settings.yaml
echo "\"$ONCHAIN_ISSUER_CONTRACT_ADDRESS\":" > onchain-issuer.settings.yaml
echo "  networkURL: $URL_MUMBAI_NODE" >> onchain-issuer.settings.yaml
echo "  contractOwner: $ONCHAIN_CONTRACT_OWNER" >> onchain-issuer.settings.yaml
echo "  chainID: 80001" >> onchain-issuer.settings.yaml

# Build resolvers.settings.yaml
echo "polygon:mumbai:" > resolvers.settings.yaml
echo "  contractState: $MUMBAI_CONTRACT_STATE_ADDRESS" >> resolvers.settings.yaml
echo "  networkURL: $URL_MUMBAI_NODE" >> resolvers.settings.yaml
echo "polygon:main:" >> resolvers.settings.yaml
echo "  contractState: $MAIN_CONTRACT_STATE_ADDRESS" >> resolvers.settings.yaml
echo "  networkURL: $URL_POLYGON_NODE" >> resolvers.settings.yaml

cp ./resolvers.settings.yaml ./server/resolvers.settings.yaml
cp ./resolvers.settings.yaml ./onchain-issuer-demo/resolvers.settings.yaml
cp ./onchain-issuer.settings.yaml ./onchain-issuer-demo/onchain-issuer.settings.yaml

# Up frontend
pushd client
npm install
npm run dev &
CLIENT_PID=$!
popd

# Up server for auth
pushd server
docker rm -f mongo || true
docker run --rm -p 27017:27017  --name mongo -d mongo:latest
go build -o server
ONCHAIN_ISSUER_CONTRACT_ADDRESS=$ONCHAIN_ISSUER_CONTRACT_ADDRESS \
ONCHAIN_ISSUER_CONTRACT_BLOCKCHAIN=$ONCHAIN_ISSUER_CONTRACT_BLOCKCHAIN \
ONCHAIN_ISSUER_CONTRACT_NETWORK=$ONCHAIN_ISSUER_CONTRACT_NETWORK \
./server -dev &
SERVER_PID=$!
popd

# Up user demo
pushd onchain-issuer-demo
go build -o onchain-issuer-demo
./onchain-issuer-demo -dev &
ISSUER_PID=$!
popd

trap "kill -9 $CLIENT_PID $SERVER_PID $ISSUER_PID; exit" SIGINT

while true
do
    sleep 1
done