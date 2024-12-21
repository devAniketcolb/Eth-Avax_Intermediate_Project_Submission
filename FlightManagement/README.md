# FlightManagement Smart Contract

## Overview
The `FlightManagement` smart contract is a decentralized application designed to manage flight bookings on the Ethereum blockchain. This system enables an owner to add and manage flights, while users can book and cancel seats, deposit funds, and interact with the system securely.

The project includes:
- A Solidity smart contract deployed using the Hardhat framework.
- A React frontend for interacting with the smart contract.

## Main Features

### Smart Contract

```solidity
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
```

- **Flight Management:**
  - Add flights with name, seat availability, and price per seat.
  - Activate or deactivate flights.
- **Booking Management:**
  - Book seats for a flight.
  - Cancel bookings and receive a refund.
- **Fund Management:**
  - Users can deposit ETH to their account balance.
  - Balances are used for booking seats.

### Frontend

- Built with React and integrates with MetaMask for user interaction.
- Allows users to:
  - View available flights.
  - Book and cancel seats.
  - Manage their ETH balance (deposit funds).
  - View flight and account details.

## Prerequisites
- **Node.js** and **npm** installed.
- **Hardhat** framework set up.
- **MetaMask** browser extension.

## Smart Contract Setup
### Installation
1. Clone the repository.
   ```bash
   git clone <repository_url>
   cd flight-management
   ```
2. Install dependencies.
   ```bash
   npm install
   ```

### Compile the Contract
Run the following command to compile the smart contract:
```bash
npx hardhat compile
```

### Deploy the Contract
1. Update `hardhat.config.js` with your Ethereum provider details.
2. Deploy the contract:
   ```bash
   npx hardhat run scripts/deploy.js --network <network_name>
   ```
   Note the deployed contract address.

## React Frontend Setup

### Installation
2. Install dependencies.
   ```bash
   npm install
   ```

### Configuration
1. Update the `contractAddress` in the React code with the deployed contract address.
2. Ensure the ABI file is placed in the `src/artifacts` folder.

### Run the Frontend
Start the React application:
```bash
npm run dev
```
The application will run on `http://localhost:3000`.

## Key Contract Functions

### Owner Functions
1. `addFlight(string memory _flightName, uint256 _seatsAvailable, uint256 _pricePerSeat)`
   - Adds a new flight.
2. `deactivateFlight(uint256 _flightId)`
   - Deactivates a flight.
3. `activateFlight(uint256 _flightId)`
   - Reactivates a flight.

### User Functions
1. `bookSeat(uint256 _flightId, uint256 _seats)`
   - Books a specified number of seats for a flight.
2. `cancelBooking(uint256 _flightId, uint256 _seats)`
   - Cancels booked seats and refunds the user.
3. `depositFunds()`
   - Deposits ETH into the user's account balance.

## Frontend Features
- **Connect Wallet:** Users connect their MetaMask wallet to interact with the app.
- **Flight List:** Displays all flights with their details.
- **Book Seats:** Users can book seats for active flights.
- **Cancel Booking:** Allows cancellation of booked seats.
- **Deposit Funds:** Enables users to deposit ETH to their account.
- **View Balance:** Displays user account balance and bookings.

## Events
- `FlightAdded(uint256 flightId, string flightName, uint256 seatsAvailable, uint256 pricePerSeat)`
- `SeatBooked(address indexed user, uint256 flightId, uint256 seatsBooked)`
- `BookingCancelled(address indexed user, uint256 flightId, uint256 seatsCancelled)`

## Development Notes
- Use `npx hardhat node` to run a local blockchain for testing.
- Deploy the contract to the local blockchain using:
  ```bash
  npx hardhat run scripts/deploy.js --network localhost
  ```
- Test the contract using Hardhat or Remix.

## Example Usage
1. **Owner:**
   - Add a flight with `addFlight("Flight A", 100, 0.01 ether)`.
   - Deactivate a flight with `deactivateFlight(1)`.
2. **User:**
   - Deposit funds using `depositFunds()` with value.
   - Book seats using `bookSeat(1, 2)`.
   - Cancel bookings with `cancelBooking(1, 1)`.

## License
This project is licensed under the MIT License.
