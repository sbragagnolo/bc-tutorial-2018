    pragma solidity ^0.5.1;
    
    contract Sell {
    	enum State { ON_SALE, WAITING_SEND, SENT, FINISH } 
    	
    	address _owner;
    	address buyer;
    	uint payed;
    	uint price;
    	string itemName;
    	
    	State state; 
    	constructor (uint toPay, string memory name) public {
    		_owner = msg.sender; 
                    itemName = name;
       	        price = toPay;
    	}
        function prepare() public {
    	    state = State.ON_SALE;
        }
        function buy() payable public {
    		if (state != State.ON_SALE) { return ; }
    		if( price != msg.value ) revert(); 
    		state = State.WAITING_SEND;
    		payed = msg.value;
    		buyer = msg.sender;
        }
        function informItemReceived  () public {
    		if ( buyer == msg.sender && state == State.WAITING_SEND ) {
    			state = State.SENT;
    		}
        }
        function withdrawMoneyTo  (address payable toAddress) public{
    		if ( _owner == msg.sender && state == State.SENT) {
    			toAddress.transfer(price);
    			state = State.FINISH;
    		}
        }
    }
