# PISP - Physical-Informed Spatial Pattern filter

## Overview

GRACE_PISP_filter is a MATLAB toolbox designed for detecting and removing stripe noise from satellite gravity field data, particularly GRACE (Gravity Recovery and Climate Experiment) data. 

## Parameters

The `PAR` structure contains the following fields:

| Parameter | Type | Description | Default |
|-----------|------|-------------|---------|
| `Njump` | int | Jump parameter for processing | 20 |
| `M` | int | MSSA Sliding size | 60 |
| `K` | int | Number of components to keep | 20 |
| `corr` | double | Correlation threshold for coupled modes | 0.9 |
| `max_shift` | int | Maximum shift for mode coupling | 3 |
| `freq` | int | Sliding Window width | 8 |
| `count_tolerance` | int | Tolerance for extrema count matching | 2 |
| `position_tolerance` | double | Threshold for position similarity | 0.9 |
| `position_lr` | int | Left-right range for position matching | 1 |
| `FM` | int | Flag for iterative processing (1=on, 0=off) | 1 |

## Supported Data Formats

The toolbox supports common satellite gravity data grid resolutions:

- **1.0° × 1.0°**: 180 × 360 grid  (recommendation)
- **0.5° × 0.5°**: 360 × 720 grid
- **0.25° × 0.25°**: 720 × 1440 grid

## Applications

- **GRACE/GRACE-FO Data Processing**: Remove GRACE level-2 products stripe noise
- **Geophysical Data Analysis**: Maintain geophysical signal strength
- **Hydological Studies**: Improve signal-to-noise ratio in sub-basin scale regions

## Performance Tips

1. **Memory Management**: Process large datasets in chunks
2. **Parameter Tuning**: Adjust correlation thresholds for different noise levels
3. **Parallel Processing**: Use MATLAB's Parallel Computing Toolbox for large datasets
4. **Preprocessing**: Apply appropriate data conditioning before processing

## Citation


## Contact

- **Author**: [Xiaohui Wu]
- **Email**: [wuxiaohui@cug.edu.cn]
- **Institution**: [China University of GeoSciences, Wuhan]