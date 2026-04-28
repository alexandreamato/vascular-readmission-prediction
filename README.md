# Vascular Readmission Prediction

Machine learning tool for predicting 30-day hospital readmission risk in vascular surgery patients.

**Live app → [software.amato.com.br/vascular-prediction](https://software.amato.com.br/vascular-prediction/)**

---

## About

This tool implements the model published in:

> Amato et al. (2020). *Machine learning in prediction of individual patient readmissions for elective carotid endarterectomy/aortofemoral bypass.* Journal of Vascular Surgery.

Given patient demographics, comorbidities (Charlson index), procedure type, and discharge disposition, the model outputs the individual probability of unplanned 30-day readmission.

The underlying model is a **Sparse Partial Least Squares Discriminant Analysis (SPLS-DA)** trained on a large administrative database of vascular surgery hospitalizations.

## Features used

| Feature | Type |
|---|---|
| Age | Continuous |
| Sex | Binary |
| Length of stay | Continuous (log-transformed) |
| Income percentile | Categorical (4 levels) |
| Primary payer | Categorical (5 levels) |
| Race | Categorical (4 levels) |
| Patient disposition at discharge | Categorical (5 levels) |
| Procedure (endarterectomy, bypass, aneurysm repair) | Binary |
| Charlson comorbidity index | Continuous (computed from 14 comorbidities) |

## Repository contents

| File | Description |
|---|---|
| `server.R` | Shiny server — prediction and LIME explanation logic |
| `ui.R` | Shiny UI — form layout and custom Bootstrap widgets |
| `CLAUDE.md` | Development guidance for Claude Code |

The trained model (`.rds`) and the compiled static app (`index.html`) are not included in this repository. The live app is deployed at the link above.

## Running locally (R Shiny)

```r
# Install dependencies
install.packages(c("shiny", "shinydashboard", "shinyjs", "caret", "lime"))

# Run (requires the .rds model file in the same directory)
shiny::runApp()
```

---

[vascular.pro](https://vascular.pro) · [software.amato.com.br](https://software.amato.com.br)
