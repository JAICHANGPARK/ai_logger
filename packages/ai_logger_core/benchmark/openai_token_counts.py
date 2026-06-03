#!/usr/bin/env python3
"""Count real tokenizer tokens for raw errors and ai_logger report formats."""

from __future__ import annotations

import argparse
import hashlib
import importlib.metadata
import json
import platform
import statistics
import sys
from datetime import datetime, timezone
from pathlib import Path


DEFAULT_ENCODINGS = ("o200k_base", "cl100k_base")


def main() -> int:
    args = parse_args()
    try:
        import tiktoken
    except ImportError:
        print(
            "Missing dependency: tiktoken. Run with:\n"
            "  uv run --with tiktoken python benchmark/openai_token_counts.py",
            file=sys.stderr,
        )
        return 1

    input_text = args.input.read_text()
    data = json.loads(input_text)
    results = {
        "metadata": {
            "benchmark": "openai_token_counts",
            "generatedAt": datetime.now(timezone.utc).isoformat(),
            "fixtureType": data.get("metadata", {}).get("fixtureType"),
            "inputSha256": hashlib.sha256(input_text.encode()).hexdigest(),
            "pythonVersion": platform.python_version(),
            "tiktokenVersion": importlib.metadata.version("tiktoken"),
            "notes": [
                "Counts use tiktoken encodings for raw/report text only.",
                "Chat message wrapper overhead and model output tokens are not included.",
            ],
        },
        "input": str(args.input),
        "encodings": {},
    }

    for encoding_name in args.encodings:
        encoding = tiktoken.get_encoding(encoding_name)
        encoding_result = count_for_encoding(data["cases"], encoding)
        results["encodings"][encoding_name] = encoding_result

    args.json_output.parent.mkdir(parents=True, exist_ok=True)
    args.json_output.write_text(json.dumps(results, indent=2) + "\n")

    markdown = render_markdown(results)
    args.markdown_output.parent.mkdir(parents=True, exist_ok=True)
    args.markdown_output.write_text(markdown)

    print("openai_token_counts benchmark")
    for encoding_name, encoding_result in results["encodings"].items():
        print(encoding_name)
        for format_name, summary in encoding_result["summary"].items():
            print(
                f"  {format_name}: raw {summary['averageRawTokens']:.1f} "
                f"vs report {summary['averageReportTokens']:.1f} "
                f"({format_percent(summary['deltaPercent'])})"
            )
    print(f"wrote {args.markdown_output}")
    print(f"wrote {args.json_output}")
    return 0


def parse_args() -> argparse.Namespace:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument(
        "--input",
        type=Path,
        default=Path("../../docs/benchmarks/raw_vs_ai_report.json"),
    )
    parser.add_argument(
        "--markdown-output",
        type=Path,
        default=Path("../../docs/benchmarks/openai_token_counts.md"),
    )
    parser.add_argument(
        "--json-output",
        type=Path,
        default=Path("../../docs/benchmarks/openai_token_counts.json"),
    )
    parser.add_argument(
        "--encodings",
        nargs="+",
        default=list(DEFAULT_ENCODINGS),
        help="tiktoken encoding names to evaluate.",
    )
    return parser.parse_args()


def count_for_encoding(cases: list[dict], encoding) -> dict:
    case_results = []
    totals: dict[str, dict[str, int]] = {}

    for case in cases:
        raw_text = case["rawText"]
        raw_tokens = len(encoding.encode(raw_text))
        report_texts = case.get("aiLoggerReports") or {
            "markdown": case["aiLoggerReport"]
        }
        report_results = {}

        for format_name, report_text in report_texts.items():
            report_tokens = len(encoding.encode(report_text))
            report_results[format_name] = {
                "tokens": report_tokens,
                "deltaTokens": report_tokens - raw_tokens,
                "deltaPercent": percent_delta(raw_tokens, report_tokens),
            }
            totals.setdefault(
                format_name,
                {
                    "raw": 0,
                    "report": 0,
                    "cases": 0,
                    "rawValues": [],
                    "reportValues": [],
                },
            )
            totals[format_name]["raw"] += raw_tokens
            totals[format_name]["report"] += report_tokens
            totals[format_name]["cases"] += 1
            totals[format_name]["rawValues"].append(raw_tokens)
            totals[format_name]["reportValues"].append(report_tokens)

        case_results.append(
            {
                "name": case["name"],
                "rawTokens": raw_tokens,
                "reports": report_results,
            }
        )

    summary = {
        format_name: {
            "caseCount": values["cases"],
            "totalRawTokens": values["raw"],
            "totalReportTokens": values["report"],
            "totalDeltaTokens": values["report"] - values["raw"],
            "averageRawTokens": values["raw"] / values["cases"],
            "averageReportTokens": values["report"] / values["cases"],
            "medianRawTokens": statistics.median(values["rawValues"]),
            "medianReportTokens": statistics.median(values["reportValues"]),
            "minRawTokens": min(values["rawValues"]),
            "maxRawTokens": max(values["rawValues"]),
            "minReportTokens": min(values["reportValues"]),
            "maxReportTokens": max(values["reportValues"]),
            "deltaPercent": percent_delta(values["raw"], values["report"]),
        }
        for format_name, values in totals.items()
    }

    return {
        "summary": summary,
        "cases": case_results,
    }


def render_markdown(results: dict) -> str:
    lines = [
        "# OpenAI Tokenizer Counts",
        "",
        "Generated by `benchmark/openai_token_counts.py` from "
        f"`{Path(results['input']).name}`.",
        "",
        f"Input SHA-256: `{results['metadata']['inputSha256']}`",
        "",
        f"Python: `{results['metadata']['pythonVersion']}`; "
        f"tiktoken: `{results['metadata']['tiktokenVersion']}`.",
        "",
        "These are real `tiktoken` counts for the saved raw runtime errors and "
        "`ai_logger` report formats. Counts vary by tokenizer, so this report "
        "includes both `o200k_base` and `cl100k_base` by default. Chat wrapper "
        "overhead and model output tokens are not included.",
        "",
        "## Summary",
        "",
        "| Encoding | ai_logger format | Avg raw tokens | Avg report tokens | Delta | Total delta |",
        "|---|---|---:|---:|---:|---:|",
    ]

    for encoding_name, encoding_result in results["encodings"].items():
        for format_name, summary in encoding_result["summary"].items():
            lines.append(
                f"| {encoding_name} | {format_name} "
                f"| {summary['averageRawTokens']:.1f} "
                f"| {summary['averageReportTokens']:.1f} "
                f"| {format_percent(summary['deltaPercent'])} "
                f"| {summary['totalDeltaTokens']:+d} |"
            )

    for encoding_name, encoding_result in results["encodings"].items():
        lines.extend(
            [
                "",
                f"## {encoding_name} Case Results",
                "",
                "| Case | Raw | Markdown | Diagnostic | Compact JSON |",
                "|---|---:|---:|---:|---:|",
            ]
        )
        for case in encoding_result["cases"]:
            reports = case["reports"]
            lines.append(
                f"| {case['name']} "
                f"| {case['rawTokens']} "
                f"| {token_cell(reports, 'markdown')} "
                f"| {token_cell(reports, 'diagnostic')} "
                f"| {token_cell(reports, 'compactJson')} |"
            )

    lines.extend(
        [
            "",
            "## Reading The Results",
            "",
            "Markdown carries the richest copy-paste context, so its token savings "
            "depend on how verbose the raw input is. Diagnostic output is the "
            "token-efficient format: it keeps the stable error kind, primary "
            "file/line, source pointer when available, and fix hint while "
            "dropping most headings and prose.",
            "",
        ]
    )
    return "\n".join(lines)


def token_cell(reports: dict, format_name: str) -> str:
    report = reports.get(format_name)
    if report is None:
        return "n/a"
    return f"{report['tokens']} ({format_percent(report['deltaPercent'])})"


def percent_delta(old: int, new: int) -> float:
    if old == 0:
        return 0.0
    return ((new - old) / old) * 100


def format_percent(value: float) -> str:
    return f"{value:+.1f}%"


if __name__ == "__main__":
    raise SystemExit(main())
