module Api exposing (..)
import WebSocket exposing (..)
import Json.Decode exposing (..)

import Types exposing (..)

wssEndpoint : String
wssEndpoint = "ws://localhost:3000"

subscribeApi : Sub Msg
subscribeApi = WebSocket.listen wssEndpoint WebsocketResponse

getResponseAction : String -> ApiResponse
getResponseAction response = 
    let 
        parseAction = decodeString (field "action" string) response 
    in 
        case parseAction of 
            Ok action -> 
                case action of 
                    "heartbeat" -> Heartbeat "heartbeat"
                    "newuser" -> ApiNewUser "asdf" 0 
                    "newmessage" -> ApiNewMessage "asdf" "message"
                    "userleft" -> ApiUserLeft "asdf" 0
                    _ -> ((++) "Unknown action " >> ApiError) action
            Err errMsg ->
                ApiError errMsg


sendMessage : String -> Cmd cmd
sendMessage data = 
    let 
        msg = "{\"action\":\"NewMessage\",\"message\":"++data++"}" 
    in
        WebSocket.send wssEndpoint msg
