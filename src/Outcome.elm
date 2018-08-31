module Outcome exposing (Outcome)

import Error exposing (ErrorChain)


type alias Outcome error data =
    Result (ErrorChain error) data
