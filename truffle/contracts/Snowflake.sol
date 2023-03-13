// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

// This contract generates 64-bit IDs where the first 44 bits are the timestamp 
// in seconds since September 4th, 2021 (the "epoch" time), the next 20 bits are the node ID (the address of the contract), 
// and the final 12 bits are a sequence number that is incremented when multiple IDs are generated in the same second.
contract Snowflake {
    uint256 private lastTimestamp;
    uint256 private sequence;
    uint256 private constant sequenceMask = 0xFFF; // 12 bits
    uint256 private constant sequenceShift = 12;
    uint256 private constant nodeBits = 10;
    uint256 private constant nodeShift = 22;
    uint256 private constant epoch = 1630761600; // 2021-09-04T00:00:00Z


    function generateId() public returns (uint256 id) {
        uint256 currentTimestamp = uint256(block.timestamp);
        require(currentTimestamp >= lastTimestamp, "Timestamp must not go backwards");

        if (currentTimestamp == lastTimestamp) {
            sequence = (sequence + 1) & sequenceMask;
            if (sequence == 0) {
                // Sequence overflow, wait until next timestamp
                currentTimestamp = waitForNextTimestamp();
            }
        } else {
            sequence = 0;
        }
        // lastTimestamp = currentTimestamp;
        // As of Solidity v0.8, you can no longer cast explicitly from address to uint256.
        uint256 nodeId = uint256(uint160(address(this))) >> (256 - nodeBits);
        // [1(no use)] [41bits(timestamp)] [10(node)] [12(seq)]
        id = ((currentTimestamp) << nodeShift) | (nodeId << sequenceShift) | sequence;
    }

    function waitForNextTimestamp() private view returns (uint256) {
        uint256 currentTimestamp = uint256(block.timestamp);
        while (currentTimestamp == lastTimestamp) {
            currentTimestamp = uint256(block.timestamp);
        }
        return currentTimestamp;
    }


    // for test
    // uint256 _id = generateId();
}
