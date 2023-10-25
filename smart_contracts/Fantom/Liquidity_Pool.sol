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

contract Liquidity_Pool is Ownable, ReentrancyGuard {
    //////////////////
    IERC20 internal USDC;
    IERC20 internal ETH;
    IERC20 internal BTC;
    IERC20 internal BNB;
    IERC20 internal BUSD;
    IERC20 internal DAI;
    //////////////////
    IERC20 internal bhFTM;
    IERC20 internal bhUSDC;
    IERC20 internal bhETH;
    IERC20 internal bhBTC;
    IERC20 internal bhBNB;
    IERC20 internal bhBUSD;
    IERC20 internal bhDAI;
    //////////////////
    AggregatorV3Interface internal ftmPrice;
    AggregatorV3Interface internal usdcPrice;
    AggregatorV3Interface internal ethPrice;
    AggregatorV3Interface internal btcPrice;
    AggregatorV3Interface internal bnbPrice;
    AggregatorV3Interface internal busdPrice;
    AggregatorV3Interface internal daiPrice;
    //////////////////
    IERC20 internal EHT;
    //////////////////
    address internal BH_W;

    string coin_0 = "FTM";
    string token_0 = "USDC";
    string token_1 = "ETH";
    string token_2 = "BTC";
    string token_3 = "BNB";
    string token_4 = "BUSD";
    string token_5 = "DAI";

    uint256 usdc_max = 10;
    uint256 eth_max = 10;
    uint256 btc_max = 10;
    uint256 bnb_max = 10;
    uint256 busd_max = 10;
    uint256 dai_max = 10;

    uint256 usd_threshold = 10000;

    constructor(address _BH_W) {
        ////////////////// 
        USDC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        ETH = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BTC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BNB = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BUSD = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        DAI = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        //////////////////
        bhFTM = IERC20(0xAf4BFaf9CD0DFD3089f0Be0c17844DE6467DeFaD);
        bhUSDC = IERC20(0xAf4BFaf9CD0DFD3089f0Be0c17844DE6467DeFaD);
        bhETH = IERC20(0xAf4BFaf9CD0DFD3089f0Be0c17844DE6467DeFaD);
        bhBTC = IERC20(0xAf4BFaf9CD0DFD3089f0Be0c17844DE6467DeFaD);
        bhBNB = IERC20(0xAf4BFaf9CD0DFD3089f0Be0c17844DE6467DeFaD);
        bhBUSD = IERC20(0xAf4BFaf9CD0DFD3089f0Be0c17844DE6467DeFaD);
        bhDAI = IERC20(0xAf4BFaf9CD0DFD3089f0Be0c17844DE6467DeFaD);
        //////////////////
        ftmPrice = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        usdcPrice = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        ethPrice = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        btcPrice = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        bnbPrice = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        busdPrice = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        daiPrice = AggregatorV3Interface(0x8A753747A1Fa494EC906cE90E9f37563A8AF630e);
        //////////////////
        EHT = IERC20(0xF60D7b9C1E46f362D033EBb07fAa325068c7458c); 
        //////////////////
        BH_W = _BH_W;
    }

    mapping(address => mapping(string => uint256)) internal timelock;

    function burnLp(uint256 _pid, uint256 _amount) public nonReentrant {
        require(_pid >= 0 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 0) {
            require(block.timestamp > timelock[msg.sender][coin_0], "You Can't Remove Liquidity Before 6 months!!");
            require(bhFTM.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = bhFTM.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            (bool success,) = msg.sender.call{value: _amount}("");
            require(success, "Transfer Failed.");
        }
        else if(_pid == 1) {
            require(block.timestamp > timelock[msg.sender][token_0], "You Can't Remove Liquidity Before 6 months!!");
            require(bhUSDC.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = bhUSDC.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            uint256 t1_dep_am = depositAmount(_pid, _amount);
            USDC.transfer(msg.sender, t1_dep_am);
        }
        else if(_pid == 2) {
            require(block.timestamp > timelock[msg.sender][token_1], "You Can't Remove Liquidity Before 6 months!!");
            require(bhETH.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = bhETH.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            uint256 t2_dep_am = depositAmount(_pid, _amount);
            ETH.transfer(msg.sender, t2_dep_am);
        }
        else if(_pid == 3) {
            require(block.timestamp > timelock[msg.sender][token_2], "You Can't Remove Liquidity Before 6 months!!");
            require(bhBTC.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = bhBTC.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            uint256 t3_dep_am = depositAmount(_pid, _amount);
            BTC.transfer(msg.sender, t3_dep_am);
        }
        else if(_pid == 4) {
            require(block.timestamp > timelock[msg.sender][token_3], "You Can't Remove Liquidity Before 6 months!!");
            require(bhBNB.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = bhBNB.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            uint256 t4_dep_am = depositAmount(_pid, _amount);
            BNB.transfer(msg.sender, t4_dep_am);
        }
        else if(_pid == 5) {
            require(block.timestamp > timelock[msg.sender][token_4], "You Can't Remove Liquidity Before 6 months!!");
            require(bhBUSD.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = bhBUSD.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            uint256 t5_dep_am = depositAmount(_pid, _amount);
            BUSD.transfer(msg.sender, t5_dep_am);
        }
        else if(_pid == 6) {
            require(block.timestamp > timelock[msg.sender][token_5], "You Can't Remove Liquidity Before 6 months!!");
            require(bhDAI.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = bhDAI.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            uint256 t6_dep_am = depositAmount(_pid, _amount);
            DAI.transfer(msg.sender, t6_dep_am);
        }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function depositAmount(uint256 _pid, uint256 _amount) internal pure returns (uint256 sum) {
        if(_pid == 1) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 6;
        }
        else if(_pid == 2) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        } 
        else if(_pid == 3) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 8;
        } 
        else if(_pid == 4) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        } 
        else if(_pid == 5) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        } 
        else if(_pid == 6) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        } 
    }

    function addCoinLiquidity() public payable nonReentrant {
        require(msg.value != 0 ,"Need Some Coin!");

        timelock[msg.sender][coin_0] = block.timestamp + 180 days;
        
        uint256 _pid = 0;
        uint256 c1_bh_am = bhAmount(_pid, msg.value);
        uint256 c1_lp_am = lpAmount(_pid, msg.value);

        bhFTM.transfer(msg.sender, c1_bh_am);
        EHT.transfer(msg.sender, c1_lp_am);
    }

    function addTokenLiquidity(uint256 _pid, uint256 _amount) public nonReentrant {
        require(_pid >= 1 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 1) {
            require(USDC.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = USDC.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            timelock[msg.sender][token_0] = block.timestamp + 180 days;

            uint256 t1_bh_am = bhAmount(_pid, _amount);
            uint256 t1_lp_am = lpAmount(_pid, _amount);

            bhUSDC.transfer(msg.sender, t1_bh_am);
            EHT.transfer(msg.sender, t1_lp_am);
        }
        else if(_pid == 2) {
            require(ETH.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = ETH.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            timelock[msg.sender][token_1] = block.timestamp + 180 days;

            uint256 t2_bh_am = bhAmount(_pid, _amount);
            uint256 t2_lp_am = lpAmount(_pid, _amount);

            bhETH.transfer(msg.sender, t2_bh_am);
            EHT.transfer(msg.sender, t2_lp_am);
        }
        else if(_pid == 3) {
            require(BTC.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = BTC.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            timelock[msg.sender][token_2] = block.timestamp + 180 days;

            uint256 t3_bh_am = bhAmount(_pid, _amount);
            uint256 t3_lp_am = lpAmount(_pid, _amount);

            bhBTC.transfer(msg.sender, t3_bh_am);
            EHT.transfer(msg.sender, t3_lp_am);
        }
        else if(_pid == 4) {
            require(BNB.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = BNB.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            timelock[msg.sender][token_3] = block.timestamp + 180 days;

            uint256 t4_bh_am = bhAmount(_pid, _amount);
            uint256 t4_lp_am = lpAmount(_pid, _amount);

            bhBNB.transfer(msg.sender, t4_bh_am);
            EHT.transfer(msg.sender, t4_lp_am);
        }
        else if(_pid == 5) {
            require(BUSD.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = BUSD.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            timelock[msg.sender][token_4] = block.timestamp + 180 days;

            uint256 t5_bh_am = bhAmount(_pid, _amount);
            uint256 t5_lp_am = lpAmount(_pid, _amount);

            bhBUSD.transfer(msg.sender, t5_bh_am);
            EHT.transfer(msg.sender, t5_lp_am);
        }
        else if(_pid == 6) {
            require(DAI.allowance(msg.sender, address(this)) >= _amount, "Allowance not Approved!!");
            bool sent = DAI.transferFrom(msg.sender, address(this), _amount);
            require(sent,"Operation Failed!!");

            timelock[msg.sender][token_5] = block.timestamp + 180 days;

            uint256 t6_bh_am = bhAmount(_pid, _amount);
            uint256 t6_lp_am = lpAmount(_pid, _amount);

            bhDAI.transfer(msg.sender, t6_bh_am);
            EHT.transfer(msg.sender, t6_lp_am);
        }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function bhAmount(uint256 _pid, uint256 _amount) internal pure returns (uint256 sum) {
        if(_pid == 0) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        }
        else if(_pid == 1) {
            uint256 decimal = 1 * 10 ** 6;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        }
        else if(_pid == 2) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        }
        else if(_pid == 3) {
            uint256 decimal = 1 * 10 ** 8;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        }
        else if(_pid == 4) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        }
        else if(_pid == 5) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        }
        else if(_pid == 6) {
            uint256 decimal = 1 * 10 ** 18;
            uint256 amount = _amount / decimal;
            return amount * 10 ** 18;
        }
    }

    function lpAmount(uint256 _pid, uint256 _amount) internal view returns (uint256 sum) {
        if(_pid == 0) {
            (
            uint256 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
            ) = ftmPrice.latestRoundData();
            uint256 currentBalance = ((address(this).balance) / 10 ** 18) + 1;
            uint256 threshold = getThreshold(price / 10 ** 8);
            uint256 numer = _amount / 10 ** 18;
            uint256 denom = threshold * currentBalance;
            return division(18, numer, denom);
        }
        else if(_pid == 1) {
            (
            uint256 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
            ) = usdcPrice.latestRoundData();
            uint256 currentBalance = (USDC.balanceOf(address(this)) / 10 ** 6) + 1;
            uint256 threshold = getThreshold(price / 10 ** 8);
            uint256 numer = _amount / 10 ** 6;
            uint256 denom = threshold * currentBalance;
            return division(18, numer, denom); 
        }
        else if(_pid == 2) {
            (
            uint256 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
            ) = ethPrice.latestRoundData();
            uint256 currentBalance = (ETH.balanceOf(address(this)) / 10 ** 18) + 1;
            uint256 threshold = getThreshold(price / 10 ** 8);
            uint256 numer = _amount / 10 ** 18;
            uint256 denom = threshold * currentBalance;
            return division(18, numer, denom); 
        }
        else if(_pid == 3) {
            (
            uint256 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
            ) = btcPrice.latestRoundData();
            uint256 currentBalance = (BTC.balanceOf(address(this)) / 10 ** 8) + 1;
            uint256 threshold = getThreshold(price / 10 ** 8);
            uint256 numer = _amount / 10 ** 8;
            uint256 denom = threshold * currentBalance;
            return division(18, numer, denom); 
        }
        else if(_pid == 4) {
            (
            uint256 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
            ) = bnbPrice.latestRoundData();
            uint256 currentBalance = (BNB.balanceOf(address(this)) / 10 ** 18) + 1;
            uint256 threshold = getThreshold(price / 10 ** 8);
            uint256 numer = _amount / 10 ** 18;
            uint256 denom = threshold * currentBalance;
            return division(18, numer, denom); 
        }
        else if(_pid == 5) {
            (
            uint256 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
            ) = busdPrice.latestRoundData();
            uint256 currentBalance = (BUSD.balanceOf(address(this)) / 10 ** 18) + 1;
            uint256 threshold = getThreshold(price / 10 ** 8);
            uint256 numer = _amount / 10 ** 18;
            uint256 denom = threshold * currentBalance;
            return division(18, numer, denom); 
        }
        else if(_pid == 6) {
            (
            uint256 roundId,
            uint256 price,
            uint256 startedAt,
            uint256 timeStamp,
            uint256 answeredInRound
            ) = daiPrice.latestRoundData();
            uint256 currentBalance = (DAI.balanceOf(address(this)) / 10 ** 18) + 1;
            uint256 threshold = getThreshold(price / 10 ** 8);
            uint256 numer = _amount / 10 ** 18;
            uint256 denom = threshold * currentBalance;
            return division(18, numer, denom); 
        }
    }

    function division(uint256 _decimalPlaces, uint256 _numerator, uint256 _denominator) internal pure returns (uint256 sum) {
        uint256 factor = 10 ** _decimalPlaces;
        uint256 quotient = _numerator / _denominator;
        uint256 base = quotient * 10 ** 18;
        uint256 remainder = (_numerator * factor / _denominator) % factor;
        return base + remainder;
    }

    function updateThreshold(uint256 _threshold) external onlyOwner {
        usd_threshold = _threshold;
    }

    function getThreshold(uint256 _price) internal view returns (uint256) {
        return usd_threshold / _price;
    }

    ////
    function updateWithdrawalAmount(uint256[6] memory _amount) external onlyOwner {
        usdc_max = _amount[0];
        eth_max = _amount[1];
        btc_max = _amount[2];
        bnb_max = _amount[3];
        busd_max = _amount[4];
        dai_max = _amount[5];
    }

    function approveWithdrawalAmount() external onlyOwner {
        USDC.approve(BH_W, usdc_max * 10 ** 6);
        ETH.approve(BH_W, eth_max * 10 ** 18);
        BTC.approve(BH_W, btc_max * 10 ** 8);
        BNB.approve(BH_W, bnb_max * 10 ** 18);
        BUSD.approve(BH_W, busd_max * 10 ** 18);
        DAI.approve(BH_W, dai_max * 10 ** 18);
    }

    function approveMaxWithdrawalAmount() external onlyOwner {
        USDC.approve(BH_W, USDC.balanceOf(address(this)));
        ETH.approve(BH_W, ETH.balanceOf(address(this)));
        BTC.approve(BH_W, BTC.balanceOf(address(this)));
        BNB.approve(BH_W, BNB.balanceOf(address(this)));
        BUSD.approve(BH_W, BUSD.balanceOf(address(this)));
        DAI.approve(BH_W, DAI.balanceOf(address(this)));
    }

    function revokeWithdrawalAmount() external onlyOwner {
        USDC.approve(BH_W, 0);
        ETH.approve(BH_W, 0);
        BTC.approve(BH_W, 0);
        BNB.approve(BH_W, 0);
        BUSD.approve(BH_W, 0);
        DAI.approve(BH_W, 0);
    }

    function updateWithdrawalAdd(address _BH_W) external onlyOwner {
        BH_W = _BH_W;
    }
    ////

    function TransferFunds(address _address) external onlyOwner {
        //////////////////
        USDC.transfer(_address, USDC.balanceOf(address(this)));
        ETH.transfer(_address, ETH.balanceOf(address(this)));
        BTC.transfer(_address, BTC.balanceOf(address(this)));
        BNB.transfer(_address, BNB.balanceOf(address(this)));
        BUSD.transfer(_address, BUSD.balanceOf(address(this)));
        DAI.transfer(_address, DAI.balanceOf(address(this)));
        //////////////////
        bhFTM.transfer(_address, bhFTM.balanceOf(address(this)));
        bhUSDC.transfer(_address, bhUSDC.balanceOf(address(this)));
        bhETH.transfer(_address, bhETH.balanceOf(address(this)));
        bhBTC.transfer(_address, bhBTC.balanceOf(address(this)));
        bhBNB.transfer(_address, bhBNB.balanceOf(address(this)));
        bhBUSD.transfer(_address, bhBUSD.balanceOf(address(this)));
        bhDAI.transfer(_address, bhDAI.balanceOf(address(this)));
        //////////////////
        EHT.transfer(_address, EHT.balanceOf(address(this)));
        //////////////////
        (bool os, ) = payable(_address).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    function CheckBalance(uint256 _pid) public view returns (uint256 bal) {
        require(_pid >= 0 || _pid <= 14, "Please Select Correct Token!!");
        if(_pid == 0) { return address(this).balance; }
        else if(_pid == 1) { return USDC.balanceOf(address(this)); }
        else if(_pid == 2) { return ETH.balanceOf(address(this)); }
        else if(_pid == 3) { return BTC.balanceOf(address(this)); }
        else if(_pid == 4) { return BNB.balanceOf(address(this)); }
        else if(_pid == 5) { return BUSD.balanceOf(address(this)); }
        else if(_pid == 6) { return DAI.balanceOf(address(this)); }
        else if(_pid == 7) { return EHT.balanceOf(address(this)); }
        else if(_pid == 8) { return bhFTM.balanceOf(address(this)); }
        else if(_pid == 9) { return bhUSDC.balanceOf(address(this)); }
        else if(_pid == 10) { return bhETH.balanceOf(address(this)); }
        else if(_pid == 11) { return bhBTC.balanceOf(address(this)); }
        else if(_pid == 12) { return bhBNB.balanceOf(address(this)); }
        else if(_pid == 13) { return bhBUSD.balanceOf(address(this)); }
        else if(_pid == 14) { return bhDAI.balanceOf(address(this)); }
        else{ revert("ERROR! Please Select Correct Id"); }
    }

    function EmergencyPause() external onlyOwner {
        //////////////////
        USDC.transfer(msg.sender, USDC.balanceOf(address(this)));
        ETH.transfer(msg.sender, ETH.balanceOf(address(this)));
        BTC.transfer(msg.sender, BTC.balanceOf(address(this)));
        BNB.transfer(msg.sender, BNB.balanceOf(address(this)));
        BUSD.transfer(msg.sender, BUSD.balanceOf(address(this)));
        DAI.transfer(msg.sender, DAI.balanceOf(address(this)));
        //////////////////
        bhFTM.transfer(msg.sender, bhFTM.balanceOf(address(this)));
        bhUSDC.transfer(msg.sender, bhUSDC.balanceOf(address(this)));
        bhETH.transfer(msg.sender, bhETH.balanceOf(address(this)));
        bhBTC.transfer(msg.sender, bhBTC.balanceOf(address(this)));
        bhBNB.transfer(msg.sender, bhBNB.balanceOf(address(this)));
        bhBUSD.transfer(msg.sender, bhBUSD.balanceOf(address(this)));
        bhDAI.transfer(msg.sender, bhDAI.balanceOf(address(this)));
        //////////////////
        EHT.transfer(msg.sender, EHT.balanceOf(address(this)));
        //////////////////
        (bool os, ) = payable(msg.sender).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    receive() external payable {}
}

interface AggregatorV3Interface {
    function latestRoundData() external view returns (
        uint256 roundId,
        uint256 answer,
        uint256 startedAt,
        uint256 updatedAt,
        uint256 answeredInRound
    );
}