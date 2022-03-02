pragma solidity ^0.8.4;

library SafeMath {

	function add(uint256 a, uint256 b) internal pure returns (uint256) {
		uint256 c = a + b;
		require(c >= a, "SafeMath: addition overflow");

		return c;
	}

	function sub(uint256 a, uint256 b) internal pure returns (uint256) {
		return sub(a, b, "SafeMath: subtraction overflow");
	}

	function sub(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b <= a, errorMessage);
		uint256 c = a - b;

		return c;
	}

	function mul(uint256 a, uint256 b) internal pure returns (uint256) {

		if (a == 0) {
			return 0;
		}

		uint256 c = a * b;
		require(c / a == b, "SafeMath: multiplication overflow");

		return c;
	}

	function div(uint256 a, uint256 b) internal pure returns (uint256) {
		return div(a, b, "SafeMath: division by zero");
	}

	function div(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b > 0, errorMessage);
		uint256 c = a / b;
		// assert(a == b * c + a % b); // There is no case in which this doesn't hold

		return c;
	}

	function mod(uint256 a, uint256 b) internal pure returns (uint256) {
		return mod(a, b, "SafeMath: modulo by zero");
	}

	function mod(uint256 a, uint256 b, string memory errorMessage) internal pure returns (uint256) {
		require(b != 0, errorMessage);
		return a % b;
	}

	function sqrrt(uint256 a) internal pure returns (uint c) {
		if (a > 3) {
			c = a;
			uint b = add( div( a, 2), 1 );
			while (b < c) {
				c = b;
				b = div( add( div( a, b ), b), 2 );
			}
		} else if (a != 0) {
			c = 1;
		}
	}

	function percentageAmount( uint256 total_, uint8 percentage_ ) internal pure returns ( uint256 percentAmount_ ) {
		return div( mul( total_, percentage_ ), 1000 );
	}

	function substractPercentage( uint256 total_, uint8 percentageToSub_ ) internal pure returns ( uint256 result_ ) {
		return sub( total_, div( mul( total_, percentageToSub_ ), 1000 ) );
	}

	function percentageOfTotal( uint256 part_, uint256 total_ ) internal pure returns ( uint256 percent_ ) {
		return div( mul(part_, 100) , total_ );
	}

	function average(uint256 a, uint256 b) internal pure returns (uint256) {
		// (a + b) / 2 can overflow, so we distribute
		return (a / 2) + (b / 2) + ((a % 2 + b % 2) / 2);
	}

	function quadraticPricing( uint256 payment_, uint256 multiplier_ ) internal pure returns (uint256) {
		return sqrrt( mul( multiplier_, payment_ ) );
	}

	function bondingCurve( uint256 supply_, uint256 multiplier_ ) internal pure returns (uint256) {
		return mul( multiplier_, supply_ );
	}
}

interface Token {
	function transfer(address _to, uint256 _value) external returns (bool);
	function balanceOf(address_ owner) external constant returns (uint256 balance);
}

contract NBICO is Ownable {
	using SafeMath for uint256;
	Token token;

	uint256 public decimals = 18;

	uint256 public constant initial_token_count = 1000_000 * 10**18;

	uint256 public constant Rate_1 = 2700;
	uint256 public constant Rate_1 = 2500;
	uint256 public constant Rate_1 = 2300;

	uint256 public constant START_1 = 1656604800; //2022-07-01-00:00:00 GMT+8 time
	uint256 public constant START_2 = 1657209600; //2022-07-08-00:00:00 GMT+8 time
	uint256 public constant START_3 = 1657814400; //2022-07-15-00:00:00 GMT+8 time
	uint256 public constant START_4 = 1658419200; //2022-07-22-00:00:00 GMT+8 time
	bool public initialized = false;

	event BoughtTokens(address indexed to, uint256 value);

	uint256 public raisedAmount = 0;

	modifier whenSaleIsActive() {
		assert(isActive());
		_;
	}

	constructor NBICO(address _tokenAddr){
		require(_tokenAddr != 0);
		token = Token(_tokenAddr);
	}

	function initialize() public onlyOwner {
		require(initialized == false); // Can only be initialized once
		require(tokensAvailable() == initialTokens); // Must have enough tokens allocated
		initialized = true;
	}

	function isActive() public view returns (bool) {
		return (
			initialized == true &&
			now >= START && // Must be after the START date
			now <= START.add(DAYS * 1 days) && // Must be before the end date
			goalReached() == false // Goal must not already be reached
		);
	}

	function goalReached() public view returns (bool) {
		return (raisedAmount >= CAP * 1 ether);
	}

	/**
	 * @dev Fallback function if ether is sent to address insted of buyTokens function
	 **/
	function () public payable {
		buyTokens();
	}

	/**
	 * buyTokens
	 * @dev function that sells available tokens
	 **/
	function buyTokens() public payable whenSaleIsActive {
		uint256 weiAmount = msg.value; // Calculate tokens to sell
		uint256 tokens = weiAmount.mul(RATE);
		
		emit BoughtTokens(msg.sender, tokens); // log event onto the blockchain
		raisedAmount = raisedAmount.add(msg.value); // Increment raised amount
		token.transfer(msg.sender, tokens); // Send tokens to buyer
		
		owner.transfer(msg.value);// Send money to owner
	}

	/**
	 * tokensAvailable
	 * @dev returns the number of tokens allocated to this contract
	 **/
	function tokensAvailable() public constant returns (uint256) {
		return token.balanceOf(this);
	}

	/**
	 * destroy
	 * @notice Terminate contract and refund to owner
	 **/
	function destroy() onlyOwner public {
		// Transfer tokens back to owner
		uint256 balance = token.balanceOf(this);
		assert(balance > 0);
		token.transfer(owner, balance);
		// There should be no ether in the contract but just in case
		selfdestruct(owner);
	}

}