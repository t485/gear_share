module WrappedPage exposing (Page(..), view, viewErrors)

import Browser exposing (Document)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick)
import Route exposing (Route)
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
        [ div [ class "" ]
            [ viewHeader page maybeViewer
            , viewContent content
            , viewFooter
            ]
        ]
    }


viewHeader : Page -> Maybe Viewer -> Html msg
viewHeader page maybeViewer =
    header [ class "fixed bg-gray-300 top-0 w-full z-20 shadow-md py-2" ]
        [ nav [ class "flex flex-row" ]
            [ ul [ class "flex flex-row flex-grow" ] <| viewNavMenu page
            , ul [ class "flex flex-row" ] <| viewUserMenu page maybeViewer
            ]
        ]


viewLogo : Html msg
viewLogo =
    div [ class "m-1 mx-8 font-bold text-2xl inline" ]
        [ span [ class "text-green-600" ] [ text "T" ]
        , span [] [ text "485" ]
        ]


{-| Renders the page links and highlights the active one
-}
viewNavMenu : Page -> List (Html msg)
viewNavMenu page =
    let
        menuItem =
            viewMenuItem page
    in
    [ viewLogo
    , menuItem Route.Home "Home"
    , menuItem Route.Home "other Home"
    ]


{-| Renders the menu items that are customized based on the user
-}
viewUserMenu : Page -> Maybe Viewer -> List (Html msg)
viewUserMenu page maybeViewer =
    let
        menuItem =
            viewMenuItem page
    in
    case maybeViewer of
        Just viewer ->
            [ menuItem Route.Logout "Sign out"
            , viewMenuItemText <| "Username: " ++ Viewer.username viewer
            ]

        Nothing ->
            [ menuItem Route.Login "Login"
            , viewMenuItemText "Not logged in"
            ]


viewMenuItemBase : Html msg -> Html msg
viewMenuItemBase content =
    li
        [ class "flex-auto m-3 flex-grow-0" ]
        [ content ]


viewMenuItem : Page -> Route.Route -> String -> Html msg
viewMenuItem page route linkText =
    let
        active =
            isActive page route
    in
    viewMenuItemBase <|
        a
            [ class <|
                "p-2 rounded-lg border-2 hover:bg-gray-100 hover:border-blue-500 trans trans-fast "
                    ++ (if active then
                            "border-blue-300"

                        else
                            ""
                       )
            , Route.href route
            ]
            [ text linkText ]


viewMenuItemText : String -> Html msg
viewMenuItemText spanText =
    viewMenuItemBase <| span [] [ text spanText ]


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

        ( Login, Route.Login ) ->
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
