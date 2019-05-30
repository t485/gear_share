module Pages.Home exposing (Model, Msg, init, subscriptions, toSession, update, view)

import Api
import Endpoint
import Html exposing (..)
import Html.Attributes as Attr exposing (class)
import Http
import Item exposing (Item, itemsDecoder)
import Route
import Session exposing (Session)



-- MODEL


type alias Model =
    { session : Session
    , items : Status (List Item)
    }


type Status a
    = Loading
    | Loaded a
    | Failed


init : Session -> ( Model, Cmd Msg )
init session =
    ( { session = session

      -- , items = Loading
      , items = Failed
      }
      -- , fetchItems session
    , Cmd.none
    )


view : Model -> { title : String, content : Html Msg }
view model =
    { title = "Home"
    , content =
        case model.items of
            Loading ->
                text "loading..."

            Loaded items ->
                viewItems items

            Failed ->
                let
                    para t =
                        p [ class "text-red-500 m-8" ] [ text t ]
                in
                -- for testing
                viewItems
                    [ { name = "ice axe"
                      , owner = "richard liu"
                      , img = "//via.placeholder.com/200x200"
                      , description = "in solid condition"
                      , id = Item.Id "ioarns890xc"
                      }
                    , { name = "ice axe"
                      , owner = "richard liu"
                      , img = "//via.placeholder.com/200x200"
                      , description = "in solid condition"
                      , id = Item.Id "ioarns890xc"
                      }
                    , { name = "ice axe"
                      , owner = "richard liu"
                      , img = "//via.placeholder.com/200x200"
                      , description = "in solid condition"
                      , id = Item.Id "ioarns890xc"
                      }
                    ]
    }


viewItems : List Item -> Html Msg
viewItems items =
    let
        viewItem : Item -> Html Msg
        viewItem item =
            div [ class "container m-auto flex flex-row my-8 p-4 rounded-lg bg-gray-300" ]
                [ div [ class "flex-initial mr-4" ] [ img [ Attr.src item.img ] [] ]
                , div [ class " flex-auto" ]
                    [ h2 []
                        [ a [ Route.href (Route.Item item.id) ] [ text item.name ] ]
                    , span [] [ text <| "Owner: " ++ item.owner ]
                    , p [] [ text item.description ]
                    ]
                ]
    in
    div [] <| List.map viewItem items



-- UPDATE


type Msg
    = GotItems (Result Http.Error (List Item))
    | GotSession Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        GotItems (Ok items) ->
            ( { model | items = Loaded items }, Cmd.none )

        GotItems (Err _) ->
            ( { model | items = Failed }, Cmd.none )

        GotSession session ->
            ( { model | session = session }, Cmd.none )



-- HTTP


fetchItems : Session -> Cmd Msg
fetchItems session =
    Api.get
        Endpoint.items
        (Session.cred session)
        (Http.expectJson GotItems itemsDecoder)



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    Session.changes GotSession (Session.navKey model.session)



-- EXPORT


toSession : Model -> Session
toSession model =
    model.session
