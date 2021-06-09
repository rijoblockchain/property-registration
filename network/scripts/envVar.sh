#!/bin/bash
#
# Copyright IBM Corp All Rights Reserved
#
# SPDX-License-Identifier: Apache-2.0
#

# This is a collection of bash functions used by different scripts

# imports
. scripts/utils.sh

export CORE_PEER_TLS_ENABLED=true
export ORDERER_CA=${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem
export PEER0_REGISTRAR_CA=${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt
export PEER0_USERS_CA=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/ca.crt
export PEER0_ORG3_CA=${PWD}/organizations/peerOrganizations/org3.property-registration-network.com/peers/peer0.org3.property-registration-network.com/tls/ca.crt
export ORDERER_ADMIN_TLS_SIGN_CERT=${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/server.crt
export ORDERER_ADMIN_TLS_PRIVATE_KEY=${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/server.key

# Set environment variables for the peer org
setGlobals() {
  local USING_PEER=$1
  local USING_ORG=""
  
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$2
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  infoln "Using organization ${USING_ORG}"
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_LOCALMSPID="registrarMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_REGISTRAR_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/Admin@registrar.property-registration-network.com/msp
    #export CORE_PEER_ADDRESS=localhost:7051
    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:7051
    else
      export CORE_PEER_ADDRESS=localhost:8051
    fi
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_LOCALMSPID="usersMSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_USERS_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp
    #export CORE_PEER_ADDRESS=localhost:9051
    if [ $USING_PEER -eq 0 ]; then
      export CORE_PEER_ADDRESS=localhost:9051
    fi
    if [ $USING_PEER -eq 1 ]; then
      export CORE_PEER_ADDRESS=localhost:10051
    fi
    if [ $USING_PEER -eq 2 ]; then
      export CORE_PEER_ADDRESS=localhost:11051
    fi
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_LOCALMSPID="Org3MSP"
    export CORE_PEER_TLS_ROOTCERT_FILE=$PEER0_ORG3_CA
    export CORE_PEER_MSPCONFIGPATH=${PWD}/organizations/peerOrganizations/org3.property-registration-network.com/users/Admin@org3.property-registration-network.com/msp
    export CORE_PEER_ADDRESS=localhost:11051
  else
    errorln "ORG Unknown"
  fi

  if [ "$VERBOSE" == "true" ]; then
    env | grep CORE
  fi

echo $CORE_PEER_LOCALMSPID
echo $CORE_PEER_ADDRESS
}



# Set environment variables for use in the CLI container 
setGlobalsCLI() {
  setGlobals 0 $1

  local USING_ORG=""
  if [ -z "$OVERRIDE_ORG" ]; then
    USING_ORG=$1
  else
    USING_ORG="${OVERRIDE_ORG}"
  fi
  if [ $USING_ORG -eq 1 ]; then
    export CORE_PEER_ADDRESS=peer0.registrar.property-registration-network.com:7051
  elif [ $USING_ORG -eq 2 ]; then
    export CORE_PEER_ADDRESS=peer0.users.property-registration-network.com:9051
  elif [ $USING_ORG -eq 3 ]; then
    export CORE_PEER_ADDRESS=peer0.org3.property-registration-network.com:11051
  else
    errorln "ORG Unknown"
  fi
}

# parsePeerConnectionParameters $@
# Helper function that sets the peer connection parameters for a chaincode
# operation
parsePeerConnectionParameters() {
  PEER_CONN_PARMS=()
  PEERS=""
  while [ "$#" -gt 0 ]; do
    setGlobals $1
    PEER="peer0.org$1"
    ## Set peer addresses
    if [ -z "$PEERS" ]
    then
	PEERS="$PEER"
    else
	PEERS="$PEERS $PEER"
    fi
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" --peerAddresses $CORE_PEER_ADDRESS)
    ## Set path to TLS certificate
    CA=PEER0_ORG$1_CA
    TLSINFO=(--tlsRootCertFiles "${!CA}")
    PEER_CONN_PARMS=("${PEER_CONN_PARMS[@]}" "${TLSINFO[@]}")
    # shift by one to get to the next organization
    shift
  done
}

verifyResult() {
  if [ $1 -ne 0 ]; then
    fatalln "$2"
  fi
}
