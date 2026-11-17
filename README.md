# Tag 15 Praxis — DevSecOps (Snyk und OWASP ZAP)

> **Praxisauftrag, Einzelarbeit.** Dieses Repository ist dein Arbeitsplatz für
> die Praxis von Tag 15. Es enthält die absichtlich verwundbare Übungsanwendung
> **DSVPWA** (Damn Simple Vulnerable Python Web Application) und die Vorlage
> `findings.md` für deine Ergebnisse.

## Ausgangslage

Du prüfst DSVPWA mit zwei Verfahren: zuerst den ruhenden Code mit **Snyk**
(SCA und SAST), danach die laufende Anwendung mit **OWASP ZAP** (DAST). Du
arbeitest **nur lokal** mit den Tools. Den Einbau in eine Pipeline machst du
anschliessend im Projekt am TechStyle-Shop.

Die vollständige Anleitung steht in der Tagesplanung von Tag 15, Abschnitt
**Praxis**. Hinweise zur Anwendung selbst stehen in [`DSVPWA.md`](DSVPWA.md).

> ⚠️ DSVPWA ist absichtlich unsicher. Starte sie nur lokal oder im Codespace,
> nie auf einem öffentlich erreichbaren Server.

## Aufgaben

| Phase | Auftrag | Zeit | Ergebnis in `findings.md` |
|-------|---------|------|---------------------------|
| Praxis 1 | **P0** Setup | 10 Min | – |
| Praxis 1 | **P1** SCA und SAST mit Snyk | 20 Min | Drei bewertete Findings |
| Praxis 2 | **P2** DAST mit ZAP und Fund von Hand prüfen | 20 Min | Zwei ZAP-Alerts, verifizierte SQL-Injection, Vergleich SAST / DAST |
| für Schnelle | **P3** Fix und Re-Scan | 10 Min | Behobene SQL-Injection |

### P0 — Setup

1. Öffne dieses Repository in einem **GitHub Codespace**: **Code** →
   **Codespaces** → **Create codespace on main**. Python, Node.js und Docker
   sind dort installiert.
2. Erstelle einen Account auf [app.snyk.io](https://app.snyk.io/login) und
   aktiviere **Settings** → **Snyk Code** → **Enable Snyk Code**.
3. `npm install -g snyk` und `snyk auth`.

### P1 — SCA und SAST mit Snyk

```bash
python -m venv venv
source venv/bin/activate          # Windows: venv\Scripts\activate
pip install -r requirements.txt
snyk test                         # SCA: Bibliotheken aus requirements.txt
snyk code test                    # SAST: eigener Quellcode
```

Trage **drei Findings** in `findings.md` ein, mindestens eines aus SCA und
eines aus SAST. Entscheide jeweils: echtes Risiko oder False Positive? Und
welche Massnahme?

### P2 — DAST mit OWASP ZAP

```bash
python dsvpwa.py --host 0.0.0.0   # Terminal 1, Port 65413

# Terminal 2, Codespace / Linux
docker run --rm --network host -t zaproxy/zap-stable zap-baseline.py -t http://localhost:65413
# Docker Desktop (macOS / Windows)
docker run --rm -t zaproxy/zap-stable zap-baseline.py -t http://host.docker.internal:65413
```

Dokumentiere **zwei Alerts**. Der Baseline-Scan ist passiv und findet die
SQL-Injection nicht. Prüfe sie von Hand:

```bash
curl "http://localhost:65413/users?id=1"
curl "http://localhost:65413/users?id=1%20OR%201=1"
```

Halte Request und Beobachtung fest und fülle die Vergleichstabelle aus: Was hat
nur SAST gefunden, was nur DAST?

### P3 — Fix und Re-Scan (für Schnelle)

Ersetze in `dsvpwa/attacks.py`, Zeile 39, die String-Verkettung durch einen
parametrisierten Query, wiederhole den Angriff und `snyk code test`, und
pushe den Fix zusammen mit `findings.md`.

## Abnahmekriterien

Diese Kriterien prüft die Pipeline bei jedem Push automatisch. **Die Haken
setzt die Pipeline selbst:** Ein erfülltes Kriterium wird abgehakt, und
sobald eine Änderung es wieder bricht, verschwindet der Haken. Du musst hier
nichts von Hand pflegen, beim nächsten Push wird die Liste überschrieben.

<!-- c50:progress -->
**Fortschritt: 0 / 6 Kriterien erfüllt** ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜
<!-- /c50:progress -->

- [ ] ⬜ P1: Drei Snyk-Findings mit Paket bzw. Datei und Severity eingetragen
- [ ] ⬜ P1: Mindestens ein Finding aus SCA und eines aus SAST
- [ ] ⬜ P1: Jedes Finding ist eingestuft (echtes Risiko oder False Positive) und hat eine Massnahme
- [ ] ⬜ P2: Zwei ZAP-Alerts mit Risiko, URL und Behebung dokumentiert
- [ ] ⬜ P2: SQL-Injection unter /users?id= von Hand verifiziert (Request und Beobachtung)
- [ ] ⬜ P2: Vergleich SAST / DAST ausgefüllt

Zusätzlich, nicht bewertet:

- P3 (für Schnelle): SQL-Injection mit einem parametrisierten Query behoben
  und im Re-Scan verschwunden. Die Prüfung meldet es mit ⭐, wenn der Fix
  drin ist.

## Abnahmekriterien selber prüfen

**Lokal**, jederzeit und ohne Push:

```bash
bash .github/classroom/grade.sh
```

Das Skript liest die Tagesnummer aus `.classroom50.yaml`. Du kannst sie auch
erzwingen:

```bash
CLASSROOM_DAY=15 bash .github/classroom/grade.sh
```

Die Ausgabe listet jedes Kriterium mit ✅ oder ❌ und nennt bei jedem ❌ den
konkreten Lösungshinweis. Sobald ein Kriterium fehlt, endet das Skript mit
Exit-Code 1.

**In GitHub**, bei jedem Push:

Der Workflow **🎓 Classroom Autograding** läuft automatisch und hakt die
erfüllten Kriterien oben im README ab. Ergebnis im Tab
**Actions** → letzter Run → Job *Abnahmekriterien prüfen*.

Die Punktzahl ist **anteilig**: Jedes erfüllte Abnahmekriterium zählt einen
Punkt (z. B. `Points 4/6`). Grün wird der Lauf erst, wenn alle Kriterien
erfüllt sind, Teilpunkte gibt es aber ab dem ersten.

## Musterlösung

Nach dem Unterricht findest du die Musterlösung im Repository
[`tbzdevops/musterloesungen-praxisauftraege`](https://github.com/tbzdevops/musterloesungen-praxisauftraege/tree/day_15_solution)
auf dem Branch `day_15_solution`.
