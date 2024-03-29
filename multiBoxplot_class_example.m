% example multi box plot with significance lines
data_cols = [1, 6, 7, 8, 9, 2, 4, 6, 5, 5, 1, 7, 12;
             5, 6, 9, 4, 3, 3, 3, 1, 1, 1, 6, 5, -2;
             6, 6, 6, 6, 4, 4, 4, 3, 2, 8, 9, 1, 12];

% transposing it so we have three columns of data
data_cols = data_cols';

data_names = {'box1', 'box2', 'box3'};

% Define our multibox class object using data columns for each plot, and a list of names
multiBox = MultiBoxplot(data_cols, 'Test Plot', data_names);

% Or we can define a multibox object from a wide table, where each variable is a dataplot
%data_table = array2table(data_cols,'VariableNames',data_names);
%multiBox = MultiBoxplot(data_table, 'Test Plot');


% Y-Axis bits
% Specific Upper and Lower Y-axis Bounds
%multiBox.UpperLimit = 12;
%mutliBox.LowerLimit = -2;
% Or a multiplier for automatically defining Y-Axis bounds
% This is used by default with a value of 0.1, unless you specifically
% define the upper or lower bounds, which will overwrite it.
% but if you redefine the multiplier it will overwrite any customer upper
% or lower bounds you may have defined
%multiBox.AutoYLimitMarginMult = 0.1;
% You can also specify a specific Y-Label, but the default is set to
% 'Rating'
%multiBox.YLabel = 'Rating';

% You can also specify an angle for the X-Axis category markers
%multiBox.XLabelAngle = 35;
% A custom font size for the plot
%multiBox.FontSize = 16;
% The thickness of the median line can also be customized
%multiBox.MedianLineThickness = 3;
% We can define either an inbuilt colormap or one of our own ones, but if
% you define your own, make sure it has more colors than you have boxes
%multiBox.ColMap = winter;
% We also can define what the box face alpha value is, for a value between
% 0 and 1
%multiBox.BoxFaceAlpha = 0.5;

figure(1)

% Can also plot it as plot(multiBox) for the same effect. Will check if
% boxplot function exists and use it if it does, else it will use boxchart
multiBox.plot()
% You can also manually tell it to use the boxchart version by calling plot
% with true
%multiBox.plot(true)

% Add the significant differences
% For easily checking you have the right significance pairs, it's set up to
% use the same name labels as you provided for the plot itself
sig_vals = {'box1', 'box2';
            'box1', 'box3'};
% And the plotter will auto update positions to stack the lines as
% necessary. If you don't like how they visually look stacked up, then
% change the ordering of your list of pairs (i.e., list box1-3 before
% box1-2 and see how the plot changes)
multiBox.plotAutoSigDiff(sig_vals,0.3)

% You can also customize the specific plot tick starting points and the
% last item is the "low" point of the significance markers, where it dips
% down above each of the boxes. The high point is computed using the height
% variable, which is the other variable in the significant difference
% plotting
%   sig_vals = {'box1', 'box2', 12.1;
%               'box1', 'box3', 12.5};
% Here we provide our pairs, and the overall height of each set
%multiBox.plotSigDiff(sig_vals,0.3)

% Save plot as eps
set(gcf,'PaperPosition',[1 1 4 4.5])
print('-depsc','example_multibox_class.eps')

