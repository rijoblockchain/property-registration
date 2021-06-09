


./network.sh up createChannel -ca -s couchdb


./network.sh deployCC -ccn regnet -ccp ../chaincode/src/prop-reg/ -ccl go -ccep "OR('registrarMSP.peer')"

export PATH=${PWD}/../bin:${PWD}:$PATH
export FABRIC_CFG_PATH=$PWD/../config/

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem
export PEER0_REGISTRAR_CA=${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt
export PEER0_USERS_CA=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.property-registration-network.com/peers/peer0.org3.property-registration-network.com/tls/ca.crt
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/server.key

export CORE_PEER_LOCALMSPID="usersMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_USERS_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:9051
