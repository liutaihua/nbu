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

svrbind_rp()
