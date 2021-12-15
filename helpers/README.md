<h1 align="center" style="font-weight: bold !important">⚡️🗂 Boostagram Files</h1>

<p align="center">
  Filter and split JSON Lines output from `lntlvs.sh` into individual files. Only TLVs matching a specified filter will be put into files.
</p>

<h3 align="center">
  <a href="#-examples-">Examples</a>
  <span> · </span>
  <a href="#-usage">Usage</a>
</h3>

## 🛫 Examples

By default the script only outputs TLVs containing a `"message"`  of at least length one. This is intended to filter out Podcast Metadata TLVs (key `7629169`) which contain a boostagram message.

### 1️⃣ File Input

👉 Run:

``` shell
./split.sh custom_records.jsonl custom_records/
```

🖨 This will write files to `custom_records/`

``` shell
custom_records
├── custom_record_00000.json
├── custom_record_00001.json
(...)
└── custom_record_NNNNN.json
```

### 2️⃣ Standard Input

You can also pipe JSON Lines directly to the script by specifying `-` as input file:

👉 Run:

``` shell
./lntlvs.sh --jsonlines | ./split.sh - custom_records/
```

🖨 This will, again, write files to `custom_records/`

``` shell
custom_records
├── custom_record_00000.json
├── custom_record_00001.json
(...)
└── custom_record_NNNNN.json
```

## 📚 Usage

```
Usage:
    ./split.sh [OPTIONS] INPUT_FILE OUTPUT_DIR

    Writes each line in INPUT_FILE to a file in OUTPUT_DIR.
    The filenames will be 'custom_record_NNNNN.json' where 'NNNNN' is an incrementing number starting with '00000'.
    If INPUT_FILE is set to '-', the script will read from stdin.

Options:
    --filter <value>    Outputs only those lines matching the given filter (case-insensitive). (default: \"message\":\".+\")
