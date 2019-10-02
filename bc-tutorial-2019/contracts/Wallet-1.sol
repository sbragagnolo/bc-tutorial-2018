pragma solidity ^0.5.1;

contract MyWallet{
    address payable private owner;
    uint8 constant private version = 1; //just to keep track of the versions
    
    constructor() public payable{
        owner = msg.sender;
    }
    modifier onlyOwner(){
        require(owner == msg.sender);
        _;
    }
    modifier checkBalance(uint amount){
        require(address(this).balance >= amount);
        _;
    }
    function getBalance() public view returns(uint){
        return address(this).balance;
    }
    function pay(address payable receiver, uint  amount) public onlyOwner checkBalance(amount) {
        receiver.transfer( amount );
    }
    function deposit() public payable {
        //Yes the deposit function is empty
    }
    
    function withdraw(uint amount) public onlyOwner checkBalance(amount) {
        owner.transfer(amount);
    }
} //end of contract
