// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {MentorAcc} from "./MentorAcc.sol";
import {MenteeAcc} from "./MenteeAcc.sol";
import {SubscriptionPlans} from "./SubscriptionPlans.sol";

contract SubscriptionManager is MentorAcc, MenteeAcc, SubscriptionPlans {
    // creates  subscript plans code

    // helper function
    function checkAddressInArray(address[] memory array, address targetAddress) public pure returns (bool) {
        for (uint i = 0; i < array.length; i++) {
            if (array[i] == targetAddress) {
                return true;
            }
        }
        return false;
    }

    // helper function
    function callCheckAddressInArray(address mentorsAddress, address menteesAddress) public view returns (bool) {
        return checkAddressInArray(getOpenSlotsForMenteesArray(mentorsAddress), menteesAddress);
    }

    modifier onlyMentee() {
        require(msg.sender == mentees[msg.sender].menteesAddress, "Caller must be a mentee");
        _;
    }

    // mentorship is created which is needed for mentee buying a subscription.
    function createMentorship( address menteesAddress, address mentorsAddress)
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

    // mentee deposits money, and buys specific plan // will have to redesign the SubscriptionManage.sol contract
    function menteeBuysSubscription(uint256 amount) internal {
        // require(some check to make sure caller is owner of account being funded); //might not be needed
        // fundMenteesWallet(amount);//might not be needed

        // payment logic takes place here, this is where the finer details happen such as when the payment happens and how much should be paid, this depends on the specific plan. That will be created on a separate contract.
        // Payment Logic!!!;buy the subscription, and split money. call the payMentor() function;
    }

    //calls the menteeBuysSubscription(uint256 amount) & createMentorship(“mentor’s address)  functions
    function BuySubscriptionAndCreateMentorship( /* amount, mentorsAddress */ ) public /*someOnlyMenteeModifier()*/ {
        // createMentorship(mentors address);
        // if(createMentorship != true) revert;
        // menteeBuysSubscription(amount);
    }

    // this function should be done in the SubscriptionManager contract. Because it will be a part of creating mentorship func which is needed right before mentee buys subscription plan
    // function setMentorAddress(address mentorAddress) public {
    //     require(mentees[msg.sender].hasMentor == false, "Mentee already has a mentor");
    //     mentees[msg.sender].mentorsAddress = mentorAddress;
    //     mentees[msg.sender].hasMentor = true;
    // }
}
