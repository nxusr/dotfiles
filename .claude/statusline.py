#!/usr/bin/env python3
import json
import sys
import time

data = json.load(sys.stdin)
parts = []

RED = "\033[31m"
ORANGE = "\033[38;5;208m"
YELLOW = "\033[33m"
GREEN = "\033[32m"
RESET = "\033[0m"


def colourise(text, colour):
    return f"{colour}{text}{RESET}" if colour else text


def threshold_colour(pct):
    if pct > 90:
        return RED
    elif pct > 70:
        return ORANGE
    elif pct > 50:
        return YELLOW
    elif pct > 25:
        return GREEN
    return ""


def fmt_tokens(n):
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def fmt_remaining(resets_at):
    if not resets_at:
        return ""
    remaining = int(resets_at - time.time())
    if remaining <= 0:
        return ""
    days, remaining = divmod(remaining, 86400)
    hours, remaining = divmod(remaining, 3600)
    mins = remaining // 60
    if days:
        return f"({days}d{hours:02d}h)"
    if hours:
        return f"({hours}h{mins:02d}m)"
    return f"({mins}m)"


# session name

name = data.get("session_name")
if name:
    parts.append(name)

# model

parts.append(f"[{data['model']['display_name']}]")

# worktree

wt = data.get("worktree", {})
if wt.get("name"):
    parts.append(f"⎇ {wt.get('branch', wt['name'])}")

# agent

agent = data.get("agent", {})
if agent.get("name"):
    parts.append(f"[{agent['name']}]")

# context window

ctx = data.get("context_window", {})
pct = int(ctx.get("used_percentage") or 0)
filled = pct * 20 // 100
bar = "▓" * filled + "░" * (20 - filled)
parts.append(f"Ctx {colourise(f'{bar} {pct}%', threshold_colour(pct))}")

# total tokens

inp = ctx.get("total_input_tokens") or 0
out = ctx.get("total_output_tokens") or 0
if inp or out:
    parts.append(f"↑{fmt_tokens(inp)} ↓{fmt_tokens(out)}")

# rate limits

rlim_parts = []
rate = data.get("rate_limits", {})
for key, label in [("five_hour", "5h"), ("seven_day", "7d")]:
    bucket = rate.get(key, {})
    used = bucket.get("used_percentage")
    if used is not None:
        reset_str = fmt_remaining(bucket.get("resets_at"))
        rlim_parts.append(colourise(f"{label}: {used:.0f}%{reset_str}", threshold_colour(used)))

if rlim_parts:
    parts.append(f"Rlim {' '.join(rlim_parts)}")

# output

print(" ".join(parts))
