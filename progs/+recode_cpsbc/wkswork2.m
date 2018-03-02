function outV = wkswork2(inV)

% Range check
assert(all(inV <= 9));

outV = nan(size(inV));

% code 0 is NIU - that must mean person is not working
oldV = 0 : 6;
newV = [0, 7, 20, 33, 44, 48, 51];

for i1 = 1 : length(oldV)
   outV(inV == oldV(i1)) = newV(i1);
end


end