var MerkleTools = require('./merkleTools')
var crypto = require('crypto')
var SHA256 = require('crypto-js/sha256')
const hash = require("circomlibjs").poseidon
const F = require("circomlibjs").babyjub.F
var JSONbig = require('json-bigint')
var JSONbigString = require('json-bigint')({ storeAsString: true })
var replace = require("replace")
const util = require('node:util');
const exec = util.promisify(require('node:child_process').exec)
const fs = require('fs')
const solc = require('solc')
const ethers = require('ethers')
const axios = require('axios')
require('dotenv').config({path: '../.env'})

const Proofs = require('../models/proofs')

async function zkpWithdraw(leaves, leaf, address, coin, amount, zeta, coinPreImage, amountPreImage, coins, recipient, network) {
    try{
        if(Array.isArray(leaves)){
            var treeOptions = {
                hashType: 'Poseidon'
              }
            var merkleTools = new MerkleTools(treeOptions)
            
            leaves.forEach((element) => {
                merkleTools.addLeaf(element)
            })
            
            merkleTools.makeTree()
            
            function _stdProof (array) {
                const hashes = []
                const selectors = []
                array.forEach((element) => {
                    if (element.right) {
                        hashes.push(element.right)
                        selectors.push(0)
                    } else if (element.left) {
                        hashes.push(element.left)
                        selectors.push(1)
                    }
                })
                return [selectors, hashes]
            }
            
            const root = merkleTools.getMerkleRoot()
            const position = leaves.indexOf(`${leaf}`)
            const proof = _stdProof(merkleTools.getProof(position))
            
            const rand =  Math.floor(Math.random() * 2**20)
            const folder = rand * rand
            const lambda = crypto.generatePrimeSync(16, {bigint: true})
        
            var jsonData = `{ "hashes": [${proof[1]}], "selectors": [${proof[0]}], "root": ${root}, "address": ${address}, "coin": ${coin}, "amount": ${amount}, "zeta": ${zeta}, "coinPreImage": ${coinPreImage}, "amountPreImage": ${amountPreImage}, "recipient": ${BigInt(parseInt(recipient, 16))}, "lambda": ${lambda} }`
            var jsonObj = JSONbigString.parse(jsonData)
            var jsonContent = JSONbigString.stringify(jsonObj)
            console.log(jsonContent)
        
            fs.writeFile(`./zkp/input${folder}.json`, jsonContent, 'utf8', function (err) {
                if (err) {
                    console.log("An error occured while writing JSON Object to File.")
                    return console.log(err)
                }
            
                return
            })
        
            const { stdout, stderr } = await exec(`cd zkp && mkdir ${folder} && cp circuit.circom execute.sh ./${folder} && mv input${folder}.json ./${folder} && cd ${folder} && mv input${folder}.json input.json && sed -i '' 's/replace/${proof[0].length}/g' circuit.circom && sh execute.sh ../server/zkp/execute.sh`);
            console.log('stdout:', stdout);
            console.error('stderr:', stderr);
        
            const output = fs.readFileSync(`./zkp/${folder}/circuit_js/output.txt`, 'utf-8').split(/[\]|\[|,|\s]+/)
            console.log(output)
        
            const sup = []
            const subA = []
            const subB = []
            const subBA = []
            const subBB = []
            const subC = []
            const subD = []
            const setArray = (arr) => {
                subA.push(arr[1].replace(/["]/g, ""))
                subA.push(arr[2].replace(/["]/g, ""))
        
                subBA.push(arr[3].replace(/["]/g, ""))
                subBA.push(arr[4].replace(/["]/g, ""))
        
                subBB.push(arr[5].replace(/["]/g, ""))
                subBB.push(arr[6].replace(/["]/g, ""))
        
                subB.push(subBA)
                subB.push(subBB)
        
                subC.push(arr[7].replace(/["]/g, ""))
                subC.push(arr[8].replace(/["]/g, ""))
        
                subD.push(arr[9].replace(/["]/g, ""))
        
                sup.push(subA)
                sup.push(subB)
                sup.push(subC)
                sup.push(subD)
        
                return sup
            }
        
            const data = setArray(output)
        
            const privateKey = process.env.WALLET_PRIVATE_KEY
        
            const nodeArr = [process.env.ETH_NODE, process.env.POLYGON_NODE, process.env.BSC_NODE, process.env.AVAX_NODE, process.env.FTM_NODE]
        
            const provider = new ethers.providers.JsonRpcProvider(nodeArr[network])
            const wallet = new ethers.Wallet(privateKey, provider)
        
            const context = fs.readFileSync(`./zkp/${folder}/circuit_js/verifier.sol`, 'utf-8')
            const recontext = context.replace("^0.6.11", "^0.8.0")
            const input = {
                language: 'Solidity',
                sources: {
                    'verifier.sol': { content: recontext }
                },
                settings: {
                    outputSelection: { '*': { '*': ['*'] } }
                }
            }
            const compiler = JSON.parse(solc.compile(JSON.stringify(input)))
            
            const compiled = compiler.contracts['verifier.sol'].Verifier
            
            const abi = compiled.abi
            const bytecode = compiled.evm.bytecode.object
        
            const factory = new ethers.ContractFactory(abi, bytecode, wallet)
            const nonce = await provider.getTransactionCount('0x2cC9346350d95DFb07a3a65859360F3b4f0B0195')
            var overrides = {
                nonce: nonce
            };
            const contract = await factory.deploy(overrides)
        
            await contract.deployed()
            const verifier = contract.address
        
            const veriAbi = [
                {
                    "inputs": [],
                    "stateMutability": "nonpayable",
                    "type": "constructor"
                },
                {
                    "anonymous": false,
                    "inputs": [
                        {
                            "indexed": true,
                            "internalType": "bytes32",
                            "name": "id",
                            "type": "bytes32"
                        }
                    ],
                    "name": "ChainlinkCancelled",
                    "type": "event"
                },
                {
                    "anonymous": false,
                    "inputs": [
                        {
                            "indexed": true,
                            "internalType": "bytes32",
                            "name": "id",
                            "type": "bytes32"
                        }
                    ],
                    "name": "ChainlinkFulfilled",
                    "type": "event"
                },
                {
                    "anonymous": false,
                    "inputs": [
                        {
                            "indexed": true,
                            "internalType": "bytes32",
                            "name": "id",
                            "type": "bytes32"
                        }
                    ],
                    "name": "ChainlinkRequested",
                    "type": "event"
                },
                {
                    "anonymous": false,
                    "inputs": [
                        {
                            "indexed": true,
                            "internalType": "address",
                            "name": "from",
                            "type": "address"
                        },
                        {
                            "indexed": true,
                            "internalType": "address",
                            "name": "to",
                            "type": "address"
                        }
                    ],
                    "name": "OwnershipTransferRequested",
                    "type": "event"
                },
                {
                    "anonymous": false,
                    "inputs": [
                        {
                            "indexed": true,
                            "internalType": "address",
                            "name": "from",
                            "type": "address"
                        },
                        {
                            "indexed": true,
                            "internalType": "address",
                            "name": "to",
                            "type": "address"
                        }
                    ],
                    "name": "OwnershipTransferred",
                    "type": "event"
                },
                {
                    "inputs": [],
                    "name": "acceptOwnership",
                    "outputs": [],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "inputs": [
                        {
                            "internalType": "bytes32",
                            "name": "_requestId",
                            "type": "bytes32"
                        },
                        {
                            "internalType": "bool",
                            "name": "_proof",
                            "type": "bool"
                        }
                    ],
                    "name": "fulfill",
                    "outputs": [],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "inputs": [],
                    "name": "owner",
                    "outputs": [
                        {
                            "internalType": "address",
                            "name": "",
                            "type": "address"
                        }
                    ],
                    "stateMutability": "view",
                    "type": "function"
                },
                {
                    "inputs": [
                        {
                            "internalType": "address",
                            "name": "to",
                            "type": "address"
                        }
                    ],
                    "name": "transferOwnership",
                    "outputs": [],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "inputs": [
                        {
                            "internalType": "uint256[2]",
                            "name": "a",
                            "type": "uint256[2]"
                        },
                        {
                            "internalType": "uint256[2][2]",
                            "name": "b",
                            "type": "uint256[2][2]"
                        },
                        {
                            "internalType": "uint256[2]",
                            "name": "c",
                            "type": "uint256[2]"
                        },
                        {
                            "internalType": "uint256[1]",
                            "name": "input",
                            "type": "uint256[1]"
                        },
                        {
                            "internalType": "uint256",
                            "name": "_pid",
                            "type": "uint256"
                        },
                        {
                            "internalType": "address",
                            "name": "_verifierAddress",
                            "type": "address"
                        },
                        {
                            "internalType": "address",
                            "name": "_withdrawalAddress",
                            "type": "address"
                        },
                        {
                            "internalType": "uint256",
                            "name": "_amount",
                            "type": "uint256"
                        }
                    ],
                    "name": "withdraw",
                    "outputs": [
                        {
                            "internalType": "bytes32",
                            "name": "requestId",
                            "type": "bytes32"
                        }
                    ],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "inputs": [],
                    "name": "withdrawEth",
                    "outputs": [],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "inputs": [],
                    "name": "withdrawLink",
                    "outputs": [],
                    "stateMutability": "nonpayable",
                    "type": "function"
                },
                {
                    "stateMutability": "payable",
                    "type": "receive"
                }
            ]
        
            const coinAbi = [
                {
                  "constant": true,
                  "inputs": [],
                  "name": "name",
                  "outputs": [
                    {
                      "name": "",
                      "type": "string"
                    }
                  ],
                  "payable": false,
                  "type": "function"
                },
                {
                  "constant": true,
                  "inputs": [],
                  "name": "decimals",
                  "outputs": [
                    {
                      "name": "",
                      "type": "uint8"
                    }
                  ],
                  "payable": false,
                  "type": "function"
                },
                {
                  "constant": true,
                  "inputs": [
                    {
                      "name": "_owner",
                      "type": "address"
                    }
                  ],
                  "name": "balanceOf",
                  "outputs": [
                    {
                      "name": "balance",
                      "type": "uint256"
                    }
                  ],
                  "payable": false,
                  "type": "function"
                },
                {
                  "constant": true,
                  "inputs": [],
                  "name": "symbol",
                  "outputs": [
                    {
                      "name": "",
                      "type": "string"
                    }
                  ],
                  "payable": false,
                  "type": "function"
                }
            ]
        
            const coinArr = ["USDT", "USDC", "ETH", "WBTC", "MATIC", "BNB", "AVAX", "DAI", "FTM", "BUSD", "WETH"]
            const coinIdArr = ["tether", "usd-coin", "ethereum", "wrapped-bitcoin", "polygon", "binance-coin", "avalanche", "multi-collateral-dai", "fantom", "binance-usd", "ethereum"]
            const coinStack = []
            coins.forEach(element => {
                const index = coinArr.indexOf(element)
                coinStack.push(index)
            })
            const coinOne = axios.get(`https://api.coincap.io/v2/assets/${coinIdArr[coinStack[0]]}`)
            const coinTwo = axios.get(`https://api.coincap.io/v2/assets/${coinIdArr[coinStack[1]]}`)
            axios.all([coinOne, coinTwo])
            .then(async(results) => {
                const arr = []
                results.forEach((ele) => {
                    arr.push(ele.data.data.priceUsd)
                })
                const quant = ethers.utils.formatUnits(amountPreImage, 10)
                const am = (Number(arr[0]) / Number(arr[1])) * Number(quant)
        
                const cArr = [
                    ["ETH", "USDT", "USDC", "WBTC", "MATIC", "BNB", "DAI"],
                    ["MATIC", "USDT", "USDC", "WETH", "WBTC", "BNB", "DAI"],
                    ["BNB", "USDT", "USDC", "ETH", "MATIC", "AVAX", "DAI"],
                    ["AVAX", "USDT", "USDC", "WETH", "WBTC", "BUSD", "DAI"],
                    ["FTM", "USDC", "ETH", "WBTC", "BNB", "BUSD", "DAI"],
                ]
        
                const tokConArr = [
                    ["*", "0xea94A0d934ddDBd14BdbE7DaE1202198F2883A37", "0x5d95625866A2BE73f1C6cEd51ebB52485836Ec58", "0x8455A41C4ac3a1B830DfEEEd3f1119d72b28e930", "0xAE9b38d823Ec580883b01aE066836eC3B5F52357", "0xaF1d9F53139683c46C931C65066F24A4eA915e1F", "0x0aE3fbba906F8cB5Ba71602516f3af9AeC3Ea1C4"],
                    ["*", "0xea94A0d934ddDBd14BdbE7DaE1202198F2883A37", "0x5d95625866A2BE73f1C6cEd51ebB52485836Ec58", "0x8455A41C4ac3a1B830DfEEEd3f1119d72b28e930", "0xAE9b38d823Ec580883b01aE066836eC3B5F52357", "0xaF1d9F53139683c46C931C65066F24A4eA915e1F", "0x0aE3fbba906F8cB5Ba71602516f3af9AeC3Ea1C4"],
                    ["*", "0xea94A0d934ddDBd14BdbE7DaE1202198F2883A37", "0x5d95625866A2BE73f1C6cEd51ebB52485836Ec58", "0x8455A41C4ac3a1B830DfEEEd3f1119d72b28e930", "0xAE9b38d823Ec580883b01aE066836eC3B5F52357", "0xaF1d9F53139683c46C931C65066F24A4eA915e1F", "0x0aE3fbba906F8cB5Ba71602516f3af9AeC3Ea1C4"],
                    ["*", "0xea94A0d934ddDBd14BdbE7DaE1202198F2883A37", "0x5d95625866A2BE73f1C6cEd51ebB52485836Ec58", "0x8455A41C4ac3a1B830DfEEEd3f1119d72b28e930", "0xAE9b38d823Ec580883b01aE066836eC3B5F52357", "0xaF1d9F53139683c46C931C65066F24A4eA915e1F", "0x0aE3fbba906F8cB5Ba71602516f3af9AeC3Ea1C4"],
                    ["*", "0xea94A0d934ddDBd14BdbE7DaE1202198F2883A37", "0x5d95625866A2BE73f1C6cEd51ebB52485836Ec58", "0x8455A41C4ac3a1B830DfEEEd3f1119d72b28e930", "0xAE9b38d823Ec580883b01aE066836eC3B5F52357", "0xaF1d9F53139683c46C931C65066F24A4eA915e1F", "0x0aE3fbba906F8cB5Ba71602516f3af9AeC3Ea1C4"],
                ]
        
                const vConArr = ["0x56615D280931E7d6eABA51D4e702a65047429212", "0x31b1F4E21610747148aBDf6aeEf169329D9fbB45", "0xAC89266674217cF2cE9972C37Ecc5c8Fcf7763C1", "0xEBdFD5ae9B33E2107800AFF00584589D03f1b61b", "0x6b605B16bAbabF0dE935d24ecAE1B681b550ca0D"]
        
                if(cArr[network].indexOf(coins[1]) == 0){
                    const quantity = ethers.utils.parseUnits(`${am}`, 18) 
        
                    const veriContract = new ethers.Contract(vConArr[network], veriAbi, wallet) 
                    veriContract.withdraw(data[0], data[1], data[2], data[3], cArr[network].indexOf(coins[1]), verifier, recipient, quantity)
                } else {
                    const token = new ethers.Contract(tokConArr[network][cArr[network].indexOf(coins[1])], coinAbi, provider)
                    const decimals = await token.decimals()
                    const quantity = ethers.utils.parseUnits(`${am}`, decimals) 
        
                    const veriContract = new ethers.Contract(vConArr[network], veriAbi, wallet) 
                    veriContract.withdraw(data[0], data[1], data[2], data[3], cArr[network].indexOf(coins[1]), verifier, recipient, quantity)
                }

                const proof = new Proofs({
                    hash: data[0][0]
                })
                const newProof = proof.save((err) => {
                    if(err){
                        throw new Error(err)
                    } else {
                        return
                    }
                })
        
                const { stdoutX, stderrX } = await exec(`rm -r ./zkp/${folder}`);
                console.log('stdout:', stdoutX);
                console.error('stderr:', stderrX);

            })
        }else{
            throw new Error()
        }
    }catch(err){
        console.log(err)
        throw new Error(err)
    }
}

// const partA = 9844309587340985708n
// const partB = 5326n
// const hashB = hash([partB])
// const partC = 1697564854n
// const hashC = hash([partC])
// const partD = 897049783204723874620348723984602973462038642380462384n
// const zero = `${hash([0, 0, 0, 0])}`
// const leafA = `${hash([partA, hashB, hashC, partD])}`
// const leafB = hash([partA, hashB, hashC, partD])

// const leaves = [zero, zero, leafA, zero, zero, zero]
// console.log(leafA, leafB)

// return zkpWithdraw(leaves, leafB, partA, hashB, hashC, partD, partB, partC, ["USDT", 'USDT'], '0x2cC9346350d95DFb07a3a65859360F3b4f0B0195', 0)

module.exports = zkpWithdraw;