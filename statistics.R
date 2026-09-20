# ============================================================
# STATISTICAL ANALYSIS OF mcr-9.1 GENOMIC ARCHITECTURE
# Cronobacter sakazakii
#
# Dataset:
#   38 mcr-9.1-positive isolates
#
# Input files:
#   data/Supplementary_Table_1.xlsx
#   data/mcr9_genetic_context.csv
#
# Statistical analyses:
#   1. Sequence-type distribution
#   2. qseBC distribution across sequence types
#   3. Architecture-size calculation
#   4. Architecture-size distribution across sequence types
#   5. Kruskal-Wallis test
#   6. Dunn's post-hoc test with BH adjustment
#   7. ST1 vs non-ST1 comparison
#   8. Wilcoxon rank-sum test
#   9. Effect sizes
#  10. Fisher's exact test
#
# R version:
#   4.6.0
# ============================================================


# ============================================================
# 1. Load packages
# ============================================================

library(dplyr)
library(rstatix)
library(readxl)


# ============================================================
# 2. Define input and output paths
# ============================================================

metadata_file <- "data/Supplementary_Table_1.xlsx"

architecture_file <- "data/mcr9_genetic_context.csv"

output_dir <- "statistical_results"


# ============================================================
# 3. Create output directory
# ============================================================

if (!dir.exists(output_dir)) {
  
  dir.create(
    output_dir,
    recursive = TRUE
  )
  
}


# ============================================================
# 4. Check input files
# ============================================================

if (!file.exists(metadata_file)) {
  
  stop(
    paste0(
      "Metadata file not found: ",
      metadata_file
    )
  )
  
}


if (!file.exists(architecture_file)) {
  
  stop(
    paste0(
      "Architecture file not found: ",
      architecture_file
    )
  )
  
}


# ============================================================
# 5. Read input files
# ============================================================

metadata <- read_excel(
  metadata_file
)

metadata <- as.data.frame(
  metadata
)


architecture <- read.csv(
  architecture_file,
  stringsAsFactors = FALSE,
  check.names = FALSE
)


# ============================================================
# 6. Check dataset sizes
# ============================================================

cat("\n============================================================\n")
cat("DATASET CHECK\n")
cat("============================================================\n")


cat(
  "Metadata isolates:",
  nrow(metadata),
  "\n"
)


cat(
  "Architecture isolates:",
  nrow(architecture),
  "\n"
)


if (nrow(metadata) != 38) {
  
  warning(
    paste0(
      "Expected 38 isolates in metadata, but ",
      nrow(metadata),
      " rows were detected."
    )
  )
  
}


if (nrow(architecture) != 38) {
  
  warning(
    paste0(
      "Expected 38 isolates in architecture data, but ",
      nrow(architecture),
      " rows were detected."
    )
  )
  
}


# ============================================================
# 7. Check required metadata columns
# ============================================================

required_metadata_columns <- c(
  "Sample",
  "ST"
)


missing_metadata_columns <- setdiff(
  required_metadata_columns,
  names(metadata)
)


if (length(missing_metadata_columns) > 0) {
  
  stop(
    paste0(
      "The following metadata columns are missing:\n",
      paste(
        missing_metadata_columns,
        collapse = "\n"
      )
    )
  )
  
}


# ============================================================
# 8. Check required architecture columns
# ============================================================

required_architecture_columns <- c(
  "Sample",
  "ST",
  "Genetic_architecture"
)


missing_architecture_columns <- setdiff(
  required_architecture_columns,
  names(architecture)
)


if (length(missing_architecture_columns) > 0) {
  
  stop(
    paste0(
      "The following architecture columns are missing:\n",
      paste(
        missing_architecture_columns,
        collapse = "\n"
      )
    )
  )
  
}


# ============================================================
# 9. Standardize identifiers
# ============================================================

metadata <- metadata %>%
  
  mutate(
    Sample = trimws(
      as.character(Sample)
    ),
    ST = trimws(
      as.character(ST)
    )
  )


architecture <- architecture %>%
  
  mutate(
    Sample = trimws(
      as.character(Sample)
    ),
    ST = trimws(
      as.character(ST)
    ),
    Genetic_architecture = trimws(
      as.character(Genetic_architecture)
    )
  )


# ============================================================
# 10. Check sample matching between datasets
# ============================================================

metadata_samples <- unique(
  metadata$Sample
)


architecture_samples <- unique(
  architecture$Sample
)


missing_in_architecture <- setdiff(
  metadata_samples,
  architecture_samples
)


missing_in_metadata <- setdiff(
  architecture_samples,
  metadata_samples
)


if (length(missing_in_architecture) > 0) {
  
  stop(
    paste0(
      "Samples present in metadata but missing from architecture data:\n",
      paste(
        missing_in_architecture,
        collapse = "\n"
      )
    )
  )
  
}


if (length(missing_in_metadata) > 0) {
  
  stop(
    paste0(
      "Samples present in architecture data but missing from metadata:\n",
      paste(
        missing_in_metadata,
        collapse = "\n"
      )
    )
  )
  
}


cat(
  "\nAll 38 samples successfully matched between input files.\n"
)


# ============================================================
# 11. Verify ST assignments
# ============================================================

ST_mismatch <- architecture %>%
  
  select(
    Sample,
    ST_architecture = ST
  ) %>%
  
  left_join(
    metadata %>%
      select(
        Sample,
        ST_metadata = ST
      ),
    by = "Sample"
  ) %>%
  
  filter(
    ST_architecture != ST_metadata
  )


if (nrow(ST_mismatch) > 0) {
  
  print(ST_mismatch)
  
  stop(
    "ST assignments do not match between the two input files."
  )
  
}


# ============================================================
# 12. Use architecture dataset as analysis dataset
# ============================================================

analysis_data <- architecture


# ============================================================
# 13. Sequence-type distribution
# ============================================================

cat("\n============================================================\n")
cat("SEQUENCE TYPE DISTRIBUTION\n")
cat("============================================================\n")


ST_distribution <- table(
  analysis_data$ST
)


print(
  ST_distribution
)


write.csv(
  as.data.frame(
    ST_distribution
  ),
  file.path(
    output_dir,
    "ST_distribution.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 14. Genetic architecture distribution
# ============================================================

cat("\n============================================================\n")
cat("GENETIC ARCHITECTURE DISTRIBUTION\n")
cat("============================================================\n")


architecture_distribution <- table(
  analysis_data$Genetic_architecture
)


print(
  architecture_distribution
)


write.csv(
  as.data.frame(
    architecture_distribution
  ),
  file.path(
    output_dir,
    "genetic_architecture_distribution.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 15. Determine qseBC presence/absence
# ============================================================
#
# qseBC is considered present only when BOTH qseB and qseC
# are present in the annotated genetic architecture.
# ============================================================

analysis_data$qseBC <- ifelse(
  
  grepl(
    "qseB",
    analysis_data$Genetic_architecture,
    ignore.case = TRUE
  ) &
    
    grepl(
      "qseC",
      analysis_data$Genetic_architecture,
      ignore.case = TRUE
    ),
  
  "Present",
  
  "Absent"
  
)


analysis_data$qseBC <- factor(
  analysis_data$qseBC,
  levels = c(
    "Absent",
    "Present"
  )
)


# ============================================================
# 16. qseBC distribution
# ============================================================

cat("\n============================================================\n")
cat("qseBC DISTRIBUTION\n")
cat("============================================================\n")


qseBC_distribution <- table(
  analysis_data$qseBC
)


print(
  qseBC_distribution
)


write.csv(
  as.data.frame(
    qseBC_distribution
  ),
  file.path(
    output_dir,
    "qseBC_distribution.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 17. ST × qseBC contingency table
# ============================================================

qseBC_table <- table(
  analysis_data$ST,
  analysis_data$qseBC
)


cat("\nST × qseBC contingency table:\n")

print(
  qseBC_table
)


write.csv(
  as.data.frame.matrix(
    qseBC_table
  ),
  file.path(
    output_dir,
    "ST_by_qseBC_contingency_table.csv"
  )
)


# ============================================================
# 18. Fisher's exact test
# ============================================================
#
# The contingency table contains multiple sequence types.
# Monte Carlo simulation is therefore used.
#
# B = 10,000 simulations.
# ============================================================

set.seed(
  12345
)


fisher_result <- fisher.test(
  qseBC_table,
  simulate.p.value = TRUE,
  B = 10000
)


cat("\n============================================================\n")
cat("FISHER'S EXACT TEST\n")
cat("============================================================\n")


print(
  fisher_result
)


capture.output(
  fisher_result,
  file = file.path(
    output_dir,
    "Fisher_qseBC_test.txt"
  )
)


# ============================================================
# 19. Calculate architecture size
# ============================================================
#
# Architecture size is defined as the number of relevant
# annotated components in the mcr-9.1-associated region.
#
# Counted components:
#
#   mcr-9.1
#   WbuC
#   qseB
#   qseC
#   annotated IS elements
#
# Other genes or hypothetical proteins are not counted.
# ============================================================


IS_elements <- c(
  "IS26",
  "IS481",
  "IS903B",
  "IS6.5",
  "IS110",
  "IS3",
  "IS1",
  "IS5"
)


calculate_architecture_size <- function(x) {
  
  if (
    is.na(x) ||
    trimws(x) == ""
  ) {
    
    return(
      NA_integer_
    )
    
  }
  
  
  components <- unlist(
    strsplit(
      as.character(x),
      "\\s*[–—-]\\s*"
    )
  )
  
  
  components <- trimws(
    components
  )
  
  
  components <- components[
    components != ""
  ]
  
  
  count <- 0L
  
  
  # mcr-9.1
  if (
    any(
      grepl(
        "^mcr-9\\.1$",
        components,
        ignore.case = TRUE
      )
    )
  ) {
    
    count <- count + 1L
    
  }
  
  
  # WbuC
  if (
    any(
      grepl(
        "^WbuC$",
        components,
        ignore.case = TRUE
      )
    )
  ) {
    
    count <- count + 1L
    
  }
  
  
  # qseB
  if (
    any(
      grepl(
        "^qseB$",
        components,
        ignore.case = TRUE
      )
    )
  ) {
    
    count <- count + 1L
    
  }
  
  
  # qseC
  if (
    any(
      grepl(
        "^qseC$",
        components,
        ignore.case = TRUE
      )
    )
  ) {
    
    count <- count + 1L
    
  }
  
  
  # IS elements
  for (
    is_element in IS_elements
  ) {
    
    pattern <- paste0(
      "^",
      gsub(
        "\\.",
        "\\\\.",
        is_element
      ),
      "$"
    )
    
    
    if (
      any(
        grepl(
          pattern,
          components,
          ignore.case = TRUE
        )
      )
    ) {
      
      count <- count + 1L
      
    }
    
  }
  
  
  return(
    as.integer(count)
  )
  
}


analysis_data$Architecture_size <- sapply(
  analysis_data$Genetic_architecture,
  calculate_architecture_size
)


# ============================================================
# 20. Check architecture-size calculation
# ============================================================

cat("\n============================================================\n")
cat("ARCHITECTURE SIZE CHECK\n")
cat("============================================================\n")


architecture_check <- analysis_data %>%
  
  select(
    Sample,
    ST,
    Genetic_architecture,
    Architecture_size
  )


print(
  architecture_check
)


write.csv(
  architecture_check,
  file.path(
    output_dir,
    "architecture_size_check.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 21. Architecture-size distribution
# ============================================================

cat("\nArchitecture size distribution:\n")


architecture_size_distribution <- table(
  analysis_data$Architecture_size,
  useNA = "ifany"
)


print(
  architecture_size_distribution
)


write.csv(
  as.data.frame(
    architecture_size_distribution
  ),
  file.path(
    output_dir,
    "architecture_size_distribution.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 22. Descriptive statistics by sequence type
# ============================================================

architecture_summary <- analysis_data %>%
  
  group_by(
    ST
  ) %>%
  
  summarise(
    
    n = n(),
    
    median = median(
      Architecture_size,
      na.rm = TRUE
    ),
    
    mean = mean(
      Architecture_size,
      na.rm = TRUE
    ),
    
    min = min(
      Architecture_size,
      na.rm = TRUE
    ),
    
    max = max(
      Architecture_size,
      na.rm = TRUE
    ),
    
    .groups = "drop"
    
  ) %>%
  
  arrange(
    desc(n),
    ST
  )


cat("\n============================================================\n")
cat("ARCHITECTURE SIZE BY SEQUENCE TYPE\n")
cat("============================================================\n")


print(
  architecture_summary
)


write.csv(
  architecture_summary,
  file.path(
    output_dir,
    "architecture_size_by_ST.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 23. Kruskal-Wallis test
# ============================================================

kruskal_result <- kruskal.test(
  Architecture_size ~ ST,
  data = analysis_data
)


cat("\n============================================================\n")
cat("KRUSKAL-WALLIS TEST\n")
cat("============================================================\n")


print(
  kruskal_result
)


capture.output(
  kruskal_result,
  file = file.path(
    output_dir,
    "Kruskal_Wallis_test.txt"
  )
)


# ============================================================
# 24. Kruskal-Wallis effect size
# ============================================================

kruskal_effect <- kruskal_effsize(
  analysis_data,
  Architecture_size ~ ST
)


cat("\n============================================================\n")
cat("KRUSKAL-WALLIS EFFECT SIZE\n")
cat("============================================================\n")


print(
  kruskal_effect
)


write.csv(
  kruskal_effect,
  file.path(
    output_dir,
    "Kruskal_Wallis_effect_size.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 25. Dunn's post-hoc test
# ============================================================

dunn_result <- analysis_data %>%
  
  dunn_test(
    Architecture_size ~ ST,
    p.adjust.method = "BH"
  )


cat("\n============================================================\n")
cat("DUNN'S POST-HOC TEST WITH BH ADJUSTMENT\n")
cat("============================================================\n")


print(
  dunn_result
)


write.csv(
  dunn_result,
  file.path(
    output_dir,
    "Dunn_posthoc_BH.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 26. Define ST1 versus non-ST1
# ============================================================

analysis_data$ST_group <- ifelse(
  
  analysis_data$ST == "ST1",
  
  "ST1",
  
  "Non-ST1"
  
)


analysis_data$ST_group <- factor(
  analysis_data$ST_group,
  levels = c(
    "ST1",
    "Non-ST1"
  )
)


# ============================================================
# 27. ST1 versus non-ST1 descriptive statistics
# ============================================================

ST1_summary <- analysis_data %>%
  
  group_by(
    ST_group
  ) %>%
  
  summarise(
    
    n = n(),
    
    median = median(
      Architecture_size,
      na.rm = TRUE
    ),
    
    mean = mean(
      Architecture_size,
      na.rm = TRUE
    ),
    
    min = min(
      Architecture_size,
      na.rm = TRUE
    ),
    
    max = max(
      Architecture_size,
      na.rm = TRUE
    ),
    
    .groups = "drop"
    
  )


cat("\n============================================================\n")
cat("ST1 VERSUS NON-ST1 DESCRIPTIVE STATISTICS\n")
cat("============================================================\n")


print(
  ST1_summary
)


write.csv(
  ST1_summary,
  file.path(
    output_dir,
    "ST1_vs_nonST1_summary.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 28. Wilcoxon rank-sum test
# ============================================================

wilcox_result <- wilcox.test(
  Architecture_size ~ ST_group,
  data = analysis_data,
  exact = FALSE
)


cat("\n============================================================\n")
cat("WILCOXON RANK-SUM TEST\n")
cat("============================================================\n")


print(
  wilcox_result
)


capture.output(
  wilcox_result,
  file = file.path(
    output_dir,
    "Wilcoxon_ST1_vs_nonST1.txt"
  )
)


# ============================================================
# 29. Wilcoxon effect size
# ============================================================

wilcox_effect <- wilcox_effsize(
  analysis_data,
  Architecture_size ~ ST_group
)


cat("\n============================================================\n")
cat("WILCOXON EFFECT SIZE\n")
cat("============================================================\n")


print(
  wilcox_effect
)


write.csv(
  wilcox_effect,
  file.path(
    output_dir,
    "Wilcoxon_effect_size.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 30. Final statistical summary
# ============================================================

summary_results <- data.frame(
  
  Analysis = c(
    "Kruskal-Wallis test",
    "Dunn post-hoc test with BH adjustment",
    "Wilcoxon rank-sum: ST1 vs non-ST1",
    "Fisher's exact test: ST vs qseBC"
  ),
  
  Result = c(
    
    paste0(
      "Chi-squared = ",
      round(
        unname(
          kruskal_result$statistic
        ),
        3
      ),
      "; df = ",
      unname(
        kruskal_result$parameter
      ),
      "; P = ",
      format.pval(
        kruskal_result$p.value,
        digits = 4
      )
    ),
    
    "Pairwise comparisons evaluated with Benjamini-Hochberg adjustment",
    
    paste0(
      "W = ",
      unname(
        wilcox_result$statistic
      ),
      "; P = ",
      format.pval(
        wilcox_result$p.value,
        digits = 4
      )
    ),
    
    paste0(
      "P = ",
      format.pval(
        fisher_result$p.value,
        digits = 4
      ),
      "; 10,000 Monte Carlo simulations"
    )
    
  ),
  
  stringsAsFactors = FALSE
)


cat("\n============================================================\n")
cat("FINAL STATISTICAL SUMMARY\n")
cat("============================================================\n")


print(
  summary_results
)


write.csv(
  summary_results,
  file.path(
    output_dir,
    "statistical_analysis_summary.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 31. Save complete analysis dataset
# ============================================================

write.csv(
  analysis_data,
  file.path(
    output_dir,
    "analysis_dataset_with_derived_variables.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 32. Save session information
# ============================================================

writeLines(
  capture.output(
    sessionInfo()
  ),
  con = file.path(
    output_dir,
    "sessionInfo.txt"
  )
)


# ============================================================
# 33. Final message
# ============================================================

cat("\n============================================================\n")
cat("STATISTICAL ANALYSIS COMPLETED SUCCESSFULLY\n")
cat("============================================================\n\n")


cat(
  "Metadata input:\n",
  metadata_file,
  "\n\n"
)


cat(
  "Architecture input:\n",
  architecture_file,
  "\n\n"
)


cat(
  "Output directory:\n",
  output_dir,
  "\n"
)


cat("\n============================================================\n")