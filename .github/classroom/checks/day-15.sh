#!/bin/bash
# PRAXIS Tag 15 — DevSecOps. Geprüft wird das Wurzel-Verzeichnis: die Workflows
# liegen in .github/workflows/ — genau dort, wo GitHub Actions sie ausführt.
source .github/classroom/grade.sh

solution_for_id() {
  case "$1" in
    sast-workflow) echo "Lege .github/workflows/aufgabe1-sast-sca.yml an" ;;
    snyk-action) echo "Binde Snyk ein, z. B. 'uses: snyk/actions/python@master'" ;;
    snyk-token) echo "Referenziere den Token als SNYK_TOKEN: \${{ secrets.SNYK_TOKEN }}" ;;
    snyk-threshold) echo "Setze --severity-threshold=high in den Snyk-Argumenten" ;;
    snyk-sarif) echo "Erzeuge --sarif-file-output und lade sie mit github/codeql-action/upload-sarif hoch" ;;
    dast-workflow) echo "Lege .github/workflows/aufgabe2-dast.yml an" ;;
    zap-action) echo "Binde OWASP ZAP ein, z. B. 'uses: zaproxy/action-baseline@v0.12.0'" ;;
    zap-target) echo "Starte die Anwendung im Workflow und gib ZAP eine target-URL (localhost:Port)" ;;
    praxis-doku) echo "Lege DOKUMENTATION.md im Wurzel-Verzeichnis an und halte die Befunde aus Aufgabe 1 und 2 fest (mind. 100 Wörter)" ;;
    *) echo "Überprüfe die Aufgabenstellung im README" ;;
  esac
}

echo "🔍 Prüfe Abnahmekriterien für Tag 15 Praxis — DevSecOps (SAST, DAST, CI-Integration)"
echo ""

WF=.github/workflows
DOKU=DOKUMENTATION.md

# classroom.yml gehoert zur Bewertung und darf kein Kriterium erfuellen.
own_wf() { ls $WF/*.yml $WF/*.yaml 2>/dev/null | grep -v '/classroom\.yml$'; }
sast_wf() { own_wf | xargs -r grep -lEi 'snyk' 2>/dev/null; }
dast_wf() { own_wf | xargs -r grep -lEi 'zap|zaproxy' 2>/dev/null; }
SAST="$(sast_wf | tr '\n' ' ')/dev/null"
DAST="$(dast_wf | tr '\n' ' ')/dev/null"

echo "── Aufgabe 1 + 3: Statische Analyse (SAST/SCA) mit Snyk in der Pipeline ──"

check "sast-workflow" \
  "Aufgabe 1: SAST/SCA-Workflow vorhanden (.github/workflows/)" \
  "sast_wf | grep -q ."

check "snyk-action" \
  "Aufgabe 1: Snyk ist in den Workflow eingebunden" \
  "grep -qiE 'snyk/actions|snyk test|snyk code' $SAST"

check "snyk-token" \
  "Aufgabe 1: SNYK_TOKEN als GitHub Secret referenziert" \
  "grep -qE 'secrets\.SNYK_TOKEN' $SAST"

check "snyk-threshold" \
  "Aufgabe 1: Severity-Threshold gesetzt (z. B. --severity-threshold=high)" \
  "grep -qiE 'severity-threshold' $SAST"

check "snyk-sarif" \
  "Aufgabe 1: SARIF-Report wird erzeugt und hochgeladen" \
  "grep -qiE 'sarif' $SAST"

echo ""
echo "── Aufgabe 2 + 3: Dynamischer Sicherheitstest (DAST) mit OWASP ZAP ──"

check "dast-workflow" \
  "Aufgabe 2: DAST-Workflow vorhanden (.github/workflows/)" \
  "dast_wf | grep -q ."

check "zap-action" \
  "Aufgabe 2: OWASP ZAP ist eingebunden (zaproxy/action-*)" \
  "grep -qiE 'zaproxy/action|zap-baseline|owasp' $DAST"

check "zap-target" \
  "Aufgabe 2: Ziel-URL bzw. laufende Anwendung im Workflow definiert" \
  "grep -qiE 'target|localhost|127\.0\.0\.1|http://' $DAST"

echo ""
echo "── Dokumentation der Befunde ──"

check_file_exists "praxis-doku" \
  "Doku: DOKUMENTATION.md vorhanden" \
  "$DOKU"

check "praxis-doku" \
  "Doku: Befunde und Massnahmen dokumentiert" \
  "grep -qiE 'schwachstell|vulnerab|finding|befund|massnahme|severity' $DOKU 2>/dev/null"

check "praxis-doku" \
  "Doku: DOKUMENTATION.md hat ausreichend Inhalt (mind. 100 Wörter)" \
  "[ \$(wc -w < $DOKU 2>/dev/null) -ge 100 ]"

summary 15
