import Html exposing (Html, button, div, text)

main: Program Never Model Model
main =
    Html.beginnerProgram { model = model, view = view, update = update}

-- MODEL
type alias Model = String

model : Model 
model = 
    "Hello world"

-- UPDATE
update : Model -> Model -> Model 
update m1 m2 = m1

-- VIEW
view : Model -> Html msg 
view model = 
    div []
        [
            div [] [ text (toString model) ]
        ]
