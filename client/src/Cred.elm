module Cred exposing (Cred, decoder, header)

{-| Credentials of the user

These credentials are used to authenticate the user when making api calls.
Currently the only credential is the authorization token.

-}

import Http
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)


{-| Cred is just the access token
-}
type Cred
    = Cred String


header : Cred -> Http.Header
header (Cred str) =
    Http.header "authorization" ("Bearer " ++ str)


decoder : Decoder Cred
decoder =
    Decode.succeed Cred
        |> required "token" Decode.string
