dofile("core.lua")

newoption {
    trigger     = "folder",
    value       = "Solution folder",
    description  = "The path to the root folder of the solution",
}

if _OPTIONS["folder"] == nil or _OPTIONS["folder"] == "" then
    error("You must specify a solution folder")
elseif not os.isdir(_OPTIONS["folder"]) then
    error("Invalid folder")
else
    moche.parse.solution(path.getbasename(_OPTIONS["folder"]), _OPTIONS["folder"])
end
