// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract FlexSub {
    struct Subscription {
        uint256 startTimestamp;
        uint256 lastActivityTimestamp;
        uint256 period; // e.g. subscription period in seconds
        bool active;
    }

    mapping(address => Subscription) public subscriptions;
    uint256 public subscriptionFee;
    address public owner;

    event Subscribed(address indexed user, uint256 startTimestamp, uint256 period);
    event ActivityUpdated(address indexed user, uint256 timestamp);
    event SubscriptionCancelled(address indexed user);

    modifier onlyOwner() {
        require(msg.sender == owner, "Not owner");
        _;
    }

    constructor(uint256 _subscriptionFee) {
        owner = msg.sender;
        subscriptionFee = _subscriptionFee;
    }

    function subscribe(uint256 period) external payable {
        require(msg.value == subscriptionFee, "Incorrect fee");
        require(!subscriptions[msg.sender].active, "Already subscribed");

        subscriptions[msg.sender] = Subscription({
            startTimestamp: block.timestamp,
            lastActivityTimestamp: block.timestamp,
            period: period,
            active: true
        });

        emit Subscribed(msg.sender, block.timestamp, period);
    }

    function updateActivity() external {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.active, "Not subscribed");
        require(block.timestamp <= sub.lastActivityTimestamp + sub.period, "Subscription expired");

        sub.lastActivityTimestamp = block.timestamp;
        emit ActivityUpdated(msg.sender, block.timestamp);
    }

    function cancelSubscription() external {
        Subscription storage sub = subscriptions[msg.sender];
        require(sub.active, "Not subscribed");

        sub.active = false;
        emit SubscriptionCancelled(msg.sender);
    }

    function isActive(address user) external view returns (bool) {
        Subscription storage sub = subscriptions[user];
        if(!sub.active) return false;
        return block.timestamp <= sub.lastActivityTimestamp + sub.period;
    }

    function setSubscriptionFee(uint256 newFee) external onlyOwner {
        subscriptionFee = newFee;
    }
}
