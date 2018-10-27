# Access to data

Due to Github's 100MB / file size limitations, we are sharing the data in a publicly accessible Dropbox folder. [On the following link](https://www.dropbox.com/sh/9vbam8rvr0v11os/AADvuMdePqAwYBNqsYM48ZoBa?dl=0), you can find the EU 28 members states' processed data. For each country, you'll find 3 files:

- address.csv
- transaction_amount.csv
- transaction.csv

The file `address.csv` contains any geolocal information associated with the given transaction - either the location of the project could be identified or the beneficiary's address, if no such information was available in the source.

The file `transaction_amount.csv` contains the distributed amounts of the original transaction, which can be joined together with the contents of the `address.csv` file with the help of the `address_id` field.

The file `transaction.csv` contains information associated with the original transaction. Here we also annotate the level of geolocation that could be traced on the original source file (`geolocation_in_source` field).

