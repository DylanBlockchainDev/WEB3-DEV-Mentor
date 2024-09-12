// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MentorAcc} from "./MentorAcc.sol";
import {MenteeAcc} from "./MenteeAcc.sol";
import {SubscriptionPlans} from "./SubscriptionPlans.sol";

contract SubscriptionManager is SubscriptionPlans, MentorAcc, MenteeAcc {
    event MentorshipCreated(address menteesAddress, address mentorsAddress);
    event SubscriptionCancelledAndEndedMentorship(uint256 planId, address menteesAddress, address mentorsAddress);

    function checkAddressInArray(address mentorsAddress, address targetAddress) private view returns (bool) {
        address[] memory OpenSlotsForMentees = getOpenSlotsForMenteesArray(mentorsAddress);
        for (uint256 i = 0; i < OpenSlotsForMentees.length; i++) {
            if (OpenSlotsForMentees[i] == targetAddress) {
                return true;
            }
        }
        return false;
    }

    modifier onlyMentee() {
        require(msg.sender == mentees[msg.sender].menteesAddress, "Caller must be a mentee");
        _;
    }

    modifier onlyMentorOrMentee() {
        require(
            msg.sender == mentees[msg.sender].menteesAddress || msg.sender == mentors[msg.sender].mentorsAddress,
            "Caller must be a mentor or mentee"
        );
        _;
    }

    // mentorship is created which is needed for mentee buying a subscription.
    function createMentorship(address menteesAddress, address mentorsAddress)
        internal
        onlyMentee
        returns (bool /*bool(there is a mentorship)*/ )
    {
        require(!mentees[menteesAddress].hasMentor == false, "Mentee already has a Mentor");
        require(mentors[msg.sender].OpenSlotsForMentees.length < MAX_MENTEES_PER_MENTOR, "No slots available");
        require(checkAddressInArray(mentorsAddress, menteesAddress), "Mentee's address has not been confirmed");

        // Set mentee's struct value 'hasMentor' to true
        mentees[menteesAddress].hasMentor = true;

        // Update mentee's mentorsAddress to the mentor's address passed in
        mentees[menteesAddress].mentorsAddress = mentorsAddress;

        emit MentorshipCreated(menteesAddress, mentorsAddress);

        return true; // mentorship exists.
    }

    // mentee buys specific plan
    function menteeBuysSubscription(uint256 planId) public payable onlyMentee {
        address mentorsAddress = mentees[msg.sender].mentorsAddress;
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
}
