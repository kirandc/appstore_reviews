#!/usr/bin/env ruby

#
# appstore_reviews
#
#  Fetch iTunes App Store reviews for each application, across all country stores, with translation
#   -- app id, app name, reads rating, author, subject and review body
#

require 'rubygems'
require 'hpricot'
require 'httparty'
require 'csv'


############ First Script :  Get All ITunes App Store product ID and Name #############

#Product Categories
categories = [
  {:name => 'Books',:ios =>'ios-books', :id=> 'id6018'},
  {:name => 'Business', :ios => 'ios-business', :id => 'id6000'},
  {:name => 'Catalogs', :ios => 'ios-catalogs', :id => 'id6022'},
  {:name => 'Education', :ios => 'ios-education', :id => 'id6017'},
  {:name => 'Entertainment', :ios => 'ios-entertainment', :id => 'id6016'},
  {:name => 'Finamce', :ios => 'ios-finance', :id => 'id6015'},
  {:name => 'Food & Drink', :ios => 'ios-food-drink', :id => 'id6023'},
  {:name => 'Games', :ios => 'ios-games', :id => 'id6014'},
  {:name => 'Health & Fitness', :ios => 'ios-health-fitness', :id => 'id6013'},
  {:name => 'Lifestyle', :ios => 'ios-lifestyle', :id => 'id6012'},
  {:name => 'Medical', :ios => 'ios-medical', :id  => 'id6020'},
  {:name => 'Music', :ios => 'ios-music', :id => 'id6011'},
  {:name => 'Navigation', :ios => 'ios-navigation', :id  => 'id6010'},
  {:name => 'News', :ios => 'ios-news', :id => 'id6009'},
  {:name => 'Newsstand', :ios => 'ios-newsstand', :id => 'id6021'},
  {:name => 'Photo & Video', :ios => 'ios-photo-video', :id => 'id6008'},
  {:name => 'Productivity', :ios => 'ios-productivity', :id => 'id6007'},
  {:name => 'Reference', :ios => 'ios-reference', :id => 'id6006'},
  {:name => 'Networking', :ios => 'ios-social-networking', :id => 'id6005'},
  {:name => 'Sports', :ios => 'ios-sports', :id => 'id6004'},
  {:name => 'Travel', :ios => 'ios-travel', :id => 'id6003'},
  {:name => 'Utilities', :ios => 'ios-utilities', :id => 'id6002'},
  {:name => 'Weather', :ios => 'ios-weather', :id => 'id6001'}
]

#get itune product category wise
CSV.open("iTune_app_list.csv", "wb") do |csv|
  categories.each do |category|
    puts "Categoty - #{category[:name]}"
    #get product alphabate wise
    c = 0 
    ('A'..'Z').to_a.each do |alpha|
      puts "Alphabate - #{alpha}"
      page = 0
      while true
        puts "Page - #{page}"
        #response = HTTParty.get("http://itunes.apple.com/us/genre/#{category[:ios]}/#{category[:id]}?mt=8&letter=#{alpha}&page=#{page}")
        cmd = sprintf(%{curl -s --socks4a localhost:9050 } <<
                      %{'http://itunes.apple.com/us/genre/%s/%s?} <<
                      %{mt=8&letter=%s&page=%d' | xmllint --format --recover - 2>/dev/null},
                        category[:ios],
                        category[:id],
                        alpha,
                        page)

        response = `#{cmd}`

        doc = Hpricot.parse(response)
        list = doc.search("//div[@class='grid3-column']")
        data_count = list.search("//a").size
        list.search("//a").each do |a|
          begin
            c += 1
            csv << [a.attributes['href'].match(/id([0-9]+)/)[1], a.inner_html, category[:name]]
          rescue => err
            p err
          end
        end #end seach data
        # if data_count less than 10 that means it's last page
        if data_count < 10
          break 
        end
        page += 1
      end #end page
    end #end alphabate
  end # end csv
end # end category
########## Second Script : Get reviews #############

# MODIFY YOUR NATIVE LANGUAGE
NATIVE_LANGUAGE = 'en'

# MODIFY THIS HASH WITH YOUR APP SET (grab the itunes store urls & pull the id params)
#software = {
  # http://phobos.apple.com/WebObjects/MZStore.woa/wa/viewSoftware?id=289923007&mt=8
 # 'iMeetingApp' => 481142632, 'Domain Scout' => 289923007
#}

stores = [
  { :name => 'United States',        :id => 143441, :language => 'en'    },
  { :name => 'Argentina',            :id => 143505, :language => 'es'    },
  { :name => 'Australia',            :id => 143460, :language => 'en'    },
  { :name => 'Belgium',              :id => 143446, :language => 'nl'    },
  { :name => 'Brazil',               :id => 143503, :language => 'pt'    },
  { :name => 'Canada',               :id => 143455, :language => 'en'    },
  { :name => 'Chile',                :id => 143483, :language => 'es'    },
  { :name => 'China',                :id => 143465, :language => 'zh-CN' },
  { :name => 'Colombia',             :id => 143501, :language => 'es'    },
  { :name => 'Costa Rica',           :id => 143495, :language => 'es'    },
  { :name => 'Croatia',              :id => 143494, :language => 'hr'    },
  { :name => 'Czech Republic',       :id => 143489, :language => 'cs'    },
  { :name => 'Denmark',              :id => 143458, :language => 'da'    },
  { :name => 'Deutschland',          :id => 143443, :language => 'de'    },
  { :name => 'El Salvador',          :id => 143506, :language => 'es'    },
  { :name => 'Espana',               :id => 143454, :language => 'es'    },
  { :name => 'Finland',              :id => 143447, :language => 'fi'    },
  { :name => 'France',               :id => 143442, :language => 'fr'    },
  { :name => 'Greece',               :id => 143448, :language => 'el'    },
  { :name => 'Guatemala',            :id => 143504, :language => 'es'    },
  { :name => 'Hong Kong',            :id => 143463, :language => 'zh-TW' },
  { :name => 'Hungary',              :id => 143482, :language => 'hu'    },
  { :name => 'India',                :id => 143467, :language => ''      },
  { :name => 'Indonesia',            :id => 143476, :language => ''      },
  { :name => 'Ireland',              :id => 143449, :language => ''      },
  { :name => 'Israel',               :id => 143491, :language => ''      },
  { :name => 'Italia',               :id => 143450, :language => 'it'    },
  { :name => 'Korea',                :id => 143466, :language => 'ko'    },
  { :name => 'Kuwait',               :id => 143493, :language => 'ar'    },
  { :name => 'Lebanon',              :id => 143497, :language => 'ar'    },
  { :name => 'Luxembourg',           :id => 143451, :language => 'de'    },
  { :name => 'Malaysia',             :id => 143473, :language => ''      },
  { :name => 'Mexico',               :id => 143468, :language => 'es'    },
  { :name => 'Nederland',            :id => 143452, :language => 'nl'    },
  { :name => 'New Zealand',          :id => 143461, :language => 'en'    },
  { :name => 'Norway',               :id => 143457, :language => 'no'    },
  { :name => 'Osterreich',           :id => 143445, :language => 'de'    },
  { :name => 'Pakistan',             :id => 143477, :language => ''      },
  { :name => 'Panama',               :id => 143485, :language => 'es'    },
  { :name => 'Peru',                 :id => 143507, :language => 'es'    },
  { :name => 'Phillipines',          :id => 143474, :language => ''      },
  { :name => 'Poland',               :id => 143478, :language => 'pl'    },
  { :name => 'Portugal',             :id => 143453, :language => 'pt'    },
  { :name => 'Qatar',                :id => 143498, :language => 'ar'    },
  { :name => 'Romania',              :id => 143487, :language => 'ro'    },
  { :name => 'Russia',               :id => 143469, :language => 'ru'    },
  { :name => 'Saudi Arabia',         :id => 143479, :language => 'ar'    },
  { :name => 'Schweiz/Suisse',       :id => 143459, :language => 'auto'  },
  { :name => 'Singapore',            :id => 143464, :language => ''      },
  { :name => 'Slovakia',             :id => 143496, :language => ''      },
  { :name => 'Slovenia',             :id => 143499, :language => ''      },
  { :name => 'South Africa',         :id => 143472, :language => 'en'    },
  { :name => 'Sri Lanka',            :id => 143486, :language => ''      },
  { :name => 'Sweden',               :id => 143456, :language => 'sv'    },
  { :name => 'Taiwan',               :id => 143470, :language => 'zh-TW' },
  { :name => 'Thailand',             :id => 143475, :language => 'th'    },
  { :name => 'Turkey',               :id => 143480, :language => 'tr'    },
  { :name => 'United Arab Emirates', :id => 143481, :language => ''      },
  { :name => 'United Kingdom',       :id => 143444, :language => 'en'    },
  { :name => 'Venezuela',            :id => 143502, :language => 'es'    },
  { :name => 'Vietnam',              :id => 143471, :language => 'vi'    },
  { :name => 'Japan',                :id => 143462, :language => 'ja'    },

  # stores added April 1, 2009
  { :name => 'Dominican Republic',   :id => 143508, :language => 'es'    },
  { :name => 'Ecuador',              :id => 143509, :language => 'es'    },
  { :name => 'Egypt',                :id => 143516, :language => ''      },
  { :name => 'Estonia',              :id => 143518, :language => 'et'    },
  { :name => 'Honduras',             :id => 143510, :language => 'es'    },
  { :name => 'Jamaica',              :id => 143511, :language => ''      },
  { :name => 'Kazakhstan',           :id => 143517, :language => ''      },
  { :name => 'Latvia',               :id => 143519, :language => 'lv'    },
  { :name => 'Lithuania',            :id => 143520, :language => 'lt'    },
  { :name => 'Macau',                :id => 143515, :language => ''      },
  { :name => 'Malta',                :id => 143521, :language => 'mt'    },
  { :name => 'Moldova',              :id => 143523, :language => ''      },
  { :name => 'Nicaragua',            :id => 143512, :language => 'es'    },
  { :name => 'Paraguay',             :id => 143513, :language => 'es'    },
  { :name => 'Uruguay',              :id => 143514, :language => 'es'    },
]

DEBUG = false

TRANSLATE_URL = "http://ajax.googleapis.com/ajax/services/language/translate?"

def translate(opts)
  from = opts[:from] == 'auto' ? '' : opts[:from]  # replace 'auto' with blank per Translate API
  to   = opts[:to]

  result = HTTParty.get(TRANSLATE_URL, :query => { :v => '1.0', :langpair => "#{from}|#{to}", :q => opts[:text] })

  raise result['responseDetails'] if result['responseStatus'] != 200
  return result['responseData']['translatedText']
end

# return a rating/subject/author/body hash
def fetch_reviews(software_id, store)
  reviews = []
  
  cmd = sprintf(%{curl -s --socks4a localhost:9050 -A "iTunes/9.2 (Macintosh; U; Mac OS X 10.6" -H "X-Apple-Store-Front: %s-1" } <<
                %{'http://ax.phobos.apple.com.edgesuite.net/WebObjects/MZStore.woa/wa/viewContentsUserReviews?id=%s&} <<
                %{pageNumber=0&sortOrdering=1&type=Purple+Software' | xmllint --format --recover - 2>/dev/null},
                store[:id],
                software_id)

  rawxml = `#{cmd}`
  
  if defined?(DEBUG) && DEBUG == true
    open("appreview.#{software_id}.#{store[:id]}.xml", 'w') { |f| f.write(rawxml) }
  end
  
  doc = Hpricot.XML(rawxml)

  doc.search("Document > View > ScrollView > VBoxView > View > MatrixView > VBoxView:nth(0) > VBoxView > VBoxView").each do |e|
    review = {}
    
    strings = (e/:SetFontStyle)
    meta    = strings[2].inner_text.split(/\n/).map { |x| x.strip }

    # Note: Translate is sensitive to spaces around punctuation, so we make sure br's connote space.
    review[:rating]  = e.inner_html.match(/alt="(\d+) star(s?)"/)[1].to_i
    review[:author]  = meta[3]
    review[:version] = meta[7][/Version (.*)/, 1] unless meta[7].nil?
    review[:date]    = meta[10]
    review[:subject] = strings[0].inner_text.strip
    review[:body]    = strings[3].inner_html.gsub("<br />", "\n").strip
    
    if ! store[:language].empty? && store[:language] != NATIVE_LANGUAGE
      begin
        review[:subject] = translate( :from => store[:language], :to => NATIVE_LANGUAGE, :text => review[:subject] )
        review[:body]    = translate( :from => store[:language], :to => NATIVE_LANGUAGE, :text => review[:body] )
      rescue => e
        if DEBUG
          puts "** oops, cannot translate #{store[:name]}/#{store[:language]} => #{NATIVE_LANGUAGE}: #{e.message}"
        end
      end
    end
    
    reviews << review
  end

  reviews
end

# a simple command-line presentation
CSV.open("itune_app_reviews.csv", "wb") do |csv|
  csv << ['App ID', 'App Name', 'Category', 'Rating','Subject', 'Aauthor', 'Version','Date','Body']
  begin
    # Read csv file and get App ID and App Name
    CSV.foreach("iTune_app_list.csv") do |row|
      puts "== App: #{row[1]}"

      csv << ['','',"--------- App: #{row[1]} ------------------",'','','']
      stores.sort_by { |a| a[:name] }.each do |store|
        reviews = fetch_reviews(row[0], store)

        if reviews.any?
          csv << ['',"--------- Store: #{store[:name]} ------------------",'','','','']
          reviews.each_with_index do |review, index|
            csv << [row[0],row[1].to_s.force_encoding("UTF-8"), row[2], "#{review[:rating]} #{review[:rating] > 1 ? 'stars' : 'star'}", 
              review[:subject], review[:author], review[:version], review[:date], review[:body]]
          end
        end
      end
      csv << ['']
    end
  rescue => err
    puts err
  end
end
