#encoding: utf-8

module TaskUtilities 
  require 'nokogiri'
  require 'open-uri'
  require 'timeout'

  @@TUTTITALIA_URL = "http://www.tuttitalia.it"
  @@WIKIPEDIA_URL = "https://it.wikipedia.org/wiki/"

  def openUrl url
    result = nil
    begin
      retryable(:tries => 10, :on => Timeout::Error) do
        result = Nokogiri::HTML(open(URI.encode(url), 'User-Agent' => 'ruby'))
      end
    rescue SocketError => se
      puts "Got Socket error: #{se}"
    rescue OpenURI::HTTPError => he
      puts "Got HTTP Error: #{he}"
    end

    return result
  end

  def getPicture url
    begin
      retryable(:tries => 10, :on => Timeout::Error) do
        return open(url)
      end
    rescue OpenURI::HTTPError => ex
      puts "No picture for found!"
    end 
  end

  def retryable(options = {})
    opts = { :tries => 1, :on => Exception }.merge(options)

    retry_exception, retries = opts[:on], opts[:tries]

    begin
      return yield
    rescue retry_exception
      if (retries -= 1) > 0
        sleep 2
        retry 
      else
        raise
      end
    end
  end

  def regions_links
    openUrl(@@TUTTITALIA_URL).css("div.fa a").to_a.keep_if {|link| 
      !link.attr("href").match(/regioni/) && 
      !link.attr("href").match(/popolazione/)}
  end

  def provinces_links
    links = []

    regions_links.each do |region_link|

      region_url = region_link.attr("href")
      region_page = openUrl(@@TUTTITALIA_URL + region_url)
      
      if region_url == "/valle-d-aosta/"
        links << region_page.css("table.af a")
        
      else
        region_page.css("table.ut tr")[1...-1].each do |p|
          links << p.css("a")
        end
      end
    end

    return links
  end

  def municipalities_links
    links = []
    
    provinces_links.each do |province_link|
      province_url = province_link.attr("href")
      province_page = openUrl(@@TUTTITALIA_URL + province_url)
      
      municipalities_links = province_page.css("table.at a")
      municipalities_links.each do |municipality_link|

        region_name = province_page.css("table.uj td.oz").first.next_element.text
        ragion_name_coded = region_name.downcase.gsub(" ", "-").gsub("'","-")
        links << @@TUTTITALIA_URL + "/" +
          ragion_name_coded + "/" + municipality_link.attr("href")[3..-1]
      end
    end

    return links
  end

  def addSymbol object, url
    picture = Picture.new
    picture.photo = getPicture(url)
    picture.picturable = object
    object.symbol = picture
  end

  def encode name
    return name.gsub(/[^0-9A-Za-z]/, '').downcase
  end

  def findItemByName class_name, item_name
    items = []
    class_name.constantize.all.each do |item|
      if encode(item.name) == encode(item_name)
        items << item
      end
    end

    return nil if items.empty?
    return items.first if items.size == 1
    return items
  end

  def findMunicipalityByName province_id, name
    Municipality.all.each do |item|
      if encode(item.name) == encode(name) && province_id.to_i == item.province.id
        return item
      end
    end
    return nil
  end

  def extractMunicipality province_id, name
    item = findMunicipalityByName(province_id, name)
    item = Municipality.new if item == nil
    return item
  end

  def extractItem class_name, item_name
    item = findItemByName(class_name, item_name)
    if item == nil
      item = class_name.constantize.new
      item.name = item_name
    end
    return item
  end

  def parseGeneralInfo object_page, object
    
    object_page.css("table.uj td").each do |info|

      if info.text == "Popolazione"
        population = info.next_element.text.split(" ")[0]
        puts "\t Population => " + population
        object.population = population.gsub(".","").to_i

      elsif info.text == "Densità"
        density = info.next_element.text.split(" ")[0]
        puts "\t Density => " + density
        object.density = density.gsub(",",".").to_f

      elsif info.text == "Superficie"
        surface = info.next_element.text.split(" ")[0]
        puts "\t Surface => " + surface
        object.surface = surface.gsub(".","").gsub(",",".").to_f

      elsif object.class.name != "Municipality" && info.text == "Sigla"
        abbreviation = info.next_element.text.split(" ")[0]
        puts "\t Abbreviation => " + abbreviation
        object.abbreviation = abbreviation

        # TODO: TO BE EXECUTED WHEN PROVINCES ARE STORED IN DB
      # elsif object.capital_id == nil && info.text == "Capoluogo"
      #   # capital_name = info.next_element.text[0..((info.next_element.text =~ /\d/).to_i - 1)]
      #   # puts "\t Capoluogo => " + capital_name
      #   #capital = Province.where(:name => capital_name).first
      #   # object.capital_id = capital.id
       end

     end

    if object_page.css("a.cq").first != nil
      president = object_page.css("a.cq").first.next_element.text
      puts "\t President => " + president
      object.president = president
    end     

    if object_page.css("a.wy").first != nil
       email = object_page.css("a.wy").first.text
       puts "\t Email => " + email
       object.email = email
    end

    if object_page.css("a.bp").first != nil
       website = object_page.css("a.bp").first.text
       puts "\t WebSite => " + website
       object.website = website
    end

  end

end