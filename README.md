# Dotpad

A tiny, fast scratchpad for thoughts and lists — a Tot-style multi-dot note
app. Up to seven (and beyond) color "dots", each holding one note in rich or
plain (Markdown) text, with smart bullets, text dividers, auto-indent, live
word/line/char counts, and light/dark/auto themes.

This repo holds two apps that share the same on-disk note format and model
design:

- **`desktop/`** — macOS menu-bar app (SwiftUI + AppKit `NSTextView`).
- **`mobile/IOS/`** — iOS app (SwiftUI + UIKit `UITextView`).

---

## Repository structure

```
dotpad-pro/
├── README.md
├── .gitignore                 # ignores generated *.xcodeproj + build output
├── release.sh                 # version bump + tag + push (triggers DMG build)
├── icons/
│   └── dot-pad-icon.png        # 1024×1024 master app icon
├── .github/workflows/
│   └── release.yml             # builds unsigned macOS DMG on desktop-v* tag
│
├── desktop/                    # macOS app
│   ├── project.yml             # XcodeGen spec (Dotpad.xcodeproj is generated)
│   ├── Dotpad/
│   │   ├── DotpadApp.swift
│   │   ├── AppDelegate.swift
│   │   ├── Model/              # Dot, DotStore, Storage, SyncEngine, Preferences
│   │   ├── Editor/             # NSTextView editor, SmartBullets, MarkdownHighlighter
│   │   ├── DotRail/            # the colored dot rail
│   │   ├── Footer/             # stats + actions footer
│   │   ├── MenuBar/            # status item, popover, global hotkey, login item
│   │   ├── SmartBulletsPicker/
│   │   ├── Settings/
│   │   └── Resources/          # Themes, Assets.xcassets, Info.plist
│   └── DotpadTests/            # unit tests (storage, word count, smart bullets)
│
├── mobile/IOS/                 # iOS app
│   ├── project.yml             # XcodeGen spec (Dotpad.xcodeproj is generated)
│   └── Dotpad/
│       ├── Model/              # Dot, TextMode, Storage, DotStore, Preferences
│       ├── Editor/             # DotTextView (UITextView), SmartBullets,
│       │                       #   MarkdownHighlighter, EditorActions
│       ├── Views/              # DotpadApp, ContentView, DotRailView,
│       │                       #   FooterView, SmartBulletsPicker
│       ├── Settings/           # SettingsView + detail screens
│       └── Resources/          # Themes, Assets.xcassets (AppIcon)
│
└── server/                     # (placeholder for future sync backend)
```

Both apps use **XcodeGen**: the `.xcodeproj` is *generated from* `project.yml`
and is git-ignored. Always regenerate after pulling or editing `project.yml`.

### Shared note format

Both apps persist identically (no shared code yet, just the same layout):

- `index.json` — ordered dot metadata (id, order, color, mode, timestamps).
- `dots/<uuid>.rtf` (rich) or `dots/<uuid>.txt` (plain) — one file per dot.

Data lives under **Application Support / `Dotpad/`**:

- macOS: `~/Library/Application Support/Dotpad/`
- iOS: inside the app sandbox's Application Support directory.

---

## Prerequisites

| Tool | Why | Install |
|------|-----|---------|
| Xcode 15+ (16/26 fine) | build both apps | App Store / developer.apple.com |
| XcodeGen | generate `.xcodeproj` from `project.yml` | `brew install xcodegen` |
| create-dmg | package the macOS DMG (release only) | `brew install create-dmg` |

---

## Desktop (macOS)

### Build & run from source

```bash
cd desktop
xcodegen generate          # creates Dotpad.xcodeproj
open Dotpad.xcodeproj       # then Run (⌘R) in Xcode
```

Or build a Release binary on the command line:

```bash
cd desktop
xcodegen generate
xcodebuild \
  -project Dotpad.xcodeproj \
  -scheme Dotpad \
  -configuration Release \
  -derivedDataPath build/dd \
  -destination 'platform=macOS' \
  CODE_SIGNING_ALLOWED=NO \
  build
# product: build/dd/Build/Products/Release/Dotpad.app
```

Dotpad is a menu-bar app (`LSUIElement = true`) — it shows a status item, not a
Dock icon. Click the menu-bar dot to open the editor popover.

### Run the tests

```bash
cd desktop
xcodegen generate
xcodebuild test -project Dotpad.xcodeproj -scheme Dotpad -destination 'platform=macOS'
```

### Install the unsigned DMG

Release builds are **unsigned**, so Gatekeeper warns on first launch. After
downloading `Dotpad-<version>.dmg` from the GitHub Release:

1. Open the DMG, drag **Dotpad** onto the **Applications** shortcut.
2. First launch — pick one:
   - **Right-click** `Dotpad.app` → **Open** → **Open** in the dialog, or
   - strip the quarantine flag:
     ```bash
     xattr -dr com.apple.quarantine /Applications/Dotpad.app
     ```
3. Eject the DMG.

### Uninstall

```bash
# 1. Quit Dotpad (menu-bar icon → Quit, or):
osascript -e 'quit app "Dotpad"'

# 2. Remove the app
rm -rf /Applications/Dotpad.app
```

### Clear all data (reset to a fresh state)

This deletes every dot and resets the app. **Irreversible.**

```bash
# Notes (dots + index)
rm -rf ~/Library/Application\ Support/Dotpad

# Preferences (theme, smart bullets, toggles, hotkey)
defaults delete com.dotpad.Dotpad 2>/dev/null || true
```

Relaunch and Dotpad re-seeds the seven default dots.

---

## Mobile (iOS)

### Build & run

```bash
cd mobile/IOS
xcodegen generate          # creates Dotpad.xcodeproj
open Dotpad.xcodeproj
```

In Xcode: pick an iOS Simulator (or a connected device) and Run (⌘R).
Deployment target is **iOS 17.0**. Bundle id `com.dotpad.mobile`.

Command-line build for the simulator:

```bash
cd mobile/IOS
xcodegen generate
xcodebuild \
  -project Dotpad.xcodeproj \
  -scheme Dotpad \
  -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' \
  -configuration Debug \
  CODE_SIGNING_ALLOWED=NO \
  build
```

> Running on a **physical device** requires signing: open the project in Xcode,
> select the Dotpad target → **Signing & Capabilities**, and set your Team.

### App icon

The icon comes from `icons/dot-pad-icon.png`, flattened (alpha removed — the
App Store rejects icons with an alpha channel) into
`mobile/IOS/Dotpad/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`.
To refresh it after changing the master:

```bash
cd mobile/IOS/Dotpad/Resources/Assets.xcassets/AppIcon.appiconset
magick ../../../../../../icons/dot-pad-icon.png \
  -background black -alpha remove -alpha off AppIcon.png
```

### Uninstall / clear data

- **Simulator/device:** long-press the icon → **Remove App** → **Delete App**.
  Deleting the app removes its sandbox (all dots + preferences).
- **Reset just the data, keep the app:** delete and reinstall, or in the
  Simulator use **Device → Erase All Content and Settings**.

iOS notes live inside the app sandbox and are removed with the app — there is no
separate cleanup step.

---

## Releasing the macOS DMG

`release.sh` bumps the version in `desktop/project.yml`, commits, tags, and
pushes. Pushing a `desktop-v*` tag triggers `.github/workflows/release.yml`,
which builds the unsigned DMG and attaches it to a GitHub Release.

```bash
./release.sh desktop patch      # 1.0.0 -> 1.0.1   (also: minor | major)
./release.sh desktop minor -y   # skip the confirm prompt
```

Requirements: clean working tree, push access. With the `gh` CLI installed the
script also watches the workflow run and opens the published release.

> Mobile has no automated release pipeline yet — distribute via Xcode / Archive
> or TestFlight manually.

---

## Notes

- Generated `*.xcodeproj`, `build/`, `DerivedData/`, and `xcuserdata/` are
  git-ignored. Commit `project.yml`, not the project.
- Sync is not implemented yet. The `Dot` model carries `remoteId`/`dirty`
  fields and there's a `SyncEngine` stub (desktop) + empty `server/` for a
  future backend; today both apps are local-only.
