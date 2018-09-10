## Exercises: Hands-on Beginner to Solidity

In this section, I will present some hands-on coding exercises for coding smart contracts in Solidity. I will also explain some of the basic concepts of the Solidity language before each exercise.

Consult the [Solidity Documentation](https://solidity.readthedocs.io/en/latest/) for a more in dept language description.

### 1. Starting out

#### 1.1. What is Solidity

Solidity is high-level language to code smart contracts in the Ehtereum platform. Solidity is a statically typed language inspired by C++, Javascript, and Python. It supports multiple inheritance, user defined types (e.g., structs, enums), and it even has some "syntactic suggar" for other features.

#### 1.2. Remix

[Remix](https://remix.ethereum.org/) is an IDE for Solidity. It can run directly on your web-browser without the need to download or install anything. Remix uses the latest Javascript compiler for Solidity.

All the exercises in this section use Remix. Therefore, you should open and get acquainted with it. 

#### 1.3. Primitive Types

* __bool__ - 1 byte boolean.
* __int__ - 32 bytes integer that accepts positive and negative values.
  * __int8 / int16 / ... int256__ - you customize the integer storage size (in increments of 8 bits) up to 256 bits.
* __uint__ - 32 bytes integer that accepts only non-negative values (i.e., unsigned integer).
  * __uint8 / uint16 / ... uint256__ - similar to int, it is possible to customize its storage size (in increments of 8 bits) up to 256 bits.
* __byte__ - 1 byte.
  * __bytes1 / bytes2 / ... bytes32__ - syntactic suggar for a byte array (up to 32 bytes).
* __fixed__ - fixed point numbers (i.e., real numbers). The storage for the integer and fractional part is flexible, and we can specify its place. Fixed is actually an alias for fixed128x18 (see bellow).
  * __fixed0x8 / fixed0x16 / ... fixed0x256 / ... fixed8x8 ...___ - fixed point number where the first number specifies the number of bits used for the integer part (i.e., before the decimal separator), and the other number specifies the bits for the fractional part. The numbers used must be in increments of 8 (zero is allowed). Moreover, the total amount of bits from both parts must be lower or equal than 256 bits. 
  * __CAUTION:__ fixed numbers are not fully supported in this version of Solidity, avoid using them.
* __ufixed__ - unsigned fixed point number. Besides not allowing negative values, it has the same characteristics as fixed.
  * __ufixed0x8 / ufixed 0x16 / ... ufixed0x256 / ...ufixed8x8 ...___ - it is also possible to customize the storage of ufixed's integer and fractional parts. Same restrictions as fixed applies here as well.
  * __CAUTION:___ fixed numbers (even the unsigned version) are not fully supported in this version of Solidity, avoid using them.
* __string__ - dynamically-sized UTF-8 encoded string.
* __address__ - a 20 bytes type that represents an Ethereum address. _This is very important, because it is very common to handle address when coding a smart contract_. An address references either an account or a contract. Every address have the attribute "balance" which shows how many Ether (stored in Wei) that address have. Addresses also have special functions that will talk later. 

The reason for many types to have the option to customize its storage is "cost". Storage and execution in the Ethereum blockchain have transactional costs attached to them. Therefore, optimizing your contract to use less storage when possible will reduce its overall costs for you and its users.



