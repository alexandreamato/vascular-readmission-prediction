
inputRadioButtons <- function(id, label, choices) {

  input_class <- NULL
  if (length(choices) > 2) {
    input_class <- "btn btn-primary"
    in_divclass <- "btn-group-stacked"
  } else {
    input_class <- "btn btn-primary radio-inline"
    in_divclass <- "btn-group-inline"
  }

  outer_div_class <- "row form-group shiny-input-radiogroup shiny-input-container shinyjs-resettable shiny-bound-input"

  options <- mapply(function(x, y) {
    shiny::tags$label(
      class = input_class,
      shiny::tags$input(
        name = id,
        type = "radio",
        value = y,
        required = ""
      ),
      shiny::tags$span(x)
    )
  }, names(choices), choices, SIMPLIFY = FALSE, USE.NAMES = FALSE)

  options[[1]]$attribs$class <- paste0(options[[1]]$attribs$class, " active")
  options[[1]]$children[[1]]$attribs$checked <- "checked"

  widget <- shiny::tags$div(
    id = id,
    class = outer_div_class,
    shiny::tags$div(
      class = "col-xs-12 col-sm-7",
      shiny::tags$h4(label)
    ),
    shiny::tags$div(
      class = "col-xs-12 col-sm-5 text-right btn-group shiny-options-group",
      shiny::tags$div(
        class = in_divclass,
        'data-toggle' = "buttons",
        options
      )
    )
  )

  widget

}


inputNumeric <- function(id, label, value, min, max, step) {

  widget <- shiny::tags$div(
    id = id,
    class = "row form-group shiny-input-container",
    shiny::tags$div(
      class = "col-xs-12 col-sm-7",
      shiny::tags$h4(label)
    ),
    shiny::tags$div(
      class = "col-xs-12 col-sm-5",
      shiny::tags$input(
        name = id,
        type = "number",
        class = "form-control shinyjs-resettable shiny-bound-input",
        value = value,
        min = min,
        max = max,
        step = step,
        required = ""
      )
    )
  )

  widget

}



ui <- shinydashboard::dashboardPage(
  title = "Vascular Readmission Prediction",
  skin = "green",
  shinydashboard::dashboardHeader(
    title = "Vascular Readmission",
    titleWidth = 268
  ),
  shinydashboard::dashboardSidebar(
    width = 268,
    shinydashboard::sidebarMenu(
      shinydashboard::menuItem("Prediction", tabName = "prediction", icon = icon("percent"))
    )
  ),
  shinydashboard::dashboardBody(

    shiny::tags$style(shiny::HTML("
.logo {
  background-color: #0F705C !important;
}

.sidebar-toggle:hover {
  background-color: #0F705C !important;
}

.sidebar-menu > li.active > a {
  border-left-color: #117d67 !important;
}

.navbar {
  background-color: #117d67 !important;
}

.box.box-solid.box-primary > .box-header {
  color: #fff;
  background-color: #117d67;
}

.box.box-solid.box-primary {
  border-bottom-color: #666666;
  border-left-color: #666666;
  border-right-color: #666666;
  border-top-color: #666666;
}

.btn.active.focus, .btn.active:focus, .btn.focus, .btn:active.focus, .btn:active:focus, .btn:focus {
  outline: none;
}

.btn-primary {
  margin: 0 !important;
  border-radius: 0;
  display: flex;
  align-items: center;
  justify-content: center;
  width: 100%;
  color: #595959 !important;
  background-color: #f0f0f0 !important;
  border: 1px solid silver !important;
  white-space:normal !important;
  word-wrap: break-word; 
}

.btn-primary:hover {
  background-color: #d7d7d7 !important;
}

.btn-group .active {
  color: #fff !important;
  background-color: #1bb193 !important;
  font-weight: 600;
}

.btn-group-inline {
  width: 100%;
  display: flex;
  justify-content: space-around;
}

.btn-group-inline .btn:first-child {
  border-top-left-radius: 4px;
  border-bottom-left-radius: 4px;
}

.btn-group-inline .btn:last-child {
  border-top-right-radius: 4px;
  border-bottom-right-radius: 4px;
}

.btn-group-stacked .btn:first-child {
  border-top-left-radius: 4px;
  border-top-right-radius: 4px;
}

.btn-group-stacked .btn:last-child {
  border-bottom-left-radius: 4px;
  border-bottom-right-radius: 4px;
}

.hr-sep {
  height: 3px;
  width: 100%;
  background: #117d67;
  position: relative;
  border: 0;
  margin: 20px 0;
}

.btn-predict {
  margin: 0 auto !important;
  padding: 10px 20px 10px 20px;
  color: white !important;
  font-size: 16px;
  font-weight: 800 !important;
  background-color: #117d67 !important;
}

.btn-predict:hover {
  background-color: #0F705C !important;
}

.small-box {
  margin-top: 20px;
  margin-bottom: 5px;
  padding: 10px;
  color: white;
  font-weight: 600;
  background-color: #117d67;
}

#lime {
  height: 600px !important;
}
    ")),
    tags$script("
$(document).on('shiny:connected', function(e) {
  var jsWidth = screen.width;
  Shiny.onInputChange('GetScreenWidth', jsWidth);
});
"),

    shinyjs::useShinyjs(),

    shinydashboard::tabItems(

      shinydashboard::tabItem(
        tabName = "prediction",
        shiny::fluidRow(
          shiny::column(2, NULL),
          shiny::column(8,
            shinydashboard::box(
              width = 12,
              solidHeader = TRUE,
              status = "primary",
              title = "Vascular Readmission Prediction",

              shiny::h3("Procedures:"),
              shiny::hr(),
              inputRadioButtons("Endarterectomy", label = "Endarterectomy:",
                choices = list("No" = FALSE, "Yes" = TRUE)),
              shiny::hr(),
              inputRadioButtons("AortaIliacFemoralBypass", label = "Aorta-iliac-femoral bypass:",
                choices = list("No" = FALSE, "Yes" = TRUE)),
              shiny::hr(),
              inputRadioButtons("OtherRepairAneurym", label = "Other aneurysm repair:",
                choices = list("No" = FALSE, "Yes" = TRUE)),
              shiny::hr(class = "hr-sep"),

              shiny::h3("Predictors:"),
              shiny::hr(),
              inputNumeric("AGE", label = "Age (years):", value = 0, min = 0, max = 150, step = 1),
              shiny::hr(),
              inputNumeric("LOS", label = "Length of stay (days):", value = 0, min = 0, max = 150, step = 1),
              shiny::hr(),
              inputRadioButtons("female", label = "Gender:",
                choices = list("Male" = FALSE, "Female" = TRUE)),
              shiny::hr(),
              inputRadioButtons("income", label = "Income percentile:",
                choices = list(
                  "0 to 25th" = "0 to 25th", "26th to 50th" = "26th to 50th",
                  "51st to 75th" = "51st to 75th", "76th to 100th" = "76th to 100th")),
              shiny::hr(),
              inputRadioButtons("payertype_grouped", label = "Primary payer:",
                choices = list(
                  "Medicare" = "Medicare", "Medicaid" = "Medicaid",
                  "Private insurance" = "Private insurance", "Self-pay" = "Self-pay",
                  "Other" = "Other")),
              shiny::hr(),
              inputRadioButtons("race_grouped", label = "Race:",
                choices = list(
                  "White" = "White", "Black" = "Black",
                  "Hispanic" = "Hispanic", "Other" = "Other")),
              shiny::hr(),
              inputRadioButtons("patient_disposition", label = "Patient disposition:",
                choices = list(
                  "Routine" = "Routine",
                  "Transfer to Short-term Hospital" = "Transfer to Short-term Hospital",
                  "Transfer to other type of facility" = "Transfer to other type of facility", 
                  "Home Health Care" = "Home Health Care",
                  "Against Medical Advice" = "Against Medical Advice")),
              shiny::hr(class = "hr-sep"),

              shiny::h3("Comorbidities (Charlson comorbidity index):"),
              shiny::hr(),
              inputRadioButtons("DM", label = "Diabetes mellitus:",
                choices = list("None" = 0, "Uncomplicated" = 1, "End-organ damage" = 2)),
              shiny::hr(),
              inputRadioButtons("LD", label = "Liver disease:",
                choices = list("None" = 0, "Mild" = 1, "Moderate to severe" = 3)),
              shiny::hr(),
              inputRadioButtons("MG", label = "Malignancy:",
                choices = list("None" = 0, "Any leukemia, lymphoma, or localized solid tumor" = 2, "Metastatic solid tumor" = 6)),
              shiny::hr(),
              inputRadioButtons("AIDS", label = "AIDS:",
                choices = list("No" = 0, "Yes" = 6)),
              shiny::hr(),
              inputRadioButtons("CKD", label = "Moderate to severe chronic kidney disease (CKD):",
                choices = list("No" = 0, "Yes" = 2)),
              shiny::hr(),
              inputRadioButtons("CHF", label = "Congestive heart failure (CHF):",
                choices = list("No" = 0, "Yes" = 1)),
              shiny::hr(),
              inputRadioButtons("MI", label = "Myocardial infarction:",
                choices = list("No" = 0, "Yes" = 1)),
              shiny::hr(),
              inputRadioButtons("COPD", label = "Chronic obstructive pulmonary disease (COPD):",
                choices = list("No" = 0, "Yes" = 1)),
              shiny::hr(),
              inputRadioButtons("PVD", label = "Peripheral vascular disease:",
                choices = list("No" = 0, "Yes" = 1)),
              shiny::hr(),
              inputRadioButtons("CVA_TIA", label = "Cerebrovascular accident (CVA) or transient ischemic attack (TIA):",
                choices = list("No" = 0, "Yes" = 1)),
              shiny::hr(),
              inputRadioButtons("DT", label = "Dementia:",
                choices = list("No" = 0, "Yes" = 1)),
              shiny::hr(),
              inputRadioButtons("HP", label = "Hemiplegia:",
                choices = list("No" = 0, "Yes" = 2)),
              shiny::hr(),
              inputRadioButtons("CTD", label = "Connective tissue disease:",
                choices = list("No" = 0, "Yes" = 1)),
              shiny::hr(),
              inputRadioButtons("PUD", label = "Peptic ulcer disease:",
                choices = list("No" = 0, "Yes" = 1)),

              shiny::hr(class = "hr-sep"),
              shiny::div(
                class = "text-center",
                shiny::actionButton("predict", "Predict", class = "btn-predict")
              ),
              shiny::hr(class = "hr-sep"),

              shiny::fluidRow(
                shiny::column(2, NULL),
                shiny::column(8,
                  shiny::div(
                    shiny::div(
                      shiny::div(
                        shiny::h3(shiny::textOutput("readmission")),
                        class = "inner"
                      ),
                      shiny::p("Readmission probability"),
                      class = "small-box"
                    ),
                    class = "col-sm-12"
                  )
                ),
                shiny::column(2, NULL)
              ), shiny::plotOutput("lime")
            )
          ),
          shiny::column(2, NULL)
        )
      )
    )
  )
)