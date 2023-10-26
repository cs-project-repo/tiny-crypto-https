require('dotenv').config()
const express = require('express')
const cors = require('cors')
const rateLimit = require('express-rate-limit')
const mongoose = require('mongoose')
const https = require ("https");
const path = require ("path");
const fs = require ("fs");

const app = express()
mongoose.connect(process.env.DATABASE_URL)
const db = mongoose.connection

db.on('error', (error) => console.error(error))
db.once('open', () => console.log('Connected to DB'))

app.use(cors({ origin: '*' }))

const limiter = rateLimit({
	windowMs: 60 * 60 * 1000, 
	max: 10, //** */
	standardHeaders: true, 
	legacyHeaders: false,
})

app.use(limiter)

app.use(express.json({ limit: "100mb" }))

const router = require('./routes/routes')
app.use('/routes', router)

const port = 8080

const privateKey = fs.readFileSync('/etc/letsencrypt/live/www.zkpserver.xyz/privkey.pem', 'utf8');
const certificate = fs.readFileSync('/etc/letsencrypt/live/www.zkpserver.xyz/cert.pem', 'utf8');
const ca = fs.readFileSync('/etc/letsencrypt/live/www.zkpserver.xyz/chain.pem', 'utf8');

const credentials = {
	key: privateKey,
	cert: certificate,
	ca: ca
};

https.createServer(credentials, app).listen(port, () => {
	console.log(`HTTPS Server running on port ${port}`);
});