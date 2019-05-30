module Profile exposing (Profile, bio, decoder, encode, username)

import Json.Decode as Decode exposing (Decoder, string)
import Json.Decode.Pipeline exposing (required)
import Json.Encode as Encode exposing (Value)



-- TYPES


{-| Profile contains user's username and bio information
-}
type alias Profile =
    { username : String
    , bio : String
    }



-- CREATE


decoder : Decoder Profile
decoder =
    Decode.succeed Profile
        |> required "username" string
        |> required "bio" string



-- TRANSFORM


encode : Profile -> Value
encode profile =
    Encode.object
        [ ( "username", Encode.string profile.username )
        , ( "bio", Encode.string profile.bio )
        ]


username : Profile -> String
username profile =
    profile.username


bio : Profile -> String
bio profile =
    profile.bio
