// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IERC1155WithUserRole is IERC1155 {
    event UpdateUser(
        address indexed operator,
        address indexed from,
        address indexed to,
        uint256 id,
        uint256 value
    );

    /**
     * @dev Returns the amount of tokens of token type `id` used by `user`.
     *
     * Requirements:
     *
     * - `user` cannot be the zero address.
     */
    function balanceOfUser(address user, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @dev Returns the amount of frozen tokens of token type `id` by `owner`.
     *
     * Requirements:
     *
     * - `owner` cannot be the zero address.
     */
    function frozenOfOwner(address owner, uint256 id)
        external
        view
        returns (uint256);

    /**
     * @dev Returns the amount of tokens of token type `id` used by `user`.
     *
     * Requirements:
     *
     * - `user` cannot be the zero address.
     * - `owner` cannot be the zero address.
     */
    function balanceOfUserFromOwner(
        address user,
        address owner,
        uint256 id
    ) external view returns (uint256);

    /// @notice set the user of a NFT
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param amount  The new user could use
    function setUser(
        address owner,
        address user,
        uint256 id,
        uint256 amount
    ) external;
}
