import { useState, useEffect } from "react";
import { ethers } from "ethers";
import flightAbi from "../artifacts/contracts/FlightManagement.sol/FlightManagement.json";

export default function FlightManagementApp() {
  const [ethWallet, setEthWallet] = useState(undefined);
  const [account, setAccount] = useState(undefined);
  const [contract, setContract] = useState(undefined);
  const [balance, setBalance] = useState(undefined);
  const [flightCounter, setFlightCounter] = useState(0);
  const [flightDetails, setFlightDetails] = useState({});
  const [bookingDetails, setBookingDetails] = useState({});
  const [selectedFlightId, setSelectedFlightId] = useState(1);
  const [seatsToBook, setSeatsToBook] = useState(1);
  const [depositAmount, setDepositAmount] = useState("0");
  const [newFlightName, setNewFlightName] = useState("");
  const [newFlightSeats, setNewFlightSeats] = useState(0);
  const [newFlightPrice, setNewFlightPrice] = useState("");

  const contractAddress = "0x5FbDB2315678afecb367f032d93F642f64180aa3";
  const flightABI = flightAbi.abi;

  const getWallet = async () => {
    if (window.ethereum) {
      setEthWallet(window.ethereum);
    }

    if (ethWallet) {
      const accounts = await ethWallet.request({ method: "eth_accounts" });
      handleAccount(accounts);
    }
  };

  const handleAccount = (accounts) => {
    if (accounts.length > 0) {
      setAccount(accounts[0]);
    } else {
      console.log("No account found");
    }
  };

  const connectAccount = async () => {
    if (!ethWallet) {
      alert("MetaMask wallet is required to connect");
      return;
    }

    const accounts = await ethWallet.request({ method: "eth_requestAccounts" });
    handleAccount(accounts);
    getContractInstance();
  };

  const getContractInstance = () => {
    const provider = new ethers.providers.Web3Provider(ethWallet);
    const signer = provider.getSigner();
    const flightContract = new ethers.Contract(contractAddress, flightABI, signer);
    setContract(flightContract);
  };

  const getBalance = async () => {
    if (contract) {
      const userBalance = await contract.balances(account);
      setBalance(ethers.utils.formatEther(userBalance));
    }
  };

  const fetchFlightDetails = async () => {
    if (contract) {
      const count = await contract.flightCounter();
      setFlightCounter(count.toNumber());
      const details = {};
      for (let i = 1; i <= count; i++) {
        const name = await contract.flightNames(i);
        const seats = await contract.seatsAvailable(i);
        const price = await contract.pricePerSeat(i);
        const active = await contract.isActive(i);
        details[i] = { name, seats: seats.toNumber(), price: ethers.utils.formatEther(price), active };
      }
      setFlightDetails(details);
    }
  };

  const bookSeats = async () => {
    if (contract) {
      try {
        const tx = await contract.bookSeat(selectedFlightId, seatsToBook);
        await tx.wait();
        alert(`Successfully booked ${seatsToBook} seat(s) for flight ID ${selectedFlightId}`);
        fetchFlightDetails();
      } catch (error) {
        console.error("Booking Error: ", error);
      }
    }
  };

  const depositFunds = async () => {
    if (contract) {
      try {
        const tx = await contract.depositFunds({ value: ethers.utils.parseEther(depositAmount) });
        await tx.wait();
        alert(`Successfully deposited ${depositAmount} ETH`);
        getBalance();
      } catch (error) {
        console.error("Deposit Error: ", error);
      }
    }
  };

  const cancelBooking = async () => {
    if (contract) {
      try {
        const tx = await contract.cancelBooking(selectedFlightId, seatsToBook);
        await tx.wait();
        alert(`Successfully cancelled ${seatsToBook} seat(s) for flight ID ${selectedFlightId}`);
        fetchFlightDetails();
      } catch (error) {
        console.error("Cancellation Error: ", error);
      }
    }
  };

  const createFlight = async () => {
    if (contract) {
      try {
        const tx = await contract.addFlight(newFlightName, newFlightSeats, ethers.utils.parseEther(newFlightPrice));
        await tx.wait();
        alert(`Flight "${newFlightName}" created successfully!`);
        fetchFlightDetails();
      } catch (error) {
        console.error("Create Flight Error: ", error);
      }
    }
  };

  useEffect(() => {
    getWallet();
  }, []);

  useEffect(() => {
    if (contract) {
      getBalance();
      fetchFlightDetails();
    }
  }, [contract]);

  const initUser = () => {
    if (!ethWallet) {
      return <p>Please install MetaMask to use this app.</p>;
    }

    if (!account) {
      return <button onClick={connectAccount}>Connect MetaMask Wallet</button>;
    }

    return (
      <div>
        <p>Your Account: {account}</p>
        <p>Your Balance: {balance || "0"} ETH</p>

        <div>
          <h3>Flights</h3>
          {Object.keys(flightDetails).length === 0 ? (
            <p>Loading flight details...</p>
          ) : (
            Object.entries(flightDetails).map(([id, details]) => (
              <div key={id}>
                <p>
                  Flight ID: {id}, Name: {details.name}, Seats: {details.seats}, Price: {details.price} ETH, Active: {details.active ? "Yes" : "No"}
                </p>
              </div>
            ))
          )}
        </div>

        <div>
          <h3>Actions</h3>
          <input
            type="number"
            value={selectedFlightId}
            onChange={(e) => setSelectedFlightId(Number(e.target.value))}
            placeholder="Flight ID"
          />
          <input
            type="number"
            value={seatsToBook}
            onChange={(e) => setSeatsToBook(Number(e.target.value))}
            placeholder="Seats to Book/Cancel"
          />
          <button onClick={bookSeats}>Book Seats</button>
          <button onClick={cancelBooking}>Cancel Booking</button>
        </div>

        <div>
          <h3>Create Flight</h3>
          <input
            type="text"
            value={newFlightName}
            onChange={(e) => setNewFlightName(e.target.value)}
            placeholder="Flight Name"
          />
          <input
            type="number"
            value={newFlightSeats}
            onChange={(e) => setNewFlightSeats(Number(e.target.value))}
            placeholder="Seats Available"
          />
          <input
            type="text"
            value={newFlightPrice}
            onChange={(e) => setNewFlightPrice(e.target.value)}
            placeholder="Price per Seat (ETH)"
          />
          <button onClick={createFlight}>Create Flight</button>
        </div>

        <div>
          <h3>Manage Funds</h3>
          <input
            type="text"
            value={depositAmount}
            onChange={(e) => setDepositAmount(e.target.value)}
            placeholder="ETH to Deposit"
          />
          <button onClick={depositFunds}>Deposit Funds</button>
        </div>
      </div>
    );
  };

  return (
    <main className="container">
      <header>
        <h1>Flight Management System</h1>
      </header>
      {initUser()}
      <style jsx>{`
        .container {
          text-align: center;
        }
      `}</style>
    </main>
  );
}
