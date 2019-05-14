module Viewer exposing (Viewer(..), cred, decoder, store, username)

{-| The logged-in user currently viewing this page. It stores enough data to
be able to render the menu bar (username and avatar), along with Cred so it's
impossible to have a Viewer if you aren't logged in.
-}

import Api exposing (Cred)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)



-- TYPES


type Viewer
    = Viewer Cred



-- INFO


cred : Viewer -> Cred
cred (Viewer val) =
    val


username : Viewer -> String
username (Viewer val) =
    Api.username val



-- SERIALIZATION


decoder : Decoder (Cred -> Viewer)
decoder =
    Decode.succeed Viewer


store : Viewer -> Cmd msg
store (Viewer credVal) =
    Api.storeCredWith
        credVal
