require 'all_stock_codes'
require 'converter'
require "sorry_yahoo_finance/version"
module SorryYahooFinance
  def get_from_code(code)
    if code.class == Fixnum && code.to_s.size == 4
      begin
        html = Converter.do("http://stocks.finance.yahoo.co.jp/stocks/detail/?code=#{code}")
        previousprice, opening, high, low, turnover, trading_volume, price_limit = html.css('div.innerDate dd').map{|x| x.css('strong').inner_text }
        margin_deal = html.css("div.ymuiDotLine div.yjMS dd.ymuiEditLink strong").map(&:text)
        {
          code:             code,
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
      rescue
        raise "code #{code} stock dont exist."
      end
    else
      raise "code #{code} must be a four-digit number."
    end
  end

  def get_from_codes(codes)
    if codes.class == Array
      codes.map{|code| get_from_code(code)}
    else
      raise "codes #{codes} must be a Array."
    end
  end

  def get_all
    get_from_codes(AllStockCodes::CODES)
  end

  module_function :get_from_code, :get_from_codes, :get_all
end