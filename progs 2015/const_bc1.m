function cS = const_bc1(setNo, expNo)
% Set constants
%{
Index order: k, age, school, iq, yp, abil, j, cohort
   iq: q
   age: t
   ability: a

Checked: 2015-Mar-18
%}
% -----------------------------

% Default set and exp numbers
cS.setDefault = 7;
cS.expBase = 1;
if isempty(setNo)
   setNo = cS.setDefault;
end
if nargin < 2
   expNo = cS.expBase;
end
if isempty(expNo)
   expNo = cS.expBase;
end
cS.setNo = setNo;
cS.expNo = expNo;
setStr = sprintf('set%03i', setNo);
expStr = sprintf('exp%03i', expNo);

cS.dbg = 111; 
cS.missVal = -9191;
cS.pauseOnError = 1;
% How often to run full debug mode during calibration?
cS.dbgFreq = 0.5;  


%% Miscellaneous

% How many nodes to use on kure
cS.kureS.nNodes = 8;
% Run parallel on kure?
cS.kureS.parallel = 1;
% Profile to use (local: no need to start multiple matlab instances)
cS.kureS.profileStr = 'local';

% When regressing college entry on [iq, yp], use weighted regression?
%  It makes little difference
cS.regrEntryIqYpWeighted = 0;

% 1 = $unitAcct
cS.unitAcct = 1e3;

% params are calibrated never / only for base exper / also for other exper
cS.calNever = 0;
cS.calBase = 1;
cS.calExp = 2;
cS.doCalValueV = [cS.calNever, cS.calBase, cS.calExp];

%          % Collection of calibrated parameters
%          pvec = pvector(30, cS.doCalValueV);

cS.male = 1;
cS.female = 2;
cS.both = 3;
cS.sexStrV = {'men', 'women', 'both'};

% fzero options for finding EE equation zeros
cS.fzeroOptS = optimset('fzero');
cS.fzeroOptS.TolX = 1e-7;

% fminbnd options for maximizing value functions
cS.fminbndOptS = optimset('fminbnd');
cS.fminbndOptS.TolX = 1e-7;

% cS.raceWhite = 23;

% Bounds for transformed guesses
cS.guessLb = 1;
cS.guessUb = 2;

% Gross interest rate (if not calibrated)
cS.R = 1.04;


% *******  Notation (used for preamble and for generating results)



%% Default parameters: Demographics, Preferences

% Cohorts modeled
cS.bYearV = [1915, 1942, 1961, 1979]';
% Year to be displayed for each cohort (high school graduation)
cS.cohYearV = cS.bYearV + 18;
% For each cohort: calibrate time varying parameters with these experiments
cS.bYearExpNoV = [203, 202, NaN, NaN];
% Data sources
cS.dataSource_cV = {'Updegraff (1936)', 'Project Talent', 'NLSY79'};
% Cross sectional calibration for this cohort
cS.iRefCohort = find(cS.bYearV == 1961);
cS.nCohorts = length(cS.bYearV);


% Age at model age 1
cS.age1 = 18;
% Last physical age
cS.physAgeLast = 75;
% Retirement age (last age with earnings)
cS.physAgeRetire = 65;

% Is curvature of u(c) the same in college / at work?
cS.ucCurvatureSame = 1;

% Consumption floor
cS.cFloor = 500 ./ cS.unitAcct;
% Leisure floor
cS.lFloor = 0.01;



%% Default: endowments

% Size of ability grid
cS.nAbil = 9;
% Earnings are determined by phi(s) * (a - aBar)
%  aBar determines for which abilities earnings gains from schooling MUST be positive
% cS.aBar = 0;

% Number of types
cS.nTypes = 150;

% IQ groups
cS.iqUbV = (0.25 : 0.25 : 1)';
cS.nIQ = length(cS.iqUbV);

% Parental income classes
cS.ypUbV = (0.25 : 0.25 : 1)';


cS.abilAffectsEarnings = 1;



%% Default: schooling

% College lasts this many periods
cS.collLength = 4;

cS.iHSG = 1;
cS.iCD = 2;
cS.iCG = 3;
cS.nSchool = cS.iCG;
cS.sLabelV = {'HSG', 'CD', 'CG'};
cS.ageWorkStart_sV = [1; 3; cS.collLength+1];




%% Default: other

% Base year for prices
cS.cpiBaseYear = 2010;

% Last year with data for anything
cS.lastDataYear = 2014;
% First year with data for anything (cpi starts in 1913)
cS.firstDataYear = 1913;

% Set no for cps routines
cS.cpsSetNo = 1;


% ******  Vector of calibrated params
pvec = calibr_bc1.pvector_default(cS);

% ******  Which calibration targets to use?
% These are targets we would like to match. Targets that are NaN are ignored.
cS.tgS = calibr_bc1.caltg_defaults('default');


%% Parameter sets

if setNo == 1
   cS.setStr = 'Default';
   cS.iCohort = cS.iRefCohort;
   
elseif setNo == 2
   cS.setStr = 'Ability does not affect earnings';
   cS.abilAffectsEarnings = 0;
   
elseif setNo == 3
   % For testing. Calibrate to another cohort
   cS.setStr = 'Test with another cohort';
   [~, cS.iCohort] = min(abs(cS.bYearV - 1940));
   
elseif setNo == 4
   % Higher curvature of u(c) during college
   % Is curvature of u(c) the same in college / at work?
   cS.ucCurvatureSame = 0;
    % Curvature of u(c) in college
   pvec = pvec.change('prefSigma', '\varphi_{c}', 'Curvature of utility', 4, 1, 5, cS.calNever);
   
elseif setNo == 5
   cS.setStr = 'SES stats';
   cS.tgS.useSesTargets = 1;
   
elseif setNo == 6
   cS.setStr = 'Alt debt stats';
   pvec = pvec.calibrate('cCollMax', cS.calBase);
   pvec = pvec.calibrate('lCollMax', cS.calBase);

elseif setNo == 7
   cS.setStr = 'Default';
%    pvec = pvec.calibrate('cCollMax', cS.calBase);
%    pvec = pvec.calibrate('lCollMax', cS.calBase);
%    pvec = pvec.change('puWeightStd',  '\sigma_{p}', 'Std of weight on parental utility', 0.05, 0.001, 2, cS.calBase);
%    pvec = pvec.change('alphaPuM', '\alpha_{y,m}', 'Correlation, $\omega_{p},m$', 0.5, -5, 5, cS.calBase);
%    % Penalize transfers > data transfers?
%    cS.tgPenalizeLargeTransfers = 0;

else
   error('Invalid');
end


%% Experiment settings
% Can modify calibration targets (e.g. just target school fractions)

[expS, tgS, pvec, cS.doCalV, cS.iCohort] = calibr_bc1.exp_settings(pvec, cS);
if ~isempty(tgS)
   cS.tgS = tgS;
end


%% Derived constants

if exist('/Users/lutz', 'dir')
   cS.runLocal = 1;
   cS.runParallel = 1; 
   cS.nNodes = 4;
   cS.parProfileStr = 'local';
else
   cS.runLocal = 0;
   cS.runParallel = cS.kureS.parallel;
   cS.nNodes = cS.kureS.nNodes;
   % Default (empty) for killdevil. Local for kure
   cS.parProfileStr = cS.kureS.profileStr;
end


cS.pr_iqV = diff([0; cS.iqUbV]);
cS.pr_ypV = diff([0; cS.ypUbV]);

cS.nCohorts = length(cS.bYearV);
% Year each cohort start college (age 19)
cS.yearStartCollege_cV = cS.bYearV + 18;

% Lifespan
cS.ageMax = cS.physAgeLast - cS.age1 + 1;
cS.ageRetire = cS.physAgeRetire - cS.age1 + 1;

% Length of work phase by s
cS.workYears_sV = cS.ageMax - cS.ageWorkStart_sV + 1;

if cS.abilAffectsEarnings == 0   
   pvec = pvec.change('phiHSG', '\phi_{HSG}', 'Return to ability, HSG', 0,  0.02, 0.2, cS.calNever);
   pvec = pvec.change('phiCG',  '\phi_{CG}',  'Return to ability, CG',  0, 0.02, 0.2, cS.calNever);
   pvec = pvec.change('eHatCD', [], [], 0, [], [], cS.calNever);
   pvec = pvec.change('dEHatHSG', [], [], 0, [], [], cS.calNever);
   pvec = pvec.change('dEHatCG', [], [], 0, [], [], cS.calNever);
end

if cS.ucCurvatureSame == 1
   % Do not calibrate curvature of work utility
   % It is the same as college utility
   pvec = pvec.calibrate('workSigma', cS.calNever);
end


%% Directories

if cS.runLocal == 1
   cS.baseDir = fullfile('/users', 'lutz', 'dropbox', 'hc', 'borrow_constraints');
else
   cS.baseDir = '/nas02/home/l/h/lhendri/bc';
   cS.dbgFreq = 0.1;    % Ensure that dbg is always low on the server
   cS.pauseOnError = 0;
end

cS.modelDir = fullfile(cS.baseDir, 'model1');

   cS.progDir = fullfile(cS.modelDir, 'progs');
   cS.matDir  = fullfile(cS.modelDir, 'mat', setStr, expStr);

   cS.setOutDir = fullfile(cS.modelDir, 'out', setStr);
      % Show data
      cS.dataOutDir = fullfile(cS.setOutDir, 'data');
      cS.outDir  = fullfile(cS.setOutDir, expStr);
         % Within an experiment: show fit
         cS.fitDir  = fullfile(cS.outDir, 'fit');
         % Parameters
         cS.paramDir = fullfile(cS.outDir, 'params');
         % Hh solution
         cS.hhDir = fullfile(cS.outDir, 'household');

      cS.figDir  = cS.outDir;
      cS.tbDir   = cS.outDir;

   cS.sharedDir = fullfile(cS.modelDir, 'shared');

cS.dataDir = fullfile(cS.baseDir, 'data');

cS.cpsDir = fullfile(cS.baseDir, 'cps');
   cS.cpsProgDir = fullfile(cS.cpsDir, 'progs');
   
% Historical study data files live here
cS.studyDir = '/Users/lutz/Dropbox/borrowing constraints/data/';
   cS.studyGradDir  = fullfile(cS.studyDir, 'income x iq x college grad');
   cS.studyEntryDir = fullfile(cS.studyDir, 'income x iq x college');


% Preamble data
cS.preambleFn = fullfile(cS.outDir, 'preamble1.tex');


%%  Saved variables

% Calibrated parameters
cS.vParams = 1;

% Hh solution
cS.vHhSolution = 2;

% Aggregates
cS.vAggregates = 3;
% Additional aggregates, computed after calibration is done
cS.vAggrStats = 8;

% Preamble data
cS.vPreambleData = 5;

% Calibration results
cS.vCalResults = 6;

% Intermediate results from cal_dev
%  so that interrupted calibration can be continued
cS.vCalDev = 7;


%%  Variables that are always saved / loaded for base expNo
%  varNo 400-499

% CPI, base year = 1
cS.vCpi = 401;

% College costs, base year prices
cS.vCollCosts = 402;

% Calibration targets
cS.vCalTargets = 403;

% Cohort earnings profiles (data)
cS.vCohortEarnProfiles = 404;

cS.vCohortSchooling = 405;

% Avg student debt by year
cS.vStudentDebtData = 406;


%% Clean up

cS.expS = expS;
cS.pvector = pvec;


end