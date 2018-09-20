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

