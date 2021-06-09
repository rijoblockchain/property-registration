cd ~/property-registration/chaincode/src/prop-reg


go mod init prop-reg
go build main.go

cd ~/property-registration/network

./network.sh up createChannel -ca -s couchdb


./network.sh deployCC -ccn regnet -ccp ../chaincode/src/prop-reg/ -ccl go -ccep "OR('registrarMSP.peer')" 

./network.sh deployCC -ccn regnet -ccp ../chaincode/src/prop-reg/ -ccl go -ccep "OR('registrarMSP.peer')" -ccv 1.1 -ccs 2

peer lifecycle chaincode checkcommitreadiness --channelID registrationchannel --name regnet --version 1.2 --sequence 1 --signature-policy "OR('registrarMSP.peer')" --output json 

peer lifecycle chaincode commit -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --channelID registrationchannel --name regnet --version 1.3 --sequence 1 --signature-policy "OR('registrarMSP.peer')" --tls --cafile $ORDERER_CA --peerAddresses localhost:7051 --tlsRootCertFiles $PEER0_REGISTRAR_CA --peerAddresses localhost:9051 --tlsRootCertFiles $PEER0_USERS_CA 

peer lifecycle chaincode querycommitted --channelID registrationchannel --name regnet


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

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt"  -c '{"function":"InitPropertyLedger","Args":[]}'

export USER_RECORDS=$(echo -n "{\"name\":\"rijo\",\"emailID\":\"rijo@gmail.com\",\"phoneNumber\":9496646330,\"aadharNumber\":165784536787,\"createdAt\":\"\"}" | base64 | tr -d \\n)

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"RequestNewUser","Args":[]}' --transient "{\"user_records\":\"$USER_RECORDS\"}"


export CORE_PEER_LOCALMSPID="registrarMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_REGISTRAR_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/Admin@registrar.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"ApproveNewUser","Args":["rijo", "165784536787"]}'

peer chaincode query -C registrationchannel -n regnet -c '{"function":"ViewUser","Args":["rijo", "165784536787"]}'

export CORE_PEER_LOCALMSPID="usersMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_USERS_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"RechargeAccount","Args":["rijo", "165784536787", "upg500"]}'


# Second User

export CORE_PEER_LOCALMSPID="usersMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_USERS_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:9051

export USER_RECORDS=$(echo -n "{\"name\":\"John\",\"emailID\":\"john@gmail.com\",\"phoneNumber\":8089666155,\"aadharNumber\":69090909090,\"createdAt\":\"\"}" | base64 | tr -d \\n)

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"RequestNewUser","Args":[]}' --transient "{\"user_records\":\"$USER_RECORDS\"}"


export CORE_PEER_LOCALMSPID="registrarMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_REGISTRAR_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/Admin@registrar.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"ApproveNewUser","Args":["John", "69090909090"]}'

peer chaincode query -C registrationchannel -n regnet -c '{"function":"ViewUser","Args":["John", "69090909090"]}'

export CORE_PEER_LOCALMSPID="usersMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_USERS_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"RechargeAccount","Args":["John", "69090909090", "upg1000"]}'


export PROPERTY_RECORDS=$(echo -n "{\"name\":\"rijo\",\"aadharNumber\":165784536787,\"propertyID\":\"001\",\"owner\":\"\",\"price\":200,\"status\":\"\"}" | base64 | tr -d \\n)

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"PropertyRegistrationRequest","Args":[]}' --transient "{\"property_records\":\"$PROPERTY_RECORDS\"}"


export CORE_PEER_LOCALMSPID="registrarMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_REGISTRAR_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/Admin@registrar.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:7051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"ApprovePropertyRegistration","Args":["001"]}'


peer chaincode query -C registrationchannel -n regnet -c '{"function":"ViewProperty","Args":["001"]}'

export CORE_PEER_LOCALMSPID="usersMSP"
export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_USERS_CA
export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp
export CORE_PEER_ADDRESS=localhost:9051

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"UpdateProperty","Args":["001","rijo","165784536787","registered"]}'

peer chaincode query -C registrationchannel -n regnet -c '{"function":"ViewProperty","Args":["001"]}'


peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"UpdateProperty","Args":["001","rijo","165784536787","onSale"]}'

peer chaincode invoke -o localhost:7050 --ordererTLSHostnameOverride orderer.property-registration-network.com --tls --cafile "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem" -C registrationchannel -n regnet --peerAddresses localhost:7051  --tlsRootCertFiles "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt" -c '{"function":"PurchaseProperty","Args":["001","John","69090909090"]}'

peer chaincode query -C registrationchannel -n regnet -c '{"function":"ViewProperty","Args":["001"]}'

peer chaincode query -C registrationchannel -n regnet -c '{"function":"ViewUser","Args":["John", "69090909090"]}'

peer chaincode query -C registrationchannel -n regnet -c '{"function":"ViewUser","Args":["rijo", "165784536787"]}'