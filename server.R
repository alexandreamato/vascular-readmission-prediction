
match_variable_labels <- function(vars, labels = NULL) {

  # Sanity check
  if (!is.null(labels) && !is.character(labels)) {
    stop("Error: labels parameter must be a character vector")
  }

  for (var_name in names(labels)) {
    if (length(labels[[var_name]]) > 1) {
      stop("Error: label contain more than one entry: ", var_name)
    }
  }

  if (!is.null(labels) && any(duplicated(names(labels)))) {
    stop("Error: labels have duplicated variables")
  }

  as.character(sapply(vars, function(var) {
    if (!is.null(labels) && var %in% names(labels)) {
      labels[[var]]
    } else {
      var
    }
  }))
}

match_level_labels <- function(var, levels, labels = NULL) {

  # Sanity check
  if (!is.null(labels) && !is.character(labels)) {
    stop("Error: labels parameter must be a character vector")
  }

  for (var_name in names(labels)) {
    if (length(labels[[var_name]]) > 1) {
      stop("Error: label contain more than one entry: ", var_name)
    }
  }

  if (!is.null(labels) && any(duplicated(names(labels)))) {
    stop("Error: labels have duplicated variables")
  }

  as.character(sapply(levels, function(level) {
    var_level <- paste(var, level, sep = "_")
    if (!is.null(labels) && var_level %in% names(labels)) {
      labels[[var_level]]
    } else {
      level
    }
  }))
}


library(caret)
library(lime)
class_analysis <- readRDS("sdatools_classAnalysis_cf764afdcd12b44769d6001344283df001f628152d60efcf695b50c003d91e63.rds")
explainer <- lime::lime(class_analysis$data_train, class_analysis$result_list[[1]]$model, bin_continuous = FALSE)

labels <- c(
  female = "Female",
  AGE = "Age",
  LOS_Log = "LOS",
  income = "Income",
  charlson = "Charlson",
  patient_disposition = "Disposition",
  payertype_grouped = "Payer",
  race_grouped = "Race",
  Endarterectomy = "Endarterectomy",
  AortaIliacFemoralBypass = "Aorta-iliac-femoral bypass",
  OtherRepairAneurym = "Other aneurysm repair"
)

server <- function(input, output, session) {

  output$readmission <- renderText("0 %")

  shiny::observeEvent(input$predict, {
    shiny::isolate({

      width <- input$GetScreenWidth
      if (width < 500) {
        font_size <- 12
        line_size <- 10
        y_axis_rotation <- 60
        y_label <- NULL
      } else {
        font_size <- 18
        line_size <- 20
        y_axis_rotation <- 0
        y_label <- "Feature"
      }

      charlson <- as.integer(input$DM) + as.integer(input$LD) + as.integer(input$MG) + 
        as.integer(input$AIDS) + as.integer(input$CKD) + as.integer(input$CHF) + 
        as.integer(input$MI) + as.integer(input$COPD) + as.integer(input$PVD) +
        as.integer(input$CVA_TIA) + as.integer(input$DT) + as.integer(input$HP) +
        as.integer(input$CTD) + as.integer(input$PUD)

      df <- data.frame(
        AGE = as.integer(input$AGE),
        female = factor(input$female, levels = c("FALSE", "TRUE")),
        charlson = as.numeric(charlson),
        LOS_Log = log(as.numeric(input$LOS) + 1),
        income = factor(input$income, 
          levels = c("0 to 25th", "26th to 50th", "51st to 75th", "76th to 100th")),
        payertype_grouped = factor(input$payertype_grouped, 
          levels = c("Medicare", "Medicaid", "Private insurance", "Self-pay", "Other")),
        race_grouped = factor(input$race_grouped, 
          levels = c("White", "Black", "Hispanic", "Other")),
        patient_disposition = factor(input$patient_disposition,
          levels = c("Routine", "Transfer to Short-term Hospital",
            "Transfer to other type of facility", "Home Health Care", "Against Medical Advice")),
        Endarterectomy = factor(input$Endarterectomy, levels = c("FALSE", "TRUE")),
        AortaIliacFemoralBypass = factor(input$AortaIliacFemoralBypass, levels = c("FALSE", "TRUE")),
        OtherRepairAneurym = factor(input$OtherRepairAneurym, levels = c("FALSE", "TRUE"))
      )

      value <- caret::predict.train(class_analysis$result_list[[1]]$model, newdata = df, type = "prob")
      output$readmission <- shiny::renderText(paste0(round(value$True, digits = 2) * 100, " %"))

      explanation <- lime::explain(df, explainer, n_labels = 1, n_features = 10)

      explanation$feature_labels <- sapply(explanation$feature_desc, function(var) {
        if (var %in% names(labels)) {
          return (labels[[var]])
        } else {
          for (predictor in class_analysis$predictors[which(startsWith(var, class_analysis$predictors))]) {
            for (level in class_analysis$categoric_predictors[[predictor]]) {
              if (paste0(predictor, " = ", level) == var) {
                return(
                  paste0(strwrap(paste0(
                    match_variable_labels(predictor, labels), " = ", match_level_labels(predictor, level, labels)
                  ), width = line_size), collapse = "\n")
                )
              }
            }
          }
        }
        return (var)
      })

      ncol = 2
      type_pal <- c("Supports", "Contradicts")
      explanation$type <- factor(ifelse(sign(explanation$feature_weight) == 1, type_pal[1], type_pal[2]), levels = type_pal)

      description <- explanation$feature_labels
      explanation$description <- factor(description, levels = description[order(abs(explanation$feature_weight))])
      explanation$probability <- paste0("Predicted probability: ", round(explanation$label_prob, digits = 2) * 100, " %")
      explanation$label <- paste0("Predicted outcome: ", explanation$label)

      p <- ggplot2::ggplot(explanation) +
        ggplot2::facet_wrap(~label + probability, scales = "free", ncol = ncol) +
        ggplot2::geom_col(ggplot2::aes_(~description, ~feature_weight, fill = ~type)) + 
        ggplot2::coord_flip() +
        ggplot2::scale_fill_manual(values = c("forestgreen", "firebrick"), drop = FALSE) +
        ggplot2::labs(y = "Weight", x = y_label, fill = NULL) +
        ggplot2::theme(
          panel.border = ggplot2::element_rect(colour = "black", fill = NA, size = 0.3),
          rect = ggplot2::element_rect(fill = "white", linetype = 1, colour = NA),
          text = ggplot2::element_text(size = font_size, family = "sans"), 
          title = ggplot2::element_text(hjust = 0.5),
          axis.text.y = ggplot2::element_text(angle = y_axis_rotation, hjust = 1),
          axis.text.x = ggplot2::element_text(angle = 90, hjust = 1),
          panel.grid.major.y = ggplot2::element_line(colour = "#D8D8D8"), 
          panel.grid.minor.y = ggplot2::element_blank(),
          panel.grid.major.x = ggplot2::element_blank(), 
          panel.grid.minor.x = ggplot2::element_blank(),
          panel.background = ggplot2::element_blank(),
          legend.key = ggplot2::element_rect(fill = "#FFFFFF00"),
          legend.position = "bottom"
        )

      output$lime <- shiny::renderPlot(p)

    })
  })

}