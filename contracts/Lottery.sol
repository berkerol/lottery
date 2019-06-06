pragma solidity ^0.5.0;

contract Lottery {

    struct Ticket {
        address owner;// Address of user who submits the hash of the random number and pays 2 ethers
        uint256 hash;// Hash of the random number
        bool revealed;// Whether user revealed the random number or not
    }

    Ticket[] private submittedTickets;// Tickets that are created by submitting the hash of the random number
    uint256[] private revealedTicketNumbers;// Ticket numbers that are revealed by submitting the random number
    uint256[] private revealedTicketNumbersLastFour;// Last 4 digits of ticket numbers that are revealed
    uint256[] private revealedTicketNumbersLastThree;// Last 3 digits of ticket numbers that are revealed
    uint256[] private revealedTicketNumbersLastTwo;// Last 2 digits of ticket numbers that are revealed
    mapping(uint256 => Ticket) private revealedTickets;// Tickets whose random numbers are revealed
    mapping(uint256 => Ticket[]) private revealedTicketsLastFour;
    mapping(uint256 => Ticket[]) private revealedTicketsLastThree;
    mapping(uint256 => Ticket[]) private revealedTicketsLastTwo;
    mapping(address => uint256) private prizes;// Money won from the lottery for each user

    uint256[23] private prizeAmounts;// Amount of money that can be gained for each place
    uint256[23] private winnerNumbers;// Generated random numbers that won

    uint256 private xor = 0;// Generated random number that determines winner numbers
    uint256 private fundsCollected = 0;// Money that is collected from selling tickets
    uint256 private totalPrizeAmount = 0;// Money that is required to pay for all the prizes

    uint256 private submissionStage = 1 days;// Duration of submission stage
    uint256 private revealStage = 1 days;// Duration of reveal stage

    uint256 private roundStart;// Starting time of round and submission stage
    uint256 private roundMiddle;// Ending time of submission stage and starting time of reveal stage
    uint256 private roundEnd;// Ending time of round and reveal stage

    address private charity;// Address of charity to send the excess money (funds - prizes)

    event SubmittedTicket(uint256 ticketNumber);// Event to inform user about ticket number

    constructor(address charity_) public {
        // Initialize submission and reveal stages
        roundStart = now;
        roundMiddle = roundStart + submissionStage;
        roundEnd = roundMiddle + revealStage;
        charity = charity_;
        prizeAmounts[0] = 50000;
        prizeAmounts[1] = 25000;
        prizeAmounts[2] = 10000;
        prizeAmounts[3] = 7500;
        prizeAmounts[4] = 5000;
        prizeAmounts[5] = 2500;
        prizeAmounts[6] = 1000;
        prizeAmounts[7] = 900;
        prizeAmounts[8] = 800;
        prizeAmounts[9] = 700;
        prizeAmounts[10] = 600;
        prizeAmounts[11] = 500;
        prizeAmounts[12] = 450;
        prizeAmounts[13] = 400;
        prizeAmounts[14] = 350;
        prizeAmounts[15] = 300;
        prizeAmounts[16] = 250;
        prizeAmounts[17] = 200;
        prizeAmounts[18] = 150;
        prizeAmounts[19] = 100;
        prizeAmounts[20] = 40;
        prizeAmounts[21] = 10;
        prizeAmounts[22] = 4;
    }

    // Checks whether the current time is the submission stage
    modifier inSubmission() {
        require(now >= roundStart && now <= roundMiddle, "Not in the submission stage!");
        _;
    }

     // Checks whether the current time is the reveal stage
    modifier inReveal() {
        require(now >= roundMiddle && now <= roundEnd, "Not in the reveal stage!");
        _;
    }

    // Checks whether the current time is after the end of the round, if so then distribute prizes and reset tickets
    modifier checkEnd() {
        if (now > roundEnd) {
            reset();
        }
        _;
    }

    // Takes the hash of the random number as parameter, creates the ticket and emits an event for ticket number
    function submit(uint256 hash) public payable checkEnd inSubmission {
        require(msg.value >= 2 ether, "Not enough money to participate!");
        if (msg.value > 2 ether) {
            require(msg.sender.send(msg.value - 2 ether), "We couldn't send your excess money!");
        }

        // Increase funds collected by 2
        fundsCollected += 2;

        // Create a new ticket
        Ticket memory ticket = Ticket({
            owner: msg.sender,
            hash: hash,
            revealed: false
        });

        submittedTickets.push(ticket);
        delete ticket;

        // Inform user about ticket number
        emit SubmittedTicket(submittedTickets.length - 1);
    }

    // Takes the revealed random number and given ticket number as parameter and generates new random numbers for winner numbers
    function reveal(uint256 randomNumber, uint256 ticketNumber) public checkEnd inReveal {
        // Check if the ticket number is valid
        require(ticketNumber < submittedTickets.length, "Ticket does not exist!");

        // Make other necessary controls
        Ticket memory ticket = submittedTickets[ticketNumber];
        require(ticket.owner == msg.sender, "Ticket is not submitted by you!");
        require(ticket.hash == hash(randomNumber), "Ticket random number is not correct!");
        require(!ticket.revealed, "Ticket is already revealed!");

        // Mark ticket as revealed
        ticket.revealed = true;

        // Store revealed tickets
        submittedTickets[ticketNumber] = ticket;
        revealedTickets[ticketNumber] = ticket;
        revealedTicketsLastFour[ticketNumber % 10000].push(ticket);
        revealedTicketsLastThree[ticketNumber % 1000].push(ticket);
        revealedTicketsLastTwo[ticketNumber % 100].push(ticket);
        revealedTicketNumbers.push(ticketNumber);
        revealedTicketNumbersLastFour.push(ticketNumber % 10000);
        revealedTicketNumbersLastThree.push(ticketNumber % 1000);
        revealedTicketNumbersLastTwo.push(ticketNumber % 100);

        // Xor with random number to generate a random number
        xor ^= randomNumber;

        totalPrizeAmount = 0;
        // Determine 20 5-digits random numbers and calculate total prize amount
        for (uint256 i = 0; i < 20; i++) {
            winnerNumbers[i] = xor % 100000;
            ticket = revealedTickets[winnerNumbers[i]];
            if (ticket.revealed) {
                totalPrizeAmount += prizeAmounts[i];
            }
            xor = hash(xor);
        }
        // Determine 1 4-digit random number and calculate total prize amount
        winnerNumbers[20] = xor % 10000;
        Ticket[] memory lastTickets = revealedTicketsLastFour[winnerNumbers[20]];
        for (uint256 i = 0; i < lastTickets.length; i++) {
            ticket = lastTickets[i];
            if (ticket.revealed) {
                totalPrizeAmount += prizeAmounts[20];
            }
        }
        xor = hash(xor);
        // Determine 1 3-digit random number and calculate total prize amount
        winnerNumbers[21] = xor % 1000;
        lastTickets = revealedTicketsLastThree[winnerNumbers[21]];
        for (uint256 i = 0; i < lastTickets.length; i++) {
            ticket = lastTickets[i];
            if (ticket.revealed) {
                totalPrizeAmount += prizeAmounts[21];
            }
        }
        xor = hash(xor);
        // Determine 1 2-digit random number and calculate total prize amount
        winnerNumbers[22] = xor % 100;
        lastTickets = revealedTicketsLastTwo[winnerNumbers[22]];
        for (uint256 i = 0; i < lastTickets.length; i++) {
            ticket = lastTickets[i];
            if (ticket.revealed) {
                totalPrizeAmount += prizeAmounts[22];
            }
        }
        delete lastTickets;
        delete ticket;
    }

    // Sends users the money that they won
    function withdraw() public checkEnd {
        if (prizes[msg.sender] > 0) {
            require(msg.sender.send(prizes[msg.sender] * 1 ether), "We couldn't send your prize!");
            prizes[msg.sender] = 0;
        }
    }

    // Distribute prizes according to the determined random numbers, delete tickets and renew stages
    function reset() private {
        // If enough funds are collected, distribute prizes
        if (fundsCollected >= totalPrizeAmount) {
            Ticket memory ticket;
            // Distribute prizes for 20 5-digits numbers
            for (uint256 i = 0; i < 20; i++) {
                ticket = revealedTickets[winnerNumbers[i]];
                if (ticket.revealed) {
                    prizes[ticket.owner] += prizeAmounts[i];
                }
            }
            // Distribute prizes for 1 4-digit number
            Ticket[] memory lastTickets = revealedTicketsLastFour[winnerNumbers[20]];
            for (uint256 i = 0; i < lastTickets.length; i++) {
                ticket = lastTickets[i];
                if (ticket.revealed) {
                    prizes[ticket.owner] += prizeAmounts[20];
                }
            }
            // Distribute prizes for 1 3-digit number
            lastTickets = revealedTicketsLastThree[winnerNumbers[21]];
            for (uint256 i = 0; i < lastTickets.length; i++) {
                ticket = lastTickets[i];
                if (ticket.revealed) {
                    prizes[ticket.owner] += prizeAmounts[21];
                }
            }
            // Distribute prizes for 1 2-digit number
            lastTickets = revealedTicketsLastTwo[winnerNumbers[22]];
            for (uint256 i = 0; i < lastTickets.length; i++) {
                ticket = lastTickets[i];
                if (ticket.revealed) {
                    prizes[ticket.owner] += prizeAmounts[22];
                }
            }
            prizes[charity] += fundsCollected - totalPrizeAmount;
            delete lastTickets;
            delete ticket;
        } else {// If not enough funds are collected, refund cost of tickets (2 ethers)
            for (uint256 i = 0; i < revealedTicketNumbers.length; i++) {
                prizes[revealedTickets[revealedTicketNumbers[i]].owner] += 2;
            }
        }
        // Delete tickets and renew stages
        delete submittedTickets;
        for (uint256 i = 0; i < revealedTicketNumbers.length; i++) {
            delete revealedTickets[revealedTicketNumbers[i]];
        }
        delete revealedTicketNumbers;
        for (uint256 i = 0; i < revealedTicketNumbersLastFour.length; i++) {
            delete revealedTicketsLastFour[revealedTicketNumbersLastFour[i]];
        }
        delete revealedTicketNumbersLastFour;
        for (uint256 i = 0; i < revealedTicketNumbersLastThree.length; i++) {
            delete revealedTicketsLastThree[revealedTicketNumbersLastThree[i]];
        }
        delete revealedTicketNumbersLastThree;
        for (uint256 i = 0; i < revealedTicketNumbersLastTwo.length; i++) {
            delete revealedTicketsLastTwo[revealedTicketNumbersLastTwo[i]];
        }
        delete revealedTicketNumbersLastTwo;
        delete winnerNumbers;
        xor = 0;
        fundsCollected = 0;
        totalPrizeAmount = 0;
        roundStart = now;
        roundMiddle = roundStart + submissionStage;
        roundEnd = roundMiddle + revealStage;
    }

    // Returns a string which explains the current stage
    function getStage() public view returns(bytes32) {
        if (now >= roundStart && now <= roundMiddle) {
            return "Submission Stage";
        } else if (now >= roundMiddle && now <= roundEnd) {
            return "Reveal Stage";
        } else {
            return "Ended, Ready to Start";
        }
    }

    // Takes the random number as parameter and returns the keccak256 hash of it
    function hash(uint256 number) public view returns(uint256) {
        return uint256(keccak256(abi.encodePacked(number, msg.sender)));
    }
}
