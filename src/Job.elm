module Job exposing (Job, andThen, annotate, fail, fromHttpTask, map, succeed)

import Error exposing (ErrorChain, ErrorKind(..))
import Http
import Task exposing (Task)


type alias Job error data =
    Task (ErrorChain error) data


fromHttpTask : Task Http.Error a -> Job a
fromHttpTask =
    Task.mapError (\err -> Error.ErrorChain [ NetworkError err ])


annotate : String -> Job a -> Job a
annotate msg =
    Task.mapError (Error.annotate msg)


succeed : a -> Job a
succeed =
    Task.succeed


fail : ErrorChain -> Job a
fail =
    Task.fail


andThen : (a -> Task ErrorChain b) -> Task ErrorChain a -> Task ErrorChain b
andThen =
    Task.andThen


map : (a -> b) -> Task ErrorChain a -> Task ErrorChain b
map =
    Task.map
