module Endpoint exposing (Endpoint, item, items, request)

{-| Specifies url endpoints to send requests to

It is important that the individual strings of the endpoints are not exported,
but instead the Enpoint type. The special request in this module unwraps the
Enpoint. This way we ensure that every url only comes from this module.

-}

import Http


{-| Http.request, except it takes an Endpoint instead of a Url.
-}
request :
    { body : Http.Body
    , expect : Http.Expect a
    , headers : List Http.Header
    , method : String
    , timeout : Maybe Float
    , tracker : Maybe String
    , url : Endpoint
    }
    -> Cmd a
request config =
    Http.request
        { body = config.body
        , expect = config.expect
        , headers = config.headers
        , method = config.method
        , timeout = config.timeout
        , tracker = config.tracker
        , url = unwrap config.url
        }



-- TYPES


{-| Gets a url to the api. This is not publicly exposed, because we want to
make sure the only way to get one of these URLs is from this module.
-}
type Endpoint
    = Endpoint String


unwrap : Endpoint -> String
unwrap (Endpoint str) =
    str



-- REST ENDPOINTS


{-| Domain/root of the database, this is not exposed
-}
databaseRoot : String
databaseRoot =
    "https://gearshare.t485.org/api_v1"


items : Endpoint
items =
    Endpoint <| databaseRoot ++ "/items"


item : String -> Endpoint
item id =
    Endpoint <| databaseRoot ++ "/items/" ++ id
