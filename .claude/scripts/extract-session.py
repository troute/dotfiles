#!/usr/bin/env python3
"""Extract user and assistant text from a Claude session JSONL for review.

Usage:
    python3 extract-session.py <path-to-jsonl>            # conversation text only
    python3 extract-session.py --errors <path-to-jsonl>   # failed tool calls only
"""

import json
import sys


def extract_text(content):
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for block in content:
            if isinstance(block, dict):
                if block.get('type') == 'text':
                    parts.append(block.get('text', ''))
                elif block.get('type') == 'tool_use':
                    parts.append(f"[tool_use: {block.get('name', '?')}]")
        return '\n'.join(parts)
    return str(content)


def extract_conversation(path):
    with open(path) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue
            t = obj.get('type')
            if t == 'user':
                content = obj.get('message', {}).get('content', '')
                if isinstance(content, list):
                    content = '\n'.join(
                        p.get('text', '') for p in content
                        if isinstance(p, dict) and p.get('type') == 'text'
                    )
                ts = obj.get('timestamp', '')
                print(f'\n--- USER [{ts}] ---\n{content}')
            elif t == 'assistant':
                text = extract_text(obj.get('message', {}).get('content', []))
                if text.strip():
                    if len(text) > 3000:
                        text = text[:3000] + '\n[...truncated...]'
                    print(f'\n--- ASSISTANT ---\n{text}')


def extract_errors(path):
    tool_calls = {}

    with open(path) as f:
        for line in f:
            try:
                obj = json.loads(line)
            except json.JSONDecodeError:
                continue

            if obj.get('type') == 'assistant':
                content = obj.get('message', {}).get('content', [])
                if isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict) and block.get('type') == 'tool_use':
                            tool_calls[block.get('id')] = {
                                'name': block.get('name', '?'),
                                'input': block.get('input', {}),
                            }

            elif obj.get('type') == 'user':
                content = obj.get('message', {}).get('content', '')
                if isinstance(content, list):
                    for block in content:
                        if isinstance(block, dict) and block.get('type') == 'tool_result' and block.get('is_error'):
                            tid = block.get('tool_use_id')
                            call = tool_calls.get(tid, {})
                            name = call.get('name', '?')
                            inp = call.get('input', {})
                            err = block.get('content', '')

                            # Skip cascading cancellations — they're noise
                            if '<tool_use_error>Cancelled:' in str(err):
                                continue

                            # Format the input concisely
                            if isinstance(inp, dict):
                                inp_str = inp.get('command', inp.get('prompt', inp.get('pattern', str(inp))))
                            else:
                                inp_str = str(inp)
                            if len(inp_str) > 200:
                                inp_str = inp_str[:200] + '...'

                            if len(err) > 300:
                                err = err[:300] + '...'

                            print(f'TOOL: {name}')
                            print(f'INPUT: {inp_str}')
                            print(f'ERROR: {err}')
                            print()


def main():
    args = sys.argv[1:]
    if '--errors' in args:
        args.remove('--errors')
        extract_errors(args[0])
    else:
        extract_conversation(args[0])


if __name__ == '__main__':
    main()
