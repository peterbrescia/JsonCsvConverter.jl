module JsonCsvConverter

using JSON
using DataFrames

type Converter
    convert::Function
    _csv_to_json::Function
    _json_to_csv::Function
    _get_file_type::Function
    _extract_row_values::Function
    _resolve_options::Function

    function Converter()
        this = new()

        """
        Convert supplied JSON/CSV file to a CSV/JSON file. Returns TRUE if successful; FALSE otherwise.
        """
        this.convert = function (input_file::String, output_file::String; parse_nested_json=false)
            input_filetype = this._get_file_type(input_file)
            output_filetype = this._get_file_type(output_file)

            if input_filetype == "csv" && output_filetype == "json"
                return this._csv_to_json(input_file, output_file, parse_nested_json)
            elseif input_filetype == "json" && output_filetype == "csv"
                return this._json_to_csv(input_file, output_file)
            else
                println("File extensions of the input and output files must be either 'csv' or 'json', and must be different.")
                return false
            end
        end

        this._json_to_csv = function (input_file::String, output_file::String)
            if !isfile(input_file)
                println("Cannot find file $input_file")
                return false
            end

            data = JSON.parsefile(input_file; dicttype=Dict)

            if length(data) == 0
                println("No data was found in the JSON file")
                return false
            end

            df_data = Dict()
            for row in data
                headers = keys(row)
                for header in headers
                    if get(df_data, header, false) === false
                        df_data[header] = []
                    end

                    entity = row[header]
                    if !isa(entity, Number) && !isa(entity, String)
                        entity = JSON.json(entity)
                    end

                    push!(df_data[header], entity)
                end
            end

            writetable(output_file, DataFrame(df_data))

            true
        end

        this._csv_to_json = function (input_file::String, output_file::String, parse_nested_json::Bool)
            if !isfile(input_file)
                println("Cannot find file $input_file")
                return false
            end

            df = readtable(input_file)
            headers = names(df)

            data = []
            for row in eachrow(df)
                push!(data, this._extract_row_values(headers, row, parse_nested_json))
            end

            open(output_file, "w") do f
                write(f, JSON.json(data))
            end

            true
        end

        this._extract_row_values = function (headers::Array{Symbol,1}, row::DataFrames.DataFrameRow{DataFrames.DataFrame}, parse_nested_json::Bool)
            formatted_row = Dict()
            for header in headers
                entity = row[Symbol(header)]

                if entity === NA
                    entity = ""
                elseif parse_nested_json
                    try
                        parsed = JSON.parse(entity)
                        entity = parsed
                    catch e
                    end
                end

                formatted_row[header] = entity
            end

            formatted_row
        end

        this._get_file_type = function (filename::String)
            fragments = split(filename, ".")
            fragments[length(fragments)]
        end

        this._resolve_options = function (options::Dict{String,Bool})
            defaults = Dict(
                "parse_nested_json" => false,
            )

            for (key, value) in defaults
                if get(options, key, nothing) === nothing
                    options[key] = value
                end
            end

            options
        end

        this
    end

end

end
