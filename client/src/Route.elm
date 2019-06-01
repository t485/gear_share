module Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation as Nav
import Html exposing (Attribute)
import Html.Attributes as Attr
import Item
import Url exposing (Url)
import Url.Parser as Parser exposing ((</>), Parser, oneOf, s)



-- ROUTING


type Route
    = Home
    | Root
    | Login
    | Logout
    | Item Item.Id
    | Add


parser : Parser (Route -> a) a
parser =
    oneOf
        [ Parser.map Home Parser.top
        , Parser.map Login (s "login")
        , Parser.map Logout (s "logout")
        , Parser.map Item (s "item" </> Item.idParser)
        , Parser.map Add (s "item")
        ]



-- PUBLIC HELPERS


href : Route -> Attribute msg
href targetRoute =
    Attr.href (routeToString targetRoute)


replaceUrl : Nav.Key -> Route -> Cmd msg
replaceUrl key route =
    Nav.replaceUrl key (routeToString route)


fromUrl : Url -> Maybe Route
fromUrl url =
    Parser.parse parser url



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Root ->
                    []

                Login ->
                    [ "login" ]

                Logout ->
                    [ "logout" ]

                Item id ->
                    [ "item", Item.idToString id ]

                Add ->
                    [ "add" ]
    in
    "/" ++ String.join "/" pieces
