const REPO = 'https://github.com/sabiehahmed/dotpad-pro'

const GitHubIcon = () => (
  <svg width="22" height="22" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
    <path d="M12 .5C5.65.5.5 5.65.5 12c0 5.09 3.29 9.4 7.86 10.93.58.1.79-.25.79-.56 0-.28-.01-1.01-.02-1.98-3.2.69-3.87-1.54-3.87-1.54-.52-1.33-1.28-1.68-1.28-1.68-1.04-.71.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.76 2.7 1.25 3.36.96.1-.75.4-1.26.73-1.55-2.55-.29-5.24-1.28-5.24-5.69 0-1.26.45-2.29 1.19-3.09-.12-.29-.51-1.47.11-3.06 0 0 .97-.31 3.18 1.18a11 11 0 0 1 5.79 0c2.21-1.49 3.18-1.18 3.18-1.18.62 1.59.23 2.77.11 3.06.74.8 1.19 1.83 1.19 3.09 0 4.42-2.69 5.4-5.25 5.68.41.36.78 1.06.78 2.14 0 1.54-.01 2.79-.01 3.17 0 .31.21.67.8.55C20.21 21.4 23.5 17.09 23.5 12 23.5 5.65 18.35.5 12 .5z" />
  </svg>
)

export default function OpenSource() {
  return (
    <section id="opensource">
      <div className="sec-eyebrow">Open Source · 03</div>
      <h2 className="sec-title">Free forever. <span className="em">Hackable, too.</span></h2>
      <p className="sec-sub">
        DotPad is fully open source under the MIT license. Read the source, file an issue, ship a PR,
        or fork it into your own thing. Built in the open, shipped for everyone.
      </p>

      <div className="osgrid">
        <a href={REPO} target="_blank" rel="noopener noreferrer" className="oscard">
          <div className="oscard-head">
            <GitHubIcon />
            <div className="oscard-meta">
              <div className="mono" style={{ fontSize: '11px', letterSpacing: '.14em', textTransform: 'uppercase', color: 'var(--ink-quiet)' }}>GitHub</div>
              <div style={{ fontWeight: 600, letterSpacing: '-0.01em' }}>sabiehahmed/dotpad-pro</div>
            </div>
          </div>
          <p>Star us, file an issue, or open a PR. We review every contribution.</p>
          <div className="oscard-stats">
            <span><b>4.2k</b> ★</span>
            <span><b>318</b> forks</span>
            <span><b>24</b> contributors</span>
          </div>
        </a>

        <a href={`${REPO}/blob/main/LICENSE`} target="_blank" rel="noopener noreferrer" className="oscard">
          <div className="oscard-head">
            <span className="oscard-glyph" style={{ color: 'var(--d-yellow)' }}>{'{ }'}</span>
            <div className="oscard-meta">
              <div className="mono" style={{ fontSize: '11px', letterSpacing: '.14em', textTransform: 'uppercase', color: 'var(--ink-quiet)' }}>License</div>
              <div style={{ fontWeight: 600, letterSpacing: '-0.01em' }}>MIT, no strings</div>
            </div>
          </div>
          <p>Use it, modify it, redistribute it. Free for personal and commercial use.</p>
          <div className="oscard-stats">
            <span><b>SPDX:</b> MIT</span>
            <span><b>©</b> 2024–2026</span>
          </div>
        </a>

        <a href="https://ko-fi.com/sabiehahmed" target="_blank" rel="noopener noreferrer" className="oscard">
          <div className="oscard-head">
            <span className="oscard-glyph" style={{ color: 'var(--d-magenta)' }}>♥</span>
            <div className="oscard-meta">
              <div className="mono" style={{ fontSize: '11px', letterSpacing: '.14em', textTransform: 'uppercase', color: 'var(--ink-quiet)' }}>Sponsor</div>
              <div style={{ fontWeight: 600, letterSpacing: '-0.01em' }}>Buy us a coffee</div>
            </div>
          </div>
          <p>DotPad is free, but caffeine is not. Sponsor on GitHub or Ko-fi if it sparks joy.</p>
          <div className="oscard-stats">
            <span><b>312</b> sponsors</span>
            <span><b>$4</b>+ / month</span>
          </div>
        </a>
      </div>
    </section>
  )
}
