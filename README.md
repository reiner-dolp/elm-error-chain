An error framework for your Elm program that produces better error messages for
end-users. For example, the framework can produce errors in the format:

> # Error
> 
> Failed to load page 'user profile'<br>
> &nbsp;&nbsp;&nbsp; **caused by:** failed to get friend list<br>
> &nbsp;&nbsp;&nbsp; **caused by:** network error (<abbr title="Invalid JSON at line 1">View Details</abbr>)
> ## Suggestions
> - Check your internet connection
> - Try reloading the page

Instead of the following error formats you encounter regularily in Elm
applications. They either show the most specific reason only:

> **Error:** NetworkError Invalid Json Payload at ...

or just the most general reason

> **Error:** Failed to load page 'user profile'

# Core Idea

Fix the error type of each `Task` and `Result` to a *list of* errors. As
results are handed down through the call hierarchy / stack of the program, each
function can annotate the error with context.

```elm
type ErrorChain errorKind
    = ErrorChain (List errorKind)


type ErrorKind
    = NetworkError Http.Error
    | OtherError String


type alias Job data =
    Task ErrorChain data

type alias Outcome data =
    Result ErrorChain data

-- imagine a lot of convenience functions here

annotateError : String -> ErrorChain -> ErrorChain
annotateError msg (ErrorChain chain) =
    ErrorChain (OtherError msg :: chain)

annotateJob : String -> Job a -> Job a
annotateJob msg =
    Task.mapError (Error.annotate msg)
```

# Usage Example

General idea is that you use `Job` instead of `Task`, and `Outcome` instead of
`Result` everywhere. A outline of using it in the Elm SPA before the 0.19
refactor (sorry!) looks as follows:

```elm
-- Main.elm: add the Error.annotate call
updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        pageLoadError pageName err =
        { model | pageState = Loaded (ErrorPage
            (err |> Error.annotate ("Failed to load page '" ++ pageName ++ "'")))
            }, Cmd.none)
    in
    case ( msg, page ) of
        ( HomeLoaded (Err error), _ ) ->
            pageLoadError "home" error
```

Where we just added the `Error.annotate` call. And in each subpage, we just
add the `Job.annotate` call:

```elm
module Page.Home exposing (init, ...)

init : Job Model
init =
    Job.map2 Model
        (Network.request friendList
            |> Job.annotate "Failed to get friend list"
        )
        (Network.request chatMessages
            |> Job.annotate "Failed to get chat messages"
        )
```
