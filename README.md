SorryYahooFinance README
=============

I'll be pulling the stock of information from Yahoo! Finance. I am sorry. Yahoo!

Update Info
--------
* 0.1.0 (2014-02-15)
  * I was in shape once.

Example
--------

I will pull the information of the stock by securities code.

```ruby:ex1.rb
SorryYahooFinance.get_from_code(3333)
=> {:code=>3333,
  :name=>"(株)あさひ",
  :market=>"東証1部",
  :industry=>"小売業",
  :price=>"1,308",
  :previousprice=>"1,321",
  :opening=>"1,326",
  :high=>"1,331",
  :low=>"1,302",
  :turnover=>"95,700",
  :trading_volume=>"125,686",
  :price_limit=>"1,021～1,621",
  :margin_buying=>"174,700",
  :margin_selling=>"135,400",
  :d_margin_buying=>"-7,800",
  :d_margin_selling=>"-39,300",
  :margin_rate=>"1.29",
  :chart_image=>"http://gchart.yahoo.co.jp/f?s=3333.T"}
```

Multiple possible.

```ruby:ex2.rb
SorryYahooFinance.get_from_codes([3333,4355])
=> [{:code=>3333,
  :name=>"(株)あさひ",
  :market=>"東証1部",
  :industry=>"小売業",
  :price=>"1,308",
  :previousprice=>"1,321",
  :opening=>"1,326",
  :high=>"1,331",
  :low=>"1,302",
  :turnover=>"95,700",
  :trading_volume=>"125,686",
  :price_limit=>"1,021～1,621",
  :margin_buying=>"174,700",
  :margin_selling=>"135,400",
  :d_margin_buying=>"-7,800",
  :d_margin_selling=>"-39,300",
  :margin_rate=>"1.29",
  :chart_image=>"http://gchart.yahoo.co.jp/f?s=3333.T"},
 {:code=>4355,
  :name=>"ロングライフホールディング(株)",
  :market=>"東証JQS",
  :industry=>"サービス業",
  :price=>"307",
  :previousprice=>"313",
  :opening=>"312",
  :high=>"312",
  :low=>"303",
  :turnover=>"21,600",
  :trading_volume=>"6,674",
  ........（略)
```

All of the shares.

```ruby:ex3.rb
SorryYahooFinance.get_all
=> .....(略)
```


LICENSE
-------
(The MIT License)

Copyright (c) 2014 GoGoTanaka

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in
all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
