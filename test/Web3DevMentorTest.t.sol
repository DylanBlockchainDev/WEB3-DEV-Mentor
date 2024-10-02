// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {SubscriptionManager} from "../src/SubscriptionManager.sol";

contract Web3DevMentorTest is Test {
    SubscriptionManager public wdm;
    address public mentor;
    address public mentee;
    uint256 availableSlots;

    function setUp() public {
        wdm = new SubscriptionManager();

        // Create mock accounts
        mentor = address(1);
        mentee = address(2);

        vm.prank(mentor);
        wdm.createMentorAccount("TestMentor", "Test Mentor Expertise", 10, "Test Mentor Bio");

        vm.prank(mentee);
        wdm.createMenteeAccount("TestMentee", "Test Mentee Expertise", 0, "Test Mentee Bio");
    }

    function testCreatMentorAccount() public {
        vm.prank(mentor);
        // wdm.signUpAsMentor("TestMentor", "Test Mentor Expertise", 10, "Test Mentor Bio");

        (
            bool isMentor, 
            address mentorsAddress_, 
            string memory name, 
            string memory expertise, 
            uint256 yearsOfExperience, 
            string memory bioMessage, 
            address[] memory openSlotsForMentees
        ) = wdm.getMentorProfile(mentor);

        assertEq(isMentor, true, "Is not Mentor: False");
        assertEq(mentorsAddress_, mentor, "Incorrect mentorsAddress");
        assertEq(name, "TestMentor", "Incorrect name");
        assertEq(expertise, "Test Mentor Expertise", "Incorrect Expertise");
        assertEq(yearsOfExperience, 10, "Incorrect years of exp");
        assertEq(bioMessage, "Test Mentor Bio", "Incorrect Mentor Bio");
        assertEq(openSlotsForMentees.length, 0, "Open slots count should be 10");

    }

    function testCreatMenteeAccount() public {
        vm.prank(mentee);
        // wdm.signUpAsMentee("TestMentee", "Test Mentee Expertise", 0, "Test Mentee Bio");

        (
            bool isMentee, 
            address menteesAddress_, 
            string memory name, 
            string memory expertise, 
            uint256 yearsOfExperience, 
            string memory bioMessage, 
            bool hasMentor,
            address mentorsAddress,
            bool menteeHasPlan
        ) = wdm.getMenteeProfile(mentee);

        assertEq(isMentee, true, "Is not mentee: false");
        assertEq(menteesAddress_, mentee, "Incorrect menteesAddress");
        assertEq(name, "TestMentee", "Incorrect name");
        assertEq(expertise, "Test Mentee Expertise", "Incorrect expertise");
        assertEq(yearsOfExperience, 0, "Incorect years of exp");
        assertEq(bioMessage, "Test Mentee Bio", "Incorrect bio message");
        assertEq(hasMentor, false, "should be false initally");
        assertEq(mentorsAddress, address(0), "Should be address(0) initially");
        assertEq(menteeHasPlan, false, "Should be false initially");
    }

    function testCallconfirmMentee() public returns(bool) {
        vm.prank(mentor);

        wdm.confirmMentee(mentee);

        bool result = false;
        for (uint256 i = 0; i < wdm.getOpenSlotsForMenteesArray(mentor).length; i++) {
            if (wdm.getOpenSlotsForMenteesArray(mentor)[i] == mentee) {
                result = true;
                break;
            }
        }
        return result;
    }

    // testCreatSubPlan - partial with setUp()
    // testDeleteSubPlan - partial with setUp()

    // testCreateMentorshipAndBuySubscription

}