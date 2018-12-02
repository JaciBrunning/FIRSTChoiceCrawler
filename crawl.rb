BASEURL = "https://www.firstchoicebyandymark.com"
URL = "#{BASEURL}/everything"

require 'nokogiri'
require 'open-uri'

@links = []

puts "Loading Homepage"
homepage = Nokogiri::HTML(open(URL).read)
homepage.css("h2[class='product-title'] a").each { |product|
  @links << product['href']
  puts "\tFound: " + product.text
}

@products = []

puts
puts "Crawling..."
@links.each do |prod_href|
  puts " -> #{prod_href}"
  url = "#{BASEURL}#{prod_href}"
  product_html = Nokogiri::HTML(open(url).read)

  name = product_html.css("h1[itemprop='name']").text.strip
  fcsku = product_html.css("span[itemprop='sku']").text.strip

  qty_stock = product_html.css("div[class='stock onhand'] span[class='value']").text.strip.to_i
  qty_hold = product_html.css("div[class='stock onhold'] span[class='value']").text.strip.to_i
  qty_avail = product_html.css("div[class='stock available'] span[class='value']").text.strip.to_i

  credits = product_html.css("span[itemprop='price']").text.strip.scan(/(\d+).*/).first.first.to_i
  
  @products << {
    name: name,
    sku: fcsku,
    qty_stocked: qty_stock,
    qty_hold: qty_hold,
    qty_avail: qty_avail,
    credits: credits,
    url: url
  }
end

@textbuf = []

def write line
  @textbuf << line
  puts line
end

write "Name,SKU,QtyStock,QtyHeld,QtyAvailable,Credits,URL"
@products.each do |p|
  write ["\"#{p[:name].gsub(/"/, '""')}\"", "\"#{p[:sku]}\"", p[:qty_stocked], p[:qty_hold], p[:qty_avail], p[:credits], p[:url]].join(',')
end

File.write("fc.csv", @textbuf.join("\n"))
