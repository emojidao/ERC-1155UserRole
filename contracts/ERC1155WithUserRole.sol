// SPDX-License-Identifier: CC0-1.0

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/token/ERC1155/utils/ERC1155Receiver.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
import "./IERC1155WithUserRole.sol";

contract ERC1155WithUserRole is ERC1155, ERC1155Receiver, IERC1155WithUserRole {
    using EnumerableSet for EnumerableSet.UintSet;

    mapping(uint256 => mapping(address => uint256)) private _frozens;

    mapping(uint256 => Record) private _records;

    mapping(uint256 => mapping(address => EnumerableSet.UintSet))
        private _userRecordIds;

    uint256 _curRecordId;
    uint8 recordLimit = 10;

    constructor(string memory uri_, uint8 recordLimit_) ERC1155(uri_) {
        recordLimit = recordLimit_;
    }

    function isOwnerOrApproved(address owner, address operator)
        public
        view
        returns (bool)
    {
        require(
            owner == operator || isApprovedForAll(owner, operator),
            "only owner or operator"
        );
        return true;
    }

    function balanceOfUsable(address user, uint256 tokenId)
        public
        view
        override
        returns (uint256 amount)
    {
        uint256[] memory recordIds = _userRecordIds[tokenId][user].values();
        for (uint256 i = 0; i < recordIds.length; i++) {
            if (block.timestamp <= _records[recordIds[i]].expiry) {
                amount += _records[recordIds[i]].amount;
            }
        }
    }

    function frozenOf(address owner, uint256 tokenId)
        public
        view
        override
        returns (uint256)
    {
        return _frozens[tokenId][owner];
    }

    function recordOf(uint256 recordId)
        public
        view
        override
        returns (Record memory)
    {
        return _records[recordId];
    }

    function setUsable(
        address owner,
        address user,
        uint256 tokenId,
        uint256 amount,
        uint64 expiry
    ) public override {
        require(isOwnerOrApproved(owner, msg.sender));
        require(amount <= balanceOf(owner, tokenId), "balance is not enough");
        require(
            _userRecordIds[tokenId][user].length() < recordLimit,
            "user cannot have more records"
        );
        _frozen(owner, tokenId, amount);
        _newRecord(owner, user, tokenId, amount, expiry);
    }

    function increaseUsable(
        uint256 recordId,
        uint256 amount,
        uint64 expiry
    ) public override {
        Record storage _record = _records[recordId];
        require(isOwnerOrApproved(_record.owner, msg.sender));
        require(
            amount <= balanceOf(_record.owner, _record.tokenId),
            "balance is not enough"
        );
        _frozen(_record.owner, _record.tokenId, amount);
        _record.amount += amount;
        _record.expiry = expiry;
        emit UpdateRecord(
            recordId,
            _record.tokenId,
            _record.amount,
            _record.owner,
            _record.user,
            _record.expiry
        );
    }

    function decreaseUsable(
        uint256 recordId,
        uint256 amount,
        uint64 expiry
    ) public override {
        Record storage _record = _records[recordId];

        if (_record.expiry < block.timestamp) {
            deleteRecord(recordId);
        } else {
            require(
                isOwnerOrApproved(_record.owner, msg.sender) ||
                    isOwnerOrApproved(_record.user, msg.sender)
            );
            require(amount <= _record.amount, "invalid amount");
            if (amount == _record.amount) {
                deleteRecord(recordId);
            } else {
                _decreaseUsable(recordId, amount, expiry);
            }
        }
    }

    function transferUsable(
        uint256 recordId,
        uint256 amount,
        address to
    ) public override {
        Record storage _record = _records[recordId];
        require(_record.expiry > block.timestamp);
        require(isOwnerOrApproved(_record.owner, msg.sender));
        require(amount <= _record.amount, "invalid amount");
        if (amount == _record.amount) {
            _frozens[_record.tokenId][_record.owner] -= amount;
            _frozens[_record.tokenId][to] += amount;
            _record.owner = to;
            emit UpdateRecord(
                recordId,
                _record.tokenId,
                _record.amount,
                _record.owner,
                _record.user,
                _record.expiry
            );
        } else {
            _frozens[_record.tokenId][_record.owner] -= amount;
            _record.amount -= amount;
            emit UpdateRecord(
                recordId,
                _record.tokenId,
                amount,
                _record.owner,
                _record.user,
                _record.expiry
            );

            _frozens[_record.tokenId][to] += amount;
            _newRecord(
                to,
                _record.user,
                _record.tokenId,
                amount,
                _record.expiry
            );
        }
    }

    function _newRecord(
        address owner,
        address user,
        uint256 tokenId,
        uint256 amount,
        uint64 expiry
    ) internal {
        _curRecordId++;
        _records[_curRecordId] = Record(tokenId, amount, owner, user, expiry);
        _userRecordIds[tokenId][user].add(_curRecordId);
        emit UpdateRecord(_curRecordId, tokenId, amount, owner, user, expiry);
    }

    function _decreaseUsable(
        uint256 recordId,
        uint256 amount,
        uint64 expiry
    ) internal {
        Record storage _record = _records[recordId];
        _unfrozen(_record.owner, _record.tokenId, amount);
        _record.amount -= amount;
        _record.expiry = expiry;
        emit UpdateRecord(
            recordId,
            _record.tokenId,
            _record.amount,
            _record.owner,
            _record.user,
            _record.expiry
        );
    }

    function deleteRecord(uint256 recordId) internal {
        Record storage _record = _records[recordId];
        _unfrozen(_record.owner, _record.tokenId, _record.amount);
        _userRecordIds[_record.tokenId][_record.user].remove(recordId);
        emit UpdateRecord(
            recordId,
            _record.tokenId,
            0,
            _record.owner,
            _record.user,
            _record.expiry
        );
        delete _records[recordId];
    }

    function _frozen(
        address owner,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        _safeTransferFrom(owner, address(this), tokenId, amount, "");
        _frozens[tokenId][owner] += amount;
    }

    function _unfrozen(
        address owner,
        uint256 tokenId,
        uint256 amount
    ) internal virtual {
        _safeTransferFrom(address(this), owner, tokenId, amount, "");
        _frozens[tokenId][owner] -= amount;
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(IERC165, ERC1155, ERC1155Receiver)
        returns (bool)
    {
        return
            interfaceId == type(IERC1155).interfaceId ||
            interfaceId == type(IERC1155MetadataURI).interfaceId ||
            interfaceId == type(IERC1155Receiver).interfaceId ||
            super.supportsInterface(interfaceId);
    }

    function onERC1155Received(
        address operator,
        address from,
        uint256 id,
        uint256 value,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC1155Receiver.onERC1155Received.selector;
    }

    function onERC1155BatchReceived(
        address operator,
        address from,
        uint256[] calldata ids,
        uint256[] calldata values,
        bytes calldata data
    ) external override returns (bytes4) {
        return IERC1155Receiver.onERC1155BatchReceived.selector;
    }
}
