-- Reference: http://support.f5.com/kb/en-us/solutions/public/6000/900/sol6917.html#ipv4rd
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

local cookie_upstream = ngx.var.cookie_NginxUpSvr
if cookie_upstream then
    local upstream = decode_upstream(cookie_upstream)
    if upstream then
        ngx.var.svrbind = upstream
    end
end
