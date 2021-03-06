module Main exposing (main)

import Api
import Browser exposing (Document)
import Browser.Navigation as Nav
import Html
import Json.Decode exposing (Value)
import Pages.Add as Add
import Pages.Blank as Blank
import Pages.Home as Home
import Pages.Item as Item
import Pages.Login as Login
import Route exposing (Route)
import Session exposing (Session)
import Url exposing (Url)
import Viewer exposing (Viewer)
import WrappedPage


type Model
    = Redirect Session
    | NotFound Session
    | Home Home.Model
    | Login Login.Model
    | Item Item.Model
    | Add Add.Model



-- MODEL


init : Maybe Viewer -> Url -> Nav.Key -> ( Model, Cmd Msg )
init maybeViewer url navKey =
    changeRouteTo
        (Route.fromUrl url)
        (Redirect <| Session.fromViewer navKey maybeViewer)



-- VIEW


view : Model -> Document Msg
view model =
    let
        -- Gets the viewer from the model
        viewer =
            Session.viewer (toSession model)

        --  Renders the page based on the content, viewer, and the msg
        viewPage page toMsg config =
            let
                { title, body } =
                    WrappedPage.view viewer page config
            in
            { title = title
            , body = List.map (Html.map toMsg) body
            }
    in
    case model of
        Home home ->
            viewPage WrappedPage.Home GotHomeMsg (Home.view home)

        Login login ->
            viewPage WrappedPage.Other GotLoginMsg (Login.view login)

        Item item ->
            viewPage WrappedPage.Item GotItemMsg (Item.view item)

        Add item ->
            viewPage WrappedPage.Other GotAddMsg (Add.view item)

        _ ->
            viewPage WrappedPage.Other (\_ -> NoOp) Blank.view



-- UPDATE


type Msg
    = ChangedUrl Url
    | ClickedLink Browser.UrlRequest
    | GotHomeMsg Home.Msg
    | GotLoginMsg Login.Msg
    | GotItemMsg Item.Msg
    | GotAddMsg Add.Msg
    | GotSession Session
    | NoOp


{-| Converts a model to a session
-}
toSession : Model -> Session
toSession page =
    case page of
        Redirect session ->
            session

        NotFound session ->
            session

        Home home ->
            Home.toSession home

        Item item ->
            Item.toSession item

        Add item ->
            Add.toSession item

        Login login ->
            Login.toSession login


changeRouteTo : Maybe Route -> Model -> ( Model, Cmd Msg )
changeRouteTo maybeRoute model =
    let
        session =
            toSession model
    in
    case maybeRoute of
        Nothing ->
            ( NotFound session, Cmd.none )

        Just Route.Root ->
            ( model, Route.replaceUrl (Session.navKey session) Route.Home )

        Just Route.Home ->
            Home.init session
                |> updateWith Home GotHomeMsg

        Just Route.Login ->
            Login.init session
                |> updateWith Login GotLoginMsg

        Just (Route.Item id) ->
            Item.init session id
                |> updateWith Item GotItemMsg

        Just Route.Add ->
            Add.init session
                |> updateWith Add GotAddMsg

        Just Route.Logout ->
            ( model, Api.logout )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case ( msg, model ) of
        ( ClickedLink urlRequest, _ ) ->
            case urlRequest of
                Browser.Internal url ->
                    ( model
                    , Nav.pushUrl (Session.navKey (toSession model)) (Url.toString url)
                    )

                Browser.External href ->
                    ( model
                    , Nav.load href
                    )

        ( ChangedUrl url, _ ) ->
            changeRouteTo (Route.fromUrl url) model

        ( GotHomeMsg subMsg, Home home ) ->
            Home.update subMsg home
                |> updateWith Home GotHomeMsg

        ( GotLoginMsg subMsg, Login login ) ->
            Login.update subMsg login
                |> updateWith Login GotLoginMsg

        ( GotSession session, Redirect _ ) ->
            ( Redirect session
            , Route.replaceUrl (Session.navKey session) Route.Home
            )

        ( GotItemMsg subMsg, Item item ) ->
            Item.update subMsg item
                |> updateWith Item GotItemMsg

        ( GotAddMsg subMsg, Add item ) ->
            Add.update subMsg item
                |> updateWith Add GotAddMsg

        ( _, _ ) ->
            -- Disregard messages that arrived for the wrong page.
            ( model, Cmd.none )


updateWith : (subModel -> Model) -> (subMsg -> Msg) -> ( subModel, Cmd subMsg ) -> ( Model, Cmd Msg )
updateWith toModel toMsg ( subModel, subCmd ) =
    ( toModel subModel
    , Cmd.map toMsg subCmd
    )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
    case model of
        NotFound _ ->
            Sub.none

        Redirect _ ->
            Session.changes GotSession (Session.navKey (toSession model))

        Home home ->
            Sub.map GotHomeMsg (Home.subscriptions home)

        Login login ->
            Sub.map GotLoginMsg (Login.subscriptions login)

        Item item ->
            Sub.map GotItemMsg (Item.subscriptions item)

        Add item ->
            Sub.map GotAddMsg (Add.subscriptions item)



-- MAIN


main : Program Value Model Msg
main =
    Api.application Viewer.decoder
        { init = init
        , onUrlChange = ChangedUrl
        , onUrlRequest = ClickedLink
        , subscriptions = subscriptions
        , update = update
        , view = view
        }
