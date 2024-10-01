// SPDX-License-Identifier: MIT
pragma solidity 0.8.20;

contract MentorAcc {
    struct Mentor {
        bool isMentor; // default true.
        address mentorsAddress; // address of mentor.
        string name; // name of mentor.
        string expertise; // specific field of expertise.
        uint256 yearsOfExperience; // number of years of experience.
        string bioMessage; //a message or description of mentor and or value provided by mentor.
        address[] OpenSlotsForMentees; // each mentor is limited to max 10 mentees.
    }

    mapping(address => Mentor) internal mentors;
    uint256 internal constant MAX_MENTEES_PER_MENTOR = 10;
    uint256 public totalMentors;

    function createMentorAccount(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) internal {
        // creates mentor account suing struct and updating mapping;
        require(msg.sender != address(0), "address cannot be null");
        require(mentors[msg.sender].isMentor == false, "this address has already been used to create Mentor account");

        mentors[msg.sender] = Mentor({
            isMentor: true,
            mentorsAddress: msg.sender,
            name: name,
            expertise: expertise,
            yearsOfExperience: yearsOfExperience,
            bioMessage: bioMessage,
            OpenSlotsForMentees: new address[](MAX_MENTEES_PER_MENTOR)
        });

        totalMentors++;
    }

    modifier onlyMentor() {
        require(msg.sender == mentors[msg.sender].mentorsAddress, "Caller must be mentor");
        _;
    }

    function confirmMentee(address menteesAddress) internal onlyMentor {
        // mentor will pass in mentee’s address to be confirmed.
        require(msg.sender == mentors[msg.sender].mentorsAddress, "Caller must be mentor");
        require(mentors[msg.sender].OpenSlotsForMentees.length < MAX_MENTEES_PER_MENTOR, "No slots available");

        mentors[msg.sender].OpenSlotsForMentees.push(menteesAddress);
    }

    function updateMentorInfo(
        string memory newName,
        string memory newExpertise,
        uint256 newYearsOfExperience,
        string memory newBioMessage
    ) internal onlyMentor{
        mentors[msg.sender] = Mentor({
            isMentor: true,
            mentorsAddress: msg.sender,
            name: newName,
            expertise: newExpertise,
            yearsOfExperience: newYearsOfExperience,
            bioMessage: newBioMessage,
            OpenSlotsForMentees: mentors[msg.sender].OpenSlotsForMentees
        });
    }

    function getMenteeCountOfMentor(address mentorsAddress) internal view returns (uint256) {
        return mentors[mentorsAddress].OpenSlotsForMentees.length;
    }

    function getOpenSlotsForMenteesArray(address mentorsAddress) public view returns (address[] memory) {
        return mentors[mentorsAddress].OpenSlotsForMentees;
    }

    // can create more getter functions to get more info about mentees.
}
