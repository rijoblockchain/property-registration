package registrar

import (
	"encoding/json"
	"fmt"
	"time"

	"github.com/hyperledger/fabric-contract-api-go/contractapi"
	
)

// SmartContract provides functions for managing an Asset
type Registrar struct {
	contractapi.Contract
}


// Asset describes basic details of what makes up a simple asset
type Request struct {
	Name            string `json:"name"`
	EmailID         string `json:"emailID"`
	PhoneNumber     int    `json:"phoneNumber"`
	AadharNumber    int    `json:"aadharNumber"`
	CreatedAt 		time.Time `json:"createdAt"`
}

type User struct {
	Request 		Request
	UpgradCoins     int `json:"upgradCoins"`
	
}

type Property struct {
	Name            string `json:"name"`
	AadharNumber    int    `json:"aadharNumber"`
	PropertyID		string `json:"propertyID"`
	Owner           string `json:"owner"`
	Price 			int    `json:"price"`
	Status			string `json:"status"`
}

var newUser User
var request Request
var property Property

// InitLedger adds a base set of assets to the ledger
func (r *Registrar) InitRegistrarLedger(ctx contractapi.TransactionContextInterface) error {
	fmt.Println("Registrar Smart contract is initiated")
	return nil
}

func (r *Registrar) ApproveNewUser(ctx contractapi.TransactionContextInterface, name string, aadharNumber int) (*User, error) {

	requestCompositeKey, _ := ctx.GetStub().CreateCompositeKey("request.property-registration-network.com", []string{name, string(aadharNumber)})
	userJSON, err := ctx.GetStub().GetState(requestCompositeKey) //get the user details from chaincode state
	if err != nil {
		return nil, fmt.Errorf("failed to read user: %v", err)
	}

	//No Request found, return empty response
	if userJSON == nil {
		fmt.Printf("%v does not exist in state ledger", name)
		return nil, nil
	}

	err = json.Unmarshal(userJSON, &request)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	newUser = User{request, 0}

	marshaledUser, err := json.Marshal(newUser)

	userCompositeKey, _ := ctx.GetStub().CreateCompositeKey("user.property-registration-network.com", []string{name, string(aadharNumber)})
	
	err = ctx.GetStub().PutState(userCompositeKey, marshaledUser)
	if err != nil {
		return nil, fmt.Errorf("failed to put User data: %v", err)
	}
	return &newUser, nil

}

func (r *Registrar) ApprovePropertyRegistration(ctx contractapi.TransactionContextInterface, propertyID string) (*Property, error) {

	requestCompositeKey, _ := ctx.GetStub().CreateCompositeKey("request.property-registration-network.com", []string{propertyID})
	propertyJSON, err := ctx.GetStub().GetState(requestCompositeKey) //get the property details from request state
	if err != nil {
		return nil, fmt.Errorf("failed to read property request: %v", err)
	}

	//No Request found, return empty response
	if propertyJSON == nil {
		fmt.Printf("%v does not exist in state ledger", propertyID)
		return nil, fmt.Errorf("%v does not exist in state ledger", propertyID)
	}

	err = json.Unmarshal(propertyJSON, &property)
	if err != nil {
		return nil, fmt.Errorf("failed to unmarshal JSON: %v", err)
	}

	property.Status = "registered"
	marshaledProperty, err := json.Marshal(property)

	propertyCompositeKey, _ := ctx.GetStub().CreateCompositeKey("property.property-registration-network.com", []string{propertyID})
	
	err = ctx.GetStub().PutState(propertyCompositeKey, marshaledProperty)
	if err != nil {
		return nil, fmt.Errorf("failed to put Property data: %v", err)
	}
	return &property, nil

}



func (r *Registrar) ViewUser(ctx contractapi.TransactionContextInterface, name string, aadharNumber int) (*User, error) {
	fmt.Printf("Read User State: Name %v", name)
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

		return &newUser, nil
	}


func (r *Registrar) ViewProperty(ctx contractapi.TransactionContextInterface, propertyID string) (*Property, error) {
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

		return &property, nil
	}


