pragma solidity^0.4.24;
/**
 * @title Wallet Contract Example v3
 * @author Henrique
 **/
contract MyWallet{
    address private owner;
    uint8 constant private version = 3;
    
    event PayEvent(address receiver, uint amount);
    event DepositEvent(address sender, uint amount);
    
    constructor() public {
        owner = msg.sender;
    }
    
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }
    modifier checkBalance(uint amount){
        require(address(this).balance >= amount, "Insuficient funds for this operation.");
        _;
    }
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function pay(address receiver, uint amount) public onlyOwner checkBalance(amount) {
        receiver.transfer( amount );
        emit PayEvent(receiver, amount);
    }
    
    function withdraw(uint amount) public onlyOwner checkBalance(amount) {
        owner.transfer(amount);
    }
    
    function() public payable { //fallback
        emit DepositEvent(msg.sender, msg.value);
    }
} // end of contract
