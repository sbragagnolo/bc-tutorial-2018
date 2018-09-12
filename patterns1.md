# Hands-on: Solidity Patterns

In this material, I focused on coding patterns for Solidity. Due to the blockchain environment, some common programming practices for other languages may not be suited for a secure smart contract.

## 1. Privacy

Privacy is a big issue in the blockchain platforms, and common programming practices may not protect our information the way we are used to. Let's use for example a Bank contract (this bank could store tokens or Ether, for the coding example it does not matter).

```solidity
pragma solidity^0.4.24;
/**
 * @title Bank Unsecured (privacy compromised)
 * @author Henrique
 */
contract Bank {
    struct Client {uint id; string name; string phone; string _address; uint balance;}
    mapping(uint=>Client) private clients;
    address private owner;
     
    constructor() public{ owner = msg.sender; }
   
    function addClient(uint id, string name, string phone, string _address) public {
        require(owner == msg.sender);
        clients[id] = Client(id,name,phone,_address,0);
    }
     
    function deposit(uint id) public { }
    function withdraw(uint id, uint amount) public { }
} //end of contract
```

All information in the blockchain is public and visible to anyone. Therefore, developers must ensure data privacy by themselves. The private visibility prevents others to modify an attribute, but its contents are still visible to anyone in the blockchain. In the above example, anyone would be able to see your clients' sensible information (name, phone, address).

First rule of privacy in the blockchain is to avoid storing sensible information. To make our Bank contract more secure, we are not going to store clients information. We also are going to use the client's blockchain address for control (since it is already a hashed and public information on the blockchain). 

```solidity
pragma solidity^0.4.24;
/**
 * @title Private Bank 
 * @author Henrique
 */
contract Bank {
    struct Client {address add; uint balance;}
    mapping(address=>Client) private clients;
    address private owner;
     
    constructor() public{ owner = msg.sender; }

    function addClient(address clientAddress) public {
        require(owner == msg.sender);
        clients[clientAddress] = Client(clientAddress,0);
    }
     
    function deposit() public { }
    function withdraw(uint amount) public { }
} //end of contract
```

The most used practice to ensure data privacy is to Hash the information. A hash will have no meaning to anyone looking at. However, if we need the original data, we can use a secondary private database linking to the hash. 

## 2. Random Generation

At first glance random number generation may not seem like a problem. However, it is very tricky to create a truly random number in Solidity (if you don’t want people to cheat). 

Miners have access to many environment variables (e.g., timestamp, blockhash) and also the contract's internal state before executing your contract. Moreover, a miner can (and probably will) manipulate some of the environmnet variables to get an advantage. Therefore, we should not rely on these variable to generate random numbers. 

There are many Random number generation patterns for Solidity. Each pattern varies a lot depending on the requirements and usage of the random numbers. Thus, I will not present any, I just want to reinforce the caution. Here is a [link](https://medium.com/@promentol/lottery-smart-contract-can-we-generate-random-numbers-in-solidity-4f586a152b27) to discussing a Lotery smart contract and random generation. 

## 3. State Machine

A common pattern in contracts is to make then act as a state machine. We use an ```enum``` to define the states, and an attribute to control which state the contract is currently in. A function can change the contract state into a different one. Moreover, some functions can become unavailble (or behave differntly) depending on which state the contract is.

For example, let's code a cryptocurrency Crowdfund contract. The states are very simple, when we create the contract the crowdfund is "Open". The contract can only receive pledges when it is "Open". After its expiration, if the total money raised equals or exceeds the minimum required, then the contract is "Closed" and the money is given to the person who created the crowdfund. Otherwise, the contract goes to a "refund" state, and everyone who contributed can ask for their refund. 

```solidity
pragma solidity^0.4.24;
/**
 * @title Crowdfunding contract  
 */ 
contract CrowdFund{
    enum State { Open, Refund, Closed }
    address private owner;
    uint totalraised;
    string fundUrl;
    mapping (address=>uint) pledges;
    uint minimumRequired;
    uint expiration; //in days
    State currentState;
    
    constructor(string url, uint min, uint exp) public {
        owner = msg.sender;
        currentState = State.Open;
        fundUrl = url;
        minimumRequired = min;
        expiration = now + (exp * 1 days);
    }
    
    function contribute() public payable{
        checkExpiration();
        require(currentState == State.Open,"Cannot contribute to an expired Crowdfund.");
        pledges[msg.sender] = msg.value;
        totalraised += msg.value;
    }
    
    function refund() public {
        require(currentState == State.Refund,"Crowfund is not refunding yet.");
        uint amount = pledges[msg.sender]; 
        pledges[msg.sender]=0;
        msg.sender.transfer(amount);
    }
    
    function checkExpiration() public {
        require(currentState == State.Open,"Contract is already expired");
        if(now >= expiration){
            if(totalraised >= minimumRequired){
                currentState = State.Closed;
                getFunds();
            }
            else{
                currentState = State.Refund;
            }
        }
    }
    
    function getFunds() public {
        require(owner == msg.sender,"Only owner can get the funds.");
        require(currentState == State.Closed,"Crowdfund is not closed yet.");
        owner.transfer( address(this).balance );
    }   
} //end of contract
```

# 4. Reentrancy




