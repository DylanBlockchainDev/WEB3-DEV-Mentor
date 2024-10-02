// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MentorAcc} from "./MentorAcc.sol";
import {MenteeAcc} from "./MenteeAcc.sol";
import {SubscriptionPlans} from "./SubscriptionPlans.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract SubscriptionManager is SubscriptionPlans, MentorAcc, MenteeAcc, Ownable, ReentrancyGuard {
    event MentorshipCreated(address menteesAddress, address mentorsAddress);
    event SubscriptionCancelledAndEndedMentorship(uint256 planId, address menteesAddress, address mentorsAddress);
    event mentorAccountCreated(address mentorsAddress);
    event menteeAccountCreated(address menteesAddress);
    event menteeConfirmed(address menteesAddress);

    constructor() Ownable(msg.sender) {}

    function transferOwnership(address newOwner) public override onlyOwner {
        _transferOwnership(newOwner);
    }

    // function createSubPlan(address token, uint256 amount, uint256 frequency) public onlyOwner {
    //     createPlan(token, amount, frequency);
    // }

    // function deleteSubPlan(uint256 planId) public onlyOwner {
    //     // unlikly to use this.
    //     // will send out a notification on frontend for users in advance.
    //     deletePlan(planId);
    // }

    // function callPay(address subscriber, uint256 planId) public payable {
    //     pay(subscriber, planId);
    // }

    function checkAddressInArray(address mentorsAddress, address targetAddress) private view returns (bool) {
        address[] memory OpenSlotsForMentees = getOpenSlotsForMenteesArray(mentorsAddress);
        for (uint256 i = 0; i < OpenSlotsForMentees.length; i++) {
            if (OpenSlotsForMentees[i] == targetAddress) {
                return true;
            }
        }
        return false;
    }

    modifier onlyMentorOrMentee() {
        require(
            msg.sender == mentees[msg.sender].menteesAddress || msg.sender == mentors[msg.sender].mentorsAddress,
            "Caller must be a mentor or mentee"
        );
        _;
    }

    // mentorship is created which is needed for mentee buying a subscription.
    function createMentorship(address menteesAddress, address mentorsAddress) internal returns (bool) {
        require(!mentees[menteesAddress].hasMentor == false, "Mentee already has a Mentor");
        require(checkAddressInArray(mentorsAddress, menteesAddress), "Mentee's address has not been confirmed");

        // Set mentee's struct value 'hasMentor' to true
        mentees[menteesAddress].hasMentor = true;

        // Update mentee's mentorsAddress to the mentor's address passed in
        mentees[menteesAddress].mentorsAddress = mentorsAddress;

        emit MentorshipCreated(menteesAddress, mentorsAddress);

        return true; // mentorship exists.
    }

    // mentee buys specific plan
    // function menteeBuysSubscription(uint256 planId) public payable onlyMentee {
    //     address mentorsAddress = mentees[msg.sender].mentorsAddress;
    //     subscribe(planId, mentorsAddress);
    // }

    function buySubscriptionAndCreateMentorship(address menteesAddress, address mentorsAddress, uint256 planId)
        public
        payable
        onlyMentee
    {
        bool mentorshipCreated = createMentorship(menteesAddress, mentorsAddress);
        require(mentorshipCreated, "Failed to create mentorship");
        // menteeBuysSubscription(planId);

        // address mentorsAddress = mentees[msg.sender].mentorsAddress;
        subscribe(planId, mentorsAddress);
    }


    function cancelSubscriptionAndEndMentorship(uint256 planId, address menteesAddress, address mentorsAddress)
        internal
        onlyMentorOrMentee
    {
        require(mentees[menteesAddress].hasMentor == true, "Menotrship already doesn't exist");
        require(checkAddressInArray(mentorsAddress, menteesAddress), "This is already not mentee's mentor");
        require(mentees[menteesAddress].mentorsAddress == mentorsAddress, "This is not mentee's mentor");
        require(mentors[mentorsAddress].OpenSlotsForMentees.length > 0, "No mentees to remove");

        // Set mentee's struct value 'hasMentor' to true
        mentees[menteesAddress].hasMentor = false;
        mentees[menteesAddress].mentorsAddress = address(0);

        // remove mentee for montor's mentee list!!!
        uint256 length = mentors[mentorsAddress].OpenSlotsForMentees.length;

        // Find the index of the mentee to remove
        uint256 indexToRemove = 0;
        for (uint256 i = 0; i < length; i++) {
            if (mentors[mentorsAddress].OpenSlotsForMentees[i] == menteesAddress) {
                indexToRemove = i;
                break;
            }
        }

        // If found, replace with the last element and pop
        if (indexToRemove < length) {
            mentors[mentorsAddress].OpenSlotsForMentees[indexToRemove] =
                mentors[mentorsAddress].OpenSlotsForMentees[length - 1];
            mentors[mentorsAddress].OpenSlotsForMentees.pop();
        }

        cancel(planId);

        emit SubscriptionCancelledAndEndedMentorship(planId, menteesAddress, mentorsAddress);
    }

    //////////////////////////////////////////

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

    function getMenteeCountOfMentor(address mentorsAddress) external view returns (uint256) {
        return mentors[mentorsAddress].OpenSlotsForMentees.length;
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
