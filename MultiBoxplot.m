classdef MultiBoxplot
   % Class for plotting sets of boxplots, setting colors, and drawing the
   % significant difference lines automatically when provided a list of
   % significant pairs.
   % Rhian C. Preston, March 2024
   properties
      BoxDataTable
      Title
      UpperLimit {mustBeNumeric}
      LowerLimit {mustBeNumeric}
      AutoYLimitMarginMult {mustBeNumeric} = 0.1
      XLabelAngle {mustBeNumeric} = 35
      MedianLineThickness {mustBePositive,mustBeNumeric,mustBeNonzero} = 3
      FontSize {mustBePositive,mustBeNumeric,mustBeNonzero} = 16
      ColMap = winter
      YLabel = 'Rating'
   end
   properties (Dependent)
      NumBoxes
      Means
      StdErrs
   end
   methods
       % Define a multiboxplot from an array, where each column is the data
       % for a box plot
       function obj = MultiBoxplot(data_cols, box_names, plot_title)
           obj.BoxDataTable = array2table(data_cols,'VariableNames',box_names);
           obj.Title = plot_title;
           obj = obj.updateAutoLimits();
       end
       % Define a multiboxplot from a table
       function obj = MultiBoxplotT(table, plot_title)
           obj.BoxDataTable = table;
           obj.Title = plot_title;
           obj = obj.updateAutoLimits();
       end
       function obj = addBox(obj, box_vector, box_name)
           obj.BoxDataTable = addVars(obj.BoxDataTable, box_vector, 'NewVariableNames', {box_name});
       end
       function obj = set.AutoYLimitMarginMult(obj,val)
           obj.AutoYLimitMarginMult = val;
           obj = obj.updateAutoLimits();
       end
       function obj = updateAutoLimits(obj)
           data_cols = table2array(obj.BoxDataTable);
           max_val = max(data_cols,[],"all");
           min_val = min(data_cols,[],"all");
           obj.UpperLimit = max_val + obj.AutoYLimitMarginMult*abs(max_val-min_val);
           obj.LowerLimit = min_val - obj.AutoYLimitMarginMult*abs(max_val-min_val);
       end
       function plot(obj)
           longTable = stack(obj.BoxDataTable, ...
               obj.BoxDataTable.Properties.VariableNames, ...
               'NewDataVariableName','BoxData', ...
               'IndexVariableName', 'DataGroups');
           %boxchart(categorical(longTable.DataGroups),longTable.BoxData, 'WhiskerLineStyle','-' );
           boxplot(longTable.BoxData, categorical(longTable.DataGroups),'color','k','Symbol','o');
           %label only goes on furthest left boxplot of each row%
            ylabel(obj.YLabel);
            ylim([obj.LowerLimit,obj.UpperLimit]);

            xtickangle(obj.XLabelAngle);

           % make whisker lines solid
            set(findobj(gcf,'LineStyle','--'),'LineStyle','-')
            % make median line thicc boi
            set(findobj(gca,'tag','Median'),'LineWidth',obj.MedianLineThickness);

            % fill the boxplots
            m = findobj(gca,'Tag','Box');

            % Get a number of colors equally spaced from the color map,
            % using interpolation in case the colormap is disorganized
            cols = interp1(1:length(obj.ColMap), obj.ColMap, linspace(1, length(obj.ColMap), length(m)));
            %cols = obj.ColMap(round(linspace(1, length(obj.ColMap), length(m))), :);

            for j=1:length(m)
                patch(get(m(j),'XData'),get(m(j),'YData'),cols(j,:),'FaceAlpha',.5);
            end

           hold on
           plot(obj.Means, '*k');

           title(obj.Title);
           set(gcf,'color','w');
           set(findall(gcf,'-property','FontSize'),'FontSize',obj.FontSize)
           hold off
       end
       % Draw the significant difference lines on the plots, when you
       % provide sig diffs that has the labels for the differences, and the
       % low tick starting height, as well as the overall height of the
       % vertical lines on the sig diff markers
       % Example sig_diffs
       %   sig_diffs = {'box1', 'box2', 12.1;
       %                'box1', 'box3', 12.5};
       % using a tick_height of 0.3 would leave ~0.1 space between the top
       % of the box1-box2 marker and the box1-box 3 marker.
       function plotSigDiff(obj, sig_diffs, tick_height)
           x_labels = xticklabels;
           for i=1:length(sig_diffs(:,1))
                % Plot sig line
                box1 = find(contains(x_labels,sig_diffs(i,1)));
                box2 = find(contains(x_labels,sig_diffs(i,2)));
                y_low = cell2mat(sig_diffs(i,3));
                y_low = y_low + tick_height/3;
                %[box1, box2, y_low] = sig_diffs(i,:);
                y_high = y_low + tick_height;
                % Little vertical line above first box
                line([box1,box1],[y_low,y_high],'Color','k')
                % little vertical line above second box
                line([box2,box2],[y_low,y_high],'Color','k')
                % horizontal line connecting the two boxes
                line([box1,box2],[y_high,y_high],'Color','k')
            end
       end% Draw the significant difference lines on the plots, when you
       % provide sig diffs that has the labels for the differences
       % Example sig_diffs
       %   sig_diffs = {'box1', 'box2';
       %                'box1', 'box3'};
       function plotAutoSigDiff(obj, sig_diffs, tick_height)
           x_labels = xticklabels;
           max_values = max(table2array(obj.BoxDataTable));
           for i=1:length(sig_diffs(:,1))
                % Plot sig line
                box1 = find(contains(x_labels,sig_diffs(i,1)));
                box2 = find(contains(x_labels,sig_diffs(i,2)));
                y_low= max([max_values(box1),max_values(box2)]);
                y_low = y_low + tick_height/3;
                y_high = y_low + tick_height;
                max_values(box1) = y_high;
                max_values(box2) = y_high;
                % Little vertical line above first box
                line([box1,box1],[y_low,y_high],'Color','k')
                % little vertical line above second box
                line([box2,box2],[y_low,y_high],'Color','k')
                % horizontal line connecting the two boxes
                line([box1,box2],[y_high,y_high],'Color','k')
            end
       end
       function val = get.NumBoxes(obj)
         val = width(obj.BoxDataTable);
       end
       function val = get.Means(obj)
         val =  mean(table2array(obj.BoxDataTable),1);
       end
       function val = get.StdErrs(obj)
         val =  std(table2array(obj.BoxDataTable),1);
       end
   end
end