// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {SubscriptionManager} from "./SubscriptionManager.sol";

contract Web3DevMentor is SubscriptionManager, Ownable, ReentrancyGuard {
    uint256 public constant MAX_PLANS = 3;

    constructor() Ownable(msg.sender) {}

    // do the following later.
    // 6. add events where needed
    // 9. figure out real plans.
    // 10. Payment Logic!!!;buy the subscription, and split money. call the payMentor() function;

    // creates  subscript plans code // onlyOwner()
    function createSubPlan(address token, uint256 amount, uint256 frequency) public onlyOwner {
        require(nextPlanId < MAX_PLANS, "Max number of plans reached");
        for (uint256 i = 0; i < 3; i++) {
            uint256 planId = nextPlanId;
            createPlan(token, amount, frequency);
            subscribe(planId);
        }
    }

    // //calls the menteeBuysSubscription(uint256 amount) & createMentorship(“mentor’s address)  functions
    function buySubscriptionAndCreateMentorship(address menteesAddress, address mentorsAddress, uint256 planId)
    public
        payable
        onlyMentee
    {
        bool mentorshipCreated = createMentorship(menteesAddress, mentorsAddress);
        require(mentorshipCreated, "Failed to create mentorship");
        menteeBuysSubscription(planId);

        // try this() { // CONSIDER refund mechanism!!!!!
        //     menteeBuysSubscription{value: msg.value}(planId);
        // } catch (bytes memory reason) {
        //     // Refund the payment if subscription creation fails
        //     (bool success, ) = msg.sender.call{value: msg.value}("");
        //     require(success, "Refund failed");
        //     revert("Subscription creation failed");
        // }
    }

    function callPay(address subscriber, uint256 planId) public payable {
        pay(subscriber, planId);
    }

    function callCancelSubscriptionAndEndMentorship(uint256 planId, address menteesAddress, address mentorsAddress)
    public
        onlyMentorOrMentee
    {
        cancelSubscriptionAndEndMentorship(planId, menteesAddress, mentorsAddress);
    }

    //////////////////////////////////////////////////////////////////////////////////////

    function signUpAsMentor(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) public {
        createMentorAccount(name, expertise, yearsOfExperience, bioMessage);
    }

    function signUpAsMentee(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) public {
        createMenteeAccount(name, expertise, yearsOfExperience, bioMessage);
    }

    function callconfirmMentee(address menteesAddress) public onlyMentor {
        confirmMentee(menteesAddress);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _transferOwnership(newOwner);
    }
}
