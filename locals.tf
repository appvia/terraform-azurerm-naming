locals {
  # ---------------------------------------------------------------------------
  # Layer 1: Load resource definitions, apply overrides, merge slug overrides
  #
  # Priority (highest wins):
  #   1. var.slug_overrides   — runtime slug customisation by module consumers
  #   2. resource_overrides.json — persistent local corrections (version-controlled)
  #   3. resource_definitions.json — auto-generated baseline from Azure docs
  # ---------------------------------------------------------------------------
  base_definitions     = jsondecode(file("${path.module}/resource_definitions.json"))
  has_overrides        = fileexists("${path.module}/resource_overrides.json")
  override_raw         = local.has_overrides ? file("${path.module}/resource_overrides.json") : "{}"
  override_definitions = jsondecode(local.override_raw)

  # Deep-merge: override fields win over base fields, per resource.
  # Keys present only in overrides are added as new resources.
  raw_definitions = {
    for key in distinct(concat(keys(local.base_definitions), keys(local.override_definitions))) :
    key => merge(
      try(local.base_definitions[key], {}),
      try(local.override_definitions[key], {})
    )
  }

  definitions = {
    for key, def in local.raw_definitions : key => merge(def, {
      slug = lookup(var.slug_overrides, key, def.slug)
    })
  }

  # ---------------------------------------------------------------------------
  # Layer 2: Build the unique random string
  # ---------------------------------------------------------------------------
  random_safe = join("", [random_string.first_letter.result, random_string.main.result])
  unique      = substr(var.unique_seed != "" ? var.unique_seed : local.random_safe, 0, var.unique_length)

  # ---------------------------------------------------------------------------
  # Layer 3: Per-resource component preparation
  # ---------------------------------------------------------------------------
  components = {
    for key, def in local.definitions : key => {
      sep        = def.dashes ? "-" : ""
      slug       = lower(def.slug)
      unique_str = lower(local.unique)
      max_length = def.max_length

      pfx = [for e in var.prefix : lower(e)]
      sfx = [for e in var.suffix : lower(e)]

      pfxshort = var.prefix_short != null ? [
        for e in var.prefix_short : lower(e)
      ] : null
      sfxshort = var.suffix_short != null ? [
        for e in var.suffix_short : lower(e)
      ] : null
    }
  }

  # ---------------------------------------------------------------------------
  # Layer 4: Assemble full-length names
  # ---------------------------------------------------------------------------
  full = {
    for key, c in local.components : key => {
      name        = join(c.sep, compact(concat(c.pfx, [c.slug], c.sfx)))
      name_unique = join(c.sep, compact(concat(c.pfx, [c.slug], c.sfx, [c.unique_str])))
    }
  }

  # ---------------------------------------------------------------------------
  # Layer 5: Assemble short-variant names
  # ---------------------------------------------------------------------------
  short = {
    for key, c in local.components : key => {
      name = join(c.sep, compact(concat(
        coalesce(c.pfxshort, c.pfx), [c.slug], coalesce(c.sfxshort, c.sfx)
      )))
      name_unique = join(c.sep, compact(concat(
        coalesce(c.pfxshort, c.pfx), [c.slug], coalesce(c.sfxshort, c.sfx), [c.unique_str]
      )))
    }
  }
}

# ---------------------------------------------------------------------------
# Truncation logic (separate locals block for clarity)
# ---------------------------------------------------------------------------
locals {
  # Step 1: Gather the base elements for truncation
  trunc_base = {
    for key, c in local.components : key => {
      sep        = c.sep
      slug       = c.slug
      unique_str = c.unique_str
      max_length = c.max_length

      # Use short variants as the base when available
      elems = concat(coalesce(c.pfxshort, c.pfx), coalesce(c.sfxshort, c.sfx))
      n_pfx = length(coalesce(c.pfxshort, c.pfx))
    }
  }

  # Step 2: Calculate budgets for name (no unique)
  trunc_name_budget = {
    for key, b in local.trunc_base : key => {
      # Number of separators = number of non-empty parts - 1
      n_parts = length(compact(concat(slice(b.elems, 0, b.n_pfx), [b.slug], slice(b.elems, b.n_pfx, length(b.elems)))))
      sep_len = b.sep == "" ? 0 : max(0, length(compact(concat(slice(b.elems, 0, b.n_pfx), [b.slug], slice(b.elems, b.n_pfx, length(b.elems))))) - 1)
      fixed   = length(b.slug)
      n_elems = length(b.elems)
      avail   = max(0, b.max_length - length(b.slug) - (b.sep == "" ? 0 : max(0, length(compact(concat(slice(b.elems, 0, b.n_pfx), [b.slug], slice(b.elems, b.n_pfx, length(b.elems))))) - 1)))
    }
  }

  # Step 3: Calculate budgets for name_unique
  trunc_uniq_budget = {
    for key, b in local.trunc_base : key => {
      n_parts = length(compact(concat(slice(b.elems, 0, b.n_pfx), [b.slug], slice(b.elems, b.n_pfx, length(b.elems)), [b.unique_str])))
      sep_len = b.sep == "" ? 0 : max(0, length(compact(concat(slice(b.elems, 0, b.n_pfx), [b.slug], slice(b.elems, b.n_pfx, length(b.elems)), [b.unique_str]))) - 1)
      fixed   = length(b.slug) + length(b.unique_str)
      n_elems = length(b.elems)
      avail   = max(0, b.max_length - length(b.slug) - length(b.unique_str) - (b.sep == "" ? 0 : max(0, length(compact(concat(slice(b.elems, 0, b.n_pfx), [b.slug], slice(b.elems, b.n_pfx, length(b.elems)), [b.unique_str]))) - 1)))
    }
  }

  # Step 4: Per-element budget (available / n_elems)
  trunc_per_elem = {
    for key, b in local.trunc_base : key => {
      name_budget = local.trunc_name_budget[key].n_elems > 0 ? max(1, floor(
        local.trunc_name_budget[key].avail / local.trunc_name_budget[key].n_elems
      )) : 0
      uniq_budget = local.trunc_uniq_budget[key].n_elems > 0 ? max(1, floor(
        local.trunc_uniq_budget[key].avail / local.trunc_uniq_budget[key].n_elems
      )) : 0
    }
  }

  # Step 5: Truncate elements and assemble
  trunc_name_parts = {
    for key, b in local.trunc_base : key => {
      prefix = [
        for i, e in b.elems : substr(e, 0, min(length(e), local.trunc_per_elem[key].name_budget))
        if i < b.n_pfx
      ]
      suffix = [
        for i, e in b.elems : substr(e, 0, min(length(e), local.trunc_per_elem[key].name_budget))
        if i >= b.n_pfx
      ]
    }
  }

  trunc_uniq_parts = {
    for key, b in local.trunc_base : key => {
      prefix = [
        for i, e in b.elems : substr(e, 0, min(length(e), local.trunc_per_elem[key].uniq_budget))
        if i < b.n_pfx
      ]
      suffix = [
        for i, e in b.elems : substr(e, 0, min(length(e), local.trunc_per_elem[key].uniq_budget))
        if i >= b.n_pfx
      ]
    }
  }

  # Step 6: Join truncated parts
  truncassembled = {
    for key, b in local.trunc_base : key => {
      name = substr(join(b.sep, compact(concat(
        local.trunc_name_parts[key].prefix,
        [b.slug],
        local.trunc_name_parts[key].suffix
      ))), 0, b.max_length)
      name_unique = substr(join(b.sep, compact(concat(
        local.trunc_uniq_parts[key].prefix,
        [b.slug],
        local.trunc_uniq_parts[key].suffix,
        [b.unique_str]
      ))), 0, b.max_length)
    }
  }
}

# ---------------------------------------------------------------------------
# Final assembly and output
# ---------------------------------------------------------------------------
locals {
  # Pick the best variant: full > short > truncated
  assembled = {
    for key, def in local.definitions : key => {
      name = (
        length(local.full[key].name) <= def.max_length
        ? local.full[key].name
        : length(local.short[key].name) <= def.max_length
        ? local.short[key].name
        : local.truncassembled[key].name
      )
      name_unique = (
        length(local.full[key].name_unique) <= def.max_length
        ? local.full[key].name_unique
        : length(local.short[key].name_unique) <= def.max_length
        ? local.short[key].name_unique
        : local.truncassembled[key].name_unique
      )
    }
  }

  # Final resources map with validation
  resources = {
    for key, def in local.definitions : key => {
      name        = local.assembled[key].name
      name_unique = local.assembled[key].name_unique
      slug        = def.slug
      min_length  = def.min_length
      max_length  = def.max_length
      scope       = def.scope
      regex       = def.regex
      dashes      = def.dashes
      valid_name = (
        length(local.assembled[key].name) >= def.min_length &&
        length(local.assembled[key].name) <= def.max_length &&
        can(regex(def.regex, local.assembled[key].name))
      )
      valid_name_unique = (
        length(local.assembled[key].name_unique) >= def.min_length &&
        length(local.assembled[key].name_unique) <= def.max_length &&
        can(regex(def.regex, local.assembled[key].name_unique))
      )
    }
  }
}
