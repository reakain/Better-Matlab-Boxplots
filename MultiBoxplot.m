classdef MultiBoxplot
   % Class for plotting sets of boxplots, setting colors, and drawing the
   % significant difference lines automatically when provided a list of
   % significant pairs.
   % Rhian C. Preston, March 2024
   properties
      BoxDataTable
      Title {mustBeText} = ''
      UpperLimit {mustBeNumeric}
      UpperManual  = false
      LowerLimit {mustBeNumeric}
      LowerManual = false
      AutoYLimitMarginMult {mustBeNumeric} = 0.1
      XLabelAngle {mustBeNumeric} = 35
      MedianLineThickness {mustBePositive,mustBeNumeric,mustBeNonzero} = 3
      FontSize {mustBePositive,mustBeNumeric,mustBeNonzero} = 16
      ColMap = winter
      YLabel = 'Rating'
      BoxFaceAlpha {mustBeInRange(BoxFaceAlpha,0,1,"exclude-lower")} = 0.5
   end
   properties (Dependent)
      NumBoxes
      Medians
      Means
      StdErrs
      DataTableLong
   end
   methods
       % Define a multiboxplot from an array, where each column is the data
       % for a box plot
%        function obj = MultiBoxplot(opts)
%            arguments
%                 opts.?MultiBoxplot
%             end
%             
%             setupper = false;
%             setlower = false;
%             for prop = string(fieldnames(opts))'
%                 obj.(prop) = opts.(prop);
%                 if prop == "UpperLimit"
%                     setupper = true;
%                 elseif prop == "LowerLimit"
%                     setlower = true;
%                 end
%             end
%        end
    function obj = MultiBoxplot(data_sets, plot_title, box_names, opts )
           arguments
               data_sets
               plot_title {mustBeText}
               box_names (1,:) {mustBeText} = {''}
               opts.?MultiBoxplot
           end
           if nargin == 3
               if size(data_sets,2) ~= length(box_names)
                   if size(data_sets,1) == length(box_names)
                       warning('Number of columns in data array does not match provided number of names, but number of rows does match, transposing array and continuing operation.');
                       data_sets = data_sets';
                   else
                       error('Number of columns in data array does not match number of box names. \nSize of array: %dx%d   Number of variables: %d',size(data_sets,1),size(data_sets,2),length(box_names));
                   end
               end
               obj.BoxDataTable = array2table(data_sets,'VariableNames',box_names);
           elseif nargin == 2
               if class(data_sets) ~= 'table'
                   error('First input should be of type table if using two inputs.');
               end
               obj.BoxDataTable = data_sets;
           elseif nargin < 2
               error('Insufficient number of inputs provided.');
           end
%                if class(plot_title) ~= 'char'
%                    error('If using two inputs, second should be')
           obj.Title = plot_title;
           for prop = string(fieldnames(opts))'
                obj.(prop) = opts.(prop);
                if prop == "UpperLimit"
                    obj.UpperManual = true;
                elseif prop == "LowerLimit"
                    obj.LowerManual = true;
                end
           end
           obj = obj.updateAutoLimits();
       end
       % Define a multiboxplot from a table
       function obj = MultiBoxplotT(table, plot_title)
           %varfun(@class,table,'OutputFormat','cell')
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
           if obj.UpperManual && obj.LowerManual
               return
           end
           data_cols = table2array(obj.BoxDataTable);
           max_val = max(data_cols,[],"all");
           min_val = min(data_cols,[],"all");
           if ~obj.UpperManual
              obj.UpperLimit = max_val + obj.AutoYLimitMarginMult*abs(max_val-min_val);
           end
           if ~obj.LowerManual
              obj.LowerLimit = min_val - obj.AutoYLimitMarginMult*abs(max_val-min_val);
           end
       end
       function plot(obj, use_boxchart)
           if nargin > 1
               if use_boxchart
                   obj.plotBoxchart();
               else
                   obj.plotBoxplot();
               end
           else
               if exist('boxplot') > 0
                   obj.plotBoxplot();
               else
                   obj.plotBoxchart();
               end
           end

           hold on
           plot(obj.Means, '*k');

           title(obj.Title);
           set(gcf,'color','w');
           set(findall(gcf,'-property','FontSize'),'FontSize',obj.FontSize)
           hold off
       end
       function plotBoxplot(obj)
           longTable = obj.DataTableLong;
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
            cols = flipud(cols);
            %cols = obj.ColMap(round(linspace(1, length(obj.ColMap), length(m))), :);

            for j=1:length(m)
                patch(get(m(j),'XData'),get(m(j),'YData'),cols(j,:),'FaceAlpha',obj.BoxFaceAlpha);
            end
       end
       function plotBoxchart(obj)
           % Get our box colors for setting the face values
           boxColors = interp1(1:length(obj.ColMap), obj.ColMap, linspace(1, length(obj.ColMap), obj.NumBoxes));

           % We need to have hold on or else it will just erase itself over
           % and over
           hold on
           for i=1:obj.NumBoxes
               data_vals = obj.BoxDataTable{:,i};
               boxchart(zeros(length(data_vals),1) + i, data_vals, 'WhiskerLineStyle','-', 'BoxFaceColor', boxColors(i,:), 'BoxFaceAlpha', obj.BoxFaceAlpha, 'BoxEdgeColor', 'Black', 'MarkerColor','Black');
           end
           hold off
           %label only goes on furthest left boxplot of each row%
            ylabel(obj.YLabel);
            ylim([obj.LowerLimit,obj.UpperLimit]);

            % make median line thicc boi
            hold on
            % Make some new colors that are darker than the originals,
            % gives the same visual effect as the patch overlay in boxplot,
            % so our big thick median lines aren't just heavy full black
            boxes = findobj('Type', 'BoxChart');
            boxw = boxes(1).BoxWidth;
            medColors = boxColors - ((boxColors - zeros([obj.NumBoxes,3]))*(1-obj.BoxFaceAlpha));
            %medianLines = plot(0.5*firstBoxchart.BoxWidth*[-1;1]+(1:obj.NumBoxes), [1;1]*obj.Medians, 'LineWidth',obj.MedianLineThickness );
            for i=1:obj.NumBoxes
                plot(0.5*boxw*[-1;1]+i, [1;1]*obj.Medians(i), 'LineWidth',obj.MedianLineThickness, 'Color',medColors(i,:) );
            end
            hold off

            % Set out x tick labels
            xticks(1:obj.NumBoxes);
            xticklabels(obj.BoxDataTable.Properties.VariableNames);
            xtickangle(obj.XLabelAngle);
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
       function val = get.Medians(obj)
         val =  median(table2array(obj.BoxDataTable),1);
       end
       function val = get.Means(obj)
         val =  mean(table2array(obj.BoxDataTable),1);
       end
       function val = get.StdErrs(obj)
         val =  std(table2array(obj.BoxDataTable),1);
       end
       function val = get.DataTableLong(obj)
         val = stack(obj.BoxDataTable, ...
                   obj.BoxDataTable.Properties.VariableNames, ...
                   'NewDataVariableName','BoxData', ...
                   'IndexVariableName', 'DataGroups');
       end
   end
end