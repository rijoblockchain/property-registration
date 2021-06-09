package users

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	"prop-reg/registrar"
	
	
)

// Users smart contract provides functions for managing an Users
type Users struct {
	contractapi.Contract
}



// InitLedger intitates the smart contract with a message
func (u *Users) InitUsersLedger(ctx contractapi.TransactionContextInterface) error {
	fmt.Println("Users smart contract is initiated")
		return nil
}


func (u *Users) RequestNewUser(ctx contractapi.TransactionContextInterface, userRecord []byte) (*registrar.Request, error) {
	var newRequest *registrar.Request
	err := json.Unmarshal(userRecord, &newRequest)
	newRequest.CreatedAt = time.Now()

	requestCompositeKey, _ := ctx.GetStub().CreateCompositeKey("request.property-registration-network.com", []string{newRequest.Name, string(newRequest.AadharNumber)})
	marshaledUser, err := json.Marshal(newRequest)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal user request into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(requestCompositeKey, marshaledUser)
	if err != nil {
		return nil, fmt.Errorf("failed to put user request: %v", err)
	}
	return newRequest, nil

}

func (r *Users) RechargeAccount(ctx contractapi.TransactionContextInterface, name string, aadharNumber int, bankTransactionID string) (*registrar.User, error) {
	var usersContract = new(Users)
	var newUser *registrar.User
	
	newUser, err := usersContract.ViewUser(ctx, name, aadharNumber)

	if bankTransactionID == "upg100" {
		newUser.UpgradCoins = 100
	} else if bankTransactionID == "upg500" {
		newUser.UpgradCoins = 500
	} else if bankTransactionID == "upg1000" {
		newUser.UpgradCoins = 1000
	} else {
		return nil, fmt.Errorf("Invalid Bank Transaction ID")
	}
	
	marshaledUser, err := json.Marshal(newUser)

	userCompositeKey, _ := ctx.GetStub().CreateCompositeKey("user.property-registration-network.com", []string{name, string(aadharNumber)})
	
	err = ctx.GetStub().PutState(userCompositeKey, marshaledUser)
	if err != nil {
		return nil, fmt.Errorf("failed to put User data: %v", err)
	}
	return newUser, nil
}

func (u *Users) PropertyRegistrationRequest(ctx contractapi.TransactionContextInterface, propertyRecord []byte) (*registrar.Property, error) {
	
	var property *registrar.Property
	err := json.Unmarshal(propertyRecord, &property)

	requestCompositeKey, _ := ctx.GetStub().CreateCompositeKey("request.property-registration-network.com", []string{property.PropertyID})
	property.Owner, _ = ctx.GetStub().CreateCompositeKey("user.property-registration-network.com", []string{property.Name, string(property.AadharNumber)})
	
	marshaledProperty, err := json.Marshal(property)
	if err != nil {
		return nil, fmt.Errorf("failed to marshal property into JSON: %v", err)
	}
	err = ctx.GetStub().PutState(requestCompositeKey, marshaledProperty)
	if err != nil {
		return nil, fmt.Errorf("failed to put property registration request: %v", err)
	}
	return property, nil

}

func (u *Users) UpdateProperty(ctx contractapi.TransactionContextInterface, propertyID string, name string, aadharNumber int, status string) (*registrar.Property, error) {

	var users Users
	users.ViewUser(ctx, name, aadharNumber)
	/*if newUser == nil {
		fmt.Printf("%v does not exist in state ledger", name)
		return nil, nil
	}*/

	property, err := users.ViewProperty(ctx, propertyID)

	owner, err := ctx.GetStub().CreateCompositeKey("user.property-registration-network.com", []string{property.Name, string(property.AadharNumber)})
	if property.Owner != owner {
		fmt.Printf("%v is not the owner of this property %v",name, propertyID)
		return nil, nil
	}

	property.Status = status

	marshaledProperty, err := json.Marshal(property)

	propertyCompositeKey, _ := ctx.GetStub().CreateCompositeKey("property.property-registration-network.com", []string{propertyID})


	err = ctx.GetStub().PutState(propertyCompositeKey, marshaledProperty)
	if err != nil {
		return nil, fmt.Errorf("failed to put property registration request: %v", err)
	}
	return property, nil

}

func (u *Users) PurchaseProperty(ctx contractapi.TransactionContextInterface, propertyID string, name string, aadharNumber int) (*registrar.Property, error) {

	var users Users

	buyer, err := users.ViewUser(ctx, name, aadharNumber)

	property, err := users.ViewProperty(ctx, propertyID)

	if property.Status != "onSale" {
		return nil, fmt.Errorf("%v is not for sale", propertyID)
	}

	if buyer.UpgradCoins < property.Price {
		return nil, fmt.Errorf("%v doesn't have sufficient balance to buy this property", name)
	}

	sellerName := property.Name
	sellerAadhar := property.AadharNumber
	seller, err := users.ViewUser(ctx, sellerName, sellerAadhar)
	sellerCompositeKey, err := ctx.GetStub().CreateCompositeKey("user.property-registration-network.com", []string{sellerName, string(sellerAadhar)})
	fmt.Println(sellerCompositeKey)

	buyerCompositeKey, err := ctx.GetStub().CreateCompositeKey("user.property-registration-network.com", []string{name, string(aadharNumber)})
	property.Owner = buyerCompositeKey 
	property.Name = name
	property.AadharNumber = aadharNumber
	property.Status = "registered"
	buyer.UpgradCoins -= property.Price

	seller.UpgradCoins += property.Price

	marshaledProperty, err := json.Marshal(property)

	propertyCompositeKey, _ := ctx.GetStub().CreateCompositeKey("property.property-registration-network.com", []string{propertyID})


	err = ctx.GetStub().PutState(propertyCompositeKey, marshaledProperty)
	if err != nil {
		return nil, fmt.Errorf("failed to put property : %v", err)
	}

	marshaledBuyer, err := json.Marshal(buyer)

	err = ctx.GetStub().PutState(buyerCompositeKey, marshaledBuyer)
	if err != nil {
		return nil, fmt.Errorf("failed to put user: %v", err)
	}

	marshaledSeller, err := json.Marshal(seller)

	err = ctx.GetStub().PutState(sellerCompositeKey, marshaledSeller)
	if err != nil {
		return nil, fmt.Errorf("failed to put user: %v", err)
	}

	return property, nil

}


func (r *Users) ViewUser(ctx contractapi.TransactionContextInterface, name string, aadharNumber int) (*registrar.User, error) {
	
	var newUser *registrar.User
	userCompositeKey, _ := ctx.GetStub().CreateCompositeKey("user.property-registration-network.com", []string{name, string(aadharNumber)})
	userJSON, err := ctx.GetStub().GetState(userCompositeKey) //get the user details from chaincode state
	if err != nil {
		return nil, fmt.Errorf("failed to read user: %v", err)
	}

	//No Request found, return empty response
	if userJSON == nil {
		fmt.Printf("%v does not exist in state ledger", name)
		return nil, fmt.Errorf("%v does not exist in state ledger", name)
	}

	err = json.Unmarshal(userJSON, &newUser)
		if err != nil {
			return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
		}

		return newUser, nil
	}

func (r *Users) ViewProperty(ctx contractapi.TransactionContextInterface, propertyID string) (*registrar.Property, error) {
	var property *registrar.Property
	
	propertyCompositeKey, _ := ctx.GetStub().CreateCompositeKey("property.property-registration-network.com", []string{propertyID})
	propertyJSON, err := ctx.GetStub().GetState(propertyCompositeKey) //get the property details from Property state
	if err != nil {
		return nil, fmt.Errorf("failed to read property: %v", err)
	}
		
	//No Property found, return empty response
	if propertyJSON == nil {
		fmt.Printf("%v does not exist in state ledger", propertyID)
		return nil, fmt.Errorf("%v does not exist in state ledger", propertyID)
	}
	
	err = json.Unmarshal(propertyJSON, &property)
		if err != nil {
			return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
		}

		return property, nil
	}
