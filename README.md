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

The setting with non-rectangular blocks (e.g. `allignment="vertical"`, `reps=4`, `treatments=21`) can be a bit tricky to analyse and to explain the choice of this randomization.
In such case, the "non-rectangular blocks" are not blocks, but "constraints" to ensure that you don't have the same treatment in the same part of the field or greenhouse.
This is a bit more robust than only randomizing over columns, but you cannot model block effect in a usual way.
All in all, if you can model rectangular blocks, do it this way. 
          

# Design evaluation 

## Rectangular blocks

Assume that rows are your long side (Y), and columns are your short side (X), e.g. `alignment="vertical"`, `reps=4`, `treatments=20`.

If you choose your blocks to be rectangular, you can model a block effect, making the design closer to a row–column design but with fewer blocks, which is generally preferred. 
In this example, `alignment="vertical"`, `X=4`, and `Y=20`.

Here, the basic model can be written as

$$
y_{ij} = \mu + a_{t(i,j)} + c_i + b_k + e_{ij}
$$

where $y_{ij}$ is the response for the plot located in the $i$-th column and $j$-th row, $\mu$ is the overall mean (intercept), $a_{t(i,j)}$ is the effect of the treatment assigned to position $(i,j)$, $c_i$ is the effect of the $i$-th column, $b_k$ is the effect of the $k$-th block, and $e_{ij}$ is the residual plot error.

The total number of blocks $K$, indexed by $k$, is smaller than the number of rows $R$, so $K < R$. In this design, each column represents a complete replicate of all treatments, and each rectangular block also contains a complete replicate.

<img width="517" height="320" alt="grafik" src="https://github.com/user-attachments/assets/14749c87-424f-47c7-8262-f891fb740704" />

## Non-rectangular blocks

If the setting with non-rectangular blocks is chosen (e.g., `treatments = 21`, `reps = 4`), you cannot model a block effect.

In this case, you would fit a model with column effect as a factor and optionally include a row effect as a continuous trend. The model can be written as

$$
y_{ij} = \mu + a_t + c_i + \beta * j + e_{ij}
$$

where $y_{ij}$ is the response for the plot in column $i$ and row $j$, $\mu$ is the overall mean (intercept), $a_t$ is the effect of treatment $t$ assigned to that plot, $c_i$ is the effect of column $i$, $\beta * j$ represents a numeric gradient effect over rows, and $e_{ij}$ is the residual error.

This design evaluation is equivalent to saying that replicates are placed over columns, but not over rows. The "blocks" over rows serve only to ensure that the same treatment does not appear repeatedly in the same part of the field or greenhouse. In theory, this makes the design more robust than randomizing only over columns.

A significant gradient effect $\beta$ over rows would indicate a linear trend across rows. If the row effect is not significant, it can be removed from the model.

<img width="517" height="320" alt="grafik" src="https://github.com/user-attachments/assets/f259067b-013f-4a41-88a4-b68f3a32fcbb" />


