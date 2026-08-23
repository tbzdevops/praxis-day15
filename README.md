# Tag 12 Praxis — DevSecOps (SAST, DAST, CI-Integration)

> **Praxisauftraege.** Dieses Repository ist dein Arbeitsplatz fuer die
> Praxis-Uebungen von Tag 12. Es enthaelt bewusst nur das Geruest —
> jede Datei schreibst du selbst.

## Ausgangslage

DevSecOps mit **Snyk** (SAST/SCA) und **OWASP ZAP** (DAST). Die Auftraege bauen
aufeinander auf: zuerst wird der ruhende Code statisch geprueft, dann die
laufende Anwendung dynamisch getestet, und schliesslich werden beide
Pruefungen in eine GitHub-Actions-Pipeline automatisiert.

Als Uebungsobjekt dient die absichtlich verwundbare Anwendung **DSVPWA**
(Damn Simple Vulnerable Python Web Application):
<https://github.com/tbzdevops/DSVPWA>

## Ordnerstruktur

Die leeren Ordner geben die erwartete Struktur vor. Halte dich daran —
die automatische Pruefung sucht die Dateien genau dort.

```
tag12/auftrag03-ci-security/.github/workflows/
```

## Aufgaben

### Auftrag 1 — Statische Code-Analyse mit Snyk (SAST + SCA)

Lokale Uebung mit der Snyk-CLI an der geforkten DSVPWA-App.

- Snyk-Account anlegen, Projekt-Token als GitHub Secret `SNYK_TOKEN`
  hinterlegen.
- `snyk test` (Dependencies/SCA) und `snyk code test` (Code/SAST) ausfuehren.
- Halte die Befunde in `tag12/README.md` fest: Schwachstelle, Severity,
  moegliche Behebung.

### Auftrag 2 — Dynamischer Sicherheitstest mit OWASP ZAP (DAST)

Lokale Uebung: DSVPWA starten und mit OWASP ZAP im Docker-Container
scannen.

- Anwendung lokal starten und erreichbar machen.
- ZAP Baseline Scan gegen die laufende Anwendung ausfuehren.
- Ergaenze die Befunde in `tag12/README.md` und vergleiche sie mit den
  SAST-Ergebnissen aus Auftrag 1.

### Auftrag 3 — Security-Scans in die CI/CD-Pipeline einbauen

Ueberfuehre beide Pruefungen in GitHub Actions.

- `tag12/auftrag03-ci-security/.github/workflows/aufgabe1-sast-sca.yml`:
  Snyk einbinden (z. B. `snyk/actions/python@master`), `SNYK_TOKEN` als
  Secret, `--severity-threshold=high` und `--sarif-file-output`, danach
  `github/codeql-action/upload-sarif@v3`.
- `tag12/auftrag03-ci-security/.github/workflows/aufgabe2-dast.yml`:
  Anwendung im Workflow starten und `zaproxy/action-baseline` gegen die
  Ziel-URL laufen lassen.

## Abnahmekriterien

Diese Kriterien prueft die Pipeline bei jedem Push automatisch. **Die Haken
setzt die Pipeline selbst:** ein erfuelltes Kriterium wird abgehakt, und
sobald eine Aenderung es wieder bricht, verschwindet der Haken. Du musst hier
nichts von Hand pflegen — beim naechsten Push wird die Liste ueberschrieben.

<!-- c50:progress -->
**Fortschritt: 0 / 11 Kriterien erfüllt** ⬜⬜⬜⬜⬜⬜⬜⬜⬜⬜ — noch nicht geprueft.
<!-- /c50:progress -->

- [ ] ⬜ Aufgabe 1: SAST/SCA-Workflow vorhanden (tag12/auftrag03-ci-security/.github/workflows/)
- [ ] ⬜ Aufgabe 1: Snyk ist in den Workflow eingebunden
- [ ] ⬜ Aufgabe 1: SNYK_TOKEN als GitHub Secret referenziert
- [ ] ⬜ Aufgabe 1: Severity-Threshold gesetzt (z. B. --severity-threshold=high)
- [ ] ⬜ Aufgabe 1: SARIF-Report wird erzeugt und hochgeladen
- [ ] ⬜ Aufgabe 2: DAST-Workflow vorhanden (tag12/auftrag03-ci-security/.github/workflows/)
- [ ] ⬜ Aufgabe 2: OWASP ZAP ist eingebunden (zaproxy/action-*)
- [ ] ⬜ Aufgabe 2: Ziel-URL bzw. laufende Anwendung im Workflow definiert
- [ ] ⬜ Doku: tag12/README.md vorhanden
- [ ] ⬜ Doku: Befunde und Massnahmen dokumentiert
- [ ] ⬜ Doku: tag12/README.md hat ausreichend Inhalt (mind. 100 Wörter)

Zusaetzlich manuell abgenommen (nicht automatisch geprueft):

- Auftrag 1 und 2 lokal an DSVPWA durchgefuehrt (Snyk-CLI, ZAP im Container)
- Findings priorisiert und Behebungsvorschlaege formuliert

## Abnahmekriterien selber pruefen

**Lokal** — jederzeit, ohne Push:

```bash
bash .github/classroom/grade.sh
```

Das Skript liest die Tagesnummer aus `.classroom50.yaml`. Du kannst sie
auch erzwingen:

```bash
CLASSROOM_DAY=12 bash .github/classroom/grade.sh
```

Die Ausgabe listet jedes Kriterium mit ✅ oder ❌ und nennt bei jedem ❌
den konkreten Loesungshinweis. Sobald ein Kriterium fehlt, endet das
Skript mit Exit-Code 1.

**In GitHub** — bei jedem Push:

Der Workflow **🎓 Classroom Autograding** laeuft automatisch und hakt die
erfuellten Kriterien oben im README ab. Ergebnis im Tab **Actions** →
letzter Run → Job *Abnahmekriterien pruefen*.

## Musterloesung

Nach dem Unterricht findest du die Musterloesung im Repository
[`tbzdevops/musterloesungen-praxisauftraege`](https://github.com/tbzdevops/musterloesungen-praxisauftraege/tree/day_12_solution/tag12)
auf dem Branch `day_12_solution`.
