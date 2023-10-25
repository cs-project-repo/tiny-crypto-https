const mongoose = require('mongoose')

//Entangled Pairs
const HashMap = new mongoose.Schema({
    key:{
        type: String,
        required: true
    },
    value:{
        type: String,
        required: true
    }
}) 

module.exports = mongoose.model('HashMap', HashMap)