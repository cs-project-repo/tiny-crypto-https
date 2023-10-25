const mongoose = require('mongoose')

//Nullifer Hashes
const Nullifiers = new mongoose.Schema({
    hash:{
        type: String,
        required: true
    }
}) 

module.exports = mongoose.model('Nullifiers', Nullifiers)