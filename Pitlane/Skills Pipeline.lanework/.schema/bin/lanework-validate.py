#!/usr/bin/env python3
# lanework-validate v1
"""lanework-validate — a board, or one index.md, checked against the schema set beside this script.

    python3 .schema/bin/lanework-validate.py <path> [<path> ...]

A path naming a FILE validates that one document against the schema its position selects — the
first ancestor whose name ends `.lanework` is its board, and the folder depth below that picks
board, lane, card, comment or attachment, exactly as the board walk would; a file outside any
board is read by its own `kind`. A path naming a `.lanework` DIRECTORY walks the whole board: every
lane, card, comment and attachment, `.trash/` included and `comments/.draft` excluded. Any other
directory is searched one level down for boards.

Three kinds of line, and an exit code that reads only the first:

    FAIL <file>: <rule> at <schema locator> (instance <document locator>) — <why>     exit 1
    WARN <file>: <rule> — <why>                                            reported, exit 0
    DEPRECATED <file>: deprecated at <locator> (instance <locator>) — <branch>: <why>   exit 0

A DEPRECATED line names a value the app still READS but no longer WRITES — the `deprecated: true`
branch of the schema the value matched. A clean run prints no FAIL and no DEPRECATED line; that is
the check to make before committing a hand-written file. Exit 2 is a usage error, a schema set
this script cannot read, or a population of zero documents, which is never a pass.

Options: `--schema <dir>` reads a set other than the `.schema/` folder this script lives in;
`-v` / `--verbose` prints the schema pick on a clean single-file run, which is otherwise silent.

This is the stock-interpreter copy of `scripts/lanework-validate` in the Lanework repository —
the standard library only, python 3.9 and up, nothing installed that `git` did not already need.
Each part is transcribed from that validator with the line cited, so the two can be diffed rather
than compared: the frontmatter splitter from `Frontmatter.swift`, the walk and its skip rules from
`BoardWalk.swift`, the structural mirrors from `IntegrityMirrors.swift`, and scalar resolution
from Yams' own `Resolver.swift` and `Constructor.swift`. What it reads of YAML is exactly the
dialect the app writes — plain, single- and double-quoted scalars, flow and block mappings and
sequences, plain-scalar line folding — and a construct outside that dialect (a block scalar, an
anchor, a tag) is reported as unreadable rather than guessed at; `scripts/validate-schema.sh`
in the repository reads the full language. The repository's validator is the reference, and
`scripts/test-board-validator.sh` there pins this script's verdict per document to its.
"""

import json
import math
import os
import re
import sys

# MARK: - Names the format claims (IntegrityMirrors.swift)

INDEX_FILE = "index.md"
TRASH_FOLDER = ".trash"
ATTACHMENTS_FOLDER = "attachments"
COMMENTS_FOLDER = "comments"
BOARD_SUFFIX = ".lanework"

# The app's own supported format version (`BoardLoader.supportedSchema`).
SUPPORTED_SCHEMA = 1

# The kinds the format knows, in the format's own order, and the emitted file each validates against.
KINDS = ("board", "lane", "card", "comment", "attachment", "config")
SCHEMA_FILENAMES = {
    "board": "board.json",
    "lane": "lane.json",
    "card": "card.json",
    "comment": "comment.json",
    "attachment": "attachment.json",
    "config": "config-document.json",
}
COMMON_FILENAME = "common.json"

# The identity predicate (`IntegrityRules.isIdentityShaped`): hex, 8-4-4-4-12, any case, any version.
IDENTITY = re.compile(r"^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{4}-[0-9a-fA-F]{12}$")


def is_identity_shaped(name):
    return IDENTITY.match(name) is not None


def canonical_identity(name):
    """Identity comparison is UUID-value equality (`IntegrityRules.canonicalIdentity`)."""
    return name.lower()


def blob_name(extension):
    """`AttachmentStore.blobName(extension:)`: `blob`, plus `.` and the extension where there is one."""
    if not extension:
        return "blob"
    return "blob." + extension


# MARK: - What can go wrong while reading a file (Frontmatter.Failure)


class FrontmatterFailure(Exception):
    """One reason a file has no frontmatter to validate: the keyword a FAIL line carries, and why."""

    def __init__(self, keyword, message):
        Exception.__init__(self, message)
        self.keyword = keyword
        self.message = message


class YAMLError(Exception):
    """The reader refused the block. Reported as `unparseable-yaml`, the same keyword Yams' refusal gets."""


# MARK: - The frontmatter splitter (Frontmatter.swift, transcribed from FrontmatterDocument.parse)


def lines_of(text):
    """`FrontmatterDocument.lines(of:)` — every line keeps its own terminator, so joining reproduces the text."""
    parts = text.split("\n")
    lines = [part + "\n" for part in parts[:-1]]
    if parts[-1]:
        lines.append(parts[-1])
    return lines


def is_delimiter(line):
    """`FrontmatterDocument.isDelimiter(_:)`: the line is `---` once trailing whitespace is dropped."""
    return line.rstrip() == "---"


def read_document(path):
    """One index.md, read from disk and projected — `Frontmatter.read(contentsOf:)`.

    UTF-8 without a BOM is checked here rather than in the structural pass, because it is the same
    read: the app's hard rule is "files must be UTF-8, no BOM", and a file that fails it has no
    frontmatter to speak of.
    """
    try:
        with open(path, "rb") as handle:
            data = handle.read()
    except OSError:
        raise FrontmatterFailure("not-utf8", "the file could not be read")
    if data[:3] == b"\xef\xbb\xbf":
        raise FrontmatterFailure("byte-order-mark", "the file opens with a UTF-8 byte-order mark")
    try:
        text = data.decode("utf-8")
    except UnicodeDecodeError:
        raise FrontmatterFailure("not-utf8", "the file is not valid UTF-8")
    return parse_document(text)


def parse_document(text):
    """`FrontmatterDocument.parse`, transcribed: line 1 must be a `---` delimiter, the block ends at the
    next one, and the body is ignored entirely."""
    all_lines = lines_of(text)
    if not all_lines or not is_delimiter(all_lines[0]):
        raise FrontmatterFailure("frontmatter-delimiters", "line 1 is not a `---` delimiter")
    closing = None
    for index in range(1, len(all_lines)):
        if is_delimiter(all_lines[index]):
            closing = index
            break
    if closing is None:
        raise FrontmatterFailure(
            "frontmatter-delimiters", "the frontmatter block is never closed by a second `---`"
        )
    yaml_lines = [line.rstrip("\r\n") for line in all_lines[1:closing]]
    try:
        root = Reader(yaml_lines).read_root()
    except YAMLError as error:
        raise FrontmatterFailure("unparseable-yaml", "the frontmatter does not parse: %s" % error)
    # `FrontmatterDocument.parse`'s own three cases: no node and an explicitly null block both read
    # as an empty mapping; anything else that is not a mapping is refused.
    if root is None:
        return {}
    if not isinstance(root, dict):
        raise FrontmatterFailure("frontmatter-not-a-mapping", "the frontmatter block is not a mapping")
    return root


# MARK: - Scalar resolution (Yams' Resolver.default and its constructors, transcribed)

# `Resolver.Rule.bool` / `.int` / `.float` / `.merge` / `.null` / `.timestamp` / `.value`, in the order
# `Resolver.default` consults them. A plain scalar takes the first tag whose pattern matches; a quoted
# scalar is always a string (libYAML marks it `quoted_implicit`, and Yams reads that as `!!str`).
RESOLVER_RULES = (
    ("bool", re.compile(r"^(?:yes|Yes|YES|no|No|NO|true|True|TRUE|false|False|FALSE|on|On|ON|off|Off|OFF)$")),
    (
        "int",
        re.compile(
            r"^(?:[-+]?0b[0-1_]+"
            r"|[-+]?0o?[0-7_]+"
            r"|[-+]?(?:0|[1-9][0-9_]*)"
            r"|[-+]?0x[0-9a-fA-F_]+"
            r"|[-+]?[1-9][0-9_]*(?::[0-5]?[0-9])+)$"
        ),
    ),
    (
        "float",
        re.compile(
            r"^(?:[-+]?(?:[0-9][0-9_]*)(?:\.[0-9_]*)?(?:[eE][-+]?[0-9]+)?"
            r"|\.[0-9_]+(?:[eE][-+][0-9]+)?"
            r"|[-+]?[0-9][0-9_]*(?::[0-5]?[0-9])+\.[0-9_]*"
            r"|[-+]?\.(?:inf|Inf|INF)"
            r"|\.(?:nan|NaN|NAN))$"
        ),
    ),
    ("merge", re.compile(r"^(?:<<)$")),
    ("null", re.compile(r"^(?:~|null|Null|NULL|)$")),
    (
        "timestamp",
        re.compile(
            r"^(?:[0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9]"
            r"|[0-9][0-9][0-9][0-9]-[0-9][0-9]?-[0-9][0-9]?"
            r"(?:[Tt]|[ \t]+)[0-9][0-9]?"
            r":[0-9][0-9]:[0-9][0-9](?:\.[0-9]*)?"
            r"(?:[ \t]*(?:Z|[-+][0-9][0-9]?(?::[0-9][0-9])?))?)$"
        ),
    ),
    ("value", re.compile(r"^(?:=)$")),
)


def resolve_tag(text):
    for tag, pattern in RESOLVER_RULES:
        if pattern.search(text):
            return tag
    return "str"


def sexagesimal(text, create):
    """Yams' `String.sexagesimal()`: `1:30` is ninety, each `:`-separated part a base-60 digit."""
    negative = text.startswith("-")
    if negative or text.startswith("+"):
        text = text[1:]
    total = create("0")
    for part in text.split(":"):
        digit = create(part)
        if digit is None:
            return None
        total = total * 60 + digit
    return -total if negative else total


def construct_int(text):
    """`Int.construct(from:)` (Constructor.swift, `private_construct`): underscores dropped, a sign,
    the `0x` / `0b` / `0o` / leading-`0` radix prefixes, sexagesimal on a `:`."""
    scalar_with_sign = text.replace("_", "")
    if scalar_with_sign == "0":
        return 0
    negative = scalar_with_sign.startswith("-")
    has_sign = negative or scalar_with_sign.startswith("+")
    sign = "-" if negative else ""
    scalar = scalar_with_sign[1:] if has_sign else scalar_with_sign
    for prefix, radix in (("0x", 16), ("0b", 2), ("0o", 8), ("0", 8)):
        if scalar.startswith(prefix):
            try:
                return int(sign + scalar[len(prefix):], radix)
            except ValueError:
                return None
    if ":" in scalar:
        return sexagesimal(scalar_with_sign, lambda part: _int_or_none(part))
    return _int_or_none(scalar_with_sign)


def _int_or_none(text):
    if not text or not re.match(r"^[-+]?[0-9]+$", text):
        return None
    return int(text)


def _float_or_none(text):
    if not text or not re.match(r"^[-+]?(?:[0-9]+\.?[0-9]*|\.[0-9]+)(?:[eE][-+]?[0-9]+)?$", text):
        return None
    try:
        return float(text)
    except ValueError:
        return None


def construct_double(text):
    """`Double.construct(from:)` (Constructor.swift): the three non-finite spellings, underscores
    dropped, sexagesimal on a `:`, else the plain decimal reading."""
    lowered = text.lower()
    if lowered in (".inf", "+.inf"):
        return math.inf
    if lowered == "-.inf":
        return -math.inf
    if lowered == ".nan":
        return math.nan
    stripped = text.replace("_", "")
    if ":" in stripped:
        return sexagesimal(stripped, _float_or_none)
    return _float_or_none(stripped)


def construct_bool(text):
    """`Bool.construct(from:)`: the lowercased word, three spellings each way."""
    lowered = text.lower()
    if lowered in ("true", "yes", "on"):
        return True
    if lowered in ("false", "no", "off"):
        return False
    return None


def project_plain_scalar(text):
    """**A scalar, by its resolved tag — and the one rule the whole dialect question turns on**
    (`Frontmatter.project(scalar:tag:)`).

    `YAMLValue` constructs a `Date` for a timestamp-tagged scalar. This projects its SOURCE TEXT
    instead: a bare `2026-08-25` names a calendar day and an instant is a different value, a
    distinction a `Date` round-trip destroys, and the emitted `timestamp` definition is a
    `type: string` with Yams' own pattern on it precisely so this side hands it a string.

    Every other case is the app's, clause for clause: a tag whose value will not construct falls
    back to the scalar's text rather than to a failure.
    """
    tag = resolve_tag(text)
    if tag == "null":
        return None
    if tag == "bool":
        value = construct_bool(text)
        return text if value is None else value
    if tag == "int":
        value = construct_int(text)
        if value is not None:
            return value
        value = construct_double(text)
        return text if value is None else value
    if tag == "float":
        value = construct_double(text)
        if value is None or not math.isfinite(value):
            # JSON has no way to write a non-finite number and the app has no use for one, so the
            # source text is the honest projection rather than a number the instance cannot hold.
            return text
        return value
    # `timestamp` projects as its source text; `str`, `merge` and `value` are text already.
    return text


# MARK: - The YAML-subset reader

# What a plain scalar may not begin with (YAML's indicator characters). A value opening with one of
# these was written as something other than a bare sentence, and the ones this reader does not
# read are refused by name rather than read as text.
PLAIN_FORBIDDEN_START = set('-?:,[]{}#&*!|>\'"%@`')

# Double-quoted escapes, `\x`, `\u` and `\U` handled separately.
DOUBLE_QUOTED_ESCAPES = {
    "0": "\0", "a": "\a", "b": "\b", "t": "\t", "\t": "\t", "n": "\n", "v": "\v", "f": "\f",
    "r": "\r", "e": "\x1b", " ": " ", '"': '"', "/": "/", "\\": "\\", "N": "\u0085",
    "_": "\u00a0", "L": "\u2028", "P": "\u2029",
}


def indent_of(line):
    count = 0
    for char in line:
        if char == " ":
            count += 1
        elif char == "\t":
            raise YAMLError("a tab is not indentation")
        else:
            break
    return count


def is_blank_or_comment(line):
    stripped = line.strip()
    return stripped == "" or stripped.startswith("#")


class Reader:
    """Reads the five constructs the app writes — `key: scalar`, flow mappings, flow sequences,
    block mappings, block sequences — plus plain-scalar line folding and quoted scalars.

    The block structure is read line by line by indentation; a flow collection or a quoted scalar
    that runs past its line is read from the joined text of the lines it spans. Duplicate keys are
    refused everywhere except the top level, where the last occurrence wins — the app's own
    tolerance (`FrontmatterDocument.parse`: "Duplicate top-level keys: last one wins"), and only
    there.
    """

    def __init__(self, lines):
        self.lines = lines
        self.index = 0

    # -- Lines

    def next_content(self):
        """The index of the next line that is neither blank nor a comment, or None."""
        index = self.index
        while index < len(self.lines):
            if not is_blank_or_comment(self.lines[index]):
                return index
            index += 1
        return None

    def read_root(self):
        index = self.next_content()
        if index is None:
            return None
        root = self.read_node(0, top_level=True)
        trailing = self.next_content()
        if trailing is not None:
            raise YAMLError("line %d: unexpected content `%s`" % (trailing + 1, self.lines[trailing].strip()))
        return root

    def read_node(self, min_indent, top_level=False):
        """The node starting at the next content line, which must sit at `min_indent` or deeper."""
        index = self.next_content()
        if index is None:
            return None
        line = self.lines[index]
        indent = indent_of(line)
        if indent < min_indent:
            return None
        text = line[indent:]
        if is_sequence_entry(text):
            return self.read_block_sequence(indent)
        if key_span(text) is not None:
            return self.read_block_mapping(indent, top_level)
        self.index = index + 1
        return self.read_inline_value(indent, text, indent - 1)

    # -- Block mappings and sequences

    def read_block_mapping(self, indent, top_level=False):
        ordered = []
        seen = {}
        while True:
            index = self.next_content()
            if index is None:
                break
            line = self.lines[index]
            line_indent = indent_of(line)
            if line_indent < indent:
                break
            if line_indent > indent:
                raise YAMLError("line %d: unexpected indentation" % (index + 1))
            text = line[indent:]
            span = key_span(text)
            if span is None:
                raise YAMLError("line %d: expected a `key:` line, found `%s`" % (index + 1, text))
            key, rest = span
            self.index = index + 1
            if rest.strip() == "" or rest.lstrip().startswith("#"):
                value = self.read_nested_value(indent)
            else:
                value = self.read_inline_value(indent, rest.lstrip(), indent)
            if key in seen:
                if not top_level:
                    raise YAMLError("line %d: duplicate key `%s` inside a nested mapping" % (index + 1, key))
                # **The top-level mapping, last-wins** (`Frontmatter.project(topLevel:)`): one entry per
                # distinct key, carrying the LAST occurrence's value and sitting where that occurrence sits.
                ordered = [pair for pair in ordered if pair[0] != key]
            seen[key] = True
            ordered.append((key, value))
        result = {}
        for key, value in ordered:
            result[key] = value
        return result

    def read_block_sequence(self, indent):
        items = []
        while True:
            index = self.next_content()
            if index is None:
                break
            line = self.lines[index]
            line_indent = indent_of(line)
            if line_indent < indent:
                break
            if line_indent > indent:
                raise YAMLError("line %d: unexpected indentation" % (index + 1))
            text = line[indent:]
            if not is_sequence_entry(text):
                raise YAMLError("line %d: expected a `- ` entry, found `%s`" % (index + 1, text))
            rest = text[1:]
            stripped = rest.lstrip()
            if stripped == "" or stripped.startswith("#"):
                self.index = index + 1
                items.append(self.read_nested_value(indent, same_indent_sequence=False))
                continue
            offset = 1 + (len(rest) - len(stripped))
            column = indent + offset
            if is_sequence_entry(stripped) or key_span(stripped) is not None:
                # `- key: value` opens a block mapping (and `- - x` a sequence) whose indentation is
                # the column the content starts at: the line is re-read as if it began there.
                self.lines[index] = " " * column + stripped
                self.index = index
                items.append(self.read_node(column))
                continue
            self.index = index + 1
            items.append(self.read_inline_value(column, stripped, indent))
        return items

    def read_nested_value(self, owner_indent, same_indent_sequence=True):
        """The value of a `key:` or `-` whose content sits on the following lines, or null."""
        index = self.next_content()
        if index is None:
            return None
        line = self.lines[index]
        line_indent = indent_of(line)
        if line_indent > owner_indent:
            return self.read_node(line_indent)
        # A block sequence may sit at the SAME indentation as the key it is the value of — but a
        # `- ` at a sequence's own indentation is that sequence's next item, never a nested one.
        if same_indent_sequence and line_indent == owner_indent and is_sequence_entry(line[line_indent:]):
            return self.read_block_sequence(line_indent)
        return None

    # -- Inline values: the text after `key: ` or `- `

    def read_inline_value(self, column, text, owner_indent):
        """A value that begins on the current line at `column`; `self.index` is the line after it.

        `owner_indent` is the indentation of the mapping or sequence the value belongs to — a plain
        scalar's continuation lines must be indented deeper than that.
        """
        first = text[0]
        if first in "[{":
            return self.read_flow(text, column)
        if first in "\"'":
            return self.read_quoted(text, column)
        if first in "|>":
            raise YAMLError("a block scalar (`%s`) is outside the dialect this script reads; run scripts/validate-schema.sh" % first)
        if first in "&*!":
            raise YAMLError("an anchor, alias or tag (`%s`) is outside the dialect this script reads; run scripts/validate-schema.sh" % first)
        if first in "%@`":
            raise YAMLError("a value may not begin with `%s`" % first)
        if first == "?":
            raise YAMLError("a complex key (`? `) is outside the dialect this script reads")
        if is_sequence_entry(text):
            raise YAMLError("block sequence entries are not allowed in this context")
        return self.read_plain(text, owner_indent)

    def read_plain(self, text, owner_indent):
        """A plain scalar, folded across the more-indented lines that follow it.

        Line folding is YAML's: each continuation line is joined with one space, and an empty line
        between two of them becomes a newline. A ` #` comment ends the scalar where libYAML ends it:
        the scan stops at the comment, so a more-indented line after one is not a continuation but
        an indentation error, left for the block reader to refuse ("unexpected indentation") — the
        reference's verdict on that shape. A `: ` inside the scalar is libYAML's "mapping values
        are not allowed in this context" — the shape the app rescues at write time and the reference
        validator refuses, so it is refused here too.
        """
        first, commented = split_inline_comment(text)
        pieces = [first]
        while not commented and self.index < len(self.lines):
            line = self.lines[self.index]
            if line.strip() == "":
                # A blank line inside a plain scalar folds to a newline, but only if a continuation
                # follows; trailing blank lines belong to nobody.
                probe = self.index + 1
                while probe < len(self.lines) and self.lines[probe].strip() == "":
                    probe += 1
                if probe < len(self.lines) and not is_blank_or_comment(self.lines[probe]) \
                        and indent_of(self.lines[probe]) > owner_indent:
                    pieces.append("\n" * (probe - self.index))
                    self.index = probe
                    continue
                break
            if line.lstrip().startswith("#"):
                break
            line_indent = indent_of(line)
            if line_indent <= owner_indent:
                break
            # libYAML's plain-scalar scan checks indentation and nothing else at a new line, so a
            # more-indented `- x` or `[x]` is text here, not a collection.
            piece, commented = split_inline_comment(line[line_indent:])
            pieces.append(piece)
            self.index += 1
        folded = fold_plain(pieces)
        if ": " in folded or folded.endswith(":") or "\t:" in folded:
            raise YAMLError("mapping values are not allowed in this context")
        return project_plain_scalar(folded)

    def joined_from(self, first_text, column):
        """The rest of the block from the current line's `column` on, as one string with `\\n`
        between lines — what a flow collection or a quoted scalar that spans lines is read from."""
        return first_text + "".join("\n" + line for line in self.lines[self.index:])

    def consume_lines(self, text, end):
        """Advances past the lines `text[:end]` spans, requiring the rest of the last one to be blank
        or a comment."""
        consumed = text.count("\n", 0, end)
        self.index += consumed
        last_line_end = text.find("\n", end)
        rest = text[end:] if last_line_end < 0 else text[end:last_line_end]
        stripped = rest.strip()
        if stripped and not stripped.startswith("#"):
            raise YAMLError("unexpected content after a value: `%s`" % stripped)

    def read_flow(self, text, column):
        joined = self.joined_from(text, column)
        scanner = FlowScanner(joined)
        value = scanner.read_collection()
        self.consume_lines(joined, scanner.position)
        return value

    def read_quoted(self, text, column):
        joined = self.joined_from(text, column)
        value, end = read_quoted_scalar(joined, 0)
        self.consume_lines(joined, end)
        return value


def is_sequence_entry(text):
    return text == "-" or text.startswith("- ")


def key_span(text):
    """The `(key, rest)` of a `key: rest` line, or None when the line does not open with a key.

    A key is a plain scalar or a quoted one, followed by `:` and a space or the end of the line.
    """
    if text[0] in "\"'":
        try:
            key, end = read_quoted_scalar(text, 0)
        except YAMLError:
            return None
        if end < len(text) and text[end] == ":" and (end + 1 == len(text) or text[end + 1] in " \t"):
            return key, text[end + 1:]
        return None
    if text[0] in PLAIN_FORBIDDEN_START and not (text[0] == "-" and not is_sequence_entry(text)):
        return None
    position = 0
    while True:
        colon = text.find(":", position)
        if colon < 0:
            return None
        if colon + 1 == len(text) or text[colon + 1] in " \t":
            key = text[:colon].rstrip()
            if key == "" or " #" in key:
                return None
            return key, text[colon + 1:]
        position = colon + 1


def split_inline_comment(text):
    """`(text, True)` with its ` #` comment removed, or `(text, False)` when it carries none; a `#`
    glued to text is text. The flag is for `read_plain`: a comment ends a plain scalar."""
    for index in range(len(text)):
        if text[index] == "#" and index > 0 and text[index - 1] in " \t":
            return text[:index].rstrip(), True
    return text.rstrip(), False


def fold_plain(pieces):
    """Joins the lines of a multi-line plain scalar the way YAML folds them: one space between two
    lines, and a run of n blank lines between them becoming n newlines and no space."""
    result = ""
    pending_space = False
    for piece in pieces:
        if piece.startswith("\n"):
            result += piece
            pending_space = False
            continue
        piece = piece.strip()
        if pending_space and piece:
            result += " "
        result += piece
        pending_space = True
    return result.strip()


def read_quoted_scalar(text, start):
    """A single- or double-quoted scalar beginning at `text[start]`, folded across lines the way
    YAML folds a quoted scalar: line breaks become one space, an empty line a newline, and in a
    double-quoted scalar an escaped line break joins with nothing. Returns `(value, end)`."""
    quote = text[start]
    position = start + 1
    pieces = []
    while True:
        if position >= len(text):
            raise YAMLError("found unexpected end of stream inside a quoted scalar")
        char = text[position]
        if char == quote:
            if quote == "'" and position + 1 < len(text) and text[position + 1] == "'":
                pieces.append("'")
                position += 2
                continue
            return "".join(pieces), position + 1
        if char == "\\" and quote == '"':
            position += 1
            if position >= len(text):
                raise YAMLError("found unexpected end of stream inside a quoted scalar")
            escaped = text[position]
            if escaped == "\n":
                # An escaped line break: the break and the next line's leading blanks vanish.
                position += 1
                while position < len(text) and text[position] in " \t":
                    position += 1
                continue
            if escaped in "xuU":
                width = {"x": 2, "u": 4, "U": 8}[escaped]
                digits = text[position + 1:position + 1 + width]
                if len(digits) != width or not re.match(r"^[0-9a-fA-F]+$", digits):
                    raise YAMLError("a `\\%s` escape needs %d hexadecimal digits" % (escaped, width))
                pieces.append(chr(int(digits, 16)))
                position += 1 + width
                continue
            if escaped not in DOUBLE_QUOTED_ESCAPES:
                raise YAMLError("found unknown escape character `\\%s`" % escaped)
            pieces.append(DOUBLE_QUOTED_ESCAPES[escaped])
            position += 1
            continue
        if char == "\n":
            # Folding: trailing blanks on this line and leading blanks on the next are dropped; one
            # break is a space, each further empty line a newline.
            while pieces and pieces[-1] in (" ", "\t"):
                pieces.pop()
            breaks = 0
            while position < len(text) and text[position] in "\n \t":
                if text[position] == "\n":
                    breaks += 1
                position += 1
            pieces.append(" " if breaks == 1 else "\n" * (breaks - 1))
            continue
        pieces.append(char)
        position += 1


class FlowScanner:
    """A flow mapping or sequence, read from one string — the joined lines it spans."""

    FLOW_INDICATORS = ",[]{}"

    def __init__(self, text):
        self.text = text
        self.position = 0

    def skip_space(self):
        while self.position < len(self.text):
            char = self.text[self.position]
            if char in " \t\n\r":
                self.position += 1
            elif char == "#" and (self.position == 0 or self.text[self.position - 1] in " \t\n\r"):
                end = self.text.find("\n", self.position)
                self.position = len(self.text) if end < 0 else end
            else:
                break

    def read_collection(self):
        self.skip_space()
        opener = self.text[self.position]
        if opener == "{":
            return self.read_mapping()
        if opener == "[":
            return self.read_sequence()
        raise YAMLError("expected a flow collection")

    def read_mapping(self):
        self.position += 1
        result = {}
        while True:
            self.skip_space()
            if self.position >= len(self.text):
                raise YAMLError("did not find expected `}`")
            if self.text[self.position] == "}":
                self.position += 1
                return result
            key, explicit = self.read_key()
            self.skip_space()
            if explicit:
                if self.position < len(self.text) and self.text[self.position] in ",}":
                    value = None
                else:
                    value = self.read_value()
            else:
                value = None
            if key in result:
                raise YAMLError("duplicate key `%s` inside a flow mapping" % key)
            result[key] = value
            self.skip_space()
            if self.position < len(self.text) and self.text[self.position] == ",":
                self.position += 1
            elif self.position < len(self.text) and self.text[self.position] == "}":
                continue
            else:
                raise YAMLError("did not find expected `,` or `}`")

    def read_sequence(self):
        self.position += 1
        items = []
        while True:
            self.skip_space()
            if self.position >= len(self.text):
                raise YAMLError("did not find expected `,` or `]`")
            if self.text[self.position] == "]":
                self.position += 1
                return items
            items.append(self.read_value())
            self.skip_space()
            if self.position < len(self.text) and self.text[self.position] == ",":
                self.position += 1
            elif self.position < len(self.text) and self.text[self.position] == "]":
                continue
            else:
                raise YAMLError("did not find expected `,` or `]`")

    def read_key(self):
        """A flow mapping key and whether a `:` followed it. Returns the key's text — a scalar key
        reads as its text whatever it would resolve to, `Node.string`'s own reading."""
        char = self.text[self.position]
        if char == "?":
            raise YAMLError("a complex key (`? `) is outside the dialect this script reads")
        if char in "\"'":
            key, end = read_quoted_scalar(self.text, self.position)
            self.position = end
        elif char in "[{":
            raise YAMLError("a collection is not a key this script reads")
        else:
            key = self.read_plain_text()
        self.skip_space()
        if self.position < len(self.text) and self.text[self.position] == ":":
            self.position += 1
            return key, True
        return key, False

    def read_value(self):
        self.skip_space()
        if self.position >= len(self.text):
            raise YAMLError("found unexpected end of stream inside a flow collection")
        char = self.text[self.position]
        if char in "[{":
            return self.read_collection()
        if char in "\"'":
            value, end = read_quoted_scalar(self.text, self.position)
            self.position = end
            return value
        if char in "|>":
            raise YAMLError("a block scalar is not allowed inside a flow collection")
        if char in "&*!":
            raise YAMLError("an anchor, alias or tag (`%s`) is outside the dialect this script reads; run scripts/validate-schema.sh" % char)
        if char in "%@`?":
            raise YAMLError("a value may not begin with `%s`" % char)
        if char in "]}":
            raise YAMLError("expected a value before `%s`" % char)
        text = self.read_plain_text()
        return project_plain_scalar(text)

    def read_plain_text(self):
        """A plain scalar in flow context: it ends at a flow indicator, at a `:` followed by a blank
        or an indicator, or at a ` #` comment; line breaks inside it fold to one space."""
        start = self.position
        while self.position < len(self.text):
            char = self.text[self.position]
            if char in self.FLOW_INDICATORS:
                break
            if char == ":" and (
                self.position + 1 == len(self.text) or self.text[self.position + 1] in " \t\n\r,[]{}"
            ):
                break
            if char == "#" and self.position > start and self.text[self.position - 1] in " \t\n\r":
                break
            self.position += 1
        raw = self.text[start:self.position]
        if raw.strip() == "":
            raise YAMLError("expected a plain scalar")
        lines = [line.strip() for line in raw.split("\n")]
        return fold_plain([line if line else "\n" for line in lines]) if len(lines) > 1 else raw.strip()


# MARK: - The schema set

# Every keyword this script implements. A set carrying an assertion or applicator outside this list is
# refused on load: silently ignoring `required` or `const` would be a validator that passes documents
# the reference refuses, which is the one failure a second implementation must never have.
IMPLEMENTED_KEYWORDS = frozenset(
    ["$ref", "type", "additionalProperties", "anyOf", "items", "pattern", "enum", "not", "properties"]
)
ANNOTATION_KEYWORDS = frozenset(
    ["$schema", "$id", "$defs", "title", "description", "deprecated", "$comment", "default", "examples",
     "readOnly", "writeOnly"]
)
# Where a keyword's value is a map of NAMES to schemas rather than a schema or a keyword.
NAMED_SCHEMA_MAPS = frozenset(["properties", "$defs", "patternProperties", "dependentSchemas"])
SCHEMA_LISTS = frozenset(["anyOf", "oneOf", "allOf", "prefixItems"])
SINGLE_SCHEMAS = frozenset(
    ["items", "not", "additionalProperties", "if", "then", "else", "contains", "propertyNames",
     "unevaluatedItems", "unevaluatedProperties"]
)


class SchemaSet:
    """The seven emitted files, loaded once and validated against many times (`SchemaSet.swift`).

    Every file carries an absolute `$id` — `lanework:///schema/1/<file>` — and every cross-file
    reference is spelled `common.json#/$defs/<name>`, resolved against that `$id` rather than against
    the file's location on disk. So the whole set is registered in one table keyed by `$id`, and
    NOTHING is ever fetched: a reference that does not resolve inside the loaded set is a load
    failure rather than a lookup anywhere else.
    """

    def __init__(self, directory):
        self.directory = directory
        self.by_id = {}
        self.by_filename = {}
        self.filename_by_id = {}
        filenames = [SCHEMA_FILENAMES[kind] for kind in KINDS] + [COMMON_FILENAME]
        for filename in filenames:
            path = os.path.join(directory, filename)
            try:
                with open(path, "rb") as handle:
                    document = json.loads(handle.read().decode("utf-8"))
            except OSError:
                raise UsageError("the schema set at %s is missing %s" % (directory, filename))
            except (UnicodeDecodeError, ValueError) as error:
                raise UsageError("%s could not be read as JSON: %s" % (filename, error))
            identifier = document.get("$id") if isinstance(document, dict) else None
            if not isinstance(identifier, str):
                raise UsageError("%s carries no $id, so its cross-file references cannot resolve" % filename)
            self.by_id[identifier] = document
            self.by_filename[filename] = document
            self.filename_by_id[identifier] = filename
        unsupported = []
        for filename in filenames:
            self.collect_unsupported(self.by_filename[filename], filename + "#", unsupported)
        if unsupported:
            raise UsageError(
                "the schema set uses %s, which this script does not implement — run scripts/validate-schema.sh"
                % ", ".join("`%s` at %s" % (keyword, where) for keyword, where in unsupported)
            )

    def collect_unsupported(self, node, pointer, found):
        if isinstance(node, list):
            for index, child in enumerate(node):
                self.collect_unsupported(child, "%s/%d" % (pointer, index), found)
            return
        if not isinstance(node, dict):
            return
        for keyword, value in node.items():
            child_pointer = "%s/%s" % (pointer, escape_pointer(keyword))
            if keyword in NAMED_SCHEMA_MAPS:
                if isinstance(value, dict):
                    for name, child in value.items():
                        self.collect_unsupported(child, "%s/%s" % (child_pointer, escape_pointer(name)), found)
            elif keyword in SCHEMA_LISTS:
                self.collect_unsupported(value, child_pointer, found)
            elif keyword in SINGLE_SCHEMAS:
                self.collect_unsupported(value, child_pointer, found)
            if keyword in IMPLEMENTED_KEYWORDS or keyword in ANNOTATION_KEYWORDS:
                continue
            found.append((keyword, child_pointer))

    def schema_for(self, kind):
        filename = SCHEMA_FILENAMES[kind]
        return self.by_filename[filename], self.by_filename[filename]["$id"]

    def resolve(self, ref, base_id):
        """`common.json#/$defs/x` against a document's `$id`, or `#/$defs/x` inside one."""
        uri, _, fragment = ref.partition("#")
        if uri == "":
            target_id = base_id
        elif re.match(r"^[A-Za-z][A-Za-z0-9+.-]*:", uri):
            target_id = uri
        else:
            target_id = base_id[:base_id.rfind("/") + 1] + uri
        document = self.by_id.get(target_id)
        if document is None:
            raise UsageError("`%s` names %s, which is not in the schema set" % (ref, target_id))
        node = document
        if fragment:
            for segment in fragment.lstrip("/").split("/"):
                segment = segment.replace("~1", "/").replace("~0", "~")
                if isinstance(node, list):
                    node = node[int(segment)]
                elif isinstance(node, dict) and segment in node:
                    node = node[segment]
                else:
                    raise UsageError("`%s` names nothing in the schema set" % ref)
        return node, target_id, "%s#%s" % (self.filename_by_id[target_id], fragment)


def escape_pointer(segment):
    return segment.replace("~", "~0").replace("/", "~1")


class UsageError(Exception):
    pass


# MARK: - Validation: the eight assertion keywords, and the deprecated walk


def json_type(value):
    if value is None:
        return "null"
    if isinstance(value, bool):
        return "boolean"
    if isinstance(value, int):
        return "integer"
    if isinstance(value, float):
        return "number"
    if isinstance(value, str):
        return "string"
    if isinstance(value, list):
        return "array"
    return "object"


def type_matches(allowed, value):
    """`JSONType.matches(instanceType:)`: exact, or `number` admitting an integer."""
    actual = json_type(value)
    if allowed == actual:
        return True
    return allowed == "number" and actual == "integer"


def json_equal(left, right):
    """Equality that keeps `true` and `1` apart, which Python's `==` does not."""
    if json_type(left) != json_type(right):
        return False
    if isinstance(left, list):
        return len(left) == len(right) and all(json_equal(a, b) for a, b in zip(left, right))
    if isinstance(left, dict):
        return left.keys() == right.keys() and all(json_equal(left[key], right[key]) for key in left)
    return left == right


def describe(value):
    text = json.dumps(value, ensure_ascii=False)
    return text if len(text) <= 80 else text[:77] + "..."


class Complaint:
    """One schema failure, reduced to the four things a finding line needs — the leaf keyword, where it
    lives in the schema (relative, through every `$ref` it was reached by), where the value sits in
    the document, and why."""

    def __init__(self, keyword, keyword_location, instance_location, message):
        self.keyword = keyword
        self.keyword_location = keyword_location
        self.instance_location = instance_location
        self.message = message


class DeprecatedMatch:
    """A `deprecated: true` node the instance SATISFIED — the retired branch it was written in."""

    def __init__(self, keyword_location, instance_location, absolute, description):
        self.keyword_location = keyword_location
        self.instance_location = instance_location
        self.absolute = absolute
        self.description = description


class Outcome:
    def __init__(self):
        self.complaints = []
        self.deprecated = []


def pointer(segments):
    return "#/" + "/".join(escape_pointer(str(segment)) for segment in segments) if segments else "#"


class Validator:
    def __init__(self, schemas):
        self.schemas = schemas

    def validate(self, instance, kind):
        """One document against the file its kind selects. Returns the leaf complaints and the
        deprecated branches the document matched."""
        outcome = Outcome()
        schema, base_id = self.schemas.schema_for(kind)
        absolute = SCHEMA_FILENAMES[kind] + "#"
        self.check(schema, base_id, absolute, instance, [], [], outcome)
        return outcome

    def check(self, schema, base_id, absolute, instance, kloc, iloc, outcome):
        """Validates `instance` against `schema`, appending complaints and deprecated matches to
        `outcome`; returns whether the instance is valid here. `kloc` and `iloc` are the segments of
        the keyword and instance locations; `absolute` is the schema node's own `<file>#<pointer>`.

        A node carrying `deprecated: true` that the instance satisfies is recorded once the whole
        node has been checked — so a property whose retired value fails its own pattern is a FAIL
        and not a DEPRECATED, and an `anyOf` names exactly the branch that matched.
        """
        if schema is True or schema == {}:
            return True
        if schema is False:
            outcome.complaints.append(
                Complaint("false", pointer(kloc), pointer(iloc), "the schema `false` accepts nothing"))
            return False
        before = len(outcome.complaints)

        ref = schema.get("$ref")
        if isinstance(ref, str):
            target, target_id, target_absolute = self.schemas.resolve(ref, base_id)
            self.check(target, target_id, target_absolute, instance, kloc + ["$ref"], iloc, outcome)

        allowed = schema.get("type")
        if allowed is not None:
            options = allowed if isinstance(allowed, list) else [allowed]
            if not any(type_matches(option, instance) for option in options):
                wanted = "[%s]" % ", ".join(options)
                outcome.complaints.append(
                    Complaint("type", pointer(kloc + ["type"]), pointer(iloc),
                              "Expected type '%s' but found '%s'" % (wanted, json_type(instance))))

        allowed_values = schema.get("enum")
        if isinstance(allowed_values, list):
            if not any(json_equal(instance, option) for option in allowed_values):
                outcome.complaints.append(
                    Complaint("enum", pointer(kloc + ["enum"]), pointer(iloc),
                              "Value %s is not one of the allowed values" % describe(instance)))

        regex = schema.get("pattern")
        if isinstance(regex, str) and isinstance(instance, str):
            if not pattern_matches(regex, instance):
                outcome.complaints.append(
                    Complaint("pattern", pointer(kloc + ["pattern"]), pointer(iloc),
                              "String %s does not match pattern '%s'" % (describe(instance), regex)))

        properties = schema.get("properties")
        if isinstance(properties, dict) and isinstance(instance, dict):
            for name, subschema in properties.items():
                if name in instance:
                    self.check(subschema, base_id, "%s/properties/%s" % (absolute, escape_pointer(name)),
                               instance[name], kloc + ["properties", name], iloc + [name], outcome)

        additional = schema.get("additionalProperties")
        if additional is not None and additional is not True and isinstance(instance, dict):
            known = properties if isinstance(properties, dict) else {}
            for name, value in instance.items():
                if name in known:
                    continue
                if additional is False:
                    outcome.complaints.append(
                        Complaint("additionalProperties", pointer(kloc + ["additionalProperties"]),
                                  pointer(iloc + [name]), "the key `%s` is not declared here" % name))
                else:
                    self.check(additional, base_id, absolute + "/additionalProperties", value,
                               kloc + ["additionalProperties"], iloc + [name], outcome)

        items = schema.get("items")
        if items is not None and isinstance(instance, list):
            for index, element in enumerate(instance):
                self.check(items, base_id, absolute + "/items", element,
                           kloc + ["items"], iloc + [index], outcome)

        branches = schema.get("anyOf")
        if isinstance(branches, list):
            # **The composition keywords are where descent stops** (`SchemaSet.leaves`): a value that
            # matched no branch is one finding at the `anyOf` node itself, not one line per branch.
            # Every branch is still walked, because the deprecated walk needs the retired one's
            # answer even when the canonical one already said yes.
            matched = False
            for index, branch in enumerate(branches):
                trial = Outcome()
                valid = self.check(branch, base_id, "%s/anyOf/%d" % (absolute, index), instance,
                                   kloc + ["anyOf", index], iloc, trial)
                if valid:
                    matched = True
                    outcome.deprecated.extend(trial.deprecated)
            if not matched:
                outcome.complaints.append(
                    Complaint("anyOf", pointer(kloc + ["anyOf"]), pointer(iloc),
                              "no branch of `anyOf` accepts a value of type `%s`" % json_type(instance)))

        forbidden = schema.get("not")
        if forbidden is not None:
            trial = Outcome()
            if self.check(forbidden, base_id, absolute + "/not", instance, kloc + ["not"], iloc, trial):
                outcome.complaints.append(
                    Complaint("not", pointer(kloc + ["not"]), pointer(iloc),
                              "a value of type `%s` is forbidden here" % json_type(instance)))

        valid = len(outcome.complaints) == before
        if valid and schema.get("deprecated") is True:
            outcome.deprecated.append(
                DeprecatedMatch(pointer(kloc), pointer(iloc), absolute,
                                schema.get("description") or "a retired spelling"))
        return valid


_PATTERN_CACHE = {}


def pattern_matches(regex, text):
    """`pattern` is a search, not a whole-string match — the reference library's `firstMatch` — and
    `$` is the end of the string only, never the position before a final line break, which is what
    the single-line title rule turns on."""
    compiled = _PATTERN_CACHE.get(regex)
    if compiled is None:
        compiled = re.compile(regex.replace("$", r"\Z") if regex.endswith("$") and not regex.endswith(r"\$") else regex)
        _PATTERN_CACHE[regex] = compiled
    return compiled.search(text) is not None


# MARK: - Findings and the report (Findings.swift)


def one_line(message):
    """One finding is one line, whatever the message arrived as."""
    return " ".join(part.strip() for part in message.splitlines() if part.strip())


class Finding:
    def __init__(self, path, keyword, locator, instance, message):
        self.path = path
        self.keyword = keyword
        self.locator = locator
        self.instance = instance
        self.message = message

    def line(self):
        return "FAIL %s: %s at %s (instance %s) — %s" % (
            self.path, self.keyword, self.locator, self.instance, one_line(self.message))


class Warning:
    """A dangling reference, printed and not failing: `hero` and `in-reply-to` are dangling-tolerant
    by ruling."""

    def __init__(self, path, keyword, message):
        self.path = path
        self.keyword = keyword
        self.message = message

    def line(self):
        return "WARN %s: %s — %s" % (self.path, self.keyword, one_line(self.message))


class Deprecation:
    """A retired spelling the document was written in — printed, counted, and not failing: the
    schema is lenient, and the line is the machine-readable "do not write this" made visible."""

    def __init__(self, path, match):
        self.path = path
        self.match = match

    def line(self):
        return "DEPRECATED %s: deprecated at %s (instance %s) — %s: %s" % (
            self.path, self.match.keyword_location, self.match.instance_location,
            self.match.absolute, one_line(self.match.description))


class Populations:
    def __init__(self):
        self.boards = 0
        self.documents_by_kind = {}
        self.stray_folders = 0
        self.indexless_identity_folders = 0
        self.symlinks_skipped = 0
        self.flat_attachments = 0

    def count(self, kind):
        self.documents_by_kind[kind] = self.documents_by_kind.get(kind, 0) + 1

    @property
    def documents(self):
        return sum(self.documents_by_kind.values())

    def kind_breakdown(self):
        return ", ".join("%s %d" % (kind, self.documents_by_kind.get(kind, 0)) for kind in KINDS)


class Report:
    def __init__(self):
        self.findings = []
        self.warnings = []
        self.deprecations = []
        self.populations = Populations()

    def failing_documents(self):
        return len(set(finding.path for finding in self.findings))

    def write_lines(self):
        for warning in sorted(self.warnings, key=lambda w: w.path):
            print(warning.line())
        for deprecation in sorted(self.deprecations, key=lambda d: (d.path, d.match.keyword_location)):
            print(deprecation.line())
        for finding in sorted(self.findings, key=lambda f: (f.path, f.locator)):
            print(finding.line())

    def write_summary(self, schema_directory):
        populations = self.populations
        print("")
        print("schema      %s (lenient)" % schema_directory)
        print("boards      %d" % populations.boards)
        print("documents   %d  —  %s" % (populations.documents, populations.kind_breakdown()))
        print(
            "skipped     strays %d, index-less identity folders %d, symlinks %d, retired flat attachments %d"
            % (populations.stray_folders, populations.indexless_identity_folders,
               populations.symlinks_skipped, populations.flat_attachments)
        )
        print("warnings    %d" % len(self.warnings))
        print("deprecated  %d" % len(self.deprecations))
        print("failures    %d over %d of %d documents"
              % (len(self.findings), self.failing_documents(), populations.documents))


# MARK: - One document


def validate_document(index_path, kind, is_board_root, display_path, validator, report, trusted=False):
    """Reads, projects, validates and structurally checks one `index.md` (`BoardWalk.validate`).
    Returns the projected value when it parsed, so a caller can read `hero` or `extension` off it.

    `trusted` is whether `kind` is taken as given rather than checked against position — true inside
    `.trash/`, where position deliberately cannot answer, and for a file named on the command line
    whose kind came from its own `kind` key.
    """
    report.populations.count(kind)
    try:
        document = read_document(index_path)
    except FrontmatterFailure as failure:
        report.findings.append(Finding(display_path, failure.keyword, "#/", "#/", failure.message))
        return None

    outcome = validator.validate(document, kind)
    for complaint in outcome.complaints:
        report.findings.append(Finding(display_path, complaint.keyword, complaint.keyword_location,
                                       complaint.instance_location, complaint.message))
    for match in outcome.deprecated:
        report.deprecations.append(Deprecation(display_path, match))

    check_schema_version(document, display_path, is_board_root, report)
    if not trusted:
        check_kind(document, kind, display_path, report)
    return document


def text_of(value):
    """The value as text when it has a text reading — the `lenient-text` family's own rule: any scalar
    reads as what the author typed, a sequence or a mapping has no reading at all."""
    if value is None or isinstance(value, (list, dict)):
        return None
    if isinstance(value, bool):
        return "true" if value else "false"
    return str(value)


def whole_number(value):
    """`schema`'s reading, which takes no coercion at all beyond an integral double."""
    if isinstance(value, bool):
        return None
    if isinstance(value, int):
        return value
    if isinstance(value, float) and math.isfinite(value) and value == int(value):
        return int(value)
    return None


def check_schema_version(document, path, is_board_root, report):
    """`schema`, the one key the root must carry (`BoardWalk.checkSchemaVersion`)."""
    raw = document.get("schema")
    present = "schema" in document and raw is not None
    if not present:
        if is_board_root:
            report.findings.append(Finding(path, "missing-schema", "#/schema", "#/schema",
                                           "a board root carries no schema — the this-really-is-a-board gate"))
        return
    value = whole_number(raw)
    if value is None:
        report.findings.append(Finding(path, "malformed-schema", "#/schema", "#/schema",
                                       "schema is present and has no integer reading, which is a claim the app cannot check"))
        return
    if value > SUPPORTED_SCHEMA:
        report.findings.append(Finding(path, "schema-newer-than-app", "#/schema", "#/schema",
                                       "schema %d is newer than the %d this app supports" % (value, SUPPORTED_SCHEMA)))


def check_kind(document, expected, path, report):
    """`kind` against depth (`BoardWalk.checkKind`): a missing `kind` is healable, never fatal, so only
    a value that DISAGREES is reported."""
    written = text_of(document.get("kind"))
    if not written or written == expected:
        return
    report.findings.append(Finding(path, "kind-placement", "#/kind", "#/kind",
                                   "kind is `%s` where this position says `%s`" % (written, expected)))


def check_blob_name(folder, index_display, document, report):
    """The `extension` key and the blob's name must agree (`BoardWalk.checkBlobName`)."""
    if document is None:
        return
    written = text_of(document.get("extension"))
    predicted = blob_name(written)
    if os.path.exists(os.path.join(folder, predicted)):
        return
    if written is None:
        message = "no extension key, so the file must be named exactly `blob`, and none is there"
    else:
        message = "extension `%s` predicts `%s`, which is not in the folder" % (written, predicted)
    report.findings.append(Finding(index_display, "attachment-extension", "#/extension", "#/extension", message))


# MARK: - The board walk (BoardWalk.swift, transcribed)


class BoardWalk:
    """One board, walked and validated. Depth defines meaning, so a folder's position picks the
    schema file its `index.md` is validated against, and everything the format tolerates is skipped
    and counted rather than reported."""

    def __init__(self, root, validator, display_root, report):
        self.root = root
        self.validator = validator
        self.display_root = display_root
        self.report = report
        self.identities = {}

    def run(self):
        self.report.populations.boards += 1
        index = os.path.join(self.root, INDEX_FILE)
        if not os.path.isfile(index):
            self.report.findings.append(Finding(self.display(self.root), "board-root-missing-index", "#/",
                                                INDEX_FILE, "a board root has no index.md, so nothing here is a board"))
            return
        self.validate(index, "board", is_board_root=True)
        for entry in self.children(self.root):
            name = os.path.basename(entry)
            if name.lower() == TRASH_FOLDER:
                self.walk_trash(entry)
                continue
            # `.schema/`, `.log/` and every other hidden entry are skipped by the same rule the loader
            # skips them with (`BoardLoader.directoryCandidates` and its `.skipsHiddenFiles`).
            if name.startswith("."):
                continue
            if not os.path.isdir(entry):
                continue
            if not is_identity_shaped(name):
                self.report.populations.stray_folders += 1
                continue
            self.walk_lane(entry)
        self.check_identities()

    def walk_lane(self, lane):
        self.register(lane)
        index = os.path.join(lane, INDEX_FILE)
        if os.path.isfile(index):
            self.validate(index, "lane")
        else:
            self.report.populations.indexless_identity_folders += 1
        for entry in self.children(lane):
            name = os.path.basename(entry)
            if name.startswith(".") or not os.path.isdir(entry):
                continue
            if not is_identity_shaped(name):
                self.report.populations.stray_folders += 1
                continue
            self.walk_card(entry)

    def walk_card(self, card):
        self.register(card)
        index = os.path.join(card, INDEX_FILE)
        document = None
        if os.path.isfile(index):
            document = self.validate(index, "card")
        else:
            self.report.populations.indexless_identity_folders += 1
        attachments = self.walk_attachments(os.path.join(card, ATTACHMENTS_FOLDER))
        self.walk_comments(card)
        # `hero` names one of that card's own attachments, and a dangling one warns.
        hero = text_of(document.get("hero")) if document else None
        if hero:
            if canonical_identity(hero) not in attachments:
                self.report.warnings.append(Warning(self.display(index), "hero",
                                                    "names %s, which is not one of this card's %d attachments" % (hero, len(attachments))))

    def walk_comments(self, card):
        folder = os.path.join(card, COMMENTS_FOLDER)
        if not os.path.isdir(folder):
            return set()
        identities = set()
        documents = []
        for entry in self.children(folder):
            name = os.path.basename(entry)
            if not os.path.isdir(entry):
                continue
            # `comments/.draft` is skipped, and that is a ruling rather than an oversight: it is the
            # app's unposted composer draft — half-typed by definition — and validating it would turn
            # "somebody has a card window open" into a board defect. `comments/.trash` skips with it.
            if name.startswith("."):
                continue
            if not is_identity_shaped(name):
                self.report.populations.stray_folders += 1
                continue
            identities.add(canonical_identity(name))
            index = os.path.join(entry, INDEX_FILE)
            if not os.path.isfile(index):
                self.report.populations.indexless_identity_folders += 1
                continue
            value = self.validate(index, "comment")
            documents.append((index, value))
            self.walk_attachments(os.path.join(entry, ATTACHMENTS_FOLDER))
        # `in-reply-to` names a sibling comment, and a dangling one warns.
        for index, value in documents:
            target = text_of(value.get("in-reply-to")) if value else None
            if not target or canonical_identity(target) in identities:
                continue
            self.report.warnings.append(Warning(self.display(index), "in-reply-to",
                                                "names %s, which is not one of the %d comments on this card" % (target, len(identities))))
        return identities

    def walk_attachments(self, folder):
        if not os.path.isdir(folder):
            return set()
        identities = set()
        for entry in self.children(folder):
            name = os.path.basename(entry)
            if name.startswith("."):
                continue
            if not os.path.isdir(entry):
                # A flat file directly in `attachments/` is the RETIRED layout: counted, never failed.
                self.report.populations.flat_attachments += 1
                continue
            if not is_identity_shaped(name):
                continue
            identities.add(canonical_identity(name))
            index = os.path.join(entry, INDEX_FILE)
            if not os.path.isfile(index):
                self.report.populations.indexless_identity_folders += 1
                continue
            value = self.validate(index, "attachment")
            check_blob_name(entry, self.display(index), value, self.report)
        return identities

    def walk_trash(self, trash):
        """`.trash/` is flat, and the `kind` value is the only discriminator in it."""
        if not os.path.isdir(trash):
            return
        for entry in self.children(trash):
            name = os.path.basename(entry)
            if name.startswith(".") or not os.path.isdir(entry):
                continue
            if not is_identity_shaped(name):
                self.report.populations.stray_folders += 1
                continue
            self.register(entry)
            index = os.path.join(entry, INDEX_FILE)
            if not os.path.isfile(index):
                self.report.populations.indexless_identity_folders += 1
                continue
            kind_value = None
            try:
                kind_value = text_of(read_document(index).get("kind"))
            except FrontmatterFailure:
                pass
            if kind_value is None:
                self.report.findings.append(Finding(self.display(index), "trash-kind", "#/kind", "#/kind",
                                                    "a trashed entry carries no kind, and the trash is flat — nothing else can tell a trashed lane from a card"))
            kind = trash_kind(kind_value, lambda: has_identity_shaped_child_index(entry))
            self.validate(index, kind, trusted=True)
            if kind == "lane":
                for child in self.children(entry):
                    child_name = os.path.basename(child)
                    if child_name.startswith(".") or not os.path.isdir(child) or not is_identity_shaped(child_name):
                        continue
                    self.walk_card(child)
            else:
                self.walk_attachments(os.path.join(entry, ATTACHMENTS_FOLDER))
                self.walk_comments(entry)

    def validate(self, index, kind, is_board_root=False, trusted=False):
        return validate_document(index, kind, is_board_root, self.display(index), self.validator,
                                 self.report, trusted)

    # -- Identity

    def register(self, folder):
        self.identities.setdefault(canonical_identity(os.path.basename(folder)), []).append(folder)

    def check_identities(self):
        """One identity per board, by UUID value — over lanes, cards and trash entries. A case twin
        warns, exactly as the loader's `caseTwinIgnored` does; two folders wearing the identical name
        are a genuine duplicate and fail."""
        for identity in sorted(self.identities):
            folders = self.identities[identity]
            if len(folders) < 2:
                continue
            spellings = set(os.path.basename(folder) for folder in folders)
            paths = ", ".join(sorted(self.display(folder) for folder in folders))
            if len(spellings) > 1:
                self.report.warnings.append(Warning(paths, "case-twin",
                                                    "%d folders spell one identity %s differently" % (len(folders), identity)))
            else:
                self.report.findings.append(Finding(paths, "duplicate-identity", "#/", identity,
                                                    "%d folders on this board claim the identity %s" % (len(folders), identity)))

    # -- Filesystem

    def children(self, directory):
        """The directory's entries, symlinks removed and counted — never followed, never resolved."""
        try:
            names = os.listdir(directory)
        except OSError:
            return []
        kept = []
        for name in sorted(names):
            path = os.path.join(directory, name)
            if os.path.islink(path):
                self.report.populations.symlinks_skipped += 1
                continue
            kept.append(path)
        return kept

    def display(self, path):
        return display_relative(path, self.display_root)


def trash_kind(kind_value, has_identity_shaped_child_index):
    """`IntegrityRules.trashKind`: the value is trusted outright — `lane` or `card` — and every other
    value, and no key at all, falls through to shape."""
    if kind_value == "lane":
        return "lane"
    if kind_value == "card":
        return "card"
    return "lane" if has_identity_shaped_child_index() else "card"


def has_identity_shaped_child_index(folder):
    try:
        names = os.listdir(folder)
    except OSError:
        return False
    return any(is_identity_shaped(name) and os.path.isfile(os.path.join(folder, name, INDEX_FILE)) for name in names)


def display_relative(path, root):
    path = os.path.normpath(path)
    base = os.path.normpath(root)
    if path.startswith(base + os.sep):
        return path[len(base) + 1:]
    return path


# MARK: - One file named on the command line: which schema, by position


def board_ancestor(path):
    """The first ancestor directory whose name ends `.lanework`, or None."""
    current = os.path.dirname(os.path.abspath(path))
    while True:
        if os.path.basename(current).endswith(BOARD_SUFFIX):
            return current
        parent = os.path.dirname(current)
        if parent == current:
            return None
        current = parent


def placement_of_file(path, board):
    """Where the file's folder sits inside its board, answered by the walk's own rules — the
    `comments/` and `attachments/` checks ahead of the shape ones, because a posted comment is an
    identity-shaped folder whose parent is not identity-shaped, shape-identical to a lane.

    Returns `(kind, is_board_root, trusted, rule)`, or None when position cannot answer.
    """
    folder = os.path.dirname(os.path.abspath(path))
    if os.path.normpath(folder) == os.path.normpath(board):
        return "board", True, False, "the board root"
    name = os.path.basename(folder)
    parent = os.path.dirname(folder)
    parent_name = os.path.basename(parent)
    if parent_name.lower() == ATTACHMENTS_FOLDER:
        return "attachment", False, False, "an `attachments/` entry"
    if parent_name.lower() == COMMENTS_FOLDER:
        return "comment", False, False, "a `comments/` entry"
    if parent_name.lower() == TRASH_FOLDER:
        kind_value = None
        try:
            kind_value = text_of(read_document(path).get("kind"))
        except FrontmatterFailure:
            pass
        kind = trash_kind(kind_value, lambda: has_identity_shaped_child_index(folder))
        return kind, False, True, "a `.trash/` entry, by its own `kind`" if kind_value in ("lane", "card") else "a `.trash/` entry, by shape"
    if is_identity_shaped(name):
        if os.path.normpath(parent) == os.path.normpath(board):
            return "lane", False, False, "depth 1 — a lane"
        if is_identity_shaped(parent_name):
            grandparent = os.path.dirname(parent)
            if os.path.normpath(grandparent) == os.path.normpath(board):
                return "card", False, False, "depth 2 — a card"
            if os.path.basename(grandparent).lower() == TRASH_FOLDER:
                return "card", False, False, "a card inside a trashed lane"
    return None


def validate_single_file(path, schema_directory, validator, verbose):
    """B1: a path naming a file validates that one document alone. Prints its finding lines and, when
    anything was printed or `-v` was given, the schema pick — a clean run is otherwise silent."""
    report = Report()
    board = board_ancestor(path)
    placement = placement_of_file(path, board) if board else None
    if placement is not None:
        kind, is_board_root, trusted, rule = placement
        display_root = os.path.dirname(board)
        how = "%s by position (%s in %s)" % (SCHEMA_FILENAMES[kind], rule, os.path.basename(board))
    else:
        try:
            kind_value = text_of(read_document(path).get("kind"))
        except FrontmatterFailure as failure:
            kind_value = None
            report.findings.append(Finding(path, failure.keyword, "#/", "#/", failure.message))
        if kind_value not in SCHEMA_FILENAMES:
            if not report.findings:
                raise UsageError(
                    "%s is not inside a board and carries no readable `kind` — name a file inside a `.lanework` folder, or give it a kind"
                    % path)
            report.write_lines()
            return 1
        kind, is_board_root, trusted = kind_value, kind_value == "board", True
        display_root = os.path.dirname(os.path.abspath(path))
        how = "%s by the file's own `kind` (not inside a board)" % SCHEMA_FILENAMES[kind]
    display_path = display_relative(os.path.abspath(path), display_root)
    document = validate_document(path, kind, is_board_root, display_path, validator, report, trusted)
    if kind == "attachment":
        check_blob_name(os.path.dirname(os.path.abspath(path)), display_path, document, report)
    report.write_lines()
    printed = report.findings or report.warnings or report.deprecations
    if printed or verbose:
        print("schema      %s (lenient) — %s" % (schema_directory, how))
    return 1 if report.findings else 0


# MARK: - Which boards


def boards_under(path):
    """A board is a directory whose name ends in `.lanework`; anything else named on the command line
    is a container searched one level down for them (`Options.boards(under:)`)."""
    if not os.path.exists(path):
        raise UsageError("no such path: %s" % path)
    if not os.path.isdir(path):
        raise UsageError("not a directory: %s" % path)
    if os.path.basename(os.path.abspath(path)).endswith(BOARD_SUFFIX):
        return [os.path.abspath(path)]
    try:
        names = os.listdir(path)
    except OSError:
        raise UsageError("cannot list: %s" % path)
    found = []
    for name in sorted(names):
        if name.startswith(".") or not name.endswith(BOARD_SUFFIX):
            continue
        full = os.path.join(os.path.abspath(path), name)
        if os.path.isdir(full):
            found.append(full)
    return found


def common_ancestor(paths):
    """The deepest directory every path shares, for readable relative paths in the report."""
    parents = [os.path.dirname(os.path.abspath(path)) for path in paths]
    if not parents:
        return os.getcwd()
    shared = parents[0].split(os.sep)
    for parent in parents[1:]:
        components = parent.split(os.sep)
        kept = []
        for left, right in zip(shared, components):
            if left != right:
                break
            kept.append(left)
        shared = kept
    return os.sep.join(shared) or os.sep


# MARK: - Entry point

USAGE = """usage: python3 lanework-validate.py [--schema <dir>] [-v] <path> [<path> ...]

  <path>   one index.md (validated alone, its schema picked by its position in its board),
           a `.lanework` board folder (walked whole), or a folder holding boards
  --schema <dir>   the schema set to read, instead of the folder this script lives in
  -v, --verbose    say which schema a clean single-file run used
  exit 0  every document validated (DEPRECATED and WARN lines may still print)
  exit 1  at least one document failed, each named on a FAIL line
  exit 2  a usage error, an unreadable schema set, or a population of zero documents"""


def default_schema_directory():
    """The `.schema/` folder this script lives in: `bin/`'s parent."""
    return os.path.dirname(os.path.dirname(os.path.realpath(__file__)))


def main(argv):
    schema_directory = None
    verbose = False
    paths = []
    index = 0
    while index < len(argv):
        argument = argv[index]
        if argument in ("-h", "--help"):
            print(USAGE)
            return 0
        if argument in ("-v", "--verbose"):
            verbose = True
        elif argument == "--schema":
            index += 1
            if index >= len(argv):
                return usage_failure("--schema needs a directory")
            schema_directory = argv[index]
        elif argument.startswith("-") and argument != "-":
            return usage_failure("unknown option %s" % argument)
        else:
            paths.append(argument)
        index += 1
    if not paths:
        return usage_failure("no paths given")

    try:
        schema_directory = os.path.abspath(schema_directory or default_schema_directory())
        if not os.path.isdir(schema_directory):
            raise UsageError("no schema set at %s — this script reads the .schema/ folder it lives in, or the one --schema names" % schema_directory)
        validator = Validator(SchemaSet(schema_directory))

        files = [path for path in paths if os.path.isfile(path)]
        directories = [path for path in paths if not os.path.isfile(path)]
        if files and directories:
            raise UsageError("name files or boards, not both in one run")
        if files:
            status = 0
            for path in files:
                status = max(status, validate_single_file(path, schema_directory, validator, verbose))
            return status

        boards = []
        for path in directories:
            for board in boards_under(path):
                if board not in boards:
                    boards.append(board)
        if not boards:
            raise UsageError("the paths named hold no board — a board is a directory whose name ends in `.lanework`")
        display_root = common_ancestor(boards)
        report = Report()
        for board in boards:
            BoardWalk(board, validator, display_root, report).run()
        # A population of zero is never a pass; a finding is not an empty population.
        if report.populations.documents == 0 and not report.findings:
            raise UsageError("validated 0 documents over %d board(s) — an empty population is never a pass" % len(boards))
        report.write_lines()
        report.write_summary(schema_directory)
        return 1 if report.findings else 0
    except UsageError as error:
        return usage_failure(str(error))


def usage_failure(message):
    sys.stderr.write("lanework-validate: %s\n" % message)
    return 2


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
