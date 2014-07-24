#encoding: utf-8

namespace :passes do

  require 'nokogiri'
  require "#{Rails.root}/lib/tasks/task_utilities"
  include TaskUtilities

  desc "Fetch some information about this region"
  task :fetch => :environment do

    ROOT_URL="http://www.tornanti.it/html/"

    italy = openUrl(ROOT_URL + "mappa.htm").css("map area")
    
    italy.each do |region_link|
      url = region_link.attr("href").to_s
      if !url.nil? && url != "#"
        region_page = openUrl(ROOT_URL + url)
        
        region_name = region_link.attr("alt").to_s
        region = Region.search(region_name)
        num_pages = region_page.css("p").last.css("b").last.text.match(/[0-9]+/).to_s.to_i

        puts region.name 
        puts "\t url => " + url
        puts "\t num_pages => " + num_pages.to_s

        if num_pages > 1 
          1.upto(num_pages) { |page_index| 
            parse_table(region_page.css("table").first, region)
          }
        else
          parse_table(region_page.css("table").first, region)
        end

      end
    end

  end

end

def parse_name name
  if name.match(",")
    name = name.split(",")
    return name[1] + " " + name[0]
  else
    return name
  end
end

def get_municipality locality
  municipality = Municipality.search(locality)

  if municipality.nil?
    if locality == "Isolaccia"
      return Municipality.search("Valdidentro")
    end
  end

  return municipality
end



def parse_table table, region

  foreign_pass = ["Livigno, Forcola"]

  table.css("tr")[1..-1].each_with_index do |pass_info, index|
    
    name = pass_info.css("td").first.text
    altitude = pass_info.css("td")[1].text
    locality = pass_info.css("td").last.text
    
    if !encode(locality).match(/sud|nord|est|ovest|^da|bivio/) && !foreign_pass.include?(name)
      municipality = Municipality.search(locality)
      puts "\t\t" + parse_name(name) + " (" + altitude + ") - " + municipality.name
    end

  end
end