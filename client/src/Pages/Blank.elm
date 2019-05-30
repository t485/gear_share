module Pages.Blank exposing (view)

import Html exposing (..)


view : { title : String, content : Html msg }
view =
    { title = ""
    , content = p [] [ text "[blank page]" ]
    }
