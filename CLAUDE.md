# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this is

A clinical decision support tool that predicts 30-day hospital readmission risk for vascular surgery patients, published as part of "Machine learning in prediction of individual patient readmissions for elective carotid endarterectomy/aortofemoral bypass" (Amato et al., 2020).

There are two implementations:
- **`index.html`** — self-contained static page (no server required); the model is embedded as JavaScript constants. Deploy by copying to any web root.
- **`server.R` + `ui.R`** — original R Shiny app, requires R with `shiny`, `shinydashboard`, `shinyjs`, `caret`, `lime`, `ggplot2`.

## Running

**Static version** — open `index.html` directly in a browser, or serve from any HTTP server. No build step.

**Shiny version**
```r
shiny::runApp()
# or: Rscript -e "shiny::runApp('.')"
```
Required packages: `shiny`, `shinydashboard`, `shinyjs`, `caret`, `lime`, `ggplot2`

## Architecture

**`server.R`** — loads the pre-trained model at startup, then on each "Predict" button click:
1. Computes the Charlson comorbidity index by summing weighted comorbidity inputs
2. Constructs a one-row `data.frame` with all predictors (applying `log(LOS + 1)` to length of stay)
3. Calls `caret::predict.train(..., type = "prob")` to get readmission probability
4. Calls `lime::explain()` to compute per-feature weights for the LIME plot
5. Renders the probability as text and the LIME explanation as a `ggplot2` bar chart

**`ui.R`** — defines the dashboard layout and two custom widget functions:
- `inputRadioButtons()` — renders Bootstrap button-group radio inputs (2 choices → inline, 3+ choices → stacked)
- `inputNumeric()` — renders a Bootstrap-styled number input

**`sdatools_classAnalysis_*.rds`** — the serialized model object. Contains:
- `$data_train` — training data used to fit the LIME explainer
- `$result_list[[1]]$model` — the `caret` trained model
- `$predictors` / `$categoric_predictors` — variable metadata used for label matching

The `.rds` file is loaded once at server startup (not inside the `server()` function), so the model and LIME explainer are shared across all sessions.

## Key implementation details

**Static `index.html` — prediction pipeline (JavaScript)**

The model is an SPLS-DA (`caret` method `"spls"`) with only 6 non-zero coefficients (out of 21 features). The full pipeline embedded in JS:
1. One-hot encode categorical variables (reference level → all zeros)
2. Center and scale: `x_scaled = (x − center) / std` using the training-set statistics from `caret`'s preProcess
3. Linear predictor: `η_True = Σ(x_scaled × β_True) + μ_True`, `η_False = -η_True_component + μ_False`
4. Softmax: `P(readmission) = exp(η_True) / (exp(η_True) + exp(η_False))`
5. Feature contributions displayed as `x_scaled × β` (exact, not LIME approximation)

Intercepts: `μ_True = 0.4286`, `μ_False = 0.5714` (class proportions in training data).

**Shiny `server.R` / `ui.R`**

- **Label mapping**: The `labels` named vector and `match_variable_labels()`/`match_level_labels()` helpers translate raw variable names (e.g. `female`, `LOS_Log`) to human-readable labels for the LIME plot.
- **Responsive layout**: Screen width is read via JavaScript on `shiny:connected` and stored as `input$GetScreenWidth`; font sizes and axis rotation adapt below 500 px.
- **Factor levels matter**: All factor variables must be constructed with explicit `levels=` matching the training data. Note: the model uses `"Home Health Care (HHC)"` and `"Against Medical Advice (AMA)"` as `patient_disposition` levels — the Shiny UI uses shortened strings that do not match, so those two options effectively map to the reference category in the original app.
- **LOS transform**: `log(LOS + 1)` applied before prediction in both implementations.
