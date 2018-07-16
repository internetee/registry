# Authentication

## Authenticating with mobileID or ID-card

For specified partners the API allows for use of data from mobile ID for
authentication. API client should perform authentication with eID according to
the approriate documentation, and then pass on values from the webserver's
certificate to the API server.

## POST /repp/v1/registrant/auth/eid

Returns a bearer token to be used for further API requests. Tokens are valid for 2 hours since their creation.

#### Paramaters

Values in brackets represent values that come from the id card certificate.

| Field name        | Required | Type   | Allowed values              | Description                                       |
| ----------------- | -------- | ----   | --------------              | -----------                                       |
| ident             | true     | String |                             | Identity code of the user (`serialNumber`)        |
| first_name        | true     | String |                             | Name of the customer (`GN`)                       |
| last_name         | true     | String |                             | Name of the customer (`SN`)                       |
| country           | true     | String | 'ee'                        | Code of the country that issued the id card (`C`) |
| issuing authority | true     | String | 'AS Sertifitseerimiskeskus' |                                                   |
|                   |          |        |                             |                                                   |


#### Request
```
POST /repp/v1/auth/token HTTP/1.1
Accept: application/json
Content-length: 0
Content-type: application/json

{
  "ident": "30110100103",
  "first_name": "Jan",
  "last_name": "Tamm",
  "country": "ee",
  "issuing authority": "AS Sertifitseerimiskeskus"
}
```

#### Response
```
HTTP/1.1 201
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 0
Content-Type: application.json


{
  "access_token": "<SOME TOKEN>",
  "expires_at": "2018-07-13 11:30:51 UTC",
  "type": "Bearer"
}
```

## POST /repp/v1/auth/username -- NOT IMPLEMENTED

#### Paramaters

Values in brackets represent values that come from the id card certificate

| Field name        | Required | Type   | Allowed values                   | Description |
| ----------------- | -------- | ----   | --------------                   | ----------- |
| username          | true     | String | Username as provided by the user |             |
| password          | true     | String | Password as provided by the user |             |


#### Request
```
POST /repp/v1/auth/token HTTP/1.1
Accept: application/json
Content-length: 0
Content-type: application/json
```

#### Response
```
HTTP/1.1 201
Cache-Control: max-age=0, private, must-revalidate
Content-Length: 0
Content-Type: application.json


{
  "access_token": "<SOME TOKEN>",
  "expires_at": "2018-07-13 11:30:51 UTC",
  "type": "Bearer"
}
```

## Implementation notes:

We do not need to store the session data at all, instead we can levarage AES encryption and use
Rails secret as the key. General approximation:

```ruby
class AuthenticationToken
  def initialize(secret = Rails.application.config.secret_key_base, values = {})
  end

  def create_token_hash
    data = values.to_s

    cipher = OpenSSL::Cipher::AES.new(256, :CBC)
    cipher.encrypt

    encrypted = cipher.update(data) + cipher.final
    base64_encoded = Base64.encode64(encrypted)

    {
      token: base64_encoded,
      expires_in = values[:expires_in]
      type: "Bearer"
    }
  end
end
```
