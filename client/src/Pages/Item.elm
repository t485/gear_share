module Pages.Item exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api
import Endpoint
import Html exposing (..)
import Html.Attributes as Attr
import Http
import Item exposing (Id(..), Item, itemDecoder)
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , item : Status Item
    }


type Status a
    = Loading
    | Loaded a
    | Failed


init : Session -> Id -> ( Model, Cmd Msg )
init session id =
    ( { session = session
      , item = Loading
      }
    , fetchItem session id
    )


view : Model -> { title : String, content : Html Msg }
view model =
    { title =
        case model.item of
            Loaded item ->
                item.name

            _ ->
                "Item"
    , content =
        case model.item of
            Loading ->
                text "loading..."

            Loaded item ->
                viewItem item

            Failed ->
                text "(home) failed to load items"
    }


viewItem : Item -> Html Msg
viewItem item =
    div [ Attr.style "margin" "15px" ]
        [ h2 [] [ text item.name ]
        , div [] [ img [ Attr.src item.img ] [] ]
        , span [] [ text <| "Owner: " ++ item.owner ]
        , p [] [ text item.description ]
        ]



-- UPDATE


type Msg
    = GotItem (Result Http.Error Item)
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotItem (Ok item) ->
            ( { model | item = Loaded item }, Cmd.none )

        GotItem (Err _) ->
            ( { model | item = Failed }, Cmd.none )

        GotSession session ->
            ( { model | session = session }, Cmd.none )



-- HTTP


fetchItem : Session -> Id -> Cmd Msg
fetchItem session (Id id) =
    Api.get
        (Endpoint.item id)
        (Session.cred session)
        (Http.expectJson GotItem itemDecoder)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
