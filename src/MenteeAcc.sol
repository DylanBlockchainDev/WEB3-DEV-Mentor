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
    uint256 public totalMentees;

    function createMenteeAccount(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) external {
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

        totalMentees++;
    }

    modifier onlyMentee() {
        require(msg.sender == mentees[msg.sender].menteesAddress, "Caller must be mentee");
        _;
    }

    function updateMenteeInfo(
        string memory newName,
        string memory newExpertise,
        uint256 newYearsOfExperience,
        string memory newBioMessage
    ) external onlyMentee {
        // might remove, shouldn't have to have a mentor in order to update info.
        // require(!mentees[msg.sender].hasMentor, "Mentee does not have mentor yet");

        mentees[msg.sender] = Mentee({
            isMentee: true,
            menteesAddress: msg.sender,
            name: newName,
            expertise: newExpertise,
            yearsOfExperience: newYearsOfExperience,
            bioMessage: newBioMessage,
            hasMentor: mentees[msg.sender].hasMentor,
            mentorsAddress: mentees[msg.sender].mentorsAddress,
            menteeHasPlan: mentees[msg.sender].menteeHasPlan
        });
    }
}
