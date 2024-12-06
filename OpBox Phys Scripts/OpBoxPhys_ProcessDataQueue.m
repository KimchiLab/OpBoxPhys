%% Extra function
function OpBoxPhys_ProcessDataQueue(data)
    global subjects;
    mask = [subjects.cam_idx] == data{1};
    subjects(mask).num_frame = data{2};
    subjects(mask).curr_frame = data{3};
end
