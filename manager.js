function Manager() {
    var savedVal
    return {
        init: function(value) {
            savedVal = value
        },
        exit: function() {
            return savedVal
        }
    };
}

module.exports = Manager