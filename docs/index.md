# What is PSc.CloudDNS

I wrote PSc.CloudDNS during a project when we wanted to migrate the DNS zone management of over 200 domains from CSC (also know as Netnames) and to Azure DNS.
Netnames didn't have an API at the time (2019) and only offered txt exports of each zone one by one.

To make this project happen, I set out to write a script to parse the txt files and then re-create them in Azure Public DNS. Thankfully everything went well, and I also did a handful of AWS Route 53 to Azure DNS migrations.

I thought that this tooling might be useful for others, so decided to clean up the code and publish it for all to use.

I would love to hear any feedback, or take any feature requests for improvements!