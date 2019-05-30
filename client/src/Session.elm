module Session exposing (Session, changes, cred, fromViewer, navKey, viewer)

{-| This module stores the login state, viewer, and NavKey

A session is the broadest cross-page state that exists. It represents a
logged in/guest state, which may wrap a viewer, used for rendering things
like username. Sessions also contain the NavKey, essential for using links.

-}

import Api
import Browser.Navigation as Nav
import Cred exposing (Cred)
import Viewer exposing (Viewer)


type Session
    = LoggedIn Nav.Key Viewer
    | Guest Nav.Key


viewer : Session -> Maybe Viewer
viewer session =
    case session of
        LoggedIn _ val ->
            Just val

        Guest _ ->
            Nothing


cred : Session -> Maybe Cred
cred session =
    case session of
        LoggedIn _ val ->
            Just (Viewer.cred val)

        Guest _ ->
            Nothing


navKey : Session -> Nav.Key
navKey session =
    case session of
        LoggedIn key _ ->
            key

        Guest key ->
            key



-- CHANGES


changes : (Session -> msg) -> Nav.Key -> Sub msg
changes toMsg key =
    Api.viewerChanges (\maybeViewer -> toMsg (fromViewer key maybeViewer)) Viewer.decoder


fromViewer : Nav.Key -> Maybe Viewer -> Session
fromViewer key maybeViewer =
    -- It's stored in localStorage as a JSON String;
    -- first decode the Value as a String, then
    -- decode that String as JSON.
    case maybeViewer of
        Just viewerVal ->
            LoggedIn key viewerVal

        Nothing ->
            Guest key
