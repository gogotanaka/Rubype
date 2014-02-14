require 'open-uri'
require 'nokogiri'
module Converter
  def do(url)
    begin
      html = open(url).read
    rescue URI::InvalidURIError
      url = URI.encode(url)
      html = open(url, "Accept-Encoding" => "utf-8")
    rescue Zlib::DataError
      html = open(url, "Accept-Encoding" => "utf-8")
    rescue OpenURI::HTTPError => ex
      raise ex
    rescue Errno::ENOENT => ex
      raise ex
    end
    doc = Nokogiri::HTML(html, url)
  end
  module_function :do
end