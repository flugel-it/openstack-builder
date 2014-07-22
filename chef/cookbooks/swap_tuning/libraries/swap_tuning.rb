# encoding: UTF-8
#
# Author:: Xabier de Zuazo (<xabier@onddo.com>)
# Copyright:: Copyright (c) 2014 Onddo Labs, SL. (www.onddo.com)
# License:: Apache License, Version 2.0
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

require 'chef/application'

class Chef
  # Methods to recommend swap sizes depending on memory values
  module SwapTuning
    def self.memory2bytes(memory)
      case memory.to_s
      when /^([0-9]+)GB$/i then Regexp.last_match[1].to_i * 1_073_741_824
      when /^([0-9]+)MB$/i then Regexp.last_match[1].to_i * 1_048_576
      when /^([0-9]+)KB$/i then Regexp.last_match[1].to_i * 1024
      when /^([0-9]+)B?$/i then Regexp.last_match[1].to_i
      when nil then 0
      else Chef::Application.fatal!("Unknown size: #{memory}")
      end
    end

    def self.memory2mbytes(memory)
      memory2bytes(memory).to_f / 1_048_576
    end

    def self.memory2gbytes(memory)
      memory2mbytes(memory) / 1024
    end

    def self.unknown_size_check(memory)
      Chef::Log.warn(
        "RAM size too high (#{memory2gbytes(memory).round} GB), "\
        'I may not be able to choose the best swap size. Best size will be'\
        'workload dependent.'
      ) if memory > 68_719_476_736 # 64 GB
    end

    def self.recommended_size_bytes(memory)
      memory_b = memory2bytes(memory)
      unknown_size_check(memory_b)
      if memory_b <= 2_147_483_648 # 2 GB
        memory_b * 2
      elsif memory_b <= 8_589_934_592 # 8 GB
        memory_b
      else
        (memory_b.to_f / 2).ceil
      end
    end

    def self.recommended_size_mb(memory)
      bytes = recommended_size_bytes(memory)
      (bytes.to_f / 1_048_576).ceil
    end
  end
end
