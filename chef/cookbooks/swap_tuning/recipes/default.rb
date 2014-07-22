# encoding: UTF-8
#
# Cookbook Name:: swap_tuning
# Recipe:: default
#
# Copyright 2014, Onddo Labs, SL.
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

self.class.send(:include, Chef::SwapTuning::RecipeHelpers)

unless node['swap_tuning']['file_prefix'].nil?

  # Calculate swap size
  if node['swap_tuning']['size'].nil?
    node.default['swap_tuning']['size'] = Chef::SwapTuning.recommended_size_mb(node['memory']['total'])
    if !node['swap_tuning']['minimum_size'].nil? &&
       node['swap_tuning']['size'] < node['swap_tuning']['minimum_size']
      node.default['swap_tuning']['size'] = node['swap_tuning']['minimum_size']
    end
  end

  i = 0
  current_size = swap_size_mb
  # margin of 10 MB and 10 swapfiles maximum
  while current_size + 10 < node['swap_tuning']['size'] && i < 10
    remaining_size = node['swap_tuning']['size'] - current_size

    swap_file "#{node['swap_tuning']['file_prefix']}#{i}" do
      size remaining_size # MBs
      persist node['swap_tuning']['persist']
      not_if do
        # not required
        ::File.exist?("#{node['swap_tuning']['file_prefix']}#{i}")
      end
    end.run_action(:create)

    i += 1
    current_size = swap_size_mb
  end

end
