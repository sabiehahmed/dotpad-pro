export default function Features() {
  return (
    <section id="features">
      <div className="sec-eyebrow">Features · 01</div>
      <h2 className="sec-title">Ten dots. <span className="em">Infinite ideas.</span></h2>
      <p className="sec-sub">
        Every dot is a separate note, color&#8209;coded for the way your brain already works.
        Switch between them with a single keystroke — no folders, no clutter, no app to open.
      </p>

      <div className="features">

        {/* Color Dots */}
        <div className="feat tall">
          <div>
            <div className="feat-head">
              <span className="fdot" style={{ background: 'var(--d-magenta)', boxShadow: '0 0 8px var(--d-magenta)' }} />
              Color Dots
            </div>
            <h3>Ten quick&#8209;access notes, always one tap away.</h3>
            <p>Yellow for the day. Red for blockers. Cyan for tomorrow. Bind whatever meaning you want — DotPad doesn't care.</p>
          </div>
          <div className="viz">
            <div className="dotsviz">
              {[
                'var(--d-yellow)', 'var(--d-orange)', 'var(--d-red)', 'var(--d-magenta)',
                'var(--d-purple)', 'var(--d-blue)', 'var(--d-cyan)', 'var(--d-mint)',
                'var(--d-amber)', 'var(--d-rose)',
              ].map((c, i) => (
                <span key={i} className="d" style={{ '--c': c }} />
              ))}
            </div>
          </div>
        </div>

        {/* Smart Bullets */}
        <div className="feat wide tall">
          <div>
            <div className="feat-head">
              <span className="fdot" style={{ background: 'var(--d-mint)', boxShadow: '0 0 8px var(--d-mint)' }} />
              Smart Bullets
            </div>
            <h3>
              Type a dash, get a list. Type <span className="mono" style={{ color: 'var(--d-yellow)' }}>[x]</span>, get a check.
            </h3>
            <p>DotPad understands shorthand. Bullets, checks, dividers, stars — all from plain keystrokes, all rendered live.</p>
          </div>
          <div className="viz">
            <div className="bulletsviz" style={{ maxWidth: '520px' }}>
              <div className="b"><span className="bg-circ" /><span>open the dot picker</span></div>
              <div className="b"><span className="bg-fill" /><span>ship to TestFlight</span></div>
              <div className="b"><span className="bg-check" /><span className="strike">finish the spec doc</span></div>
              <div className="b"><span className="bg-star">★</span><span>idea: rainbow theme pack</span></div>
              <div className="b"><span className="bg-sq" /><span>review the changelog</span></div>
              <div className="b"><span className="bg-tri" /><span>followup with marketing</span></div>
            </div>
          </div>
        </div>

        {/* Menu Bar */}
        <div className="feat">
          <div>
            <div className="feat-head">
              <span className="fdot" style={{ background: 'var(--d-yellow)', boxShadow: '0 0 8px var(--d-yellow)' }} />
              Lives Up There
            </div>
            <h3>Always open. Never in the way.</h3>
            <p>DotPad ships with a global hotkey and a one-pixel footprint. Your dock stays clean.</p>
          </div>
          <div className="viz">
            <div className="barviz">
              <span>⌘⇧D</span>
              <span className="pulse" />
              <span>3:21 PM</span>
            </div>
          </div>
        </div>

        {/* Themes */}
        <div className="feat">
          <div>
            <div className="feat-head">
              <span className="fdot" style={{ background: 'var(--d-orange)', boxShadow: '0 0 8px var(--d-orange)' }} />
              Themes
            </div>
            <h3>Vibrant, dark, or paper&#8209;white.</h3>
            <p>Three built-in themes plus full custom support. Optionally tint the background to match your active dot.</p>
          </div>
          <div className="viz">
            <div className="themeviz">
              <div className="tcard dark">
                <div className="ttitle">
                  <span className="tdot" style={{ background: 'var(--d-magenta)' }} />
                  Dark
                </div>
                echo &quot;hi&quot;<br />// 3 lines<br />// 12 words
              </div>
              <div className="tcard light">
                <div className="ttitle" style={{ color: '#7a6a4a' }}>
                  <span className="tdot" style={{ background: 'var(--d-orange)' }} />
                  Paper
                </div>
                echo &quot;hi&quot;<br />// 3 lines<br />// 12 words
              </div>
              <div className="tcard coffee">
                <div className="ttitle" style={{ color: '#c89a5c' }}>
                  <span className="tdot" style={{ background: 'var(--d-amber)' }} />
                  Coffee
                </div>
                echo &quot;hi&quot;<br />// 3 lines<br />// 12 words
              </div>
            </div>
          </div>
        </div>

        {/* Markdown */}
        <div className="feat wide">
          <div>
            <div className="feat-head">
              <span className="fdot" style={{ background: 'var(--d-cyan)', boxShadow: '0 0 8px var(--d-cyan)' }} />
              Markdown Native
            </div>
            <h3>Write in Markdown. Export anywhere.</h3>
            <p>Live formatting, syntax-aware highlighting, and one-click export to .md, .pdf, .html, or your clipboard.</p>
          </div>
          <div className="viz">
            <div className="mdviz" style={{ maxWidth: '520px' }}>
              <div><span className="hashes"># Q3 Roadmap</span></div>
              <div><span className="hashes">##</span> goals</div>
              <div><span className="ast">**</span><em>ship dot v2</em><span className="ast">**</span> — themes &amp; bullets</div>
              <div>see <span className="lnk">[changelog](v2.md)</span></div>
              <div style={{ opacity: 0.4 }}>---</div>
              <div>- launch on <span className="lnk">producthunt</span></div>
            </div>
          </div>
        </div>

      </div>
    </section>
  )
}
