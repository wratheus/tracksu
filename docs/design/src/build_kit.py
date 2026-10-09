from icons import ic, bevel, mode
css = open('base.css').read()
SURF='#19161E'; CONT='#292430'

def sw(name, hexv, note=''):
    return f'<div class="sw"><div class="c" style="background:{hexv};box-shadow:inset 0 0 0 1px rgba(128,128,128,.18)"></div><div class="t"><b>{name}</b><span class="mono">{hexv}</span>{f"<span class=cap>{note}</span>" if note else ""}</div></div>'

dark = [('primary','#F28BB7','actions, focus, selection'),('onPrimary','#3E0924',''),('primaryContainer','#51243C','selected rows, nav pill'),('onPrimaryContainer','#FFD9E6',''),
        ('secondary','#C6B5E0',''),('secondaryContainer','#352D45','secondary buttons, info'),('tertiary','#E3C27B','ranks, highlights'),('surface','#19161E','page background'),
        ('surfaceContainerLowest','#131116',''),('surfaceContainerLow','#211D27','cards, nav bar'),('surfaceContainer','#292430','sheets, segmented track'),('surfaceContainerHigh','#332D3B','option rows'),
        ('surfaceContainerHighest','#3D3545','pickers, fields'),('onSurface','#F1EAF2','text'),('onSurfaceVariant','#C7BBCD','secondary text'),('outline','#95879F',''),('outlineVariant','#4D4158','dividers')]
light = [('primary','#A32960',''),('onPrimary','#FFFFFF',''),('primaryContainer','#FFD9E6',''),('onPrimaryContainer','#45112B',''),('secondary','#655079',''),('secondaryContainer','#ECE2F5',''),
         ('tertiary','#76571B',''),('surface','#FCF8FB',''),('surfaceContainerLow','#F6F0F6',''),('surfaceContainer','#F0EAF1',''),('surfaceContainerHigh','#EAE3EC',''),('surfaceContainerHighest','#E3DBE6',''),
         ('onSurface','#251F2B',''),('onSurfaceVariant','#65576C',''),('outline','#82718A',''),('outlineVariant','#D3C7DB','')]
status = [('success / on','#193C34','#A4DECA'),('warning / on','#443719','#F1D493')]
osu = [('pink (supporter)','#FF66AB'),('rank SS','#DE31AE'),('rank S','#02B5C3'),('rank A','#88DA20'),('rank B','#E3B130'),('rank C','#FF8E5D'),('300 great','#66CCFF'),('100 ok','#88B300'),('50 meh','#FFCC22'),('miss','#ED1121')]

def opt(label, icon_html, selected=False, parent=CONT):
    inner = (f'<div class="opt{" sel" if selected else ""}">'
             + bevel(f'<div class="chip" style="color:{"#FFD9E6" if selected else "#F28BB7"}">{icon_html}</div>', '#5a3149' if selected else '#332D3B', 8)
             + f'<b>{label}</b>' + (ic('check',20,'#FFD9E6') if selected else '') + '</div>')
    return bevel(inner, parent, 12)

boards = []
boards.append(f'''<section class="board"><h1>Tracksu · Colors (dark)</h1><p class="lead">Material 3 scheme from seed #AD366D, hand-tuned pinks and violet surfaces. Dark is the primary theme; text pairs keep contrast ≥ 4.5:1.</p>
<div class="row">{''.join(sw(*c) for c in dark)}</div>
<h2>Status</h2><div class="row">{''.join(f'<div class="sw"><div class="c" style="background:{a};display:flex;align-items:center;justify-content:center;color:{b};font-weight:600;font-size:20px">Aa</div><div class="t"><b>{n}</b><span class="mono">{a} / {b}</span></div></div>' for n,a,b in status)}</div></section>''')
boards.append(f'''<section class="board light" style="background:#FCF8FB;color:#251F2B"><h1>Tracksu · Colors (light)</h1><p class="lead" style="color:#65576C">Same roles in the light theme.</p>
<div class="row">{''.join(sw(*c) for c in light)}</div></section>''')
boards.append(f'''<section class="board"><h1>osu! colors · game marks</h1><p class="lead">Game colors, separate from UI roles: grades, hit results, the supporter pink. Used only for osu! data.</p>
<div class="row">{''.join(sw(n,h) for n,h in osu)}</div>
<h2>Grade badges</h2><div class="row">{''.join(f'<div class="grade" style="background:{c}">{g}</div>' for g,c in [('SS','#DE31AE'),('S','#02B5C3'),('A','#88DA20'),('B','#E3B130'),('C','#FF8E5D'),('D','#ED1121')])}</div>
<h2>Game modes · app-bar button (ADR-011)</h2><div class="row">{''.join(f'<div class="col" style="align-items:center;gap:6px"><div class="ib" style="background:var(--cont)">{mode(k)}</div><span class="cap">{l}</span></div>' for k,l in [('osu','ctd'),('taiko','taiko'),('fruits','catch'),('mania','mania')])}</div>
<p class="cap">Stand-ins for the osu! mode glyphs in assets/icon_game_mods.</p></section>''')
types = [('displaySmall','Exo 2 · 32 / 600','Map of the day'),('headlineSmall','Exo 2 · 22 / 600','Article headline'),('titleLarge','Exo 2 · 20 / 600','App bar title'),
         ('titleMedium','SF / Inter · 16 / 600','Section title'),('titleSmall','SF / Inter · 14 / 500','Option row label'),('bodyLarge','16 / 1.5','Long text'),('bodyMedium','14 / 1.45','Default body text in lists and articles.'),
         ('bodySmall','12 / 1.4','Captions, timestamps, secondary facts'),('labelLarge','14 / 600','Button label'),('labelSmall','11 / 500','Picker caption')]
sizes = {'displaySmall':(32,600,'Exo 2'),'headlineSmall':(22,600,'Exo 2'),'titleLarge':(20,600,'Exo 2'),'titleMedium':(16,600,'Inter'),'titleSmall':(14,500,'Inter'),'bodyLarge':(16,400,'Inter'),'bodyMedium':(14,400,'Inter'),'bodySmall':(12,400,'Inter'),'labelLarge':(14,600,'Inter'),'labelSmall':(11,500,'Inter')}
boards.append('<section class="board"><h1>Typography</h1><p class="lead">Headings in Exo 2 (bundled, tabular figures); body in the platform font (SF Pro on iOS, shown as Inter). App-bar titles stay regular size, never large titles (ADR-010).</p>' + ''.join(
  f'<div class="row" style="align-items:baseline;gap:24px;border-top:1px solid var(--outlinev);padding-top:12px;flex-wrap:nowrap"><div style="width:200px;flex-shrink:0" class="col"><b style="font-size:13px">{n}</b><span class="mono">{spec}</span></div><div style="font-family:\'{sizes[n][2]}\';font-size:{sizes[n][0]}px;font-weight:{sizes[n][1]}">{sample}</div></div>' for n,spec,sample in types) + '</section>')
sp = [('xs',4),('sm',8),('md',12),('lg',16),('xl',24),('xxl',32)]
boards.append(f'''<section class="board"><h1>Spacing · shape · motion</h1>
<h2>UiSpace</h2><div class="row" style="align-items:flex-end">{''.join(f'<div class="col" style="align-items:center;gap:6px"><div style="width:{v}px;height:{v}px;background:var(--primary);border-radius:2px"></div><span class="mono">{n} {v}</span></div>' for n,v in sp)}</div>
<h2>UiShape</h2><div class="row">
<div class="col" style="align-items:center"><div style="width:120px;height:56px;border-radius:12px;background:var(--high)"></div><span class="mono">control 12</span></div>
<div class="col" style="align-items:center"><div style="width:120px;height:80px;border-radius:16px;background:var(--low)"></div><span class="mono">card 16</span></div>
<div class="col" style="align-items:center"><div style="width:120px;height:80px;border-radius:24px 24px 0 0;background:var(--cont)"></div><span class="mono">sheet 24 (top)</span></div>
<div class="col" style="align-items:center">{bevel('<div style="width:120px;height:56px;background:#332D3B"></div>', SURF)}<span class="mono">chamfer 12 (TL·BR)</span></div>
<div class="col" style="align-items:center"><div style="width:48px;height:48px;border:1px dashed var(--outline);border-radius:8px"></div><span class="mono">minTarget 48</span></div></div>
<h2>UiMotion</h2><div class="list">
{''.join(f'<div class="tile"><div class="tt"><b>{a}</b><span>{b}</span></div><div class="v mono">{c}</div></div>' for a,b,c in [('reveal','Content fades in over its placeholder (easeOutCubic) — only after a real load, never for a ready page.','260 ms'),('skeletonEntry','Placeholders wait ~130 ms, then fade in: fast loads never flash them.','330 ms'),('skeletonPulse','One dim-and-restore cycle; static under reduced motion.','1400 ms'),('progressDelay','App-bar progress line appears only for slow answers…','600 ms'),('progressMinVisible','…and then stays at least this long.','400 ms')])}
</div></section>''')
segs = lambda items, on, w='100%': f'<div class="seg" style="width:{w}">' + ''.join(f'<div class="{"on" if i==on else ""}">{ic(icn,16)} {l}</div>' for i,(icn,l) in enumerate(items)) + '</div>'
picker = bevel(f'''<div style="width:360px;background:rgba(61,53,69,.72);box-shadow:inset 0 0 0 1px rgba(241,234,242,.1);display:flex;align-items:center;gap:12px;padding:8px 12px">
{bevel(f'<div style="width:36px;height:36px;background:#51243C;display:flex;align-items:center;justify-content:center;color:#FFD9E6">{ic("bolt",18)}</div>', '#352F3E', 8)}
<div class="col" style="gap:0;flex:1"><span style="font-size:11px;color:var(--onv);font-weight:500">Filter</span><b style="font-size:14px">All events</b></div><span style="color:var(--onv)">{ic("unfold",18)}</span></div>''', SURF, style='width:fit-content')
boards.append(f'''<section class="board"><h1>Buttons · controls</h1>
<div class="row"><span class="btn primary">{ic("plus",18)} Primary</span><span class="btn secondary">{ic("expand",18)} Secondary</span><span class="btn text">{ic("open",18)} Text</span><span class="btn primary dis">Disabled</span></div>
<h2>UiSegmentedControl · glass thumb, follows the swipe</h2>
{segs([('news','News'),('bolt','Events'),('forum','Forum'),('update','Changes')],0)}
{segs([('bolt','PP'),('chart','Score')],0,'420px')}
<h2>UiSwitch · settings rows</h2>
<div class="list" style="width:520px"><div class="tile"><div class="ti">{ic("image",18)}</div><div class="tt"><b>Load images</b><span>Covers, avatars and article images</span></div><div class="switch on"><i></i></div></div>
<div class="tile"><div class="ti">{ic("play",18)}</div><div class="tt"><b>Autoplay previews</b></div><div class="switch"><i></i></div></div>
<div class="tile"><div class="ti">{ic("globe",18)}</div><div class="tt"><b>Language</b></div><div class="v">English</div><div class="chev">{ic("chev",18)}</div></div></div>
<h2>OsuCategoryPicker · chamfered glass button</h2>{picker}
</section>''')
appbar = lambda title, acts, back=True: f'''<div style="width:393px;border-radius:16px;overflow:hidden;background:var(--surface);box-shadow:0 0 0 1px var(--outlinev)"><div class="appbar">{f'<div class="back">{ic("back",18)}</div>' if back else ''}<div class="title">{title}</div>{acts}</div>{'<div class="progress"></div>' if back else ''}</div>'''
acc = '<div class="ib"><div class="avatar"></div></div>'
nav = lambda on: '<div class="nav">' + ''.join(f'<div class="d{" on" if i==on else ""}"><div class="pill">{ic(n,20)}</div>{l}</div>' for i,(n,l) in enumerate([('home','Home'),('chart','Rankings'),('compass','osu!')])) + f'<div class="s{" on" if on==3 else ""}">{ic("search",22)}</div></div>'
boards.append(f'''<section class="board"><h1>App bar · navigation</h1><p class="lead">The title names the place, not the item. Actions: [mode] · share · account (ADR-010, ADR-011). Custom back button; the 3 pt progress line sits under the bar. Bottom bar: Home / Rankings / osu! and the round Search tab (iOS 26).</p>
{appbar('Rankings', f'<div class="ib">{mode("osu")}</div><div class="ib">{ic("share")}</div>{acc}')}
{appbar('Tracksu', f'<div class="ib">{ic("share")}</div><div class="ib">{ic("person")}</div>', back=False)}
<div style="width:393px;border-radius:16px;overflow:hidden">{nav(0)}</div>
<p class="cap">Keyboard: the bar stays under it and fades by the covered fraction; pages see only the keyboard above the bar.</p>
</section>''')
modes=[('osu','ctd'),('taiko','taiko'),('fruits','catch'),('mania','mania')]
boards.append(f'''<section class="board"><h1>Sheets · option rows</h1><p class="lead">Sheets fit their content, have no close button (swipe or tap outside) and never open exactly at the minimum height. Choices are UiOptionRow: chamfered card, icon chip, accent fill and a check when selected.</p>
<div class="row"><div style="width:393px" class="sheet"><div class="grab"></div><h3>Game mode</h3>
{''.join(opt(l, mode(k,20), k=='osu') for k,l in modes)}</div>
<div style="width:393px" class="sheet"><div class="grab"></div><h3>Previously known as</h3>
{''.join(opt(n, ic('history',18)) for n in ['Rafis','-Rafis-','RafisLeaves'])}</div></div>
</section>''')
boards.append(f'''<section class="board"><h1>Lists · cards · rows</h1>
<div class="row"><div class="col" style="width:400px">
<h2>Ranking row</h2><div class="list">
{''.join(f'<div class="tile"><span style="width:30px;font-family:Exo 2;font-weight:700;color:{c}">#{i}</span><div class="avatar" style="width:36px;height:36px;border-radius:8px"></div><div class="tt"><b>{n}</b><span>{cc} · {a}% acc</span></div><b style="font-family:Exo 2">{pp}pp</b></div>' for i,n,cc,a,pp,c in [(1,'mrekk','AU','98.31','27 412','#E3C27B'),(2,'lifeline','US','97.88','25 905','#C7BBCD'),(3,'Accolibed','KR','98.02','25 120','#C68A5E')])}</div>
<h2>Event row · lazy feed in one card</h2><div class="list">
{''.join(f'<div class="tile"><div class="grade" style="background:{c};width:36px">{g}</div><div class="tt"><b style="font-size:14px">{t}</b><span>{w}</span></div></div>' for g,c,t,w in [('S','#02B5C3','WhiteCat got rank #12 on Blue Zenith [FOUR DIMENSIONS]','2 min ago'),('A','#88DA20','Rafis got rank #48 on Freedom Dive [FOUR DIMENSIONS]','5 min ago')])}</div>
</div><div class="col" style="width:380px">
<h2>Beatmap pack row · type tint</h2>
<div class="card" style="background:linear-gradient(135deg,#3a2433,#211D27);display:flex;gap:12px;align-items:center"><div class="ti">{ic("star",18)}</div><div class="col" style="gap:2px;flex:1"><b style="font-size:14px">S1500 · Beatmap Pack #1500</b><span class="cap">2026-09-30 · by Stixy · ctd</span></div></div>
<h2>Map of the day poster</h2>
<div style="height:220px;border-radius:16px;background:linear-gradient(160deg,#6b3a5c,#2a1f35 60%,#19161E);padding:16px;display:flex;flex-direction:column;justify-content:space-between">
<div class="row" style="gap:8px"><span class="glass" style="height:28px;font-size:12px;padding:0 10px;color:var(--on)">{ic("calendar",14)} Today</span><span class="glass" style="height:28px;font-size:12px;padding:0 10px;color:var(--on)">{ic("clock",14)} 6 h left</span></div>
<div class="col" style="gap:4px"><b style="font-family:Exo 2;font-size:22px">Cyber Inductance</b><span class="cap" style="color:var(--on)">Camellia · [Insane] · ★ 5.42 · HD</span></div></div>
<h2>Notices</h2><div class="notice info">{ic("info",18)} Loading the selected mode. Previous data stays shown.</div><div class="notice warn">{ic("warn",18)} The map of the day could not be loaded. Retry</div><div class="notice ok">{ic("check",18)} Cache cleared</div>
</div></div></section>''')
boards.append(f'''<section class="board"><h1>States · search</h1><p class="lead">Placeholders only on the first load, never over usable content. Refresh keeps content and shows the app-bar line. Search is a Liquid Glass capsule floating over results, above the keyboard.</p>
<div class="row"><div class="card col" style="width:400px"><div class="sk" style="height:120px"></div>{''.join('<div class="row" style="gap:12px;align-items:center;flex-wrap:nowrap"><div class="sk" style="width:40px;height:40px"></div><div class="col" style="flex:1;gap:6px"><div class="sk" style="height:12px;width:70%"></div><div class="sk" style="height:10px;width:40%"></div></div></div>' for _ in range(3))}<span class="cap">UiPageSkeleton.profile</span></div>
<div class="col" style="width:400px"><div class="card col" style="align-items:center;gap:8px;padding:24px">{ic("search",28,"#C7BBCD")}<b>Nothing found</b><span class="cap">Try another name or tag</span></div>
<div class="card col" style="align-items:center;gap:8px;padding:24px">{ic("warn",28,"#FFB4AB")}<b>Couldn't load</b><span class="cap">Check the connection</span><span class="btn secondary" style="height:40px">Retry</span></div></div></div>
<h2>UiSearchBar · Liquid Glass</h2><div class="row" style="background:linear-gradient(135deg,#3b2a4a,#5a2d45 50%,#1f2a44);padding:24px;border-radius:16px;width:816px">
<div class="glass" style="width:360px">{ic("search",20)} <span>Players, maps, wiki</span></div><div class="glass focus" style="width:360px">{ic("search",20)} <span>cookiezi</span><span style="margin-left:auto">{ic("clear",20)}</span></div></div>
</section>''')
html = f'<!doctype html><html><head><meta charset="utf-8"><title>Tracksu UI kit</title><style>{css}</style></head><body>{"".join(boards)}</body></html>'
open('kit.html','w').write(html)
print(len(boards), len(html))
