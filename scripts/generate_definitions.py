#!/usr/bin/env python3
# /// script
# requires-python = ">=3.10"
# dependencies = [
#   "requests",
#   "beautifulsoup4",
# ]
# ///
"""
Fetches Azure CAF resource abbreviations and naming rules from Microsoft docs,
then generates resource_definitions.json and exceptions.md.

Usage (recommended):
    uv run scripts/generate_definitions.py

Usage (manual):
    pip install requests beautifulsoup4
    python scripts/generate_definitions.py
"""

import json
import re
import sys
import warnings

warnings.filterwarnings("ignore", message="urllib3 v2 only supports OpenSSL")

from pathlib import Path

import requests
from bs4 import BeautifulSoup

CAF_URL = "https://learn.microsoft.com/en-us/azure/cloud-adoption-framework/ready/azure-best-practices/resource-abbreviations"
NAMING_RULES_URL = "https://learn.microsoft.com/en-us/azure/azure-resource-manager/management/resource-name-rules"

OUTPUT_DIR = Path(__file__).resolve().parent.parent
DEFINITIONS_FILE = OUTPUT_DIR / "resource_definitions.json"
OVERRIDES_FILE = OUTPUT_DIR / "resource_overrides.json"
EXCEPTIONS_FILE = OUTPUT_DIR / "exceptions.md"


def fetch_page(url: str) -> BeautifulSoup:
    resp = requests.get(url, timeout=30)
    resp.raise_for_status()
    return BeautifulSoup(resp.text, "html.parser")


def to_snake_case(name: str) -> str:
    """Convert a resource display name to a Terraform-friendly snake_case key."""
    s = name.strip()
    # Remove content in parentheses for the key but keep for reference
    s = re.sub(r"\s*\(.*?\)\s*", " ", s)
    # Replace common separators
    s = re.sub(r"[/\-–—]", " ", s)
    s = re.sub(r"[^a-zA-Z0-9\s]", "", s)
    s = re.sub(r"\s+", "_", s.strip())
    s = s.lower()
    # Remove leading/trailing underscores
    s = s.strip("_")
    return s


def parse_caf_abbreviations(soup: BeautifulSoup) -> list[dict]:
    """Parse CAF abbreviation tables into a list of resource defs."""
    resources = []
    tables = soup.find_all("table")
    current_category = "General"

    for table in tables:
        # Try to find the category heading before this table
        prev = table.find_previous(["h2", "h3"])
        if prev:
            current_category = prev.get_text(strip=True)

        headers = [th.get_text(strip=True).lower() for th in table.find_all("th")]
        if not headers:
            continue

        # Find column indices
        name_idx = None
        abbr_idx = None
        rt_idx = None
        for i, h in enumerate(headers):
            if "resource" in h and ("type" not in h or "namespace" not in h):
                if name_idx is None:
                    name_idx = i
            if "abbreviation" in h:
                abbr_idx = i
            if "namespace" in h or ("resource" in h and "provider" in h):
                rt_idx = i
            # Some tables use "Resource type and provider namespace"
            if "type" in h and "provider" in h:
                rt_idx = i

        if name_idx is None or abbr_idx is None:
            continue

        for row in table.find_all("tr")[1:]:
            cells = row.find_all("td")
            if len(cells) <= max(name_idx, abbr_idx):
                continue

            display_name = cells[name_idx].get_text(strip=True)
            slug = cells[abbr_idx].get_text(strip=True)

            # Skip entries with descriptive/variable slugs
            if slug.startswith("<") or slug.startswith("(") or not slug:
                continue

            resource_type = ""
            if rt_idx is not None and len(cells) > rt_idx:
                rt_cell = cells[rt_idx]
                # Get the text, handle code blocks
                code = rt_cell.find("code")
                resource_type = (code.get_text(strip=True) if code else rt_cell.get_text(strip=True))

            key = to_snake_case(display_name)
            if not key:
                continue

            resources.append({
                "key": key,
                "display_name": display_name,
                "slug": slug.lower() if slug == slug.upper() and len(slug) <= 2 else slug,
                "resource_type": resource_type,
                "category": current_category,
            })

    return resources


def parse_naming_rules(soup: BeautifulSoup) -> dict[str, dict]:
    """Parse the naming rules page into a dict keyed by resource type."""
    rules = {}
    tables = soup.find_all("table")

    for table in tables:
        headers = [th.get_text(strip=True).lower() for th in table.find_all("th")]
        if not headers:
            continue

        # Find relevant columns
        entity_idx = None
        scope_idx = None
        length_idx = None
        chars_idx = None

        for i, h in enumerate(headers):
            if "entity" in h or "resource" in h:
                entity_idx = i
            if "scope" in h:
                scope_idx = i
            if "length" in h:
                length_idx = i
            if "valid" in h or "character" in h:
                chars_idx = i

        if entity_idx is None or length_idx is None:
            continue

        for row in table.find_all("tr")[1:]:
            cells = row.find_all("td")
            if len(cells) <= max(filter(lambda x: x is not None, [entity_idx, length_idx])):
                continue

            entity_cell = cells[entity_idx]
            # Try to find an anchor with the resource type
            anchor = entity_cell.find("a")
            entity_name = entity_cell.get_text(strip=True)

            # Extract resource type from the link or text
            resource_type = ""
            if anchor and anchor.get("href"):
                # The naming rules page links often contain resource type info
                pass

            # Look for resource type pattern in nearby elements
            # The naming rules tables are organised by provider namespace
            # Check the heading above this table
            prev_heading = table.find_previous(["h2", "h3"])
            provider = prev_heading.get_text(strip=True) if prev_heading else ""

            # Parse length
            length_text = cells[length_idx].get_text(strip=True)
            min_length = 1
            max_length = 260
            length_match = re.search(r"(\d+)\s*[-–]\s*(\d+)", length_text)
            if length_match:
                min_length = int(length_match.group(1))
                max_length = int(length_match.group(2))
            else:
                single_match = re.search(r"(\d+)", length_text)
                if single_match:
                    val = int(single_match.group(1))
                    min_length = val
                    max_length = val

            # Parse valid characters
            chars_text = ""
            if chars_idx is not None and len(cells) > chars_idx:
                chars_text = cells[chars_idx].get_text(strip=True)

            # Determine if dashes are allowed
            dashes = "-" in chars_text or "hyphen" in chars_text.lower()

            # Build regex from character description
            regex = build_regex_from_chars(chars_text, min_length, max_length)

            # Parse scope
            scope = "resource group"
            if scope_idx is not None and len(cells) > scope_idx:
                scope = cells[scope_idx].get_text(strip=True).lower()

            # Build the resource type from provider + entity
            if provider.startswith("Microsoft."):
                rt = f"{provider}/{entity_name}"
            else:
                rt = entity_name

            rules[rt.lower()] = {
                "entity_name": entity_name,
                "provider": provider,
                "min_length": min_length,
                "max_length": max_length,
                "dashes": dashes,
                "regex": regex,
                "scope": scope,
                "valid_chars": chars_text,
            }
            # Also store by entity name for fuzzy matching
            rules[entity_name.lower()] = rules[rt.lower()]

    return rules


def build_regex_from_chars(chars_text: str, min_len: int, max_len: int) -> str:
    """Build a validation regex from a character description."""
    if not chars_text:
        return f"^.{{{min_len},{max_len}}}$"

    text = chars_text.lower()
    char_classes = []

    if "alphanumeric" in text or ("letter" in text and "number" in text) or ("a-z" in text):
        char_classes.append("a-zA-Z0-9")
    elif "lowercase" in text:
        char_classes.append("a-z0-9")

    if "hyphen" in text or "dash" in text:
        char_classes.append("-")
    if "underscore" in text:
        char_classes.append("_")
    if "period" in text or "dot" in text:
        char_classes.append(".")

    if not char_classes:
        return f"^.{{{min_len},{max_len}}}$"

    chars = "".join(char_classes)

    # Check start/end constraints
    start = f"[{chars}]"
    if "start with" in text and "letter" in text:
        start = "[a-zA-Z]"
    elif "start with" in text and "lowercase" in text:
        start = "[a-z]"
    elif "can't start with" in text and ("hyphen" in text or "underscore" in text):
        start = f"[a-zA-Z0-9]"

    end = f"[{chars}]"
    if "can't end with" in text and ("hyphen" in text or "period" in text):
        end = "[a-zA-Z0-9_]"

    if min_len <= 1:
        return f"^{start}$|^{start}[{chars}]*{end}$"

    middle_min = max(0, min_len - 2)
    middle_max = max(0, max_len - 2)

    if middle_min == 0:
        return f"^{start}[{chars}]{{{middle_min},{middle_max}}}{end}$"

    return f"^{start}[{chars}]{{{middle_min},{middle_max}}}{end}$"


def match_naming_rules(caf_resources: list[dict], naming_rules: dict[str, dict]) -> dict:
    """Try to match CAF resources to naming rules by resource type."""
    matched = {}

    for res in caf_resources:
        rt = res.get("resource_type", "").lower()
        entity = res["display_name"].lower()
        key = res["key"]

        rule = None
        # Try exact resource type match
        if rt and rt in naming_rules:
            rule = naming_rules[rt]
        # Try entity name match
        elif entity in naming_rules:
            rule = naming_rules[entity]
        # Try fuzzy match on entity name
        else:
            for rule_key, rule_val in naming_rules.items():
                if entity in rule_key or rule_key in entity:
                    rule = rule_val
                    break

        if rule:
            matched[key] = {
                "slug": res["slug"],
                "min_length": rule["min_length"],
                "max_length": rule["max_length"],
                "regex": rule["regex"],
                "scope": rule["scope"],
                "dashes": rule["dashes"],
                "resource_type": res.get("resource_type", ""),
            }
        else:
            # Use defaults when we can't find naming rules
            matched[key] = {
                "slug": res["slug"],
                "min_length": 1,
                "max_length": 260,
                "regex": "^[a-zA-Z0-9][a-zA-Z0-9-._]*[a-zA-Z0-9]$",
                "scope": "resource group",
                "dashes": True,
                "resource_type": res.get("resource_type", ""),
                "_unmatched_rules": True,
            }

    return matched


def generate_exceptions(caf_resources: list[dict], definitions: dict) -> str:
    """Generate exceptions.md content."""
    lines = [
        "# Resource Naming Exceptions",
        "",
        "Resources from the Azure Cloud Adoption Framework abbreviations that could not be",
        "automatically matched to entries in the Azure resource naming rules documentation.",
        "",
        "These resources currently use default naming constraints (1-260 chars, alphanumeric",
        "+ hyphens). To provide accurate constraints, add entries to `resource_overrides.json`.",
        "Overrides are applied both at script regeneration time and directly by Terraform at",
        "plan time. See the README for details on the override workflow.",
        "",
        "| Resource Key | Display Name | Slug | Resource Type |",
        "|---|---|---|---|",
    ]

    unmatched = [
        (key, defn) for key, defn in sorted(definitions.items())
        if defn.get("_unmatched_rules")
    ]

    for key, defn in unmatched:
        display = next((r["display_name"] for r in caf_resources if r["key"] == key), key)
        lines.append(f"| {key} | {display} | {defn['slug']} | {defn.get('resource_type', '')} |")

    if not unmatched:
        lines.append("| *(none)* | All resources matched | | |")

    lines.append("")
    lines.append(f"*Generated from Azure docs. Total CAF resources: {len(definitions)}, "
                 f"Unmatched: {len(unmatched)}*")
    lines.append("")
    return "\n".join(lines)


def load_overrides() -> dict:
    """Load resource_overrides.json if it exists."""
    if not OVERRIDES_FILE.exists():
        return {}
    with open(OVERRIDES_FILE) as f:
        return json.load(f)


def apply_overrides(definitions: dict, overrides: dict) -> dict:
    """Deep-merge overrides on top of auto-generated definitions.

    For each key in overrides:
      - If the key exists in definitions, merge the override fields on top
      - If the key doesn't exist, add it as a new resource definition

    Override fields take precedence. The _unmatched_rules flag is cleared
    if the override provides min_length, max_length, or regex.
    """
    result = dict(definitions)
    for key, override in overrides.items():
        if key in result:
            base = dict(result[key])
            # If override provides naming rule fields, clear the unmatched flag
            rule_fields = {"min_length", "max_length", "regex", "scope", "dashes"}
            if rule_fields & set(override.keys()):
                base.pop("_unmatched_rules", None)
            base.update(override)
            result[key] = base
        else:
            # New resource entirely from overrides
            result[key] = override
    return result


def clean_definitions(definitions: dict) -> dict:
    """Remove internal flags from definitions before writing."""
    cleaned = {}
    for key, defn in sorted(definitions.items()):
        clean = {k: v for k, v in defn.items() if not k.startswith("_")}
        cleaned[key] = clean
    return cleaned


def main():
    print("Fetching CAF resource abbreviations...")
    caf_soup = fetch_page(CAF_URL)
    caf_resources = parse_caf_abbreviations(caf_soup)
    print(f"  Found {len(caf_resources)} resources with abbreviations")

    print("Fetching Azure resource naming rules...")
    rules_soup = fetch_page(NAMING_RULES_URL)
    naming_rules = parse_naming_rules(rules_soup)
    print(f"  Found {len(naming_rules)} naming rule entries")

    print("Matching resources to naming rules...")
    definitions = match_naming_rules(caf_resources, naming_rules)

    unmatched_before = sum(1 for d in definitions.values() if d.get("_unmatched_rules"))
    print(f"  Matched: {len(definitions) - unmatched_before}, Unmatched: {unmatched_before}")

    # Apply local overrides
    overrides = load_overrides()
    if overrides:
        print(f"Applying {len(overrides)} overrides from {OVERRIDES_FILE.name}...")
        definitions = apply_overrides(definitions, overrides)
        unmatched_after = sum(1 for d in definitions.values() if d.get("_unmatched_rules"))
        resolved = unmatched_before - unmatched_after
        if resolved > 0:
            print(f"  Resolved {resolved} previously unmatched resources")
    else:
        print(f"No overrides file found ({OVERRIDES_FILE.name}). "
              "Create one to persist manual corrections across regenerations.")

    unmatched_final = sum(1 for d in definitions.values() if d.get("_unmatched_rules"))
    print(f"Final: {len(definitions)} resources, {unmatched_final} still unmatched")

    # Write definitions
    cleaned = clean_definitions(definitions)
    with open(DEFINITIONS_FILE, "w") as f:
        json.dump(cleaned, f, indent=2, sort_keys=False)
    print(f"  Wrote {DEFINITIONS_FILE}")

    # Write exceptions (only resources still unmatched after overrides)
    exceptions_md = generate_exceptions(caf_resources, definitions)
    with open(EXCEPTIONS_FILE, "w") as f:
        f.write(exceptions_md)
    print(f"  Wrote {EXCEPTIONS_FILE}")

    print("Done!")
    return 0


if __name__ == "__main__":
    sys.exit(main())
