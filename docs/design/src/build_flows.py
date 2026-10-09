from icons import ic
def node(t, sub='', kind='screen'):
    bg = {'screen':'#332D3B','action':'#51243C','system':'#352D45','end':'#193C34'}[kind]
    col = {'screen':'#F1EAF2','action':'#FFD9E6','system':'#ECE2F5','end':'#A4DECA'}[kind]
    return f'<div style="background:{bg};color:{col};border-radius:12px;padding:10px 14px;min-width:120px;max-width:190px;display:flex;flex-direction:column;gap:2px"><b style="font-size:13px">{t}</b>{f"<span style=font-size:11px;opacity:.8>{sub}</span>" if sub else ""}</div>'
arrow = lambda label='': f'<div style="display:flex;flex-direction:column;align-items:center;gap:2px;color:#95879F;min-width:44px"><span style="font-size:10px">{label}</span><svg width="44" height="12" viewBox="0 0 44 12"><path d="M0 6H40M34 1l6 5-6 5" fill="none" stroke="#95879F" stroke-width="1.5"/></svg></div>'
def flow(title, steps):
    parts=[]
    for i,s in enumerate(steps):
        if isinstance(s,str): parts.append(arrow(s))
        else: parts.append(node(*s))
    return f'<div class="col" style="gap:10px"><h2>{title}</h2><div class="row" style="align-items:center;gap:6px;flex-wrap:wrap">{"".join(parts)}</div></div>'
legend = '<div class="row" style="gap:10px">' + ''.join(node(t,'',k) for t,k in [('Screen','screen'),('User action','action'),('System','system'),('Result','end')]) + '</div>'
nav = '''<div class="col" style="gap:10px"><h2>Navigation map (ADR-010)</h2><div class="row" style="gap:16px;align-items:flex-start;flex-wrap:nowrap">''' + ''.join(
 f'<div class="col" style="gap:8px;background:#211D27;border-radius:16px;padding:14px;flex:1"><b style="font-family:Exo 2;font-size:15px">{tab}</b>' + ''.join(node(n,s) for n,s in items) + '</div>'
 for tab, items in [
  ('Home  /search', [('Map of the day','poster → day page, history'),('Beatmap packs','shelf → type list → pack'),('Spotlights','seasonal charts')]),
  ('Rankings  /rankings', [('Players · Teams · Countries · Kudosu','swipe pages, mode in app bar'),('PP / Score','shared filter'),('Country · 4K/7K','players page only')]),
  ('osu!  /news', [('News','article + comments'),('Events','global feed, filter'),('Forum','boards → topics → posts'),('Changelog','streams, builds')]),
  ('Search  /find', [('Players · Maps · Wiki','glass bar above keyboard'),('Results','open profile / beatmap / wiki')]),
 ]) + '</div><p class="cap">Every tab stack can push details: profile, beatmap, team, wiki, forum topic, pack, settings, sign-in. osu.ppy.sh links open in-app (AppLinks); other pages in the single-page viewer (ADR-009).</p></div>'
flows = [
 flow('Sign in', [('Any screen','account menu'), 'tap', ('Sign in with osu!','','action'), '', ('Auth screen','Continue with osu!'), 'opens', ('Safari','osu! OAuth','system'), 'callback', ('Code exchange','token stored','system'), '', ('Back where you were','avatar in app bar','end')]),
 flow('Game mode (ADR-011)', [('Rankings / Spotlights',''), 'tap mode icon', ('Game mode sheet','4 option rows','action'), 'choose', ('RulesetController','saved like the theme','system'), 'notifies', ('Pages reload in mode','profile & team keep own mode','end')]),
 flow('Search', [('Search tab','round button'), 'focus', ('Glass bar rides keyboard','nav bar fades by covered %','system'), 'type ≥ 2', ('Results','players / maps / wiki'), 'tap', ('Detail page','','end')]),
 flow('Link from content', [('Article / comment / wiki',''), 'tap link', ('AppLinks','classify URL','system'), 'osu! page', ('In-app screen','profile, map, wiki, forum, pack','end')]),
 flow('Loading', [('Page opens',''), 'cache hit', ('Content at once','no fade','end')]),
 flow('', [('Page opens',''), 'network', ('Skeleton','after ~130 ms','system'), 'data', ('Content fades in','260 ms','end'), 'pull', ('Refresh','content stays, bar line','system')]),
]
board = f'<section class="board" style="width:1880px"><h1>Flows</h1><p class="lead">How the main paths move through the app. Source: docs/design/FLOWS.md (Mermaid) in the repository.</p>{legend}{nav}{"".join(flows)}</section>'
open('flows_board.html','w').write(board); print(len(board))
