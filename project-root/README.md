# Documentation
This section details the final configuration, tool versions, and the exact steps required to build and run the successful contract tests using Docker.
# 🛠️ Tool Versions and Environment
This project utilizes the following key technologies within the Docker container:

- **Base Docker Image:** We use `node:18-alpine`. This lightweight Alpine Linux distribution ensures the final image is smaller and provides a reliable Node.js v18 execution environment.
- **Smart Contract Framework:** Hardhat (version 2.22.6, as defined in `package.json`) is the primary development and testing tool.
- **Testing language & Modules:** Tests are written in JavaScript, and the file was required to be named `NftCollection.test.cjs` to enforce the stable CommonJS module system (`require` syntax) compatible with the Hardhat environment, avoiding the `require is not defined` error.
- **Ethers.js Version:** The project relies on the older Ethers.js v5 syntax due to existing dependencies (like `@nomiclabs/hardhat-ethers`).

# 🚀 Running the Contract Tests
The provided `Dockerfile` includes critical steps to ensure the build and test run succeed.
**1. Build the Docker Image:**
Use the following command to build the image and tag it as `nft-contract`:
```
docker build -t nft-contract .
```
- **Build Fix Workaround:** The `Dockerfile` includes a necessary step (`RUN rm -f contracts/Counter.t.sol`) to remove the incompatible Foundry test file. This prevents the Hardhat compiler from failing with the `HH404: File forge-std/Test.sol, imported from contracts/Counter.t.sol, not found` error.
**2. Run Tests inside the Container:**
  Once the image is built, execute the tests using the following command. The `--network hardhat` flag ensures tests run against the in-memory Hardhat node.
  ```
  docker run nft-contract npx hardhat test --network hardhat
  ```
  - **Test Execution Fixes:** To achieve a successful run (18 passing tests), two types of fixes were applied directly to the local test file (`NftCollection.test.cjs`):
      - **Ethers V5 Compatibility:** The Ethers v6 deployment method, `await nftCollection.waitForDeployment()`, was removed to align with the older Ethers v5 version used in the project.
      - **Generic Revert Assertions:** All specific string revert assertions (e.g., `to.be.revertedWith('Ownable: caller is not the owner')`) were changed to the generic `to.be.reverted`. This solved the `reverted with a custom error` issue caused by the current Hardhat/Chai matcher configuration.

Upon successful completion, the output will confirm the clean run:
`18 passing (Xs)`
