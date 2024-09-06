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
    
    mapping(address => Mentor) public mentors;
    uint256 public constant MAX_MENTEES_PER_MENTOR = 10;

    function createMentorAccount(
        string memory name,
        string memory expertise,
        uint256 yearsOfExperience,
        string memory bioMessage
    ) public {
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
    }

    modifier onlyMentor() {
        require(msg.sender == mentors[msg.sender].mentorsAddress, "Caller must be mentor");
        _;
    }    

    function confirmMentee(address menteesAddress) public onlyMentor {
        // mentor will pass in mentee’s address to be confirmed.
        require(msg.sender == mentors[msg.sender].mentorsAddress, "Caller must be mentor");
        require(mentors[msg.sender].OpenSlotsForMentees.length < MAX_MENTEES_PER_MENTOR, "No slots available");

        mentors[msg.sender].OpenSlotsForMentees.push(menteesAddress);
    }

    // Function RemoveMentee onlyMentor // <-- still add.

    //////////////////////////
    ///// GETTER FUNCTIONS ///
    //////////////////////////

    // might not be needed
    function getMentorsAddressForSharedPayment(address mentorsAddress) public view returns (address) {
        //gets mentor's address to transfers money from the purchase of a subscription by a mentee to the mentor. // or at least thier cut of the money.
        return mentors[mentorsAddress].mentorsAddress;
    }

    function getMenteeCount(address mentorsAddress) public view returns (uint256) {
        return mentors[mentorsAddress].OpenSlotsForMentees.length;
    }

    function getOpenSlotsForMenteesArray(address mentorsAddress) public view returns (address[] memory) {
        return mentors[mentorsAddress].OpenSlotsForMentees;
    }

    // can create more getter functions to get more info about mentees.
}
