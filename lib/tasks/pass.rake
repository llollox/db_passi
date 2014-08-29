#encoding: utf-8

namespace :passes do

  require 'nokogiri'
  require "#{Rails.root}/lib/tasks/task_utilities"
  include TaskUtilities

  task :geocode => :environment do
    Pass.all.each_with_index do |pass,index|
      if pass.latitude.nil? || pass.longitude.nil?
        pass.geocode
        pass.save
        puts "[#{index}] " + pass.name + ": [" + pass.latitude.to_s + 
          ", " + pass.longitude.to_s + "]"
      end
    end
  end

  task :remove_useless_items => :environment do
    counter = 0
    Pass.all.each_with_index do |pass,index|
      if !pass.name.downcase.match(/^via|^bivio|^scollinamento/)
        m = Municipality.search(pass.name)
        if !m.blank?
          puts "[#{index}] #{pass.name} -> MUNICIPALITY : #{m.first.name}"
          pass.destroy
        else
          f = Fraction.search(pass.name)
          if !f.blank?
            puts "[#{index}] #{pass.name} -> FRACTION : #{f.first.name}" 
            pass.destroy
          else
            puts "[#{index}] #{pass.name} -> NON TROVATO!"
            counter = counter + 1
          end
        end
      else
        pass.destroy
      end
    end
    puts "Unfounded: #{counter}"
  end

  task :set_name_encoded => :environment do
    Pass.all.each_with_index do |pass, index|
      pass.name_encoded = encode(pass.name)
      pass.save
      puts "[#{index}] " + pass.name
    end
  end

  desc "Fetch some information about this region"
  task :fetch => :environment do

    ROOT_URL="http://www.tornanti.it/html/"

    italy = openUrl(ROOT_URL + "mappa.htm").css("map area")
    
    italy[6..-1].each do |region_link|
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
            table_page = openUrl(ROOT_URL + url + "?pag=" + page_index.to_s)
            parse_table(table_page.css("table").first, region)
          }
        else
          parse_table(region_page.css("table").first, region)
        end

      end
    end

  end

end

def findFractionByMunicipalityName fractions, name
  return fractions if fractions.class.name == "Fraction"
  fractions.each do |fraction|
    return fraction if encode(fraction.municipality.name) == encode(name)
  end
end

def checkRegion element, region
  if element.class.name.to_s == "Municipality"
    return element.province.region.id == region.id
  elsif element.class.name.to_s == "Fraction"
    return element.municipality.province.region.id == region.id
  end
end

def findElementsByRegion class_name, locality, region
  result = class_name.capitalize.constantize.search(locality)
  if result.class.name.to_s == "Array"
    list = []
    result.each do |element|
      list << element if checkRegion(element, region)
    end
    return list.first if list.size == 1
    return list
  
  else 
    return result if checkRegion(result, region)
  
  end
end

def parse_name name
  name = name.split(" - ")[0]
  if name.match(",")
    name = name.split(",")
    return name[1] + " " + name[0]
  else
    return name
  end
end

def addLocality locality, pass
  if !already_saved?(pass, locality)
    loc = Locality.new
    if locality.class.name.to_s == "Municipality"
      loc.municipality_id = locality.id
      puts "\t\t\t municipality => " + locality.name
    else
      loc.fraction_id = locality.id
      loc.municipality_id = locality.municipality.id
      puts "\t\t\t fraction => " + locality.name
      puts "\t\t\t municipality => " + locality.municipality.name
    end
    pass.localities << loc
  end
end

def fix_pass_name name, region
  return "Passo del Foscagno" if name == "Passo di Foscagno" && region.name == "Lombardia"
  return "Passo dell'Eira" if name == "Passo d' Eira" && region.name == "Lombardia"
  return "Muro di Sormano" if name == "Colma di Sormano" && region.name == "Lombardia"
  return "Rifugio CAO Brunate" if name == "Rifugio CAO" && region.name == "Lombardia"
  return "Sant'Alberto di Butrio" if name == "Sant'Alberto di Buttrio" && region.name == "Lombardia"

  return "Rifugio Barbara Lowrie" if name == "Barbara Lowrie" && region.name == "Piemonte"
  return "Rucas" if name == "Ruccas" && region.name == "Piemonte"
  return "Campiglia Soana" if name == "Campiglia" && region.name == "Piemonte"
  return "Frassinetto" if name == "Frassineto" && region.name == "Piemonte"
  return "Colle del Mortè" if name == "Colle di Mortè" && region.name == "Piemonte"
  return "Monte San Salvatore" if name == "San Salvatore" && region.name == "Piemonte"
  return "Alto Vergante" if name == "Colazza" && region.name == "Piemonte"

  return "Passo Oclini" if name == "Passo Occlini" && region.name == "Trentino-Alto Adige"
  
  return "Malga San Giorgio" if name == "San Giorgio" && region.name == "Veneto"
  return "Le Ej" if name == "Le" && region.name == "Veneto"
  return "Pian di Castagnè" if name == "Castagnè" && region.name == "Veneto"
  return "Passo delle Fittanze della Sega" if name == "Passo Fittanze della Sega" && region.name == "Veneto"
  return "Monte Tomba" if name == "Passo del Tomba" && region.name == "Veneto"

  return "Passo di Crocedomini" if name == "Passo di Croce" && region.name == "Toscana"
  return "Santuario della Madonna del Monte" if name == "Madonna del Monte" && region.name == "Toscana"

  return name
end

def fix_locality name, region
  return "Val Brembilla" if name == "Brembilla" && region.name == "Lombardia"
  return "Trepalle" if name == "Ponte del Rezz" && region.name == "Lombardia"
  return "Val Masino" if name == "Masino" && region.name == "Lombardia"
  return "Bienno" if name == "Ponte Prada" && region.name == "Lombardia" 
  return "Casanova di Destra" if name == "Casanova Staffora" && region.name == "Lombardia" 
  return "Capizzone" if name == "Medega" && region.name == "Lombardia" 
  return "Ponte Seghe" if name == "Ponte di Briolta" && region.name == "Lombardia" 
  return "Piano Porlezza" if name == "Piano di Porlezza" && region.name == "Lombardia"
  return "Sant'Omobono Terme" if name == "San Omobono" && region.name == "Lombardia"
  return "Monticello Brianza" if name == "Torrevilla" && region.name == "Lombardia"
  return "Piano" if name == "Brissago Piano" && region.name == "Lombardia"

  return "Pont Canavese" if name == "Pont" && region.name == "Piemonte"
  return "Orta San Giulio" if name == "Orta" && region.name == "Piemonte"
  return "Chiusa di Pesio" if name == "Chiusa Pesio" && region.name == "Piemonte"
  return "Bagnolo Piemonte" if name == "Bagnolo" && region.name == "Piemonte"
  return "Villanova Mondovì" if name == "Villanova" && region.name == "Piemonte"
  return "Pradleves" if name == "Pradlèves-Demonte-Ponte Marmora" && region.name == "Piemonte"
  return "Perosa Argentina" if name == "Perosa Argentina-Cesana-Oulx" && region.name == "Piemonte"
  return "Varzo" if name == "Varzo-Domodossola" && region.name == "Piemonte"
  return "Lanzo Torinese" if name == "Lanzo" && region.name == "Piemonte"
  return "Ponte di Bibiana" if name == "Ponte Bibiana" && region.name == "Piemonte"
  return "Varallo" if name == "Varallo Sesia" && region.name == "Piemonte"
  return "Occhieppo Inferiore" if name == "Ochieppo Inferiore" && region.name == "Piemonte"
  return "Premosello-Chiovenda" if name == "Premosello" && region.name == "Piemonte"
  return "Villar Perosa" if name == "Villa Perosa" && region.name == "Piemonte"
  return "Alzo" if name == "Alzo di Pella" || name == "Pella-Alzo" && region.name == "Piemonte"
  return "Borgofranco d'Ivrea" if name == "Borgofranco" && region.name == "Piemonte"
  return "Superga" if name == "Torino P.G.Modena" && region.name == "Piemonte"

  return "Chiusavecchia" if name == "Chiusavecchi" && region.name == "Liguria"
  return "Borzonasca" if name == "Borzonsasca" && region.name == "Liguria"
  return "Vara Superiore" if name == "Vara" && region.name == "Liguria"
  return "Albisola Superiore" if name == "Albisola" && region.name == "Liguria"
  return "Molini" if name == "Molini di Prelà" && region.name == "Liguria"  

  return "Prato allo Stelvio" if name == "Prato" || name == "Prato Stelvio" && region.name == "Trentino-Alto Adige"
  return "Castello-Molina di Fiemme" if name == "Molina di Fiemme" && region.name == "Trentino-Alto Adige"
  return "Funes" if name == "Val di Funes" && region.name == "Trentino-Alto Adige"
  return "Rio di Pusteria" if name == "Rio Pusteria" && region.name == "Trentino-Alto Adige"
  return "Appiano sulla strada del vino" if name == "Appiano" && region.name == "Trentino-Alto Adige"
  return "Varignano" if name == "Varignano di Arco" || name == "Varigano di Arco" && region.name == "Trentino-Alto Adige"
  return "Tione di Trento" if name == "Tione" && region.name == "Trentino-Alto Adige"

  return "Cortina d'Ampezzo" if name == "Cortina" && region.name == "Veneto"
  return "Cencenighe Agordino" if name == "Cencenighe" && region.name == "Veneto"
  return "Mezzane di Sotto" if name == "Mezzane" && region.name == "Veneto"
  return "Isola Vicentina" if name == "Isola" && region.name == "Veneto" 
  return "Saviner di Laste" if name == "Saviner" || name == "Saviner di Lastè" && region.name == "Veneto"
  return "Santo Stefano di Cadore" if name == "S. Stefano" && region.name == "Veneto"
  return "Recoaro Terme" if name == "Recoaro" && region.name == "Veneto"  
  return "Puos D'alpago" if name == "Puos" && region.name == "Veneto"
  return "Brenzone sul Garda" if name == "Brenzone" && region.name == "Veneto" 
  return "Cornei" if name == "Cornei d' Alpago" && region.name == "Veneto" 
  return "Bosco Chiesanuova" if name == "Boscochiesanuova" && region.name == "Veneto"
  return "Ponte Oltra" if name == "Ponte d'Oltra" && region.name == "Veneto"
  return "Recoaro Terme" if name == "Recoaro" && region.name == "Veneto"
  return "Piovene Rocchette" if name == "Piovene" && region.name == "Veneto"  
  return "Volpago del Montello" if name == "Volpago" && region.name == "Veneto"  

  return "Prè Saint Didier" if name == "Prè St. Didier" && region.name == "Valle d'Aosta"
  return "Châtillon" if name == "Chatillon" && region.name == "Valle d'Aosta"
  return "Champorcher" if name == "Valle di Champorcher" || name == "Val di Champorcher" && region.name == "Valle d'Aosta"  

  return "Castelnuovo di Garfagnana" if name == "Castelnuovo" || name == "Castelnuovo Garfagnana" && region.name == "Toscana"
  return "Cervara di Roma" if name == "Cervara" && region.name == "Lazio"
  return name
end

def fix_region name, region
  return Region.search("Veneto") if name == "Pian di Castagnè" || name == "Danta di Cadore"
  return Region.search("Emilia-Romagna") if name == "Monte di Lesima" || name == "Passo della Scaparina"
  return Region.search("Lombardia") if name == "Passo di Capovalle"
  return region
end

def already_saved? pass, locality
  
  pass.localities.each do |loc|
    if locality.class.name.to_s == "Municipality"
      return true if loc.municipality_id == locality.id
    elsif locality.class.name.to_s == "Fraction"
      return true if loc.fraction_id == locality.id
    end
  end

  return false
end

def addLocalityManually fractions, pass, locality, region
  case [pass.name, locality]

    # manually fixes LOMBARDIA
    when ["Passo del Vivione", "Forno Allione"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Berzo Demo"), pass)
    when ["Passo dell'Eira", "San Antonio"] then 
      addLocality(findElementsByRegion("Fraction","Trepalle",region), pass)
    when ["Muro di Sormano", "Maglio"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Asso"), pass)
    when ["Vedello", "Busteggia"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Piateda"), pass)
    when ["Alfaedo", "Selvetta"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Forcola"), pass)
    when ["Sant'Alberto di Butrio", "Molino del Conte"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Ponte Nizza"), pass)
    when ["Forcella di Berbenno", "Ponte Giurino"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Berbenno"), pass)
    when ["Lissolo", "Monticello"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Santa Maria Hoé"), pass)
    when ["Castello", "Albogasio"] then 
      addLocality(fractions.first, pass) # is Albogasio fraction of Valsolda
    when ["Colle di Zambla Alta", "Fonte Bracca"] then 
      addLocality(findElementsByRegion("Municipality","Serina",region), pass)
    when ["Passo del Carmine", "Molino Cocchi"] then 
      addLocality(findElementsByRegion("Fraction","Pomino",region), pass)
      addLocality(findElementsByRegion("Municipality","Montalto Pavese",region), pass)
      addLocality(findElementsByRegion("Municipality","Romagnese",region), pass)
      addLocality(findElementsByRegion("Fraction","Bivio Carmine",region), pass) 
    when ["Villaggio Olandese", "Piano"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Brissago-Valtravaglia"), pass)
    when ["Ponna Superiore", "Ponte sul Livone"] then 
      addLocality(findElementsByRegion("Municipality","Laino",region), pass)
    
    # manually fixes PIEMONTE
    when ["Rifugio Barbara Lowrie", "Rifugio"] then 
      addLocality(findElementsByRegion("Municipality","Bobbio Pellice",region), pass)
    when ["Colle della Lombarda", "Pratolungo"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Vinadio"), pass)
    when ["Santuario di Sant'Anna", "Pratolungo"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Vinadio"), pass)
    when ["Certosa Monte Bracco", "San Martino"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Barge"), pass)
    when ["Chesio", "Prelo"] then 
      addLocality(findElementsByRegion("Municipality","Loreglia",region), pass)
    when ["Laghetti di Nonio", "Oira"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Nonio"), pass)
    when ["Lago di Malciaussia", "Lanzo Torinese"] then 
      addLocality(findElementsByRegion("Fraction","Malciaussia",region), pass)
    when ["Indiritti", "Ponte Rabbioso"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Ghigo"), "Prali"), pass)
    when ["Colletto la Breccia", "Borgosesia-Zuccaro"] then 
      addLocality(findElementsByRegion("Municipality","Borgosesia",region), pass)
      addLocality(findElementsByRegion("Fraction","Zuccaro",region), pass)
    when ["Basilica di Superga", "Superga"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Torino"), pass)
    when ["Armeno", "Orta-Miasino"] then 
      addLocality(findElementsByRegion("Municipality","Orta San Giulio",region), pass)
      addLocality(findElementsByRegion("Municipality","Miasino",region), pass)
    when ["Alto Vergante", "Alto Vergante"] then 
      addLocality(findElementsByRegion("Municipality","Colazza",region), pass)
    when ["Monte Camoscio", "SS 33"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Mottarone"), "Stresa"), pass)
      addLocality(findElementsByRegion("Municipality","Baveno",region), pass)

    # manually fixes LIGURIA
    when ["Passo Cento Croci", "Campi"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Campi"), "Albareto"), pass)
    when ["Passo del Termine", "Nozza"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Legnaro"), "Levanto"), pass)
    when ["Monte Fasce", "Borgoratti"] then 
      addLocality(Fraction.search("Premanico"), pass)
    when ["Passo del Termine", "Levanto Piè di Legnano"] then 
      nil
    when ["Torre del Mare", "Bossarino"] then 
      addLocality(findElementsByRegion("Municipality","Vado Ligure",region), pass)
    when ["Pantasina", "Molini"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Prelà"), pass)

    # manually fixes TRENTINO
    when ["Passo Pennes", "Riobianco"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Valle Aurina"), pass)
    when ["Passo Gardena", "Corvara"] then 
      addLocality(findElementsByRegion("Municipality","Corvara in Badia",region), pass)
    when ["Passo Oclini", "Molina"] then 
      addLocality(fractions.first, pass) # is Molina fraction of Castello-Molina di Fiemme
    when ["Passo Campolongo", "Corvara"] then 
      addLocality(findElementsByRegion("Municipality","Corvara in Badia",region), pass)
    when ["Alpe di Siusi", "Prato all'Isarco"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Fiè allo Sciliar"), pass)
    when ["Passo di Pinei", "Prato all'Isarco"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Fiè allo Sciliar"), pass)
    when ["Passo Nigra", "Prato all'Isarco"] then 
      addLocality(findElementsByRegion("Municipality","Tires",region), pass)
    when ["Collepietra", "Prato all'Isarco"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Fiè allo Sciliar"), pass)
    when ["Sella di Andalo", "Rocchetta"] then 
      addLocality(findElementsByRegion("Municipality","Fai della Paganella",region), pass)
    when ["Rifugio Prati di Kohl", "Pineta"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Laives"), pass)
    when ["Val Senales", "Compaccio"] then 
      addLocality(findElementsByRegion("Fraction","Alpe di Siusi",region), pass)
    when ["Passo di Prato Piazza", "Monguelfo-Vallone"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Vallone"), "Braies"), pass)
      addLocality(findElementsByRegion("Municipality","Monguelfo-Tesido",region), pass)
    when ["Passo delle Erbe", "Ponte Rü"] then 
      addLocality(findElementsByRegion("Fraction","Antermoia",region), pass)
    when ["Redagno", "La Copara"] then 
      addLocality(findElementsByRegion("Fraction","Redagno",region), pass)
    when ["Passo Palade", "Lana di Sopra"] then 
      addLocality(findElementsByRegion("Municipality","Lana",region), pass)
    when ["Passo della Borcola", "Castello di Rovereto"] then 
      addLocality(findElementsByRegion("Municipality","Rovereto",region), pass)

    
    # manually fixes VENETO
    when ["Rifugio sorgenti del Piave", "Cima Sappada"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Sappada"), pass)
    when ["Passo Tre Croci", "Ca San Marco"] then 
      pass.name = "Rifugio Cà San Marco"
      addLocality(Municipality.search("Averara"), pass) 
    when ["Col Sant'Angelo", "Carbonin"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Carbonin"), "Dobbiaco"), pass)
    when ["Valico del Branchetto", "Stallavena"] then 
      addLocality(fractions.first, pass) # is Stallavena fraction of Stallavena
    when ["Malga San Giorgio", "Stallavena"] then 
      addLocality(fractions.first, pass) # is Stallavena fraction of Stallavena
    when ["Lusiana", "Laverda"] then 
      addLocality(fractions.first, pass) # is Laverda fraction of Lusiana
    when ["Monte Comun", "Stallavena"] then 
      addLocality(fractions.first, pass) # is Stallavena fraction of Stallavena
    when ["Fiamene", "Stallavena"] then 
      addLocality(fractions.first, pass) # is Stallavena fraction of Stallavena
    when ["Cerro", "Lugo"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Grezzana"), pass)
    when ["via della Vittoria Montello", "Montello"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Montebelluna"), pass)
    when ["Passo delle Fittanze della Sega", "Bellori"] then 
      addLocality(Municipality.search("Erbezzo"), pass)
    when ["Passo delle Fittanze della Sega", "Sdruzzina"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Sabbionara") , "Avio"), pass)
    when ["Cengio", "Campiello"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Tresche' Conca") , "Roana"), pass)
    when ["Prada Alta", "Castello di Brenzone"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Castello") , "Brenzone sul Garda"), pass)
    when ["Passo Xomo", "Valli"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Sant'Antonio") , "Valli del Pasubio"), pass)
    when ["Dosso Gervasio", "Bellori"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Corbiolo"), "Bosco Chiesanuova"), pass)
    when ["Fosse", "Bellori"] then 
      nil
    when ["Magrano", "Castagnè"] then
      nil
    when ["Caiò", "Pian di Castagnè"] then 
      nil
    when ["Angelo", "Piovene Rocchette"] then 
      pass.name = "Costo"
      addLocality(findFractionByMunicipalityName(Fraction.search("Chiesa dell'Angelo"), "Piovene Rocchette"), pass)
    when ["Monte Magrè", "Cà Trenta"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Ongaro"), "Recoaro Terme"), pass)
    when ["Salcedo", "Campodirondo"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Covolo"), "Lusiana"), pass)
    when ["Salcedo", "ponte Astico"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Ponte"), "Lusiana"), pass)


    # manually fixes TOSCANA
    when ["Passo delle Radici", "Castelnuovo"] then 
      addLocality(findElementsByRegion("Municipality","Castiglione di Garfagnana",region), pass)
    when ["Abetone", "La Lima"] then 
      addLocality(findElementsByRegion("Fraction","Boscolungo",region), pass)
    when ["Foce della Formica", "Poggio"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Camporgiano"), pass)
    when ["Monte Ferchia", "Piano di Coreglia"] then 
      addLocality(fractions.first, pass) # is Piano di Coreglia fraction of Coreglia Antelminelli
    when ["Passo del Cipollaio", "Ruosina"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Seravezza"), pass)
    when ["Valico di Collesino", "Tavernelle"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Montalcino"), pass)
    when ["Monte Carnevale", "Palazzuolo"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Tavarnelle Val di Pesa"), pass)
    when ["Monte Morello", "Colonnata"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Sesto Fiorentino"), pass)
    when ["Foce il Cuccù", "Borghetto"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Fosdinovo"), pass)
    when ["Pasquilio", "Capannelle"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Castelnuovo di Garfagnana"), pass)
    when ["Monte Amiata", "La Biserda"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Rifugio Cantore"), "Abbadia San Salvatore"), pass)
    when ["Monte Amiata", "Ponte di Riga"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Casa Lichio"), "Seggiano"), pass)
    when ["Campo Cecina", "Molicciara"] then 
      addLocality(findElementsByRegion("Municipality","Fosdinovo",region), pass)
    when ["Passo del Cirone", "Bosco di Corniglio"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Bosco"), "Corniglio"), pass)
    when ["Colle Uccelliera", "Molicciara"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Molicciara"), "Castelnuovo Magra"), pass)
    when ["Rifugio Casentini", "Imbocco SP 56 \"Valfegana\""] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Val Fegana"), "Bagni di Lucca"), pass)
    when ["Passo di Crocedomini", "Ruosina"] then 
      addLocality(Municipality.search("Breno"), pass)
    when ["Passo del Vestito", "Molino del Riccio"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Isola Santa"), "Careggine"), pass)
    when ["Santuario della Madonna del Monte", "Case Baldini"] then 
      addLocality(Municipality.search("Marciana"), pass)
    when ["Passo del Cipollaio", "Molino del Riccio"] then 
      nil
    when ["Castell'Azzara", "Proceno"] then 
      addLocality(Municipality.search("Castell'Azzara"), pass)
    when ["Volterra", "Saline di Volterra"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Saline"), "Volterra"), pass)
    when ["Regnano", "Ponte Tabiano"] then 
      addLocality(findFractionByMunicipalityName(Fraction.search("Regnano"), "Casola in Lunigiana"), pass)
    when ["Guardistallo", "Quadri Tramerini"] then 
      addLocality(Municipality.search("Guardistallo"), pass)
    when ["Guardistallo", "Casa Giusti"] then 
      nil

      

    # manually fixes EMILIA ROMAGNA
    when ["Passo della Cisa", "Ghiare"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Berceto"), pass)
    when ["Castello di Carpineti", "Colombaia"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Carpineti"), pass)
    when ["Settefonti", "Mercatale"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Ozzano dell'Emilia"), pass)
    when ["Passo della Sella", "Altipiani di Arcinazzo"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Piglio"), pass)
    when ["Rocca di Mezzo", "Madonna della Pace"] then 
      addLocality(findFractionByMunicipalityName(fractions, "Agosta"), pass)
    else 
      binding.pry 
  end 
end

def parse_table table, region

  excluded_passes = ["Sella di Sharter","Rifugio Prati di - Schneiderwiesn Hütte Kohl",
      "Tires", "Sella Ciampigotto", "Cima Sappada", "Telegrafo", "via Marostica Rubbio",
      "via Mori Rubbio", "Faedo", "Maso di Quinzano", "via Medaglie d'Oro Montello",
      "via S.Martino Montello", "via E. Porcu  Montello", "San Fidenzio",
      "Maresca 2000","Pasquilio - Foce del Termo", "Farneta", "Poggio Ferrari", "Monte Albano",
      "Gorga","Acquapendente","Loreglia", "Sistina", "Colle San Giovanni", "Roverè 1000","Passo Santa Lucia",
      "Boscochiesanuova","Cona","Roverè","San Mauro di Saline","San Rocco","Caiò","Cardiologo","Cave Cervaiole",
      "Poggiol Verde","Ca' Marastoni","Colle della Spolverina","Tabaccaia","Pozzatelli"]

  table.css("tr")[1..-1].each_with_index do |pass_info, index|
    
    name = parse_name(pass_info.css("td").first.text).strip
    name = fix_pass_name(name, fix_region(name,region))

    altitude = pass_info.css("td")[1].text.gsub(".","")
    
    locality = pass_info.css("td").last.text.split(",")[0]
    locality = fix_locality(locality, fix_region(name,region))

    next if excluded_passes.include?(name)

    pass = extractItem("Pass", name)
    pass.name = name
    pass.altitude = altitude
    
    puts "\t\t" + name + " (" + altitude.to_s + ")"

    locality_regexp = /sud|nord|est|ovest|^da|^bivio|^pedaggio|^iniziosalita$|cavalcavia|^sp|^ss|scollinamento|^via|^versante|^piazza|^soloscalata$/
    pass_regexp = /^bivio|^pedaggio|^inizio salita$|cavalcavia|^sp|^ss|scollinamento|^via|^versante|^piazza/

    if !encode(locality).match(locality_regexp) && !encode(pass.name).match(pass_regexp)
      
      municipality = findElementsByRegion("Municipality",locality,fix_region(name,region))
      if municipality.nil?
        fraction = findElementsByRegion("Fraction",locality,fix_region(name,region))
        if !fraction.nil? && fraction.class.name == "Fraction"
          addLocality(fraction, pass)
        else
          addLocalityManually(fraction, pass, locality, fix_region(name,region))
        end
      else
        addLocality(municipality, pass)
      end
      
    else
      puts "\t\t\t Unrecognizable string!"
    end
    
    
    pass.save
    
    
    puts "\n"
  end

end