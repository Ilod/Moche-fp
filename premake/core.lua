local solutionConfigCurrent

local configFileExtension       = ".mpc"

local configFileGroupName       = "group"
local configFileProjectName     = "project"
local configFileSolutionName    = "solution"
local configFileNoopName        = "noop"

local configFileGroup           = configFileGroupName       .. configFileExtension
local configFileProject         = configFileProjectName     .. configFileExtension
local configFileSolution        = configFileSolutionName    .. configFileExtension
local configFileNoop            = configFileNoopName        .. configFileExtension


-- Log functions declarations
local dump
local log
local setLogLevel
local getLogLevel
local LogLevel = { None = 0, Always = 1, Error = 2, Warning = 3, Debug = 4, Trace = 5, All = 6 }

-- Variable type functions declarations
local isObj
local makeTable
local makeConfigString
local deepCopy
local makePrefixedPathTable

-- Config file parsing functions declarations
local parseSolution
local parseProject
local parseFolder
local parseSolutionProjects
local parseConfig
local parseSolutionConfig
local parseGroupConfig
local parseProjectConfig
local parseSolutionConfigValue
local parseGroupConfigValue
local parseProjectConfigValue
local parseKindName
local isConfigFolder
local exploreSrcFolder

-- Public premake API extend functions declarations
local pushGroup
local popGroup
local pushConfig
local popConfig
local addDefines
local addFlags
local addLibdirs
local addIncludedirs
local initSolution
local initProject
local addSrcFolder

-- Log functions
dump = function(var, indent)
    if not indent then
        indent = ""
    end
    if type(var) == "userdata" then
        return "<!--RAWDATA-->"
    elseif type(var) == "thread" then
        return "<!--THREAD-->"
    elseif type(var) == "function" then
        return "<!--FUNCTION-->"
    elseif type(var) == "string" then
        return "\"" .. var .. "\""
    elseif type(var) == "table" then
        ret = "{\n"
        local newIndent = indent .. "\t"
        for k, v in pairs(var) do
            ret = ret .. newIndent .. dump(k, newIndent) .. " = " .. dump(v, newIndent) .. ",\n"
        end
        return ret .. indent .. "}"
    else
        return tostring(var)
    end
end

local currentLogLevel = LogLevel.Always

getLogLevel = function()
    return currentLogLevel
end

setLogLevel = function(logLevel)
    currentLogLevel = logLevel
end

log = function(logLevel, str, ...)
    if logLevel <= currentLogLevel then
        print(string.format(str, ...))
    end
end

-- Variable type functions
isObj = function(variable, attributeToCheck)
    return type(variable) == "table" and (attributeToCheck == nil or variable[attributeToCheck] ~= nil)
end

deepCopy = function(obj)
    if type(obj) == "table" then
        local copy = {}
        for key, value in next, obj, nil do
            copy[deepCopy(key)] = deepCopy(value)
        end
        setmetatable(copy, deepCopy(getmetatable(obj)))
        return copy
    else
        return obj
    end
end

makeTable = function(variable, attributeToCheck)
    if variable == nil then
        return {}
    elseif type(variable) == "table" then
        if attributeToCheck ~= nil and variable[attributeToCheck] ~= nil then
            return { variable }
        else
            return variable
        end
    else
        return { variable }
    end
end

makePrefixedPathTable = function(dirs, prefix)
    local ret = {}
    for key, value in next, makeTable(dirs), nil do
        ret[key] = path.join(prefix, value)
    end
    return ret
end

makeConfigString = function(configs)
    local value = ""
    for i,config in ipairs(makeTable(configs)) do
        value = value .. config .. " or "
    end
    return string.sub(value, 0, -5)
end

-- Config file parsing function
isConfigFolder = function(folder)
    return os.isfile(path.join(folder, configFileProject)) or os.isfile(path.join(folder, configFileGroup)) or os.isfile(path.join(folder, configFileNoop)) or os.isfile(path.join(folder, "premake5.lua"))
end

parseConfig = function(file, config, parseConfigValue)
    for line in io.lines() do
        local index = line:find("=")
        if index ~= nil then
            name = line:sub(1, index-1)
            value = line:sub(index+1)
            if value ~= nil then
                name = name:match'^%s*(.*%S)' or ''
                name = name:lower()
                value = value:match'^%s*(.*%S)' or ''
                parseConfigValue(name, value, config)
            end
        end
    end
end

parseGroupConfig = function(file, config)
    io.input(file)
    parseConfig(file, config, parseSolutionConfigValue)
end

parseGroupConfigValue = function(name, value, config)
    name = name:lower()
    if name == "name" then
        config.name = value;
    end
end

parseSolutionConfig = function(file, config)
    io.input(file)
    parseConfig(file, config, parseSolutionConfigValue)
end

parseSolutionConfigValue = function(name, value, config)
    name = name:lower()
    if name == "name" then
        config.name = value;
    elseif name == "norootproject" then
        config.noRootProject = (value:lower() == "true")
    elseif name == "rootproject" then
        config.noRootProject = (value:lower() ~= "true")
    elseif name == "libdir" or name == "libsdir" or name == "libsdirs" or name == "libdirs" then
        config.libdirs = string.explode(value, ",")
    elseif name == "incdir" or name == "incsdir" or name == "incsdirs" or name == "incdirs" or name == "includedir" or name == "includesdir" or name == "includesdirs" or name == "includedirs" or name == "inc" or name == "incs" or name == "include" or name == "includes" then
        config.incdirs = string.explode(value, ",")
    elseif name == "kind" or name == "type" then
        config.defaultKind = value
    elseif name == "toolset" or name == "platformtoolset" then
        config.toolset = value
    end
end

parseProjectConfig = function(file, config)
    io.input(file)
    parseConfig(file, config, parseProjectConfigValue)
end

parseProjectConfigValue = function(name, value, config)
    name = name:lower()
    if name == "name" then
        config.name = value;
    elseif name == "lib" or name == "libs" then
        config.libs = string.explode(value, ",")
    elseif name == "libdir" or name == "libsdir" or name == "libsdirs" or name == "libdirs" then
        config.libdirs = string.explode(value, ",")
    elseif name == "incdir" or name == "incsdir" or name == "incsdirs" or name == "incdirs" or name == "includedir" or name == "includesdir" or name == "includesdirs" or name == "includedirs" or name == "inc" or name == "incs" or name == "include" or name == "includes" then
        config.incdirs = string.explode(value, ",")
    elseif name == "kind" or name == "type" then
        config.kind = value
    elseif name == "toolset" or name == "platformtoolset" then
        config.toolset = value
    elseif name == "start" or name == "startup" or name == "startproject" or name == "startupproject" then
        config.startproject = (value:lower() == "true")
    end
end

parseSolution = function(solutionName, solutionRootFolder)
    log(LogLevel.Debug, "Start parsing solution folder %s", solutionRootFolder)
    if os.isfile(path.join(solutionRootFolder, "premake5.lua")) then
        log(LogLevel.Debug, "Premake5 file found")
        dofile(path.join(solutionRootFolder, "premake5.lua"))
    else
        local config = {}
        config.name = solutionName
        config.rootFolder = solutionRootFolder
        if os.isfile(path.join(solutionRootFolder, configFileSolution)) then
            log(LogLevel.Trace, "Solution config file found")
            parseSolutionConfig(path.join(solutionRootFolder, configFileSolution), config)
        end
        initSolution(solutionName, solutionRootFolder, config)
        parseSolutionProjects()
    end
end

parseGroup = function(folder)
    log(LogLevel.Debug, "Start parsing group folder %s", folder)
    local config = {}
    config.name = path.getname(folder)
    if os.isfile(path.join(folder, configFileGroup)) then
        log(LogLevel.Trace, "Group config file found")
        parseGroupConfig(path.join(folder, configFileGroup), config)
    end
    pushGroup(config.name)
end

parseProject = function(folder)
    log(LogLevel.Debug, "Start parsing project folder %s", folder)
    if os.isfile(path.join(folder, "premake5.lua")) then
        log(LogLevel.Debug, "Premake5 file found")
        dofile(path.join(folder, "premake5.lua"))
    else
        local config = {}
        config.name = path.getname(folder)
        config.rootFolder = folder
        if os.isfile(path.join(folder, configFileProject)) then
            log(LogLevel.Trace, "Project config file found")
            parseProjectConfig(path.join(folder, configFileProject), config)
        end
        initProject(config)
        exploreSrcFolder(config.rootFolder)
    end
end

parseSolutionProjects = function()
    if solutionConfigCurrent.noRootProject then
        log(LogLevel.Trace, "No root project, explore subfolders")
        for i,dir in ipairs(os.matchdirs(solutionConfigCurrent.rootFolder .. "/*")) do
            parseFolder(dir)
        end
    else
        parseFolder(solutionConfigCurrent.rootFolder)
    end
end

exploreSrcFolder = function(folder,configFolders)
    if configFolders == nil then
        configFolders = {}
    elseif isConfigFolder(folder) then -- not for the first folder, when configFolder is nil, because we start the exploring where this project config file is.
        table.insert(configFolders, folder)
        return configFolders
    end
    addSrcFolder(folder, false)
    for i,dir in ipairs(os.matchdirs(folder .. "/*")) do
        exploreSrcFolder(dir, configFolders)
    end
    return configFolders
end

parseFolder = function(folder)
    log(LogLevel.Trace, "Parse folder %s", folder)
    if isConfigFolder(folder) then
        if os.isfile(path.join(folder, configFileGroup)) then
            log(LogLevel.Trace, "Group detected")
            parseGroup(folder)
        end
        if os.isfile(path.join(folder, configFileProject)) then
            log(LogLevel.Trace, "Project detected")
            parseProject(folder)
        elseif os.isfile(path.join(folder, "premake5.lua")) then
            log(LogLevel.Trace, "Premake5 file detected")
            parseProject(folder)
        elseif os.isfile(path.join(folder, configFileNoop)) then
            log(LogLevel.Trace, "Noop detected")
            for i,dir in ipairs(os.matchdirs(folder .. "/*")) do
                parseFolder(dir)
            end
        end
        if os.isfile(path.join(folder, configFileGroup)) then
            popGroup()
        end
    else
        log(LogLevel.Trace, "No config file, default to project")
        parseProject(folder)
    end
end

parseKindName = function(kindName)
    if kindName ~= nil then
        local askedKind = kindName:lower()
        if askedKind == "cmd" or askedKind == "commandline" or askedKind == "command" or askedKind == "console" or askedKind == "consoleapp" then
            return "ConsoleApp"
        elseif askedKind == "window" or askedKind == "windows" or askedKind == "graphic" or askedKind == "graphical" or askedKine == "exe" or askedKind == "gui" or askedKind == "windowedapp" then
            return "WindowedApp"
        elseif askedKind == "lib" or askedKind == "library" or askedKind == "static" or askedKind == "staticlib" then
            return "StaticLib"
        elseif askedKind == "dll" or askedKind == "shared" or askedKind == "sharedlib" then
            return "SharedLib"
        end
    end
    return nil
end

-- Public premake API extend functions

local groupStack = {}

pushGroup = function(groupName)
    table.insert(groupStack, groupName)
    group(table.concat(groupStack, "/"))
end

popGroup = function()
    table.remove(groupStack)
    group(table.concat(groupStack, "/"))
end

local configStack = {{}}

pushConfig = function(platforms, configs)
    local configStrings = {}
    if platforms ~= nil then
        table.insert(configStrings, 'platforms:'..makeConfigString(platforms))
    end
    if configs ~= nil then
        table.insert(configStrings, 'configurations:'..makeConfigString(configs))
    end
    table.insert(configStack, configStrings)
    filter(configStrings)
end

popConfig = function()
    table.remove(configStack)
    filter(configStack[#configStack])
end

addDefines = function(defineValues, platforms, configs)
    local defineStrings = {}
    pushConfig(platforms, configs)
        for i, defineValue in ipairs(makeTable(defineValues, "name")) do
            if isObj(defineValue, "name") then
                if isObj(defineValue, "value") then
                    table.insert(defineStrings, defineValue.name .. "=" .. defineValue.value)
                else
                    table.insert(defineStrings, defineValue.name)
                end
            else
                table.insert(defineStrings, defineValue)
            end
        end
        defines(defineStrings)
    popConfig()
end

addFlags = function(_flags, platforms, configs)
    pushConfig(platforms, configs)
        flags(makeTable(_flags))
    popConfig()
end

addLibdirs = function(dirs)
    libdirs(makePrefixedPathTable(dirs, '.'))
end

addIncludedirs = function(dirs)
    includedirs(makePrefixedPathTable(dirs, '.'))
end

initSolution = function(solutionName, solutionRootFolder, config)
    if config.name ~= nil then solutionName = config.name end
    solutionConfigCurrent = deepCopy(config)
    solution(solutionName)
        solutionConfigCurrent.name = solutionName
        if os.is64bit() then
            platforms({ "x32", "x64" })
        else
            platforms({ "x32" })
        end
        if solutionConfigCurrent.isTool == nil and solutionConfigCurrent.isLib == nil then
            if string.startswith(path.getabsolute(solutionRootFolder), path.getabsolute("../tools")) then
                solutionConfigCurrent.isTool = true
            end
        end
        configurations({"Debug", "Release"})
        language "C++"
        location("../build/%{sln.name}/" .. _ACTION .. "/")
        if solutionConfigCurrent.isTool then
            targetdir("../tools/bin/%{sln.name}")
            location("../tools/build/%{sln.name}/" .. _ACTION .. "/")
        elseif solutionConfigCurrent.isLib then
            targetdir("../lib/%{sln.name}")
        else
            targetdir("../bin/%{sln.name}")
        end
        local askedKind = parseKindName(solutionConfigCurrent.defaultKind)
        if askedKind == nil then
            if solutionConfigCurrent.isLib or solutionConfigCurrent.noRootProject then
                askedKind = "StaticLib"
            else
                askedKind = "WindowedApp"
            end
        end
        solutionConfigCurrent.defaultKind = askedKind
        
        if solutionConfigCurrent.toolset ~= nil then
            platformToolset(solutionConfigCurrent.toolset)
        else
            platformToolset("llvm")
        end
            
        if solutionConfigCurrent.libdirs ~= nil then
            addLibdirs(makePrefixedPathTable(solutionConfigCurrent.libdirs, solutionConfigCurrent.rootFolder))
        end
        if solutionConfigCurrent.incdirs ~= nil then
            addIncludedirs(makePrefixedPathTable(solutionConfigCurrent.incdirs, solutionConfigCurrent.rootFolder))
        end
        targetname "%{prj.name}_%{cfg.platform}_%{cfg.buildcfg}"
        warnings "Extra"
        addFlags { "FatalWarnings", "Unicode", "MultiProcessorCompile", "Symbols" }
        addDefines({"MOCHE_DEBUG", "DEBUG", "_DEBUG"}, nil, {"Debug"})
        addDefines({"MOCHE_RELEASE", "RELEASE", "_RELEASE"}, nil, {"Release"})
        addDefines "_CRT_SECURE_NO_WARNINGS"
        pushConfig(nil, "Debug")
            optimize "Off"
        popConfig()
        pushConfig(nil, "Release")
            optimize "Full"
            flags "NoRTTI"
        popConfig()
end

initProject = function(config)
    project(config.name)
        targetname "%{prj.name}_%{cfg.platform}_%{cfg.buildcfg}"
        local askedKind = parseKindName(config.kind)
        if askedKind == nil then
            askedKind = solutionConfigCurrent.defaultKind
        end
        kind(askedKind)
        uuid(os.uuid("moche_premake_generation::" .. solutionConfigCurrent.name .. "::" .. config.name))
        if config.startproject then
            solution(solutionConfigCurrent.name)
                startproject(config.name)
            project(config.name)
        end
        if config.toolset ~= nil then
            platformToolset(config.toolset)
        end
        if config.libdirs ~= nil then
            addLibdirs(config.libdirs)
        end
        if config.libs ~= nil then
            links(config.libs)
        end
        if config.incdirs ~= nil then
            addIncludedirs(config.incdirs)
        end
end

addSrcFolder = function(folder, recursive)
    local recur = ""
    if recursive == true then
        recur = "*"
    end
    files {
        folder .. "/*" .. recur .. ".h",
        folder .. "/*" .. recur .. ".hpp",
        folder .. "/*" .. recur .. ".cpp",
    }
end

premake.override(premake.vstudio.vc2010, "platformToolset", function(orig, cfg)
    if cfg.platformToolset ~= nil and _ACTION > "vs2010" then
        local t = cfg.platformToolset:lower()
        if t == "" or t == "vs" or t == "visual" or t == "cl" then
            orig(cfg)
        elseif t == "latest" or t == "ctp" or t == "vslatest" or t == "vs-latest" or t == "vs_latest" or t == "vsctp" or t == "vs-ctp" or t == "vs_ctp" or t == "visuallatest" or t == "visual-latest" or t == "visual_latest" or t == "visualctp" or t == "visual-ctp" or t == "visual_ctp" or t == "cllatest" or t == "cl-latest" or t == "cl_latest" or t == "clctp" or t == "cl-ctp" or t == "cl_ctp" then
            if _ACTION > "vs2013" then
                orig(cfg)
            elseif _ACTION > "vs2012" then
                _p(2,'<PlatformToolset>CTP_Nov2013</PlatformToolset>')
            else
                _p(2,'<PlatformToolset>v120_CTP_Nov2012</PlatformToolset>')
            end
        elseif t == "xp" or t == "vsxp" or t == "vs-xp" or t == "vs_xp" or t == "visualxp" or t == "visual-xp" or t == "visual_xp" or t == "clxp" or t == "cl-xp" or t == "cl_xp" then
            if _ACTION > "vs2012" then
                _p(2,'<PlatformToolset>v120_xp</PlatformToolset>')
            else
                _p(2,'<PlatformToolset>v110_xp</PlatformToolset>')
            end
        elseif t == "llvm" or t == "clang" or t == "clangcl" or t == "clang-cl" then
            if _ACTION > "vs2012" then
                _p(2,'<PlatformToolset>LLVM-vs2013</PlatformToolset>')
            else
                _p(2,'<PlatformToolset>LLVM-vs2012</PlatformToolset>')
            end
        elseif t == "llvmxp" or t == "llvm-xp" or t == "llvm_xp" or t == "clangxp" or t == "clang-xp" or t == "clang_xp" or t == "clangclxp" or t == "clangcl-xp" or t == "clangcl_xp" or t == "clang-clxp" or t == "clang-cl-xp" or t == "clang-cl_xp" then
            if _ACTION > "vs2012" then
                _p(2,'<PlatformToolset>LLVM-vs2013_xp</PlatformToolset>')
            else
                _p(2,'<PlatformToolset>LLVM-vs2012_xp</PlatformToolset>')
            end
        else
            _p(2,'<PlatformToolset>'..cfg.platformToolset..'</PlatformToolset>')
        end
    else
        orig(cfg)
    end
end)

newoption {
    trigger = "log",
    value = "Log level",
    description = "The maximum log level to display",
    allowed = {
        { "none" },
        { "always" },
        { "error" },
        { "warning" },
        { "debug" },
        { "trace" },
        { "all" },
    },
}

if (_OPTIONS["log"] ~= nil) then
    local level = _OPTIONS["log"]:lower()
    if level == "none" then
        setLogLevel(LogLevel.None)
    elseif level == "always" then
        setLogLevel(LogLevel.Always)
    elseif level == "error" then
        setLogLevel(LogLevel.Error)
    elseif level == "warning" then
        setLogLevel(LogLevel.Warning)
    elseif level == "debug" then
        setLogLevel(LogLevel.Debug)
    elseif level == "trace" then
        setLogLevel(LogLevel.Trace)
    elseif level == "all" then
        setLogLevel(LogLevel.All)
    end
end

premake.api.register {
    name = "platformToolset",
    scope = "config",
    kind = "string",
}

moche = {
    util = {
        dump        = dump,
        isObject    = isObj,
        deepCopy    = deepCopy,
        setLogLevel = setLogLevel,
        getLogLevel = getLogLevel,
        LogLevel    = LogLevel,
    },
    parse = {
        solution    = parseSolution,
        project     = parseProject,
        folder      = parseFolder,
        projects    = parseSolutionProjects,
        src         = exploreSrcFolder,
    },
    pushGroup       = pushGroup,
    popGroup        = popGroup,
    pushConfig      = pushConfig,
    popConfig       = popConfig,
    defines         = addDefines,
    flags           = addFlags,
    incdirs         = addIncludedirs,
    libdirs         = addLibdirs,
    solution        = initSolution,
    project         = initProject,
    src             = addSrcFolder,
}
