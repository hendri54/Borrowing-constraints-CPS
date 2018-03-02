function preamble_cpsbc(setNo)

cS = const_cpsbc(setNo);

dataFn = var_fn_cpsbc(cS.vPreambleData, [], setNo);
preamble_lh.initialize(dataFn, fullfile(cS.outDir, 'preamble.tex'));

add_field('cpsAgeMin',  sprintf('%i', cS.fltAgeMin), 'Earliest data age', cS);
add_field('cpsAgeMax',  sprintf('%i', cS.fltAgeMax), 'Latest data age', cS);
add_field('cpsYearFirst',  sprintf('%i', cS.yearV(1)), 'First data year', cS);
add_field('cpsYearLast',  sprintf('%i', cS.yearV(end)), 'Last data year', cS);

outStr = string_lh.string_from_vector(cS.ageWorkStart_sV, '%i');
add_field('cpsAgeWorkStartV',  outStr, 'Work start age by school', cS);
add_field('cpsAgeWorkLast',  sprintf('%i', cS.ageWorkLast), 'Last work age', cS);
add_field('cpsAgeOne',  sprintf('%i', cS.age1),  'Discount to this age', cS);

add_field('cpsWageMinFactor',  sprintf('%.2f', cS.wageMinFactor),  'Multiple of median', cS);
add_field('cpsWageMaxFactor',  sprintf('%0f',  cS.wageMaxFactor),  'Multiple of median', cS);

add_field('cpsAggrAgeRange', sprintf('%i-%i', cS.aggrAgeRangeV([1, end])), 'Age range for aggregates', cS);
% add_field('cpsCpiBaseYear',  sprintf('%i', cS.cpiBaseYear), 'cpi base year', cS);

% ****  filter

add_field('cpsHoursMin', sprintf('%i', cS.fltHoursMin), 'Min hours per week', cS);
add_field('cpsWeeksMin', sprintf('%i', cS.fltWeeksMin), 'Min weeks per year', cS);

texFn = preamble_lh.write_tex(dataFn);
type(texFn);


end


function add_field(fieldName, commandStr, commentStr, cS)

dataFn = var_fn_cpsbc(cS.vPreambleData, [], cS.setNo);
preamble_lh.add_field(fieldName, commandStr, dataFn, commentStr);

end