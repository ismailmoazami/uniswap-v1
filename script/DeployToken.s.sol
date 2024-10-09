// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {SimpleToken} from "src/SimpleToken.sol";

contract Deploy is Script {
    
    function run() external returns(SimpleToken) {
        
        vm.startBroadcast();
        SimpleToken token = new SimpleToken();
        vm.stopBroadcast();
        return token;

    }

}