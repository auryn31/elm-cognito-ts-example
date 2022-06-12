port module Cognito exposing (..)


port signup : { emailAddress : String, password : String, name : String } -> Cmd msg


port login : { emailAddress : String, password : String } -> Cmd msg


port errors : (String -> msg) -> Sub msg


port signupSuccess : ({ username : String } -> msg) -> Sub msg


port loginSuccess : (String -> msg) -> Sub msg


port logout : String -> Cmd msg
