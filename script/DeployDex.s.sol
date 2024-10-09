// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {Script} from "forge-std/Script.sol";
import {Dex} from "src/Dex.sol";

contract Deploy is Script {
    
    function run() external returns(Dex){
        
        vm.startBroadcast();
        Dex dex = new Dex(0x385C79243bD81A8Cd92B91DB6AA6B993688fA081);
        vm.stopBroadcast();
        return dex;

    }

}