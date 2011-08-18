local p = "/opt/conf/nginx/lua/"
package.path = string.format("%s;%s/?.lua", package.path, p)

local svrapply_cp = require "svr_for_code_test"
svrapply_cp.svrapply_cp()
