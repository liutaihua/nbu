if ngx.var.svrbind == "null" then
    ngx.say("empty NginxUpSvr coookie, panic!")
else
    ngx.say("currently bind to: " .. ngx.var.svrbind)
end
