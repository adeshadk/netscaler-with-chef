netscaler Cookbook
======================
 cookbook communicates with netscaler load balancers on SSH.
 Can do following:
 1) actions: add,remove and set actions of type cs,rewrite and responder
 2) SSL certificates: Add/removed SSL certificate, for adding certficate certificate and key file should exists in on netscaler
 3) Content Switch Virtual Servers: Enable disable, add, remove, set and bind content switch servers to policies and lb vservers
 3) LB Virtual Servers: Enable disable, add, remove, set and bind content switch servers to policies and services/servicegroups
 5) Policies: add,remove and set policies of type cs,rewrite and responder 
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

