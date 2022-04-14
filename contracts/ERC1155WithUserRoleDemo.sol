// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./ERC1155WithUserRole.sol";

contract ERC1155WithUserRoleDemo is ERC1155WithUserRole {
    function mint(
        address to,
        uint256 id,
        uint256 amount
    ) public {
        _mint(to, id, amount, "");
    }

    function burn(
        address from,
        uint256 id,
        uint256 amount
    ) public {
        _burn(from, id, amount);
    }
    
}
