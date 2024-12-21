# Flight Management - Module 1 Project Submission

This project implements a **Flight Management System** using Solidity. It provides a decentralized platform for managing flight bookings, cancellations, and related financial transactions. The contract allows administrators to manage flights and users to book or cancel seats while maintaining transparency and security through blockchain technology.

## Features
- **Add Flights**: Add new flights with details such as flight name, available seats, and price per seat.
- **Book Seats**: Book seats for a specific flight if enough seats and funds are available.
- **Cancel Bookings**: Cancel booked seats and get a refund for the canceled seats.
- **Manage Funds**: Users can deposit and withdraw funds from their accounts.
- **Activate/Deactivate Flights**: Administrators can activate or deactivate specific flights.

## Smart Contract Details

### Contract Overview
```solidity
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
```

The contract consists of several key functionalities and mappings to manage flights and bookings efficiently. The following mappings are used:
- `flightNames`: Maps flight IDs to their names.
- `seatsAvailable`: Tracks the number of available seats for each flight.
- `pricePerSeat`: Maps flight IDs to the price per seat.
- `isActive`: Indicates whether a flight is active.
- `bookings`: Tracks user bookings by flight ID.
- `balances`: Maintains user balances for payments and refunds.

### Constructor
The contract initializes with the deployer as the owner.

### Functions
#### Public Functions
- **`addFlight(string memory _flightName, uint256 _seatsAvailable, uint256 _pricePerSeat)`**
  - Adds a new flight with specified details.
  - Emits `FlightAdded` event.

- **`bookSeat(uint256 _flightId, uint256 _seats)`**
  - Allows users to book a specified number of seats for a flight.
  - Ensures the user has sufficient balance and seats are available.
  - Emits `SeatBooked` event.

- **`cancelBooking(uint256 _flightId, uint256 _seats)`**
  - Cancels a booking and refunds the user for the canceled seats.
  - Emits `BookingCancelled` event.

- **`depositFunds()`**
  - Allows users to deposit funds to their account.

- **`withdrawFunds(uint256 amount)`**
  - Enables users to withdraw funds from their account.

- **`deactivateFlight(uint256 _flightId)`**
  - Deactivates a specific flight.

- **`activateFlight(uint256 _flightId)`**
  - Reactivates a specific flight.

#### Receive Function
- Prevents direct Ether transfers to the contract.

### Events
- **`FlightAdded(uint256 flightId, string flightName, uint256 seatsAvailable, uint256 pricePerSeat)`**: Triggered when a flight is added.
- **`SeatBooked(address indexed user, uint256 flightId, uint256 seatsBooked)`**: Triggered when a user books seats.
- **`BookingCancelled(address indexed user, uint256 flightId, uint256 seatsCancelled)`**: Triggered when a booking is canceled.

## Security Measures
- **Assertions and Reverts**: Ensure contract integrity by validating state changes.
- **Funds Management**: Implements strict checks for deposit and withdrawal operations.
- **Flight Status Control**: Allows only valid flight operations based on their active/inactive status.

## Usage
1. **Deploy the Contract**: Use a Solidity-compatible Ethereum environment (e.g., Remix) to deploy the contract.
2. **Add Flights**: The owner adds flights with details like name, available seats, and price per seat.
3. **Deposit Funds**: Users deposit funds to their accounts using `depositFunds()`.
4. **Book Seats**: Users book seats for active flights using `bookSeat()`.
5. **Cancel Bookings**: Users cancel bookings using `cancelBooking()`.
6. **Withdraw Funds**: Users can withdraw their remaining balance using `withdrawFunds()`.

## Prerequisites
- Solidity compiler version `^0.8.28`.
- Ethereum wallet with test Ether.

## License
This project is licensed under the [MIT License](https://opensource.org/licenses/MIT).
