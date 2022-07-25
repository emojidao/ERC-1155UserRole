// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/IERC1155.sol";

interface IERC1155WithUserRole is IERC1155 {
    struct Record {
        uint256 tokenId;
        uint256 amount;
        address owner;
        address user;
        uint64 expiry;
    }

    event UpdateRecord(
        uint256 recordId,
        uint256 tokenId,
        uint256 amount,
        address owner,
        address user,
        uint64 expiry
    );

    /**
     * @dev Returns the amount of tokens of token type `id` used by `user`.
     *
     * Requirements:
     *
     * - `user` cannot be the zero address.
     */
    function balanceOfUsable(address user, uint256 id)
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
    function frozenOf(address owner, uint256 id)
        external
        view
        returns (uint256);

    function recordOf(uint256 recordId) external view returns (Record memory);

    /// @notice set the user of NFTs
    /// @dev The zero address indicates there is no user
    /// Throws if `tokenId` is not valid NFT
    /// @param user  The new user of the NFT
    /// @param amount  The new user could use
    /// @param expiry  UNIX timestamp, The new user could use the NFT before expires
    function setUsable(
        address owner,
        address user,
        uint256 id,
        uint256 amount,
        uint64 expiry
    ) external;
    
    function increaseUsable(uint256 recordId, uint256 amount,uint64 expiry) external;

    function decreaseUsable(uint256 recordId, uint256 amount,uint64 expiry) external;

    function transferUsable(
        uint256 recordId,
        uint256 amount,
        address to
    ) external;
}
