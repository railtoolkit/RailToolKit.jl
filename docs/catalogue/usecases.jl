# Use-case page generation from usecases/UC-*/usecase.md.

struct UseCaseRecord
    dir::String
    dir_name::String
    meta::Dict
    body::String
    page_ref::String
    page_path::String
    edit_url::String
end

function load_usecase_record(dir::AbstractString)
    usecase = joinpath(dir, "usecase.md")
    isfile(usecase) || error("missing usecase.md in $(dir)")
    text = read(usecase, String)
    yaml, body = split_frontmatter(text)
    meta = load_frontmatter(yaml)
    id = string(get(meta, "id", basename(dir)))
    dir_name = basename(dir)
    page_path = "generated/usecases/$id.md"
    return UseCaseRecord(
        dir,
        dir_name,
        meta,
        body,
        id,
        page_path,
        "$REPO_EDIT_BASE/usecases/$dir_name/usecase.md",
    )
end

function render_case_header(record::UseCaseRecord, id_to_path::Dict{String, String})
    meta = record.meta
    id = string(get(meta, "id", "?"))
    status = string(get(meta, "status", "?"))
    version = get(meta, "version", "?")
    template_version = get(meta, "template_version", "?")
    owner = string(get(meta, "owner", ""))
    created = string(get(meta, "created", ""))
    updated = string(get(meta, "updated", ""))
    summary = string(get(meta, "summary", ""))
    related = refs_summary(meta, "related", id_to_path)
    builds_on = refs_summary(meta, "builds_on", id_to_path)
    lineage = lineage_summary(meta, id_to_path)

    lines = String[
        "```@meta",
        "EditURL = \"$(record.edit_url)\"",
        "```",
        "",
        # Julia Markdown: single backticks = code; double backticks = math.
        "**Status:** `$status` · **Version:** `$id@$version` · **Template:** v$template_version",
        "",
        summary == "" ? "" : "> $summary",
        summary == "" ? "" : "",
        "| Field | Value |",
        "|-------|-------|",
        "| ID | `$id` |",
        "| Owner | $owner |",
        "| Created | $created |",
        "| Updated | $updated |",
        "| Packages | $(packages_summary(meta)) |",
    ]
    related != "" && push!(lines, "| Related | $related |")
    builds_on != "" && push!(lines, "| Builds on | $builds_on |")
    lineage != "" && push!(lines, "| Lineage | $lineage |")
    push!(lines, "")
    push!(lines, "Source: [`usecase.md`]($(record.edit_url)) in [`$(record.dir_name)`](https://github.com/railtoolkit/RailToolKit.jl/tree/main/usecases/$(record.dir_name)).")
    push!(lines, "")
    return join(filter(!isempty, lines), "\n")
end

const CATALOGUE_STATUS_ORDER = ("active", "draft", "deprecated")

function catalogue_row(record::UseCaseRecord)
    meta = record.meta
    id = string(get(meta, "id", "?"))
    title = string(get(meta, "title", id))
    status = string(get(meta, "status", "?"))
    pkgs = packages_summary(meta)
    summary = string(get(meta, "summary", ""))
    link = "[$title](usecases/$id.md)"
    return "| `$id` | $link | `$status` | $pkgs | $summary |"
end

function render_catalogue_section(status::AbstractString, records::Vector{UseCaseRecord})
    matching = filter(r -> string(get(r.meta, "status", "")) == status, records)
    isempty(matching) && return String[]
    heading = titlecase(status)
    lines = String[
        "## $heading",
        "",
        "| ID | Title | Status | Packages | Summary |",
        "|----|-------|--------|----------|---------|",
    ]
    for record in matching
        push!(lines, catalogue_row(record))
    end
    push!(lines, "")
    return lines
end

function render_catalogue_table(records::Vector{UseCaseRecord})
    lines = String[
        "# Use-case catalogue",
        "",
        "Every workflow under [`usecases/`](https://github.com/railtoolkit/RailToolKit.jl/tree/main/usecases),",
        "including **draft**, **active**, and **deprecated**. Generated from YAML frontmatter at docs build time.",
        "Package landing pages are generated only from **active** cases — see [Packages](packages.md).",
        "",
    ]
    if isempty(records)
        push!(lines, "_No `UC-*` use cases in this tree yet._")
        push!(lines, "")
        return join(lines, "\n")
    end
    for status in CATALOGUE_STATUS_ORDER
        append!(lines, render_catalogue_section(status, records))
    end
    known = Set(CATALOGUE_STATUS_ORDER)
    extras = unique(
        string(get(r.meta, "status", "?")) for r in records
        if !(string(get(r.meta, "status", "?")) in known)
    )
    for status in sort(collect(extras))
        append!(lines, render_catalogue_section(status, records))
    end
    return join(lines, "\n")
end

const USECASE_ASSET_MEDIA_EXTS = (".png", ".svg", ".jpg", ".jpeg", ".gif", ".webp")

"""
Copy illustrative media from `usecases/UC-*/assets/` next to generated pages and
rewrite `](assets/…)` links so Documenter resolves them. GitHub keeps viewing
the original relative paths in `usecase.md`.
"""
function stage_usecase_assets!(src_dir::AbstractString, record::UseCaseRecord)
    assets_src = joinpath(record.dir, "assets")
    isdir(assets_src) || return
    assets_dst = joinpath(src_dir, "generated", "usecases", "assets", record.dir_name)
    mkpath(assets_dst)
    for name in readdir(assets_src)
        ext = lowercase(splitext(name)[2])
        ext in USECASE_ASSET_MEDIA_EXTS || continue
        cp(joinpath(assets_src, name), joinpath(assets_dst, name); force=true)
    end
    return
end

function rewrite_asset_links(body::AbstractString, dir_name::AbstractString)
    return replace(body, r"\]\(assets/" => "](assets/$(dir_name)/")
end

function write_usecase_pages!(src_dir::AbstractString, records::Vector{UseCaseRecord})
    id_to_path = Dict{String, String}(
        string(get(record.meta, "id", "")) => record.page_path for record in records
    )
    link_map = Dict(uc_id => basename(path) for (uc_id, path) in id_to_path)

    for record in records
        stage_usecase_assets!(src_dir, record)
        body = strip_html_comments(record.body)
        body = rewrite_body_links(body, link_map)
        body = rewrite_asset_links(body, record.dir_name)
        header = render_case_header(record, id_to_path)
        write(joinpath(src_dir, record.page_path), join([header, body], "\n"))
    end
    return id_to_path
end

function usecase_sidebar_pages(records::Vector{UseCaseRecord})
    groups = Any[]
    known = Set(CATALOGUE_STATUS_ORDER)
    for status in CATALOGUE_STATUS_ORDER
        matching = filter(r -> string(get(r.meta, "status", "")) == status, records)
        isempty(matching) && continue
        pages = [r.page_ref => r.page_path for r in matching]
        push!(groups, titlecase(status) => pages)
    end
    extras = unique(
        string(get(r.meta, "status", "?")) for r in records
        if !(string(get(r.meta, "status", "?")) in known)
    )
    for status in sort(collect(extras))
        matching = filter(r -> string(get(r.meta, "status", "")) == status, records)
        pages = [r.page_ref => r.page_path for r in matching]
        push!(groups, titlecase(status) => pages)
    end
    return groups
end
