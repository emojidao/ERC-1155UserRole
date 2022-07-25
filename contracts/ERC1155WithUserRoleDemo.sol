// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "./ERC1155WithUserRole.sol";

contract ERC1155WithUserRoleDemo is ERC1155WithUserRole {
    constructor(string memory uri_, uint8 recordLimit_)
        ERC1155WithUserRole(uri_, recordLimit_)
    {}

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
