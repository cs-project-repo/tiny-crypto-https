const mongoose = require('mongoose')

//Nullifer Hashes
const Proofs = new mongoose.Schema({
    hash:{
        type: String,
        required: true
    }
}) 

module.exports = mongoose.model('Proofs', Proofs)