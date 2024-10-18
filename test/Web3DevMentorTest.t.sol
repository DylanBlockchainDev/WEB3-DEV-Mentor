// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Test, console} from "../lib/forge-std/src/Test.sol";
import {SubscriptionManager} from "../src/SubscriptionManager.sol";
import {ERC20Mock} from "lib/openzeppelin-contracts/contracts/mocks/token/ERC20Mock.sol";

contract Web3DevMentorTest is Test {
    SubscriptionManager public subm;
    address public mentor;
    address public mentee;
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

        console.log("SubscriptionManager address", address(subm));
        console.log("weth address", address(weth));

        // Create mock SubPlans
        // have to create mock token.
        subm.createPlan(address(beth), 100, 30 days);
        subm.createPlan(address(weth), 600, 180 days);
        subm.createPlan(address(meth), 1200, 365 days);

        // Create mock accounts
        mentor = address(1);
        mentee = address(2);
        
        testBalances[address(this)] = TESTING_BALANCE;
        testBalances[mentor] = TESTING_BALANCE;
        testBalances[mentee] = TESTING_BALANCE;

        vm.deal(address(this), TESTING_BALANCE);
        vm.deal(mentor, TESTING_BALANCE);
        vm.deal(mentee, TESTING_BALANCE);

        vm.prank(mentor);
        subm.createMentorAccount("TestMentor", "Test Mentor Expertise", 10, "Test Mentor Bio");

        vm.prank(mentee);
        subm.createMenteeAccount("TestMentee", "Test Mentee Expertise", 0, "Test Mentee Bio");
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

        SubscriptionManager.Mentee memory mentees = subm.getMenteeProfile(mentee);


        assertEq(mentees.isMentee, true, "Is not mentee: false");
        assertEq(mentees.menteesAddress, mentee, "Incorrect menteesAddress");
        assertEq(mentees.name, "TestMentee", "Incorrect name");
        assertEq(mentees.expertise, "Test Mentee Expertise", "Incorrect expertise");
        assertEq(mentees.yearsOfExperience, 0, "Incorect years of exp");
        assertEq(mentees.bioMessage, "Test Mentee Bio", "Incorrect bio message");
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
        vm.prank(mentee);
        subm.updateMenteeInfo("2 TestMentee", "2 Test Mentee Expertise", 2, "2 Test Mentee Bio");

        SubscriptionManager.Mentee memory mentees = subm.getMenteeProfile(mentee);


        assertEq(mentees.isMentee, true, "Is not mentee: false");
        assertEq(mentees.menteesAddress, mentee, "Incorrect menteesAddress");
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
        subm.confirmMentee(mentee);

        SubscriptionManager.Mentor memory mentors = subm.getMentorProfile(mentor);
        uint256 expectedLength = 1;

        console.log("mentors.OpenSlotsForMentees.length", mentors.OpenSlotsForMentees.length);
        assertEq(mentors.OpenSlotsForMentees.length, expectedLength, "array length is not as expected");
        
        bool result = false;
        for (uint256 i = 0; i < subm.getOpenSlotsForMenteesArray(mentor).length; i++) {
            if (subm.getOpenSlotsForMenteesArray(mentor)[i] == mentee) {
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
        // SET UP
        vm.prank(mentor);
        subm.confirmMentee(mentee);

        uint256 planId1 = 1; // we will be using plan 1 for the test
        SubscriptionManager.Mentor memory mentors = subm.getMentorProfile(mentor);
        SubscriptionManager.Mentee memory mentees = subm.getMenteeProfile(mentee);
        SubscriptionManager.Subscription memory subscription = subm.getSubscription(mentee, planId1);

        console.log("mentor info", mentors.name);
        console.log("mentee info", mentees.hasMentor);
        

        uint256 initialMenteeBalance = testBalances[mentee];
        uint256 initialMentorBalance = testBalances[mentor];
        uint256 initialWeb3DevMentorTestBalance = testBalances[address(this)];

        console.log("initialMenteeBalance", initialMenteeBalance);
        console.log("initialMentorBalance", initialMentorBalance);
        console.log("initialWeb3DevMentorTestBalance", initialWeb3DevMentorTestBalance);
        
        // step1 - call CreateMentorshipAndBuySubscription
        vm.prank(mentee);
        subm.CreateMentorshipAndBuySubscription(mentee, mentor, planId1);

        // // step2 - check if mentee's .hasMentor = true
        assertEq(mentees.hasMentor, true, "mentee.hasMentor should be true");

        // // step3 - check if mentee's mentorsAddress = mentor
        assertEq(mentees.mentorsAddress, mentor, "mentee's mentorsAddress is not expected mentor's address");

        // step5 - check for successful payment transfers
        // accessories - console.log() balances of mentor and subm before
        // accessories - console.log() balances of mentor and subm after
        // Get final balances
        uint256 finalMenteeBalance = testBalances[mentee];
        uint256 finalMentorBalance = testBalances[mentor];
        uint256 finalWeb3DevMentorTestBalance = testBalances[address(this)];

        // Verify balances changed as expected
        assertEq(finalMenteeBalance, initialMenteeBalance - 600, "Mentee didn't spend WETH");
        assertEq(finalMentorBalance, initialMentorBalance + 480, "Mentor didn't receive WETH");
        assertEq(finalWeb3DevMentorTestBalance, initialinitialWeb3DevMentorTestBalance + 120, "Web3DevMentorTest / merchant didn't recive WETH");

        // LATER!!!
        // step6 - check is subscription was successfully created and added to subscriptions array 
        assertEq(subscription.subscriber, mentee, "not expected subscriber address"); // expected subscriber address
        // assertEq(); // expected mentor
        // assertEq(); // expected start
        // assertEq(); // expected nextPayment
    }

    // testEndMentorshipAndCancelSubscription
}