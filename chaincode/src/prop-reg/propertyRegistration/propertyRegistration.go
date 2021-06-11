package propertyRegistration

import (
	"fmt"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"prop-reg/registrar"
	"prop-reg/users"
)

// PropertyRegistration SmartContract provides functions for managing an registrar and users smart contracts
type PropertyRegistration struct {
	contractapi.Contract
}

var usersContract users.Users
var registrarContract registrar.Registrar
var newRequest *registrar.Request
var newUser *registrar.User
var propertyDetails *registrar.Property

// InitPropertyLedger initializes the contract
func (p *PropertyRegistration) InitPropertyLedger(ctx contractapi.TransactionContextInterface) error {
	fmt.Println(registrarContract.InitRegistrarLedger(ctx))
	fmt.Println(usersContract.InitUsersLedger(ctx))
	return nil
}

// Invokes the RequestNewUser smart contract from users contract
func (p *PropertyRegistration) RequestNewUser(ctx contractapi.TransactionContextInterface) (*registrar.Request, error) {
	// Get the function invoking client's MSP ID
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	// If users not calling this function, declines the transaction
	if clientMSPID != "usersMSP" {
		return nil, fmt.Errorf("client from org %v is not authorized to request new user", clientMSPID)
	}
	
	// Records are passed in transient field to make it more secure.
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return nil, fmt.Errorf("error getting transient: %v", err)
	}


	// Users records are private, therefore they get passed in transient field, instead of func args
	transientUserJSON, ok := transientMap["user_records"]
	if !ok {
		//log error to stdout
		return nil, fmt.Errorf("new Request not found in the transient map input")
	}

	newRequest, err = usersContract.RequestNewUser(ctx, transientUserJSON)
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}
	
	return newRequest, nil
	
}

// Invokes the ApproveNewUser smart contract from registrar contract
func (p *PropertyRegistration) ApproveNewUser(ctx contractapi.TransactionContextInterface, name string, aadharNumber int) (*registrar.User, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "registrarMSP" {
		return nil, fmt.Errorf("client from org %v is not authorized to approve new user", clientMSPID)
	}

	newUser, err = registrarContract.ApproveNewUser(ctx, name, aadharNumber)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}

	return newUser, nil
}

// Invokes the RechargeAccount smart contract from users contract
func (p *PropertyRegistration) RechargeAccount(ctx contractapi.TransactionContextInterface, name string, aadharNumber int, bankTransactionID string) (*registrar.User, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "usersMSP" {
		return nil, fmt.Errorf("client from org %v is not authorized to recharge account", clientMSPID)
	}

	newUser, err = usersContract.RechargeAccount(ctx, name, aadharNumber, bankTransactionID)
	if err != nil {
		return nil, fmt.Errorf("failed to create user: %v", err)
	}

	return newUser, nil
}

// Invokes the PropertyRegistrationRequest smart contract from users contract
func (p *PropertyRegistration) PropertyRegistrationRequest(ctx contractapi.TransactionContextInterface) (*registrar.Property, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "usersMSP" {
		return nil, fmt.Errorf("client from org %v is not authorized to request new user", clientMSPID)
	}
	
	transientMap, err := ctx.GetStub().GetTransient()
	if err != nil {
		return nil, fmt.Errorf("error getting transient: %v", err)
	}


	// Property records get passed in transient field, instead of func args
	transientPropertyJSON, ok := transientMap["property_records"]
	if !ok {
		//log error to stdout
		return nil, fmt.Errorf("new Request not found in the transient map input")
	}

	propertyDetails, err = usersContract.PropertyRegistrationRequest(ctx, transientPropertyJSON)
	
	if err != nil {
		return nil, fmt.Errorf("failed to create request: %v", err)
	}
	
	return propertyDetails, nil	
}

// Invokes the ApprovePropertyRegistration smart contract from registrar contract
func (p *PropertyRegistration) ApprovePropertyRegistration(ctx contractapi.TransactionContextInterface, propertyID string) (*registrar.Property, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "registrarMSP" {
		return nil, fmt.Errorf("client from org %v is not authorized to approve new user", clientMSPID)
	}

	propertyDetails, err = registrarContract.ApprovePropertyRegistration(ctx, propertyID)
	if err != nil {
		return nil, fmt.Errorf("failed to create property: %v", err)
	}

	return propertyDetails, nil
}

// Invokes the UpdateProperty smart contract from users contract
func (p *PropertyRegistration) UpdateProperty(ctx contractapi.TransactionContextInterface, propertyID string, name string, aadharNumber int, status string) (*registrar.Property, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "usersMSP" {
		return nil, fmt.Errorf("client from org %v is not authorized to approve new user", clientMSPID)
	}

	propertyDetails, err = usersContract.UpdateProperty(ctx, propertyID, name, aadharNumber, status)
	if err != nil {
		return nil, fmt.Errorf("failed to update property: %v", err)
	}

	return propertyDetails, nil
}

// Invokes the PurchaseProperty smart contract from users contract
func (p *PropertyRegistration) PurchaseProperty(ctx contractapi.TransactionContextInterface, propertyID string, name string, aadharNumber int) (*registrar.Property, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID != "usersMSP" {
		return nil, fmt.Errorf("client from org %v is not authorized to approve new user", clientMSPID)
	}

	propertyDetails, err = usersContract.PurchaseProperty(ctx, propertyID, name, aadharNumber)
	if err != nil {
		return nil, fmt.Errorf("failed to purchase property: %v", err)
	}

	return propertyDetails, nil
}

// Invokes the ViewUser smart contract from users contract if client is users and from registrar if client is registrar
func (p *PropertyRegistration) ViewUser(ctx contractapi.TransactionContextInterface, name string, aadharNumber int) (*registrar.User, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID == "usersMSP" {
		newUser, err = usersContract.ViewUser(ctx, name, aadharNumber)
		if err != nil {
			return nil, fmt.Errorf("failed to read patient: %v", err)
		}
		
		return newUser, nil
		
	}

	if clientMSPID == "registrarMSP" {
		newUser, err = registrarContract.ViewUser(ctx, name, aadharNumber)
		if err != nil {
			return nil, fmt.Errorf("failed to read user: %v", err)
		}
		
		return newUser, nil		
	}
	return nil, nil
}

// Invokes the ViewProperty smart contract from users contract if client is users and from registrar if client is registrar
func (p *PropertyRegistration) ViewProperty(ctx contractapi.TransactionContextInterface, propertyID string) (*registrar.Property, error) {
	clientMSPID, err:= ctx.GetClientIdentity().GetMSPID()
	if err != nil {
		return nil, fmt.Errorf("failed getting the client's MSPID: %v", err)
	}

	if clientMSPID == "usersMSP" {
		propertyDetails, err = usersContract.ViewProperty(ctx, propertyID)
		if err != nil {
			return nil, fmt.Errorf("failed to read property: %v", err)
		}
		
		return propertyDetails, nil
		
	}

	if clientMSPID == "registrarMSP" {
		propertyDetails, err = registrarContract.ViewProperty(ctx, propertyID)
		if err != nil {
			return nil, fmt.Errorf("failed to read property: %v", err)
		}
		
		return propertyDetails, nil		
	}
	return nil, nil
}