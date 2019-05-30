module Viewer exposing (Viewer(..), cred, decoder, profile, username)

{-| Stores enough information to render user-specific items

The logged-in user currently viewing this page. It stores enough data to
be able to render the menu bar (username and avatar), along with Cred so it's
impossible to have a Viewer if you aren't logged in.

-}

import Cred exposing (Cred)
import Json.Decode as Decode exposing (Decoder)
import Json.Decode.Pipeline exposing (required)
import Profile exposing (Profile)



-- TYPES


type Viewer
    = Viewer Cred Profile



-- INFO


cred : Viewer -> Cred
cred (Viewer val _) =
    val


profile : Viewer -> Profile
profile (Viewer _ prof) =
    prof


username : Viewer -> String
username (Viewer _ prof) =
    Profile.username prof



-- SERIALIZATION


decoder : Decoder Viewer
decoder =
    Decode.succeed Viewer
        |> required "cred" Cred.decoder
        |> required "profile" Profile.decoder
