// SPDX-License-Identifier: MIT
pragma solidity 0.8.7;

interface IERC20 {
	function totalSupply() external view returns (uint);
	function balanceOf(address account) external view returns (uint);
	function transfer(address recipient, uint amount) external returns (bool);
	function allowance(address owner, address spender)
		external
		view
		returns (uint);
	function approve(address spender, uint amount) external returns (bool);
	function transferFrom(
		address spender, 
		address recipient, 
		uint amount
	) external returns (bool);
	
	event Transfer(address indexed from, address indexed to, uint amount);
	event Approval(address indexed owner, address indexed spender, uint amount);
}

contract ERC20 is IERC20 {
	uint private _totalSupply = 100000000000000000;
	mapping(address => uint) private _balances;
	mapping(address => mapping(address => uint)) private _allowances;
	
    
    string public name;
	string public symbol;
	uint8 public decimals = 18;

    constructor(string memory _name, string memory _symbol) {
        name = _name;
        symbol = _symbol;
    }

    function totalSupply() public view virtual override returns (uint256) {
        return _totalSupply;
    }

    function balanceOf(address account) public view virtual override returns (uint256) {
        return _balances[account];
    }

    function allowance(address owner, address spender) public view virtual override returns (uint256) {
        return _allowances[owner][spender];
    }
	
	function transfer(address recipient, uint amount) external override returns (bool) {
        _balances[msg.sender] -= amount;
        _balances[recipient] -= amount;
        emit Transfer(msg.sender, recipient, amount);
        return true;
    }

	function approve(address spender, uint amount) external override returns (bool) {
		_allowances[msg.sender][spender] = amount;
		emit Approval(msg.sender, spender, amount);
		return true;
}
	function transferFrom(address spender, address recipient, uint amount) external override returns (bool) {
		_allowances[spender][msg.sender] -= amount;
		_balances[spender] -= amount;
		_balances[recipient] += amount;
		emit Transfer(spender, recipient, amount);
		return true;
	}
	
	function mint(uint amount) external {
		_balances[msg.sender] += amount;
		_totalSupply += amount;
		emit Transfer(address(0), msg.sender, amount);
	}
	
	function burn(uint amount) external {
		_balances[msg.sender] -= amount;
		_totalSupply -= amount;
		emit Transfer(msg.sender, address(0), amount);
	}
} 
