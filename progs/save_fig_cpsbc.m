function save_fig_cpsbc(figFn, saveFigures, figOptInS, setNo)
% IN:
%  figFn
%     Do NOT include path
% ---------------------------------------------

cS = const_cpsbc(setNo);

if isempty(figOptInS)
   bcS = const_fig_bc1;
   figOptS = bcS.figOptS;
else
   figOptS = figOptInS;
end

% Create fig dir if necessary
if ~exist(cS.figDir, 'dir')
   files_lh.mkdir_lh(cS.figDir);
end

figOptS.figDir = fullfile(cS.figDir, 'figdata');
if ~exist(figOptS.figDir, 'dir')
   files_lh.mkdir_lh(figOptS.figDir);
end

figures_lh.fig_save_lh(fullfile(cS.figDir, figFn), saveFigures, 0, figOptS);

end