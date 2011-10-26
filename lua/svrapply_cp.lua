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


svrapply_cp()
