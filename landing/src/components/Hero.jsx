import { useEffect, useRef } from 'react'

const AppleIcon = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
    <path d="M17.05 20.28c-.98.95-2.05.88-3.08.41-1.09-.47-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.41C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.53 4.08zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
  </svg>
)

const DOT_COLORS = [
  'var(--d-yellow)',
  'var(--d-orange)',
  'var(--d-red)',
  'var(--d-magenta)',
  'var(--d-purple)',
  'var(--d-blue)',
  'var(--d-cyan)',
  'var(--d-mint)',
  'var(--d-amber)',
  'var(--d-rose)',
]

export default function Hero() {
  const stageRef = useRef(null)
  const sceneRef = useRef(null)

  useEffect(() => {
    const stage = stageRef.current
    const scene = sceneRef.current
    if (!stage || !scene) return

    let raf = null
    let tx = 0, ty = 0, cx = 0, cy = 0

    function update() {
      cx += (tx - cx) * 0.08
      cy += (ty - cy) * 0.08
      stage.style.animation = 'none'
      stage.style.transform = `rotateX(${10 - cy * 6}deg) rotateY(${cx * 8}deg) rotateZ(${cx * 0.6}deg)`
      if (Math.abs(tx - cx) > 0.001 || Math.abs(ty - cy) > 0.001) {
        raf = requestAnimationFrame(update)
      } else {
        raf = null
      }
    }

    function onMouseMove(e) {
      const r = scene.getBoundingClientRect()
      tx = ((e.clientX - r.left) / r.width - 0.5) * 2
      ty = ((e.clientY - r.top) / r.height - 0.5) * 2
      if (!raf) raf = requestAnimationFrame(update)
    }

    function onMouseLeave() {
      tx = 0; ty = 0
      if (!raf) raf = requestAnimationFrame(update)
    }

    scene.addEventListener('mousemove', onMouseMove)
    scene.addEventListener('mouseleave', onMouseLeave)

    return () => {
      scene.removeEventListener('mousemove', onMouseMove)
      scene.removeEventListener('mouseleave', onMouseLeave)
      if (raf) cancelAnimationFrame(raf)
    }
  }, [])

  return (
    <section className="hero">
      <div className="eyebrow">
        <span className="pill">New · v2.0</span>
        <span>Smart bullets, vibrant themes, blazing-fast.</span>
      </div>

      <h1 className="hero-title">
        <span className="stack">A text editor</span>
        <span className="stack">that lives in your <span className="em">menu&nbsp;bar.</span></span>
      </h1>

      <p className="hero-sub">
        DotPad is a fast, beautiful scratch&#8209;pad for macOS. Ten color-coded dots.
        Infinite notes. One keyboard shortcut away — always.
      </p>

      <div className="hero-actions">
        <a className="btn btn-primary" href="https://github.com/sabiehahmed/dotpad-pro/releases" target="_blank" rel="noopener noreferrer">
          <AppleIcon />
          Download for Mac
        </a>
        <a className="btn" href="#features">Watch the demo →</a>
      </div>

      <div className="hero-meta">
        <span className="mono">macOS 13+</span>
        <span style={{ opacity: 0.4 }}>·</span>
        <span><b>Free</b> &amp; Open Source · MIT</span>
      </div>

      {/* 3D Scene */}
      <div className="scene" ref={sceneRef}>
        <div className="scene-floor" />
        <div className="stage" ref={stageRef}>

          {/* Orbs */}
          <div className="orb orb-1" />
          <div className="orb orb-2" />
          <div className="orb orb-3" />
          <div className="orb orb-4" />
          <div className="orb orb-5" />

          {/* Menu bar slice */}
          <div className="menubar" aria-hidden="true">
            <div className="left">
              <span className="apple" />
              <span>Finder</span>
              <span style={{ opacity: 0.6 }}>File</span>
              <span style={{ opacity: 0.6 }}>Edit</span>
              <span style={{ opacity: 0.6 }}>View</span>
            </div>
            <div className="right">
              <span>21°C</span>
              <span className="mbdot" title="DotPad" />
              <span>3:21 PM</span>
            </div>
          </div>

          {/* Left back window */}
          <div className="pad pad-2">
            <div className="pad-tabs">
              <span className="pad-close" />
              <div className="dots-row">
                <span className="dot" style={{ color: 'var(--d-yellow)' }} />
                <span className="dot active" style={{ color: 'var(--d-magenta)' }} />
                <span className="dot" style={{ color: 'var(--d-blue)' }} />
                <span className="dot" style={{ color: 'var(--d-mint)' }} />
              </div>
              <span className="pad-gear">⚙</span>
            </div>
            <div className="pad-body">
              <span className="row">## standup notes</span>
              <span className="row muted">— ship the dot picker</span>
              <span className="row muted">— review PR #482</span>
              <span className="row muted">— talk to design</span>
            </div>
            <div className="pad-foot">
              <div className="meta">
                <span className="dot-mini" style={{ background: 'var(--d-magenta)', boxShadow: '0 0 8px var(--d-magenta)' }} />
                <span>4 lines · 18 words</span>
              </div>
              <div className="icons">∗ A ↗</div>
            </div>
          </div>

          {/* Right back window */}
          <div className="pad pad-3">
            <div className="pad-tabs">
              <span className="pad-close" />
              <div className="dots-row">
                <span className="dot" style={{ color: 'var(--d-orange)' }} />
                <span className="dot" style={{ color: 'var(--d-red)' }} />
                <span className="dot active" style={{ color: 'var(--d-cyan)' }} />
              </div>
              <span className="pad-gear">⚙</span>
            </div>
            <div className="pad-body">
              <span className="row" style={{ color: 'var(--d-cyan)' }}>// snippet</span>
              <span className="row">const dot = (i) =&gt;</span>
              <span className="row">&nbsp;&nbsp;hues[i % hues.length]</span>
            </div>
            <div className="pad-foot">
              <div className="meta">
                <span className="dot-mini" style={{ background: 'var(--d-cyan)', boxShadow: '0 0 8px var(--d-cyan)' }} />
                <span>3 lines</span>
              </div>
              <div className="icons">∗ A ↗</div>
            </div>
          </div>

          {/* Center hero window */}
          <div className="pad pad-1">
            <div className="pad-tabs">
              <span className="pad-close" />
              <div className="dots-row">
                {DOT_COLORS.map((c, i) => (
                  <span
                    key={i}
                    className={`dot${i === 0 ? ' active' : ''}`}
                    style={{ color: c }}
                  />
                ))}
              </div>
              <span className="pad-gear">⚙</span>
            </div>
            <div className="pad-body">
              <span className="row">This is a fancy text editor</span>
              <span className="row">Which lives in your menu bar.</span>
              <span className="row">
                Press <span style={{ color: 'var(--d-yellow)' }}>⌘⇧D</span> from anywhere.
                <span className="caret" />
              </span>
            </div>
            <div className="pad-foot">
              <div className="meta">
                <span className="dot-mini" />
                <span>3 lines · 12 words · 58 characters · Just now</span>
              </div>
              <div className="icons">∗ A ↗</div>
            </div>
          </div>

        </div>
      </div>
    </section>
  )
}
