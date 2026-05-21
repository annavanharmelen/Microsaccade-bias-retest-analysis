clear all
close all
clc

%% set parameters and loops
display_percentage_ok = 1;
plot_individuals = 1;
plot_averages = 1;

pp2do = [12, 13, 17, 19, 25, 29, 30, 36, 40, 49, 57, 66, 75, 77, 95, 97];

subplot_size = ceil(sqrt(size(pp2do, 2)*2));

%% load and aggregate the data from all pp
for s = 1:size(pp2do, 2)
    % loop over sessions within participant
    for session = [1, 2]
        
        figure_nr = 1;
        
        param = getSubjParam(pp2do(s), session);
        disp(['getting data from ', param.subjName, ' session ', param.session]);
        
        %% load actual behavioural data
        behdata = readtable(param.log);
    
        %% check percentage oktrials
        % select trials with reasonable decision times
        oktrials = abs(zscore(behdata.idle_reaction_time_in_ms))<=3; 
        percentageok(s,session,1) = mean(oktrials)*100;
      
        % display percentage ok trials
        if display_percentage_ok
            fprintf('%s session %s has %.2f%% oktrials\n', param.subjName, param.session, percentageok(s,session,1))
        end

        %% basic data checks, each pp in own subplot
        if plot_individuals
            figure(figure_nr);
            figure_nr = figure_nr+1;
            subplot(subplot_size,subplot_size,2*s+session-2);
            h = histogram(behdata.idle_reaction_time_in_ms,50);
            title(['decision time - pp ', num2str(pp2do(s))]);
            xlim([0 2000]);
            ylim([0 150]);
    
            figure(figure_nr);
            figure_nr = figure_nr+1;
            subplot(subplot_size,subplot_size,2*s+session-2);
            h = histogram(behdata.response_time_in_ms, 50);
            title(['response time - pp ', num2str(pp2do(s))]);
            xlim([0 2010]);
            ylim([0 150]);
            
            figure(figure_nr);
            figure_nr = figure_nr+1;
            subplot(subplot_size,subplot_size,2*s+session-2);
            histogram(behdata.signed_difference(oktrials),50);
            title(['signed error - pp ', num2str(pp2do(s))]);
            xlim([-100 100]);
    
            figure(figure_nr);
            figure_nr = figure_nr+1;
            subplot(subplot_size,subplot_size,2*s+session-2);
            histogram(behdata.absolute_difference(oktrials),50);
            title(['error - pp ', num2str(pp2do(s))]);
            xlim([0 100]);
        end
    
        
        %% trial selections
        left_trials = ismember(behdata.target_position, {'left'});
        right_trials = ismember(behdata.target_position, {'right'});
    
        obj1_trials = behdata.target_object == 1;
        obj2_trials = behdata.target_object == 2;
        obj3_trials = behdata.target_object == 3;
        obj4_trials = behdata.target_object == 4;
        obj5_trials = behdata.target_object == 5;
        obj6_trials = behdata.target_object == 6;
        obj7_trials = behdata.target_object == 7;
        obj8_trials = behdata.target_object == 8;
    
        premature_trials = ismember(behdata.premature_pressed, {'True'});
        
        %% extract data of interest
        overall_dt(s,session,1) = mean(behdata.idle_reaction_time_in_ms(oktrials), "omitnan");
        overall_error(s,session,1) = mean(behdata.signed_difference(oktrials), "omitnan");
        overall_abs_error(s,session,1) = mean(behdata.absolute_difference(oktrials), "omitnan");
    
    end
end

if plot_averages
 %% check performance per participant over sessions combined
    figure; 
    figure_nr = figure_nr+1;
    subplot(4,1,1);
    bar(1:size(pp2do,2), mean(overall_dt, 2));
    title('overall decision time');
    ylim([0 900]);
    xticks(1:size(pp2do,2))
    xticklabels(pp2do)
    xlabel('pp #');

    subplot(4,1,2);
    bar(1:size(pp2do,2), mean(overall_error, 2));
    title('overall error');
    xticks(1:size(pp2do,2))
    xticklabels(pp2do)
    xlabel('pp #');

    subplot(4,1,3);
    hold on
    bar(1:size(pp2do,2), mean(overall_abs_error, 2));
    title('overall abs error');
    xticks(1:size(pp2do,2))
    xticklabels(pp2do)
    xlabel('pp #');

    subplot(4,1,4);
    bar(1:size(pp2do,2), mean(percentageok, 2));
    title('percentage ok trials');
    ylim([90 100]);
    xticks(1:size(pp2do,2))
    xticklabels(pp2do)
    xlabel('pp #');

end
