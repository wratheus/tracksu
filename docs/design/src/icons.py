P = {
 'home': '<path d="M4 11l8-7 8 7v8a1 1 0 0 1-1 1h-4v-6h-6v6H5a1 1 0 0 1-1-1z"/>',
 'chart': '<path d="M5 20V10M12 20V4M19 20v-7"/>',
 'compass': '<circle cx="12" cy="12" r="9"/><path d="M15.5 8.5l-2 5-5 2 2-5z"/>',
 'search': '<circle cx="11" cy="11" r="6.5"/><path d="M16 16l4.5 4.5"/>',
 'share': '<path d="M12 15V4M8 8l4-4 4 4M5 13v6h14v-6"/>',
 'back': '<path d="M15 5l-7 7 7 7"/>',
 'check': '<path d="M5 12.5l4.5 4.5L19 7.5"/>',
 'history': '<path d="M4 12a8 8 0 1 0 2.4-5.7M4 4v4h4"/><path d="M12 8v4l3 2"/>',
 'bolt': '<path d="M13 3L5 13h6l-1 8 8-10h-6z"/>',
 'news': '<rect x="4" y="5" width="16" height="14" rx="2"/><path d="M8 9h8M8 13h8M8 17h5"/>',
 'forum': '<path d="M4 5h12v9H8l-4 3z"/><path d="M18 9h2v10l-3-2h-7v-2"/>',
 'update': '<path d="M20 12a8 8 0 1 1-2.3-5.7M20 4v4h-4"/>',
 'image': '<rect x="4" y="5" width="16" height="14" rx="2"/><circle cx="9" cy="10" r="1.5"/><path d="M5 18l5-5 4 4 2-2 3 3"/>',
 'play': '<path d="M8 5l11 7-11 7z"/>',
 'globe': '<circle cx="12" cy="12" r="8.5"/><path d="M3.5 12h17M12 3.5c3 3 3 14 0 17M12 3.5c-3 3-3 14 0 17"/>',
 'star': '<path d="M12 4l2.5 5 5.5.8-4 3.9 1 5.5-5-2.6-5 2.6 1-5.5-4-3.9 5.5-.8z"/>',
 'clock': '<circle cx="12" cy="12" r="8.5"/><path d="M12 7.5V12l3 2"/>',
 'info': '<circle cx="12" cy="12" r="8.5"/><path d="M12 11v5M12 8h.01"/>',
 'warn': '<path d="M12 4l9 16H3z"/><path d="M12 10v4M12 17h.01"/>',
 'unfold': '<path d="M8 9l4-4 4 4M8 15l4 4 4-4"/>',
 'chev': '<path d="M9 5l7 7-7 7"/>',
 'expand': '<path d="M6 9l6 6 6-6"/>',
 'clear': '<circle cx="12" cy="12" r="8.5"/><path d="M9 9l6 6M15 9l-6 6"/>',
 'plus': '<path d="M12 5v14M5 12h14"/>',
 'open': '<path d="M14 4h6v6M20 4l-9 9M18 14v5H5V6h5"/>',
 'heart': '<path d="M12 19s-7-4.4-7-9.5A3.8 3.8 0 0 1 12 7a3.8 3.8 0 0 1 7 2.5C19 14.6 12 19 12 19z"/>',
 'person': '<circle cx="12" cy="8" r="3.5"/><path d="M5 20c1-4 4-6 7-6s6 2 7 6"/>',
 'group': '<circle cx="9" cy="9" r="3"/><circle cx="16.5" cy="10" r="2.5"/><path d="M3.5 19c.8-3.4 3-5 5.5-5s4.7 1.6 5.5 5M15 14.5c2.3 0 4.3 1.4 5 4.5"/>',
 'music': '<path d="M9 18V6l10-2v12"/><circle cx="7" cy="18" r="2"/><circle cx="17" cy="16" r="2"/>',
 'medal': '<circle cx="12" cy="14" r="5"/><path d="M8.5 3l3.5 6 3.5-6"/>',
 'trophy': '<path d="M8 4h8v5a4 4 0 0 1-8 0zM8 6H5a3 3 0 0 0 3 4M16 6h3a3 3 0 0 1-3 4M12 13v4M8 20h8"/>',
 'comment': '<path d="M4 5h16v11H9l-5 4z"/>',
 'calendar': '<rect x="4" y="5" width="16" height="15" rx="2"/><path d="M4 10h16M9 3v4M15 3v4"/>',
}
def ic(name, size=20, color='currentColor', sw=2):
    return f'<svg width="{size}" height="{size}" viewBox="0 0 24 24" fill="none" stroke="{color}" stroke-width="{sw}" stroke-linecap="round" stroke-linejoin="round">{P[name]}</svg>'
def mode(kind, size=22, color='currentColor'):
    s = {'osu': f'<circle cx="12" cy="12" r="9" fill="none" stroke="{color}" stroke-width="2"/><circle cx="12" cy="12" r="3.5" fill="{color}"/>',
         'taiko': f'<circle cx="12" cy="12" r="9" fill="none" stroke="{color}" stroke-width="2"/><circle cx="12" cy="12" r="4.5" fill="none" stroke="{color}" stroke-width="2"/><path d="M12 3v4.5M12 16.5V21" stroke="{color}" stroke-width="2"/>',
         'fruits': f'<circle cx="12" cy="12" r="9" fill="none" stroke="{color}" stroke-width="2"/><circle cx="9" cy="13" r="2.3" fill="{color}"/><circle cx="15" cy="13" r="2.3" fill="{color}"/><circle cx="12" cy="8.5" r="2.3" fill="{color}"/>',
         'mania': f'<circle cx="12" cy="12" r="9" fill="none" stroke="{color}" stroke-width="2"/><path d="M8.5 8v8M12 7v10M15.5 8v8" stroke="{color}" stroke-width="2" stroke-linecap="round"/>'}[kind]
    return f'<svg width="{size}" height="{size}" viewBox="0 0 24 24">{s}</svg>'
def bevel(inner, bg, cut=12, style='', cls=''):
    """Chamfered box (top-left, bottom-right) drawn with corner triangles in the parent's colour,
    so it survives HTML→Figma conversion (no clip-path)."""
    c = cut
    tri_tl = f'<svg style="position:absolute;left:0;top:0" width="{c}" height="{c}" viewBox="0 0 {c} {c}"><path d="M0 0H{c}L0 {c}z" fill="{bg}"/></svg>'
    tri_br = f'<svg style="position:absolute;right:0;bottom:0" width="{c}" height="{c}" viewBox="0 0 {c} {c}"><path d="M{c} 0V{c}H0z" fill="{bg}"/></svg>'
    return f'<div class="{cls}" style="position:relative;{style}">{inner}{tri_tl}{tri_br}</div>'
