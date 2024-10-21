// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {SubscriptionManager} from "../src/SubscriptionManager.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Web3DevMentorTest is Test {
    SubscriptionManager public subm;
    address public mentor;
    address public mentee1;
    address public mentee2;
    address public mentee3;
    ERC20Mock public weth;
    ERC20Mock public beth;
    ERC20Mock public meth;
    uint256 public constant TESTING_BALANCE = 2000 ether;

    mapping(address => uint256) public testBalances;

    function setUp() public {
        subm = new SubscriptionManager();
        weth = new ERC20Mock();
        beth = new ERC20Mock();
        meth = new ERC20Mock();

        // Create mock SubPlans
        // have to create mock token.
        subm.createPlan(address(beth), 100, 30 days);
        subm.createPlan(address(weth), 600, 180 days);
        subm.createPlan(address(meth), 1200, 365 days);

        // Create mock accounts
        mentor = address(1);
        mentee1 = address(2);
        mentee2 = address(3);
        mentee3 = address(4);
        
        testBalances[address(this)] = TESTING_BALANCE;
        testBalances[mentor] = TESTING_BALANCE;
        testBalances[mentee1] = TESTING_BALANCE;
        testBalances[mentee2] = TESTING_BALANCE;
        testBalances[mentee3] = TESTING_BALANCE;

        vm.deal(address(this), TESTING_BALANCE);
        vm.deal(mentor, TESTING_BALANCE);
        vm.deal(mentee1, TESTING_BALANCE);
        vm.deal(mentee2, TESTING_BALANCE);
        vm.deal(mentee3, TESTING_BALANCE);

        ERC20Mock(weth).mint(address(this), TESTING_BALANCE);
        ERC20Mock(weth).mint(mentor, TESTING_BALANCE);
        ERC20Mock(beth).mint(mentee1, TESTING_BALANCE);
        ERC20Mock(weth).mint(mentee2, TESTING_BALANCE);
        ERC20Mock(meth).mint(mentee3, TESTING_BALANCE);

        vm.prank(mentor);
        subm.createMentorAccount("TestMentor", "Test Mentor Expertise", 10, "Test Mentor Bio");

        vm.prank(mentee1);
        subm.createMenteeAccount("TestMentee1", "Test Mentee1 Expertise", 0, "Test Mentee1 Bio");

        vm.prank(mentee2);
        subm.createMenteeAccount("TestMentee2", "Test Mentee2 Expertise", 0, "Test Mentee2 Bio");

        vm.prank(mentee3);
        subm.createMenteeAccount("TestMentee3", "Test Mentee3 Expertise", 0, "Test Mentee3 Bio");
    }

    // Helper Function
    function balanceOf(address account) public view returns (uint256) {
        return testBalances[account];
    }

    function testCreatMentorAccount() public view {
        // vm.prank(mentor);
        // subm.signUpAsMentor("TestMentor", "Test Mentor Expertise", 10, "Test Mentor Bio");

        SubscriptionManager.Mentor memory mentors = subm.getMentorProfile(mentor);

        assertEq(mentors.isMentor, true, "Is not Mentor: False");
        assertEq(mentors.mentorsAddress, mentor, "Incorrect mentorsAddress");
        assertEq(mentors.name, "TestMentor", "Incorrect name");
        assertEq(mentors.expertise, "Test Mentor Expertise", "Incorrect Expertise");
        assertEq(mentors.yearsOfExperience, 10, "Incorrect years of exp");
        assertEq(mentors.bioMessage, "Test Mentor Bio", "Incorrect Mentor Bio");
        assertEq(mentors.OpenSlotsForMentees.length, 0, "Open slots count is 10, but current length of array is 0");

    }

    function testCreatMenteeAccount() public view {
        // vm.prank(mentee);
        // subm.signUpAsMentee("TestMentee", "Test Mentee Expertise", 0, "Test Mentee Bio");

        SubscriptionManager.Mentee memory mentees = subm.getMenteeProfile(mentee1);


        assertEq(mentees.isMentee, true, "Is not mentee: false");
        assertEq(mentees.menteesAddress, mentee1, "Incorrect menteesAddress");
        assertEq(mentees.name, "TestMentee1", "Incorrect name");
        assertEq(mentees.expertise, "Test Mentee1 Expertise", "Incorrect expertise");
        assertEq(mentees.yearsOfExperience, 0, "Incorect years of exp");
        assertEq(mentees.bioMessage, "Test Mentee1 Bio", "Incorrect bio message");
        assertEq(mentees.hasMentor, false, "should be false initally");
        assertEq(mentees.mentorsAddress, address(0), "Should be address(0) initially");
        assertEq(mentees.menteeHasPlan, false, "Should be false initially");
    }

    function testUpdateMentorInfo() public {
        vm.prank(mentor);
        subm.updateMentorInfo("2 TestMentor", "2 Test Mentor Expertise", 12, "2 Test Mentor Bio");

        SubscriptionManager.Mentor memory mentors = subm.getMentorProfile(mentor);

        assertEq(mentors.isMentor, true, "Is not Mentor: False");
        assertEq(mentors.mentorsAddress, mentor, "Incorrect mentorsAddress");
        assertEq(mentors.name, "2 TestMentor", "Incorrect name");
        assertEq(mentors.expertise, "2 Test Mentor Expertise", "Incorrect Expertise");
        assertEq(mentors.yearsOfExperience, 12, "Incorrect years of exp");
        assertEq(mentors.bioMessage, "2 Test Mentor Bio", "Incorrect Mentor Bio");
        assertEq(mentors.OpenSlotsForMentees.length, 0, "Open slots count is 10, but current length of array is 0");
    }

    function testUpdateMenteeInfo() public {
        vm.prank(mentee1);
        subm.updateMenteeInfo("2 TestMentee", "2 Test Mentee Expertise", 2, "2 Test Mentee Bio");

        SubscriptionManager.Mentee memory mentees = subm.getMenteeProfile(mentee1);


        assertEq(mentees.isMentee, true, "Is not mentee: false");
        assertEq(mentees.menteesAddress, mentee1, "Incorrect menteesAddress");
        assertEq(mentees.name, "2 TestMentee", "Incorrect name");
        assertEq(mentees.expertise, "2 Test Mentee Expertise", "Incorrect expertise");
        assertEq(mentees.yearsOfExperience, 2, "Incorect years of exp");
        assertEq(mentees.bioMessage, "2 Test Mentee Bio", "Incorrect bio message");
        assertEq(mentees.hasMentor, false, "should be false initally");
        assertEq(mentees.mentorsAddress, address(0), "Should be address(0) initially");
        assertEq(mentees.menteeHasPlan, false, "Should be false initially");
    }

    function testCallconfirmMentee() public returns(bool) {
        vm.prank(mentor);
        subm.confirmMentee(mentee1);

        SubscriptionManager.Mentor memory mentors = subm.getMentorProfile(mentor);
        uint256 expectedLength = 1;

        console.log("mentors.OpenSlotsForMentees.length", mentors.OpenSlotsForMentees.length);
        assertEq(mentors.OpenSlotsForMentees.length, expectedLength, "array length is not as expected");
        
        bool result = false;
        for (uint256 i = 0; i < subm.getOpenSlotsForMenteesArray(mentor).length; i++) {
            if (subm.getOpenSlotsForMenteesArray(mentor)[i] == mentee1) {
                result = true;
                break;
            }
        }
        return result;
    }

    // testCreatPlan - partial with setUp()
    function testCreatPlan() public view {
        console.log("SubscriptionManager addr - ", address(subm));
        console.log("test contract addr - ", address(this));

        // Check if the correct number of plans were created
        uint256 expectedNumberOfPlans = 3;
        assertEq(subm.nextPlanId(), expectedNumberOfPlans, "Incorrect number of plans created");

        // Iterate through the plans and verify their properties
        for (uint256 i = 0; i < subm.nextPlanId(); i++) {
            SubscriptionManager.Plan memory plan = subm.getPlanWithId(i);

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
        subm.createPlan(address(0), 100, 30 days);
    }

    function testCreatePlanWithInvalidInput2() public {
        vm.expectRevert("amount needs to be > 0");
        subm.createPlan(address(beth), 0, 30 days);
    }

    function testCreatePlanWithInvalidInput3() public {
        vm.expectRevert("frequency needs to be > 0");
        subm.createPlan(address(beth), 100, 0); 
    } 

    // testDeletePlan 
    function testDeletePlan() public {
        SubscriptionManager.Plan memory plan = subm.getPlanWithId(0);
        console.log("Plan 0", plan.token, plan.amount, plan.frequency);

        uint256 testPlanId = 0; // out of 0,1,2
        subm.deletePlan(testPlanId);

        uint256 expectedNumberOfPlans = 2;
        assertEq(subm.nextPlanId(), expectedNumberOfPlans, "Incorrect number of plans created");
    }

    // testCreateMentorshipAndBuySubscription
    function testCreateMentorshipAndBuySubscription() public {
        // Create mentorship and buy subscription for multiple mentees
        for (uint256 i = 0; i <= 2; i++) {
            address mentee = i == 0 ? mentee1 : i == 1 ? mentee2 : mentee3;
            ERC20Mock token = i == 0 ? beth : i == 1 ? weth : meth;
            uint256 price = i == 0 ? 100 : i == 1 ? 600 : 1200;

            // console.log("mentee", mentee);

            // SET UP
            vm.prank(mentor);
            subm.confirmMentee(mentee);

            uint256 initialMenteeBalance = testBalances[mentee];
            uint256 initialMentorBalance = testBalances[mentor];
            uint256 initialWeb3DevMentorTestBalance = testBalances[address(this)];

            // console.log("initialMenteeBalance", initialMenteeBalance);
            // console.log("initialMentorBalance", initialMentorBalance);
            // console.log("initialWeb3DevMentorTestBalance", initialWeb3DevMentorTestBalance);

            vm.prank(mentee);
            token.approve(address(subm), price);

            // Check if the allowance was set correctly
            assertEq(token.allowance(mentee, address(subm)), price, "Allowance not set correctly");
            
            // step1 - call CreateMentorshipAndBuySubscription
            vm.prank(mentee);
            subm.CreateMentorshipAndBuySubscription(mentee, mentor, i);

            // SubscriptionManager.Mentor memory mentors = subm.getMentorProfile(mentor);
            SubscriptionManager.Mentee memory mentees = subm.getMenteeProfile(mentee);
            SubscriptionManager.Subscription memory subscription = subm.getSubscription(mentee, i);
            // console.log("mentee", mentee);

            // // step2 - check if mentee's .hasMentor = true
            assertEq(mentees.hasMentor, true, "mentee.hasMentor should be true");

            // // step3 - check if mentee's mentorsAddress = mentor
            assertEq(mentees.mentorsAddress, mentor, "mentee's mentorsAddress is not expected mentor's address");

            // step5 - check for successful payment transfers
            // console.log() balances of mentor and subm before
            // console.log() balances of mentor and subm after
            // Get final balances
            uint256 finalMenteeBalance = testBalances[mentee] - price;
            uint256 finalMentorBalance = testBalances[mentor] + (price * 8 / 10);
            uint256 finalWeb3DevMentorTestBalance = testBalances[address(this)] + (price * 2 / 10);

            // console.log("finalMenteeBalance", finalMenteeBalance);
            // console.log("finalMentorBalance", finalMentorBalance);
            // console.log("finalWeb3DevMentorTestBalance", finalWeb3DevMentorTestBalance);

            // Verify balances changed as expected
            assertEq(finalMenteeBalance, initialMenteeBalance - price, "Mentee didn't spend token");
            assertEq(finalMentorBalance, initialMentorBalance + (price * 8 / 10), "Mentor didn't receive token");
            assertEq(finalWeb3DevMentorTestBalance, initialWeb3DevMentorTestBalance + (price * 2 / 10), "Web3DevMentorTest / merchant didn't recive token");

            // step6 - check is subscription was successfully created and added to subscriptions array 
            assertEq(subscription.subscriber, mentee, "not expected subscriber address"); // expected subscriber address
            assertEq(subscription.mentor, mentor, "not expected mentor address"); // expected mentor
            assertEq(subscription.start, 1, "not expected start time"); // expected start
            uint256 expectedNextPayment = i == 0 ? 30 days : i == 1 ? 180 days : 365 days;
            assertEq(subscription.nextPayment, expectedNextPayment + 1 seconds, "not expected nextPayment"); // expected nextPayment
        }
    }

    // testEndMentorshipAndCancelSubscription
    function testEndMentorshipAndCancelSubscription() public {
        // SET UP for this test will just be calling the testCreateMentorshipAndBuySubscription test.
        testCreateMentorshipAndBuySubscription();

        for (uint256 i = 0; i <= 2; i++) {
            address mentee = i == 0 ? mentee1 : i == 1 ? mentee2 : mentee3;

            // Secondly call the EndMentorshipAndCancelSubscription function.
            // vm.prank(mentee); // both mentee and mentor can call this function.
            vm.prank(mentor); // both mentee and mentor can call this function.
            subm.EndMentorshipAndCancelSubscription(i, mentee, mentor);
            
            // Thirdly check if the changes were reversed.
            SubscriptionManager.Mentee memory mentees = subm.getMenteeProfile(mentee);
            SubscriptionManager.Subscription memory subscription = subm.getSubscription(mentee, i);
            assertEq(subscription.start, 0, "subscription was not removed");
            
            assertEq(mentees.hasMentor, false, "mentee.hasMentor should be false");
            assertEq(mentees.mentorsAddress, address(0), "mentee's mentorsAddress is not expected address(0)");

            bool IsMenteeInArray = subm.getCheckIfMenteesAddressInOpenSlotsForMenteesArray(mentor, mentee);
            assertEq(IsMenteeInArray, false, "mentee has not been removed from OpenSlotsForMenteesArray");

            uint256 expectedCount = 3 - (i + 1); // Adjusted calculation
            uint256 menteeCountOfMentor = subm.getMenteeCountOfMentor(mentor);
            assertEq(menteeCountOfMentor, expectedCount, "menteeCountOfMentor is not 0 as expected");
        }
    }

    function testPayRecurring() public {}
}