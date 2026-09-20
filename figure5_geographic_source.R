# ============================================================
# FIGURE 5
# Geographic distribution and source of isolation
# 38 mcr-9.1-positive Cronobacter sakazakii isolates
#
# Input:
#   data/Supplementary_Table_1.xlsx
#
# Output:
#   figures/Figure_2_geographic_source.pdf
#   figures/Figure_2_geographic_source.svg
#   figures/Figure_2_geographic_source.png
#
# Software:
#   R
#   dplyr
#   ggplot2
#   readxl
#   sf
#   rnaturalearth
#   rnaturalearthdata
#   patchwork
# ============================================================


# ============================================================
# 1. Load packages
# ============================================================

library(dplyr)
library(ggplot2)
library(readxl)
library(sf)
library(rnaturalearth)
library(rnaturalearthdata)
library(patchwork)


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
# 5. Check dataset size
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


cat("\n")
cat("============================================================\n")
cat("DATASET CHECK\n")
cat("============================================================\n")


cat(
  "Number of isolates:",
  nrow(data),
  "\n"
)


# ============================================================
# 6. Check required columns
# ============================================================

required_columns <- c(
  "Country",
  "Source"
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
# 7. Clean country names for plotting
# ============================================================
#
# Country names are cleaned only for visualization.
# The original Country column in Supplementary Table 1
# is not modified.
# ============================================================

plot_data <- data %>%
  
  mutate(
    Country_plot = trimws(
      as.character(Country)
    )
  ) %>%
  
  mutate(
    Country_plot = sub(
      ":.*$",
      "",
      Country_plot
    )
  ) %>%
  
  mutate(
    Country_plot = trimws(
      Country_plot
    )
  ) %>%
  
  mutate(
    Country_plot = ifelse(
      Country_plot == "Not Provided",
      NA_character_,
      Country_plot
    )
  )


# ------------------------------------------------------------
# Standardize USA for Natural Earth
# ------------------------------------------------------------

plot_data$Country_plot[
  plot_data$Country_plot == "USA"
] <- "United States"


# ============================================================
# 8. Count isolates by country
# ============================================================

country_count <- plot_data %>%
  
  filter(
    !is.na(Country_plot)
  ) %>%
  
  count(
    Country_plot,
    name = "Number_of_isolates"
  ) %>%
  
  arrange(
    desc(Number_of_isolates),
    Country_plot
  )


cat("\n")
cat("============================================================\n")
cat("ISOLATES BY COUNTRY\n")
cat("============================================================\n")


print(
  country_count
)


# ============================================================
# 9. Count isolates by source
# ============================================================

source_count <- data %>%
  
  mutate(
    Source_plot = trimws(
      as.character(Source)
    )
  ) %>%
  
  filter(
    !is.na(Source_plot),
    Source_plot != "",
    Source_plot != "Not Provided"
  ) %>%
  
  count(
    Source_plot,
    name = "Number_of_isolates"
  ) %>%
  
  arrange(
    Number_of_isolates,
    Source_plot
  )


cat("\n")
cat("============================================================\n")
cat("ISOLATES BY SOURCE\n")
cat("============================================================\n")


print(
  source_count
)


# ============================================================
# 10. World map
# ============================================================

world <- ne_countries(
  scale = "medium",
  returnclass = "sf"
)


# ============================================================
# 11. Join country counts to world map
# ============================================================

map_data <- world %>%
  
  left_join(
    country_count,
    by = c(
      "name" = "Country_plot"
    )
  )


# ============================================================
# 12. Geographic distribution map
# ============================================================

p_map <- ggplot(
  map_data
) +
  
  geom_sf(
    aes(
      fill = Number_of_isolates
    ),
    color = "grey70",
    linewidth = 0.2
  ) +
  
  scale_fill_gradient(
    low = "white",
    high = "black",
    na.value = "grey90",
    name = "Number of isolates"
  ) +
  
  theme_void() +
  
  labs(
    title = "A. Geographic distribution"
  ) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14
    ),
    
    legend.title = element_text(
      size = 10
    ),
    
    legend.text = element_text(
      size = 9
    )
  )


# ============================================================
# 13. Source-of-isolation plot
# ============================================================

p_source <- ggplot(
  source_count,
  aes(
    x = Number_of_isolates,
    y = reorder(
      Source_plot,
      Number_of_isolates
    )
  )
) +
  
  geom_col() +
  
  theme_classic() +
  
  labs(
    title = "B. Source of isolation",
    x = "Number of isolates",
    y = NULL
  ) +
  
  theme(
    plot.title = element_text(
      face = "bold",
      size = 14
    ),
    
    axis.text.y = element_text(
      size = 9
    )
  )


# ============================================================
# 14. Combine panels
# ============================================================

final_figure <- p_map +
  p_source +
  
  plot_layout(
    widths = c(
      1.4,
      1
    )
  )


# ============================================================
# 15. Display final figure
# ============================================================

print(
  final_figure
)


# ============================================================
# 16. Define output files
# ============================================================

pdf_file <- file.path(
  output_dir,
  "Figure_2_geographic_source.pdf"
)


svg_file <- file.path(
  output_dir,
  "Figure_2_geographic_source.svg"
)


png_file <- file.path(
  output_dir,
  "Figure_2_geographic_source.png"
)


# ============================================================
# 17. Export PDF
# ============================================================

ggsave(
  filename = pdf_file,
  plot = final_figure,
  width = 12,
  height = 6.5,
  units = "in",
  device = cairo_pdf
)


# ============================================================
# 18. Export SVG
# ============================================================

ggsave(
  filename = svg_file,
  plot = final_figure,
  width = 12,
  height = 6.5,
  units = "in"
)


# ============================================================
# 19. Export high-resolution PNG
# ============================================================

ggsave(
  filename = png_file,
  plot = final_figure,
  width = 12,
  height = 6.5,
  units = "in",
  dpi = 600
)


# ============================================================
# 20. Save country counts
# ============================================================

write.csv(
  country_count,
  file.path(
    output_dir,
    "Figure_2_country_counts.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 21. Save source counts
# ============================================================

write.csv(
  source_count,
  file.path(
    output_dir,
    "Figure_2_source_counts.csv"
  ),
  row.names = FALSE
)


# ============================================================
# 22. Verify output files
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
# 23. Final summary
# ============================================================

cat("\n")
cat("============================================================\n")
cat("FIGURE 2 COMPLETED\n")
cat("============================================================\n")


cat(
  "Input file:",
  metadata_file,
  "\n"
)


cat(
  "Total isolates:",
  nrow(data),
  "\n"
)


cat(
  "Countries represented:",
  nrow(country_count),
  "\n"
)


cat(
  "Source categories represented:",
  nrow(source_count),
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