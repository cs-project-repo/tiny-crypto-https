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

contract Reserve is Ownable {
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

    function WithdrawBalance(uint256 _pid, uint256 _amount) external onlyOwner {
        require(_pid >= 0 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 0) { (bool os, ) = payable(msg.sender).call{value : _amount}("");
        require(os,"Failed!!"); }
        else if(_pid == 1) { USDC.transfer(msg.sender, _amount); }
        else if(_pid == 2) { ETH.transfer(msg.sender, _amount); }
        else if(_pid == 3) { BTC.transfer(msg.sender, _amount); }
        else if(_pid == 4) { BNB.transfer(msg.sender, _amount); }
        else if(_pid == 5) { BUSD.transfer(msg.sender, _amount); }
        else if(_pid == 6) { DAI.transfer(msg.sender, _amount); }
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