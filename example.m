% GRACE_PISP_filter is a 
% MATLAB toolbox designed for detecting and removing stripe noise from 
% satellite gravity field data, particularly GRACE (Gravity Recovery and Climate Experiment)data.


% The `PAR` structure contains the following fields:
% 
% | Parameter | Type | Description | Default |
% |-----------|------|-------------|---------|
% | `Njump` int  | Jump parameter for processing | 20 |
% | `M`| int | MSSA Sliding size | 60 |
% | `K` int | Number of components to keep | 20 |
% | `corr` double | Correlation threshold for coupled modes | 0.9 |
% | `max_shift` | int | Maximum shift for mode coupling | 3 |
% | `freq`| int | Sliding Window width | 8 |
% | `count_tolerance` | int | Tolerance for extrema count matching | 2 |
% | `position_tolerance` | double | Threshold for position similarity | 0.9 |
% | `position_lr` | int | Left-right range for position matching | 1 |
% | `FM` | int | Flag for iterative processing (1=on, 0=off) | 1 |


% - **Author**: [Xiaohui Wu]
% - **Email**: [wuxiaohui@cug.edu.cn]
% - **Institution**: [China University of GeoSciences, Wuhan]
%% main exmpale
addpath('data','function')
load('data\testgrid.mat','testgrid')
lat=89.5:-1:-89.5;
PAR=struct('Njump',20,'M',60,'K',20,'corr',0.9,...
    'max_shift',3,'Nstep',6,'freq',8,...
    'lat',lat,'time_step',1,'idx',0,'max_counts',0, ...
    'count_tolerance',2,'position_tolerance',0.9,'position_lr',1,'FM',1);
[noise_new] = fuc_PISP(testgrid, 1, PAR);

result=testgrid-noise_new;
%% plot
subplot(1,2,1)
fuc_figure_global(testgrid,50,'no filter')
subplot(1,2,2)
fuc_figure_global(result,50,'LSSA')