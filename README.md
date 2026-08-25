[![Docs on contextowl.co](https://contextowl.co/uploads/_brand/badge-docs.svg)](https://contextowl.co)

A retro terminal music player inspired by Winamp. Play local files, streams, podcasts, YouTube, YouTube Music, SoundCloud, Bilibili, Spotify, NetEase Cloud Music, Xiaoyuzhou (小宇宙), Navidrome, Plex, Jellyfin, and Audiobookshelf with a spectrum visualizer, parametric EQ, and playlist management.

**[cliamp.stream](https://cliamp.stream)** · **[docs](https://whiterose.org.contextowl.co/docs/cliamp)**

Built with [Bubbletea](https://github.com/charmbracelet/bubbletea), [Lip Gloss](https://github.com/charmbracelet/lipgloss), [Beep](https://github.com/gopxl/beep), and [go-librespot](https://github.com/devgianlu/go-librespot).


https://github.com/user-attachments/assets/fbc33d20-e3ac-4a62-a991-8a2f0243c8ea

<div align="center">
  <a href="https://contextowl.co"><img src="https://contextowl.co/uploads/_brand/sponsor-dark.svg" alt="Proudly sponsored by contextowl.co" width="400"></a>
</div>

## Install

```sh
curl -fsSL https://raw.githubusercontent.com/bjarneo/cliamp/HEAD/install.sh | sh
```

**Homebrew**

```sh
brew install bjarneo/cliamp/cliamp
```

The formula pulls in all required runtime libraries automatically.

**Arch Linux (AUR)**

```sh
yay -S cliamp
```

**Nix**

```sh
nix run github:bjarneo/cliamp
```

For a declarative NixOS configuration, add `github:bjarneo/cliamp` as a flake
input and install its default package:

```nix
inputs.cliamp.url = "github:bjarneo/cliamp";

environment.systemPackages = [
  inputs.cliamp.packages.${pkgs.stdenv.hostPlatform.system}.default
];
```

**Go**

```sh
go install github.com/bjarneo/cliamp@latest
```

Linux builds need ALSA development headers installed first. See [Building from source](#building-from-source).

**Pre-built binaries**

Download from [GitHub Releases](https://github.com/bjarneo/cliamp/releases/latest).

> **macOS:** the pre-built binaries dynamically link against FLAC, Vorbis, Ogg, and mpg123
> from Homebrew. If you download directly from Releases (or use the `install.sh`
> script) you must install them first, otherwise you will see errors like
> `Library not loaded: /opt/homebrew/opt/libvorbis/lib/libvorbisenc.2.dylib`:
>
> ```sh
> brew install flac libvorbis libogg mpg123
> ```
>
> Installing via `brew install bjarneo/cliamp/cliamp` does this for you.
>
> **Linux:** the pre-built binaries statically link FLAC, Vorbis, Ogg, and mpg123, so no
> extra codec packages are required. You may still need an ALSA bridge for your
> sound server — see [Troubleshooting](#troubleshooting).
>
> **Windows:** download and extract `cliamp-windows-amd64.zip` or
> `cliamp-windows-arm64.zip` from Releases. Each zip includes the codec DLLs
> required by Spotify. If `HOME` is not set, cliamp stores its config under
> `%APPDATA%\cliamp`.

**Optional runtime dependencies** (all platforms, all install methods):

- [ffmpeg](https://ffmpeg.org/) — for AAC, ALAC, Opus, and WMA playback
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — for YouTube, YouTube Music, SoundCloud, Bandcamp, Bilibili, and NetEase Cloud Music

On macOS: `brew install ffmpeg yt-dlp`. On Linux, use your distribution's package manager.

On Windows, install `ffmpeg` and `yt-dlp` with your preferred package manager and keep both on `PATH`.

**Build from source**

```sh
git clone https://github.com/bjarneo/cliamp.git && cd cliamp && go build -o cliamp .
```

## Quick Start

```sh
cliamp ~/Music                     # play a directory
cliamp *.mp3 *.flac               # play files
cliamp https://example.com/stream  # play a URL
```

Press `Ctrl+K` to see all keybindings.

**Configure remote providers** (Navidrome, Plex, Jellyfin, Audiobookshelf, Spotify, YouTube Music, NetEase Cloud Music) with the interactive wizard:

```sh
cliamp setup
```

It walks you through each provider, validates the connection, and writes the right block to your config file (`~/.config/cliamp/config.toml`, or `%APPDATA%\cliamp\config.toml` on Windows when `HOME` is unset). See [docs/cli.md](docs/cli.md#setup-wizard) for details.

## Radio

Press `R` in the player to browse and search 30,000+ online radio stations from the [Radio Browser](https://www.radio-browser.info/) directory.

Add your own stations to `~/.config/cliamp/radios.toml` (or `%APPDATA%\cliamp\radios.toml` on Windows when `HOME` is unset). See [docs/configuration.md](docs/configuration.md#custom-radio-stations).

Want to host your own radio? Check out [cliamp-server](https://github.com/bjarneo/cliamp-server).

## Building from source

**Prerequisites:**

- [Go](https://go.dev/dl/) 1.25.5 or later
- ALSA development headers (Linux only — required by the audio backend)

**Linux (Debian/Ubuntu):**

```sh
sudo apt install libasound2-dev libflac-dev libvorbis-dev libogg-dev libmpg123-dev
```

**Linux (Fedora):**

```sh
sudo dnf install alsa-lib-devel flac-devel libvorbis-devel libogg-devel mpg123-devel
```

**Linux (Arch):**

```sh
sudo pacman -S alsa-lib flac libvorbis libogg mpg123
```

**macOS:** `brew install flac libvorbis libogg mpg123 pkg-config`

**Windows:** No extra SDKs required for the core player — it uses pure-Go audio decoding. `ffmpeg.exe` and `yt-dlp.exe` remain optional runtime dependencies for the same formats/providers as on other platforms.

Spotify support uses `go-librespot`, which needs CGO and an MSYS2 toolchain.
Use MINGW64 on amd64 and CLANGARM64 on arm64.

1. Install [MSYS2](https://www.msys2.org/).
2. Open the matching MSYS2 environment, not the plain MSYS2 terminal, and install the toolchain and codec libraries.

   **amd64 (MINGW64):** use the MSYS2 MinGW64 terminal, then:
   ```sh
   pacman -S mingw-w64-x86_64-gcc mingw-w64-x86_64-pkg-config \
     mingw-w64-x86_64-libogg mingw-w64-x86_64-libvorbis \
     mingw-w64-x86_64-flac mingw-w64-x86_64-mpg123
   ```

   **arm64 (CLANGARM64):** start `C:\msys64\clangarm64.exe`, then:
   ```sh
   pacman -S --needed mingw-w64-clang-aarch64-clang \
     mingw-w64-clang-aarch64-pkgconf \
     mingw-w64-clang-aarch64-libogg mingw-w64-clang-aarch64-libvorbis \
     mingw-w64-clang-aarch64-flac mingw-w64-clang-aarch64-mpg123
   ```
3. From that same terminal, so the compiler and `pkg-config` are on `PATH`, build with CGO enabled.

   **amd64:**
   ```sh
   CGO_ENABLED=1 go build -o cliamp.exe .
   ```

   **arm64.** Go cgo looks for `gcc` unless `CC` is set. CLANGARM64's compiler is `clang`:
   ```sh
   CGO_ENABLED=1 CC=clang go build -o cliamp.exe .
   ```

   Some MSYS2 `libogg` builds ship a `libogg-0.dll` whose export table is missing `ogg_stream_iovecin`, even though it's present in the static `libogg.a`. If the link fails with `undefined reference to 'ogg_stream_iovecin'`, add `CGO_LDFLAGS="-Wl,-Bstatic -logg -Wl,-Bdynamic"` to the same command.
4. `cliamp.exe` dynamically links codec and MinGW runtime DLLs. Keep the matching MSYS2 bin directory on `PATH` at runtime (`C:\msys64\mingw64\bin` on amd64, `C:\msys64\clangarm64\bin` on arm64), or copy every `$MINGW_PREFIX/bin/*.dll` shown by `ldd cliamp.exe` next to `cliamp.exe`.

**Clone and build:**

```sh
git clone https://github.com/bjarneo/cliamp.git
cd cliamp
make && make install
```

Or without Make: `go build -o cliamp .`

`make install` places the binary in `~/.local/bin/`.

**Optional runtime dependencies:**

- [ffmpeg](https://ffmpeg.org/) — for AAC, ALAC, Opus, and WMA playback
- [yt-dlp](https://github.com/yt-dlp/yt-dlp) — for YouTube, SoundCloud, Bandcamp, Bilibili, and NetEase Cloud Music

## Docs

Full documentation is hosted at **[whiterose.org.contextowl.co/docs/cliamp](https://whiterose.org.contextowl.co/docs/cliamp)**.

## Troubleshooting

**No audio output (silence with no errors)**

On Linux systems using PipeWire or PulseAudio, cliamp's ALSA backend needs a bridge package to route audio through your sound server:

- **PipeWire:** `pipewire-alsa`
- **PulseAudio:** `pulseaudio-alsa`

Install the appropriate package for your system:

```sh
# PipeWire (Arch)
sudo pacman -S pipewire-alsa

# PulseAudio (Arch)
sudo pacman -S pulseaudio-alsa

# Debian/Ubuntu (PipeWire)
sudo apt install pipewire-alsa
```

## Author

[x.com/iamdothash](https://x.com/iamdothash)

## Disclaimer

Use this software at your own risk. We are not responsible for any damages or issues that may arise from using this software.
