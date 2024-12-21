// SPDX-License-Identifier: MIT
pragma solidity 0.8.17;

contract FlightManagement {

    mapping(uint256 => string) public flightNames;
    mapping(uint256 => uint256) public seatsAvailable;
    mapping(uint256 => uint256) public pricePerSeat;
    mapping(uint256 => bool) public isActive;
    mapping(address => mapping(uint256 => uint256)) public bookings;
    mapping(address => uint256) public balances;

    uint256 public flightCounter; //0 
    address public owner;

    event FlightAdded(uint256 flightId, string flightName, uint256 seatsAvailable, uint256 pricePerSeat);
    event SeatBooked(address indexed user, uint256 flightId, uint256 seatsBooked);
    event BookingCancelled(address indexed user, uint256 flightId, uint256 seatsCancelled);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function addFlight(string memory _flightName, uint256 _seatsAvailable, uint256 _pricePerSeat) public onlyOwner {
        flightCounter++;
        flightNames[flightCounter] = _flightName;
        seatsAvailable[flightCounter] = _seatsAvailable;
        pricePerSeat[flightCounter] = _pricePerSeat;
        isActive[flightCounter] = true;
        emit FlightAdded(flightCounter, _flightName, _seatsAvailable, _pricePerSeat);
    }

    function bookSeat(uint256 _flightId, uint256 _seats) public {
        require(isActive[_flightId], "Flight not active");
        require(seatsAvailable[_flightId] >= _seats, "Not enough seats");

        uint256 totalCost = _seats * pricePerSeat[_flightId];
        require(balances[msg.sender] >= totalCost, "Insufficient balance");

        seatsAvailable[_flightId] -= _seats;
        bookings[msg.sender][_flightId] += _seats;
        balances[msg.sender] -= totalCost;

        emit SeatBooked(msg.sender, _flightId, _seats);
    }

    function cancelBooking(uint256 _flightId, uint256 _seats) public {
        require(bookings[msg.sender][_flightId] >= _seats, "Not enough booked seats");

        bookings[msg.sender][_flightId] -= _seats;
        seatsAvailable[_flightId] += _seats;
        balances[msg.sender] += _seats * pricePerSeat[_flightId];

        emit BookingCancelled(msg.sender, _flightId, _seats);
    }

    function depositFunds() public payable {
        require(msg.value > 0, "Deposit must be greater than zero");
        balances[msg.sender] += msg.value;
    }

    function deactivateFlight(uint256 _flightId) public onlyOwner {
        isActive[_flightId] = false;
    }

    function activateFlight(uint256 _flightId) public onlyOwner {
        isActive[_flightId] = true;
    }
}
