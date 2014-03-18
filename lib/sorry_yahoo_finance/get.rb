require 'all_stock_codes'
require 'converter'
require 'hash_accessor'

module SorryYahooFinance
  class Hash
    def map_to_hash &block
      ret = {}
      each { |k,v| ret[k] = block.call(k,v) }
      ret
    end
  end
  class GET
    extend HashAccessor
    hash_accessor :values, :code, :name, :market, :industry, :price, :previousprice, :opening, :high, :low, :turnover, :trading_volume, :price_limit, :margin_buying, :margin_selling, :d_margin_buying, :d_margin_selling, :margin_rate, :chart_image
    class << self
      def get_infos(url)
        html = Converter.do(url)
        previousprice, opening, high, low, turnover, trading_volume, price_limit = html.css('div.innerDate dd').map{|x| x.css('strong').inner_text }
        margin_deal = html.css("div.ymuiDotLine div.yjMS dd.ymuiEditLink strong").map(&:text)
        {
          code:             html.css("div#divAddPortfolio + dl dt").text,
          name:             html.css('table.stocksTable th.symbol h1').inner_text,
          market:           html.css('div.stocksDtlWp dd')[0].content,
          industry:         html.css("div.stocksDtl dd.category a").text,
          price:            html.css('table.stocksTable td.stoksPrice')[1].content,
          previousprice:    previousprice,
          opening:          opening,
          high:             high,
          low:              low,
          turnover:         turnover,
          trading_volume:   trading_volume,
          price_limit:      price_limit,
          margin_buying:    margin_deal[0],
          margin_selling:   margin_deal[3],
          d_margin_buying:  margin_deal[1],
          d_margin_selling: margin_deal[4],
          margin_rate:      margin_deal[2],
          chart_image:      html.css("div.styleChart img")[0][:src],
        }
      end

      def get_infos_with_date(url)
        html = Converter.do(url)
        tds = html.xpath("(//div[@id='main']//table)[2]//td")
        opening, high, low, finish, turnover = tds[1..5].map(&:text)
        {
          code:     html.css("div#divAddPortfolio + dl dt").text,
          name:     html.css('table.stocksTable th.symbol h1').inner_text,
          market:   html.css('div.stocksDtlWp dd')[0].content,
          industry: html.css("div.stocksDtl dd.category a").text,
          opening:  opening,
          high:     high,
          low:      low,
          finish:   finish
        }
      end

      def get_by_codes(codes)
        if codes.class == Array
          codes.map{|code| self.new(code)}
        else
          raise "codes #{codes} must be a Array."
        end
      end

      def get_all
        get_by_codes(AllStockCodes::CODES)
      end
    end

    # 急場の時はアラート出したい
    def initialize(code, date=nil)
      if code.class == Fixnum && code.to_s.size == 4
        begin
          @values = if date
            year, month, day = date.strftime("%Y,%m,%d").split(",")
            month.delete!("0")
            url = "http://info.finance.yahoo.co.jp/history/?code=#{code}.T&sy=#{year}&sm=#{month}&sd=#{day}&ey=#{year}&em=#{month}&ed=#{day}&tm=d"
            self.class.get_infos_with_date(url)
          else
            self.class.get_infos("http://stocks.finance.yahoo.co.jp/stocks/detail/?code=#{code}")
          end
        rescue => ex
          raise "code #{code} stock dont exist. #{ex}"
        end
      else
        raise "code #{code} must be a four-digit number."
      end
    end

    def values
      @values
    end

    def to_range
      # str is like 183〜201
      price_limit = @values[:price_limit]
      price_limit.delete!(",")
      price_limit =~ /(\d+)～(\d+)/
      @values[:price_limit] = Range.new($1.to_i,$2.to_i)
    end

    def formalize_values
      int_keys = [
        :code,
        :price,
        :previousprice,
        :opening,
        :high,
        :low,
        :turnover,
        :trading_volume,
        :margin_buying,
        :margin_selling,
        :d_margin_buying,
        :d_margin_selling,
        :finish
      ]
      @values = @values.map_to_hash do |k,v|
        if int_keys.include?(k) && v.class == String
          v.delete(",").to_i
        else
          v
        end
      end
      to_range
      @values[:margin_rate] = @values[:margin_rate].to_f
    end
  end
end
Stock = SorryYahooFinance
