module Network exposing (request)

import Http
import Job exposing (Job)


request : Http.Request a -> Job a
request req =
    Http.toTask req |> Job.fromHttpTask
