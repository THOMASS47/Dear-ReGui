-- https://guidedhacking.com/forums/roblox-exploit-scripting-course-res100.521/
-- https://www.youtube.com/watch?v=DFs83HEgp7k

-- Hydroxide: https://github.com/Upbolt/Hydroxide

-- Roblox api: https://robloxapi.github.io/ref/
-- Potassium docs: https://docs.potassium.pro
-- SUNC: https://github.com/sUNC-Utilities/Global-Functions-Documentation
-- UNC: https://github.com/unified-naming-convention/NamingStandard/tree/main
-- Synapse docs: https://synapsexdocs.github.io/custom-lua-functions/environment-helper-functions/
-- Stingray: https://github.com/Nebula-Manta/Stingray/tree/main
-- Exploiting Debug Library Guide: https://gist.github.com/TehBlaxxor/c8022570fea9e48ab7a6a6ad23c7c671
-- Roblox-Identities: https://github.com/Pseudoreality/Roblox-Identities
-- Definitions example: https://github.com/JohnnyMorganz/luau-lsp/blob/main/scripts/globalTypes.d.luau
-- Documentation example: https://raw.githubusercontent.com/MaximumADHD/Roblox-Client-Tracker/roblox/api-docs/en-us.json

-- Random stuff --
--[[ type Request = { Url: string, Method: "GET" | "POST" | string?, Headers: { [string]: any, Body: string? }?}
type Response = { Success: boolean, StatusCode: number?, StatusMessage: string?, ErrorMessage: string?, HttpError: Enum.HttpError?, Version: string?, Headers: { [string]: any }?, Body: string? }
type Connection = { Enabled: boolean, ForeignState: boolean, LuaConnection: boolean, Thread: thread, Function: () -> (), Fire: () -> (), Disconnect: () -> (), Enable: () -> (), Disable: () -> (), Defer: () -> () }

declare function getgenv(): { [string]: any }
declare function getgc(includetables: boolean?): { [string]: any }
declare function gethwid(): string
declare function gethui(): Instance
declare function isfile(path: string): boolean
declare function writefile(path: string, contents: string): ()
declare function readfile(path: string): string
declare function setclipboard(text: string): ()
declare function setsimulationradius(radius: number): ()
declare function identifyexecutor(): string
-- on xeno it return a boolean but we need to call the return for it to work on others
declare function queue_on_teleport(code: string): boolean
declare function fireproximityprompt(path: ProximityPrompt, distance: number?): ()
declare function request(request: Request): Response
declare function getconnections(func: RBXScriptConnection): { Connection }
-- actually can return nil when code is wrong but i know code i put in it will be right
declare function loadstring(src: string): () -> any ]]


-- Helper Types --
export type Function = (...any) -> ...any
export type Table = {[any]: any}

-- DataModel Patch --
declare game: DataModel & {
    HttpGet: (self: DataModel, url: string, synchronous: boolean?, Enum.HttpRequestType?, doNotAllowDiabolicalMode: boolean?) -> (string),
    HttpPost: (self: DataModel, url: string, data: string, synchronous: boolean?, Enum.HttpRequestType?, doNotAllowDiabolicalMode: boolean?) -> (string),
}

-- sUNC --
export type FunctionFilterOptions = {
    Name: string?,
    IgnoreExecutor: boolean?,
    Hash: any?,
    Constants: {any}?,
    Upvalues: {any}?,
}

export type TableFilterOptions = {
    Keys: {any}?,
    Values: {any}?,
    KeyValuePairs: Table?,
    Metatable: {[string]: any}?,
}
declare filtergc: (
    ((filter_type: "function", filter_options: FunctionFilterOptions, return_one: true) -> (Function?)) &
    ((filter_type: "function", filter_options: FunctionFilterOptions, return_one: false?) -> ({Function})) &
    ((filter_type: "table", filter_options: TableFilterOptions, return_one: true) -> (Table?)) &
    ((filter_type: "table", filter_options: TableFilterOptions, return_one: false?) -> ({Table}))
)

--- Potassium: https://docs.potassium.pro ---
--- TODO: maybe use sUNC docs to improve https://github.com/sUNC-Utilities/Global-Functions-Documentation ---

-- Undocumented --
declare function getfunctionhash(func: Function): string

-- Cache --
declare cache: {
    invalidate:(object: Instance)-> (),
    iscached: (object: Instance)-> boolean,
    replace: (object: Instance, newObject: Instance)-> (),
}
declare function cloneref<T>(object: T & Instance): T
declare function compareinstances(a: Instance, b: Instance): boolean

-- Closures --
declare function checkcaller(): boolean
declare function clonefunction<A..., R...>(func: (A...) -> R...): (A...) -> R...
declare function getcallingscript(): BaseScript
declare function hookfunction<A..., R...>(func: (A...) -> R..., hook: (A...) -> R...): (A...) -> R...
declare function iscclosure<A..., R...>(func: (A...) -> R...): boolean
declare function islclosure<A..., R...>(func: (A...) -> R...): boolean
declare function isexecutorclosure<A..., R...>(func: (A...) -> R...): boolean
declare function loadstring<A...>(source: string, chunkname: string?): ((A...) -> any, string?)
declare function newcclosure<A..., R...>(func: (A...) -> R...): (A...) -> R...

-- Console --
declare function rconsoleclear(): ()
declare function rconsolecreate(): ()
declare function rconsoledestroy(): ()
declare function rconsoleinput(): string
declare function rconsoleprint(text: string): ()
declare function rconsolewarn(text: string): ()
declare function rconsoleerror(text: string): ()
declare function rconsolesettitle(title: string): ()

-- Crypt --
declare crypt: {
    base64encode: (data: string) -> string,
    base64decode: (data: string) -> string,
    encrypt: (data: string, key: string, iv: string?, mode: string?) -> (string, string),
    decrypt: (data: string, key: string, iv: string, mode: string) -> string,
    generatebytes: (size: number) -> string,
    generatekey: () -> string,
    hash: (data: string, algo:  'sha1' | 'sha384' | 'sha512' | 'md5' | 'sha256' | 'sha3-224' | 'sha3-256' | 'sha3-512' | string) -> string
}

-- Debug --
export type DebugInfo = {
    source: string,
    short_src: string,
    func: Function,
    what: string,
    currentline: number,
    name: string,
    nups: number,
    numparams: number,
    is_vararg: number
}

declare function isvalidlevel(level: number): boolean
declare function getregistry(): Table
declare function getconstant(func: Function | number, index: number): any
declare function getconstants(func: Function | number): {[number]: any}
declare function getinfo(func: Function | number): DebugInfo
declare function getproto(func: Function | number, index: number, active: boolean?): (Function) | {[number]: Function}
declare function getprotos(func: Function | number): {[number]: Function}
declare function getstack(func: Function | number, index: number?): any | {[number]: any}
declare function getupvalue(func: Function | number, index: number): any
declare function getupvalues(func: Function | number): {[number]: any}
declare function setconstant(func: Function | number, index: number, value: any): ()
declare function setstack(func: Function | number, index: number, value: any): ()
declare function setupvalue(func: Function | number, index: number, value: any): ()

declare debug: typeof(debug) & {
    isvalidlevel: typeof(isvalidlevel),
    getregistry: typeof(getregistry),
    getconstant: typeof(getconstant),
    getconstants: typeof(getconstants),
    getinfo: typeof(getinfo),
    getproto: typeof(getproto),
    getprotos: typeof(getprotos),
    getstack: typeof(getstack),
    getupvalue: typeof(getupvalue),
    getupvalues: typeof(getupvalues),
    setconstant: typeof(setconstant),
    setstack: typeof(setstack),
    setupvalue: typeof(setupvalue),
}

-- Drawing --
export type BaseDrawingObject = {
    Visible: boolean,
    ZIndex: number,
    Transparency: number,
    Color: Color3,
    Destroy: () -> ()
}

export type LineDrawingObject = BaseDrawingObject & {
    From: Vector2,
    To: Vector2,
    Thickness: number
}

export type TextDrawingObject = BaseDrawingObject & {
    Text: string,
    TextBounds: Vector2,
    Font: number,
    Size: number,
    Position: Vector2,
    Center: boolean,
    Outline: boolean,
    OutlineColor: Color3
}

export type ImageDrawingObject = BaseDrawingObject & {
    Data: string,
    Size: Vector2,
    Position: Vector2,
    Rounding: number
}

export type CircleDrawingObject = BaseDrawingObject & {
    NumSides: number,
    Radius: number,
    Position: Vector2,
    Thickness: number,
    Filled: boolean
}

export type SquareDrawingObject = BaseDrawingObject & {
    Size: Vector2,
    Position: Vector2,
    Thickness: number,
    Filled: boolean
}

export type QuadDrawingObject = BaseDrawingObject & {
    PointA: Vector2,
    PointB: Vector2,
    PointC: Vector2,
    PointD: Vector2,
    Thickness: number,
    Filled: boolean
}

export type TriangleDrawingObject = BaseDrawingObject & {
    PointA: Vector2,
    PointB: Vector2,
    PointC: Vector2,
    Thickness: number,
    Filled: boolean
}

export type DrawingObject = LineDrawingObject | TextDrawingObject | ImageDrawingObject | CircleDrawingObject | SquareDrawingObject | QuadDrawingObject | TriangleDrawingObject

export type DrawingType = "Line" | "Text" | "Image" | "Circle" | "Square" | "Quad" | "Triangle"

declare Drawing: {
    new: ((type: "Line") -> LineDrawingObject) &
         ((type: "Text") -> TextDrawingObject) &
         ((type: "Image") -> ImageDrawingObject) &
         ((type: "Circle") -> CircleDrawingObject) &
         ((type: "Square") -> SquareDrawingObject) &
         ((type: "Quad") -> QuadDrawingObject) &
         ((type: "Triangle") -> TriangleDrawingObject),
    Fonts: {
        UI: number,
        System: number,
        Plex: number,
        Monospace: number
    }
}

declare function cleardrawcache(): ()
declare function getrenderproperty(drawing: DrawingObject, property: string): any
declare function isrenderobj(object: any): boolean
declare function setrenderproperty(drawing: DrawingObject, property: string, value: any): ()

-- File System --
declare function readfile(path: string): string
declare function listfiles(path: string): {string}
declare function writefile(path: string, data: string): ()
declare function makefolder(path: string): ()
declare function appendfile(path: string, data: string): ()
declare function isfile(path: string): boolean
declare function isfolder(path: string): boolean
declare function delfile(path: string): ()
declare function delfolder(path: string): ()
declare function loadfile<A...>(path: string, chunkname: string?): ((A...) -> any, string?)
declare function dofile(path: string): ()

-- Input --
declare function isrbxactive(): boolean
declare function mouse1click(): ()
declare function mouse1press(): ()
declare function mouse1release(): ()
declare function mouse2click(): ()
declare function mouse2press(): ()
declare function mouse2release(): ()
declare function mousemoveabs(x: number, y: number): ()
declare function mousemoverel(x: number, y: number): ()
declare function mousescroll(pixels: number): ()

-- Instance --
export type Connection = {
    Enabled: boolean,
    ForeignState: boolean,
    LuaConnection: boolean,
    Function: (() -> ())?,
    Thread: thread?,
    Fire: (...any) -> (),
    Defer: (...any) -> (),
    Disconnect: () -> (),
    Disable: () -> (),
    Enable: () -> ()
}

declare function fireclickdetector(object: ClickDetector, distance: number?): ()
declare function firetouchinterest(instance: Instance, touchingPart: Instance, isTouching: boolean): ()
declare function isnetworkowner(part: Instance): boolean
declare function getcallbackvalue(object: Instance, property: string): (() -> ())?
declare function fireproximityprompt(prompt: ProximityPrompt): ()
declare function getconnections(signal: RBXScriptSignal): {Connection}
declare function getconnection(signal: RBXScriptSignal, index: number): Connection
declare function firesignal(signal: RBXScriptSignal, ...: any?): ()
declare function getcustomasset(path: string): string
declare function gethiddenproperty(object: Instance, property: string): (any, boolean)
declare function setsimulationradius(simulationRadius: number, maxSimulationRadius: number?): ()
declare function gethui(): Folder
declare function getinstances(): {Instance}
declare function getnilinstances(): {Instance}
declare function isscriptable(object: Instance, property: string): boolean?
declare function sethiddenproperty(object: Instance, property: string, value: any): boolean
declare function setrbxclipboard(data: string): boolean
declare function setscriptable(object: Instance, property: string, value: boolean): boolean
declare function getrendersteppedlist(): {any}
declare function replicatesignal(signal: RBXScriptSignal, ...: any?): ()

-- Metatable --
declare function getrawmetatable(object: Table): Table
declare function hookmetamethod(object: Table, method: string, hook: Function): Function
declare function getnamecallmethod(): string
declare function setnamecallmethod(method: string): ()
declare function isreadonly(object: Table): boolean
declare function setrawmetatable(object: Table, metatable: Table): ()
declare function setreadonly(object: Table, readonly: boolean): ()
declare function makewriteable(object: Table): ()
declare function makereadonly(object: Table): ()

-- Miscellaneous --
export type HttpRequest = {
    Url: string,
    Method: string,
    Body: string?,
    Headers: {[string]: string}?,
    Cookies: {[string]: string}?
}

export type HttpResponse = {
    Success: boolean,
    StatusCode: number,
    StatusMessage: string,
    Headers: {[string]: string},
    Cookies: {[string]: string},
    Body: string
}

declare function identifyexecutor(): (string, string)
declare function lz4compress(data: string): string
declare function lz4decompress(data: string, size: number): string
declare function messagebox(text: string, caption: string, flags: number): number
declare function queue_on_teleport(code: string): ()
declare function request(options: HttpRequest): HttpResponse
declare function getinternalparent(instance: Instance): Instance
declare function getfflag(fflag: string): any
declare function setfflag(fflag: string, value: any): ()
declare function setinternalparent(instance: Instance, newParent: Instance): ()
declare function setclipboard(text: string): ()
declare function setfpscap(fps: number): ()

-- Scripts --
declare function getgc(includeTables: boolean?): {any}
declare function getgenv(): {[string]: any}
declare function gettenv(thread: thread): {[string]: any}
declare function getreg(): {Function | thread}
declare function getloadedmodules(): {ModuleScript}
declare function getrenv(): {[string]: any}
declare function getrunningscripts(): {LocalScript | ModuleScript}
declare function getscriptbytecode(script: LocalScript | ModuleScript): string
declare function getscriptclosure(script: LocalScript | ModuleScript): Function
declare function getscripthash(script: LocalScript | ModuleScript): string
declare function getscripts(): {LocalScript | ModuleScript}
declare function getsenv(script: LocalScript | ModuleScript): {[string]: any}
declare function getthreadidentity(): number
declare function setthreadidentity(identity: number): ()

-- Web Sockets --
export type WebSocketConnection = {
    Send: (self: WebSocketConnection, message: string) -> (),
    Close: (self: WebSocketConnection) -> (),
    OnMessage: RBXScriptSignal<(message: string) -> ()>,
    OnClose: RBXScriptSignal<() -> ()>
}

declare WebSocket: {
    connect: (url: string) -> WebSocketConnection
}

-- Actor --
declare function create_comm_channel(): (number, BindableEvent)
declare function get_comm_channel(id: number): BindableEvent
declare function run_on_actor(actor: Actor, script: string, ...: any): ()
declare function getactors(): {Actor}
declare function is_parallel(): boolean
declare function run_on_thread(thread: thread, script: string, ...: any): ()
declare function getactorthreads(): {thread}