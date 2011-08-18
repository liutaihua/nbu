local p = "/opt/conf/nginx/lua/"
package.path = string.format("%s;%s/?.lua", package.path, p)

local svrbind_rp = require "svr_for_code_test"
local xff_secure = require "xff-beta"

svrbind_rp.svrbind_rp()
