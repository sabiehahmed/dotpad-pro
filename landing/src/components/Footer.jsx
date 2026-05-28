export default function Footer() {
  return (
    <footer>
      <div className="brand">
        <span className="brand-dot" />
        <span>DotPad</span>
        <span className="mono" style={{ color: 'var(--ink-quiet)', marginLeft: '10px' }}>v2.0.4</span>
      </div>
      <div className="links">
        <a href="#">Privacy</a>
        <a href="#">Terms</a>
        <a href="#">Changelog</a>
        <a href="#">Support</a>
        <a href="#">@dotpadapp</a>
      </div>
      <div className="mono">© 2026 DotPad Labs · Made with ⌘⇧D</div>
    </footer>
  )
}
