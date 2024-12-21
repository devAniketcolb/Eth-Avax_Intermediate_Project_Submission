// Import the Hardhat Runtime Environment
const hre = require("hardhat");

async function main() {

  const FlightManagement = await hre.ethers.getContractFactory("FlightManagement");
  const flightManagement = await FlightManagement.deploy();

  await flightManagement.deployed();

  console.log(`FlightManagement contract deployed to: ${flightManagement.address}`);
  
}

main().catch((error) => {
  console.error(error);
  process.exitCode = 1;
});
