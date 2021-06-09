#!/bin/bash

function createRegistrar() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/registrar.property-registration-network.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:7054 --caname ca-registrar --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-registrar.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-registrar.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-registrar.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-7054-ca-registrar.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-registrar --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-registrar --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-registrar --id.name registraradmin --id.secret registraradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-registrar -M "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/msp" --csr.hosts peer0.registrar.property-registration-network.com --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:7054 --caname ca-registrar -M "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls" --enrollment.profile tls --csr.hosts peer0.registrar.property-registration-network.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/tlsca/tlsca.registrar.property-registration-network.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/ca"
  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer0.registrar.property-registration-network.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/ca/ca.registrar.property-registration-network.com-cert.pem"


  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-registrar --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-registrar -M "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/msp" --csr.hosts peer1.registrar.property-registration-network.com --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:7054 --caname ca-registrar -M "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls" --enrollment.profile tls --csr.hosts peer1.registrar.property-registration-network.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/tlsca/tlsca.registrar.property-registration-network.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/peers/peer1.registrar.property-registration-network.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/ca/ca.registrar.property-registration-network.com-cert.pem"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:7054 --caname ca-registrar -M "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/User1@registrar.property-registration-network.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/User1@registrar.property-registration-network.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://registraradmin:registraradminpw@localhost:7054 --caname ca-registrar -M "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/Admin@registrar.property-registration-network.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/registrar/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/registrar.property-registration-network.com/users/Admin@registrar.property-registration-network.com/msp/config.yaml"
}

function createUsers() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/peerOrganizations/users.property-registration-network.com/

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/peerOrganizations/users.property-registration-network.com/

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:8054 --caname ca-users --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-users.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-users.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-users.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-8054-ca-users.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/config.yaml"

  infoln "Registering peer0"
  set -x
  fabric-ca-client register --caname ca-users --id.name peer0 --id.secret peer0pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering user"
  set -x
  fabric-ca-client register --caname ca-users --id.name user1 --id.secret user1pw --id.type client --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the org admin"
  set -x
  fabric-ca-client register --caname ca-users --id.name registraradmin --id.secret registraradminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer0 msp"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/msp" --csr.hosts peer0.users.property-registration-network.com --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/msp/config.yaml"

  infoln "Generating the peer0-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer0:peer0pw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls" --enrollment.profile tls --csr.hosts peer0.users.property-registration-network.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/server.key"

  mkdir -p "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/tlscacerts"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/tlscacerts/ca.crt"

  mkdir -p "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/tlsca"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/tlsca/tlsca.users.property-registration-network.com-cert.pem"

  mkdir -p "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/ca"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer0.users.property-registration-network.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/ca/ca.users.property-registration-network.com-cert.pem"

  infoln "Registering peer1"
  set -x
  fabric-ca-client register --caname ca-users --id.name peer1 --id.secret peer1pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer1 msp"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/msp" --csr.hosts peer1.users.property-registration-network.com --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/msp/config.yaml"

  infoln "Generating the peer1-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer1:peer1pw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls" --enrollment.profile tls --csr.hosts peer1.users.property-registration-network.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/tlsca/tlsca.users.property-registration-network.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer1.users.property-registration-network.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/ca/ca.users.property-registration-network.com-cert.pem"

  infoln "Registering peer2"
  set -x
  fabric-ca-client register --caname ca-users --id.name peer2 --id.secret peer2pw --id.type peer --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the peer2 msp"
  set -x
  fabric-ca-client enroll -u https://peer2:peer2pw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/msp" --csr.hosts peer2.users.property-registration-network.com --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/msp/config.yaml"

  infoln "Generating the peer2-tls certificates"
  set -x
  fabric-ca-client enroll -u https://peer2:peer2pw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls" --enrollment.profile tls --csr.hosts peer2.users.property-registration-network.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/ca.crt"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/signcerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/server.crt"
  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/keystore/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/server.key"

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/tlscacerts/ca.crt"

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/tlsca/tlsca.users.property-registration-network.com-cert.pem"

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/peers/peer2.users.property-registration-network.com/msp/cacerts/"* "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/ca/ca.users.property-registration-network.com-cert.pem"


  infoln "Generating the user msp"
  set -x
  fabric-ca-client enroll -u https://user1:user1pw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/User1@users.property-registration-network.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/User1@users.property-registration-network.com/msp/config.yaml"

  infoln "Generating the org admin msp"
  set -x
  fabric-ca-client enroll -u https://registraradmin:registraradminpw@localhost:8054 --caname ca-users -M "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/users/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/msp/config.yaml" "${PWD}/organizations/peerOrganizations/users.property-registration-network.com/users/Admin@users.property-registration-network.com/msp/config.yaml"
}

function createOrderer() {
  infoln "Enrolling the CA admin"
  mkdir -p organizations/ordererOrganizations/property-registration-network.com

  export FABRIC_CA_CLIENT_HOME=${PWD}/organizations/ordererOrganizations/property-registration-network.com

  set -x
  fabric-ca-client enroll -u https://admin:adminpw@localhost:9054 --caname ca-orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  echo 'NodeOUs:
  Enable: true
  ClientOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: client
  PeerOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: peer
  AdminOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: admin
  OrdererOUIdentifier:
    Certificate: cacerts/localhost-9054-ca-orderer.pem
    OrganizationalUnitIdentifier: orderer' > "${PWD}/organizations/ordererOrganizations/property-registration-network.com/msp/config.yaml"

  infoln "Registering orderer"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name orderer --id.secret ordererpw --id.type orderer --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Registering the orderer admin"
  set -x
  fabric-ca-client register --caname ca-orderer --id.name ordererAdmin --id.secret ordererAdminpw --id.type admin --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  infoln "Generating the orderer msp"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp" --csr.hosts orderer.property-registration-network.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/property-registration-network.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/config.yaml"

  infoln "Generating the orderer-tls certificates"
  set -x
  fabric-ca-client enroll -u https://orderer:ordererpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls" --enrollment.profile tls --csr.hosts orderer.property-registration-network.com --csr.hosts localhost --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/ca.crt"
  cp "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/signcerts/"* "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/server.crt"
  cp "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/keystore/"* "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/server.key"

  mkdir -p "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem"

  mkdir -p "${PWD}/organizations/ordererOrganizations/property-registration-network.com/msp/tlscacerts"
  cp "${PWD}/organizations/ordererOrganizations/property-registration-network.com/orderers/orderer.property-registration-network.com/tls/tlscacerts/"* "${PWD}/organizations/ordererOrganizations/property-registration-network.com/msp/tlscacerts/tlsca.property-registration-network.com-cert.pem"

  infoln "Generating the admin msp"
  set -x
  fabric-ca-client enroll -u https://ordererAdmin:ordererAdminpw@localhost:9054 --caname ca-orderer -M "${PWD}/organizations/ordererOrganizations/property-registration-network.com/users/Admin@property-registration-network.com/msp" --tls.certfiles "${PWD}/organizations/fabric-ca/ordererOrg/tls-cert.pem"
  { set +x; } 2>/dev/null

  cp "${PWD}/organizations/ordererOrganizations/property-registration-network.com/msp/config.yaml" "${PWD}/organizations/ordererOrganizations/property-registration-network.com/users/Admin@property-registration-network.com/msp/config.yaml"
}
