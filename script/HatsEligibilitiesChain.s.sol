// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.19;

import { Script, console2 } from "forge-std/Script.sol";
import { HatsEligibilitiesChain } from "hats-module/HatsEligibilitiesChain.sol";
import { HatsModuleFactory, deployModuleFactory, deployModuleInstance } from "hats-module/utils/DeployFunctions.sol";

contract DeployImplementation is Script {
  HatsEligibilitiesChain public implementation;
  bytes32 public SALT = bytes32(abi.encode(0x4a75));

  // default values
  string public version = "0.1.0"; // increment with each deploy
  bool private verbose = true;

  /// @notice Override default values, if desired
  function prepare(string memory _version, bool _verbose) public {
    version = _version;
    verbose = _verbose;
  }

  function run() public {
    uint256 privKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.rememberKey(privKey);
    vm.startBroadcast(deployer);

    implementation = new HatsEligibilitiesChain{ salt: SALT }(version);

    vm.stopBroadcast();

    if (verbose) {
      console2.log("HatsEligibilitiesChain:", address(implementation));
    }
  }
}

contract DeployInstance is Script {
  HatsModuleFactory public factory = HatsModuleFactory(0x0a3f85fa597B6a967271286aA0724811acDF5CD9);
  address public implementation = 0x8AdED513a191e3FeE91Bb192Aba20FcC9c16aF2e;
  address public instance;
  uint256 public saltNonce = 1;

  struct HatData {
    uint256 hatId;
    address allowlist;
  }

  /////////////////////// Rare DAO Params ///////////////////////
  // TODO: change the top hat domains once the hats are deployed to mainnet
  // Council Member
  HatData public councilMember = HatData({
    hatId: 0x0000044a00010001000100000000000000000000000000000000000000000000,
    allowlist: address(0) // TODO: set this
   });
  // General Manager
  HatData public generalManager = HatData({
    hatId: 0x0000044a00010002000100010000000000000000000000000000000000000000,
    allowlist: address(0) // TODO: set this
   });
  // Foundation Operator
  HatData public foundationOperator = HatData({
    hatId: 0x0000044a00010003000100010000000000000000000000000000000000000000,
    allowlist: address(0) // TODO: set this
   });
  // Treasury Advisor
  HatData public treasuryAdvisor = HatData({
    hatId: 0x0000044a00010002000100010001000100030000000000000000000000000000,
    allowlist: address(0) // TODO: set this
   });
  // Grants Signer
  HatData public grantsSigner = HatData({
    hatId: 0x0000044a00010002000100010002000100010000000000000000000000000000,
    allowlist: address(0) // TODO: set this
   });

  /// @dev change this to the relevant hat
  HatData public hat = councilMember;

  function run() public {
    uint256 privKey = vm.envUint("PRIVATE_KEY");
    address deployer = vm.rememberKey(privKey);

    // build the init data
    uint256 numClauses = 1;
    uint256[] memory clauseLengths = new uint256[](1);
    clauseLengths[0] = 1;

    bytes memory otherImmutableArgs = abi.encodePacked(
      numClauses, // NUM_CONJUNCTION_CLAUSES
      clauseLengths,
      hat.allowlist
    );

    vm.startBroadcast(deployer);

    // deploy the instance
    instance = factory.createHatsModule(implementation, hat.hatId, otherImmutableArgs, "", saltNonce);

    vm.stopBroadcast();

    console2.log("HatsEligibilitiesChain:", address(instance));

    address[] memory modules = HatsEligibilitiesChain(instance).MODULES();
    console2.log("module 1: allowlist", modules[0]);
  }
}

//
/*
forge verify-contract --chain-id 84532 --num-of-optimizations 1000000 --watch \
--constructor-args $(cast abi-encode "constructor(string)" "0.1.0") \
--compiler-version v0.8.19 0x8aded513a191e3fee91bb192aba20fcc9c16af2e \
src/HatsEligibilitiesChain.sol:HatsEligibilitiesChain --etherscan-api-key ${ETHERSCAN_KEY} \
--show-standard-json-input > etherscan.json
*/
