# ============================================================
# FIGURE 4
# Temporal distribution of mcr-9.1-positive Cronobacter sakazakii
# isolates (1982–2025)
#
# Input:
#   data/Supplementary_Table_1.xlsx
#
# Output:
#   figures/Figure_1_temporal_distribution.pdf
#   figures/Figure_1_temporal_distribution.svg
#   figures/Figure_1_temporal_distribution.png
# ============================================================


# ============================================================
# 1. Load packages
# ============================================================

library(ggplot2)
library(dplyr)
library(readxl)


# ============================================================
# 2. Define input and output paths
# ============================================================

metadata_file <- "data/Supplementary_Table_1.xlsx"

output_dir <- "figures"


if (!dir.exists(output_dir)) {
  
  dir.create(
    output_dir,
    recursive = TRUE
  )
  
}


# ============================================================
# 3. Check input file
# ============================================================

if (!file.exists(metadata_file)) {
  
  stop(
    paste0(
      "Input file not found: ",
      metadata_file,
      "\n\n",
      "Please make sure that Supplementary_Table_1.xlsx ",
      "is located in the data/ directory."
    )
  )
  
}


# ============================================================
# 4. Read Supplementary Table 1
# ============================================================

data <- read_excel(
  metadata_file
)


data <- as.data.frame(
  data
)


# ============================================================
# 5. Check required columns
# ============================================================

required_columns <- c(
  "Sample",
  "Year of isolation",
  "ST",
  "MOB-suite Localization"
)


missing_columns <- setdiff(
  required_columns,
  names(data)
)


if (length(missing_columns) > 0) {
  
  stop(
    paste0(
      "The following required columns are missing from ",
      "Supplementary_Table_1.xlsx:\n\n",
      paste(
        missing_columns,
        collapse = "\n"
      ),
      "\n\nAvailable columns are:\n",
      paste(
        names(data),
        collapse = "\n"
      )
    )
  )
  
}


# ============================================================
# 6. Check dataset size
# ============================================================

if (nrow(data) != 38) {
  
  warning(
    paste0(
      "Expected 38 isolates, but ",
      nrow(data),
      " rows were detected."
    )
  )
  
}


# ============================================================
# 7. Prepare plotting data
# ============================================================

plot_data <- data


# ------------------------------------------------------------
# Convert year to numeric
# ------------------------------------------------------------

plot_data$Year <- suppressWarnings(
  as.numeric(
    plot_data[["Year of isolation"]]
  )
)


# ------------------------------------------------------------
# Standardize Sample
# ------------------------------------------------------------

plot_data$Sample <- trimws(
  as.character(
    plot_data$Sample
  )
)


# ------------------------------------------------------------
# Standardize ST
# ------------------------------------------------------------

plot_data$ST <- trimws(
  as.character(
    plot_data$ST
  )
)


# ------------------------------------------------------------
# Standardize genomic localization
# ------------------------------------------------------------

plot_data$Localization <- trimws(
  as.character(
    plot_data[["MOB-suite Localization"]]
  )
)


# ============================================================
# 8. Check localization categories
# ============================================================

expected_localization <- c(
  "Predicted chromosome",
  "Plasmid-associated"
)


unexpected_localization <- setdiff(
  unique(
    plot_data$Localization[
      !is.na(
        plot_data$Localization
      )
    ]
  ),
  expected_localization
)


if (length(unexpected_localization) > 0) {
  
  stop(
    paste0(
      "Unexpected genomic localization value(s) detected:\n",
      paste(
        unexpected_localization,
        collapse = "\n"
      ),
      "\n\nExpected values are:\n",
      paste(
        expected_localization,
        collapse = "\n"
      )
    )
  )
  
}


# ============================================================
# 9. Exclude isolates with missing year
# ============================================================
#
# Isolates without an available isolation year are excluded
# only from the temporal figure.
# ============================================================

plot_data <- plot_data %>%
  
  filter(
    !is.na(Year)
  )


# ============================================================
# 10. Check temporal range
# ============================================================

cat("\n")
cat("============================================================\n")
cat("TEMPORAL DATA CHECK\n")
cat("============================================================\n")


cat(
  "Total isolates in metadata:",
  nrow(data),
  "\n"
)


cat(
  "Isolates included in Figure 1:",
  nrow(plot_data),
  "\n"
)


cat(
  "Isolates excluded because year was missing:",
  sum(
    is.na(data[["Year of isolation"]])
  ),
  "\n"
)


cat(
  "Earliest year:",
  min(
    plot_data$Year,
    na.rm = TRUE
  ),
  "\n"
)


cat(
  "Latest year:",
  max(
    plot_data$Year,
    na.rm = TRUE
  ),
  "\n"
)


# ============================================================
# 11. Define ST order
# ============================================================

st_levels <- c(
  "ST1",
  "ST4",
  "ST8",
  "ST13",
  "ST14",
  "ST21",
  "ST148",
  "ST256"
)


plot_data$ST <- factor(
  plot_data$ST,
  levels = st_levels
)


# ============================================================
# 12. Check ST values
# ============================================================

if (
  any(
    is.na(plot_data$ST)
  )
) {
  
  stop(
    paste0(
      "One or more ST values are not included in the predefined ",
      "ST order.\nPlease check the ST column in ",
      "Supplementary_Table_1.xlsx."
    )
  )
  
}


# ============================================================
# 13. Define localization factor
# ============================================================

plot_data$Localization <- factor(
  plot_data$Localization,
  levels = c(
    "Predicted chromosome",
    "Plasmid-associated"
  )
)


# ============================================================
# 14. Controlled vertical stacking
# ============================================================
#
# When multiple isolates have the same year and ST,
# points are slightly offset vertically to avoid overlap.
#
# A single isolate remains centered on the ST line.
# ============================================================

plot_data <- plot_data %>%
  
  group_by(
    Year,
    ST
  ) %>%
  
  arrange(
    Sample,
    .by_group = TRUE
  ) %>%
  
  mutate(
    offset = if (
      n() == 1
    ) {
      0
    } else {
      seq(
        -0.20,
        0.20,
        length.out = n()
      )
    }
  ) %>%
  
  ungroup()


# ============================================================
# 15. Create Figure 1
# ============================================================

p1 <- ggplot(
  plot_data,
  aes(
    x = Year,
    y = as.numeric(ST) + offset,
    color = Localization,
    shape = Localization
  )
) +
  
  geom_point(
    size = 3.6,
    alpha = 0.95,
    stroke = 0.8
  ) +
  
  scale_color_manual(
    values = c(
      "Predicted chromosome" = "#800080",
      "Plasmid-associated" = "#FFA500"
    ),
    drop = FALSE
  ) +
  
  scale_shape_manual(
    values = c(
      "Predicted chromosome" = 16,
      "Plasmid-associated" = 17
    ),
    drop = FALSE
  ) +
  
  scale_y_continuous(
    breaks = seq_along(
      st_levels
    ),
    labels = st_levels,
    limits = c(
      0.5,
      length(st_levels) + 0.5
    ),
    expand = c(
      0,
      0
    )
  ) +
  
  scale_x_continuous(
    breaks = seq(
      1985,
      2025,
      by = 5
    ),
    limits = c(
      1980,
      2026
    ),
    expand = c(
      0,
      0
    )
  ) +
  
  labs(
    title = expression(
      paste(
        "Temporal distribution of ",
        italic("mcr-9.1"),
        "-positive ",
        italic("Cronobacter sakazakii"),
        " isolates (1982–2025)"
      )
    ),
    x = "Year of isolation",
    y = "Sequence type (ST)",
    color = "Genomic localization",
    shape = "Genomic localization"
  ) +
  
  theme_classic(
    base_size = 14
  ) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 15,
      hjust = 0.5
    ),
    
    axis.title = element_text(
      face = "bold",
      size = 14
    ),
    
    axis.text = element_text(
      size = 11,
      color = "black"
    ),
    
    legend.title = element_text(
      face = "bold",
      size = 12
    ),
    
    legend.text = element_text(
      size = 11
    ),
    
    legend.position = "right"
  )


# ============================================================
# 16. Display Figure 1
# ============================================================

print(p1)


# ============================================================
# 17. Define output files
# ============================================================

pdf_file <- file.path(
  output_dir,
  "Figure_1_temporal_distribution.pdf"
)


svg_file <- file.path(
  output_dir,
  "Figure_1_temporal_distribution.svg"
)


png_file <- file.path(
  output_dir,
  "Figure_1_temporal_distribution.png"
)


# ============================================================
# 18. Export PDF
# ============================================================

ggsave(
  filename = pdf_file,
  plot = p1,
  width = 10,
  height = 7,
  units = "in",
  device = cairo_pdf
)


# ============================================================
# 19. Export SVG
# ============================================================

ggsave(
  filename = svg_file,
  plot = p1,
  width = 10,
  height = 7,
  units = "in"
)


# ============================================================
# 20. Export high-resolution PNG
# ============================================================

ggsave(
  filename = png_file,
  plot = p1,
  width = 10,
  height = 7,
  units = "in",
  dpi = 600
)


# ============================================================
# 21. Verify output files
# ============================================================

output_files <- c(
  pdf_file,
  svg_file,
  png_file
)


cat("\n")
cat("============================================================\n")
cat("OUTPUT CHECK\n")
cat("============================================================\n")


for (f in output_files) {
  
  if (file.exists(f)) {
    
    cat(
      "Created:",
      f,
      "\n"
    )
    
  } else {
    
    warning(
      paste(
        "Output file was not created:",
        f
      )
    )
    
  }
  
}


# ============================================================
# 22. Final summary
# ============================================================

cat("\n")
cat("============================================================\n")
cat("FIGURE 1 COMPLETED\n")
cat("============================================================\n")


cat(
  "Input file:",
  metadata_file,
  "\n"
)


cat(
  "Localization column:",
  "MOB-suite Localization",
  "\n"
)


cat(
  "Isolates included:",
  nrow(plot_data),
  "\n"
)


cat(
  "Year range:",
  min(
    plot_data$Year,
    na.rm = TRUE
  ),
  "–",
  max(
    plot_data$Year,
    na.rm = TRUE
  ),
  "\n"
)


cat(
  "Output directory:",
  output_dir,
  "\n"
)


cat(
  "PDF:",
  pdf_file,
  "\n"
)


cat(
  "SVG:",
  svg_file,
  "\n"
)


cat(
  "PNG:",
  png_file,
  "\n"
)


cat(
  "============================================================\n"
)