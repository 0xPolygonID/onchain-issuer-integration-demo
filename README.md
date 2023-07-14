# Onchain-issuer-integration-demo

This is an example of using an on-chain issuer. In this application, we communicate with Metamask to retrieve the user's balance and the issuer's claim about the user's balance via the on-chain issuer.

There are three main components in this application:
1. On-chain issuer ([demo](https://github.com/0xPolygonID/onchain-issuer-demo/)|[contract](https://github.com/iden3/contracts))
2. Server for user authorization
3. Front-end component for communication with Metamask

## Requirments:
1. Node js => 18.x
2. Go => 1.20.x
3. npm => 9.x.x
3. docker => 20.x

## Configuration exists on run.sh file:
```bash
ONCHAIN_ISSUER_CONTRACT_ADDRESS=<ONCHAIN_ISSUER_CONTRACT_ADDRESS>
URL_MUMBAI_NODE=<URL_TO_POLYGON_MUMBAI_NODE>
URL_POLYGON_NODE=<URL_TO_POLYGON_MAINNET_NODE>
ONCHAIN_CONTRACT_OWNER=<PRIVATE_KEY_IS_USED_FOR_DEPLOY_ONCHAIN_ISSUER_CONTRACT>
MUMBAI_CONTRACT_STATE_ADDRESS=0x134B1BE34911E39A8397ec6289782989729807a4
MAIN_CONTRACT_STATE_ADDRESS=0xdc2A724E6bd60144Cde9DEC0A38a26C619d84B90
ONCHAIN_ISSUER_CONTRACT_BLOCKCHAIN=<BLOCKCHAIN_OF_ISSUER_CONTRACT>
ONCHAIN_ISSUER_CONTRACT_NETWORK=<BLOCKCHAIN_OF_WITH_ISSUER_CONTRACT>
```

## How to run:
1. Clone this repository:
    ```bash
    git clone https://github.com/0xPolygonID/onchain-issuer-integration-demo
    ```
2. Deploy onchain issuer contract. Use these next states:
    * For mumbai network: `0x134B1BE34911E39A8397ec6289782989729807a4`
    * For mainnet network: `0x624ce98D2d27b20b8f8d521723Df8fC4db71D79D`
3. Fill in the configuration files with the actual values.
4. Run the run.sh script:
    ```bash
    ./run.sh
    ```
5. Open http://localhost:3000 in your web browser.

## How to verify the balance claim:
1. Go to https://verifier-v2.polygonid.me/
2. Choose `custom` from the drop down
3. Fill form:
    * **Circuit Id**: Credential Atomic Query MTP;
    * **Url**: https://gist.githubusercontent.com/ilya-korotya/b06baa37453ed9aedfcb79100b84d51f/raw/balance-v1.jsonld;
    * **Type**: BalanceCredential;
    * **Field**: balance;
    * **Operator**: all operators work for the claim;
    * **Value**: set value that you want to verify;
4. Press submit;
5. Use mobile application for verify.


## Tested on:
1. MacBook Pro M1, OS: Monterey 12.3
