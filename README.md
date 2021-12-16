<h1 align="center" style="font-weight: bold !important">⚡️📝 TLV Payment Metadata Parser for LND </h1>

<p align="center">
  Extract <a href="https://klabo.blog/lightning/bitcoin/2021/03/21/custom-data-in-lightning-payments.html">custom records</a>, such as <a href="https://twitter.com/HillebrandMax/status/1443519648125833218?s=20">boostagrams</a>, that may have been attached to lightning payments you received. For more information, see the <a href="https://github.com/lightningnetwork/lnd/releases/tag/v0.9.0-beta">release notes of LND's v0.9 release</a>.
</p>

<h3 align="center">
  <a href="#-examples-">Examples</a>
  <span> · </span>
  <a href="#-usage">Usage</a>
</h3>


## 🛫 Example

The `lntlvs.sh` script extracts custom TLV records from invoices.

The `helpers/split.sh` script can be used to filter the output of the `lntlvs.sh` script for TLV records containing a certain pattern and to split them to individual files.

For example, to get all boostagrams from the first 20,000 invoices on a BTCPay Server node and write them to files in a `custom_records/` directory, run:

```shell
./lntlvs.sh --lncliwrapper ../bitcoin-lncli.sh --maxinvoices 20000 --jsonlines | helpers/split.sh - custom_records/
```

## 📚 Usage

The `lntlvs.sh` script either prints JSON or outputs [JSON Lines](https://jsonlines.org) to a file.

### 1️⃣ JSON

For debugging and informational purposes, JSON output is supported. 

👉 Run:

``` shell
./lntlvs.sh --maxinvoices 2
```

🖨 This will print JSON like so:

``` json
[
  {
    "podcast": "Example Podcast",
    "episode": "#01 - First Episode of the Example Podcast",
    "action": "boost",
    "time": "00:01:08",
    "feedID": "<PodcastIndex.org Feed ID>",
    "app_name": "Breez",
    "value_msat_total": "10000",
    "message": "This is a boostagram!"
  },
  {
    "podcast": "Example Podcast",
    "episode": "#01 - First Episode of the Example Podcast",
    "action": "boost",
    "time": "00:01:09",
    "feedID": "<PodcastIndex.org Feed ID>",
    "app_name": "Breez",
    "value_msat_total": "10000",
    "message": "This is another boostagram!"
  }
]
```

### 2️⃣ Files

For persisting custom records, they can be written to a file, one JSON per line.

👉 Run:

``` shell
./lntlvs.sh --maxinvoices 2 --output records.json
```

🖨 This will write custom records to a file `records.json` like so:

```
{"podcast":"Example Podcast","episode":"#01 - First Episode of the Example Podcast","action":"boost","time":"00:01:08","feedID":"<PodcastIndex.org Feed ID>","app_name":"Breez","value_msat_total":"10000","message":"This is a boostagram!"}
{"podcast":"Example Podcast","episode":"#01 - First Episode of the Example Podcast","action":"boost","time":"00:01:09","feedID":"<PodcastIndex.org Feed ID>","app_name":"Breez","value_msat_total":"10000","message":"This is another boostagram!"}
```

## 📚 Usage

```
Usage:
  ./lntlvs.sh [OPTIONS]

Options:
  --network <value>       The network lnd is running on. (default: mainnet)
  --indexoffset <value>.  Query only for invoices after this offset. (default: 0)
  --maxinvoices <value>   The max number of invoices to query. (default: 1000)
  --tlvkey <value>        The TLV key to extract and decode. (default: 7629169)
  --lncliwrapper <value>  A wrapper script to use instead if lncli is not available. (default: ./bitcoin-lncli.sh)
  --jsonlines             If set, output will be formatted in JSON Lines format (one JSON per line). (default: 0)
  --output <value>        If set, custom records will be written to this file in JSON Lines format (one JSON per line).
```
