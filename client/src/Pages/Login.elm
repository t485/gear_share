module Pages.Login exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api
import Cred exposing (Cred)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Route
import Session exposing (Session)
import Viewer



-- MODEL


type alias Model =
    { session : Session
    , cred : Maybe Cred
    }


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session
      , cred = Nothing
      }
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view model =
    let
        loginButton : Cmd Msg -> String -> Html Msg
        loginButton cmd title =
            p []
                [ button
                    [ onClick (SendCommand cmd)
                    , style "border" "1px solid cornflowerblue"
                    , style "border-radius" "5px"
                    , style "margin" "5px"
                    , style "padding" "5px"
                    ]
                    [ text title ]
                ]
    in
    { title = "Login"
    , content =
        div [ class "cred-page" ]
            [ h1 [ class "text-xs-center" ] [ text "Sign in" ]
            , loginButton Api.loginGoogle "Sign in with Google"
            , loginButton Api.loginPassword "Sign in with password"
            ]
    }



-- UPDATE


type Msg
    = GotSession Session
    | SendCommand (Cmd Msg)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotSession session ->
            ( { model
                | session = session
                , cred =
                    session
                        |> Session.viewer
                        |> Maybe.andThen (Viewer.cred >> Just)
              }
              -- TODO: maybe change where to redirect after user has logged in
              -- , Route.replaceUrl (Session.navKey session) Route.Home
            , Cmd.none
            )

        SendCommand cmd ->
            ( model, cmd )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
