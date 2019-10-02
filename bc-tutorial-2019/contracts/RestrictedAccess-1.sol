pragma solidity ^0.5.1;

contract FirstContract {
    address private owner;
    string name;
    
    
    constructor () public {
        owner = msg.sender;
    }
    
   
    function setName( string memory _name) public {
        require(owner == msg.sender, "Only the owner can invoke this method");
        name = _name; 
    }
    function getName () public view returns (string memory)  {
        return name;
        
    }
    
}

