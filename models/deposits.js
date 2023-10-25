const mongoose = require('mongoose')

//Deposit Hashes
const Deposits = new mongoose.Schema({
    hash:{
        type: String,
        required: true
    }
}) 

module.exports = mongoose.model('Deposits', Deposits)
