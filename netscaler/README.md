netscaler Cookbook
======================
 cookbook communicates with netscaler load balancers on SSH.
 Can do following:
 1) actions: add,remove and set actions of type cs,rewrite and responder
 2) SSL certificates: Add/removed SSL certificate, for adding certficate certificate and key file should exists in on netscaler
 3) Content Switch Virtual Servers: Enable disable, add, remove, set and bind content switch servers to policies and lb vservers
 3) LB Virtual Servers: Enable disable, add, remove, set and bind content switch servers to policies and services/servicegroups
 5) Policies:
 6) Pattern sets: Add,remove pattern sets, bind and unbind patterns  to pattern sets
 7) Service and Servicegroup: enable,disable, add,set,remove services/servicegroups. bind/unbind service to members
 8) Server: add,remove server

Requirements
------------
Uses Net::SSH to communicates with netscaler

Attributes
----------
default['netscaler']['management_ip'] = ""
default['netscaler']['login_name'] = ""
default['netscaler']['login_passwd'] = ""

Usage
-----
Pass the IP, crendentials and needed parameter to each of the recipe

Contributing
------------
TODO: (optional) If this is a public cookbook, detail the process for contributing. If this is a private cookbook, remove this section.

e.g.
1. Fork the repository on Github
2. Create a named feature branch (like `add_component_x`)
3. Write your change
4. Write tests for your change (if applicable)
5. Run the tests, ensuring they all pass
6. Submit a Pull Request using Github

License and Authors
-------------------
Authors:
Adesh Kumar
Art.com

