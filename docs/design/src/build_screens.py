from icons import ic, bevel, mode
css = open('base.css').read() + '''
body { display:flex; flex-wrap:wrap; gap:48px; width: 2400px; }
.phone { width:393px; height:852px; background:var(--surface); border-radius:44px; overflow:hidden; position:relative; display:flex; flex-direction:column; box-shadow: 0 0 0 10px #000, 0 0 0 11px #333; }
.status { height:54px; display:flex; align-items:flex-end; justify-content:space-between; padding: 0 32px 8px 40px; font-size:16px; font-weight:600; }
.body { flex:1; overflow:hidden; padding: 0 16px; display:flex; flex-direction:column; gap:16px; }
.phone .nav { position:absolute; bottom:0; left:0; right:0; height:96px; }
.label { position:absolute; top:-34px; left:4px; font-family:'Exo 2'; font-weight:600; font-size:18px; color:#C7BBCD; }
.wrap { position:relative; margin-top:40px; }
.secttl { display:flex; justify-content:space-between; align-items:center; }
.secttl b { font-family:'Exo 2'; font-size:18px; font-weight:600; }
.secttl span { font-size:13px; color: var(--primary); font-weight:600; }
.scrim { position:absolute; inset:0; background: rgba(0,0,0,.5); }
'''
SURF='#19161E'
acc = '<div class="ib"><div class="avatar"></div></div>'
def appbar(title, acts='', back=True, progress=False):
    return f'''<div class="appbar">{f'<div class="back">{ic("back",18)}</div>' if back else ''}<div class="title">{title}</div>{acts}</div>{'<div class="progress"></div>' if progress else ''}'''
def nav(on):
    return '<div class="nav">' + ''.join(f'<div class="d{" on" if i==on else ""}"><div class="pill">{ic(n,20)}</div>{l}</div>' for i,(n,l) in enumerate([('home','Home'),('chart','Rankings'),('compass','osu!')])) + f'<div class="s{" on" if on==3 else ""}">{ic("search",22)}</div></div>'
def seg(items, on):
    return '<div class="seg">' + ''.join(f'<div class="{"on" if i==on else ""}">{ic(icn,15) if icn else ""} {l}</div>' for i,(icn,l) in enumerate(items)) + '</div>'
def phone(label, inner, navon=None, extra=''):
    return f'<div class="wrap"><div class="label">{label}</div><div class="phone"><div class="status"><span>9:41</span><span style="font-size:13px">●●● ▮</span></div>{inner}{nav(navon) if navon is not None else ""}{extra}</div></div>'
def share(): return f'<div class="ib">{ic("share")}</div>'
def rrow(i,n,cc,a,pp,c):
    return f'<div class="tile"><span style="width:34px;font-family:Exo 2;font-weight:700;color:{c}">#{i}</span><div class="avatar" style="width:36px;height:36px;border-radius:8px;background:linear-gradient(135deg,{["#8a5cf6","#06b6d4","#f59e0b","#ec4899","#10b981","#6366f1"][i%6]},#2a2433)"></div><div class="tt"><b>{n}</b><span>{cc} · {a}% · {int(pp.replace(" ",""))//7} plays</span></div><b style="font-family:Exo 2;font-size:15px">{pp}</b></div>'
picker = lambda cap,val,icn: bevel(f'''<div style="background:rgba(61,53,69,.72);box-shadow:inset 0 0 0 1px rgba(241,234,242,.1);display:flex;align-items:center;gap:12px;padding:8px 12px">
{bevel(f'<div style="width:36px;height:36px;background:#51243C;display:flex;align-items:center;justify-content:center;color:#FFD9E6">{ic(icn,18)}</div>', '#352F3E', 8)}
<div class="col" style="gap:0;flex:1"><span style="font-size:11px;color:var(--onv);font-weight:500">{cap}</span><b style="font-size:14px">{val}</b></div><span style="color:var(--onv)">{ic("unfold",18)}</span></div>''', SURF)
poster = lambda h=220, today=True: f'''<div style="height:{h}px;border-radius:16px;background:linear-gradient(160deg,#7a3d63,#3a2547 55%,#1d1824);padding:16px;display:flex;flex-direction:column;justify-content:space-between;flex-shrink:0">
<div class="row" style="gap:8px"><span class="glass" style="height:28px;font-size:12px;padding:0 10px;color:var(--on)">{ic("calendar",14)} {"Today" if today else "Oct 3"}</span><span class="glass" style="height:28px;font-size:12px;padding:0 10px;color:var(--on)">{ic("clock",14)} 6 h left</span></div>
<div class="row" style="justify-content:space-between;align-items:flex-end;flex-wrap:nowrap"><div class="col" style="gap:4px"><span style="font-size:12px;color:var(--on-pc);font-weight:600">MAP OF THE DAY</span><b style="font-family:Exo 2;font-size:22px">Cyber Inductance</b><span class="cap" style="color:var(--on)">Camellia · [Insane] · ★ 5.42 · HD</span></div>
<div class="glass" style="width:44px;height:44px;padding:0;justify-content:center;color:var(--on)">{ic("play",18)}</div></div></div>'''
screens = []
# 1 Home
packs = ''.join(f'<div style="width:132px;height:96px;flex-shrink:0;border-radius:16px;background:linear-gradient(135deg,{c},#211D27);padding:12px;display:flex;flex-direction:column;justify-content:space-between"><div style="color:{t}">{ic(i,20)}</div><div class="col" style="gap:2px"><b style="font-size:13px">{n}</b><span style="font-size:11px;color:var(--onv)">{d}</span></div></div>' for n,d,i,c,t in [('Standard','Ranked by year','star','#5a2d45','#F28BB7'),('Featured Artist','Licensed music','music','#2d3f5a','#8ab4f8'),('Tournament','Mappools','trophy','#5a4a2d','#E3C27B')])
screens.append(phone('Home', appbar('Tracksu', share()+acc, back=False) + f'''<div class="body">{poster()}
<div class="secttl"><b>Beatmap packs</b><span>All</span></div><div class="row" style="flex-wrap:nowrap;gap:12px;overflow:hidden">{packs}</div>
<div class="secttl"><b>Spotlights</b><span>Open</span></div><div class="card" style="display:flex;gap:12px;align-items:center"><div class="ti">{ic("trophy",18)}</div><div class="col" style="gap:2px;flex:1"><b style="font-size:14px">Summer 2026 Spotlight</b><span class="cap">Seasonal charts · ranked maps of the season</span></div>{ic("chev",18,"#95879F")}</div></div>''', 0))
# 2 Rankings
rows = ''.join(rrow(*r) for r in [(1,'mrekk','AU','98.31','27 412','#E3C27B'),(2,'lifeline','US','97.88','25 905','#C7BBCD'),(3,'Accolibed','KR','98.02','25 120','#C68A5E'),(4,'aetrna','CA','97.40','24 830','#F1EAF2'),(5,'Rafis','PL','98.95','24 710','#F1EAF2'),(6,'WhiteCat','DE','98.12','24 556','#F1EAF2'),(7,'Mathi','CL','97.71','24 120','#F1EAF2')])
screens.append(phone('Rankings · mode in the app bar', appbar('Rankings', f'<div class="ib">{mode("osu")}</div>'+share()+acc, back=False) + f'''<div style="padding:4px 16px 0">{seg([('person','Players'),('group','Teams'),('globe','Countries'),('heart','Kudosu')],0)}</div>
<div class="body" style="padding-top:12px">{seg([('bolt','PP'),('chart','Score')],0)}{picker('Country','All countries','globe')}<div class="list">{rows}</div></div>''', 1))
# 3 Profile
screens.append(phone('Profile · player\'s own mode', appbar('Rafis', f'<div class="ib">{mode("osu")}</div>'+share()+acc) + f'''<div class="body" style="padding-top:8px">
<div style="height:120px;border-radius:16px;background:linear-gradient(135deg,#4b2a5c,#2a3a5c);position:relative"></div>
<div class="row" style="margin-top:-52px;padding:0 12px;align-items:flex-end;gap:12px;flex-wrap:nowrap"><div style="width:84px;height:84px;border-radius:16px;background:linear-gradient(135deg,#06b6d4,#8a5cf6);box-shadow:0 0 0 4px var(--surface)"></div><div class="col" style="gap:2px;padding-bottom:4px"><b style="font-family:Exo 2;font-size:22px">Rafis</b><span class="cap">Poland · joined 2009 · <span style="color:#FF66AB">♥ supporter</span></span></div></div>
<div class="row" style="gap:8px;flex-wrap:nowrap">{''.join(f'<div class="card col" style="flex:1;gap:2px;padding:12px"><span class="cap">{a}</span><b style="font-family:Exo 2;font-size:18px;color:{c}">{b}</b></div>' for a,b,c in [('Global','#5','#E3C27B'),('Country','#1','#F1EAF2'),('pp','24 710','#F28BB7')])}</div>
{seg([('','Info'),('','Top'),('','Recent'),('','Maps')],1)}
<div class="list">{''.join(f'<div class="tile"><div class="grade" style="background:{c};width:40px">{g}</div><div class="tt"><b style="font-size:14px">{t}</b><span>{d}</span></div><b style="font-family:Exo 2">{p}</b></div>' for g,c,t,d,p in [('SS','#DE31AE','Blue Zenith [FOUR DIMENSIONS]','HDHR · 100.00%','1 042pp'),('S','#02B5C3','Freedom Dive [FOUR DIMENSIONS]','HD · 99.12%','998pp'),('S','#02B5C3','Galaxy Collapse [Galaxy]','DT · 98.70%','974pp')])}</div></div>''', 1))
# 4 osu! hub events
ev = ''.join(f'<div class="tile"><div class="{"grade" if g else "ti"}" style="{"background:"+c+";width:36px" if g else ""}">{g or ic(c,18)}</div><div class="tt"><b style="font-size:14px;font-weight:400">{t}</b><span>{w}</span></div></div>' for g,c,t,w in [('S','#02B5C3','<b>WhiteCat</b> got rank #12 on Blue Zenith','2 min ago'),('','medal','<b>Mathi</b> unlocked the "Jackpot" medal','4 min ago'),('A','#88DA20','<b>Rafis</b> got rank #48 on Freedom Dive','5 min ago'),('','music','<b>Sotarks</b> updated "Kimi no Shiranai…"','9 min ago'),('','heart','<b>aetrna</b> became a supporter again','12 min ago'),('SS','#DE31AE','<b>mrekk</b> got rank #1 on Galaxy Collapse','15 min ago')])
screens.append(phone('osu! · Events', appbar('osu!', share()+acc, back=False) + f'''<div style="padding:4px 16px 0">{seg([('news','News'),('bolt','Events'),('forum','Forum'),('update','Changes')],1)}</div>
<div class="body" style="padding-top:12px">{picker('Filter','All events','bolt')}<div class="list">{ev}</div></div>''', 2))
# 5 Article + comments
screens.append(phone('News article · comments', appbar('News', share()+acc) + f'''<div class="body" style="padding-top:8px">
<b style="font-family:Exo 2;font-size:22px;line-height:1.25">osu! World Cup 2026: the finals are set</b>
<div class="row" style="gap:16px"><span style="font-size:14px;color:var(--primary);font-weight:600">Hivie</span><span class="cap">Oct 8, 2026</span></div>
<div style="height:170px;border-radius:12px;background:linear-gradient(135deg,#2d3f5a,#5a2d45);flex-shrink:0"></div>
<p style="font-size:14px;line-height:1.45">After three weekends of qualifiers, eight teams remain. The mappool for the grand finals features maps from the Featured Artist library…</p>
<div class="secttl"><b>Comments · 128</b>{picker('Sort','Newest','update').replace('padding:8px 12px','padding:4px 10px')}</div>
{''.join(f'<div class="row" style="gap:12px;flex-wrap:nowrap"><div class="avatar" style="width:32px;height:32px;border-radius:8px;flex-shrink:0"></div><div class="col" style="gap:4px"><span style="font-size:13px;font-weight:600">{n} <span class="cap">· {t}</span></span><span style="font-size:14px;line-height:1.4">{c}</span></div></div>' for n,t,c in [('btmc','1 h','that pool is insane, cant wait'),('Rafis','2 h','GL to everyone in the finals!')])}</div>''', 2))
# 6 Search
kb = '<div style="position:absolute;left:0;right:0;bottom:0;height:300px;background:#3a3540;display:flex;align-items:center;justify-content:center;color:#95879F;font-size:13px">keyboard</div>'
screens.append(phone('Search · Liquid Glass bar over the keyboard', appbar('Search', share()+acc, back=False) + f'''<div style="padding:4px 16px 0">{seg([('person','Players'),('music','Maps'),('news','Wiki')],0)}</div>
<div class="body" style="padding-top:12px"><div class="list">{''.join(rrow(*r) for r in [(5,'Rafis','PL','98.95','24 710','#F1EAF2'),(812,'rafisfan','PL','96.10','9 120','#F1EAF2')])}</div></div>''', None,
 kb + '<div style="position:absolute;left:16px;right:16px;bottom:312px"><div class="glass focus">' + ic("search",20) + ' <span>rafis</span><span style="margin-left:auto">' + ic("clear",20) + '</span></div></div>'))
# 7 Mode sheet
def opt(label, icon_html, selected=False):
    inner = (f'<div class="opt{" sel" if selected else ""}">' + bevel(f'<div class="chip" style="color:{"#FFD9E6" if selected else "#F28BB7"}">{icon_html}</div>', '#5a3149' if selected else '#332D3B', 8)
             + f'<b>{label}</b>' + (ic('check',20,'#FFD9E6') if selected else '') + '</div>')
    return bevel(inner, '#292430', 12)
sheet = '<div class="scrim"></div><div class="sheet" style="position:absolute;left:0;right:0;bottom:0;padding-bottom:40px"><div class="grab"></div><h3>Game mode</h3>' + ''.join(opt(l, mode(k,20), k=='mania') for k,l in [('osu','ctd'),('taiko','taiko'),('fruits','catch'),('mania','mania')]) + '</div>'
screens.append(phone('Game mode sheet', appbar('Rankings', f'<div class="ib">{mode("mania")}</div>'+share()+acc, back=False) + f'''<div style="padding:4px 16px 0">{seg([('person','Players'),('group','Teams'),('globe','Countries'),('heart','Kudosu')],0)}</div><div class="body" style="padding-top:12px"><div class="list">{''.join(rrow(*r) for r in [(1,'jakads','KR','98.1','31 002','#E3C27B'),(2,'Vortex','US','97.9','30 455','#C7BBCD')])}</div></div>''', 1, sheet))
# 8 Map of the day page
pod = ''.join(f'<div class="col" style="align-items:center;gap:6px;flex:1"><div class="avatar" style="width:44px;height:44px;border-radius:10px"></div><b style="font-size:13px">{n}</b><div style="width:100%;height:{h}px;border-radius:12px 12px 0 0;background:linear-gradient(180deg,{c},#211D27);display:flex;justify-content:center;padding-top:8px;font-family:Exo 2;font-weight:700">{p}</div></div>' for n,h,c,p in [('Mathi',70,'#9aa3ad','2'),('mrekk',96,'#E3C27B','1'),('Rafis',52,'#C68A5E','3')])
screens.append(phone('Map of the day', appbar('Map of the day', share()+acc) + f'''<div class="body" style="padding-top:8px">{poster(200)}
<div class="secttl"><b>Today's leaderboard</b><span>History</span></div><div class="row" style="flex-wrap:nowrap;align-items:flex-end;gap:8px">{pod}</div>
<div class="list">{''.join(rrow(*r) for r in [(4,'aetrna','CA','99.10','1 204 331','#F1EAF2'),(5,'WhiteCat','DE','98.80','1 198 002','#F1EAF2')]).replace('plays','')}</div></div>''', 0))
# 9 Packs
prow = ''.join(f'<div class="card" style="background:linear-gradient(135deg,{c},#211D27);display:flex;gap:12px;align-items:center;padding:12px 14px"><div class="ti">{ic(i,18)}</div><div class="col" style="gap:2px;flex:1"><b style="font-size:14px">{t}</b><span class="cap">{d}</span></div></div>' for t,d,i,c in [('S1500 · Beatmap Pack #1500','2026-09-30 · Stixy · ctd','star','#3a2433'),('S1499 · Beatmap Pack #1499','2026-09-23 · Stixy · ctd','star','#3a2433'),('S1498 · Beatmap Pack #1498','2026-09-16 · Stixy · ctd','star','#3a2433'),('S1497 · Beatmap Pack #1497','2026-09-09 · Stixy · ctd','star','#3a2433')])
screens.append(phone('Beatmap packs · tag jump', appbar('Beatmap packs', share()+acc) + f'''<div class="body" style="padding-top:8px">
<div style="height:48px;border-radius:12px;background:var(--highest);display:flex;align-items:center;gap:10px;padding:0 14px;color:var(--on)">{ic("search",18)} S1500</div>
<div class="card" style="display:flex;gap:12px;align-items:center;background:var(--pc)"><div class="ti" style="background:rgba(255,217,230,.14);color:#FFD9E6">{ic("open",18)}</div><b style="font-size:14px;color:var(--on-pc);flex:1">Open pack S1500</b>{ic("chev",18,"#FFD9E6")}</div>
{prow}</div>''', 0))
html = f'<!doctype html><html><head><meta charset="utf-8"><title>Tracksu screens</title><style>{css}</style></head><body>{"".join(screens)}</body></html>'
open('screens.html','w').write(html); print(len(screens), len(html))
