netscaler Cookbook
======================
 cookbook communicates with netscaler load balancers on SSH.
 Can do following:
 1) actions: add,remove and set actions of type cs,rewrite and responder
 2) SSL certificates: Add/removed SSL certificate, for adding certficate certificate and key file should exists in on netscaler
 3) Content Switch Virtual Servers:
 

Requirements
------------
Uses Net::SSH to communicates with netscaler

Attributes
----------
TODO: List your cookbook attributes here.

e.g.
#### netscaler::default
<table>
  <tr>
    <th>Key</th>
    <th>Type</th>
    <th>Description</th>
    <th>Default</th>
  </tr>
  <tr>
    <td><tt>['netscaler']['bacon']</tt></td>
    <td>Boolean</td>
    <td>whether to include bacon</td>
    <td><tt>true</tt></td>
  </tr>
</table>

Usage
-----
#### netscaler::default
TODO: Write usage instructions for each cookbook.

e.g.
Just include `netscaler` in your node's `run_list`:

```json
{
  "name":"my_node",
  "run_list": [
    "recipe[netscaler]"
  ]
}
```

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
Authors: TODO: List authors
