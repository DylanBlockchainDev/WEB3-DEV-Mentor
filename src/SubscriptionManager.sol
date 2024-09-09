// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MentorAcc} from "./MentorAcc.sol";
import {MenteeAcc} from "./MenteeAcc.sol";
import {SubscriptionPlans} from "./SubscriptionPlans.sol";

contract SubscriptionManager is SubscriptionPlans, MentorAcc, MenteeAcc {
    // helper function
    function checkAddressInArray(address[] memory array, address targetAddress) private pure returns (bool) {
        for (uint256 i = 0; i < array.length; i++) {
            if (array[i] == targetAddress) {
                return true;
            }
        }
        return false;
    }

    // helper function
    function callCheckAddressInArray(address mentorsAddress, address menteesAddress) private view returns (bool) {
        return checkAddressInArray(getOpenSlotsForMenteesArray(mentorsAddress), menteesAddress);
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
        require(mentees[menteesAddress].hasMentor == false, "Mentee already has a Mentor");
        require(mentors[msg.sender].OpenSlotsForMentees.length < MAX_MENTEES_PER_MENTOR, "No slots available");
        require(callCheckAddressInArray(mentorsAddress, menteesAddress), "Mentee's address has not been confirmed");

        // Set mentee's struct value 'hasMentor' to true
        mentees[menteesAddress].hasMentor = true;

        // Update mentee's mentorsAddress to the mentor's address passed in
        mentees[menteesAddress].mentorsAddress = mentorsAddress;

        return true; // mentorship exists.
    }

    // mentee buys specific plan
    function menteeBuysSubscription(uint256 planId) public payable onlyMentee {
        require(msg.value > 0, "Payment required");
        subscribe(planId);
    }

    function cancelSubscriptionAndEndMentorship(uint256 planId, address menteesAddress, address mentorsAddress)
        internal
        onlyMentorOrMentee
    {
        require(mentees[menteesAddress].hasMentor == true, "Menotrship already doesn't exist");
        require(callCheckAddressInArray(mentorsAddress, menteesAddress), "This is already not mentee's mentor");
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
    }
}
