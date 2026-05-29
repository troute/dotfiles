# Dictation Guide

## Purpose

I use dictation (speech-to-text) for the vast majority of my inputs. This means my messages
frequently contain transcription errors, especially for words that are uncommon in a typical
dictation corpus: variable names, function names, file paths, library names, CLI commands, and
other technical references.

In general, use your best judgment when interpreting ambiguous input under the assumption that I
may be dictating. I often go back and manually correct meaningful transcription errors, but this
guidance should let me skip that step in most cases.

## How to Interpret Dictated Input

- **Read phonetically when something seems nonsensical.** If a word or phrase doesn't make sense
  literally, consider whether it's a phonetic approximation of a term that *does* make sense in the
  context of our conversation, the current codebase, or the task at hand. Map it to the most likely
  intended term.
- **Use conversational and code context as the disambiguator.** A garbled token is very often the
  name of a symbol, file, or concept we've already discussed or that exists in the current project.
  Prefer interpretations grounded in that context over literal readings.
- **Watch for homophones and near-homophones.** Dictation commonly substitutes similar-sounding
  words (e.g. "their/there", "to/two/too", "sight/site/cite", or a real word in place of a technical
  term). Correct these silently when the intent is clear.
- **Spoken punctuation and symbols may be transcribed as words.** Words like "dot", "slash",
  "underscore", "dash", "open paren", "bracket", or "new line" may be literal punctuation I spoke
  aloud, or may be actual words — infer which from context.
- **Don't over-correct.** Only reinterpret when the literal reading is implausible. If the input
  reads sensibly as-is, take it at face value.
- **Ask when it's both ambiguous and consequential.** If you can't confidently resolve a garbled
  reference and getting it wrong would be costly (e.g. editing the wrong file, running a destructive
  command), briefly confirm rather than guessing.
