#!/usr/bin/env python3
"""
PreCompact hook — snapshot important context before compaction.

Reads the session transcript, extracts:
  1. User's original request / goals
  2. Key decisions made
  3. Files modified
  4. Unresolved issues / next steps

Writes a handover summary to ~/.claude/handovers/latest.md so that
CLAUDE.md can @import it and Claude picks it up after compaction.
"""

import json
import sys
import os
from pathlib import Path
from datetime import datetime


def main():
    # Read hook input from stdin
    hook_input = json.load(sys.stdin)
    transcript_path = hook_input.get("transcript_path", "")
    session_id = hook_input.get("session_id", "unknown")
    cwd = hook_input.get("cwd", os.getcwd())

    if not transcript_path or not Path(transcript_path).exists():
        sys.exit(0)  # Nothing to do

    # Read transcript (JSONL format)
    messages = []
    with open(transcript_path) as f:
        for line in f:
            line = line.strip()
            if line:
                try:
                    messages.append(json.loads(line))
                except json.JSONDecodeError:
                    continue

    # Extract key information
    user_messages: list[str] = []
    assistant_messages: list[str] = []
    tool_uses: list[dict] = []
    files_modified: set[str] = set()

    for msg in messages:
        role = msg.get("role", "")
        content = msg.get("content", "")

        if role == "user":
            if isinstance(content, str):
                user_messages.append(content)
            elif isinstance(content, list):
                for block in content:
                    if isinstance(block, dict) and block.get("type") == "text":
                        user_messages.append(block["text"])

        elif role == "assistant":
            if isinstance(content, str):
                assistant_messages.append(content)
            elif isinstance(content, list):
                for block in content:
                    if isinstance(block, dict):
                        if block.get("type") == "text":
                            assistant_messages.append(block["text"])
                        elif block.get("type") == "tool_use":
                            tool_name = block.get("name", "")
                            tool_input = block.get("input", {})
                            tool_uses.append({"tool": tool_name, "input": tool_input})

                            # Track modified files
                            if tool_name in ("Edit", "Write"):
                                fp = tool_input.get("file_path", "")
                                if fp:
                                    files_modified.add(fp)

    # Build handover summary
    lines: list[str] = []
    lines.append(f"# Session Handover — {datetime.now().strftime('%Y-%m-%d %H:%M')}")
    lines.append(f"Session: {session_id}")
    lines.append(f"Working directory: {cwd}")
    lines.append("")

    # First user message = original request
    if user_messages:
        first_msg = user_messages[0][:2000]  # Truncate if huge
        lines.append("## Original Request")
        lines.append(first_msg)
        lines.append("")

    # Last few user messages = most recent context
    if len(user_messages) > 1:
        lines.append("## Most Recent User Messages")
        for msg in user_messages[-3:]:
            truncated = msg[:500]
            lines.append(f"- {truncated}")
        lines.append("")

    # Files modified
    if files_modified:
        lines.append("## Files Modified This Session")
        for fp in sorted(files_modified):
            lines.append(f"- {fp}")
        lines.append("")

    # Last assistant message = current state
    if assistant_messages:
        last_msg = assistant_messages[-1][:1500]
        lines.append("## Last Assistant Response (truncated)")
        lines.append(last_msg)
        lines.append("")

    # Tool use summary
    if tool_uses:
        tool_counts: dict[str, int] = {}
        for tu in tool_uses:
            tool_counts[tu["tool"]] = tool_counts.get(tu["tool"], 0) + 1
        lines.append("## Tool Usage Summary")
        for tool, count in sorted(tool_counts.items(), key=lambda x: -x[1]):
            lines.append(f"- {tool}: {count} calls")
        lines.append("")

    # Write handover files
    handover_dir = Path.home() / ".claude" / "handovers"
    handover_dir.mkdir(parents=True, exist_ok=True)

    # Session-specific file (for history)
    handover_file = handover_dir / f"handover-{session_id}.md"
    handover_file.write_text("\n".join(lines))

    # "latest" file that CLAUDE.md @imports
    latest_file = handover_dir / "latest.md"
    latest_file.write_text("\n".join(lines))

    # Output confirmation — only top-level fields are valid for PreCompact
    json.dump(
        {
            "continue": True,
            "systemMessage": (
                f"Session context saved to {handover_file}. "
                f"Tracked {len(files_modified)} modified files, "
                f"{len(user_messages)} user messages, "
                f"{len(tool_uses)} tool calls."
            ),
        },
        sys.stdout,
    )

    sys.exit(0)


if __name__ == "__main__":
    main()
