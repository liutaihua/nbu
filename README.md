# Nginx Bind Upstream

## Synopsis

    server {
        listen                              80;
        server_name                         foo.com;

        # applicants visit this page to allow cookie inserted
        include                             svrapply.conf;

        # applicants query this page to know which server he is bind to currently.
        # also contains decode logic
        include                             svrbind.conf;

        proxy_set_header                    Host $host;

        location / {
            # the context of binding is location*
            set                             $svrbind "normal_upstream";
            rewrite_by_lua_file             lua/svrbind_rp.lua;
            proxy_pass                      http://$svrbind;
        }

        upstream normal_upstream {
            server 192.168.0.11;
            server 192.168.0.12;
            server 192.168.0.13;
        }
    }

    # * there is no http/server context due to the natural of this problem

## Steps to integrating nbu

1. add the following line to the server block. It adds an extra location `location = /svrapply`.

        server {
            ......
            include svrapply.conf;
            ......
        }

2. insert another line into the serverblock. It adds an extra location `location = /svrbind`. When visited, it will display the current binding server.

        server {
            ......
            include svrbind.conf;
            include svrapply.conf;
            ......
        }    

3. In the location block, replace the address part of proxy_pass/fastcgi_pass with a variable called `$svrbind`. Then add the following two lines:

        server {
            ......
            include svrbind.conf;
            include svrapply.conf;
            ......
          
            location / {
                # replace upstream addr with $svrbind variable
                proxy_pass             http://$svrbind;

                # rewrite_by_lua_file will modify $svrbind accordingly
                set                    $svrbind "normal_upstream";
                rewrite_by_lua_file    /opt/conf/nginx/lua/svrbind_rp.lua;
            }
        }    

`normal_upstream` is your original upstream address; `rewrite_by_lua_file` will set svrbind variable to the current binding upstream.
Finally, nginx will send request the user-defined upstream.

## Steps to use nbu 

Suppose your website is located at: `http://foo.bar.com`:

1. visit the following url:

    http://foo.bar.com/svrapply?server=192.168.2.111:8080

    the `server` parameter is the upstream server to be bind to. 

2. (optional) verify if the previous binding succeeded or you want to find out which is the current binding server

    http://foo.bar.com/svrbind

3. We are done! Now you can proceed as normal.


### Note

* For non-browser agent, such as curl, one must explicitly send cookie to server each time.

## Goal

The sole aim of this little project is to let you forget /etc/hosts

## Backstory

Nowadays the most common architecture for web applications looks like this:

    Netscaler/LVS(Layer4 Load-balancer) -> Nginx(Layer 7 Load-banlancer) -> AppServer(s)

Usually, application servers don't have public addresses which are assigned to Layer4 or layer7 load-balancer exclusively.
This raises a surprisingly hard problem for 

1. Developers who may want to access a specific app server.
2. QA who does not know what kind of entry should be added to /etc/hosts.

Every op guy will reinvent wheel(port forwarding, VPN) to make dev and QA's life easier. However, under most circumstances, he will bite his own foot. There is just __NO__ free lunch.

## Analyze the problem

First, we define access a specific app server behind load-balancer as a `binding problem`. Then, we call people who want to bind to a specific app server as a `applicant`. 

The key observations are:

1. All the binding stuff should be done at layer7. This means we don't need any solution below it, because port forwarding or VPN is too heavy a hammer and unavoidably have too much __side effects__.

2. Each applicant submit their own requests, requests are isolated and remembered.

3. The problem is caused by load-balancer, so it may be good to solve it in load-balancer. Thus, binding problem is equal to a application routing problem and all the routing logic should be implemented in Layer4 or Layer7.

## The Solution

It is __simple__:

1. Applicant visits a specific page to tell load-balancer(e.,g nginx) which app server to bind to.
2. Nginx encode the `(ip, port)` tuple, then insert a domain cookie including the encoded tuple.
3. Applicant visits some page in the previous domain, nginx decode the cookie value and examine its expiration date. If the cookie is not expired, proxy request to the target server. Otherwise, apply normal proxy logic.

## Implementation

Read the code, it's very short.

## Prerequisite
The only requirement is to add nginx-lua-module: [lua-nginx-module](https://github.com/chaoslawful/lua-nginx-module)
