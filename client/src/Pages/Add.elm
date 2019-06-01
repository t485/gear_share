module Pages.Add exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api
import Endpoint
import Html exposing (..)
import Html.Attributes as Attr
import Http
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    }


type Status a
    = Loading
    | Loaded a
    | Failed


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      }
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "add"
    , content = text "add page"
    }



-- UPDATE


type Msg
    = GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model | session = session }, Cmd.none )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
