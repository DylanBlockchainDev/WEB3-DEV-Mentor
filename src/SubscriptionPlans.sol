// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {IERC20} from "../lib/openzeppelin-contracts/contracts/token/ERC20/IERC20.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";

contract SubscriptionPlans is Ownable{
    uint256 public nextPlanId;

    struct Plan {
        address merchant;
        address token;
        uint256 amount;
        uint256 frequency;
    }

    struct Subscription {
        address subscriber;
        address mentor;
        uint256 start;
        uint256 nextPayment;
    }

    mapping(uint256 => Plan) public plans;
    mapping(address => mapping(uint256 => Subscription)) public subscriptions;

    event PlanCreated(address merchant);
    event PlanDeleted(address merchant, uint256 planId, uint256 date);
    event SubscriptionCreated(address subscriber, address mentor, uint256 planId, uint256 date);
    event SubscriptionCancelled(address subscriber, uint256 planId, uint256 date);
    event PaymentSent(address from, address to, address to2, uint256 amount, uint256 planId, uint256 date);

    constructor() Ownable(msg.sender) {}

    function transferOwnership(address newOwner) public override onlyOwner {
        _transferOwnership(newOwner);
    }

    function createPlan(address token, uint256 amount, uint256 frequency) external onlyOwner {
        require(token != address(0), "address cannot be null address");
        require(amount > 0, "amount needs to be > 0");
        require(frequency > 0, "frequency needs to be > 0");
        plans[nextPlanId] = Plan(msg.sender, token, amount, frequency);
        nextPlanId++;
        emit PlanCreated(msg.sender);
    }

    function deletePlan(uint256 planId) external onlyOwner {
        Plan memory plan = plans[planId];
        require(plan.merchant == msg.sender, "Caller is not the merchant");
        require(planId < nextPlanId, "Plan does not exist");

        delete plans[planId];
        nextPlanId--;

        emit PlanDeleted(msg.sender, planId, block.timestamp);
    }

    function subscribe(uint256 planId, address mentor) internal {
        IERC20 token = IERC20(plans[planId].token);
        Plan storage plan = plans[planId];
        require(plan.merchant != address(0), "this plan does not exist");
        require(plan.token != address(0), "Invalid token address");

        uint256 amount = plan.amount;
        uint256 splitRatio = 20;

        uint256 merchantAmount = amount * splitRatio / 100;
        uint256 mentorAmount = amount - merchantAmount;

        bool success1 = token.transferFrom(msg.sender, plan.merchant, merchantAmount); // Owner receives 20%
        bool success2 = token.transferFrom(msg.sender, mentor, mentorAmount); // Menotr receives 80%

        if (!success1 || !success2) {
            // Revert if either transfer fails
            revert("Transfer failed");
        }

        emit PaymentSent(msg.sender, mentor, plan.merchant, plan.amount, planId, block.timestamp);

        subscriptions[msg.sender][planId] =
            Subscription(msg.sender, mentor, block.timestamp, block.timestamp + plan.frequency);
        emit SubscriptionCreated(msg.sender, mentor, planId, block.timestamp);
    }

    function cancel(uint256 planId) internal {
        Subscription storage subscription = subscriptions[msg.sender][planId];
        require(subscription.subscriber != address(0), "this subscription does not exist");
        delete subscriptions[msg.sender][planId];
        emit SubscriptionCancelled(msg.sender, planId, block.timestamp);
    }

    function pay(address subscriber, uint256 planId) external {
        Subscription storage subscription = subscriptions[subscriber][planId];
        Plan storage plan = plans[planId];
        IERC20 token = IERC20(plan.token);
        require(subscription.subscriber != address(0), "this subscription does not exist");
        require(block.timestamp > subscription.nextPayment, "not due yet");

        bool success1 = token.transferFrom(msg.sender, plan.merchant, plan.amount * 20 / 100); // Owner receives 20%
        bool success2 = token.transferFrom(msg.sender, subscription.mentor, plan.amount * 80 / 100); // Mentor receives 80%

        if (!success1 || !success2) {
            // Revert if either transfer fails
            revert("Transfer failed");
        }

        emit PaymentSent(subscriber, subscription.mentor, plan.merchant, plan.amount, planId, block.timestamp);
        subscription.nextPayment = subscription.nextPayment + plan.frequency;
    }

    // Getter functions
    function getPlanWithId(uint256 planId) public view returns (Plan memory) {
        return plans[planId];
    }

    function getSubscription(address subscriber, uint256 planId) public view returns (Subscription memory) {
        return subscriptions[subscriber][planId];
    }
}
