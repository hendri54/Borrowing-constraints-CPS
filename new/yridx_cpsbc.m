function yrIdxV = yridx_cpsbc(yearV, setNo)
% --------------------------

cS = const_cpsbc(setNo);

yrIdxV = repmat(cS.missVal, size(yearV));
for iy = 1 : length(yearV)
   yrIdx = find(cS.yearV == yearV(iy));
   if ~isempty(yrIdx)
      yrIdxV(iy) = yrIdx;
   end
end


end