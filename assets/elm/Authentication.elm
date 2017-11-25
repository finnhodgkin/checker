module Authentication exposing (..)

import Html exposing (..)
import Html.Attributes as HA exposing (..)
import Html.Events exposing (..)
import Http exposing (..)
import Json.Decode as Decode exposing (Decoder, bool, dict, field, int, string)
import Json.Encode as JE exposing (Value, bool, int)
import Types exposing (..)


authenticateView : Model -> Html Msg
authenticateView model =
    a [ href "https://www.facebook.com/v2.11/dialog/oauth?client_id=1639208492813532&redirect_uri=http://localhost:4000/auth/facebook/callback" ]
        [ text "Log in with facebook" ]
