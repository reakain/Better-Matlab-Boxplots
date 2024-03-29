# Better Matlab Boxplots

I got tired of constantly needing to rework different code for making boxplots for my reports, or troubleshooting other folks' boxplot code, so I just made a class to simplify the experience.

Tested with Matlab 2022a and b, using the boxplot function from the Statistics and Machine Learning Toolbox. It's also designed to check if you have the toolbox, and if not, then it uses the boxchart method instead.

The example script shows how to run the the script and the shape for importing data. Capabilities are:

 - Generate flexible numbers of boxplots from a set of named data columns (either a table or an array plus a name list). 
 - Each boxplot with be colored using either the selected inbuilt colormap or a custom colormap, because most of the time I want each boxplot to have its own color, since my sets of boxplots are normally multiple independant variables and then I have a set of boxplots for each measure.
 - Auto-generation of significant difference lines, when provided a set of significant difference pairs. The script to generate them is pretty simple, so if you don't like what the stack of lines looks like you can just re-order them in the list. First one in the list is at the bottom of the stack.

### Additional Notes
This is the first time I've made a class for Matlab, or anything that's more than a one-off script, so if anyone reading this has ideas on best practices, ways to protect against input error, or methods to better blend it with existing plotting structures in Matlab, please definitely submit an issue ticket or pull request!

Some updates that would be nice to have:

 - Test/get a version set up that works with Octave


### Programming Details
The class takes in an array of data and transforms it to a wide table, or it can take in a wide table directly. At plot generation time it converts it to a long table.