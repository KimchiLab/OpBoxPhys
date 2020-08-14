function nums = CellStrToNums(cell_str)

matches = regexp(cell_str, '\d+$', 'match');

nums = nan(numel(cell_str),1);

for i_cell = 1:numel(cell_str)
    nums(i_cell) = str2double(matches{i_cell});
end
