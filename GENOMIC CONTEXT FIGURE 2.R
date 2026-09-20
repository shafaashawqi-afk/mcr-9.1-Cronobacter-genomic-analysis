# ============================================================
# GENOMIC CONTEXT FIGURE
# Diversity of mcr-9.1 genomic contexts across representative
# Cronobacter sakazakii sequence types
# ============================================================


# ------------------------------------------------------------
# 1. Load packages
# ------------------------------------------------------------

library(ggplot2)
library(gggenes)
library(dplyr)
library(readxl)
library(grid)


# ------------------------------------------------------------
# 2. Define repository paths
# ------------------------------------------------------------

coordinates_file <- "data/mcr9_architecture_coordinates.tsv"
metadata_file <- "data/Supplementary_Table_1.xlsx"

output_dir <- "figures"


# ------------------------------------------------------------
# 3. Check input files
# ------------------------------------------------------------

if (!file.exists(coordinates_file)) {
  stop(
    paste(
      "Coordinates file not found:",
      coordinates_file
    )
  )
}

if (!file.exists(metadata_file)) {
  stop(
    paste(
      "Metadata file not found:",
      metadata_file
    )
  )
}


# ------------------------------------------------------------
# 4. Create output directory
# ------------------------------------------------------------

if (!dir.exists(output_dir)) {
  dir.create(
    output_dir,
    recursive = TRUE
  )
}


# ------------------------------------------------------------
# 5. Read data
# ------------------------------------------------------------

coordinates <- read.delim(
  coordinates_file,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

metadata <- read_excel(
  metadata_file
)


# ------------------------------------------------------------
# 6. Check required columns
# ------------------------------------------------------------

required_coordinate_columns <- c(
  "sample",
  "start",
  "end",
  "feature",
  "strand"
)

required_metadata_columns <- c(
  "Sample",
  "ST"
)

missing_coordinate_columns <- setdiff(
  required_coordinate_columns,
  names(coordinates)
)

missing_metadata_columns <- setdiff(
  required_metadata_columns,
  names(metadata)
)

if (length(missing_coordinate_columns) > 0) {
  stop(
    paste(
      "Missing columns in coordinates file:",
      paste(missing_coordinate_columns, collapse = ", ")
    )
  )
}

if (length(missing_metadata_columns) > 0) {
  stop(
    paste(
      "Missing columns in Supplementary_Table_1.xlsx:",
      paste(missing_metadata_columns, collapse = ", ")
    )
  )
}


# ------------------------------------------------------------
# 7. Clean isolate names
# ------------------------------------------------------------

coordinates <- coordinates %>%
  mutate(
    sample = trimws(sample)
  )

metadata <- metadata %>%
  mutate(
    Sample = trimws(Sample)
  )


# ------------------------------------------------------------
# 8. Standardize known isolate-name difference
# ------------------------------------------------------------
#
# Coordinates file:
#     2001-10-06
#
# Supplementary Table 1:
#     10_6_2001
#
# Both refer to the same isolate.
# ------------------------------------------------------------

metadata <- metadata %>%
  mutate(
    Sample = case_when(
      Sample == "10_6_2001" ~ "2001-10-06",
      TRUE ~ Sample
    )
  )


# ------------------------------------------------------------
# 9. Basic data checks
# ------------------------------------------------------------

cat("\n============================================\n")
cat("DATA CHECK\n")
cat("============================================\n")

cat(
  "Number of coordinate records:",
  nrow(coordinates),
  "\n"
)

cat(
  "Number of metadata records:",
  nrow(metadata),
  "\n"
)

cat(
  "Number of isolates in coordinates:",
  length(unique(coordinates$sample)),
  "\n"
)


# ------------------------------------------------------------
# 10. Representative isolates
# ------------------------------------------------------------
#
# Selected to represent:
# - variation within ST1
# - variation within ST4
# - ST8
# - ST13
# - ST14
# - ST21
# - ST148
# - ST256
#
# bq was removed and replaced by CS291 (ST4)
# ------------------------------------------------------------

selected_samples <- c(
  
  # ST1 - multiple architectures
  "2001-10-06",
  "25MDFML003369-4A",
  "CFSAN135223",
  "MOD1_WNTSBCO4",
  
  # ST4 - two different architectures
  "CS6162",
  "CS291",
  
  # ST8
  "cro1489B1",
  
  # ST13
  "1011-04",
  
  # ST14
  "716",
  
  # ST21
  "CS-42",
  
  # ST148
  "CFSAN145334",
  
  # ST256
  "CRZK"
)


# ------------------------------------------------------------
# 11. Check selected isolates
# ------------------------------------------------------------

available_samples <- unique(
  coordinates$sample
)

missing_samples <- setdiff(
  selected_samples,
  available_samples
)

if (length(missing_samples) > 0) {
  
  cat("\n============================================\n")
  cat("ERROR: SELECTED ISOLATES NOT FOUND\n")
  cat("============================================\n")
  
  print(missing_samples)
  
  stop(
    "One or more selected isolates are missing from the coordinates file."
  )
}


# ------------------------------------------------------------
# 12. Select representative isolates
# ------------------------------------------------------------

plot_data <- coordinates %>%
  filter(
    sample %in% selected_samples
  )


# ------------------------------------------------------------
# 13. Add ST information
# ------------------------------------------------------------

plot_data <- plot_data %>%
  left_join(
    metadata %>%
      select(
        Sample,
        ST
      ),
    by = c(
      "sample" = "Sample"
    )
  )


# ------------------------------------------------------------
# 14. Check ST information
# ------------------------------------------------------------

missing_ST <- plot_data %>%
  distinct(
    sample,
    ST
  ) %>%
  filter(
    is.na(ST) |
      ST == ""
  )

if (nrow(missing_ST) > 0) {
  
  cat("\n============================================\n")
  cat("ERROR: MISSING ST INFORMATION\n")
  cat("============================================\n")
  
  print(missing_ST)
  
  stop(
    "One or more selected isolates do not have ST information."
  )
}


# ------------------------------------------------------------
# 15. Show selected isolates and ST
# ------------------------------------------------------------

cat("\n============================================\n")
cat("SELECTED REPRESENTATIVE ISOLATES\n")
cat("============================================\n")

selected_summary <- plot_data %>%
  distinct(
    sample,
    ST
  ) %>%
  arrange(
    ST,
    sample
  )

print(selected_summary)


# ------------------------------------------------------------
# 16. Calculate relative genomic position
# ------------------------------------------------------------
#
# For each isolate:
#
# mcr-9.1 start = 0
# upstream genes   = negative coordinates
# downstream genes = positive coordinates
# ------------------------------------------------------------

plot_data <- plot_data %>%
  group_by(sample) %>%
  mutate(
    
    mcr9_start = start[
      feature == "mcr-9.1"
    ][1],
    
    rel_start =
      start - mcr9_start,
    
    rel_end =
      end - mcr9_start
    
  ) %>%
  ungroup()


# ------------------------------------------------------------
# 17. Check mcr-9.1 normalization
# ------------------------------------------------------------

cat("\n============================================\n")
cat("mcr-9.1 RELATIVE POSITION CHECK\n")
cat("============================================\n")

print(
  plot_data %>%
    filter(
      feature == "mcr-9.1"
    ) %>%
    select(
      sample,
      feature,
      start,
      end,
      rel_start,
      rel_end
    )
)


# ------------------------------------------------------------
# 18. Create isolate + ST label
# ------------------------------------------------------------

plot_data <- plot_data %>%
  mutate(
    
    isolate_ST = paste0(
      sample,
      "   |   ",
      ST
    ),
    
    strand = as.numeric(
      strand
    )
    
  )


# ------------------------------------------------------------
# 19. Define ST order
# ------------------------------------------------------------

ST_order <- c(
  "ST1",
  "ST4",
  "ST8",
  "ST13",
  "ST14",
  "ST21",
  "ST148",
  "ST256"
)


# ------------------------------------------------------------
# 20. Order isolates within ST groups
# ------------------------------------------------------------

sample_info <- plot_data %>%
  distinct(
    sample,
    ST,
    isolate_ST
  ) %>%
  mutate(
    ST = factor(
      ST,
      levels = ST_order
    )
  ) %>%
  arrange(
    ST,
    sample
  )

sample_order <- sample_info %>%
  pull(
    isolate_ST
  )


# ------------------------------------------------------------
# 21. Set isolate order
# ------------------------------------------------------------

plot_data$isolate_ST <- factor(
  plot_data$isolate_ST,
  levels = rev(sample_order)
)


# ------------------------------------------------------------
# 22. Define genetic feature categories
# ------------------------------------------------------------

plot_data <- plot_data %>%
  mutate(
    
    feature_group = case_when(
      
      feature == "mcr-9.1" ~
        "mcr-9.1",
      
      feature == "WbuC" ~
        "WbuC",
      
      feature %in% c(
        "qseB",
        "qseC"
      ) ~
        "qseBC",
      
      feature %in% c(
        "IS26",
        "IS481",
        "IS903B",
        "IS6.5",
        "IS110",
        "IS3",
        "IS1",
        "IS5"
      ) ~
        "IS elements",
      
      TRUE ~
        "Other"
    )
  )


# ------------------------------------------------------------
# 23. Define publication colors
# ------------------------------------------------------------

feature_colors <- c(
  
  "mcr-9.1" =
    "#78B000",
  
  "WbuC" =
    "#C77CFF",
  
  "qseBC" =
    "#16A6B6",
  
  "IS elements" =
    "#F8766D",
  
  "Other" =
    "#BDBDBD"
)


# ------------------------------------------------------------
# 24. Calculate x-axis limits
# ------------------------------------------------------------

x_min <- floor(
  min(
    plot_data$rel_start,
    na.rm = TRUE
  ) / 1000
) * 1000

x_max <- ceiling(
  max(
    plot_data$rel_end,
    na.rm = TRUE
  ) / 1000
) * 1000


# ------------------------------------------------------------
# 25. Calculate ST group boundaries
# ------------------------------------------------------------
#
# Horizontal lines appear ONLY between ST groups.
# They do NOT appear between individual isolates.
# ------------------------------------------------------------

ordered_levels <- levels(
  plot_data$isolate_ST
)

ordered_ST <- plot_data %>%
  distinct(
    isolate_ST,
    ST
  ) %>%
  mutate(
    isolate_ST = factor(
      isolate_ST,
      levels = ordered_levels
    )
  ) %>%
  arrange(
    isolate_ST
  )

ST_vector <- ordered_ST$ST

if (length(ST_vector) > 1) {
  
  ST_boundaries <- which(
    ST_vector[
      -length(ST_vector)
    ] !=
      ST_vector[
        -1
      ]
  )
  
  horizontal_lines <-
    ST_boundaries + 0.5
  
} else {
  
  horizontal_lines <- numeric(0)
  
}


# ------------------------------------------------------------
# 26. Create final figure
# ------------------------------------------------------------

p <- ggplot(
  
  plot_data,
  
  aes(
    
    xmin =
      rel_start,
    
    xmax =
      rel_end,
    
    y =
      isolate_ST,
    
    fill =
      feature_group,
    
    forward =
      strand == 1
    
  )
  
) +
  
  # ----------------------------------------------------------
# ST group separators
# ----------------------------------------------------------

geom_hline(
  
  yintercept =
    horizontal_lines,
  
  colour =
    "grey70",
  
  linewidth =
    0.45
  
) +
  
  # ----------------------------------------------------------
# Gene arrows
# ----------------------------------------------------------

geom_gene_arrow(
  
  arrowhead_height =
    unit(
      3.2,
      "mm"
    ),
  
  arrow_body_height =
    unit(
      5.5,
      "mm"
    ),
  
  colour =
    "black",
  
  linewidth =
    0.35
  
) +
  
  # ----------------------------------------------------------
# Gene labels
# ----------------------------------------------------------

geom_gene_label(
  
  aes(
    label =
      feature
  ),
  
  size =
    2.8,
  
  colour =
    "black",
  
  grow =
    TRUE,
  
  min.size =
    0
  
) +
  
  # ----------------------------------------------------------
# mcr-9.1 reference position
# ----------------------------------------------------------

geom_vline(
  
  xintercept =
    0,
  
  linetype =
    "dashed",
  
  linewidth =
    0.45,
  
  colour =
    "grey35"
  
) +
  
  # ----------------------------------------------------------
# Feature colors
# ----------------------------------------------------------

scale_fill_manual(
  
  values =
    feature_colors,
  
  drop =
    FALSE
  
) +
  
  # ----------------------------------------------------------
# X-axis
# ----------------------------------------------------------

scale_x_continuous(
  
  limits =
    c(
      x_min,
      x_max
    ),
  
  breaks =
    seq(
      x_min,
      x_max,
      by = 2000
    ),
  
  expand =
    expansion(
      mult =
        c(
          0.02,
          0.02
        )
    )
  
) +
  
  # ----------------------------------------------------------
# Labels
# ----------------------------------------------------------

labs(
  
  x =
    "Relative position to mcr-9.1 (bp)",
  
  y =
    "Isolate | MLST",
  
  fill =
    "Genetic feature"
  
) +
  
  # ----------------------------------------------------------
# Theme
# ----------------------------------------------------------

theme_bw() +
  
  theme(
    
    panel.grid.major.y =
      element_blank(),
    
    panel.grid.minor =
      element_blank(),
    
    axis.text.y =
      element_text(
        size = 9,
        colour = "black"
      ),
    
    axis.text.x =
      element_text(
        size = 9,
        colour = "black"
      ),
    
    axis.title.x =
      element_text(
        size = 11,
        face = "bold"
      ),
    
    axis.title.y =
      element_text(
        size = 11,
        face = "bold"
      ),
    
    legend.title =
      element_text(
        size = 10,
        face = "bold"
      ),
    
    legend.text =
      element_text(
        size = 9
      ),
    
    legend.key.height =
      unit(
        0.55,
        "cm"
      ),
    
    plot.margin =
      margin(
        10,
        15,
        10,
        10
      ),
    
    panel.border =
      element_rect(
        colour =
          "black",
        
        fill =
          NA,
        
        linewidth =
          0.6
      )
    
  )


# ------------------------------------------------------------
# 27. Display figure
# ------------------------------------------------------------

print(p)


# ------------------------------------------------------------
# 28. Define output files
# ------------------------------------------------------------

pdf_file <-
  file.path(
    output_dir,
    "genomic_context_figure.pdf"
  )

svg_file <-
  file.path(
    output_dir,
    "genomic_context_figure.svg"
  )

png_file <-
  file.path(
    output_dir,
    "genomic_context_figure.png"
  )


# ------------------------------------------------------------
# 29. Export PDF
# ------------------------------------------------------------

ggsave(
  
  filename =
    pdf_file,
  
  plot =
    p,
  
  width =
    11,
  
  height =
    8,
  
  units =
    "in",
  
  device =
    cairo_pdf
  
)


# ------------------------------------------------------------
# 30. Export SVG
# ------------------------------------------------------------

ggsave(
  
  filename =
    svg_file,
  
  plot =
    p,
  
  width =
    11,
  
  height =
    8,
  
  units =
    "in"
  
)


# ------------------------------------------------------------
# 31. Export 600-dpi PNG
# ------------------------------------------------------------

ggsave(
  
  filename =
    png_file,
  
  plot =
    p,
  
  width =
    11,
  
  height =
    8,
  
  units =
    "in",
  
  dpi =
    600
  
)


# ------------------------------------------------------------
# 32. Verify exported files
# ------------------------------------------------------------

cat("\n============================================\n")
cat("EXPORT CHECK\n")
cat("============================================\n")

cat(
  "PDF exists: ",
  file.exists(pdf_file),
  "\n"
)

cat(
  "SVG exists: ",
  file.exists(svg_file),
  "\n"
)

cat(
  "PNG exists: ",
  file.exists(png_file),
  "\n"
)


# ------------------------------------------------------------
# 33. Final completion message
# ------------------------------------------------------------

cat("\n============================================\n")
cat("FIGURE GENERATION COMPLETED\n")
cat("============================================\n")

cat(
  "Number of isolates plotted:",
  length(unique(plot_data$sample)),
  "\n"
)

cat(
  "Number of ST groups:",
  length(unique(plot_data$ST)),
  "\n"
)

cat(
  "Files exported successfully.\n"
)

# ============================================================
# DONE
# ============================================================
