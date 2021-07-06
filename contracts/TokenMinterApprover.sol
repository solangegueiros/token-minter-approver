// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/AccessControl.sol';

interface IERC20Minter {
    function name() external view returns (string memory);
    function symbol() external view returns (string memory);
    function decimals() external view returns (uint8);
    function totalSupply() external view returns (uint256);
    function balanceOf(address account) external view returns (uint256);
    function transfer(address recipient, uint256 amount) external returns (bool);
    function allowance(address owner, address spender) external view returns (uint256);
    function approve(address spender, uint256 amount) external returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);
    function mint(address account, uint256 amount) external;
    event Transfer(address indexed from, address indexed to, uint256 value);
    event Approval(address indexed owner, address indexed spender, uint256 value);
}


contract TokenMinterApprover is AccessControl {
    
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant APPROVER_ROLE = keccak256("APPROVER_ROLE");
    IERC20Minter public token;
    
    struct ApproveStruct {
        address minter;
        address approver;
        uint256 amount;
    }
    mapping (address => ApproveStruct) public mintAllowances;

    constructor(address tokenAddress) {
        token = IERC20Minter(tokenAddress);
        _setupRole(DEFAULT_ADMIN_ROLE, msg.sender);
    }
    
    modifier onlyMinter() {
        require(hasRole(MINTER_ROLE, msg.sender), "TokenMinter: only minter");
      _;
    }    
    
    modifier onlyApprover() {
        require(hasRole(APPROVER_ROLE, msg.sender), "TokenMinter: only approver");
      _;
    }

    function requestMint(address account, uint256 amount) public onlyMinter returns (bool) {
        if (mintAllowances[account].amount > 0) {
            require (mintAllowances[account].amount == amount, "TokenMinter: different amount");
        }
        else {
            mintAllowances[account].amount = amount;
        }
        mintAllowances[account].minter = msg.sender;
        if (mintAllowances[account].approver != address(0x0)) {
            mint(account, amount);
        }
        return true;
    }
    
    function approveMint(address account, uint256 amount) public onlyApprover returns (bool) {
        if (mintAllowances[account].amount > 0) {
            require (mintAllowances[account].amount == amount, "TokenMinter: different amount");
        }
        else {
            mintAllowances[account].amount = amount;
        }
        mintAllowances[account].approver = msg.sender;
        if (mintAllowances[account].minter != address(0x0)) {
            mint(account, amount);
        }
        return true;
    }
    
    function mint(address account, uint256 amount) public returns (bool) {
        token.mint(account, amount);
        delete mintAllowances[account];
        return true;
    }
}