function mkdir_cpsbc(setNo)
% Make dirs for a new experiment
% -----------------------------------

cS = const_cpsbc(setNo);

dirListV = {cS.matDir, cS.figDir, cS.tbDir};

for i1 = 1 : length(dirListV)
   if ~exist(dirListV{i1}, 'dir')
      files_lh.mkdir_lh(dirListV{i1}, 0);
   end
end

end