# Partial sudoku plot randomization

**Description**: Partial sudoku randomization function to create experimental design for a greenhouse table or a field. This design is in-between of RCBD and row-column, so that
              every column and every 'block' contain a complete replicate. 
              This design can help to account for gradients in both X and Y directions.

**Creator**: m-hrachov

 **License**:     Creative Commons Attribution-NonCommercial 4.0 International
              (CC BY-NC 4.0)
              https://creativecommons.org/licenses/by-nc/4.0
 Copyright (c) 2025  Maksym Hrachov

# Warning 

This code implementation allows rectangualr and non-rectangular blocks.
It is highly recommended to choose the setting with rectangular blocks, because it is easier to analyse and to interpret. 

The setting with non-rectangular blocks (e.g. allignment="vertical", reps=4, treatments=21) can be a bit tricky to analyse and to explain the choice of this randomization.
In such case, the "non-rectangular blocks" are not blocks, but "constraints" to ensure that you don't have the same treatment in the same part of the field/greenhouse.
This is a bit more robust than only randomizing over columns, but you cannot model block effect in a usual way.
All in all, if you can model rectangular blocks, do it this way. 
          

# Design evaluation 

Assume that rows are your long side (Y), and columns are your short side (X), e.g. `allignment="vertical"`, `reps=4`, `treatments=20`.
                    
If you chose your blocks to be rectangular, then you can model block effect, and the design is more similar to a row-column design, 
but with fewer blocks - this is much more preferred.
Taking this example, `alignment="vertical"`, `X=4`, `Y=20`.
In this case, 

$$y_{ik} = \mu + c_i + b_k + e_{ik}$$ 

where $y_{ij}$ is the response for the $ij$-th plot, $c_i$ is the effect of column $i$, 
$b_k$ is the effect of block $k$, and $e_{ik}$ is the residual plot error.
Here the total number of blocks $K$ indexed with $k$ is smaller than number of rows $R$, so that $K < R$. 
This design than has a complete replicate in each column, and each "block" is also a complete replicate.

If the setting with non-rectangular blocks is chosen (e.g., `treatments = 21`, `reps = 3`), you cannot model block effect.
In this case you would fit a model with column effect as factor. You can add a row effect as a continuous trend.
This means: 

$$y_{ij} = mu + c_i + r_j + e_{ij}$$ 

where $y_{ij}$ is the response for the $ij$-th plot, $c_i$ is the effect of column $i$, 
$r_j$ is the effect of row $j$, and $e_{ij}$ is the residual error.
This design evaluation is equivalent to saying: I have place replicates over columns, but I did not place replicates over rows.
The "blocks" over rows play solely a role of ensuring that you do not have the same treatment in the same part of the field/greenhouse.
This should, in theory, make this design more robust than only randomizing over columns.
A significant effect gradient effect $r_j$ over rows would say: we have some trend over rows, and (many) treatments are
affected about equally by this trend. Note that with a small number of columns, you will have less certainty in this effect's estimate.
If the effect over rows is not significant, drop it.

<img width="517" height="320" alt="grafik" src="https://github.com/user-attachments/assets/14749c87-424f-47c7-8262-f891fb740704" />

