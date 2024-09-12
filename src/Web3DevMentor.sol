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

    function deleteSubPlan(uint256 planId) public onlyOwner {
        // unlikly to use this.
        // will send out a notification on frontend for users in advance.
        deletePlan(planId);
    }

    //calls the menteeBuysSubscription(uint256 amount) & createMentorship(“mentor’s address)  functions
    function buySubscriptionAndCreateMentorship(address menteesAddress, address mentorsAddress, uint256 planId)
        public
        payable
        onlyMentee
    {
        bool mentorshipCreated = createMentorship(menteesAddress, mentorsAddress);
        require(mentorshipCreated, "Failed to create mentorship");
        menteeBuysSubscription(planId);
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
        require(mentees[menteesAddress].hasMentor == false, "Mentee already has a Mentor");
        confirmMentee(menteesAddress);
        emit menteeConfirmed(menteesAddress);
    }

    function transferOwnership(address newOwner) public override onlyOwner {
        _transferOwnership(newOwner);
    }

    function getMenteeProfile(address menteesAddress) public view returns (
        bool isMentee,
        address menteesAddress_,
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage,
        bool hasMentor,
        address mentorsAddress,
        bool menteeHasPlan
    ) {
        Mentee storage mentee = mentees[menteesAddress];
        return (
            mentee.isMentee,
            mentee.menteesAddress,
            mentee.name,
            mentee.expertise,
            mentee.yearsOfExperience,
            mentee.bioMessage,
            mentee.hasMentor,
            mentee.mentorsAddress,
            mentee.menteeHasPlan
        );
    }

    function getMentorProfile(address mentorsAddress) public view returns (
        bool isMentor,
        address mentorsAddress_,
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage,
        address[] memory openSlotsForMentees
    ) {
        Mentor storage mentor = mentors[mentorsAddress];
        return (
            mentor.isMentor,
            mentor.mentorsAddress,
            mentor.name,
            mentor.expertise,
            mentor.yearsOfExperience,
            mentor.bioMessage,
            mentor.OpenSlotsForMentees
        );
    }

    function getTotalSubscribersForMentor(address mentorsAddress) public view returns (uint256) {
        Mentor storage mentor = mentors[mentorsAddress];
        return mentor.OpenSlotsForMentees.length;
    }

    function getTotalMentors() public view returns (uint256) {
        return totalMentors; 
    }

    function getTotalMentees() public view returns (uint256) {
        return totalMentees;
    }

    function getNextPaymentDate(address subscriber, uint256 planId) public view returns (uint256) {
        Subscription storage subscription = subscriptions[subscriber][planId];
        return subscription.nextPayment;
    }    

    function getRemainingPayments(address subscriber, uint256 planId) public view returns (uint256) {
        // Get the subscription details for the given subscriber and plan
        Subscription storage subscription = subscriptions[subscriber][planId];

        // Retrieve the plan details for the given plan ID
        Plan storage plan = plans[planId];

        // Calculate the total number of payments
        // This is done by summing up the start time and then multiplying the difference between nextPayment and start by the frequency minus one
        // This formula assumes payments occur at regular intervals
        uint256 totalPayments = subscription.start + (subscription.nextPayment - subscription.start) * (plan.frequency - 1);

        // Return the difference between the totalPayments and the current block timestamp
        // This gives us the number of seconds until the next payment is due
        return totalPayments - block.timestamp;
    }
    
}
