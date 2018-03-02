classdef directories < handle
   
properties (SetAccess = private)
   setStr char
   
   baseDir  char
      progDir  char
      
   setDir  char
      figDir  char
      tbDir  char
      outDir  char
      
   matBaseDir  char
      matDir  char
      rawDir  char
end

properties (Constant)
   userDir = '/Users/lutz';
end



methods
   function dirS = directories(setName)
      dirS.baseDir = fullfile(dirS.userDir, 'Dropbox', 'hc', 'borrow_constraints', 'cps');
      dirS.progDir = fullfile(dirS.baseDir, 'progs');
      dirS.setStr  = setName;

      % For results
      dirS.setDir = fullfile(dirS.baseDir, dirS.setStr);
      dirS.figDir = dirS.setDir;
      dirS.tbDir  = dirS.figDir;
      dirS.outDir = dirS.figDir;

      % Matrix files are stored outside of dropbox
      dirS.matBaseDir = fullfile(dirS.userDir,'Documents','econ','hc','borrow_constraints','cps');
      % Set specific
      dirS.matDir = fullfile(dirS.matBaseDir, dirS.setStr);
      % Raw data
      dirS.rawDir = fullfile(dirS.matBaseDir, 'raw_data');

      % % For outside data, such as unemployment rate
      % cS.dataDir = '/Users/lutz/dropbox/risky_school/data/';
   end
end

end