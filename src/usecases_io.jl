# I/O for usecases/UC-*/usecase.md (YAML frontmatter + directory discovery).
# Shared by test/catalogue.jl and docs/catalogue/build.jl — not re-exported.

using YAML

function usecases_root()
    return normpath(joinpath(@__DIR__, "..", "usecases"))
end

function usecase_directories()
    root = usecases_root()
    dirs = sort(filter(isdir, readdir(root; join=true)))
    return filter(d -> occursin(r"^UC-\d+", basename(d)), dirs)
end

function split_frontmatter(text::AbstractString)
    startswith(text, "---") || error("missing YAML frontmatter opener")
    rest = text[4:end]
    close_idx = findfirst(r"\n---\s*\n", rest)
    close_idx === nothing && error("missing YAML frontmatter closer")
    yaml = rest[1:prevind(rest, first(close_idx))]
    body = rest[nextind(rest, last(close_idx)):end]
    return yaml, body
end

function load_frontmatter(yaml::AbstractString)
    meta = YAML.load(yaml)
    meta isa AbstractDict || error("frontmatter must be a YAML mapping")
    return meta
end

function template_version_int(meta::AbstractDict)
    haskey(meta, "template_version") || return nothing
    tv = meta["template_version"]
    if tv isa Integer
        return Int(tv)
    elseif tv isa AbstractString
        return parse(Int, tv)
    end
    return nothing
end

function usecase_version_int(meta::AbstractDict)
    haskey(meta, "version") || return nothing
    v = meta["version"]
    if v isa Integer
        return Int(v)
    elseif v isa AbstractString
        return parse(Int, v)
    end
    return nothing
end

const USECASE_REF = r"^(UC-\d+)@(\d+)$"

function parse_usecase_ref(ref::AbstractString)
    m = match(USECASE_REF, ref)
    m === nothing && return nothing
    return (id=m.captures[1], version=parse(Int, m.captures[2]))
end

function usecase_ref(id::AbstractString, version::Int)
    return "$id@$version"
end

function load_usecase_meta(dir::AbstractString)
    usecase = joinpath(dir, "usecase.md")
    isfile(usecase) || return nothing
    text = read(usecase, String)
    yaml, _ = split_frontmatter(text)
    return load_frontmatter(yaml)
end
