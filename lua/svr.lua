module(..., package.seeall)


-------------- svrapply rewrite remote by lua -----------------------------------
function svrapply_rp()
local query_string = ngx.var.query_string
local ip, port, _tmp
local ip_ot, port_ot, _ot
if query_string then
    _tmp = string.match(query_string, "server=(%d+\.%d+\.%d+\.%d+:?%d*)")
    ip = string.match(_tmp, "(%d+\.%d+\.%d+\.%d+)")
    port = string.match(_tmp, ":(%d+)")
    _ot = string.match(query_string, "other=(%d+\.%d+\.%d+\.%d+:?%d*)")
    if _ot ~= nil then
        ip_ot = string.match(_ot, "(%d+\.%d+\.%d+\.%d+)")
        port_ot = string.match(_ot, ":(%d+)")
        if port_ot == nil then
            ngx.var.svrapply_ot = ip_ot .. ":80"
        else
            ngx.var.svrapply_ot = ip_ot .. ":" .. port_ot
        end
    end

    if port == nil then
        ngx.var.svrapply = ip .. ":80"
    else
        ngx.var.svrapply = ip .. ":" .. port
    end

end
end
-------------- end svrapply rewrite remote by lua -------------------------------


--------------- svrapply rewrite content by lua -----------------------------
function encode_upstream(upstream_full)
    local result

    upstream_ipaddr = string.match(upstream_full, "^(%d+\.%d+\.%d+\.%d+)")
    upstream_port   = string.match(upstream_full, ":(%d+)$")

    encoded_ipaddr = ipaddr_bigint(upstream_ipaddr)
    encoded_port = port_bigint(upstream_port)

    if (encoded_ipaddr == nil or encoded_port == nil) then
        result = nil
    else
        result = encoded_ipaddr .. "." .. encoded_port .. "." .. "0000"
    end

    return result
end

-- in:  decimal port
-- out: bigint representation of reversed hex port
function port_bigint(port)
    port = tonumber(port)

    if port >= 1 and port <= 65535 then
        local hex_port = string.format("%x", port)
        local len = string.len(hex_port)

        if len == 1 then
            hex_port = "000" .. hex_port
        elseif len == 2 then
            hex_port = "00" .. hex_port
        elseif len == 3 then
            hex_port = "0" .. hex_port
        elseif len > 4 or len < 1 then
            return nil
        end

        local part1, part2 = string.match(hex_port, "(%w%w)(%w%w)")
        local reversed_hex_port = part2 .. part1

        return tonumber("0x" .. reversed_hex_port)
    else
        return nil
    end
end

-- in:  ipv4 address
-- out: bigint representation of ipv4 address
function ipaddr_bigint(ipaddr)
    local idx = 0
    local result = 0

    for part in string.gmatch(ipaddr, "%d+") do
        result = result + part*(256^idx)
        idx = idx + 1
    end

    if result >= 0 then
        return result
    else
        return nil
    end
end

function svrapply_cp()
if ngx.var.svrapply == "null" then
    ngx.say("empty or incorrect parameter, panic!")
else
    local encoded_upstream = encode_upstream(ngx.var.svrapply)
    if ngx.var.svrapply_ot ~= "null" then
        local encoded_upstream_ot = encode_upstream(ngx.var.svrapply_ot)

        if encoded_upstream == nil or encoded_upstream_ot == nil then
            ngx.say("encoding failed, panic!")
        else
            -- Expire: Thursday, 19-May-2011 10:04:12 GMT
            cookie_expire = os.date("%a, %d-%b-%Y %H:%M:%S GMT", os.time()-3600*8+86400*2)
            --ngx.header["Set-Cookie"] = { "NginxUpSvr=" .. encoded_upstream .. "; Expires=" .. cookie_expire .. "; path=/; httponly" }
            ngx.header["Set-Cookie"] = { "NginxUpSvr_OT=" .. encoded_upstream_ot .. "; Expires=" .. cookie_expire .. "; path=/", "NginxUpSvr=" .. encoded_upstream .. "; Expires=" .. cookie_expire .. "; path=/; httponly" }
            ngx.say("bind to:" .. ngx.var.svrapply)
            ngx.say("bind to:" .. ngx.var.svrapply_ot)
        end
    else
        if encoded_upstream == nil then
            ngx.say("encoding failed, panic!")
        else
            -- Expire: Thursday, 19-May-2011 10:04:12 GMT
            cookie_expire = os.date("%a, %d-%b-%Y %H:%M:%S GMT", os.time()-3600*8+86400*2)
            ngx.header["Set-Cookie"] = { "NginxUpSvr=" .. encoded_upstream .. "; Expires=" .. cookie_expire .. "; path=/; httponly" }
            ngx.say("bind to:" .. ngx.var.svrapply)
        end
    end
        
end
end

--------------- end  svrapply rewrite content by lua ----------------------------



--------------- svrbind rewrite remote by lua -----------------------------------
function decode_upstream(encoded_upstream_full)
    local result

    encoded_upstream_ipaddr = string.match(encoded_upstream_full, "^(%d+)")
    encoded_upstream_port   = string.match(encoded_upstream_full, "\.(%d+)\.0000$")

    upstream_ipaddr         = bigint_ipaddr(encoded_upstream_ipaddr)
    upstream_port           = bigint_port(encoded_upstream_port)

    if (upstream_ipaddr == nil or upstream_port == nil) then
        result = nil
    else
        result = upstream_ipaddr .. ":" .. upstream_port
    end

    return result
end


-- in:  bigint representation of reversed hex port
-- out: decimal port
function bigint_port(bigint)
    bigint = tonumber(bigint)

    if bigint then
        local reversed_hex_port = string.format("%x", bigint)
        local len = string.len(reversed_hex_port)

        local part1, part2 = nil, nil
        if len == 3 then
            part1, part2 = string.match("0" .. reversed_hex_port, "^(%w%w)(%w%w)$")
        else
            part1, part2 = string.match(reversed_hex_port, "^(%w%w)(%w%w)$")
        end

        if part1 and part2 then
            return tonumber('0x' .. part2 .. part1)
        else
            return nil
        end
    else
        return nil
    end
end

-- in:  bigint representation of ipv4 address
-- out: ipv4 address
function bigint_ipaddr(bigint)
    bigint = tonumber(bigint)

    local reversed_hex_ipaddr = string.format("%x", bigint)
    local idx = 8 - string.len(reversed_hex_ipaddr)
    local want_str = ""

    if idx == 0 then
        reversed_hex_ipaddr = reversed_hex_ipaddr
    elseif idx >=1 and idx <=7 then
        while idx > 0 do
            want_str = want_str .. "0"
            idx = idx - 1
        end
        reversed_hex_ipaddr = want_str .. reversed_hex_ipaddr
    else
        return nil
    end

    local part1, part2, part3, part4 = string.match(reversed_hex_ipaddr, "^(%w%w)(%w%w)(%w%w)(%w%w)$")
    if part1 and part2 and part3 and part4 then
        return tonumber("0x" .. part4) .. "." .. tonumber("0x" .. part3) .. "." .. tonumber("0x" .. part2) .. "." .. tonumber("0x" .. part1)
    else
        return nil
    end
end


function svrbind_rp()
local cookie_upstream = ngx.var.cookie_NginxUpSvr
local cookie_upstream_ot = ngx.var.cookie_NginxUpSvr_OT
if cookie_upstream then
    local upstream = decode_upstream(cookie_upstream)
    if cookie_upstream_ot and upstream then
        local upstream_ot = decode_upstream(cookie_upstream_ot)
        ngx.var.svrbind = upstream
        ngx.var.svrbind_ot = upstream_ot
    elseif upstream then
            ngx.var.svrbind = upstream
    end
end
end

--------------- end svrbind rewrite remote by lua --------------------------------



--------------- svrbind rewrite content by lua -----------------------------------
function svrbind_cp()
if ngx.var.svrbind == "null" then
    ngx.say("empty NginxUpSvr coookie, panic!")
else
    if ngx.var.svrbnd ~= "null" then
        ngx.say("currently bind to: " .. ngx.var.svrbind)
        ngx.say("currently bind to: " .. ngx.var.svrbind_ot)
    else
        ngx.say("currently bind to: " .. ngx.var.svrbind)
    end
end
end
--------------- end svrbind rewrite content by lua -------------------------------
