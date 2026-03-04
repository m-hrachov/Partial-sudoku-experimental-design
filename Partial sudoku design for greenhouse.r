
###################################################################################################
## WARNING: the code below allows rectangualr blocks and non-rectangular "blocks" that are actually only constraints.
##          It is highly recommended to choose the setting with rectangular blocks, because
##          it is easier to analyse and to interpret. 
##          The setting with "non-rectangular blocks" (e.g. allignment="vertical", reps=4, treatments=21)
##          can be a bit tricky to analyse and to explain the choice of this randomization.
##          In such case, the "non-rectangular blocks" are not blocks, but "constraints" to ensure that 
##          you don't have the same treatment in the same part of the field/greenhouse.
##          This is a bit more robust than only randomizing over columns, but you cannot model block effect in a usual way.
##          All in all, if you can model rectangular blocks, do it this way. 
##          

## Design evaluation: Assume that rows are your long side (Y), and columns are your short side (X), e.g. allignment="vertical", reps=4, treatments=20.
##                    
##                    If you chose your blocks to be rectangular, then you can model block effect, and the design is more similar to a row-column design, 
##                    but with fewer blocks - this is much more preferred.
##                    Taking this example, alignment "vertical", X=4, Y=20.
##                    In this case, the basic model would be y_ij = mu + a_t(i,j) + c_i + b_k + e_ij, where y_ij is the plot value in i-th column and j-th row, 
##                    mu is the overall mean (intercept), a_t(i,j) is the treatment effect assigned to the i-j-th position, c_i is the effect of the column i, 
##                    b_k is the effect of block k, and e_ij is the residual error.
##                    Here you can see that number of blocks indexed with k is smaller than number of rows. 
##                    This design than has a complete replicate in each column, and each "block" is also a complete replicate.
##
##                    If the setting with "non-rectangular blocks" is chosen (e.g., treatments = 21, reps = 4), you cannot model block effect.
##                    In this case you would fit a model with column effect as factor. You can add a row effect as a continuous trend.
##                    This means: y_ij = mu + a_t(i,j) + c_i + beta*j + e_ij, where y_ij is the response for the i-j-th plot, mu is the overall mean (intercept), 
##                    a_t(i,j) is the treatment assigned to this plot, c_i is the effect of column i, beta*j is the numeric gradient effect, and e_ij is the residual error.
##                    This design evaluation is equivalent to saying: I have place replicates over columns, but I did not place replicates over rows.
##                    The "blocks" over rows play solely a role of ensuring that you do not have the same treatment in the same part of the field/greenhouse.
##                    This should, in theory, make this design more robust than only randomizing over columns.
##                    A significant gradient effect beta over rows would say: we have some linear trend over rows 
##                    If the effect over rows is not significant, drop it.
## 
## Title:       Partial sudoku plot randomization
##
## Date:        15.05.2025
##
## Creator:     Maksym Hrachov (maksym.hrachov@uni-hohenheim.de)
##
## Description: Partial sudoku randomization function to create experimental design for a
##              greenhouse table or a field. This design is in-between of RCBD and row-column, so that
##              every column and every 'block' contain a complete replicate. 
##              This design can help to account for gradients in both X and Y directions.
##
## License:     Creative Commons Attribution-NonCommercial 4.0 International
##              (CC BY-NC 4.0)
##              https://creativecommons.org/licenses/by-nc/4.0
## Copyright (c) 2025  Maksym Hrachov


# Scroll down to see an example

############################
######## Function ##########
############################
partial_sudoku <- function(treatments, reps, columns, seed){
  library(dplyr)
  library(tidyr)
  library(ggplot2)
  
  set.seed(seed)
  
  prep <- expand_grid(
    X = 1:columns,
    Y = 1:treatments
  ) %>%
    arrange(Y) %>%
    mutate(
      Observation = row_number(),
      Block       = rep(1:reps, each = treatments),
      Value       = NA_integer_
    )
  
  assigned <- prep
  b = 1
  for (b in 1:reps) {
    block_df <- prep %>% filter(Block == b) %>%
      mutate(Value = sample(1:treatments))
    
    check_assignment <- rows_update(assigned, block_df %>% select(Observation, Value), by = ("Observation")) %>% 
      group_by(X) %>% 
      mutate(flag = duplicated(Value)) %>% 
      filter(Block %in% 1:b) %>% 
      ungroup
    
    assigned <- rows_update(assigned, block_df %>% select(Observation, Value), by = ("Observation"))
    
    if(sum(check_assignment$flag) != 0 ){
      iter <- 0
      five_iter_save <- 0
      repeat {
        iter <- iter + 1
        subset_reshuffle <- check_assignment %>% filter(flag == T) %>% 
          mutate(Value = sample(Value)) %>% 
          select(-flag)
        
        assigned <- rows_update(assigned, subset_reshuffle %>% select(Observation, Value), by = ("Observation"))
        
        check_assignment <- rows_update(assigned, subset_reshuffle %>% select(Observation, Value), by = ("Observation")) %>% 
          group_by(X) %>% 
          mutate(flag = duplicated(Value)) %>% 
          filter(Block %in% 1:b)%>% 
          ungroup
        
        if(sum(check_assignment$flag) == five_iter_save | sum(check_assignment$flag) == 1){
          block_df <- prep %>% filter(Block == b) %>%
            mutate(Value = sample(1:treatments))
          
          check_assignment <- rows_update(assigned, block_df %>% select(Observation, Value), by = ("Observation")) %>% 
            group_by(X) %>% 
            mutate(flag = duplicated(Value)) %>% 
            filter(Block %in% 1:b) %>% 
            ungroup
          
          assigned <- rows_update(assigned, block_df %>% select(Observation, Value), by = ("Observation"))
        }
        
        # print(sum(check_assignment$flag))
        
        if(iter %% 5) five_iter_save <- sum(check_assignment$flag)
        
        if (!any(check_assignment$flag)) break
      }
    }
    print(paste("Block", b, "has been created."))
  }  
  
  # sanity check
  sanity_check <- assigned %>% group_by(Block) %>% 
    mutate(block_check = duplicated(Value)) %>% 
    ungroup %>% 
    group_by(X) %>% 
    mutate(X_check = duplicated(Value)) %>% 
    ungroup()
  
  if( sum(sanity_check$block_check) != 0 | sum(sanity_check$X_check) != 0 ){
    stop("There are duplicates... Contact Maksym Hrachov to check the code.")
  }
  return(assigned)
}

###################
####  Example  ####
###################

library(dplyr)
library(tidyr)
library(ggplot2)

# number of unique treatment levels in a replicate: e.g. varieties, dose levels, 
# or number of treatment combinations: 5 levels of trt_1 * 3 levels of trt_2 = 15
treatments <- 20 
# number of replicates; it can support designs of ~40 treatments with 10 reps, but it will take a minute or two
reps <- 4
# design assumes number_of_rows > number of columns, and n_columns = n_reps. 
columns <- reps
# to change alignment (from "vertical" - default, to "horizontal", please specify)
alignment <- "vertical"
# change the random seed to get another design with the same dimensions
seed <- 42

# run function
assigned <- partial_sudoku(treatments, reps, columns, seed)

# visualize the output
if(alignment == "vertical"){
  ggplot(assigned, aes(x = X, y = Y, fill = factor(Block))) +
    geom_tile(color = "grey80") +
    geom_text(aes(label = Value), size = 4) +
    
    scale_x_continuous(
      breaks = 1:columns,
      expand = c(0, 0)
    ) +
    scale_y_reverse(
      breaks = 1:treatments,
      expand = c(0, 0)
    ) +
    
    scale_fill_brewer(palette = "Set3") +
    coord_fixed() +
    labs(
      x     = "X",
      y     = "Y",
      fill  = "Block",
      title = "Design grid"
    ) +
    
    theme_minimal(base_size = 14) +
    theme(
      panel.grid.major   = element_blank(),
      panel.grid.minor   = element_blank(),
      plot.title         = element_text(hjust = 0.5)  # center the title
    )
} else {
  ggplot(assigned, aes(x = Y, y = -X, fill = factor(Block))) +
    geom_tile(color = "grey80") +
    geom_text(aes(label = Value), size = 4) +
    
    scale_x_continuous(
      breaks = 1:treatments,
      expand = c(0, 0)
    ) +
    scale_y_reverse(
      breaks = - (1:columns),      # data positions at −1,−2,…,−columns
      labels = 1:columns,          # but label them “1, 2, …, columns”
      expand = c(0, 0)
    ) +
    
    scale_fill_brewer(palette = "Set3") +
    coord_fixed() +
    labs(
      x     = "X",
      y     = "Y",
      fill  = "Block",
      title = "Design grid"
    ) +
    
    theme_minimal(base_size = 14) +
    theme(
      panel.grid.major   = element_blank(),
      panel.grid.minor   = element_blank(),
      plot.title         = element_text(hjust = 0.5) 
    )
}




