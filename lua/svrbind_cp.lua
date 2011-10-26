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

svrbind_cp()
