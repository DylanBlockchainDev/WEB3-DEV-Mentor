// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {SubscriptionManager} from "../src/SubscriptionManager.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Web3DevMentorTest is Test {
    SubscriptionManager public wdm;
    address public mentor;
    address public mentee;
    ERC20Mock public weth;
    ERC20Mock public beth;
    ERC20Mock public meth;

    function setUp() public {
        wdm = new SubscriptionManager();
        weth = new ERC20Mock();
        beth = new ERC20Mock();
        meth = new ERC20Mock();

        // Create mock SubPlans
        // have to create mock token.
        wdm.createPlan(address(beth), 100, 30 days);
        wdm.createPlan(address(weth), 600, 180 days);
        wdm.createPlan(address(meth), 1200, 365 days);

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

    function testUpdateMentorInfo() public {
        vm.prank(mentor);
        wdm.updateMentorInfo("2 TestMentor", "2 Test Mentor Expertise", 12, "2 Test Mentor Bio");

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
        assertEq(name, "2 TestMentor", "Incorrect name");
        assertEq(expertise, "2 Test Mentor Expertise", "Incorrect Expertise");
        assertEq(yearsOfExperience, 12, "Incorrect years of exp");
        assertEq(bioMessage, "2 Test Mentor Bio", "Incorrect Mentor Bio");
        assertEq(openSlotsForMentees.length, 0, "Open slots count should be 10");
    }

    function testUpdateMenteeInfo() public {
        vm.prank(mentee);
        wdm.updateMenteeInfo("2 TestMentee", "2 Test Mentee Expertise", 2, "2 Test Mentee Bio");

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
        assertEq(name, "2 TestMentee", "Incorrect name");
        assertEq(expertise, "2 Test Mentee Expertise", "Incorrect expertise");
        assertEq(yearsOfExperience, 2, "Incorect years of exp");
        assertEq(bioMessage, "2 Test Mentee Bio", "Incorrect bio message");
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

    // testCreatPlan - partial with setUp()
    function testCreatPlan() public view {
        console.log("SubscriptionManager addr - ", address(wdm));
        console.log("test contract addr - ", address(this));

        // Check if the correct number of plans were created
        uint256 expectedNumberOfPlans = 3;
        assertEq(wdm.nextPlanId(), expectedNumberOfPlans, "Incorrect number of plans created");

        // Iterate through the plans and verify their properties
        for (uint256 i = 0; i < wdm.nextPlanId(); i++) {
            SubscriptionManager.Plan memory plan = wdm.getPlanWithId(i);

            console.log("plan.merchant - ", plan.merchant);
            console.log("plan.token - ", plan.token);
            console.log("plan.amount - ", plan.amount);
            console.log("plan.frequency - ", plan.frequency);
            
            assertEq(plan.merchant, address(this), "Plan merchant should be the deployer of SubscriptionManager contract - (which in this case is this test contract)");
            // assertEq(plan.token, address(weth) || address(beth) || address(meth), "Plan token should be the mock WETH token");

            address expectedToken;
            uint256 expectedAmount;
            uint256 expectedFrequency;

            if (i == 0) {
                expectedToken = address(beth);
                expectedAmount = 100;
                expectedFrequency = 30 days;
            } else if (i == 1) {
                expectedToken = address(weth);
                expectedAmount = 600;
                expectedFrequency = 180 days;
            } else {
                expectedToken = address(meth);
                expectedAmount = 1200;
                expectedFrequency = 365 days;
            }

            assertEq(plan.token, expectedToken, "Plan token is not expected mock token");
            assertEq(plan.amount, expectedAmount, "Incorrect plan amount");
            assertEq(plan.frequency, expectedFrequency, "Incorrect plan frequency");
        }

    }

    function testCreatePlanWithInvalidInput1() public {
        vm.expectRevert("address cannot be null address");
        wdm.createPlan(address(0), 100, 30 days);
    }

    function testCreatePlanWithInvalidInput2() public {
        vm.expectRevert("amount needs to be > 0");
        wdm.createPlan(address(beth), 0, 30 days);
    }

    function testCreatePlanWithInvalidInput3() public {
        vm.expectRevert("frequency needs to be > 0");
        wdm.createPlan(address(beth), 100, 0);
    } 

    // testDeletePlan - partial with setUp()
    function testDeletePlan() public {
        SubscriptionManager.Plan memory plan = wdm.getPlanWithId(0);
        console.log("Plan 0", plan.token, plan.amount, plan.frequency);

        uint256 testPlanId = 0; // out of 0,1,2
        wdm.deletePlan(testPlanId);

        uint256 expectedNumberOfPlans = 2;
        assertEq(wdm.nextPlanId(), expectedNumberOfPlans, "Incorrect number of plans created");
    }

    // testCreateMentorshipAndBuySubscription
    // testEndMentorshipAndCancelSubscription
}