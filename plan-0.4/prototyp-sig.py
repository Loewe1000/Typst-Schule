#!/usr/bin/env python3
"""Signatur-Snapshot + Namens-Lint für Typst-Quelltexte (ohne Typst-Parser).
usage: sig.py datei.typ [...] [--json] [--lint]"""
import sys, re, json

def strip_comments(s):
    out=[]; i=0; n=len(s); in_str=False
    while i<n:
        c=s[i]
        if in_str:
            out.append(c)
            if c=='\\' and i+1<n: out.append(s[i+1]); i+=2; continue
            if c=='"': in_str=False
            i+=1; continue
        if c=='"': in_str=True; out.append(c); i+=1; continue
        if s.startswith('//',i) and not (i>0 and s[i-1]==':'):   # nicht in URLs
            j=s.find('\n',i); j=n if j<0 else j
            i=j; continue
        if s.startswith('/*',i):
            d=1; i+=2
            while i<n and d:
                if s.startswith('/*',i): d+=1; i+=2
                elif s.startswith('*/',i): d-=1; i+=2
                else:
                    if s[i]=='\n': out.append('\n')
                    i+=1
            continue
        out.append(c); i+=1
    return ''.join(out)

def match_paren(s,i):
    """s[i]=='(' -> Index der schließenden Klammer"""
    d=0; in_str=False; n=len(s)
    while i<n:
        c=s[i]
        if in_str:
            if c=='\\': i+=2; continue
            if c=='"': in_str=False
        elif c=='"': in_str=True
        elif c in '([{': d+=1
        elif c in ')]}':
            d-=1
            if d==0: return i
        i+=1
    return -1

def split_top(s):
    parts=[]; d=0; in_str=False; cur=[]; i=0
    while i<len(s):
        c=s[i]
        if in_str:
            cur.append(c)
            if c=='\\' and i+1<len(s): cur.append(s[i+1]); i+=1
            elif c=='"': in_str=False
        elif c=='"': in_str=True; cur.append(c)
        elif c in '([{': d+=1; cur.append(c)
        elif c in ')]}': d-=1; cur.append(c)
        elif c==',' and d==0: parts.append(''.join(cur)); cur=[]
        else: cur.append(c)
        i+=1
    if ''.join(cur).strip(): parts.append(''.join(cur))
    return [p.strip() for p in parts if p.strip()]

IDENT=r'[^\W\d][\w\-]*'
def parse(path):
    s=strip_comments(open(path,encoding='utf-8').read())
    res=[]
    for m in re.finditer(r'^#let\s+('+IDENT+r')\s*(\(|=)', s, re.M):   # nur Top-Level (Spalte 0)
        name=m.group(1); line=s.count('\n',0,m.start())+1
        if m.group(2)=='=':
            res.append(dict(name=name,kind='variable',line=line,params=[])); continue
        e=match_paren(s,m.end()-1)
        params=[]
        for p in split_top(s[m.end():e]):
            if p.startswith('..'): params.append(dict(name=p,kind='sink'))
            else:
                mm=re.match(r'('+IDENT+r')\s*:\s*(.*)$',p,re.S)
                if mm: params.append(dict(name=mm.group(1),kind='named',default=' '.join(mm.group(2).split())))
                else: params.append(dict(name=p,kind='positional'))
        res.append(dict(name=name,kind='function',line=line,params=params))
    return res

# --- Lint -----------------------------------------------------------------
DE=set("aufgabe aufgaben teilaufgabe loesung loesungen lösung lösungen punkte materialien material erwartung erwartungen bewertung fach thema jahrgang stufe niveau typ stichworte stand zweifach akzent anzeige titel klasse offene erreicht alle teile teil kerncurriculum".split())
EN=set("title class paper print duplex workspace workspaces theme font size math figure landscape custom header page settings copyright scope show set get options points grouped new compact full inline curr label caption method icons large number item body numbering reset format position".split())
def lint(name):
    out=[]
    if re.search(r'[a-zäöüß][A-ZÄÖÜ]',name): out.append('camelCase')
    if '_' in name.strip('_'): out.append('snake_case')
    if re.search(r'[äöüßÄÖÜ]',name): out.append('Umlaut')
    w=[x for x in re.split(r'[-_]',name.lower()) if x]
    de=[x for x in w if x in DE]; en=[x for x in w if x in EN]
    if de and en: out.append('gemischt de(%s)+en(%s)'%(','.join(de),','.join(en)))
    unk=[x for x in w if x not in DE and x not in EN]
    if unk: out.append('nicht im Wörterbuch: '+','.join(unk))
    return out

if __name__=='__main__':
    files=[a for a in sys.argv[1:] if not a.startswith('--')]
    allr={f:parse(f) for f in files}
    if '--json' in sys.argv: print(json.dumps(allr,ensure_ascii=False,indent=1)); sys.exit()
    for f,r in allr.items():
        pub=[x for x in r if not x['name'].startswith('_')]
        print(f'## {f}: {len(r)} Top-Level-Definitionen, {len(pub)} öffentlich')
        for x in pub:
            if '--lint' in sys.argv:
                for n,wo in [(x['name'],'')]+[(p['name'],' (Parameter von '+x['name']+')') for p in x['params'] if p['kind']=='named']:
                    for l in lint(n):
                        if not l.startswith('nicht im') or '--strict' in sys.argv: print(f"  {f.split('/')[-1]}:{x['line']}: `{n}`{wo}: {l}")
            else:
                ps=', '.join(p['name']+(': '+p['default'] if p['kind']=='named' else '') for p in x['params'])
                print(f"  {x['line']:5d} {x['name']}" + (f"({ps})" if x['kind']=='function' else ' [Variable]'))
