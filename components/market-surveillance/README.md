# market-surveillance

Order book surveillance with explainable alerts and an investigation agent for compliance analysts.

**Status:** planned · **Target:** January 2027

## Layout

```text
components/market-surveillance/
├── _infra/                 # Stage-3 Terraform (Vertex AI, Vector Search, BigQuery)
├── spoofing-detector/      # Python anomaly model & Vertex Explainable AI attributions
└── investigation-agent/    # Python Gemini / Agent Development Kit (ADK) agent + evals
```

## Scope

- **Detection:** spoofing detection on the Eurex order book with an anomaly model on Vertex AI (`spoofing-detector/`).
- **Explainability:** feature attributions with Vertex Explainable AI for every alert, so each alert is justified and auditable (EU AI Act).
- **Retrieval:** market abuse rules (MAR) and exchange rules searchable through vector search.
- **Investigation agent:** Gemini agent in Python (`investigation-agent/`), built with the Agent Development Kit, with tools on BigQuery and the positions API, for example via MCP.
- **Evaluation and security:** agent evaluation and agent security controls in CI.

## Documents

- PRD: to follow in [`../../docs/prd/`](../../docs/prd/)
- Hand-off guide: to follow
