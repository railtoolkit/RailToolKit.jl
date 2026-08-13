# Use-case catalogue validation (YAML frontmatter + section headings).

using YAML

const REQUIRED_FRONTMATTER = (
    :id,
    :title,
    :template_version,
    :version,
    :status,
    :owner,
    :created,
    :updated,
    :packages,
    :summary,
)

const LINEAGE_LIST_KEYS = ("supersedes", "merged_from")
const LINEAGE_SCALAR_KEYS = ("split_from", "superseded_by")
const RELATION_LIST_KEYS = ("related", "builds_on")
const USECASE_REF = r"^(UC-\d+)@(\d+)$"

const REQUIRED_SECTION_TITLES = (
    "Goal",
    "Scope",
    "Actors & systems",
    "Preconditions",
    "Main scenario",
    "Artifacts",
    "Expected outcomes",
    "Exceptions",
    "Worked example",
    "Verification",
    "Assumptions & limits",
    "Reproducibility",
    "Open questions",
    "References",
)

const ALLOWED_STATUS = Set(["draft", "active", "deprecated"])

struct UseCaseCheck
    case::String
    errors::Vector{String}
    warnings::Vector{String}
end

ok(check::UseCaseCheck) = isempty(check.errors)

function usecases_root()
    return joinpath(@__DIR__, "..", "usecases")
end

function template_versions_dir()
    return joinpath(usecases_root(), "template", "versions")
end

function current_template_version()
    versions_dir = template_versions_dir()
    isdir(versions_dir) || error("Missing template/versions/ under $(usecases_root())")
    current = 0
    for name in readdir(versions_dir)
        m = match(r"^v(\d+)\.md$", name)
        m === nothing && continue
        current = max(current, parse(Int, m.captures[1]))
    end
    current == 0 && error("No template/versions/vN.md snapshots found")
    return current
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

function section_headings(body::AbstractString)
    titles = String[]
    for line in split(body, '\n')
        m = match(r"^## (.+)$", line)
        m === nothing && continue
        push!(titles, strip(m.captures[1]))
    end
    return titles
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

function validate_lineage_frontmatter!(errors, warnings, meta::AbstractDict, id, version)
    haskey(meta, "lineage") || return
    lineage = meta["lineage"]
    if !(lineage isa AbstractDict)
        push!(errors, "`lineage` must be a YAML mapping")
        return
    end

    self_ref = id isa AbstractString && version isa Int ? usecase_ref(id, version) : nothing

    for key in LINEAGE_LIST_KEYS
        haskey(lineage, key) || continue
        val = lineage[key]
        val === nothing && continue
        if !(val isa AbstractVector)
            push!(errors, "lineage.$key must be a list of UC-NNN@M refs")
            continue
        end
        for item in val
            item isa AbstractString || begin
                push!(errors, "lineage.$key entries must be strings (UC-NNN@M)")
                continue
            end
            parse_usecase_ref(item) === nothing &&
                push!(errors, "invalid lineage ref `$item` in lineage.$key (expected UC-NNN@M)")
            self_ref !== nothing && item == self_ref &&
                push!(errors, "lineage.$key must not reference this case itself (`$item`)")
        end
    end

    for key in LINEAGE_SCALAR_KEYS
        haskey(lineage, key) || continue
        val = lineage[key]
        val === nothing && continue
        val isa AbstractString || begin
            push!(errors, "lineage.$key must be a UC-NNN@M ref or null")
            continue
        end
        parse_usecase_ref(val) === nothing &&
            push!(errors, "invalid lineage ref `$val` in lineage.$key (expected UC-NNN@M)")
        self_ref !== nothing && val == self_ref &&
            push!(errors, "lineage.$key must not reference this case itself (`$val`)")
    end
end

function validate_relation_frontmatter!(errors, warnings, meta::AbstractDict, id, version)
    self_ref = id isa AbstractString && version isa Int ? usecase_ref(id, version) : nothing

    for key in RELATION_LIST_KEYS
        haskey(meta, key) || continue
        val = meta[key]
        val === nothing && continue
        if !(val isa AbstractVector)
            push!(errors, "`$key` must be a list of UC-NNN@M refs")
            continue
        end
        for item in val
            item isa AbstractString || begin
                push!(errors, "$key entries must be strings (UC-NNN@M)")
                continue
            end
            parse_usecase_ref(item) === nothing &&
                push!(errors, "invalid ref `$item` in $key (expected UC-NNN@M)")
            self_ref !== nothing && item == self_ref &&
                push!(errors, "$key must not reference this case itself (`$item`)")
        end
    end
end

function cross_validate_usecase_relations!(checks::Dict{String, UseCaseCheck}, dirs)
    registry = Dict{Tuple{String, Int}, String}()
    for dir in dirs
        case_name = basename(dir)
        meta = load_usecase_meta(dir)
        meta === nothing && continue
        id = get(meta, "id", nothing)
        version = usecase_version_int(meta)
        id isa AbstractString || continue
        version === nothing && continue
        registry[(id, version)] = case_name
    end

    for dir in dirs
        case_name = basename(dir)
        meta = load_usecase_meta(dir)
        meta === nothing && continue

        refs = String[]
        for key in RELATION_LIST_KEYS
            haskey(meta, key) || continue
            val = meta[key]
            val isa AbstractVector || continue
            append!(refs, filter(x -> x isa AbstractString, val))
        end

        for ref in refs
            parsed = parse_usecase_ref(ref)
            parsed === nothing && continue
            key = (parsed.id, parsed.version)
            haskey(registry, key) && continue
            msg = "`related`/`builds_on` references missing use case `$ref` (navigation only — not a CI gate)"
            checks[case_name].warnings = vcat(checks[case_name].warnings, [msg])
        end
    end
end

function cross_validate_usecase_versions!(checks::Dict{String, UseCaseCheck}, dirs)
    registry = Dict{Tuple{String, Int}, String}()
    active_by_id = Dict{String, Vector{String}}()

    for dir in dirs
        case_name = basename(dir)
        meta = load_usecase_meta(dir)
        meta === nothing && continue
        id = get(meta, "id", nothing)
        version = usecase_version_int(meta)
        id isa AbstractString || continue
        version === nothing && continue

        key = (id, version)
        if haskey(registry, key)
            other = registry[key]
            msg = "duplicate use-case version `$id@$version` (also in `$other`)"
            checks[case_name].errors = vcat(checks[case_name].errors, [msg])
            checks[other].errors = vcat(checks[other].errors, [msg])
        else
            registry[key] = case_name
        end

        get(meta, "status", nothing) == "active" || continue
        push!(get!(active_by_id, id, String[]), case_name)
    end

    for (id, cases) in active_by_id
        length(cases) <= 1 && continue
        msg = "multiple active versions/directories for id `$id`: $(join(cases, ", "))"
        for case_name in cases
            checks[case_name].errors = vcat(checks[case_name].errors, [msg])
        end
    end

    for dir in dirs
        case_name = basename(dir)
        meta = load_usecase_meta(dir)
        meta === nothing && continue
        lineage = get(meta, "lineage", nothing)
        lineage isa AbstractDict || continue

        refs = String[]
        for key in LINEAGE_LIST_KEYS
            haskey(lineage, key) || continue
            val = lineage[key]
            val isa AbstractVector || continue
            append!(refs, filter(x -> x isa AbstractString, val))
        end
        for key in LINEAGE_SCALAR_KEYS
            haskey(lineage, key) || continue
            val = lineage[key]
            val isa AbstractString && push!(refs, val)
        end

        for ref in refs
            parsed = parse_usecase_ref(ref)
            parsed === nothing && continue
            key = (parsed.id, parsed.version)
            haskey(registry, key) && continue
            msg = "lineage references missing use case `$ref`"
            checks[case_name].errors = vcat(checks[case_name].errors, [msg])
        end
    end
end

function validate_usecase(dir::AbstractString, current_template::Int)
    case_name = basename(dir)
    errors = String[]
    warnings = String[]
    usecase = joinpath(dir, "usecase.md")

    if !isfile(usecase)
        return UseCaseCheck(case_name, ["missing usecase.md"], warnings)
    end

    text = read(usecase, String)
    yaml, body = try
        split_frontmatter(text)
    catch e
        return UseCaseCheck(case_name, ["$(sprint(showerror, e))"], warnings)
    end

    meta = try
        load_frontmatter(yaml)
    catch e
        return UseCaseCheck(case_name, ["invalid YAML frontmatter: $(sprint(showerror, e))"], warnings)
    end

    for key in REQUIRED_FRONTMATTER
        haskey(meta, string(key)) || push!(errors, "missing frontmatter key `$key`")
    end

    status = get(meta, "status", nothing)
    if status === nothing
        push!(errors, "missing `status`")
    elseif !(status isa AbstractString) || status ∉ ALLOWED_STATUS
        push!(errors, "invalid status `$status` (expected draft|active|deprecated)")
    end

    tv = template_version_int(meta)
    tv === nothing && haskey(meta, "template_version") &&
        push!(errors, "unreadable `template_version`")

    uv = usecase_version_int(meta)
    if uv === nothing && haskey(meta, "version")
        push!(errors, "unreadable `version`")
    elseif uv !== nothing && uv < 1
        push!(errors, "`version` must be a positive integer")
    end

    id = get(meta, "id", nothing)
    dirname_id = match(r"^(UC-\d+)", case_name)
    if id isa AbstractString && dirname_id !== nothing && id != dirname_id.captures[1]
        push!(errors, "frontmatter id `$id` does not match directory prefix `$(dirname_id.captures[1])`")
    end

    id isa AbstractString && uv isa Int &&
        validate_lineage_frontmatter!(errors, warnings, meta, id, uv)
    id isa AbstractString && uv isa Int &&
        validate_relation_frontmatter!(errors, warnings, meta, id, uv)

    found = Set(section_headings(body))
    for title in REQUIRED_SECTION_TITLES
        title in found || push!(errors, "missing section heading `$title`")
    end

    if status == "active"
        tv !== nothing && tv != current_template &&
            push!(errors, "active case template_version=$tv but current template is v$current_template (see template/versions/)")
        isfile(joinpath(dir, "test.jl")) || push!(errors, "active case missing test.jl")
        occursin("<!--", body) &&
            push!(errors, "active case still contains HTML comments (remove template instructions)")
    elseif status in ("draft", "deprecated") && tv !== nothing && tv != current_template
        push!(warnings, "uses template v$tv; current template is v$current_template (allowed for $status)")
    end

    return UseCaseCheck(case_name, errors, warnings)
end

function validate_all_usecases()
    current = current_template_version()
    dirs = usecase_directories()
    isempty(dirs) && error("No usecases/UC-* directories found under $(usecases_root())")
    checks = Dict(basename(dir) => validate_usecase(dir, current) for dir in dirs)
    cross_validate_usecase_versions!(checks, dirs)
    cross_validate_usecase_relations!(checks, dirs)
    return current, collect(values(checks))
end

function active_usecase_test_files()
    files = String[]
    for dir in usecase_directories()
        usecase = joinpath(dir, "usecase.md")
        isfile(usecase) || continue
        text = read(usecase, String)
        yaml, _ = split_frontmatter(text)
        meta = load_frontmatter(yaml)
        get(meta, "status", nothing) == "active" || continue
        test_jl = joinpath(dir, "test.jl")
        isfile(test_jl) || error("Active use case $(basename(dir)) is missing test.jl")
        push!(files, test_jl)
    end
    return files
end
