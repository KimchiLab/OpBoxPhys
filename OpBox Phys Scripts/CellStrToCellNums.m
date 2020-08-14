function nums = CellStrToCellNums(cell_str)

if isempty(cell_str) || ~iscell(cell_str)
    fprintf('Variable cell_str is empty or is not a cell within CellStrToCellNums\n');
    nums = [];
    return;
end

if isnumeric(cell_str{1})
    nums = cell_str;
else
    matches = regexp(cell_str, '\d+', 'match');
    nums = cell(numel(cell_str),1);
    for i_cell = 1:numel(cell_str)
        nums{i_cell} = str2double(matches{i_cell});
    end
end
