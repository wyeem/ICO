pragma solidity 0.5.8;

import './interfaces/ERC20Interface.sol';

/**
 * @title Token
 * @dev Contract that implements ERC20 token standard
 * Is deployed by `Crowdsale.sol`, keeps track of balances, etc.
 */

 // To do: Use SafeMath



contract Token is ERC20Interface {

	 string public  name; //Token name for display purposes
	 string public symbol; //Token symbol for display purposes
	 uint8 public decimals; //Number of decimals to show for display purposes

    //Token balance of each account
    mapping(address => uint256)  tokenBalances;

    //All the accounts approved to withdraw from a given account together with the withdrawal sum allowed for each
    mapping (address => mapping (address => uint256)) public allowed;

    //event
    event Burn(address indexed _owner,uint256 _numTokens);
    
    // constructor
    constructor(string memory  _name, string memory _symbol, uint8 _decimals, uint256 _initialNumTokens) public  {
       name = _name;
       symbol = _symbol;
       decimals = _decimals;
       totalSupply = _initialNumTokens * 10**uint256(decimals);//totalSupply is total number of tokens (in smallest unit)

       tokenBalances[msg.sender] = totalSupply; //Assign all tokens initially to account creator

    }


        function balanceOf(address _owner) public view returns (uint256 balance){
        	return tokenBalances[_owner];
        }

        //Transfer of tokens to an address
        function transfer(address _to, uint256 _numTokens) public returns (bool success){

        	require(tokenBalances[msg.sender] >= _numTokens);
        	
        	tokenBalances[msg.sender] = tokenBalances[msg.sender] - _numTokens;
        	tokenBalances[_to] = tokenBalances[_to] + _numTokens;

        	emit Transfer(msg.sender,_to,_numTokens);
        	return true;


        }

        //number of tokens that _spender is allowed to spend by _owner
        function allowance(address _owner, address _spender) public view returns (uint256 remaining){
 				return allowed[_owner][_spender];

        }

        //Approve _spender to spend the _numTokens on behalf of msg.sender
        function approve(address _spender, uint256 _numTokens) public returns (bool success){
               // require(tokenBalances[msg.sender] >= _numTokens); not needed here https://ethereum.stackexchange.com/questions/45873/checking-balance-of-msg-sender-before-approve
                allowed[msg.sender][_spender] = _numTokens;
                emit Approval(msg.sender, _spender, _numTokens);

                return true;
         }

         //allows a delegate approved for withdrawal (msg.sender) to transfer owner (_from) funds to a third-party account (_to).
        function transferFrom(address _from, address _to, uint256 _numTokens) public returns (bool success){
        	      require(tokenBalances[_from] >= _numTokens && allowed[_from][msg.sender] >= _numTokens);
        	      tokenBalances[_to] += _numTokens;
        	       tokenBalances[_from] -= _numTokens;


        	       emit Transfer(_from,_to,_numTokens);
        	       return true;


        }

        //Set token balance of _owner to zero
      	function refundToken(address _owner) public{
      			totalSupply = totalSupply - tokenBalances[_owner];
      			tokenBalances[_owner]=0;


      	}

        function burnToken(address _owner, uint256 _numTokens) public returns (bool success){
        		   require(tokenBalances[_owner] >= _numTokens);

        		   tokenBalances[_owner] = tokenBalances[_owner] - _numTokens;
        		   totalSupply = totalSupply - _numTokens;

        		   emit Burn(_owner,_numTokens);

        		   return true;


        }


}