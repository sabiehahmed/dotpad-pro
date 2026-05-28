const GitHubIcon = () => (
  <svg width="15" height="15" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true">
    <path d="M12 .5C5.65.5.5 5.65.5 12c0 5.09 3.29 9.4 7.86 10.93.58.1.79-.25.79-.56 0-.28-.01-1.01-.02-1.98-3.2.69-3.87-1.54-3.87-1.54-.52-1.33-1.28-1.68-1.28-1.68-1.04-.71.08-.7.08-.7 1.16.08 1.77 1.19 1.77 1.19 1.03 1.76 2.7 1.25 3.36.96.1-.75.4-1.26.73-1.55-2.55-.29-5.24-1.28-5.24-5.69 0-1.26.45-2.29 1.19-3.09-.12-.29-.51-1.47.11-3.06 0 0 .97-.31 3.18 1.18a11 11 0 0 1 5.79 0c2.21-1.49 3.18-1.18 3.18-1.18.62 1.59.23 2.77.11 3.06.74.8 1.19 1.83 1.19 3.09 0 4.42-2.69 5.4-5.25 5.68.41.36.78 1.06.78 2.14 0 1.54-.01 2.79-.01 3.17 0 .31.21.67.8.55C20.21 21.4 23.5 17.09 23.5 12 23.5 5.65 18.35.5 12 .5z" />
  </svg>
)

export default function Nav() {
  return (
    <nav className="nav">
      <div className="brand">
        <span className="brand-dot" />
        <span>DotPad</span>
      </div>
      <div className="nav-links">
        <a href="#features">Features</a>
        <a href="#showcase">Showcase</a>
        <a href="#opensource">Open Source</a>
        <a href="#changelog">Changelog</a>
      </div>
      <div className="nav-cta">
        <a className="btn btn-primary" href="https://github.com/sabiehahmed/dotpad-pro/releases" target="_blank" rel="noopener noreferrer">
          Download <span style={{ opacity: 0.6 }}>↓</span>
        </a>
        <a
          className="btn"
          href="https://github.com/sabiehahmed/dotpad-pro"
          target="_blank"
          rel="noopener noreferrer"
          aria-label="GitHub"
          style={{ padding: '10px', width: '38px', height: '38px', justifyContent: 'center' }}
        >
          <GitHubIcon />
        </a>
      </div>
    </nav>
  )
}
