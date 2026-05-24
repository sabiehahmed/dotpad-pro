# Dotpad — macOS Desktop App Plan

A native macOS menu-bar note editor. Tot-style UI, pixel-faithful, with extras: **unlimited dots** and a **smart-bullets picker** that continues bullets on line change like a rich-text editor.

> Scope of this document: the **desktop** app only. Local-only storage now; a sync layer to `server/` comes later (designed for, not built).

---

## 1. Goals & Non-Goals

### Goals
- Lives **only** in the macOS menu bar (status bar). No Dock icon by default; appears as a popover under the menu-bar icon.
- UI matches Tot exactly: cream/dark themes, 7-dot color rail, footer stats, gear settings, smart-bullets popover.
- **Unlimited dots** (Tot is fixed at 7): start with the 7 colored dots, add/remove/reorder freely. Each dot = one note document.
- **Smart bullets**: picker popover (bullets, dividers, list markers, checkboxes) + auto-continue behavior on `Return` and auto-clear on empty line, like a rich-text editor.
- **Rich Text** and **Plain Text** modes per dot (matches Tot's two text modes).
- Local storage: one file per dot + a JSON metadata index. Sync-ready layout.
- Global hotkey to summon the window; launch at login; detachable floating window.

### Non-Goals (now)
- Server sync (later — storage layout is sync-friendly).
- iOS/iPadOS/Watch apps (handled in `mobile/` later).
- iCloud sync, collaboration, plugins.

---

## 2. Tech Stack

| Concern | Choice |
|---|---|
| Language | Swift 5.9+ |
| UI | **SwiftUI + AppKit hybrid** |
| Menu-bar item | `NSStatusItem` (AppKit) |
| Popover window | `NSPopover` (anchored) + detachable `NSPanel` (floating mode) |
| Editor | `NSTextView` wrapped in `NSViewRepresentable` (full control over rich text, bullets, typing attributes) |
| Settings / chrome | SwiftUI views |
| Global hotkey | Carbon `RegisterEventHotKey` (lightweight) or `MASShortcut`-style recorder |
| Launch at login | `SMAppService` (macOS 13+) |
| Persistence | `FileManager` — RTF/TXT per dot + JSON index in Application Support |
| Min target | macOS 13 Ventura |
| Build | Xcode project (`Dotpad.xcodeproj`), Swift Package deps via SPM |

**Why hybrid:** SwiftUI is fast for the settings panels and dot rail. But menu-bar lifecycle, the popover, and a real rich-text editor with bullet logic need AppKit (`NSStatusItem`, `NSTextView`). Hybrid gives both.

---

## 3. Project Structure (`desktop/`)

```
desktop/
├── Plan.md
├── Dotpad.xcodeproj
├── Dotpad/
│   ├── DotpadApp.swift            # @main, NSApplicationDelegate adaptor, LSUIElement
│   ├── AppDelegate.swift          # status item, popover, hotkey, login item
│   ├── Info.plist                 # LSUIElement = true (agent app, no Dock)
│   │
│   ├── MenuBar/
│   │   ├── StatusItemController.swift   # NSStatusItem + icon (dot color tint)
│   │   └── PopoverController.swift      # NSPopover <-> detached NSPanel toggle
│   │
│   ├── Editor/
│   │   ├── EditorView.swift             # SwiftUI container (rail + text + footer)
│   │   ├── DotTextView.swift            # NSViewRepresentable wrapping NSTextView
│   │   ├── DotTextViewCoordinator.swift # typing attrs, bullet continuation, paste
│   │   ├── SmartBullets.swift           # bullet/divider/marker catalog + rules
│   │   └── TextMode.swift               # .rich / .plain
│   │
│   ├── DotRail/
│   │   ├── DotRailView.swift            # the colored-dot tab strip
│   │   ├── DotView.swift                # single dot (filled = active)
│   │   └── DotRailViewModel.swift       # add/remove/reorder/select
│   │
│   ├── SmartBulletsPicker/
│   │   ├── SmartBulletsPopover.swift    # the * popover (SMART BULLETS/DIVIDERS/BULLETS)
│   │   └── BulletPalette.swift          # grid layout + insert action
│   │
│   ├── Settings/
│   │   ├── SettingsWindow.swift         # gear popover, 4 tabs
│   │   ├── ControlTab.swift             # activate-with, hotkey, login, quit
│   │   ├── AppearanceTab.swift          # theme, highlights, vibrant, icon
│   │   ├── BehaviorTab.swift            # esc-closes, floating, indent lists
│   │   └── AndMoreTab.swift             # about, help, version
│   │
│   ├── Model/
│   │   ├── Dot.swift                    # id, color, title, mode, fileRef, order
│   │   ├── DotStore.swift               # load/save/observe; @Observable
│   │   ├── Storage.swift                # file IO (RTF/TXT + index.json)
│   │   └── Preferences.swift            # UserDefaults-backed settings
│   │
│   ├── Footer/
│   │   └── FooterView.swift             # "N lines · N words · N characters · <saved>"
│   │
│   └── Resources/
│       ├── Assets.xcassets             # app/menu-bar icons, dot colors
│       └── Themes.swift                # cream (light) + dark palettes, vibrancy
│
└── DotpadTests/
    ├── SmartBulletsTests.swift         # continuation/clear logic
    ├── StorageTests.swift              # round-trip RTF/TXT + index
    └── WordCountTests.swift            # footer stats
```

---

## 4. Data Model & Storage

### On disk
```
~/Library/Application Support/Dotpad/
├── index.json                 # ordered dot metadata
└── dots/
    ├── <uuid>.rtf             # rich-text dots
    └── <uuid>.txt             # plain-text dots
```

### `index.json`
```json
{
  "version": 1,
  "dots": [
    { "id": "UUID", "order": 0, "color": "#F5C518", "title": "appgefahren Artikel-Ideen",
      "mode": "rich", "file": "dots/UUID.rtf", "updatedAt": "ISO8601" }
  ],
  "activeDotId": "UUID"
}
```

- **Rich** dots stored as RTF (preserves bold, color highlights, bullets/attributes).
- **Plain** dots stored as UTF-8 `.txt` (Markdown-friendly, monospace render).
- `title` = first non-empty line (derived, cached for the rail tooltip/numbering).
- Atomic writes (write temp → rename) to avoid corruption.
- Debounced autosave (~400ms after last keystroke) + save on window hide/quit.

### Sync-ready (future)
- Per-dot files + small index = easy to diff/push.
- Add `remoteId`, `syncedAt`, `dirty` fields later without migration pain.
- `Storage` is the single IO seam; a `SyncEngine` will sit beside it.

---

## 5. Feature Breakdown (from screenshots)

### 5.1 Menu-bar presence (Img 1, 2)
- `NSStatusItem` with the ring "O" icon; tints to the **active dot's color** when "Show dot color on menu bar icon" is on.
- Click toggles popover. `LSUIElement = true` → no Dock icon (Dock icon only appears when window detached, per Tot Control tab note).

### 5.2 Window chrome (Img 1, 3)
- Rounded popover with menu-bar arrow.
- Top bar: **close (✕)** top-left, **dot rail** centered, **gear (settings)** top-right.
- Body: scrollable text editor.
- Footer bar: stat line + right-side action icons.

### 5.3 Dot rail — **unlimited** (extends Tot)
- Renders dots in order; active dot = filled, others = ring outline.
- Default seed: 7 dots, Tot's colors (yellow, orange, red, purple, blue, teal/cyan, grey).
- **`+` button** at the end of the rail to add a dot (cycles through palette, then custom).
- **Right-click dot** → context menu: Rename color / Move left-right / Delete (with confirm if non-empty).
- **Drag to reorder.**
- Keyboard: `⌘1…⌘9` jump to dot; `⌘⌥→ / ←` next/prev dot (Tot parity + extension for >9).
- Switching dots saves current, loads target.

### 5.4 Editor (Img 1 rich, Img 3 plain)
- `NSTextView` via `NSViewRepresentable`.
- **Rich mode:** bold/italic/headings, color highlights (Appearance toggle), inserted bullet glyphs as styled text.
- **Plain mode:** monospaced font, no styling, Markdown-friendly; bullet glyphs inserted as literal chars.
- Toggle mode via bottom-right **`a`/`A`** icon (Tot's rich/plain switch) — converts content (RTF↔plain) with confirm when downgrading rich→plain.
- Respects "Automatically indent lists" and "Indent plain text" (Behavior tab).

### 5.5 Smart Bullets — picker + continuation (Img 3) ★ core extra
**Picker** (opens from the **`*`** footer icon), three sections matching the screenshot:
- **SMART BULLETS** (continue on Return): `○/●`, `□/■`, `▷/▶`, `☆/★`, `– / +`, `– / ✓`, `❌/✅`, `⭕/🔴`.
- **DIVIDERS** (insert a full-width rule line, no continuation): `———`, `–·–`, `———`, `··· ` variants.
- **BULLETS** (one-off glyph, no continuation): `·`, `•`, `✳︎`, `✸`, `✦`, `◆`, `◇`, `◈`, etc.

**Continuation rules** (the rich-text behavior):
- On **Return** at end of a smart-bullet line → insert the same bullet (+ matching indent) on the new line.
- **Return on an empty bullet line** → remove the bullet and outdent (terminates the list). Classic editor behavior.
- **Tab / Shift-Tab** on a bullet line → indent / outdent one level.
- Checkbox markers (`○/●`, `❌/✅`) → clicking the glyph toggles checked/unchecked state.
- Numbered support optional later; screenshot set is glyph-based, so v1 = glyph bullets.
- Logic lives in `SmartBullets.swift` + the coordinator's `textView(_:shouldChangeTextIn:)` / `doCommandBy:` handling. Unit-tested.

### 5.6 Footer stats (Img 1, 3)
- `"<lines> lines · <words> words · <chars> characters"` + `· <relative saved time>` ("Just now", "2m ago").
- Right icons: **`*`** (smart bullets), **`a`/`A`** (rich/plain toggle), **share** (export/copy — Img 3).
- Leading colored dot = active dot color.

### 5.7 Settings — gear popover, 4 tabs
**Control (Img 5)**
- *Activate with:* Menu Bar Icon / Both Icons (dropdown).
- *Show window:* global hotkey recorder.
- *Start at login* (`SMAppService`).
- *Quit Dotpad.*

**Appearance (Img 4)**
- *Theme:* Dark / Light / Auto.
- *Add color highlights to text* (toggle).
- *Use vibrant background* (NSVisualEffectView).
- *Show dot number in title bar.*
- *Show dot color on menu bar icon.*
- *Smart Bullets: Customize…* (edit which glyphs appear in picker).
- *App Icon* picker.

**Behavior (Img 6)**
- *Escape key closes window.*
- *Display as floating window* (detach popover → always-on-top `NSPanel`).
- *Window hotkey follows mouse.*
- *Automatically indent lists* / *Indent plain text.*

**And More… (Img 2)**
- About Dotpad, What's New, Help/User Manual, Support link, version footer. (No "Purchase" — adapt to About.)

### 5.8 Window behaviors
- Esc closes (if enabled), `⌘W` closes, click-outside dismisses popover.
- Floating mode: detaches to movable always-on-top panel; Dock icon appears while detached.
- Global hotkey shows window + focuses editor immediately; optional "follow mouse" repositions to cursor.

---

## 6. Build Phases

**Phase 0 — Skeleton**
- Xcode project, `LSUIElement`, `NSStatusItem` showing icon, empty `NSPopover` toggle.

**Phase 1 — Editor + storage**
- `DotTextView` (plain mode first), `DotStore` + `Storage` (txt + index.json), autosave, footer stats.

**Phase 2 — Dot rail (unlimited)**
- Rail UI, add/remove/reorder, color seeding, `⌘1…9` switching, per-dot load/save.

**Phase 3 — Rich text + modes**
- RTF storage, rich rendering, color highlights, rich/plain toggle + conversion.

**Phase 4 — Smart bullets ★**
- Picker popover (3 sections), insert actions, continuation/clear/indent logic, checkbox toggling. Unit tests.

**Phase 5 — Settings**
- 4-tab gear popover; wire prefs (theme, vibrancy, indent, hotkey, login item, floating window).

**Phase 6 — Polish / parity pass**
- Exact spacing, fonts, cream + dark palettes, vibrancy, animations, share/export, relative save time.

**Phase 7 — Sync seam (stub only)**
- Define `SyncEngine` protocol + `dirty/remoteId` fields. No network yet.

---

## 7. Open Questions / Assumptions
- **Fonts:** assume system (SF) for rich, SF Mono for plain — confirm if Tot's exact face matters.
- **Smart-bullet glyph set:** seeded from screenshot; "Customize…" lets users edit later.
- **Share icon:** assume = copy-as-text + export `.txt`/`.rtf`. Confirm if "Send to mobile/server" wanted now (likely later).
- **Distribution:** dev-signed local build now; notarization/DMG later.
- **App name in bundle:** `Dotpad`.
