pwd = Dir.getwd + "/"

cookbook_path    [ pwd + "cookbooks", pwd + "site-cookbooks"]
node_path        pwd + "nodes"
role_path        pwd + "roles"
environment_path pwd + "environments"
data_bag_path    pwd + "data_bags"

