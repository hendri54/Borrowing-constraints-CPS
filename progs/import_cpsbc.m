function import_cpsbc(year1, setNo)
% Import all cps variables, after filtering

% Checked: 2015-07-01
% -----------------------------------------

cS = const_cpsbc(setNo);

% Filter variable
vIdxV = var_load_cpsbc(cS.vFilter, year1, setNo);

varNoV = 1 : length(cS.cpsVarNameV);
%varNoV = 8;

for varNo = varNoV(:)'
   varStr = cS.cpsVarNameV{varNo};
   
   % Is this variable number used?
   if ~isempty(varStr)
      % Try to load the cps variable
      %  Applies standard recode
      [inV, success] = var_load_cps(varStr, year1, 1);
      if success == 1
         % Keep only those who pass filter
         inV = inV(vIdxV);
         
         % Recode - variable specific
         if any(varNo == [cS.vAge, cS.vClassWkr, cS.vSex, cS.vRace, cS.vEduc, cS.vEduc99, cS.vHigrade, ...
               cS.vHoursWeek, cS.vWeight])
            % No recode needed
            outV = inV;
            
         else
            if varNo == cS.vIncBus
               outV = recode_incbus_cpsbc(inV, year1, setNo);
            elseif varNo == cS.vIncWage
               outV = recode_incwage_cpsbc(inV, year1, setNo);
            elseif varNo == cS.vLabForce
               outV = recode_labforce_cpsbc(inV, year1, setNo);
            elseif varNo == cS.vEmpStat
               outV = recode_empstat_cpsbc(inV, year1, setNo);
            elseif varNo == cS.vWeeksYear
               outV = recode_wkswork2_cpsbc(inV, year1, setNo);
            else
               error('Variable does not have recode function');
            end
         end % if
         
         var_save_cpsbc(outV, varNo, year1, setNo);
         
      %else
         % Could not load variable
      end
   end
end



end