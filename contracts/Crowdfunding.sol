// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract Project {
    address public owner;
    string public projectName;
    uint256 public goalAmount;
    uint256 public totalFunds;
    bool public goalReached;
    bool public fundsWithdrawn;

    mapping(address => uint256) public contributions;

    constructor(string memory _projectName, uint256 _goalAmount) {
        owner = msg.sender;
        projectName = _projectName;
        goalAmount = _goalAmount;
        goalReached = false;
        fundsWithdrawn = false;
    }

    // Function to fund the project
    function fundProject() external payable {
        require(msg.value > 0, "Must send some ETH to fund.");
        require(!fundsWithdrawn, "Project closed.");

        contributions[msg.sender] += msg.value;
        totalFunds += msg.value;

        if (totalFunds >= goalAmount) {
            goalReached = true;
        }
    }

    // Function for the owner to withdraw funds once the goal is reached
    function withdrawFunds() external {
        require(msg.sender == owner, "Only owner can withdraw.");
        require(goalReached, "Goal not reached yet.");
        require(!fundsWithdrawn, "Funds already withdrawn.");

        uint256 amount = address(this).balance;
        totalFunds = 0;
        fundsWithdrawn = true;

        (bool success, ) = payable(owner).call{value: amount}("");
        require(success, "Transfer failed.");
    }

    // Function to check contract balance
    function getBalance() external view returns (uint256) {
        return address(this).balance;
    }

    //  NEW FUNCTION #1: Refund contributors if goal not reached
    function refund() external {
        require(!goalReached, "Goal reached, refunds not allowed.");
        require(contributions[msg.sender] > 0, "No contribution found.");

        uint256 amount = contributions[msg.sender];
        contributions[msg.sender] = 0;
        totalFunds -= amount;

        (bool success, ) = payable(msg.sender).call{value: amount}("");
        require(success, "Refund failed.");
    }

    //  NEW FUNCTION #2: Get contribution amount for a user
    function getContributorAmount(address _user) external view returns (uint256) {
        return contributions[_user];
    }
}
