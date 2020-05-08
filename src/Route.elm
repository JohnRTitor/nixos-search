module Route exposing (Route(..), fromUrl, href, replaceUrl)

import Browser.Navigation
import Html
import Html.Attributes
import Url
import Url.Parser exposing ((<?>))
import Url.Parser.Query



-- ROUTING


type Route
    = NotFound
    | Home
    | Packages (Maybe String) (Maybe String)
    | Options (Maybe String) (Maybe String)


parser : Url.Parser.Parser (Route -> msg) msg
parser =
    Url.Parser.oneOf
        [ Url.Parser.map
            Home
            Url.Parser.top
        , Url.Parser.map
            NotFound
            (Url.Parser.s "not-found")
        , Url.Parser.map
            Packages
            (Url.Parser.s "packages"
                <?> Url.Parser.Query.string "query"
                <?> Url.Parser.Query.string "showDetailsFor"
            )
        , Url.Parser.map
            Options
            (Url.Parser.s "options"
                <?> Url.Parser.Query.string "query"
                <?> Url.Parser.Query.string "showDetailsFor"
            )
        ]



-- PUBLIC HELPERS


href : Route -> Html.Attribute msg
href targetRoute =
    Html.Attributes.href (routeToString targetRoute)


replaceUrl : Browser.Navigation.Key -> Route -> Cmd msg
replaceUrl navKey route =
    Browser.Navigation.replaceUrl navKey (routeToString route)


fromUrl : Url.Url -> Maybe Route
fromUrl url =
    -- The RealWorld spec treats the fragment like a path.
    -- This makes it *literally* the path, so we can proceed
    -- with parsing as if it had been a normal path all along.
    --{ url | path = Maybe.withDefault "" url.fragment, fragment = Nothing }
    Url.Parser.parse parser url



-- INTERNAL


routeToString : Route -> String
routeToString page =
    let
        ( path, query ) =
            routeToPieces page
    in
    "/" ++ String.join "/" path ++ "?" ++ String.join "&" (List.filterMap Basics.identity query)


routeToPieces : Route -> ( List String, List (Maybe String) )
routeToPieces page =
    case page of
        Home ->
            ( [], [] )

        NotFound ->
            ( [ "not-found" ], [] )

        Packages query showDetailsFor ->
            ( [ "packages" ], [ query, showDetailsFor ] )

        Options query showDetailsFor ->
            ( [ "options" ], [ query, showDetailsFor ] )
