const express = require('express')
const axios = require('axios')
const ethers = require('ethers')
// const ImmudbClient = require('immudb-node')
const SHA256 = require('crypto-js/sha256')
const hash = require("circomlibjs").poseidon
const router = express.Router()
var JSONbig = require('json-bigint')
var JSONbigString = require('json-bigint')({ storeAsString: true })

const Deposits = require('../models/deposits')
const Nullifiers = require('../models/nullifiers')
const Proofs = require('../models/proofs')
const HashMap = require('../models/hashmap')

const man = require('../manager')()
const zkpWithdraw = require('../zkp/merkleTree.js')

// const IMMUDB_HOST = process.env.IMMUDB_HOST
// const IMMUDB_PORT = process.env.IMMUDB_PORT
// const IMMUDB_USER = process.env.IMMUDB_USER
// const IMMUDB_PWD = process.env.IMMUDB_PWD

// const cl = new ImmudbClient.default({
//   host: IMMUDB_HOST,
//   port: IMMUDB_PORT,
// })

// router.post('/seeder', async (req, res) => {
//     const data = await Deposits.distinct("hash")
//     res.status(200).json({"message": data.length})
// }) 

router.post('/deposit', /*chainScannerFunc,*/ async (req, res) => {
    try{
        // const loginReq = { user: IMMUDB_USER, password: IMMUDB_PWD }
        // await cl.login(loginReq)

        // const useDatabaseReq = { databasename: "deposits" }
        // await cl.useDatabase(useDatabaseReq) 

        req.body.addresses.forEach(async (address) => {
            const coin = hash([req.body.coin])
            const amount = hash([req.body.amount])
            const leaf = hash([address, coin, amount, req.body.zeta])
            const deposit = new Deposits({
                hash: leaf
            })
            const newDeposit = deposit.save((err) => {
                if(err){
                    res.status(500).json({"message": 500})
                } else {
                    return
                }
            })

            // const setReq = { key: leaf, value: '0x000' }
            // await cl.set(setReq)
        })
        res.status(200).json({"message": "success"})
    }catch (err){
        res.status(400).json({"message": 400})
    }
})

router.post('/withdraw', async (req, res) => {
   try{
    // const loginReq = { user: IMMUDB_USER, password: IMMUDB_PWD }
    // await cl.login(loginReq)

    // const useDatabaseReq = { databasename: "nullifiers" }
    // await cl.useDatabase(useDatabaseReq)

    const nullHash = hash([req.body.address, req.body.zeta]) 
    const n = await Nullifiers.find({hash: nullHash}).count()
    if(n>=1){
        res.status(400).json({"message": 400})
        console.log(nullHash, n)
    }else{
        const leaves = []
        const data = await Deposits.find({})
        data.forEach(leaf => {
            leaves.push(leaf.hash)
        })
        const coin = hash([req.body.coin])
        const amount = hash([req.body.amount])
        const leaf = hash([req.body.address, coin, amount, req.body.zeta])
        await zkpWithdraw(leaves, leaf, req.body.address, coin, amount, req.body.zeta, req.body.coin, req.body.amount, req.body.coins, req.body.recipient, req.body.network)
        const nullifier = new Nullifiers({
            hash: nullHash
        })
        const newNullifier = nullifier.save((err) => {
            if(err){
                res.status(500).json({"message": 500})
            } else {
                return
            }
        })

        // const setReq = { key: nullHash, value: '0x000' }
        // await cl.set(setReq)

        res.status(200).json({"message": "success"})
    }
   }catch(err){
    res.status(500).json({"message": 500})
    console.log(err)
   }
})

//

router.post('/send', async (req, res) => {
    const proof = new Proofs({
        hash: req.query.entry
    })
    const newProof = proof.save((err) => {
        if(err){
            res.status(500).json({"message": 500})
        } else {
            return
        }
    })
})

router.post('/receive', async (req, res) => {
    const data = await Proofs.find({})
    res.status(200).json({"message": data})
})

router.post('/test', async (req, res) => {
    res.status(200).json({"message": "success"})
})

//

router.get('/proofs', async (req, res) => {
    const proofs = []
    const data = await Proofs.find({})
    data.forEach(proof => {
        proofs.push(parseInt(proof.hash, 16))
    })
    if(proofs.includes(parseInt(req.query.proof, 16))){
        res.status(200).json({"message": true})
    }else{
        res.status(200).json({"message": false})
    }
})

router.post('/ai', async (req, res) => {
    try{
        const ocr = "http://127.0.0.1:8000/OCR"
        const fmm = "http://127.0.0.1:8000/FMM"
        const lod = "http://127.0.0.1:8000/LOD"
        const ird = "http://127.0.0.1:8000/IRD"

        const img1 = req.body.img1.replace(/^data:image\/(png|jpg);base64,/,"")
        const img2 = req.body.img2.replace(/^data:image\/(png|jpg);base64,/,"")

        const ocrCall = axios.post(ocr, {
            img1: img1,
            str1: req.body.str1,
            str2: req.body.str2,
            str3: req.body.str3
        })  
        const fmmCall = axios.post(fmm, {
            img1: img1,
            img2: img2
        })
        const lodCall = axios.post(lod, {
            img1: img1,
        })
        const irdCall = axios.post(ird, {
            img1: img1,
        })

        axios.all([ocrCall, fmmCall, lodCall, irdCall])
        .then(function (results) {
            const array = []
            results.forEach((element) => {
                array.push(element.data)
            })
            if(array.includes('Failed')){
                res.status(400).json({"message": 400})
            } else {
                res.status(200).json({"message": 200})
            }
        });
    } catch(err) {
        res.status(500).json({"message": 500})
    }
})

////

function chainScannerFunc (req, res, next) {
    try{
        const chainArr = ["ETH", "MATIC", "BSC", "AVAX", "FTM"]
        const chain = chainArr.indexOf(req.body.chain)
        const chainAPI = [process.env.ETHER_API_KEY, process.env.POLYGON_API_KEY, process.env.BSC_API_KEY, process.env.AVAX_API_KEY, process.env.FTM_API_KEY]
        const site = ["etherscan.io", "polygonscan.com", "bscscan.com", "snowtrace.io", "ftmscan.com"]
        
        axios.get(`https://api.${site[chain]}/api?module=transaction&action=gettxreceiptstatus&txhash=${req.body.txAddress}&apikey=${chainAPI[chain]}`)
        .then((response) => {
            if(response.data.result.status == 1){
                next()
                return
            }else{
                res.status(500).json({"message": 500})
            }
        })
        res.status(200).json({"message": 200})
    } catch(err) {
        res.status(500).json({"message": 500})
    }
}


module.exports = router