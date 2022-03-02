pragma solidity ^0.8.4;

library SafeMath {
  /**
   * SafeMath mul function
   * @dev function for safe multiply
   **/
  function mul(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a * b;
    assert(a == 0 || c / a == b);
    return c;
  }
  
  /**
   * SafeMath div funciotn
   * @dev function for safe devide
   **/
  function div(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a / b;
    return c;
  }
  
  /**
   * SafeMath sub function
   * @dev function for safe subtraction
   **/
  function sub(uint256 a, uint256 b) internal pure returns (uint256) {
    assert(b <= a);
    return a - b;
  }
  
  /**
   * SafeMath add fuction 
   * @dev function for safe addition
   **/
  function add(uint256 a, uint256 b) internal pure returns (uint256) {
    uint256 c = a + b;
    assert(c >= a);
    return c;
  }
}

contract ERC20Basic {

  uint256 public totalSupply;

  function balanceOf(address _addr) public constant returns (uint256);

  function transfer(address _to, uint256 _value) public returns (bool);

  event Transfer(address indexed _from, address indexed _to, uint256 value);

}

contract BasicToken is ERC20Basic {

  using SafeMath for uint256;

  mapping(address => uint256) balances;

  function transfer(address _to, uint256 _value) public returns (bool) {
    require(balances[msg.sender] > _value, "Not enought amount to transfer");
    balances[msg.sender] = balances[msg.sender].sub(_value);
    balances[_to] = balances[_to].add(_value);
    emit Transfer(msg.sender, _to, _value);
    return true;
  }

  function balanceOf(address _addr) public constant returns (uint256 balance) {
    return balances[_addr];
  }

}

contract ERC20 is ERC20Basic {
  function allowance(address owner, address spender) public constant returns (uint256);
  function transferFrom(address from, address to, uint256 value) public constant returns (bool);
  function approve(address owner, uint256 value) public constant returns (bool);
  event Approval(address indexed owner, address indexed spender, uint256 _value);
}

contract Token is ERC20, BasicToken {
  mapping(address => mapping(address => uint256)) allowed;

  function transferFrom(address _from, address _to, uint256 _value) public returns (bool) {
    require(balanceOf(_from) > _value);
    require(allowed[_from][msg.sender] > _value);

    uint256 _allowance = allowed[_from][msg.sender];

    balances[_to] = balances[_to].add(_value);
    balances[_from] = balances[_from].sub(_value);

    allowed[from][msg.sender] = _allowance.sub(_value);
    emit Transfer(_from, _to, _value);

    return true;
  }

  function approve(address _spender, uint256 _value) public returns (bool) {
    require(_value > 0);
    allowed[msg.sender][_spender] = _value;
    emit Approval(msg.sender, _spender, _value);
    return true;
  }

  function allowance(address _owner, address _spender) public view returns (uint256 remaining) {
    return allowed[_owner][_spender];
  }

}

contract NBToken is Token {
  string public constant NAME = "1Nance Exchange";
  string public constant SYMBOL = "NB";
  uint256 public constant DECIMALS = 18;

  uint256 public constant INITIAL_SUPPLY = 500000000 * 10**18;

  /**
   * Kimera Token Constructor
   * @dev Create and issue tokens to msg.sender.
   */
  constructor NBToken() {
    totalSupply = INITIAL_SUPPLY;
    balances[msg.sender] = INITIAL_SUPPLY;
  }
}