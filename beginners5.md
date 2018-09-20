## 5. Lesson 5 (Under development -- needs new section title)

Due to time constraints, Section 5 was not presented at CBSoft. However, this lesson is important to understand more concepts of Solidity.

### 5.1. Complex Types

We can do a lot with primitive types. But most languages offers some way to compose more complex types. The following list shows Solidity complex types and some examples:

* __struct__ - similar to C++ structs, it serves as a container for a set of variables. Functions in Solidity cannot return structs. Example:
```solidity
struct BondType { //creating the struct
    string name;
    uint issue_price;
    uint face_value;
}
BondType StandardBond = BondType("standard",10,12); //defining a struct attribute and setting its value 
```
* __enum__ - also similar to C++ enums, we can create a type set. They are explicitly convertible to and from all integer types but implicit conversion is not allowed. Example: 
```solidity
enum States{ OPEN, CLOSED, CANCELED};
States myState = States.OPEN; 
```
* __array__ - supports fixed sized arrays and also dynamic ones. We can access array elements by using an index enclosed by brackets (similar to C++ or JavaScript). Example: 
```solidity
address[] voters; //dynamic sized array
address[5] supervisors; //fixed sized array
uint private superCount = 0;

function addVoter(address v) public{ voters.push( v ); }
function addSuper(address s) public { 
    require(superCount < supervisors.length, "Too many Supers in this");
    supervisors[ superCount++ ] = s;
}
```

* __mapping__ - a mapping is like a hash table where we define the key => value. Not every type can be used as key, but any primitive type is safe to use. For the value, almost anything can be used. The mapping is virtually initialized in a way that every key exists and the value is set to zero (or a byte-representation composed of only zeros). Example: 

```solidity
mapping(address=>uint) funds; //maps an address (key) to an unsigned integer (value)

function verifyMyFunds() public view returns(uint) {
    return funds[ msg.sender ];
}
```
* __contract__ - we can also use (and instantiate) other contracts inside one. We go into more details on that soon.

### 5.2. Deploying Another Contract

For a contract to deploy another, it just needs to instantiate it (using the ```new``` keyword). Just be sure to return or save the new instance address for future use (otherwise you may "loose" your new contract in the blockchain). The complete source of the instantiated needs to be available.

As an example to demonstrate a contract creating others, I will show a fixed interest Bond marketplace. A bond is a fixed income investment in which an investor loans money to an entity (e.g., a company or the State). Our example is a simplified Bond (without interest rates, coupon dates, etc.). Our marketplace creates Bonds contracts which can be self managed by its users.

```solidity
pragma solidity^0.4.24;
/** 
 * @title Bond Market for Investors
 * @author Henrique
 */
contract BondMarket {
    struct BondType{string name; uint issue_price; uint face_value;}
    mapping(string=>BondType) available;
    address private owner;
    
    constructor() public {
        owner = msg.sender;
        addBondType('b5',5,11);
        addBondType('b13',13,30);
    }
    function() public payable{
        
    }
    function getFunds(uint amount) public {
        require(msg.sender == owner);
        require(address(this).balance >= amount);
        owner.transfer(amount);
    }
    function addBondType(string name, uint price, uint value) public{
        require(owner == msg.sender);
        available[name]=BondType(name,price*1 ether,value*1 ether);
    }
    function removeBondType(string name) public {
        require(owner == msg.sender);
        delete available[name];
    }
    function checkBondType(string name) public view returns(uint,uint){
        return (available[name].issue_price,available[name].face_value);
    }
    
    function buyBond(string name) public payable returns(Bond) {
        require( msg.value>0 && available[name].issue_price == msg.value );
        Bond b = new Bond(msg.sender, name,
            available[name].issue_price, available[name].face_value);
        return b;
    }
    function cashBond(Bond b) public {
        require(b.getIssuer() == address(this));
        require(b.getOwner() == msg.sender);
        require(b.getStartDate()+365 days == now);
        uint face_value = b.getFaceValue();
        address(b).transfer( face_value );
        b.terminate();
    }
} //end of contract

contract Bond {
    address private issuer; address private owner;
    string public name; uint private start_date;
    uint private issue_price; uint private face_value;
    uint private selling_price;
    
    constructor(address _owner,string _name,uint _price,uint _value)public{
        issuer = msg.sender;
        start_date = now;
        
        owner = _owner;
        name = _name;
        issue_price = _price;
        face_value = _value;
        selling_price = 0;
    }
    function() public payable {
    }
    function openForSale(uint _sellingPrice) public {
        require(msg.sender == owner);
        selling_price = _sellingPrice*1 ether;
    }
    function checkSellingPrice() public view returns (uint){
        return selling_price;
    }
    function buy() public payable{
        require(selling_price > 0 && msg.value == selling_price);
        address previous_owner = owner;
        owner = msg.sender;
        selling_price = 0;
        previous_owner.transfer(msg.value);
    }
    function terminate() public {
        require(msg.sender == issuer);
        require(address(this).balance >= face_value);
        selfdestruct(owner);
    }
    
    function getIssuer() public view returns (address){
        return issuer;
    }
    function getOwner() public view returns (address){
        return owner;
    }
    function getFaceValue() public view returns(uint){
        return face_value;
    }
    function getStartDate() public view returns(uint){
        return start_date;
    }
}
```

### 5.3. Killing a Contract

...
