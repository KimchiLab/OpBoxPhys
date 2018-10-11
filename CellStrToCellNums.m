function nums = CellStrToCellNums(cell_str)

if iscell(cell_str) && ~isempty(cell_str) 
    if ischar(cell_str{1})
        matches = regexp(cell_str, '\d+', 'match');

        nums = cell(numel(cell_str),1);

        for i_cell = 1:numel(cell_str)
            nums{i_cell} = str2double(matches{i_cell});
        end
    elseif isnumeric(cell_str{1})
        nums = cell_str;
    end
end
