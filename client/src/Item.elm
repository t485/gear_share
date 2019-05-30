module Item exposing (Id(..), Item, idParser, idToString, itemDecoder, itemsDecoder)

import Json.Decode as Decode exposing (Decoder, list, string)
import Json.Decode.Pipeline exposing (custom, required)
import Url.Parser


type Id
    = Id String


type alias Item =
    { name : String
    , owner : String
    , img : String
    , description : String
    , id : Id
    }



-- SERIALIZATION


singleItemDecoder : Decoder Item
singleItemDecoder =
    Decode.succeed Item
        |> required "name" string
        |> required "owner" string
        |> required "img" string
        |> required "description" string
        |> required "_id" (Decode.map Id string)


itemDecoder : Decoder Item
itemDecoder =
    Decode.succeed identity
        |> required "item" singleItemDecoder


itemsDecoder : Decoder (List Item)
itemsDecoder =
    Decode.succeed identity
        |> required "items" (list singleItemDecoder)



-- TRANSFORM


idParser : Url.Parser.Parser (Id -> a) a
idParser =
    Url.Parser.custom "id" (\str -> Just (Id str))


idToString : Id -> String
idToString (Id id) =
    id
