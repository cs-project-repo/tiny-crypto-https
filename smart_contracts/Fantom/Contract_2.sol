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
    IERC20 internal USDC;
    IERC20 internal ETH;
    IERC20 internal BTC;
    IERC20 internal BNB;
    IERC20 internal BUSD;
    IERC20 internal DAI;
    //////////////////
    address payable Reserve;
    address payable Fund;

    constructor(address _Pool_1, address _Pool_2) {
        //////////////////
        USDC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        ETH = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BTC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BNB = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BUSD = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        DAI = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        //////////////////
        Reserve = payable(_Pool_1);
        Fund = payable(_Pool_2);
    }

    function TransferPool() private {
        //////////////////
        uint256 usdc = USDC.balanceOf(address(this));
        uint256 eth = ETH.balanceOf(address(this));
        uint256 btc = BTC.balanceOf(address(this));
        uint256 bnb = BNB.balanceOf(address(this));
        uint256 busd = BUSD.balanceOf(address(this));
        uint256 dai = DAI.balanceOf(address(this));

        //////////////////
        uint256 t1_90_per = (usdc * 90) / 100;
        USDC.transfer(Reserve, t1_90_per);
        uint256 t1_10_per = (usdc * 10) / 100;
        USDC.transfer(Fund, t1_10_per);
        //////////////////
        uint256 t2_90_per = (eth * 90) / 100;
        ETH.transfer(Reserve, t2_90_per);
        uint256 t2_10_per = (eth * 10) / 100;
        ETH.transfer(Fund, t2_10_per);
        //////////////////
        uint256 t3_90_per = (btc * 90) / 100;
        BTC.transfer(Reserve, t3_90_per);
        uint256 t3_10_per = (btc * 10) / 100;
        BTC.transfer(Fund, t3_10_per);
        //////////////////
        uint256 t4_90_per = (bnb * 90) / 100;
        BNB.transfer(Reserve, t4_90_per);
        uint256 t4_10_per = (bnb * 10) / 100;
        BNB.transfer(Fund, t4_10_per);
        //////////////////
        uint256 t5_90_per = (busd * 90) / 100;
        BUSD.transfer(Reserve, t5_90_per);
        uint256 t5_10_per = (busd * 10) / 100;
        BUSD.transfer(Fund, t5_10_per);
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