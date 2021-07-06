// SPDX-License-Identifier: MIT
pragma solidity 0.8.4;

import '@openzeppelin/contracts/access/AccessControlEnumerable.sol';
import '@openzeppelin/contracts/token/ERC20/extensions/ERC20Pausable.sol';

contract BRZ is Context, AccessControlEnumerable, ERC20Pausable  {

    bytes32 public constant ADMIN_ROLE = keccak256("ADMIN_ROLE");

    constructor() ERC20("BRZ", "BRZ") {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());
        _setupRole(ADMIN_ROLE, _msgSender());
    }

    function decimals() public pure override returns (uint8) {
        return 4;
    }

    function mint(address to, uint256 amount) public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Token: must have admin role to mint");
        _mint(to, amount);
    }    

    function burn(uint256 amount) public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Token: must have admin role to burn");
        _burn(_msgSender(), amount);
    }

    function burnFrom(address account, uint256 amount) public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Token: must have admin role to burnFrom");
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "ERC20: burn amount exceeds allowance");
        _approve(account, _msgSender(), currentAllowance - amount);
        _burn(account, amount);
    }    

    function pause() public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Token: must have admin role to pause");
        _pause();
    }

    function unpause() public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Token: must have admin role to unpause");
        _unpause();
    }
    
    /**
    * @dev Manage tokens sent to this contract
    */
    function tokenBalanceOf(address addressToken) public view returns (string memory, uint256) {        
        IERC20Metadata token = IERC20Metadata(addressToken);
        return (token.symbol(), token.balanceOf(address(this)));
    }
    
    function tokenWithdraw(address addressToken) public {
        require(hasRole(ADMIN_ROLE, _msgSender()), "Token: must have admin role to tokenWithdraw");
        IERC20 token = IERC20(addressToken);
        uint256 balance = token.balanceOf(address(this));
        token.transfer(msg.sender, balance);
    }
    
}