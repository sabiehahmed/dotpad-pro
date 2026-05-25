# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

Dotpad — a Tot-style multi-dot scratchpad. Two native apps in one repo:

- `desktop/` — macOS menu-bar app, SwiftUI chrome + AppKit `NSTextView` editor.
- `mobile/IOS/` — iOS app, SwiftUI + UIKit `UITextView` editor.

The two apps **share no code** but mirror each other: the model layer
(`Dot`, `DotStore`, `Storage`, `SmartBullets`, `TextMode`, `Preferences`,
`Themes`) is the same design, ported between AppKit and UIKit. When changing
model/editor behavior in one, check whether the sibling app needs the same
change.

## Build / test

Both apps use **XcodeGen**: the `.xcodeproj` is generated from `project.yml`
and is git-ignored. **You must run `xcodegen generate` before any build** (and
after pulling or editing `project.yml`).

```bash
# Desktop
cd desktop && xcodegen generate
xcodebuild -project Dotpad.xcodeproj -scheme Dotpad -configuration Release \
  -destination 'platform=macOS' CODE_SIGNING_ALLOWED=NO build

# Desktop tests (all)
xcodebuild test -project Dotpad.xcodeproj -scheme Dotpad -destination 'platform=macOS'
# Single test
xcodebuild test -project Dotpad.xcodeproj -scheme Dotpad -destination 'platform=macOS' \
  -only-testing:DotpadTests/SmartBulletsTests/testReturnContinuesList

# Mobile (simulator)
cd mobile/IOS && xcodegen generate
xcodebuild -project Dotpad.xcodeproj -scheme Dotpad -sdk iphonesimulator \
  -destination 'generic/platform=iOS Simulator' -configuration Debug \
  CODE_SIGNING_ALLOWED=NO build
```

Mobile has no unit-test target. Mobile device builds need a signing Team set in
Xcode (Signing & Capabilities); simulator/CI builds pass `CODE_SIGNING_ALLOWED=NO`.

> SourceKit-in-editor may report "No such module 'UIKit'" / cross-file "cannot
> find type" errors for the mobile sources — that's because there's no project
> context until `xcodegen generate` runs. The real `xcodebuild` against the iOS
> SDK is the source of truth, not those diagnostics.

## Architecture (the parts that span files)

**`DotStore` is the single source of truth** (`Model/DotStore.swift`,
`ObservableObject`). It owns the ordered `[Dot]`, the `activeDotId`, the active
dot's `NSAttributedString` content, and live `DocStats`. SwiftUI chrome and the
text-view coordinator both observe it. Edits flow editor → `updateActiveContent`
→ debounced (0.4s) `flushSave`. Switching dots flushes first, then reloads.
First launch with no `index.json` seeds 7 dots from `DotStore.palette`.

**`Storage` is the IO seam** (`index.json` + one `dots/<uuid>.rtf|txt` per dot,
all atomic writes) under Application Support `Dotpad/`. It is deliberately the
*single boundary* a future `SyncEngine`/`server/` will sit beside — `Dot`
carries unused `remoteId`/`dirty` fields for that. Today everything is
local-only.

**`SmartBullets` is a pure, unit-tested engine** shared by the picker catalog
*and* the editor's key handling. `handleReturn` / `detect` / `togglePairs`
decide list continuation, empty-bullet termination, and checkbox toggling.
Editor coordinators call into it; they contain no bullet logic themselves.
User-defined pairs live in `Preferences.smartBulletPairs` (JSON in
`@AppStorage`) and are merged in via `allMarkers(from:)` / `togglePairs(from:)`.

**The editor is a platform text view wrapped in a representable + Coordinator**
(`Editor/DotTextView.swift`). The Coordinator: binds edits back to the store,
runs `MarkdownHighlighter` in **plain mode only**, continues/clears bullets on
Return, and toggles a bullet when the user taps within its marker region. Rich
mode stores RTF and preserves per-run attributes; plain mode is treated as
Markdown and re-highlighted on every change.

**Theming** flows through a `Theme` struct resolved from
`Preferences.theme` (`AppTheme` light/dark/auto) + the system `colorScheme`,
injected via `\.theme` environment. Editors take an `isDark` flag and recolor
text on theme flips and dot switches.

### Desktop specifics
Menu-bar app (`LSUIElement = true`): `MenuBar/` owns the status item, the
editor popover, a Carbon global hot key, and the login-item helper. Editor =
`NSTextView`; the SwiftUI bullets picker drives it through an `EditorActions`
closure bridge held by a shared `EditorActionsHolder`.

### Mobile specifics
Editor = `UITextView`. Two non-obvious constraints learned here, keep them:
- **Don't access `UITextView.layoutManager`** — it forces the view into TextKit
  1 compatibility mode. Hit-test taps with `closestPosition(to:)` /
  `offset(from:to:)` instead.
- **Don't use `TabView(.page)`** for the dot carousel — its `UIPageViewController`
  reparents the hosting controllers around the `UITextView` (`_UIReparentingView`
  warnings, broken hierarchy). The dot swipe is a paging `ScrollView`
  (`.scrollTargetBehavior(.paging)` + `.scrollPosition(id:)`) in
  `Views/ContentView.swift`, synced both ways with rail taps.

Mobile `Preferences` intentionally drops macOS-only settings (hotkey, login
item, window/menu-bar options) and adds iOS ones (font size, autocorrect,
haptics).

## Releases

`./release.sh desktop major|minor|patch [-y]` bumps `MARKETING_VERSION` in
`desktop/project.yml`, commits, tags `desktop-v<x.y.z>`, and pushes. The tag
triggers `.github/workflows/release.yml`, which `xcodegen`-builds an **unsigned**
Release `.app` and packages it as a DMG attached to a GitHub Release. There is
no mobile release pipeline.

## App icon

Master is `icons/dot-pad-icon.png` (1024²). Icons must have **no alpha channel**
(App Store rejects it) — flatten with `magick … -background black -alpha remove
-alpha off` before dropping into an `AppIcon.appiconset`.


# IMPORTANT INSTRUCTIONS

Behavioral guidelines to reduce common LLM coding mistakes. Merge with project-specific instructions as needed.

**Tradeoff:** These guidelines bias toward caution over speed. For trivial tasks, use judgment.

## 1. Think Before Coding

**Don't assume. Don't hide confusion. Surface tradeoffs.**

Before implementing:
- State your assumptions explicitly. If uncertain, ask.
- If multiple interpretations exist, present them - don't pick silently.
- If a simpler approach exists, say so. Push back when warranted.
- If something is unclear, stop. Name what's confusing. Ask.

## 2. Simplicity First

**Minimum code that solves the problem. Nothing speculative.**

- No features beyond what was asked.
- No abstractions for single-use code.
- No "flexibility" or "configurability" that wasn't requested.
- No error handling for impossible scenarios.
- If you write 200 lines and it could be 50, rewrite it.

Ask yourself: "Would a senior engineer say this is overcomplicated?" If yes, simplify.

## 3. Surgical Changes

**Touch only what you must. Clean up only your own mess.**

When editing existing code:
- Don't "improve" adjacent code, comments, or formatting.
- Don't refactor things that aren't broken.
- Match existing style, even if you'd do it differently.
- If you notice unrelated dead code, mention it - don't delete it.

When your changes create orphans:
- Remove imports/variables/functions that YOUR changes made unused.
- Don't remove pre-existing dead code unless asked.

The test: Every changed line should trace directly to the user's request.

## 4. Goal-Driven Execution

**Define success criteria. Loop until verified.**

Transform tasks into verifiable goals:
- "Add validation" → "Write tests for invalid inputs, then make them pass"
- "Fix the bug" → "Write a test that reproduces it, then make it pass"
- "Refactor X" → "Ensure tests pass before and after"

For multi-step tasks, state a brief plan:
```
1. [Step] → verify: [check]
2. [Step] → verify: [check]
3. [Step] → verify: [check]
```

Strong success criteria let you loop independently. Weak criteria ("make it work") require constant clarification.

---

**These guidelines are working if:** fewer unnecessary changes in diffs, fewer rewrites due to overcomplication, and clarifying questions come before implementation rather than after mistakes.