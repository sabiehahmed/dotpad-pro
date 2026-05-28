export default function TrustStrip() {
  return (
    <div className="trust-strip">
      <div
        className="trust-inner"
        style={{
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'space-between',
          gap: '30px',
          flexWrap: 'wrap',
          color: 'var(--ink-quiet)',
          fontFamily: "'Geist Mono', monospace",
          fontSize: '12px',
          letterSpacing: '.15em',
          textTransform: 'uppercase',
        }}
      >
        <span>Loved by 42,000+ writers, devs, and PMs</span>
        <span
          className="trust-logos"
          style={{ display: 'flex', gap: '30px', alignItems: 'center', flexWrap: 'wrap' }}
        >
          <span>· Product Hunt #1</span>
          <span>· Setapp Featured</span>
          <span>· The Verge</span>
          <span>· Daring Fireball</span>
          <span>· Hacker News (1.2k ▲)</span>
        </span>
      </div>
    </div>
  )
}
