# Hands-on: Solidity Patterns

In this material, I focused on coding patterns for Solidity. Due to the blockchain environment, some common programming practices for other languages may not be suited for a secure smart contract.

### 1.1. Privacy

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



