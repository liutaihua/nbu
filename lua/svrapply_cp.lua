-- Reference: http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html#ipv4rd
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

if ngx.var.svrapply == "null" then
    ngx.say("empty or incorrect parameter, panic!")
else
    local encoded_upstream = encode_upstream(ngx.var.svrapply)

    if encoded_upstream == nil then
        ngx.say("encoding failed, panic!")
    else
        -- Expire: Thursday, 19-May-2011 10:04:12 GMT
        cookie_expire = os.date("%a, %d-%b-%Y %H:%M:%S GMT", os.time()-3600*8+86400*2)
        ngx.header["Set-Cookie"] = { "NginxUpSvr=" .. encoded_upstream .. "; Expires=" .. cookie_expire .. "; path=/; httponly" }
        ngx.say("bind to:" .. ngx.var.svrapply)
    end
end
