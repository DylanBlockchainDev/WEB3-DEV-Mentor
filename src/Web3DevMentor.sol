// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

import {Ownable} from "../lib/openzeppelin-contracts/contracts/access/Ownable.sol";
import {ReentrancyGuard} from "../lib/openzeppelin-contracts/contracts/utils/ReentrancyGuard.sol";

contract Web3DevMentor {
// 1. call create plan function, (figure out how I'm going to create 3 plans, probaly dynamicly after deployment).
// 2. call createMentorship and buySubscription funcs on order as one, with required checks/conditions.
// 3. call pay function.
// 4. call cancelSubscriptionAndEndMentorship function.
// 5. Apply access control where needed
// 6. add events where needed

// creates  subscript plans code
function createSubPlan(address token, uint256 amount, uint256 frequency) external {
    createPlane(token, amount, frequency);
}

// //calls the menteeBuysSubscription(uint256 amount) & createMentorship(“mentor’s address)  functions
function BuySubscriptionAndCreateMentorship( /* amount, mentorsAddress */ ) public /*someOnlyMenteeModifier()*/ {
    // createMentorship(mentors address);
    // if(createMentorship != true) revert;
    // menteeBuysSubscription(amount);
}

// payment logic takes place here, this is where the finer details happen such as when the payment happens and how much should be paid, this depends on the specific plan. That will be created on a separate contract.
// Payment Logic!!!;buy the subscription, and split money. call the payMentor() function;
}
