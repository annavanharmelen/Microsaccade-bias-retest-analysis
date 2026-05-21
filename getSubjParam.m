function param = getSubjParam(unique_id, session)

%% set path and datafile locations
param.path = '\\scistor.vu.nl\shares\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\m7 - test-retest\Data all\';

log_string = sprintf('data_%d_%d.csv', unique_id, session);
param.log = [param.path, log_string];

eds_string = sprintf('%d_%d.asc', unique_id, session);
param.eds = [param.path, eds_string];

param.savedir = '\\scistor.vu.nl\shares\FGB-ETP-CogPsy-ProactiveBrainLab\core_lab_members\Anna\Data\m7 - test-retest';
param.session = num2str(session);
param.subjName = sprintf('pp%d', unique_id);
