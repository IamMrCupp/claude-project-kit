# demo/

VHS-rendered demos that get embedded in the main `README.md`.

## Tapes

- `bootstrap.tape` — interactive `bootstrap.sh` walkthrough (Phase 1)
- `second-session.tape` — fresh Claude Code session loading kit context (Phase 2, pending — see [#87](https://github.com/IamMrCupp/claude-project-kit/issues/87))

## Rendering

[VHS](https://github.com/charmbracelet/vhs) is required:

```sh
brew install vhs
```

Render a tape **from the kit checkout root** (each tape captures `$PWD` at start so it can locate `bootstrap.sh` regardless of where the kit is checked out):

```sh
vhs demo/bootstrap.tape
```

Output lands at `demo/bootstrap.gif`.

## Why renders aren't committed

`demo/*.gif` and `demo/*.mp4` are git-ignored. The kit is docs-and-templates only; binary artifacts would bloat the repo over time.

The canonical rendered copy lives as a GitHub user-attachment referenced from the main `README.md`. The currently embedded `bootstrap.gif` is at:

> `https://github.com/user-attachments/assets/48ab501b-46d8-47d6-950c-88ba6721232d`

To update the embedded demo:

1. Edit and re-render the tape locally.
2. Drag the new `bootstrap.gif` into any GitHub PR or issue comment.
3. GitHub returns a `https://github.com/user-attachments/assets/...` URL.
4. Update the `<img>` reference in `README.md` (and the URL above) to the new attachment.

## Why no CI re-rendering

VHS output is non-deterministic across environments (font availability, shell prompt, animation timing). Manual local rendering on the maintainer's machine is the right tradeoff at this scale.
