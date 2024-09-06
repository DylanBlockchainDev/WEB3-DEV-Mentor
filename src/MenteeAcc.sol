// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract MenteeAcc {
    struct Mentee {
        bool isMentee; // default true.
        address menteesAddress; // address of mentor.
        string name; // name of mentor.
        string expertise; // specific field of expertise.
        uint256 yearsOfExperience; // number of years of experience.
        string bioMessage; //a message or description of mentor and or value provided by mentor.
        bool hasMentor; // (default value false, but set to true when mentor is acquired)
        address mentorsAddress; // should get filled in when mentee buys subscription.
        bool menteeHasPlan;
    }

    mapping(address => Mentee) public mentees;

    function createMenteeAccount(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) public {
        //creates mentee account suing struct and updating mapping;
        mentees[msg.sender] = Mentee({
            isMentee: true,
            menteesAddress: msg.sender,
            name: name,
            expertise: expertise,
            yearsOfExperience: yearsOfExperience,
            bioMessage: bioMessage,
            hasMentor: false,
            mentorsAddress: address(0), //zero address initialized
            menteeHasPlan: false
        });
    }

    ////////////////////////////
    ///// GETTER FUNCTIONS /////
    //////////////////////////// 

    function getMentorsAddress(address menteesAddress) public view returns (address) {
        require(mentees[menteesAddress].hasMentor == true, "Mentee does not have mentor... yet");
        return mentees[menteesAddress].mentorsAddress;
    }

    // this function should be done in the SubscriptionManager contract. Because it will be a part of creating mentorship func which is needed right before mentee buys subscription plan
    // function setMentorAddress(address mentorAddress) public {
    //     require(mentees[msg.sender].hasMentor == false, "Mentee already has a mentor");
    //     mentees[msg.sender].mentorsAddress = mentorAddress;
    //     mentees[msg.sender].hasMentor = true;
    // }

    // mentee’s wallet/account;
    // function fundMenteesWallet() {
    //     // funds mentee’s wallet/account();
    // }
}
