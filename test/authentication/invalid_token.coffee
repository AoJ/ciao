
# Token Auth - Invalid Token
host: 'stage.bizzby.me'
path: '/auth/token'
method: 'POST'
headers:
  'Accept': 'application/json'
  'Content-Type': 'application/json'
body: 
  service: 'facebook'
  token: '43423'

# Bad Request
response.statusCode.should.equal 401

# Error message is provided
JSON.parse( response.body ).body.error.should.eql "Your facebook account must share the email address"