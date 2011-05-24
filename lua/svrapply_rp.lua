local query_string = ngx.var.query_string
local ip, port

if query_string then
    ip = string.match(query_string, "server=(%d+\.%d+\.%d+\.%d+)")
    port = string.match(query_string, ":(%d+)")

    if port == nil then
        ngx.var.svrapply = ip .. ":80"
    else
        ngx.var.svrapply = ip .. ":" .. port
    end
end
