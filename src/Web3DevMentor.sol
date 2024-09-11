// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";
import {SubscriptionManager} from "./SubscriptionManager.sol";

contract Web3DevMentor is SubscriptionManager, Ownable, ReentrancyGuard {
    event mentorAccountCreated(address mentorsAddress);
    event menteeAccountCreated(address menteesAddress);
    event menteeConfirmed(address menteesAddress);

    constructor() Ownable(msg.sender) {}

    // creates  subscript plans code // onlyOwner()
    function createSubPlan(address token, uint256 amount, uint256 frequency) public onlyOwner {
            createPlan(token, amount, frequency);
    }

    function deleteSubPlan(uint256 planId) internal onlyOwner {
        // unlikly to use this.
        // will send out a notification on frontend for users in advance.
        deletePlan(planId);
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
        emit mentorAccountCreated(msg.sender);
    }

    function signUpAsMentee(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) public {
        createMenteeAccount(name, expertise, yearsOfExperience, bioMessage);
        emit menteeAccountCreated(msg.sender);
    }

    function callconfirmMentee(address menteesAddress) public onlyMentor {
        confirmMentee(menteesAddress);
        emit menteeConfirmed(menteesAddress);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _transferOwnership(newOwner);
    }
}
