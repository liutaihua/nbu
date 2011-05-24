# nbu for Nginx Bind Upstream

## Synopsis




## Goal

The sole aim of this little project is to let you forget /etc/hosts

## Backstory

Nowadays the most common architecture for web applications looks like this:

    Netscaler/F5/A10/LVS(Layer4 Load-banlancer) -> Nginx(Layer 7 Load-banlancer) -> AppServer(s)

Usually, application servers don't have public addresses which are assigned to Layer4 or layer7 load-balancer exclusively.
This raises a surprisingly hard problem for 

1. Developers who may want to access a specific app server
2. QA who does not know what kind of entry should be added to /etc/hosts

And every op guy is reinventing wheel(port forwarding, VPN) to make dev and QA's life easier. However, under most circumstances, he will bite his own foot.

## The Solution


