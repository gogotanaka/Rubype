require "sorry_yahoo_finance/version"
require "sorry_yahoo_finance/get"
module SorryYahooFinance
  class << self
    def GET(code, date=nil)
      SorryYahooFinance::GET.new(code, date)
    end
  end
end