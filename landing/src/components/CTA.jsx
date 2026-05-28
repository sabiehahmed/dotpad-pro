const AppleIcon = () => (
  <svg width="14" height="14" viewBox="0 0 24 24" fill="currentColor">
    <path d="M17.05 20.28c-.98.95-2.05.88-3.08.41-1.09-.47-2.09-.48-3.24 0-1.44.62-2.2.44-3.06-.41C2.79 15.25 3.51 7.59 9.05 7.31c1.35.07 2.29.74 3.08.8 1.18-.24 2.31-.93 3.57-.84 1.51.12 2.65.72 3.4 1.8-3.12 1.87-2.38 5.98.48 7.13-.57 1.5-1.31 2.99-2.53 4.08zM12.03 7.25c-.15-2.23 1.66-4.07 3.74-4.25.29 2.58-2.34 4.5-3.74 4.25z" />
  </svg>
)

export default function CTA() {
  return (
    <section className="cta" id="download">
      <h2>
        Your next thought<br />
        deserves a <span className="em">good home.</span>
      </h2>
      <p>Free, open source, and made with care. No accounts. No tracking. No nonsense.</p>
      <div className="hero-actions">
        <a className="btn btn-primary" href="https://github.com/sabiehahmed/dotpad-pro/releases" target="_blank" rel="noopener noreferrer">
          <AppleIcon />
          Download for Mac · 3.1 MB
        </a>
        <a className="btn" href="https://github.com/sabiehahmed/dotpad-pro" target="_blank" rel="noopener noreferrer">★ Star on GitHub</a>
      </div>
    </section>
  )
}
