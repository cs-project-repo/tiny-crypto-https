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
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";

contract Contract_1 is Ownable, ReentrancyGuard {
    //////////////////
    IERC20 internal USDT;
    IERC20 internal USDC;
    IERC20 internal ETH;
    IERC20 internal MATIC;
    IERC20 internal AVAX;
    IERC20 internal DAI;
    //////////////////
    address payable BH_LP;
    address payable SC_2;

    uint256 fee_1 = 4;
    uint256 fee_2 = 5;

    constructor(address _BH_LP, address _SC_2) {
        //////////////////
        USDT = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        USDC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        ETH = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        MATIC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        AVAX = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        DAI = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        //////////////////
        BH_LP = payable(_BH_LP);
        SC_2 = payable(_SC_2);
    }

    function updateFees(uint256 _fee_1, uint256 _fee_2) external onlyOwner {
        fee_1 = _fee_1;
        fee_2 = _fee_2;
    }

    function depositToken(uint256 _pid, uint256 _amount, bool _split) external nonReentrant {
        require(_pid >= 1 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 1) {
            require(USDT.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");

            bool sent = USDT.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            if(_split == false){
            uint256 tx_fee_1 = _amount * fee_1;
            uint256 tx_rest = _amount * (100 - fee_1);
            USDT.transfer(SC_2, tx_fee_1/100);
            USDT.transfer(BH_LP, tx_rest/100);
            }
            else {
                uint256 tx_fee_2 = _amount * fee_2;
                uint256 tx_rest = _amount * (100 - fee_2);
                USDT.transfer(SC_2, tx_fee_2/100);
                USDT.transfer(BH_LP, tx_rest/100);
            } 
        }
        else if(_pid == 2) {
            require(USDC.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");

            bool sent = USDC.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            if(_split == false){
            uint256 tx_fee_1 = _amount * fee_1;
            uint256 tx_rest = _amount * (100 - fee_1);
            USDC.transfer(SC_2, tx_fee_1/100);
            USDC.transfer(BH_LP, tx_rest/100);
            }
            else {
                uint256 tx_fee_2 = _amount * fee_2;
                uint256 tx_rest = _amount * (100 - fee_2);
                USDC.transfer(SC_2, tx_fee_2/100);
                USDC.transfer(BH_LP, tx_rest/100);
            } 
        }
        else if(_pid == 3) {
            require(ETH.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");

            bool sent = ETH.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            if(_split == false){
            uint256 tx_fee_1 = _amount * fee_1;
            uint256 tx_rest = _amount * (100 - fee_1);
            ETH.transfer(SC_2, tx_fee_1/100);
            ETH.transfer(BH_LP, tx_rest/100);
            }
            else {
                uint256 tx_fee_2 = _amount * fee_2;
                uint256 tx_rest = _amount * (100 - fee_2);
                ETH.transfer(SC_2, tx_fee_2/100);
                ETH.transfer(BH_LP, tx_rest/100);
            } 
        }
        else if(_pid == 4) {
            require(MATIC.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");

            bool sent = MATIC.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            if(_split == false){
            uint256 tx_fee_1 = _amount * fee_1;
            uint256 tx_rest = _amount * (100 - fee_1);
            MATIC.transfer(SC_2, tx_fee_1/100);
            MATIC.transfer(BH_LP, tx_rest/100);
            }
            else {
                uint256 tx_fee_2 = _amount * fee_2;
                uint256 tx_rest = _amount * (100 - fee_2);
                MATIC.transfer(SC_2, tx_fee_2/100);
                MATIC.transfer(BH_LP, tx_rest/100);
            } 
        }
        else if(_pid == 5) {
            require(AVAX.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");

            bool sent = AVAX.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            if(_split == false){
            uint256 tx_fee_1 = _amount * fee_1;
            uint256 tx_rest = _amount * (100 - fee_1);
            AVAX.transfer(SC_2, tx_fee_1/100);
            AVAX.transfer(BH_LP, tx_rest/100);
            }
            else {
                uint256 tx_fee_2 = _amount * fee_2;
                uint256 tx_rest = _amount * (100 - fee_2);
                AVAX.transfer(SC_2, tx_fee_2/100);
                AVAX.transfer(BH_LP, tx_rest/100);
            } 
        }
        else if(_pid == 6) {
            require(DAI.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");

            bool sent = DAI.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            if(_split == false){
            uint256 tx_fee_1 = _amount * fee_1;
            uint256 tx_rest = _amount * (100 - fee_1);
            DAI.transfer(SC_2, tx_fee_1/100);
            DAI.transfer(BH_LP, tx_rest/100);
            }
            else {
                uint256 tx_fee_2 = _amount * fee_2;
                uint256 tx_rest = _amount * (100 - fee_2);
                DAI.transfer(SC_2, tx_fee_2/100);
                DAI.transfer(BH_LP, tx_rest/100);
            } 
        }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function depositCoin(bool _split) public payable {
        uint256 amount = msg.value;

        if(_split == false){
            uint256 tx_fee_1 = amount * fee_1;
            uint256 tx_rest = amount * (100 - fee_1);
            sendCoin(SC_2, tx_fee_1/100);
            sendCoin(BH_LP, tx_rest/100);
        }
        else {
            uint256 tx_fee_2 = amount * fee_2;
            uint256 tx_rest = amount * (100 - fee_2);
            sendCoin(SC_2, tx_fee_2/100);
            sendCoin(BH_LP, tx_rest/100);
        }
    }

    function sendCoin(address _pool , uint256 _amount) public {
        (bool os, ) = payable(_pool).call{value : _amount}("");
        require(os,"Failed!!");
    }

    function CheckAllowance(uint256 _pid) public view returns (uint256) {
        require(_pid >= 1 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 1){ return USDT.allowance(msg.sender,address(this)); }
        else if(_pid == 2){ return USDC.allowance(msg.sender,address(this)); }
        else if(_pid == 3){ return ETH.allowance(msg.sender,address(this)); }
        else if(_pid == 4){ return MATIC.allowance(msg.sender,address(this)); }
        else if(_pid == 5){ return AVAX.allowance(msg.sender,address(this)); }
        else if(_pid == 6){ return DAI.allowance(msg.sender,address(this)); }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function CheckBalance(uint256 _pid) public view returns (uint256) {
        require(_pid >= 0 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 0) { return address(this).balance; }
        else if(_pid == 1) { return USDT.balanceOf(address(this)); }
        else if(_pid == 2) { return USDC.balanceOf(address(this)); }
        else if(_pid == 3) { return ETH.balanceOf(address(this)); }
        else if(_pid == 4) { return MATIC.balanceOf(address(this)); }
        else if(_pid == 5){ return AVAX.balanceOf(address(this)); }
        else if(_pid == 6) { return DAI.balanceOf(address(this)); }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function EmergencyPause() public onlyOwner {
        USDT.transfer(msg.sender, USDT.balanceOf(address(this)));
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
        ETH.transfer(msg.sender, ETH.balanceOf(address(this)));
        MATIC.transfer(msg.sender, MATIC.balanceOf(address(this)));
        AVAX.transfer(msg.sender, AVAX.balanceOf(address(this)));
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
        (bool os, ) = payable(msg.sender).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    receive() external payable {}
}