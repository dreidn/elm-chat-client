module Types exposing (..)

type alias UserName = String

type ChatMessage = Message UserName String

type RawResponse = Data String

type ApiResponse = 
    Heartbeat String
    | ApiNewUser String Int
    | ApiNewMessage String String
    | ApiUserLeft String Int
    | ApiError String


type Msg = 
    NewUser UserName
    | NewMessage ChatMessage
    | UserInput String
    | WebsocketResponse String