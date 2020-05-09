# Default options
const defaultParams = Dict{Symbol,Any}(
    :storeresults => false,
    :chunk_defaults => Dict{Symbol,Any}(
        :echo => true,
        :results => "markup",
        :hold => false,
        :fig => true,
        :include => true,
        :eval => true,
        :tangle => true,
        :cache => false,
        :fig_cap => nothing,
        # Size in inches
        :fig_width => 6,
        :fig_height => 4,
        :fig_path => "figures",
        :dpi => 96,
        :term => false,
        :display => false,
        :prompt => "\njulia> ",
        :label => nothing,
        :wrap => true,
        :line_width => 75,
        :engine => "julia",
        # :option_AbstractString=> "",
        # Defined in formats
        :fig_ext => nothing,
        :fig_pos => nothing,
        :fig_env => nothing,
        :out_width => nothing,
        :out_height => nothing,
        :skip => false,
    ),
)
# This one can be changed at runtime, initially a copy of defaults
const rcParams = deepcopy(defaultParams)

"""
    set_chunk_defaults(opts::Dict{Symbol, Any})

Set default options for code chunks, use [`get_chunk_defaults`](@ref) to see the current values.

E.g.: set default `dpi` to `200` and `fig_width` to `8`

```julia
julia> set_chunk_defaults(Dict{Symbol, Any}(:dpi => 200, fig_width => 8))
```
"""
function set_chunk_defaults(opts::Dict{Symbol,Any})
    merge!(rcParams[:chunk_defaults], opts)
    return nothing
end

"""
    get_chunk_defaults()

Get default options used for code chunks.
"""
function get_chunk_defaults()
    return (rcParams[:chunk_defaults])
end

"""
    restore_chunk_defaults()

Restore Weave.jl default chunk options.
"""
function restore_chunk_defaults()
    rcParams[:chunk_defaults] = defaultParams[:chunk_defaults]
    return nothing
end

"""Combine format specific and common options from document header"""
function combine_args(args, doctype)
    common = Dict()
    specific = Dict()
    for key in keys(args)
        if key in keys(Weave.formats)
            specific[key] = args[key]
        else
            common[key] = args[key]
        end
    end
    haskey(specific, doctype) && merge!(common, specific[doctype])
    common
end

"""
    header_args(doc::WeaveDoc)

Get weave arguments from document header.
"""
function header_args(
    doc::WeaveDoc,
    out_path,
    fig_ext,
    fig_path,
    cache_path,
    cache,
    throw_errors,
    template,
    highlight_theme,
    css,
    pandoc_options,
    latex_cmd,
)
    args = get(doc.header, WEAVE_OPTION_NAME, Dict())
    doctype = get(args, "doctype", doc.doctype)
    args = combine_args(args, doctype)
    informat = get(args, "informat", :auto)
    out_path = get(args, "out_path", out_path)
    out_path == ":pwd" && (out_path = :pwd)
    isa(out_path, Symbol) || (out_path = joinpath(dirname(doc.source), out_path))
    fig_path = get(args, "fig_path", fig_path)
    fig_ext = get(args, "fig_ext", fig_ext)
    cache_path = get(args, "cache_path", cache_path)
    cache = Symbol(get(args, "cache", cache))
    throw_errors = get(args, "throw_errors", throw_errors)
    template = get(args, "template", template)
    if template != nothing && !isa(template, Mustache.MustacheTokens) && !isempty(template)
        template = joinpath(dirname(doc.source), template)
    end
    highlight_theme = get(args, "highlight_theme", highlight_theme)
    css = get(args, "css", css)
    pandoc_options = get(args, "pandoc_options", pandoc_options)
    latex_cmd = get(args, "latex_cmd", latex_cmd)

    return (
        doctype,
        informat,
        out_path,
        args,
        fig_path,
        fig_ext,
        cache_path,
        cache,
        throw_errors,
        template,
        highlight_theme,
        css,
        pandoc_options,
        latex_cmd,
    )
end
