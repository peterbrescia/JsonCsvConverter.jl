include("../src/JsonCsvConverter.jl")
using Base.Test

c = JsonCsvConverter.Converter()

function _output_file(filename::String)
    Base.source_dir()*"/output/$filename"
end

function _input_file(filename::String)
    Base.source_dir()*"/input/$filename"
end

function _expected_file(filename::String)
    Base.source_dir()*"/expected/$filename"
end

function set_up()
    files = [
        "out.csv",
        "out.json",
    ]

    for filename in files
        filepath = _output_file(filename)
        if isfile(filepath)
            rm(filepath)
        end
    end
end

function _test(
    input_filename::String,
    output_filename::String,
    expected_output_filename::String,
    parse_nested_json::Bool=false,
)
    set_up()
    input_filepath = _input_file(input_filename)
    output_filepath = _output_file(output_filename)
    expected_filepath = _expected_file(expected_output_filename)
    c.convert(input_filepath, output_filepath, parse_nested_json=parse_nested_json)
    @test readstring(output_filepath) == readstring(expected_filepath)
end

function _test_double(
    input_filename::String,
    first_output_filename::String,
    second_output_filename::String,
    parse_nested_json::Bool=false,
)
    set_up()
    input_filepath = _input_file(input_filename)
    first_output_filepath = _output_file(first_output_filename)
    second_output_filepath = _output_file(second_output_filename)

    c.convert(input_filepath, first_output_filepath, parse_nested_json=parse_nested_json)
    c.convert(first_output_filepath, second_output_filepath, parse_nested_json=parse_nested_json)

    @test readstring(second_output_filepath) == readstring(input_filepath)
end

function test_flat_json_to_csv()
    _test("flat.json", "out.csv", "flat_json_to_csv.csv")
end

function test_flat_quoted_csv_to_json()
    _test("flat_quoted.csv", "out.json", "flat_csv_to_json.json")
end

function test_flat_unquoted_csv_to_json()
    _test("flat_unquoted.csv", "out.json", "flat_csv_to_json.json")
end

function test_flat_json_to_csv_and_back()
    _test_double("flat.json", "out.csv", "out.json")
end

function test_flat_csv_to_json_and_back()
    _test_double("flat_quoted.csv", "out.json", "out.csv")
end

function test_nested_json_to_csv()
    _test("nested.json", "out.csv", "nested_json_to_csv.csv")
end

function test_nested_csv_to_nested_json()
    _test("nested.csv", "out.json", "nested_csv_to_json.json", true)
end

function test_nested_csv_to_flat_json()
end

function test_nested_json_to_csv_and_back()
    _test_double("nested.json", "out.csv", "out.json", true)
end

function test_nested_csv_to_json_and_back()
    _test_double("nested.csv", "out.json", "out.csv", true)
end

function test_na_handling()
    _test("flat_unquoted_nas.csv", "out.json", "na_handling.json")
end

test_flat_json_to_csv()
test_flat_quoted_csv_to_json()
test_flat_unquoted_csv_to_json()
test_flat_json_to_csv_and_back()
test_flat_csv_to_json_and_back()

test_nested_json_to_csv()
test_nested_csv_to_nested_json()
test_nested_csv_to_flat_json()
test_nested_json_to_csv_and_back()
test_nested_csv_to_json_and_back()

test_na_handling()
