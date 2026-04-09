function param = getSubjParam(unique_id, exp, session)

%% set path and pp-specific file locations
if exp == 'l'
    unique_numbers = [29];
    param.path = '\\scistor.vu.nl\shares\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\m7 - test-retest\Data Lissy\';

elseif exp == 'b'
    unique_numbers = [40];
    param.path = '\\scistor.vu.nl\shares\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\m7 - test-retest\Data Bernadett\';

end

log_string = sprintf('data_session_%d_%d_%d.csv', find(unique_numbers == unique_id, 1), unique_id, session);
param.log = [param.path, log_string];

eds_string = sprintf('%d_%d_%d.asc', find(unique_numbers == unique_id, 1), unique_id, session);
param.eds = [param.path, eds_string];

param.savedir = '\\scistor.vu.nl\shares\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\m7 - test-retest';
param.session = num2str(session);
param.subjName = sprintf('pp%d', unique_id);
