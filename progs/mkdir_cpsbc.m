function mkdir_cpsbc(setNo)
% Make dirs for a new experiment
% -----------------------------------

dirS = helper_cpsbc.directories(setNo);

dirListV = {dirS.matDir, dirS.figDir, dirS.tbDir};

for i1 = 1 : length(dirListV)
   if ~exist(dirListV{i1}, 'dir')
      filesLH.mkdir_lh(dirListV{i1}, 0);
   end
end

end