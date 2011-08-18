local p = "/opt/conf/nginx/lua/"
package.path = string.format("%s;%s/?.lua", package.path, p)

local svrapply_rp = require "svr_for_code_test"
svrapply_rp.svrapply_rp()
