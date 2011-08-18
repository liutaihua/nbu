-- From: http://en.wikipedia.org/wiki/X-Forwarded-For
-- The general format of the field is: X-Forwarded-For: client1, proxy1, proxy2
-- the left-most being the farthest downstream client,
-- and each successive proxy that passed the request adding the IP address where it received the request from
module(..., package.seeall)


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
