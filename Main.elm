import Html exposing (..)
import Html.Events exposing (..)
import Html.Attributes exposing (..)
import WebSocket exposing (..)
import Api exposing (..)
import Types exposing (..)

main: Program Never Model Msg
main =
    Html.program {
        init = init,
        view = view,
        update = update,
        subscriptions = subscriptions
    }

-- MODEL

type alias Model = {
    members : List UserName,  
    chatlog : List ChatMessage,
    user : {
        username : UserName,
        currentInput : String
    }
}

init : (Model, Cmd Msg)
init =
    ( Model ["asdf"] [] {username="asdf", currentInput=""}, Cmd.none)

-- UPDATE


addUser  : String -> Model -> Model
addUser username model = Model (username :: model.members) model.chatlog model.user

removeUser : String -> Model -> Model  
removeUser username model = 
    let 
        isUser = \user -> user == username  
        users = List.filter isUser model.members
    in 
        Model users model.chatlog model.user

updateMessages : ChatMessage ->  Model -> Model
updateMessages message model = Model model.members (message :: model.chatlog) model.user

clearInput : Model -> Model
clearInput model = Model model.members model.chatlog {username=model.user.username, currentInput=""}

update : Msg -> Model -> (Model, Cmd Msg) 
update msg model = 
    case msg of
        NewUser username ->
            (addUser username model, Cmd.none)
        
        NewMessage message ->
            let 
                out = (updateMessages message >> clearInput)
            in 
                (out model, Cmd.none)

        UserInput input ->
            (Model model.members model.chatlog {username=model.user.username, currentInput=input}, Cmd.none)

        WebsocketResponse response ->
            case getResponseAction response of 
                ApiHeartbeat data -> 
                    (model, Cmd.none)
                ApiNewUser name userCount ->
                    (addUser name model, Cmd.none)
                ApiNewMessage username message ->
                    (updateMessages (Message username message) model, Cmd.none)
                ApiUserLeft username userCount ->
                    (removeUser username model, Cmd.none)
                ApiError error ->
                    (model, Cmd.none)

                    


onClickSend : { b | user : { a | currentInput : String, username : UserName } }
    -> Msg
onClickSend model = NewMessage (Message model.user.username model.user.currentInput)

displayChatMessage : ChatMessage -> String
displayChatMessage message = 
    let (Message username input) = message in 
        username ++ ": " ++ input ++ "\n"


-- SUBSCRIPTIONS
subscriptions : Model -> Sub Msg
subscriptions model =
  subscribeApi 


-- VIEW
chatBoxStyle : Html.Attribute Msg
chatBoxStyle = style
    [
        ("height", "500px"),
        ("width","100%"),
        ("border-radius","5px"),
        ("background-color", "#e2cbae")
    ]


chatBox : Model -> Html Msg
chatBox model =
    div [ chatBoxStyle ]
        (let 
            foldHtml = \next html -> div [] [ text next ] :: html
            stringified = List.map displayChatMessage model.chatlog
        in
            List.foldl foldHtml [] stringified
        )


chatInputStyle : Html.Attribute Msg 
chatInputStyle = style 
    [
        ("height", "150px"),
        ("width", "100%"),
        ("border-radius", "5px"),
        ("background-color", "#fff"),
        ("border", "1px solid #989796")
    ]

chatInput: Model -> Html Msg 
chatInput model = 
    textarea [
        chatInputStyle,
        value model.user.currentInput,
        onInput (\input -> UserInput input)
    ] []
      
view : Model -> Html Msg 
view model = 
    div []
        [
            button [ onClick (NewUser "asdf") ] [ text "new user" ] ,
            div [] [ text (toString model.members) ],
            chatBox model,
            chatInput model,
            button [ onClick (onClickSend model)] [ text "send" ]
        ]
