// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

contract UUIDProvider {

// Uses keccak256 (a version of SHA-3) to hash together the 
// current block timestamp, difficulty, block number, and the sender's address. 
// It then converts the resulting 32-byte hash into a 16-byte UUID and returns it.

// Note that this is a simple example, and you may want to
// consider using more sources of entropy to 
// ensure that the UUIDs generated by your contract are sufficiently random and hard to predict.
    function generateUUID() public view returns (bytes16) {
        bytes32 uuid = keccak256(abi.encodePacked(
            block.timestamp,
            block.difficulty,
            // block.prevrandao,
            block.number,
            msg.sender
        ));
        bytes16 uuid16 = bytes16(uuid);
        return uuid16;
    }

}