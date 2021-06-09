/*
SPDX-License-Identifier: Apache-2.0
*/

package main

import (
	"log"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"prop-reg/propertyRegistration"
)

func main() {
	propertyRegistrationChaincode, err := contractapi.NewChaincode(&propertyRegistration.PropertyRegistration{})
	if err != nil {
		log.Panicf("Error creating PropertyRegistration chaincode: %v", err)
	}

	if err := propertyRegistrationChaincode.Start(); err != nil {
		log.Panicf("Error starting chaincode: %v", err)
	}

	/*usersChaincode, err := contractapi.NewChaincode(&chaincode.Users{})
	if err != nil {
		log.Panicf("Error creating Users chaincode: %v", err)
	}

	if err := usersChaincode.Start(); err != nil {
		log.Panicf("Error starting Users chaincode: %v", err)
	}*/
}
