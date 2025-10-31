// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Project {
    address public owner;
    string public projectName;
    uint256 public goalAmount;
    uint256 public totalFunds;

    mapping(address => uint256) public contributions;

    constructor(string memory _projectName, uint256 _goalAmount) {
        owner = msg.sender;
        projectName = _projectName;
        goalAmount = _goalAmount;
    }

    // Function to fund the project
    function fundProject() external payable {
        require(msg.value > 0, "Must send some ETH to fund.");
        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;
    }

    // Function for the owner to withdraw funds once the goal is reached
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw.");
        require(totalFunds >= goalAmount, "Goal not reached yet.");

        uint256 amount = address(this).balance;
        totalFunds = 0;
        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed.");
    }

    // Function to check contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }
}

