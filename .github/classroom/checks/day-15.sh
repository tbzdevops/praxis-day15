#!/bin/bash
# PRAXIS Tag 15 — DevSecOps. Geprüft wird findings.md im Wurzel-Verzeichnis.
# Die Vorlage liegt bereits im Repo, darum zählt nur, was in den Tabellen
# tatsächlich ausgefüllt ist. Die Praxis läuft lokal (Snyk CLI, OWASP ZAP);
# den Einbau in eine Pipeline macht das Projekt.
source .github/classroom/grade.sh

solution_for_id() {
  case "$1" in
    p1-rows) echo "Trage in findings.md unter P1 drei Snyk-Findings ein: Paket/Datei mit Version/Zeile und die Severity" ;;
    p1-tools) echo "Wähle mindestens ein Finding aus 'snyk test' (Tool: SCA) und eines aus 'snyk code test' (Tool: SAST)" ;;
    p1-triage) echo "Ergänze für jedes der drei Findings die Einstufung (echtes Risiko oder False Positive) und eine Massnahme" ;;
    p2-alerts) echo "Trage unter P2 zwei Alerts aus dem ZAP-Bericht mit Risiko, betroffener URL und Behebung ein" ;;
    p2-sqli) echo "Notiere unter 'Verifizierte SQL-Injection' den Request (z. B. /users?id=1%20OR%201=1) und was du beobachtet hast" ;;
    p2-compare) echo "Fülle die Vergleichstabelle aus: mindestens ein Fund nur aus SAST und einer nur aus DAST" ;;
    *) echo "Überprüfe die Aufgabenstellung im README" ;;
  esac
}

FINDINGS=findings.md

# Wertet die Markdown-Tabellen in findings.md aus. Argument: Name des Kriteriums.
# Exit 0 = erfüllt. Leere Vorlagenzellen zählen nicht.
findings_ok() {
  python3 - "$1" "$FINDINGS" <<'PY'
import re, sys

criterion, path = sys.argv[1], sys.argv[2]
try:
    text = open(path, encoding="utf-8").read()
except OSError:
    sys.exit(1)

def section(title_re):
    """Text unter der ersten Überschrift, die title_re trifft, bis zur nächsten gleich hohen oder höheren."""
    lines = text.splitlines()
    for i, line in enumerate(lines):
        m = re.match(r"^(#{2,3})\s+(.*)$", line)
        if m and re.search(title_re, m.group(2), re.I):
            level = len(m.group(1))
            out = []
            for nxt in lines[i + 1:]:
                n = re.match(r"^(#{1,6})\s", nxt)
                if n and len(n.group(1)) <= level:
                    break
                out.append(nxt)
            return "\n".join(out)
    return ""

def rows(block):
    """Datenzeilen der ersten Tabelle im Block, ohne Kopf- und Trennzeile."""
    table = []
    for line in block.splitlines():
        s = line.strip()
        if s.startswith("|"):
            table.append([c.strip() for c in s.strip("|").split("|")])
        elif table:
            break
    data = table[1:]
    return [r for r in data if not all(re.fullmatch(r":?-{2,}:?", c or "--") for c in r)]

def filled(cell):
    return bool(cell) and not re.fullmatch(r"[-–—\s]*", cell)

def cell(r, i):
    return r[i] if i < len(r) else ""

p1 = [r for r in rows(section(r"^P1\b")) if filled(cell(r, 2))]
p2 = rows(section(r"^P2\b"))

if criterion == "p1-rows":
    ok = sum(1 for r in p1 if filled(cell(r, 3))) >= 3
elif criterion == "p1-tools":
    tools = " ".join(cell(r, 1) for r in p1).upper()
    ok = "SCA" in tools and "SAST" in tools
elif criterion == "p1-triage":
    triage = re.compile(r"risiko|false|positiv|ausnutzbar|erreichbar|\bfp\b", re.I)
    ok = sum(1 for r in p1 if triage.search(cell(r, 4)) and filled(cell(r, 5))) >= 3
elif criterion == "p2-alerts":
    ok = sum(1 for r in p2
             if all(filled(cell(r, i)) for i in (1, 2, 3, 4))
             and re.search(r"/|localhost|http", cell(r, 3), re.I)) >= 2
elif criterion == "p2-sqli":
    block = section(r"Verifizierte SQL-Injection")
    req = re.search(r"Request:(.*?)(?=^\s*-\s*Beobachtung:|\Z)", block, re.S | re.M | re.I)
    obs = re.search(r"Beobachtung:(.*)", block, re.S | re.I)
    req_txt = req.group(1) if req else ""
    ok = (re.search(r"id=", req_txt, re.I) is not None
          and re.search(r"\bor\b|%20or|'", req_txt, re.I) is not None
          and obs is not None and len(re.findall(r"\w+", obs.group(1))) >= 3)
elif criterion == "p2-compare":
    cmp_rows = rows(section(r"^Vergleich"))
    ok = any(filled(cell(r, 0)) for r in cmp_rows) and any(filled(cell(r, 1)) for r in cmp_rows)
else:
    ok = False

sys.exit(0 if ok else 1)
PY
}

echo "🔍 Prüfe Abnahmekriterien für Tag 15 Praxis — DevSecOps (Snyk und OWASP ZAP)"
echo ""

echo "── P1: SCA und SAST mit Snyk ──"

check "p1-rows" \
  "P1: Drei Snyk-Findings mit Paket bzw. Datei und Severity eingetragen" \
  "findings_ok p1-rows"

check "p1-tools" \
  "P1: Mindestens ein Finding aus SCA und eines aus SAST" \
  "findings_ok p1-tools"

check "p1-triage" \
  "P1: Jedes Finding ist eingestuft (echtes Risiko oder False Positive) und hat eine Massnahme" \
  "findings_ok p1-triage"

echo ""
echo "── P2: DAST mit OWASP ZAP ──"

check "p2-alerts" \
  "P2: Zwei ZAP-Alerts mit Risiko, URL und Behebung dokumentiert" \
  "findings_ok p2-alerts"

check "p2-sqli" \
  "P2: SQL-Injection unter /users?id= von Hand verifiziert (Request und Beobachtung)" \
  "findings_ok p2-sqli"

check "p2-compare" \
  "P2: Vergleich SAST / DAST ausgefüllt" \
  "findings_ok p2-compare"

echo ""
echo "── P3 (für Schnelle, nicht bewertet) ──"
if grep -qE 'WHERE id=\?' dsvpwa/attacks.py 2>/dev/null && ! grep -qE 'WHERE id=" *\+' dsvpwa/attacks.py 2>/dev/null; then
  echo "⭐ P3: SQL-Injection in dsvpwa/attacks.py ist mit einem parametrisierten Query behoben"
else
  echo "ℹ️  P3: SQL-Injection in dsvpwa/attacks.py ist noch offen (freiwillig)"
fi

summary 15
