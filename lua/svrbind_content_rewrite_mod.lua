local p = "/opt/conf/nginx/lua/"
package.path = string.format("%s;%s/?.lua", package.path, p)

local svrbind_cp = require "svr_for_code_test"

svrbind_cp.svrbind_cp()
