mpex-csv-parser
===============

The UX on mpex.co is terrible, here's a script that converts the data into a readable csv

Once the MPEX class has been loaded, the following will create a "mpex.csv" file in your working directory.
```ruby
m = MPEX.new
m.to_csv
```