#!/bin/bash
# PRAXIS Tag 12 — DevSecOps. Geprüft wird der Praxis-Ordner tag12/.
source .github/classroom/grade.sh

solution_for_id() {
  case "$1" in
    sast-workflow) echo "Lege tag12/auftrag03-ci-security/.github/workflows/aufgabe1-sast-sca.yml an" ;;
    snyk-action) echo "Binde Snyk ein, z. B. 'uses: snyk/actions/python@master'" ;;
    snyk-token) echo "Referenziere den Token als SNYK_TOKEN: \${{ secrets.SNYK_TOKEN }}" ;;
    snyk-threshold) echo "Setze --severity-threshold=high in den Snyk-Argumenten" ;;
    snyk-sarif) echo "Erzeuge --sarif-file-output und lade sie mit github/codeql-action/upload-sarif hoch" ;;
    dast-workflow) echo "Lege tag12/auftrag03-ci-security/.github/workflows/aufgabe2-dast.yml an" ;;
    zap-action) echo "Binde OWASP ZAP ein, z. B. 'uses: zaproxy/action-baseline@v0.12.0'" ;;
    zap-target) echo "Starte die Anwendung im Workflow und gib ZAP eine target-URL (localhost:Port)" ;;
    praxis-doku) echo "Lege tag12/README.md an und dokumentiere die Befunde aus Aufgabe 1 und 2 (mind. 100 Wörter)" ;;
    *) echo "Überprüfe die Aufgabenstellung im README" ;;
  esac
}

echo "🔍 Prüfe Abnahmekriterien für Tag 12 Praxis — DevSecOps (SAST, DAST, CI-Integration)"
echo ""

WF=tag12/auftrag03-ci-security/.github/workflows

sast_wf() { grep -lEi 'snyk' $WF/*.yml $WF/*.yaml 2>/dev/null; }
dast_wf() { grep -lEi 'zap|zaproxy' $WF/*.yml $WF/*.yaml 2>/dev/null; }
SAST="$(sast_wf | tr '\n' ' ')/dev/null"
DAST="$(dast_wf | tr '\n' ' ')/dev/null"

echo "── Aufgabe 1 + 3: Statische Analyse (SAST/SCA) mit Snyk in der Pipeline ──"

check "sast-workflow" \
  "Aufgabe 1: SAST/SCA-Workflow vorhanden (tag12/auftrag03-ci-security/.github/workflows/)" \
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
  "Aufgabe 2: DAST-Workflow vorhanden (tag12/auftrag03-ci-security/.github/workflows/)" \
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
  "Doku: tag12/README.md vorhanden" \
  "tag12/README.md"

check "praxis-doku" \
  "Doku: Befunde und Massnahmen dokumentiert" \
  "grep -qiE 'schwachstell|vulnerab|finding|befund|massnahme|severity' tag12/README.md 2>/dev/null"

check "praxis-doku" \
  "Doku: tag12/README.md hat ausreichend Inhalt (mind. 100 Wörter)" \
  "[ \$(wc -w < tag12/README.md 2>/dev/null) -ge 100 ]"

summary 12
