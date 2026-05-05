# demo/

VHS-rendered demos that get embedded in the main `README.md`.

## Tapes

- `bootstrap.tape` — interactive `bootstrap.sh` walkthrough; setup-time demo
- `second-session.tape` — fresh Claude Code session loading kit context via auto-memory; daily-use demo. Assumes `~/Code/recipe-card-maker` is already bootstrapped (working folder + auto-memory populated). Adjust the repo path if you fork this for your own kit.

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

## Converting GIFs to MP4 for social posts

GitHub's README renders animated GIFs inline natively, so the kit's `README.md` references them as-is. Most social-media composers (Threads, Bluesky, LinkedIn, etc.) **don't accept animated `.gif` uploads** — they want MP4 video for any motion content, and their file pickers filter `.gif` out at the OS level.

If you're posting a launch / update thread and want the demo motion in the post itself (not just a link to the repo), convert the GIF to MP4 with `ffmpeg`:

```sh
cd demo
ffmpeg -y -i bootstrap.gif -movflags faststart -pix_fmt yuv420p \
  -vf "scale=trunc(iw/2)*2:trunc(ih/2)*2" bootstrap.mp4
```

The flags handle three things social platforms care about:

- `-movflags faststart` — moves the video metadata to the front so the file plays without buffering.
- `-pix_fmt yuv420p` — required pixel format for broad compatibility (Threads/Bluesky/LinkedIn all reject other formats).
- `-vf "scale=trunc(iw/2)*2..."` — forces even dimensions, which H.264 requires (otherwise `ffmpeg` errors out).

Output lands at `demo/bootstrap.mp4`. Like the GIFs, MP4 renders are git-ignored — generate locally as needed for posts.

## Why renders aren't committed

`demo/*.gif` and `demo/*.mp4` are git-ignored. The kit is docs-and-templates only; binary artifacts would bloat the repo over time.

The canonical rendered copies live as GitHub user-attachments referenced from the main `README.md`:

- `bootstrap.gif` → `https://github.com/user-attachments/assets/48ab501b-46d8-47d6-950c-88ba6721232d`
- `second-session.gif` → `https://github.com/user-attachments/assets/822251d0-9252-4326-bce1-eed07d50a6fe`

To update the embedded demo:

1. Edit and re-render the tape locally.
2. Drag the new `bootstrap.gif` into any GitHub PR or issue comment.
3. GitHub returns a `https://github.com/user-attachments/assets/...` URL.
4. Update the `<img>` reference in `README.md` (and the URL above) to the new attachment.

## Why no CI re-rendering

VHS output is non-deterministic across environments (font availability, shell prompt, animation timing). Manual local rendering on the maintainer's machine is the right tradeoff at this scale.
