function dirS = directories(setNo)

dirS.baseDir = fullfile('/Users/lutz/Dropbox', 'hc', 'borrow_constraints', 'cps');
dirS.progDir = fullfile(dirS.baseDir, 'progs');
dirS.setStr  = sprintf('set%03i', setNo);

% For results
dirS.setDir = fullfile(dirS.baseDir, dirS.setStr);
dirS.figDir = dirS.setDir;
dirS.tbDir  = dirS.figDir;
dirS.outDir = dirS.figDir;

% Matrix files are stored outside of dropbox
dirS.matBaseDir = fullfile('~','documents','econ','hc','borrow_constraints','cps');
dirS.matDir = fullfile(dirS.matBaseDir, dirS.setStr);

% % For outside data, such as unemployment rate
% cS.dataDir = '/Users/lutz/dropbox/risky_school/data/';


end