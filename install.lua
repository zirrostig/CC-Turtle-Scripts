local function split(str, delim)
    local s = {}
    local pos = (str:find(delim))
    s[1] = str:sub(0, pos-1)
    s[2] = str:sub(pos+1)
    return s
end

local function pull()
    local updateList = http.get('https://raw.github.com/Zirrostig/CC-Turtle-Scripts/master/installList.cfg')
    if not updateList then
        print("Couldn't pull files")
        return false
    end
    fileCount = tonumber(updateList.readLine())
    local files = {}
    -- Parse Config File
    for fnum=1,fileCount do
        local cfgLn = split(updateList.readLine(), '=')
        files[cfgLn[1]] = cfgLn[2]
    end

    for lf, rf in pairs(files) do
        local f = fs.open(lf, 'w')
        local nf = http.get(rf)
        f.write(nf)
    end
end













