# Markdown link rewriting and frontmatter summaries for generated pages.

function strip_html_comments(text::AbstractString)
    return replace(text, r"<!--[\s\S]*?-->" => "")
end

function packages_summary(meta::AbstractDict)
    pkgs = get(meta, "packages", nothing)
    pkgs === nothing && return ""
    if !(pkgs isa AbstractVector)
        return string(pkgs)
    end
    parts = String[]
    for item in pkgs
        item isa AbstractDict || continue
        name = get(item, "name", "?")
        role = get(item, "role", "")
        role == "" ? push!(parts, string(name)) : push!(parts, "$name ($role)")
    end
    return join(parts, ", ")
end

function ref_link_from_usecase(ref::AbstractString, id_to_path::Dict{String, String})
    parsed = parse_usecase_ref(ref)
    parsed === nothing && return "`$ref`"
    haskey(id_to_path, parsed.id) || return "`$ref`"
    return "[`$ref`]($(basename(id_to_path[parsed.id])))"
end

function refs_summary(meta::AbstractDict, key::AbstractString, id_to_path::Dict{String, String})
    val = get(meta, key, nothing)
    val === nothing && return ""
    if val isa AbstractVector
        links = [
            item isa AbstractString ? ref_link_from_usecase(item, id_to_path) : string(item)
            for item in val
        ]
        return join(links, ", ")
    end
    return string(val)
end

function lineage_summary(meta::AbstractDict, id_to_path::Dict{String, String})
    lineage = get(meta, "lineage", nothing)
    lineage isa AbstractDict || return ""
    parts = String[]
    for (key, val) in lineage
        if val isa AbstractVector
            for item in val
                item isa AbstractString || continue
                push!(parts, "$key: $(ref_link_from_usecase(item, id_to_path))")
            end
        elseif val isa AbstractString
            push!(parts, "$key: $(ref_link_from_usecase(val, id_to_path))")
        end
    end
    return join(parts, "; ")
end

function rewrite_usecase_link(m::RegexMatch, id_to_path)
    dir = m.captures[1]
    id_match = match(r"^(UC-\d+)", dir)
    id_match === nothing && return m.match
    uc_id = id_match.captures[1]
    haskey(id_to_path, uc_id) || return m.match
    return "]($(id_to_path[uc_id]))"
end

function rewrite_body_links(body::AbstractString, id_to_path::Dict{String, String})
    pattern = r"\]\(\.\./(UC-\d+-[^)/]+)/?\)"
    out = IOBuffer()
    last_end = 1
    for m in eachmatch(pattern, body)
        start_idx = m.offset
        write(out, body[last_end:start_idx - 1])
        write(out, rewrite_usecase_link(m, id_to_path))
        last_end = start_idx + ncodeunits(m.match)
    end
    write(out, body[last_end:end])
    body = String(take!(out))
    body = replace(body, r"\]\(\.\./\.\./AGENTS\.md\)" => "](../../contributing.md)")
    return body
end
