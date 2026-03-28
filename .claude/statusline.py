#!/usr/bin/env python3
import json, sys

statusline = ''

data = json.load(sys.stdin)
model = data['model']['display_name']

# context window usage

pct = int(data.get('context_window', {}).get('used_percentage', 0) or 0)

filled = pct * 10 // 100
bar = '▓' * filled + '░' * (10 - filled)

statusline += f"[{model}] Ctx {bar} {pct}%"

# rate limit usage

parts = []
rate = data.get('rate_limits', {})
five_h = rate.get('five_hour', {}).get('used_percentage')
week = rate.get('seven_day', {}).get('used_percentage')

def rlim_color(pct):
    if pct > 90:
        return '\033[31m'  # red
    elif pct > 70:
        return '\033[38;5;208m'  # orange
    elif pct > 50:
        return '\033[33m'  # yellow
    return ''

RESET = '\033[0m'

if five_h is not None:
    c = rlim_color(five_h)
    r = RESET if c else ''
    parts.append(f"{c}5h: {five_h:.0f}%{r}")
if week is not None:
    c = rlim_color(week)
    r = RESET if c else ''
    parts.append(f"{c}7d: {week:.0f}%{r}")

if parts:
    statusline += f" Rlim {' '.join(parts)}"

# output

print(statusline)
