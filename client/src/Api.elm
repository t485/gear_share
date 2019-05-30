port module Api exposing (application, get, loginGoogle, loginPassword, logout, viewerChanges)

{-| Communicates with JS for authentication and constructs requests

This module uses ports to send auth requests to JS, as well as listen for auth
changes. It also exports an application, which has an init function that is
passed the viewer on startup.

Requests can be made in this module as well, although that may be split into a
separate module (TODO)

-}

import Browser
import Browser.Navigation as Nav
import Cred exposing (Cred)
import Endpoint exposing (Endpoint)
import Http exposing (Expect)
import Json.Decode as Decode exposing (Decoder, Value, string)
import Json.Encode as Encode
import Url exposing (Url)



-- PORTS


{-| Request to javascript that the auth status be changed
-}
port requestAuth : Value -> Cmd msg


{-| Encodes an auth request with a string for the login/logout type (google or password)
-}
authRequestEncoder : String -> Value
authRequestEncoder type_ =
    Encode.object
        [ ( "type", Encode.string type_ ) ]


{-| Command to redirect user to the login page for google
-}
loginGoogle : Cmd msg
loginGoogle =
    (authRequestEncoder >> requestAuth) "login_google"


{-| Command to redirect user to the login page for username and password
-}
loginPassword : Cmd msg
loginPassword =
    (authRequestEncoder >> requestAuth) "login_password"


{-| Command to logout
-}
logout : Cmd msg
logout =
    (authRequestEncoder >> requestAuth) "logout"


{-| Receives an auth state change from javascript
-}
port receiveAuth : (Value -> msg) -> Sub msg


{-| Listens for changes in the viewer received from the `receiveAuth` port.
Requires a decoder for the viewer and a function to transform it into a msg.
-}
viewerChanges : (Maybe viewer -> msg) -> Decoder viewer -> Sub msg
viewerChanges toMsg decoder =
    {- let
           handleError : Result Decode.Error viewer -> Maybe viewer
           handleError result =
               case result of
                   Ok viewer ->
                       Just viewer

                   Err error ->
                       let
                           _ =
                               Debug.log "viewer decoding error" <| Decode.errorToString error
                       in
                       Nothing
       in
       receiveAuth (Decode.decodeValue decoder >> handleError >> toMsg)
    -}
    receiveAuth (Decode.decodeValue decoder >> Result.toMaybe >> toMsg)



-- APPLICATION


{-| Browser application, except that a viewer decoder must be provided to parse
the viewer passed in via the flags
-}
application :
    Decoder viewer
    ->
        { init : Maybe viewer -> Url -> Nav.Key -> ( model, Cmd msg )
        , onUrlChange : Url -> msg
        , onUrlRequest : Browser.UrlRequest -> msg
        , subscriptions : model -> Sub msg
        , update : msg -> model -> ( model, Cmd msg )
        , view : model -> Browser.Document msg
        }
    -> Program Value model msg
application viewerDecoder config =
    let
        init flags url navKey =
            config.init
                (flags
                    |> Decode.decodeValue viewerDecoder
                    |> Result.toMaybe
                )
                url
                navKey
    in
    Browser.application
        { init = init
        , onUrlChange = config.onUrlChange
        , onUrlRequest = config.onUrlRequest
        , subscriptions = config.subscriptions
        , update = config.update
        , view = config.view
        }



-- HTTP


{-| Base http request given endpoint and cred
-}
baseRequest :
    { method : String
    , url : Endpoint
    , expect : Expect msg
    , cred : Maybe Cred
    , body : Http.Body
    }
    -> Cmd msg
baseRequest options =
    Endpoint.request
        { method = options.method
        , url = options.url
        , expect = options.expect
        , headers =
            case options.cred of
                Just cred ->
                    [ Cred.header cred ]

                Nothing ->
                    []
        , body = options.body
        , timeout = Nothing
        , tracker = Nothing
        }


{-| Simple get request
-}
get : Endpoint -> Maybe Cred -> Expect msg -> Cmd msg
get url maybeCred expect =
    baseRequest
        { method = "GET"
        , url = url
        , expect = expect
        , cred = maybeCred
        , body = Http.emptyBody
        }
