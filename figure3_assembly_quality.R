# ============================================================
# ASSEMBLY QUALITY ANALYSIS
# Comparison of assembly N50 and contig number
# between mcr-9.1 localization categories
# ============================================================


# ------------------------------------------------------------
# 1. Load packages
# ------------------------------------------------------------

library(readxl)
library(ggplot2)


# ------------------------------------------------------------
# 2. Define input and output paths
# ------------------------------------------------------------

input_file <- "data/Supplementary_Table_1.xlsx"

figure_dir <- "figures"

results_dir <- "statistical_results"


# ------------------------------------------------------------
# 3. Create output directories
# ------------------------------------------------------------

if (!dir.exists(figure_dir)) {
  dir.create(
    figure_dir,
    recursive = TRUE
  )
}

if (!dir.exists(results_dir)) {
  dir.create(
    results_dir,
    recursive = TRUE
  )
}


# ------------------------------------------------------------
# 4. Check input file
# ------------------------------------------------------------

if (!file.exists(input_file)) {
  stop(
    paste0(
      "Input file not found: ",
      input_file,
      "\n\n",
      "Please make sure that Supplementary_Table_1.xlsx ",
      "is located in the data/ directory."
    )
  )
}


# ------------------------------------------------------------
# 5. Read the master dataset
# ------------------------------------------------------------

data <- read_excel(
  input_file
)

data <- as.data.frame(data)


# ------------------------------------------------------------
# 6. Check required columns
# ------------------------------------------------------------

required_columns <- c(
  "Sample",
  "N50",
  "Number of contigs ",
  "MOB-suite Localization"
)


missing_columns <- setdiff(
  required_columns,
  names(data)
)


if (length(missing_columns) > 0) {
  stop(
    paste0(
      "The following required columns are missing:\n",
      paste(
        missing_columns,
        collapse = "\n"
      )
    )
  )
}


# ------------------------------------------------------------
# 7. Remove empty rows
# ------------------------------------------------------------

data <- data[
  !is.na(data$Sample) &
    trimws(
      as.character(data$Sample)
    ) != "",
]


# ------------------------------------------------------------
# 8. Convert N50 to numeric
# ------------------------------------------------------------

data$N50_numeric <- as.numeric(
  gsub(
    "[^0-9.-]",
    "",
    as.character(data$N50)
  )
)


# ------------------------------------------------------------
# 9. Convert number of contigs to numeric
# ------------------------------------------------------------

data$Contig_number_numeric <- as.numeric(
  data[["Number of contigs "]]
)


# ------------------------------------------------------------
# 10. Standardize localization
# ------------------------------------------------------------

data$Localization <- trimws(
  as.character(
    data[["MOB-suite Localization"]]
  )
)


data$Localization <- factor(
  data$Localization,
  levels = c(
    "Plasmid-associated",
    "Predicted chromosome"
  )
)


# ------------------------------------------------------------
# 11. Remove rows with missing analysis values
# ------------------------------------------------------------

analysis_data <- data[
  !is.na(data$N50_numeric) &
    !is.na(data$Contig_number_numeric) &
    !is.na(data$Localization),
]


# ------------------------------------------------------------
# 12. Check dataset
# ------------------------------------------------------------

cat("\n")
cat("============================================\n")
cat("ASSEMBLY QUALITY DATASET\n")
cat("============================================\n\n")


cat(
  "Number of isolates:",
  nrow(analysis_data),
  "\n\n"
)


cat("Localization categories:\n")

print(
  table(
    analysis_data$Localization
  )
)


cat("\nN50 summary:\n")

print(
  summary(
    analysis_data$N50_numeric
  )
)


cat("\nContig number summary:\n")

print(
  summary(
    analysis_data$Contig_number_numeric
  )
)


# ------------------------------------------------------------
# 13. Check localization groups
# ------------------------------------------------------------

if (
  length(
    unique(
      analysis_data$Localization
    )
  ) != 2
) {
  
  stop(
    "Both localization categories must be present."
  )
  
}


# ------------------------------------------------------------
# 14. Wilcoxon rank-sum test: N50
# ------------------------------------------------------------

wilcox_N50 <- wilcox.test(
  N50_numeric ~ Localization,
  data = analysis_data,
  exact = TRUE
)


# ------------------------------------------------------------
# 15. Wilcoxon rank-sum test: contig number
# ------------------------------------------------------------

wilcox_contigs <- wilcox.test(
  Contig_number_numeric ~ Localization,
  data = analysis_data,
  exact = TRUE
)


# ------------------------------------------------------------
# 16. Print statistical results
# ------------------------------------------------------------

cat("\n")
cat("============================================\n")
cat("Wilcoxon test: N50\n")
cat("============================================\n\n")

print(
  wilcox_N50
)


cat("\n")
cat("============================================\n")
cat("Wilcoxon test: Number of contigs\n")
cat("============================================\n\n")

print(
  wilcox_contigs
)


# ------------------------------------------------------------
# 17. Figure: Assembly N50
# ------------------------------------------------------------

p_N50 <- ggplot(
  analysis_data,
  aes(
    x = Localization,
    y = N50_numeric
  )
) +
  
  geom_boxplot(
    width = 0.55,
    outlier.shape = NA
  ) +
  
  geom_jitter(
    width = 0.12,
    height = 0,
    size = 2.5,
    alpha = 0.75
  ) +
  
  labs(
    x = "Localization category",
    y = "Assembly N50 (kb)"
  ) +
  
  theme_classic(
    base_size = 13
  ) +
  
  theme(
    axis.title = element_text(
      size = 13
    ),
    axis.text = element_text(
      size = 11
    ),
    axis.text.x = element_text(
      angle = 0,
      hjust = 0.5
    ),
    plot.margin = margin(
      10,
      10,
      10,
      10
    )
  )


# ------------------------------------------------------------
# 18. Display N50 figure
# ------------------------------------------------------------

print(p_N50)


# ------------------------------------------------------------
# 19. Save N50 figure
# ------------------------------------------------------------

ggsave(
  filename = file.path(
    figure_dir,
    "Assembly_N50_by_localization.pdf"
  ),
  plot = p_N50,
  width = 7,
  height = 5.5,
  units = "in",
  device = cairo_pdf
)


ggsave(
  filename = file.path(
    figure_dir,
    "Assembly_N50_by_localization.tiff"
  ),
  plot = p_N50,
  width = 7,
  height = 5.5,
  units = "in",
  dpi = 600,
  compression = "lzw"
)


ggsave(
  filename = file.path(
    figure_dir,
    "Assembly_N50_by_localization.png"
  ),
  plot = p_N50,
  width = 7,
  height = 5.5,
  units = "in",
  dpi = 600
)


# ------------------------------------------------------------
# 20. Figure: Number of contigs
# ------------------------------------------------------------

p_contigs <- ggplot(
  analysis_data,
  aes(
    x = Localization,
    y = Contig_number_numeric
  )
) +
  
  geom_boxplot(
    width = 0.55,
    outlier.shape = NA
  ) +
  
  geom_jitter(
    width = 0.12,
    height = 0,
    size = 2.5,
    alpha = 0.75
  ) +
  
  labs(
    x = "Localization category",
    y = "Number of contigs"
  ) +
  
  theme_classic(
    base_size = 13
  ) +
  
  theme(
    axis.title = element_text(
      size = 13
    ),
    axis.text = element_text(
      size = 11
    ),
    axis.text.x = element_text(
      angle = 0,
      hjust = 0.5
    ),
    plot.margin = margin(
      10,
      10,
      10,
      10
    )
  )


# ------------------------------------------------------------
# 21. Display contig-number figure
# ------------------------------------------------------------

print(p_contigs)


# ------------------------------------------------------------
# 22. Save contig-number figure
# ------------------------------------------------------------

ggsave(
  filename = file.path(
    figure_dir,
    "Contig_number_by_localization.pdf"
  ),
  plot = p_contigs,
  width = 7,
  height = 5.5,
  units = "in",
  device = cairo_pdf
)


ggsave(
  filename = file.path(
    figure_dir,
    "Contig_number_by_localization.tiff"
  ),
  plot = p_contigs,
  width = 7,
  height = 5.5,
  units = "in",
  dpi = 600,
  compression = "lzw"
)


ggsave(
  filename = file.path(
    figure_dir,
    "Contig_number_by_localization.png"
  ),
  plot = p_contigs,
  width = 7,
  height = 5.5,
  units = "in",
  dpi = 600
)


# ------------------------------------------------------------
# 23. Save statistical results
# ------------------------------------------------------------

results_file <- file.path(
  results_dir,
  "Assembly_quality_Wilcoxon_results.txt"
)


sink(results_file)


cat(
  "ASSEMBLY QUALITY ANALYSIS\n"
)

cat(
  "=========================\n\n"
)


cat(
  "Input file:\n",
  input_file,
  "\n\n"
)


cat(
  "Number of isolates:",
  nrow(analysis_data),
  "\n\n"
)


cat(
  "Localization categories:\n"
)

print(
  table(
    analysis_data$Localization
  )
)


cat(
  "\n\nN50 summary:\n"
)

print(
  summary(
    analysis_data$N50_numeric
  )
)


cat(
  "\n\nContig number summary:\n"
)

print(
  summary(
    analysis_data$Contig_number_numeric
  )
)


cat(
  "\n\nWilcoxon rank-sum test: N50\n"
)

print(
  wilcox_N50
)


cat(
  "\n\nWilcoxon rank-sum test: Number of contigs\n"
)

print(
  wilcox_contigs
)


sink()


# ------------------------------------------------------------
# 24. Save the exact analysis dataset
# ------------------------------------------------------------

write.csv(
  analysis_data,
  file = file.path(
    results_dir,
    "Assembly_quality_analysis_dataset.csv"
  ),
  row.names = FALSE
)


# ------------------------------------------------------------
# 25. Save session information
# ------------------------------------------------------------

writeLines(
  capture.output(
    sessionInfo()
  ),
  con = file.path(
    results_dir,
    "Assembly_quality_sessionInfo.txt"
  )
)


# ------------------------------------------------------------
# 26. Final message
# ------------------------------------------------------------

cat("\n")
cat("============================================\n")
cat("Assembly quality analysis completed successfully.\n")
cat("============================================\n\n")

cat(
  "Figures saved in: ",
  figure_dir,
  "\n",
  sep = ""
)

cat(
  "Statistical results saved in: ",
  results_dir,
  "\n",
  sep = ""
)

cat("\n")