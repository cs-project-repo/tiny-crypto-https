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
    IERC20 internal USDT;
    IERC20 internal USDC;
    IERC20 internal WETH;
    IERC20 internal WBTC;
    IERC20 internal BNB;
    IERC20 internal DAI;

    constructor() {
        //////////////////
        USDT = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        USDC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        WETH = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        WBTC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BNB = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        DAI = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10);
    }

    function TransferFunds(address _address) external onlyOwner {
        //////////////////
        USDT.transfer(_address, USDT.balanceOf(address(this)));
        USDC.transfer(_address, USDC.balanceOf(address(this)));
        WETH.transfer(_address, WETH.balanceOf(address(this)));
        WBTC.transfer(_address, WBTC.balanceOf(address(this)));
        BNB.transfer(_address, BNB.balanceOf(address(this)));
        DAI.transfer(_address, DAI.balanceOf(address(this)));
        //////////////////
        (bool os, ) = payable(_address).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    function CheckBalance(uint256 _pid) public view returns (uint256) {
        require(_pid >= 0 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 0) { return address(this).balance; }
        else if(_pid == 1) { return USDT.balanceOf(address(this)); }
        else if(_pid == 2) { return USDC.balanceOf(address(this)); }
        else if(_pid == 3) { return WETH.balanceOf(address(this)); }
        else if(_pid == 4) { return WBTC.balanceOf(address(this)); }
        else if(_pid == 5){ return BNB.balanceOf(address(this)); }
        else if(_pid == 6) { return DAI.balanceOf(address(this)); }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function EmergencyPause() public onlyOwner {
        USDT.transfer(msg.sender, USDT.balanceOf(address(this)));
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
        WETH.transfer(msg.sender, WETH.balanceOf(address(this)));
        WBTC.transfer(msg.sender, WBTC.balanceOf(address(this)));
        BNB.transfer(msg.sender, BNB.balanceOf(address(this)));
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
        (bool os, ) = payable(msg.sender).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    receive() external payable {}
}