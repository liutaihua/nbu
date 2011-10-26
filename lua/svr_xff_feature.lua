--module(..., package.seeall)

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


function svrapply_cp()
if ngx.var.svrapply == "null" then
    ngx.say("empty or incorrect parameter, panic!")
else
    local encoded_upstream = ngx.encode_base64(ngx.var.svrapply)
    if ngx.var.svrapply_ot ~= "null" then
        local encoded_upstream_ot = ngx.encode_base64(ngx.var.svrapply_ot)

        if encoded_upstream == nil or encoded_upstream_ot == nil then
            ngx.say("encoding failed, panic!")
        else
            -- Expire: Thursday, 19-May-2011 10:04:12 GMT
            cookie_expire = os.date("%a, %d-%b-%Y %H:%M:%S GMT", os.time()-3600*8+86400*2)
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

function svrbind_rp()
local cookie_upstream = ngx.var.cookie_NginxUpSvr
local cookie_upstream_ot = ngx.var.cookie_NginxUpSvr_OT
if cookie_upstream then
    local upstream = ngx.decode_base64(cookie_upstream)
    if cookie_upstream_ot and upstream then
        local upstream_ot = ngx.decode_base64(cookie_upstream_ot)
        ngx.var.svrbind = upstream
        ngx.var.svrbind_ot = upstream_ot
    elseif upstream then
            ngx.var.svrbind = upstream
    end
end
end


function svrbind_cp()
if ngx.var.svrbind == "null" then
    ngx.say("empty NginxUpSvr coookie, panic!")
else
    if ngx.var.svrbind ~= "null" then
        if ngx.var.svrbind_ot ~= "null" then
            ngx.say("currently bind to: " .. ngx.var.svrbind)
            ngx.say("currently bind to: " .. ngx.var.svrbind_ot)
        else
            ngx.say("currently bind to: " .. ngx.var.svrbind)
        end
        
    else
        ngx.say("currently bind to: " .. ngx.var.svrbind)
    end
end
end


function secure_xff()
local secure_xff = ngx.var.remote_addr
if ngx.var.http_x_forwarded_for then
    -- Currently, we trust proxy servers who came from 10.0.0.0/8
    -- which is the 24-bit private block in RFC 1918
    -- Of course this does not exclude valid public addresses, just place more elseif below
    if string.find(ngx.var.remote_addr, "^10\.") then
        secure_xff = ngx.var.http_x_forwarded_for .. ", " .. ngx.var.remote_addr
    end
    ngx.var.secure_xff = secure_xff
end
end


svrbind_rp()
secure_xff()
