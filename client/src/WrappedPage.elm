module WrappedPage exposing (Page(..), view, viewErrors)

import Api exposing (Cred)
import Browser exposing (Document)
import Endpoint
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (Route)
import Session exposing (Session)
import Viewer exposing (Viewer)


{-| Determines which navbar link (if any) will be rendered as active.

Note that we don't enumerate every page here, because the navbar doesn't
have links for every page. Anything that's not part of the navbar falls
under Other.

-}
type Page
    = Other
    | Home
    | Item
    | Login


{-| Take a page's Html and frames it with a header and footer.

The caller provides the current user, so we can display in either
"signed in" (rendering username) or "signed out" mode.

isLoading is for determining whether we should show a loading spinner
in the header. (This comes up during slow page transitions.)

-}
view : Maybe Viewer -> Page -> { title : String, content : Html msg } -> Document msg
view maybeViewer page { title, content } =
    { title = title ++ " - Gear"
    , body =
        [ div [ class "flex flex-col" ]
            [ viewHeader page maybeViewer
            , viewContent content
            , viewFooter
            ]
        ]
    }


viewHeader : Page -> Maybe Viewer -> Html msg
viewHeader page maybeViewer =
    header [ class "flex-auto bg-gray-300 fixed top-0 w-full z-20" ]
        [ nav [ class "flex" ]
            [ ul [ class "" ] <|
                [ li [] [ a [ Route.href Route.Home ] [ text "Home" ] ]
                ]
                    ++ viewMenu page maybeViewer
            ]
        ]


viewMenu : Page -> Maybe Viewer -> List (Html msg)
viewMenu page maybeViewer =
    case maybeViewer of
        Just viewer ->
            [ li [] [ a [ Route.href Route.Logout ] [ text "Sign out" ] ]
            , span [] [ text <| "Username: " ++ Viewer.username viewer ]
            ]

        Nothing ->
            [ li [] [ a [ Route.href <| Route.Login Nothing ] [ text "Login" ] ]
            , span [] [ text "Not logged in" ]
            ]


viewContent : Html msg -> Html msg
viewContent content =
    div [ class "w-full mx-auto px-6 mt-20" ] [ content ]


viewFooter : Html msg
viewFooter =
    footer [] []


isActive : Page -> Route -> Bool
isActive page route =
    case ( page, route ) of
        ( Home, Route.Home ) ->
            True

        ( Item, Route.Item _ ) ->
            True

        ( Login, Route.Login _ ) ->
            True

        _ ->
            False


{-| Render dismissable errors. We use this all over the place!
-}
viewErrors : msg -> List String -> Html msg
viewErrors dismissErrors errors =
    if List.isEmpty errors then
        Html.text ""

    else
        div
            [ class "error-messages"
            , style "position" "fixed"
            , style "top" "0"
            , style "background" "rgb(250, 250, 250)"
            , style "padding" "20px"
            , style "border" "1px solid"
            ]
        <|
            List.map (\error -> p [] [ text error ]) errors
                ++ [ button [ onClick dismissErrors ] [ text "Ok" ] ]
