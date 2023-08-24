# !/bin/bash

set -e

# Use the code snippet to generate a DID (Decentralized Identifier) from the contract address.
# You can find the code snippet at: https://github.com/iden3/go-iden3-core/blob/be566366eb43673010175a6a2347c99db9b55ab2/did_test.go#L369-L380
# Replace "ethAddrHex" with value of "ONCHAIN_ISSUER_CONTRACT_ADDRESS" (without 0x) to generate the ONCHAIN_ISSUER_DID.
ONCHAIN_ISSUER_DID=

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
echo NEXT_PUBLIC_ONCHAIN_ISSUER_DID=$ONCHAIN_ISSUER_DID > .env.local
npm install
npm run dev > ./../client.log 2>&1 &
CLIENT_PID=$!
echo "PID FOR FRONTEND: $CLIENT_PID"
popd

# Up server for auth
pushd server
go build -o server
ONCHAIN_ISSUER_CONTRACT_ADDRESS=$ONCHAIN_ISSUER_CONTRACT_ADDRESS \
ONCHAIN_ISSUER_CONTRACT_BLOCKCHAIN=$ONCHAIN_ISSUER_CONTRACT_BLOCKCHAIN \
ONCHAIN_ISSUER_CONTRACT_NETWORK=$ONCHAIN_ISSUER_CONTRACT_NETWORK \
./server -dev > ./../auth.log 2>&1 &
SERVER_PID=$!
echo "PID FOR AUTH SERVER: $SERVER_PID"
popd

# Up user demo
pushd onchain-issuer-demo
docker rm -f mongo || true
docker run --rm -p 27017:27017  --name mongo -d mongo:latest
go build -o onchain-issuer-demo
./onchain-issuer-demo -dev > ./../onchain-issuer-demo.log 2>&1 &
ISSUER_PID=$!
echo "PID FOR ON CHAIN ISSUER SERVER: $ISSUER_PID"
popd

trap "kill -9 $CLIENT_PID $SERVER_PID $ISSUER_PID; exit" SIGINT

while true
do
    sleep 1
done
