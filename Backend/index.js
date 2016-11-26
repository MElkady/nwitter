
'use strict';
const port = process.env.PORT || 8080
const username = process.env.USERNAME
const password = process.env.PASSWORD
const bodyParser = require('body-parser')
const express = require('express')
const request = require('request')

const app = express()
app.use(bodyParser.urlencoded({ extended: false }))
app.use(bodyParser.json())

app.get('/', function(req, res){
	res.send('Hello....')
})

var _token = null

function getToken(callback) {
	if(_token != null) {
		return callback(null, _token)
	}
	request.post({
        url: 'https://api.twitter.com/oauth2/token',
        headers : {
			"Content-Type": "application/x-www-form-urlencoded",
            "Authorization" : "Basic " + new Buffer(username + ":" + password).toString("base64")
        },
		form: { 
			"grant_type": "client_credentials" 
		}
    }, function(error, response, body) {
        if (error) {
            console.log('Error sending messages: ', error)
            if (callback){
                return callback(error)
            }
        } else if (response.body.error) {
            console.log('Error: ', response.body.error)
            if (callback){
                return callback(response.body.error)
            }
        } else {
            if (callback){
				_token = JSON.parse(response.body).access_token
				if (_token) {
                	return callback(null, _token)
				}
				callback("Null token!", null)
            }
        }
    })
}

const apiRoutes = express.Router()
apiRoutes.get('/tweets', function(req, res) {
	if (!req.query.q) {
		return res.status(400).send({
			"status": 'ko'
		})
	}

	getToken(function(err, token){
		if(err) {
			return res.status(500).send({
				"status": 'ko',
				"error": err
			})
		}

		var url = "https://api.twitter.com/1.1/search/tweets.json?q=" + encodeURIComponent(req.query.q)
		if (req.query.count) {
			url += "&count=" + req.query.count
		} else {
			url += "&count=20"
		}
		if (req.query.max_id) {
			url += "&max_id=" + req.query.max_id
		}
		if (req.query.since_id) {
			url += "&since_id=" + req.query.since_id
		}
		request.get({
			url: url, 
			headers: {
				"Authorization" : "Bearer " + token
			}
		}, function(error, response, body){
			if(error) {
				return res.status(500).send({
					"status": 'ko',
				"error": error
				})
			}

			return res.send({
				"status": 'ok',
				"tweets": JSON.parse(response.body)
			})
		})
	})
	
})

app.use('/api', apiRoutes)
app.listen(port)
console.log('App running....')