cookbook_path    ["cookbooks", "site-cookbooks"]
node_path        "nodes"
role_path        "roles"
environment_path "environments"
data_bag_path    "data_bags"
syntax_check_cache_path  '~/.chef/syntax_check_cache'
#encrypted_data_bag_secret "data_bag_key"

knife[:berkshelf_path] = "cookbooks"
