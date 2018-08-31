module Error exposing (ErrorChain(..), ErrorKind(..), annotate, chain, get, new)

import Http
import Task exposing (Task)


type ErrorChain errorKind
    = ErrorChain (List errorKind)


type ErrorKind
    = NetworkError Http.Error
    | OtherError String


chain : ErrorKind -> Task (ErrorChain err) a -> Task (ErrorChain err) a
chain err =
    Task.mapError (\(ErrorChain chain) -> ErrorChain (err :: chain))


annotate : String -> ErrorChain -> ErrorChain
annotate msg (ErrorChain chain) =
    ErrorChain (OtherError msg :: chain)


new : String -> ErrorChain
new msg =
    ErrorChain [ OtherError msg ]


get : ErrorChain -> List ErrorKind
get (ErrorChain chain) =
    chain
