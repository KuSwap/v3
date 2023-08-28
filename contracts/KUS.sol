// SPDX-License-Identifier: GPL-3.0-or-later
pragma solidity 0.8.13;

interface IKus {
    function totalSupply() external view returns (uint);
    function balanceOf(address) external view returns (uint);
    function approve(address spender, uint value) external returns (bool);
    function transfer(address, uint) external returns (bool);
    function transferFrom(address,address,uint) external returns (bool);
    function mint(address, uint) external returns (bool);
    function minter() external returns (address);
}

contract Kus is IKus {

    string public constant name = "KuSwapV3 Token";
    string public constant symbol = "KUSv3";
    uint8 public constant decimals = 18;
    uint public totalSupply = 0;

    mapping(address => uint) public balanceOf;
    mapping(address => mapping(address => uint)) public allowance;

    address public minter;
    address public msTimelock;
    uint public maxSupply = 47000000 ether;

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);

    constructor(address initialSupplyRecipient, uint initialAmount) {
        require(initialAmount <= maxSupply, "Exceeds max supply");
        minter = msg.sender;
        msTimelock = msg.sender; // changed to timelock
        _mint(initialSupplyRecipient, initialAmount);
    }

    // No checks as its meant to be once off to set minting rights to KCC Minter
    function setMinter(address _minter) external {
        require(msg.sender == minter, "Only minter");
        minter = _minter;
    }

    function approve(address _spender, uint _value) external returns (bool) {
        allowance[msg.sender][_spender] = _value;
        emit Approval(msg.sender, _spender, _value);
        return true;
    }

    function _mint(address _to, uint _amount) internal returns (bool) {
        require(totalSupply + _amount <= maxSupply, "Exceeds max supply");
        totalSupply += _amount;
        unchecked {
            balanceOf[_to] += _amount;
        }
        emit Transfer(address(0x0), _to, _amount);
        return true;
    }

    function _transfer(address _from, address _to, uint _value) internal returns (bool) {
        balanceOf[_from] -= _value;
        unchecked {
            balanceOf[_to] += _value;
        }
        emit Transfer(_from, _to, _value);
        return true;
    }

    function transfer(address _to, uint _value) external returns (bool) {
        return _transfer(msg.sender, _to, _value);
    }

    function transferFrom(address _from, address _to, uint _value) external returns (bool) {
        uint allowed_from = allowance[_from][msg.sender];
        if (allowed_from != type(uint).max) {
            allowance[_from][msg.sender] -= _value;
        }
        return _transfer(_from, _to, _value);
    }

    function mint(address account, uint amount) external returns (bool) {
        require(msg.sender == minter, "Only minter");
        _mint(account, amount);
        return true;
    }
    
    function setMaxSupply(uint _maxSupply) external {
        require(msg.sender == msTimelock, "Only msTimelock");
        require(_maxSupply >= totalSupply, "New maxSupply must be >= totalSupply");
        maxSupply = _maxSupply;
    }

    function setMSTimelock(address _msTimelock) external {
        require(msg.sender == msTimelock, "Only msTimelock");
        msTimelock = _msTimelock;
    }
}
