# encoding: utf-8

require 'bundler'
Bundler.require
require 'csv'
require 'json'

def csv_path sheet_name
  doc_name = 'ebay送料-システム用'
  "./data/#{doc_name} - #{sheet_name}.csv"
end

zones             = CSV.table csv_path('ゾーン一覧')         , header_converters: nil
countries         = CSV.table csv_path('国一覧')             , header_converters: nil
methods           = CSV.table csv_path('発送方法一覧')       , header_converters: nil
countries_methods = CSV.table csv_path('国×発送方法')       , header_converters: nil
methods_weights   = CSV.table csv_path('発送方法×重量一覧') , header_converters: nil

cs = countries.map{|r|
  country = r['国名']
  {
    name: country.gsub("\n", ' '),
    methods: countries_methods.select{|r| r['国名'] == country && r['発送可否'] == 'OK'}.map{|r|r['発送方法一覧.発送方法名']}.sort,
    zone_orig: r['ゾーン一覧.ゾーン名']
  }
}

new_zones = cs.group_by{|c|
  [c[:methods], c[:zone_orig]].join
}

# cs.map{|c|
#   ms = c[:methods]
#   if ms.size != ms.uniq.size
#     puts c[:name]
#     puts c[:methods].join("\n")
#     puts
#   end
# }
# exit

country_zones = {}

new_zones = Hash[new_zones.map.with_index(1) { |(k,cs),i|
  cs.each do |_|
    country = _[:name]
    methods = _[:methods]
    zone = "Zone #{i}"
    zone_orig = _[:zone_orig]
    country_zones[country] = {
      methods: methods,
      zone: zone,
      zone_orig: zone_orig
    }
    country_zones[country][:methods] = country_zones[country][:methods].map {|_|
     {
       name: _,
       costs: methods_weights.select{|r| r['発送方法一覧.発送方法名'] == _ && r['ゾーン一覧.ゾーン名'] == zone_orig }.map{|w|
         {
           weight: "#{w['重量範囲（より大きい）']}g - #{w['重量範囲（以下）']}g",
           cost: "#{w['金額（円）']}JPY"
         }
       }
     }
    }
  end
  ["Zone #{i}", cs]
}]

# new_zones.each do |(k,cs)|
#   p cs
#   puts
# end

File.open('./build/latest.json', 'w') do |f|
  f.puts country_zones.to_json
end

# puts new_zones.to_json
