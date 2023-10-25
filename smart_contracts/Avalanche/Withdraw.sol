// SPDX-License-Identifier: MIT
/*  __    __                                      
   / /_  / /_    ____ ___  ____  ____  ____  __  __
  / __ \/ __ \  / __ `__ \/ __ \/ __ \/ _  \/ / / /
 / /_/ / / / / / / / / / / /_/ / / / /  __ / /_/ / 
/_.___/_/ /_(_)_/ /_/ /_/\____/_/ /_/\____/\__, /  
                                          /____/  */
                                          
pragma solidity ^0.8.7;

import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/security/ReentrancyGuard.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "@chainlink/contracts/src/v0.8/ChainlinkClient.sol";
import "@chainlink/contracts/src/v0.8/ConfirmedOwner.sol";

contract Withdraw is ReentrancyGuard, ChainlinkClient, ConfirmedOwner {
    using Chainlink for Chainlink.Request;
    //////////////////
    IERC20 internal USDT;
    IERC20 internal USDC;
    IERC20 internal WETH;
    IERC20 internal WBTC;
    IERC20 internal BUSD;
    IERC20 internal DAI;
    //////////////////
    address payable BH_LP;
    //////////////////
    bytes32 private jobId;
    uint256 private fee;

    struct Withdrawal {
        uint256 pid;
        address withdrawalAddress;
        uint256 amount;
    }

    constructor() ConfirmedOwner(msg.sender) {
        //////////////////
        USDT = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        USDC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        WETH = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        WBTC = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        BUSD = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10); 
        DAI = IERC20(0x56742334E387923B25dD4D4E1c5EEfBAcFba8E10);
        //////////////////
        BH_LP = payable(0xeBDD9094A91176ede38183621d80377E64aE853C);
        //////////////////
        setChainlinkToken(0x326C977E6efc84E512bB9C30f76E30c160eD06FB);
        setChainlinkOracle(0x29fdbBab1812644D9c440Bfd0d1778c417e566c0);
        jobId = "89e860e5d51b4075a753ca5f3d250577";
        fee = 0;
    }

    mapping(bytes32 => Withdrawal) internal withdrawals;

    function withdraw(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input,
        uint256 _pid,
        address _verifierAddress,
        address _withdrawalAddress,
        uint256 _amount
    ) public nonReentrant returns (bytes32 requestId) {
        bool result = Verifier(_verifierAddress).verifyProof(a, b, c, input);
        require(result, "Invalid Proof");
        
        Chainlink.Request memory req = buildChainlinkRequest(jobId, address(this), this.fulfill.selector);

        string memory proof = Strings.toString(a[0]); 

        req.add("proof", proof);

        requestId = sendChainlinkRequest(req, fee); 

        withdrawals[requestId] = Withdrawal(_pid, _withdrawalAddress, _amount);

        return requestId;
    }

    function fulfill(bytes32 _requestId, bool _proof) public recordChainlinkFulfillment(_requestId) {
        Withdrawal memory Tx = withdrawals[_requestId];

        require(_proof == false, "Proof has already been used!!");
        require(Tx.withdrawalAddress != address(0), "Fulfillment not found!!");
        require(Tx.amount > 0, "Fulfillment not found!!");

        uint256 _pid = Tx.pid;
        address _withdrawalAddress = Tx.withdrawalAddress;
        uint256 _amount = Tx.amount;

        require(_pid >= 0 || _pid <= 6, "Please Select Correct Token!!");
        if(_pid == 0) {
            (bool os, ) = payable(_withdrawalAddress).call{value : _amount}("");
            require(os,"Failed!!");
        }
        else if(_pid == 1) {
            USDT.transferFrom(BH_LP, _withdrawalAddress, _amount);
        }
        else if(_pid == 2) {
            USDC.transferFrom(BH_LP, _withdrawalAddress, _amount);
        }
        else if(_pid == 3) {
            WETH.transferFrom(BH_LP, _withdrawalAddress, _amount);
        }
        else if(_pid == 4) {
            WBTC.transferFrom(BH_LP, _withdrawalAddress, _amount);
        }
        else if(_pid == 5) {
            BUSD.transferFrom(BH_LP, _withdrawalAddress, _amount);
        }
        else if(_pid == 6) {
            DAI.transferFrom(BH_LP, _withdrawalAddress, _amount);
        }
        else{ revert("ERROR! Please Select Correct Id"); }

        withdrawals[_requestId].pid = 2**8;
        withdrawals[_requestId].withdrawalAddress = address(0);
        withdrawals[_requestId].amount = 0;
    }

    function withdrawLink() public onlyOwner {
        LinkTokenInterface link = LinkTokenInterface(chainlinkTokenAddress());
        require(link.transfer(msg.sender, link.balanceOf(address(this))), "Unable to transfer");
    }

    function withdrawEth() public onlyOwner {
        (bool os, ) = payable(msg.sender).call{value : address(this).balance}("");
        require(os,"Failed!!");
    }

    receive() external payable {}
}

abstract contract Verifier { 
    function verifyProof(
            uint[2] memory a,
            uint[2][2] memory b,
            uint[2] memory c,
            uint[1] memory input
        ) public virtual returns (bool r); 
}