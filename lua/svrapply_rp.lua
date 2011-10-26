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

svrapply_rp()
