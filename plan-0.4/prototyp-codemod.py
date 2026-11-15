#!/usr/bin/env python3
"""Codemod: benennt benannte Argumente bestimmter Funktionsaufrufe und Funktionsnamen um.
Tokenbasiert (Strings, Kommentare, Raw-Blöcke werden übersprungen), kein vollständiger Parser.
usage: codemod.py regeln.json datei.typ [...] [--write]   (ohne --write: Diff)"""
import sys, re, json, difflib
ID=r'[^\W\d][\w\-]*'
def maske(s):
    """liefert bool-Liste: True = Code, False = String/Kommentar/Raw"""
    ok=[True]*len(s); i=0; n=len(s)
    def aus(a,b):
        for k in range(a,min(b,n)): ok[k]=False
    while i<n:
        if s.startswith('//',i) and not (i and s[i-1]==':'):
            j=s.find('\n',i); j=n if j<0 else j; aus(i,j); i=j
        elif s.startswith('/*',i):
            j=s.find('*/',i); j=n if j<0 else j+2; aus(i,j); i=j
        elif s[i]=='`':
            k=i
            while k<n and s[k]=='`': k+=1
            t=s[i:k]; j=s.find(t,k) if len(t)!=2 else k
            j=n if j<0 else j+len(t); aus(i,j); i=j
        elif s[i]=='"':
            j=i+1
            while j<n and s[j]!='"': j+=2 if s[j]=='\\' else 1
            aus(i,j+1); i=j+1
        else: i+=1
    return ok
def ende(s,ok,i):
    d=0
    while i<len(s):
        if ok[i]:
            if s[i] in '([{': d+=1
            elif s[i] in ')]}':
                d-=1
                if d==0: return i
        i+=1
    return -1
def lauf(s,regeln):
    ok=maske(s); edits=[]; warn=[]
    # 1) benannte Argumente:  f(  /  f.with(
    for fn,umb in regeln.get('parameter',{}).items():
        for m in re.finditer(r'(?<![\w\-.])'+re.escape(fn)+r'(\.with)?\(',s):
            if not ok[m.start()]: continue
            a=m.end()-1; e=ende(s,ok,a)
            if e<0: continue
            d=0; i=a
            while i<e:
                if ok[i]:
                    if s[i] in '([{': d+=1
                    elif s[i] in ')]}': d-=1
                    elif d==1:
                        mm=re.compile(r'('+ID+r')(\s*:)(?!:)').match(s,i)
                        if mm and s[i-1] in '(, \n\t' :
                            k=mm.group(1)
                            if k in umb:
                                ziel=umb[k]
                                if isinstance(ziel,str): edits.append((mm.start(1),mm.end(1),ziel))
                                else:
                                    edits.append((mm.start(1),mm.end(1),ziel['name']))
                                    vm=re.compile(r'\s*("[^"]*"|true|false|none)').match(s,mm.end())
                                    if vm and vm.group(1) in ziel.get('werte',{}): edits.append((vm.start(1),vm.end(1),ziel['werte'][vm.group(1)]))
                                    elif ziel.get('werte'): warn.append((s.count('\n',0,i)+1,f'Wert von `{k}` nicht statisch – von Hand prüfen'))
                            i=mm.end(); continue
                        if s.startswith('..',i): warn.append((s.count('\n',0,i)+1,f'Spread `..` in {fn}(…): Dictionary-Schlüssel von Hand prüfen'))
                i+=1
    # 2) Funktions-/Variablennamen (ganze Bezeichner, Kebab-Grenzen beachten)
    for alt,neu in regeln.get('namen',{}).items():
        for m in re.finditer(r'(?<![\w\-])'+re.escape(alt)+r'(?![\w\-])',s):
            vor=s[m.start()-1] if m.start() else ''; nach=s[m.end():m.end()+1]
            # nur eindeutig Code: `#name`, `name(`, `name[`, `name.with` – Fließtext bleibt unangetastet
            if ok[m.start()] and (vor=='#' or nach in ('(','[') or s.startswith('.with',m.end())) and not re.match(r'\s*:(?!:)',s[m.end():m.end()+3]): edits.append((m.start(),m.end(),neu))
    for a,b,t in sorted(set(edits),reverse=True): s=s[:a]+t+s[b:]
    return s,warn
if __name__=='__main__':
    regeln=json.load(open(sys.argv[1])); fs=[a for a in sys.argv[2:] if not a.startswith('--')]
    for f in fs:
        alt=open(f,encoding='utf-8').read(); neu,warn=lauf(alt,regeln)
        for z,w in warn: print(f'WARNUNG {f}:{z}: {w}')
        if '--write' in sys.argv: open(f,'w',encoding='utf-8').write(neu)
        else: sys.stdout.writelines(difflib.unified_diff(alt.splitlines(1),neu.splitlines(1),f,f+' (neu)',n=0))
