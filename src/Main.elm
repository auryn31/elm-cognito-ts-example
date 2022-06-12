module Main exposing (..)

import Browser
import Cognito as Cognito
import Html exposing (..)
import Html.Attributes exposing (placeholder, style, type_, value)
import Html.Events exposing (onClick, onInput)



-- MAIN


main =
    Browser.element
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }



-- MODEL


type alias Model =
    { email : String
    , password : String
    , cognitoError : Maybe String
    , cognitoSuccess : Maybe String
    , currentUser : Maybe String
    }


init : { username : Maybe String } -> ( Model, Cmd Msg )
init initialState =
    ( { email = ""
      , password = ""
      , currentUser = initialState.username
      , cognitoError = Nothing
      , cognitoSuccess = Nothing
      }
    , Cmd.none
    )



-- UPDATE


type Msg
    = UpdateEmail String
    | UpdatePassword String
    | CognitoError String
    | CognitoSignupSuccess { username : String }
    | CognitoLoginSuccess String
    | LoginClicked
    | SignUpClicked
    | LogoutClicked


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        UpdateEmail email ->
            ( { model | email = email }
            , Cmd.none
            )

        UpdatePassword password ->
            ( { model | password = password }
            , Cmd.none
            )

        CognitoSignupSuccess user ->
            ( { model | cognitoSuccess = Just "Signup successfull", cognitoError = Nothing, currentUser = Just user.username }
            , Cmd.none
            )

        CognitoLoginSuccess user ->
            ( { model | cognitoSuccess = Just "Login successfull", cognitoError = Nothing, currentUser = Just user }
            , Cmd.none
            )

        CognitoError error ->
            ( { model | cognitoError = Just error }
            , Cmd.none
            )

        LoginClicked ->
            ( model
            , Cognito.login
                { emailAddress = model.email
                , password = model.password
                }
            )

        SignUpClicked ->
            ( model
            , Cognito.signup
                { emailAddress = model.email
                , password = model.password
                , name = model.email
                }
            )

        LogoutClicked ->
            ( { model | currentUser = Nothing }, Cognito.logout "" )



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions _ =
    Sub.batch
        [ Cognito.signupSuccess CognitoSignupSuccess
        , Cognito.errors CognitoError
        , Cognito.loginSuccess CognitoLoginSuccess
        ]



-- VIEW


view : Model -> Html Msg
view model =
    div bodyStyle
        [ h1 [] [ text "Login/Signup Cognito" ]
        , div [ style "max-width" "30rem" ]
            [ input [ onInput UpdateEmail, value model.email, placeholder "Email" ] []
            , input [ onInput UpdatePassword, value model.password, type_ "password", placeholder "Password" ] []
            , button [ onClick LoginClicked ] [ text "login" ]
            , button [ onClick SignUpClicked ] [ text "sign up" ]
            , button [ onClick LogoutClicked ] [ text "logout" ]
            ]
        , p [] [ text "current user: ", text (Maybe.withDefault "" model.currentUser) ]
        , p [ style "color" "green" ] [ text "Login/Signup State: ", text (Maybe.withDefault "None" model.cognitoSuccess) ]
        , p [ style "color" "red" ] [ text "Error State: ", text (Maybe.withDefault "None" model.cognitoError) ]
        ]


bodyStyle : List (Attribute msg)
bodyStyle =
    [ style "margin" "2rem"
    , style "display" "flex"
    , style "align-items" "center"
    , style "flex-direction" "column"
    ]
