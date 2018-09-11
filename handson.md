# Exercises: Hands-on Beginner to Solidity

In this section, I will present some hands-on coding exercises for coding smart contracts in Solidity. I will also explain some of the basic concepts of the Solidity language before each exercise.

## 1. Starting out

### 1.1. What is Solidity

Solidity is high-level language to code smart contracts in the Ethereum platform. Solidity is a statically typed language inspired by C++, Javascript, and Python. It supports multiple inheritance, user defined types (e.g., structs, enums), and it even has some "syntactic suggar" for other features. Please, consult the [Solidity Documentation](https://solidity.readthedocs.io/en/latest/) for a more in depth language description.

Most of the language commands resemble JavaScript, for example the code sniped bellow show a simple usage of an "for" and a "if-else" statements.
```solidity
for(int i=0; i<10; i++){
    if( i%2 == 0 ){
        // Do something...
    }
    else{
        // Do something else ...
    }
}
```

### 1.2. Remix

[Remix](https://remix.ethereum.org/) is an IDE for Solidity. It can run directly on your web-browser without the need to download or install anything. Remix uses the latest Javascript compiler for Solidity. One of the best features of Solidity is that it runs on a simulator enviroment by default. Therefore, we can play with contract code without having to connect to the Ethereum blockchain (which we need to pay for most of its operations).

All the exercises in this section use Remix. Therefore, you should open and get acquainted with it. The figure bellow shows the Remix interface.

![Remix Interface](/images/remix.png)

At the left part of the screen, we can see "browser" and "config". Browser will show all contracts that you have created in Remix. Config is used for special setup and I will not use that. At the very top on the left part, we can see some small icons. The most important one (and the only we are going to need) is the first icon that looks like a plus sign. That icon creates a new contract.

The middle part of the screen is the code editor. The lower part of the middle screen is the transactions log. Every operation on the blockchain creates a transaction. Remix will show on this log every transaction that it created. 

Now, I recommend paying special attention to the right part, here is where most of our interactions with the smart contracts will happen. There are 6 tabs on the right part, but for this tutorial we only need the first two: "compile" and "run". Compile is useful to verify the errors and warnings on your code, use this tab if you are having a hard time fixing your code. The Run tab is where the "magic" is, so lets focus on it.

* The enviroment combobox for this tutorial should be JavaScript VM. That is a simulation of an Ethereum blockchain. The other enviroment options allow to actually connect to Ethereum. 
* The accounts will have some pre-generated user accounts, each with 100 Ether on it (on the JavaScript VM enviroment). We will need accounts to deploy and interact with contracts. The selected account in this comboox will be the one that is "executing" the operations. 
* The gas limit is how much gas we are sending when we execute the next transaction. For more information on gas check [this](https://solidity.readthedocs.io/en/v0.4.24/introduction-to-smart-contracts.html?limit#gas).
* Value is how much cryptocurrency the selected account will send when we execute the next transaction. The usually unit is Wei (1 Ether = 10^18 Wei ), but we can change the unit on the left combobox of value.
* The next combobox will have the available contracts on this source code that compile without errors. 
* The deploy bottom will deploy one instance of the selected contract (on the above combobox).
* The next textfield is used to load a contract instance that was previously deployed. The specified address will be "type-casted" as the selected contract on the above combobox.
* The next panel shows the transactions recorded for this contract. This differs from the transaction log at the bottom that shows transaction from every contract.
* The final panel is where your deployed contracts will be. Clicking on the deployed contract instance will open the options to call its functions (and that is how we interact with contracts).

Understanding the Remix IDE is important to execute the tutorial examples. Please come back here and read it again if you are struggling to execute something (most of the time is just a matter is selecting the right thing in one combobox at the Run tab).

### 1.3. My First Contract

Lets start by creating our first smart contract in Solidity. I am a firm believer in "learn by doing it". Remember to use [Remix](https://remix.ethereum.org/) to deploy the contract and execute its functions.

A contract is very similar to a class in a object-oriented programming. It contains attributes, functions, and etc. Lets jump into the code to our first contract (ignore the warnings for now).

```solidity
pragma solidity ^0.4.24;
/**
 * @title My First Contract
 * @author Henrique
 */
contract MyFirstContract {
    string name;
    
    function setName(string _name){
        name = _name;
    }
    
    function getName() returns (string) {
        return name;
    }
}
```

The first line `pragma solidity^0.4.24;` indicates which version of Solidity we are using (I am using the most current version at the time I wrote this tutorial). Since the Solidity language is still under development, a lot can change between even minor versions releases. Therefore, specifying the version makes the compiler aware of which version to use. 

Comments in Solidity are like C++ and Javascript (and many others). However, if a you start a multi-line with an extra asterisk (`/**`) or a single line comment with an extra slash (`///`), then you are indicating that this comment will have tags to complement the information of the definition (similar to a JavaDoc). In my example (lines 2-5), I am using a tag to indicate the title of a contract a another to indicate its author.

Every contract is created by using the `contract` keyword. As I previously said, it can contain attributes, functions, and other elements. In this contract, I created one attribute called 'name' and two functions. For now you can ignore the warning on the functions (I will came back to fix these warnings latter). To deploy the contract select its name on the right part and click on the deploy button. An instance should appear on the right, click on its name to "open" its options so that we can execute its functions.

![My First Contract on Remix](/images/remix-first-contract.png)

You should note that the select account now has 99.99... Ether instead of the initial 100. This is because every transaction needs to pay a cost (usually defined by gas amount and price). Deploying a contract is a transaction, and as such it also has a cost attached to it. You can also see that deploying a contract created a transaction in the log.

You can now have fun and execute the contract's functions. See how every function call creates a transaction. In the transaction log you can also see the details of transaction (e.g., how gas it spent, its parameters).

Congratulations, you just finished your first contract and interaction with the blockchain.

## 2. Basic Concepts

### 2.1. Primitive Types

The primitive types available in Solidity are the following:
* __bool__ - 1 byte boolean.
* __int__ - 32 bytes integer that accepts positive and negative values.
  * __int8 / int16 / ... int256__ - you customize the integer storage size (in increments of 8 bits) up to 256 bits.
* __uint__ - 32 bytes integer that accepts only non-negative values (i.e., unsigned integer).
  * __uint8 / uint16 / ... uint256__ - similar to int, it is possible to customize its storage size (in increments of 8 bits) up to 256 bits.
* __byte__ - 1 byte.
  * __bytes1 / bytes2 / ... bytes32__ - syntactic suggar for a byte array (up to 32 bytes).
* __fixed__ - fixed point numbers (i.e., real numbers). The storage for the integer and fractional part is flexible, and we can specify its place. Fixed is actually an alias for fixed128x18 (see bellow).
  * __fixed0x8 / fixed0x16 / ... fixed0x256 / ... fixed8x8 ...__ - fixed point number where the first number specifies the number of bits used for the integer part (i.e., before the decimal separator), and the other number specifies the bits for the fractional part. The numbers used must be in increments of 8 (zero is allowed). Moreover, the total amount of bits from both parts must be lower or equal than 256 bits. 
  * __CAUTION:__ fixed numbers are not fully supported in this version of Solidity, avoid using them.
* __ufixed__ - unsigned fixed point number. Besides not allowing negative values, it has the same characteristics as fixed.
  * __ufixed0x8 / ufixed 0x16 / ... ufixed0x256 / ...ufixed8x8 ...__ - it is also possible to customize the storage of ufixed's integer and fractional parts. Same restrictions as fixed applies here as well.
  * __CAUTION:__ fixed numbers (even the unsigned version) are not fully supported in this version of Solidity, avoid using them.
* __string__ - dynamically-sized UTF-8 encoded string.
* __address__ - a 20 bytes type that represents an Ethereum address. _This is very important, because it is very common to handle address when coding a smart contract_. An address references either an account or a contract. Every address have the attribute "balance" which shows how many Ether (stored in Wei) that address have. Addresses also have special functions that will talk later. 

The reason for many types to have the option to customize its storage is "cost". Storage and execution in the Ethereum blockchain have transactional costs attached to them. Therefore, optimizing your contract to use less storage when possible will reduce its overall costs for you and its users.

### 2.2. Pre-defined Modifiers

Modifiers affect the behaviour of a resource (e.g., function, attribute). In a function, the modifier is placed after its parameters definition. For an attribute, the modifier is placed after its type. The pre-defined modifiers that we can use are the following:

* __Visibility modifiers__ - specifies who can access the resource. Each resource can only have one visibility modifier. Most of them can also be applied to contract's attributes as well. The term "visibility" is misleading because the resource (specially contract's attributes) is still visible, just not accessible.
    * __private__ - only the contract that defined a private resource can access it. __Extreme Caution:__ unlike other programming languages, a private attribute of a smart contract is still visible to anyone in the blockchain. Therefore, do not count on its invisibility to perform any action.
    * __internal__ - similar to "protected" in C++/Java, the resource is accessible to the current contract and the ones deriving from it. This is the default visibility if you did not defined one for an attribute.
    * __public__ - any contract or account can access this resource. If it is an attribute, other contracts can also modify its value. This is the default visibility for functions.
    * __external__ - only for functions, mostly used when we define an interface to another contract which we don't have the code. 
* __State Mutability modifiers__ - basically, if a function performs "read-only" tasks on the contract, or does not even use its internal attributes, we can specify it by using mutability modifiers. __This is very important__, since these functions do not modify anything on the blockchain, they will not create a transaction when called. Therefore, there will be no cost when calling such functions.
    * __view__ - if a function does not modify the internal contract state (i.e., its attributes), and only reads value from it, we can mark it as "view". As an analogy, you can think of "view" as "read-only" functions. Attributes can not be marked with it.
    * __pure__ - if a function does not modify or even read the internal state, it can be marked as "pure". Attributes cannot be "pure". For example see the function bellow:
    ```solidity
    function calc(uint a, uint b) public pure returns(uint){
        return (a+1)*(b+1);
    }
    ```
    * __constant__ - deprecated for functions but still used for attributes. A constant attribute cannot be modified and we must specify its value at declaration. For example:
    ```solidity
    function calc(uint a, uint b) public pure returns(uint){
        return (a+1)*(b+1);
    }
    ```    
* __payable__ - if the function is going to receive Ether, then it must be marked with the payable modifier. Otherwise an exception will be thrown. When a payable function receives Ether, it automatically adds the sent funds to its contract's.

In Solidity it is also possible for developers to create their own custom modifiers for functions (which I will show later). 

### 2.3. Functions

The "rules" enforced by a smart contract are defined by its functions. A function always starts with a "function" keyword followed by its name. Then we can define the parameters if any. After the parameters, we can specify modifiers to the function. Finaly, we can specify the returned type (or types) of the function.

Solidity supports function overloading (i.e., functions with the same name/id but with different parameters). Just be carefull that some types may resolve as the same paramter when compiled (e.g., a contract in a parameter will be turned into an address).

Another peculiarity of Solidity is that you can return more than one value in a function (I will create an example of that shortly). Unfortunately, not every type can be returned by a function (e.g., structs, dynamic arrays). For example, function f bellow returns three different types. 
```solidity
function f() public pure returns(uint,string,int){
    return (42,"Hello World",-1);
}
```

### 2.4. Back to the First Contract

Lets go back to our first contract. The warnings showed by Remix is related to missing modifiers, you can probably fix them by now. Now we change the contract a little to use more of the concepts I just presented.

```solidity
pragma solidity ^0.4.24;
/**
 * @title Simple Contract
 * @author Henrique
 */
contract SimpleContract {
    uint public data = 10;
    string private name;
    
    function setName(string _name) public{
        name = _name;
    }
    
    function getName() public view returns (string) {
        return name;
    }

    function get() public view returns (string,uint){
        return (name,data);
    }
}
```

Try out changing the visibility modifiers on the "data" attribute and deploying the contract again. The new functions I created was to show returning multiple parameters.

## 3. X

### 3.1. Constructor

Similar to object-oriented classes, we can define a constructor for a contract. However, unlike classes, a contract can only have 1 contructor. A contructor can have parameters but when we deploy the contract we must also provide all parameters defined on its construtor. The visibility must be either _public_ or _internal_ (it is not possible to create private or external constructors). Moreover, the only other possible modifier that a constructor can have is _payable_ if it receives Ether on its creation. 

```solidity
constructor(address a, address b) public {
    // Do something...
}
```


### 3.2. Pre-defined Variables

There are some pre-defined variables available to use in any contract. Usually, they provide information related to the blockchain platform. I am going to show a small list of the ones most used, for a complete list [see this](https://solidity.readthedocs.io/en/v0.4.24/units-and-global-variables.html#block-and-transaction-properties).
* __msg__ - references the current message call (i.e., function call).
    * __msg.sender__ - address, the account or contract that initiated the message call.
    * __msg.value__ - uint, the amount of Wei ( 10^-18 Ether ) sent in this message.
* __block__ - reference the current block.
    * __block.timestamp__ - uint, the timestamp in the current block.
* __now__ - uint, an alias for block.timestamp.

You should pay attention specially to __msg.sender__, as it is probably the most used pre-defined variable. For example, whoever called the constructor is the "person" creating the contract, and we can store that for security checks later.

```solidity
contract C {
    address private owner;
    
    constructor() public {
        owner = msg.sender;
    }
    // other functions and attributes
}
```

### 3.3. Exceptions

The way to handle errors in Solidity is by raising exceptions. An exception undo all changes made in the current execution (propagating to the other function calls). The exception code we can use in our functions are the following:
* __require( condition, message )__ - raises an exception if the condition is false and returns the message to the caller. This is the code that you should use for most situations. Even though the message is optional, it is good practice to always define it. Otherwise the caller may not know why the exception was raised.
* __revert( message )__ - raiseas an exception and returns the message to the caller. The message is optinal, but it is a good practice to use it. 
* __assert( condition )__ - raises an exception if the condition is false. It may look like require but assert should be used for internal checks.
* __throw__ - deprecated in the current version of Solidity, avoid using it. Throw raises an exception.


### 3.4. Custom Modifiers

In Solidity, we can create custom function modifiers. The ideia is to ammend the semantics of function with reusable code. Mostly used for checking condition and raising exceptions. 

We use the "modifier" keyword to create one. A modifier can have parameters. The placeholder statement ("\_;") indicates where the actual function code will be placed. This allows modifiers to ammend code before or after (or both) of the normal function code.

```solidity
modifier checkBalance(uint amount){
    require( address(this).balance >= amount, "Insuficient funds for this operation");
    _; // <-- Here is where the normal function code will be placed
}

function foo(uint amount) public payable checkBalance(amount) {
    // Do something... 
}
```

### 3.5. Restrict Access Contract

Now that we know about constructors, pre-defined variables, and modifiers, I can show an example for a restrict access contract. In this case, we want to restrict the access of certain functions that only the creator (owner) can invoke them. If anyone else calls such functions then an exception should be raised. 

```solidity
pragma solidity^0.4.24;
/**
 * @title Restricted Access Example
 * @author Henrique
 */ 
contract Restricted {
   address private owner;
   uint private data;
   
   constructor() public{
       owner = msg.sender;
   }

   modifier onlyOwner(){
       require(owner == msg.sender, "Only owner can call this function");
       _;
   }
   
   function setData(uint d) public onlyOwner{
       data = d;
   }
   
   function getData() public view returns (uint) {
       return data;
   }
} //end of contract
```

You can deploy the contract using one account and use the "setData" function to modify the dta. After that, change the selected account on the "account combobox" and try calling the function again. You should see an exception in the transactions log and also the message we placed on the require.

## 4. Dealing with Money (Ether)

One of the major advantages of Smart Contracts is dealing with crypto-currency (in Ethereum always measured in Wei).

### 4.1. Special Code for Money

There are some special syntax and pre-defined functions to handle Ether. Lets revise some of terms and present new ones:

* __payable__ - if the function is going to receive Ether, then it must be marked with the payable modifier. Otherwise an exception will be thrown. When a payable function receives Ether, it automatically adds the sent funds to its contract's. __Please note__ that payable is only required for a function to __receive__ ether. If a function __sends__ it does not need the payable modifier.
* __address__ - the primitive type address references an account or a contract. We need to typecast a contract to address to use its attributes and functions. 
    * __\<address>.balance__ - the balance shows how many Ether (measured in Wei) that address have. Useful to check if the address have suficients funds for an operation.
    * __\<address>.transfer(uint amount )__ - sends money from the current contract to the address. Raises an exception if failed.
    * __\<address>.send( uint amount )__ - sends money from the current contract to the address. Returns false if failed. 
* __msg__ - references the current message call (i.e., function call).
    * __msg.value__ - uint, the amount of Wei ( 10^-18 Ether ) sent in this message. We need to use this if we want to know how much money was sent.

### 4.2. Wallet Contract version 1

As an example lets code a Wallet. Only the owner should be able to pay to another address with funds from his wallet. Anyone can deposit money into the wallet (someone could be paying the owner by doing so). We also need to create a withdraw feature where the owner could transfer funds from his wallet to his account. In the example bellow I coded only the function signatures (except for getBalance), as an exercise you should try to complete the code inside each block (i.e., constructor, modifiers, and functions). You don't need to change the function signatures, just code what should be place inside.

```solidity
pragma solidity^0.4.24;
/**
 * @title Wallet Contract Example v1
 * @author Henrique
 **/
contract MyWallet{
    address private owner;
    uint8 constant private version = 1; //just to keep track of the versions 
    
    constructor() public {}
    modifier onlyOwner(){}
    modifier checkBalance(uint amount){}
    
    function getBalance() public view returns(uint){
        return address(this).balance;
    }

    function pay(address receiver, uint amount) public onlyOwner checkBalance(amount) {}
    
    function deposit() public payable{}
    
    function withdraw(uint amount) public onlyOwner checkBalance(amount) {}
} //end of contract
```

After you are done, you should deploy the contract and try to send money to it. Please remember to adjust the "value" in the Run tab before trying to execute the deposit function. You can also send money to other accounts using the pay function on your wallet. For now it is not possible for one Wallet instance to interact with another (using pay to another Wallet will raise an exception). We will handle this limitation shortly.

You can check the complete code from the above example [here](contracts/wallet1.sol). 


