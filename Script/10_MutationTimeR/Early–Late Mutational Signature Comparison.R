# Adapted from Torrens et al. (Nat Genet 2025)
# Modified for this cohort

assign <- read.table('/Users/liconghui/Desktop/pan_cancer_EC/BigCohort/genome/WGS/Signature/SigAssignment/Assignment_Solution_Activities.txt',sep='\t',header = T)

SBS_earlylate <- assign %>% separate(Samples,c("donor_id","time"),sep='_(?=[^_]+$)',remove = T) %>%
  mutate(across(3:last_col(), ~ .x / rowSums(across(3:last_col()))
  ))


# Calculate differences between early and late
SBS_early <- SBS_earlylate %>% filter(time == "early")
SBS_late <- SBS_earlylate %>% filter(time == "late")

#### Plot activities ####

SBS_dif <- SBS_early[, -c(1, 2)] - SBS_late[, -c(1, 2)]
SBS_dif <- SBS_dif %>%
  mutate_all(~ case_when(. > 0.06 ~ "early", . < -0.06 ~ "late", TRUE ~ "unclear")) %>%
  mutate_all(~ factor(., levels = c("unclear", "early", "late")))

# Set row and column names
rownames(SBS_dif) <- SBS_early$donor_id
colnames(SBS_dif) <- paste0(colnames(SBS_dif), "_time")
SBS_dif <- SBS_dif %>% tibble::rownames_to_column("donor_id")

# Merge differences with original data
SBS_plot <- SBS_earlylate %>% left_join(SBS_dif, by = "donor_id")

plot_timing <- function(SBS_plot, signatures, title = NA, print = TRUE, save = TRUE) {
  # Perform Wilcoxon paired test for each signature
  output_stats <- NULL
  for (sig in signatures) {
    
    tmp <- SBS_plot %>%
      select(donor_id, time, !!sym(sig)) %>%
      pivot_wider(names_from = time, values_from = !!sym(sig)) %>%
      filter(!is.na(early) & !is.na(late))
    
    wilcox <- wilcox.test(tmp$early, tmp$late, paired = TRUE)
    
    stats <- data.frame(signature = sig, p_val = wilcox$p.value)
    output_stats <- rbind(output_stats, stats)
  }
  
  output_stats <- output_stats %>% mutate(p_adj = p.adjust(p_val, method = "BH"))
  
  for (sig in signatures) {
    # filter cases positive for early and/or late activities
    SBS_plot.pos_bysample <- SBS_plot %>%
      select("donor_id", "time", sig) %>%
      spread(time, sig) %>%
      filter(!(early == 0 & late == 0)) 
    
    SBS_plot.pos <- SBS_plot.pos_bysample %>%
      gather(time, sig, -donor_id)
    
    qval <- output_stats %>%
      filter(signature == sig) %>%
      pull(p_adj)
    
    plot_title <- ifelse(is.na(title),
                         paste0(sig, " (", nrow(SBS_plot.pos_bysample), "/", nrow(SBS_plot) / 2, ")"),
                         paste0(sig, " ", title, " (", nrow(SBS_plot.pos_bysample), "/", nrow(SBS_plot) / 2, ")")
    )
    
    p <- SBS_plot %>%
      arrange(get(paste0(sig, "_time"))) %>%
      mutate(donor_id = factor(donor_id, levels = unique(donor_id))) %>%
      ggplot(aes(
        x = time, y = get(sig)
      )) +
      geom_line(aes(group = donor_id, color = factor(get(paste0(sig, "_time")))), alpha = 0.6) +
      geom_boxplot(
        data = SBS_plot.pos,
        aes(x = time, y = sig, fill = time),
        width = .2, color = "#404040",
        alpha = 0.25, linewidth = .2, staplewidth = .2, outlier.shape = NA
      ) +
      geom_point(aes(group = donor_id), size = .5, alpha = 0.25) +
      scale_x_discrete(expand = c(.1, .1)) +
      scale_y_continuous(limits = c(0, 1)) +
      scale_color_manual(values = c("early" = "#6495ED", "late" = "#E97132", "unclear" = "#7D7D7D")) +
      scale_fill_manual(values = c("early" = "#6495ED", "late" = "#E97132")) +
      labs(
        title = plot_title,
        subtitle = paste0("q-val = ", signif(qval, 4)),
        x = "", y = "relative activity", color = ""
      ) +
      theme_minimal() +
      theme(
        legend.position = "none",
        plot.title = element_text(face = "bold", size = 12, hjust = 0.5),
        plot.subtitle = element_text(size = 10, hjust = 0.5),
        axis.title = element_text(size = 12),
        axis.text = element_text(size = 12),
        axis.line = element_line(size = .3,color = "#404040"),
        axis.ticks = element_line(size = .3,color = "#404040"),
        panel.grid = element_blank()
      )
    
    if (print == TRUE) {
      print(p)
    }
    
    if (save == TRUE) {
      if (is.na(title)) {
        ggsave(paste0("output/ExtendedDataFigure_4_", sig, "_", Sys.Date(), ".pdf"), device = "pdf", width = 3.25, height = 3.5, dpi = 700)
      } else {
        ggsave(paste0("output/ExtendedDataFigure_4_", sig, "_", title, "_", Sys.Date(), ".pdf"), device = "pdf", width = 3.25, height = 3.5, dpi = 700)
      }
    }
  }
}

# Plot for the whole dataset
signatures <- names(SBS_earlylate[-c(1, 2)])
plot_timing(SBS_plot, signatures, print = T, save = T)