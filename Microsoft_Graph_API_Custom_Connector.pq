// This file contains your Data Connector logic
section Microsoft_Graph_API_Custom_Connector;

client_id = Text.FromBinary(Extension.Contents("client_id"));
redirect_uri = "https://oauth.powerbi.com/views/oauthredirect.html";
token_uri = "https://login.microsoftonline.com/organizations/oauth2/v2.0/token";
authorize_uri = "https://login.microsoftonline.com/organizations/oauth2/v2.0/authorize";
logout_uri = "https://login.microsoftonline.com/logout.srf";

url = "https://graph.microsoft.com/v1.0/";

windowWidth = 720;
windowHeight = 720;

scope_prefix = "https://graph.microsoft.com/";
scopes = {
    "User.Read",
    "User.Read.All"
};

[DataSource.Kind="Microsoft_Graph_API_Custom_Connector", Publish="Microsoft_Graph_API_Custom_Connector.UI"]
shared Microsoft_Graph_API_Custom_Connector.Content = (Query as text) =>
    let
        uri = url & Query,
        source = OData.Feed(uri, null, [ ODataVersion = 4, Implementation="2.0", MoreColumns = true ])
    in
        source;

StartLogin = (clientApplication, dataSourcePath, state, display) =>
    let
        authorizeUrl = authorize_uri & "?" & Uri.BuildQueryString([
            client_id = client_id,
            redirect_uri = redirect_uri,
            state = state,
            scope = "offline_access " & GetScopeString(scopes, scope_prefix),
            response_type = "code",
            response_mode = "query",
            login = "login"
        ])
    in
        [
            LoginUri = authorizeUrl,
            CallbackUri = redirect_uri,
            WindowHeight = windowHeight,
            WindowWidth = windowWidth,
            Context = null
        ];

FinishLogin = (context, callbackUri, state) =>
    let
        parts = Uri.Parts(callbackUri)[Query],
        result = if (Record.HasFields(parts, {"error", "error_description"})) then
                    error Error.Record(parts[error], parts[error_description], parts)
                else
                    TokenMethod("authorization_code", "code", parts[code])
    in
        result;

Refresh = (resourceUrl, refresh_token) => TokenMethod("refresh_token", "refresh_token", refresh_token);

Logout = (token) => logout_uri;

TokenMethod = (grantType, tokenField, code) =>
    let
        queryString = [
            client_id = client_id,
            scope = "offline_access " & GetScopeString(scopes, scope_prefix),
            grant_type = grantType,
            redirect_uri = redirect_uri
        ],
        queryWithCode = Record.AddField(queryString, tokenField, code),
        tokenResponse = Web.Contents(token_uri, [
            Content = Text.ToBinary(Uri.BuildQueryString(queryWithCode)),
            Headers = [
                #"Content-type" = "application/x-www-form-urlencoded",
                #"Accept" = "application/json"
            ],
            ManualStatusHandling = {400}
        ]),
        body = Json.Document(tokenResponse),
        result = if (Record.HasFields(body, {"error", "error_description"})) then
                    error Error.Record(body[error], body[error_description], body)
                else
                    body
    in
        result;

Value.IfNull = (a,b) => if a <> null then a else b;

GetScopeString = (scopes as list, optional scopePrefix as text) as text =>
    let
        prefix = Value.IfNull(scopePrefix, ""),
        addPrefix = List.Transform(scopes, each prefix & _),
        asText = Text.Combine(addPrefix, " ")
    in
        asText;

// Data Source Kind description
Microsoft_Graph_API_Custom_Connector = [
    Authentication = [
        OAuth = [
            StartLogin=StartLogin,
            FinishLogin=FinishLogin,
            Refresh=Refresh,
            Logout=Logout
        ]
    ],
    Label = "Microsoft Graph API Custom Connector"
];

Microsoft_Graph_API_Custom_Connector.UI = [
    Beta = true,
    ButtonText = { "Microsoft Graph API Custom Connector", "Connect to Graph" },
    SourceImage = Microsoft_Graph_API_Custom_Connector.Icons,
    SourceTypeImage = Microsoft_Graph_API_Custom_Connector.Icons
];

Microsoft_Graph_API_Custom_Connector.Icons = [
    Icon16 = { Extension.Contents("Microsoft_Graph_API_Custom_Connector16.png"), Extension.Contents("Microsoft_Graph_API_Custom_Connector20.png"), Extension.Contents("Microsoft_Graph_API_Custom_Connector24.png"), Extension.Contents("Microsoft_Graph_API_Custom_Connector32.png") },
    Icon32 = { Extension.Contents("Microsoft_Graph_API_Custom_Connector32.png"), Extension.Contents("Microsoft_Graph_API_Custom_Connector40.png"), Extension.Contents("Microsoft_Graph_API_Custom_Connector48.png"), Extension.Contents("Microsoft_Graph_API_Custom_Connector64.png") }
];