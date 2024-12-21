// SPDX-License-Identifier: MIT
pragma solidity 0.8.28;

contract FlightManagement {

    mapping(uint256 => string) public flightNames; 
    mapping(uint256 => uint256) public seatsAvailable;
    mapping(uint256 => uint256) public pricePerSeat;
    mapping(uint256 => bool) public isActive;

    mapping(address => mapping(uint256 => uint256)) public bookings;
    mapping(address => uint256) public balances;

    uint256 public flightCounter;

    address public owner;

    event FlightAdded(uint256 flightId, string flightName, uint256 seatsAvailable, uint256 pricePerSeat);
    event SeatBooked(address indexed user, uint256 flightId, uint256 seatsBooked);
    event BookingCancelled(address indexed user, uint256 flightId, uint256 seatsCancelled);

    constructor() {
        owner = msg.sender;
    }

    function addFlight(string memory _flightName, uint256 _seatsAvailable, uint256 _pricePerSeat) public {
        if (bytes(_flightName).length == 0) {
            revert("Flight name cannot be empty");
        }
        require(_seatsAvailable > 0, "Seats available must be greater than zero");
        require(_pricePerSeat > 0, "Price per seat must be greater than zero");

        flightCounter++;
        flightNames[flightCounter] = _flightName;
        seatsAvailable[flightCounter] = _seatsAvailable;
        pricePerSeat[flightCounter] = _pricePerSeat;
        isActive[flightCounter] = true;

        assert(bytes(flightNames[flightCounter]).length > 0);
        require(seatsAvailable[flightCounter] > 0, "Seats are not available Yet");
        assert(pricePerSeat[flightCounter] > 0);
        assert(isActive[flightCounter]);

        emit FlightAdded(flightCounter, _flightName, _seatsAvailable, _pricePerSeat);
    }

    function bookSeat(uint256 _flightId, uint256 _seats) public {
        require(isActive[_flightId], "Flight is not active");
        require(_seats > 0, "Number of seats must be greater than zero");
        if (seatsAvailable[_flightId] < _seats) {
            revert("Not enough seats available");
        }

        uint256 totalCost = _seats * pricePerSeat[_flightId];
        require(balances[msg.sender] >= totalCost, "Insufficient balance to book seats");

        seatsAvailable[_flightId] -= _seats;
        bookings[msg.sender][_flightId] += _seats;
        balances[msg.sender] -= totalCost;

        assert(seatsAvailable[_flightId] >= 0);
        assert(balances[msg.sender] >= 0);

        emit SeatBooked(msg.sender, _flightId, _seats);
    }

    function cancelBooking(uint256 _flightId, uint256 _seats) public {
        require(_seats > 0, "Number of seats must be greater than zero");

        assert(bookings[msg.sender][_flightId] < _seats);

        require(isActive[_flightId], "Flight is not active");

        bookings[msg.sender][_flightId] -= _seats;
        seatsAvailable[_flightId] += _seats;

        uint256 refundAmount = _seats * pricePerSeat[_flightId];
        balances[msg.sender] += refundAmount;

        
        assert(balances[msg.sender] >= 0);

        emit BookingCancelled(msg.sender, _flightId, _seats);
    }

    function depositFunds() public payable {
        
        if (msg.value == 0) {
            revert("Deposit amount must be greater than zero");
        }

        balances[msg.sender] += msg.value;
        assert(balances[msg.sender] >= msg.value);
    }

    function withdrawFunds(uint256 amount) public {
        
        require(amount > 0, "Withdrawal amount must be greater than zero");
        if (balances[msg.sender] < amount) {
            revert("Insufficient balance to withdraw");
        }

        balances[msg.sender] -= amount;
        (bool success, ) = msg.sender.call{value: amount}("");
        assert(success); // Ensures the withdrawal was successful
        assert(balances[msg.sender] >= 0);
    }

    function deactivateFlight(uint256 _flightId) public {
        if (!isActive[_flightId]) {
            revert("Flight is already inactive");
        }

        isActive[_flightId] = false;

        assert(!isActive[_flightId]);
    }

    function activateFlight(uint256 _flightId) public {
        if (isActive[_flightId]) {
            revert("Flight is already active");
        }

        isActive[_flightId] = true;

        assert(isActive[_flightId]);
    }

    receive() external payable {
        revert("Direct payments not allowed");
    }
}
