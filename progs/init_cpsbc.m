function init_cpsbc
% Assumes that program dir is on path

disp('CPS data for BC');

% project_start('cps');
dirS = helper_cpsbc.directories(1);
addpath(dirS.progDir);
cd(dirS.progDir);


end
