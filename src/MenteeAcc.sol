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

    mapping(address => Mentee) internal mentees;

    function createMenteeAccount(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) internal {
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

    function getMentorsAddress(address menteesAddress) internal view returns (address) {
        require(mentees[menteesAddress].hasMentor == true, "Mentee does not have mentor... yet");
        return mentees[menteesAddress].mentorsAddress;
    }
}
