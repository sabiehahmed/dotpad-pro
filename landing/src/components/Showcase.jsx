export default function Showcase() {
  return (
    <section id="showcase">
      <div className="sec-eyebrow">Showcase · 02</div>
      <h2 className="sec-title">Built for the way <span className="em">you actually work.</span></h2>
      <p className="sec-sub">
        Whether you're capturing a quick thought or drafting a deep technical doc — DotPad keeps
        pace without ever asking for your full attention.
      </p>

      <div className="showcase">
        <div className="showstage">
          <div className="show-grid">

            <div className="show-card">
              <div className="feat-head">
                <span className="fdot" style={{ background: 'var(--d-purple)', boxShadow: '0 0 8px var(--d-purple)' }} />
                Capture
              </div>
              <h3 style={{ fontSize: '24px', fontWeight: 600, letterSpacing: '-0.02em', margin: '14px 0 8px' }}>
                From thought to text in{' '}
                <span className="serif" style={{ color: 'var(--d-yellow)', fontSize: '28px' }}>200ms.</span>
              </h3>
              <p style={{ color: 'var(--ink-dim)', fontSize: '14px', lineHeight: 1.5, margin: 0 }}>
                Global hotkey, instant focus, no animations getting in the way. Type. Done.
              </p>
              <div style={{ marginTop: 'auto', paddingTop: '24px', display: 'flex', gap: '8px', alignItems: 'center', fontFamily: "'Geist Mono',monospace", fontSize: '12px', color: 'var(--ink-quiet)' }}>
                <span style={{ border: '1px solid var(--hair-strong)', padding: '4px 8px', borderRadius: '6px' }}>⌘</span>
                <span style={{ border: '1px solid var(--hair-strong)', padding: '4px 8px', borderRadius: '6px' }}>⇧</span>
                <span style={{ border: '1px solid var(--hair-strong)', padding: '4px 8px', borderRadius: '6px' }}>D</span>
              </div>
            </div>

            <div className="show-card" style={{ background: 'linear-gradient(180deg,#1a0f1a,#0a070d)' }}>
              <div className="feat-head">
                <span className="fdot" style={{ background: 'var(--d-magenta)', boxShadow: '0 0 8px var(--d-magenta)' }} />
                Organize
              </div>
              <h3 style={{ fontSize: '24px', fontWeight: 600, letterSpacing: '-0.02em', margin: '14px 0 8px' }}>
                No folders.{' '}
                <span className="serif" style={{ color: 'var(--d-magenta)', fontSize: '28px' }}>No files.</span>
              </h3>
              <p style={{ color: 'var(--ink-dim)', fontSize: '14px', lineHeight: 1.5, margin: 0 }}>
                Ten dots is enough. We promise. (We tested with twelve.)
              </p>
              <div style={{ marginTop: 'auto', paddingTop: '24px', display: 'flex', gap: '6px' }}>
                {['var(--d-yellow)', 'var(--d-magenta)', 'var(--d-blue)', 'var(--d-mint)', 'var(--d-orange)'].map((c, i) => (
                  <span key={i} className="d" style={{ '--c': c, width: '16px', height: '16px' }} />
                ))}
              </div>
            </div>

            <div className="show-card">
              <div className="feat-head">
                <span className="fdot" style={{ background: 'var(--d-cyan)', boxShadow: '0 0 8px var(--d-cyan)' }} />
                Sync
              </div>
              <h3 style={{ fontSize: '24px', fontWeight: 600, letterSpacing: '-0.02em', margin: '14px 0 8px' }}>
                iCloud sync.{' '}
                <span className="serif" style={{ color: 'var(--d-cyan)', fontSize: '28px' }}>End&#8209;to&#8209;end.</span>
              </h3>
              <p style={{ color: 'var(--ink-dim)', fontSize: '14px', lineHeight: 1.5, margin: 0 }}>
                Your dots follow you across every Mac, iPhone, and iPad. Encrypted on-device.
              </p>
              <div style={{ marginTop: 'auto', paddingTop: '24px', display: 'flex', gap: '10px', alignItems: 'center', color: 'var(--ink-quiet)', fontFamily: "'Geist Mono',monospace", fontSize: '11px' }}>
                <span style={{ width: '8px', height: '8px', borderRadius: '50%', background: 'var(--d-mint)', boxShadow: '0 0 8px var(--d-mint)', animation: 'pulseGlow 1.6s ease-in-out infinite' }} />
                <span>SYNCED · 3 DEVICES</span>
              </div>
            </div>

          </div>
        </div>
      </div>
    </section>
  )
}
