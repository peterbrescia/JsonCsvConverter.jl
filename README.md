# JsonCsvConverter.jl
Utility library for converting JSON to CSV, and vice versa.

## Features
This module can convert JSON files to CSV, and vice versa. When converting from JSON to CSV, nestings are written as json-encoded strings in the output CSV. In order to get back to the original JSON file from a CSV, therefore, you should pass `parse_nested_json=true` to the `convert` function. See [Usage](#usage).

## Installation
Since this is an unregistered package, you can install it from the julia prompt as follows:
- over SSH (recommended):
```jl
if get(Pkg.installed(), "JsonCsvConverter", false) == false
    Pkg.clone("git@github.com:peterbrescia/JsonCsvConverter.jl")
end
```
- over HTTPS:
```jl
if get(Pkg.installed(), "JsonCsvConverter", false) == false
    Pkg.clone("https://github.com/peterbrescia/JsonCsvConverter.jl")
end
```

## Dependencies
Dependencies can be found in the `REQUIRE` file. Package dependencies should install automatically upon installing this module. Requires Julia v0.5.

## Usage
#### Convert CSV to JSON:
```jl
using JsonCsvConverter
c = JsonCsvConverter.Converter()
c.convert("in.csv", "out.json")
```

#### Convert JSON to CSV:
```jl
using JsonCsvConverter
c = JsonCsvConverter.Converter()
c.convert("in.json", "out.csv")
```

#### Options
- When parsing a CSV that contains JSON-encoded fields, you can pass `parse_nested_json=true` to decode these fields:
```jl
convert("in.csv", "out.json", parse_nested_json=true)
```
