SorryYahooFinance README
=============

Yahoo!Japanファイナンス（http://finance.yahoo.co.jp/）
から株の情報をひっぱてきます。ごめんなさい。Yahoo!


更新履歴
--------
* 0.1.0 (2014-02-15)
  * 一応形にした

例
--------
```ruby:heihe.rb
 SorryYahooFinance.get_from_codes([3333])
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
  :chart_image=>"http://gchart.yahoo.co.jp/f?s=3333.T"}]
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
