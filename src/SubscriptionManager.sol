// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MentorAcc} from "./MentorAcc.sol";
import {MenteeAcc} from "./MenteeAcc.sol";
import {SubscriptionPlans} from "./SubscriptionPlans.sol";
import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract SubscriptionManager is SubscriptionPlans, MentorAcc, MenteeAcc, ReentrancyGuard {
    event MentorshipCreated(address menteesAddress, address mentorsAddress);
    event SubscriptionCancelledAndEndedMentorship(uint256 planId, address menteesAddress, address mentorsAddress);
    event mentorAccountCreated(address mentorsAddress);
    event menteeAccountCreated(address menteesAddress);
    event menteeConfirmed(address menteesAddress);

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
        require(mentees[menteesAddress].hasMentor == false, "Mentee already has a Mentor");
        require(checkAddressInArray(mentorsAddress, menteesAddress), "Mentee's address has not been confirmed");
        
        // Set mentee's struct value 'hasMentor' to true
        mentees[menteesAddress].hasMentor = true;

        // Update mentee's mentorsAddress to the mentor's address passed in
        mentees[menteesAddress].mentorsAddress = mentorsAddress;

        emit MentorshipCreated(menteesAddress, mentorsAddress);

        return true; // mentorship exists.
    }

    function CreateMentorshipAndBuySubscription(address menteesAddress, address mentorsAddress, uint256 planId)
        public
        payable
        onlyMentee
    {
        
        bool mentorshipCreated = createMentorship(menteesAddress, mentorsAddress);
        require(mentorshipCreated, "Failed to create mentorship");
        require(mentorsAddress == mentees[menteesAddress].mentorsAddress, "passed in mentorsAddress is not the mentee's mentor address");

        subscribe(planId, mentorsAddress);
    }


    function EndMentorshipAndCancelSubscription(uint256 planId, address menteesAddress, address mentorsAddress)
        public
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

        cancel(planId, menteesAddress);

        emit SubscriptionCancelledAndEndedMentorship(planId, menteesAddress, mentorsAddress);
    }

    function Pay(address menteesAddress, uint256 planId) public {
        pay(menteesAddress, planId);
    }

    //////////////////////////////////////////

    function getMenteeProfile(address menteesAddress) public view returns (Mentee memory) {
        return mentees[menteesAddress];
    }

    function getMentorProfile(address mentorsAddress) public view returns (Mentor memory) {
        return mentors[mentorsAddress];
    }

    function getCheckIfMenteesAddressInOpenSlotsForMenteesArray(address mentorsAddress, address menteesAddress) public view returns (bool) {
        return checkAddressInArray(mentorsAddress, menteesAddress);
    }

    function getMenteeCountOfMentor(address mentorsAddress) external view returns (uint256) {
        return mentors[mentorsAddress].OpenSlotsForMentees.length;
    }

    function getMentorsAddress(address menteesAddress) external view returns (address) {
        require(mentees[menteesAddress].hasMentor == true, "Mentee does not have mentor... yet");
        return mentees[menteesAddress].mentorsAddress;
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
