pragma solidity 0.5.8;

//import './Queue.sol';
import './Token.sol';

/**
 * @title Crowdsale
 * @dev Contract that deploys `Token.sol`
 * Is timelocked, manages buyer queue, updates balances on `Token.sol`
 */

/* To do: Use SafeMath
		: Use Queue.sol
		: Add Mint Tokens functionality
*/

contract Crowdsale {

    address payable public owner; //owner of contract
    address payable private _wallet; //wallet address to transfer ICO funds

    Token public myToken;

    
    uint256 public numTokensSold;
    uint256 public startTime;
    uint256 public endTime;
    uint256 public tokenRate; //the amount of tokens 1 wei is worth

    // How many token units a buyer gets per wei.
    // The rate is the conversion between wei and the smallest and indivisible token unit.
    // So, if you are using a rate of 1 with a ERC20Detailed token with 3 decimals called TOK
    // 1 wei will give you 1 unit, or 0.001 TOK.



  constructor(address payable wallet, uint256 _tokenRate) public  {
        owner = msg.sender;
        uint256 initialNumTokens = 10000;
        string memory tokenName = "MYTHTOKEN";
        string memory symbol ="MYTH";
        uint8 decimals = 18;

        myToken = new Token(tokenName,symbol,decimals,initialNumTokens);

        startTime = now;
        endTime = now + 40 minutes;

        tokenRate = _tokenRate;
        _wallet = wallet;


    }


    modifier onlyOwner {
        require(msg.sender == owner,"Only owner can call this function.");
        _;
    }

    modifier onlyWhileOpen{
    	require(isICOOpen(), "ICO is not open");
    	_;
    }

    function isICOOpen() public view returns (bool) {
        return (now >= startTime && now <= endTime);
    }

    function isICOOver() public view returns (bool){
    	return (now >endTime);
    }

   
   function buyTokens() public payable onlyWhileOpen returns (bool){
    	require(msg.value>=1, 'Amount should be atleast 1 wei');

    	uint256 weiAmount = msg.value;
    	uint256 numTokensToBuy = weiAmount * tokenRate; 

    	myToken.transfer(msg.sender,numTokensToBuy);

    	numTokensSold +=numTokensToBuy;
    	//emit event
    	return true;

    }


    function refund() public onlyWhileOpen returns (bool){

    	require (myToken.balanceOf(msg.sender)>0, "Zero Token balance");

    	uint256 numTokens = myToken.balanceOf(msg.sender);

    	uint256 weiAmountToReturn = numTokens / tokenRate;
    	msg.sender.transfer(weiAmountToReturn); //Return wei

    	myToken.refundToken(msg.sender); // set to zero the token balances of the refund address

    	 numTokensSold -=numTokens; //update

    	 //emit event
    	return true;

    }


	function withdrawEthers() public onlyOwner{
		require(isICOOver(), "ICO not finished yet");
		_wallet.transfer(address(this).balance);

	}


}