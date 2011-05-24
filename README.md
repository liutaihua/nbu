# Nginx Bind Upstream( implemented using nginx-lua-module )

## Synopsis




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

## The Solution

First, we define `access a specific app server behind load-balancer` as a binding problem. Then, we call people who want to acess a specific server as a __APPLICANT__. 

The key observations are:

1. All the binding stuff should be done at layer7. This means we don't need any solution below it, because port forwarding or VPN is too heavy a hammer and unavoidably have too much __side effects__.

2. Each applicant submit their own requests, requests are isolated and remembered.

3. The problem is caused by load-balancer, so it may be good to solve it in load-balancer. Thus, binding problem is equal to a application routing problem and all the routing logic should be implemented in Layer4 or Layer7.