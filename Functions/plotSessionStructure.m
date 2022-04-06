function plotSessionStructure(axes_handle,number_of_trials,new_session_trials,rule_change_trials,strRules)

axes(axes_handle);  % make sure current axis is focus

%% define ranges to plot things in
ymax = axes_handle.YLim(2);
yrange = axes_handle.YLim(2) - axes_handle.YLim(1);
yabove = ymax + 0.1*yrange;
ytext = ymax + (0.1*yrange/2);

%% sessions: plot as faces

face = 1:4;
fcolor = [0.95 0.95 1];

sessions = [1; new_session_trials; number_of_trials];
for iSh = 1:numel(sessions)-1
    % coloured patches on alternating sessions
    if rem(1+iSh,2)  % if an odd number
        vert = [sessions(iSh) 0; sessions(iSh+1) 0; sessions(iSh+1) ymax; sessions(iSh) ymax]; 
        patch('Faces',face,'Vertices',vert,'FaceColor',fcolor,'EdgeColor','none');
    end
end

%% rules: plot as coloured bars

changes = [1; rule_change_trials; number_of_trials]; % add first and last trials to create ends of patches
rcolors = repmat([0 0 0; 0.6 0.6 0.6],ceil(numel(changes)/2),1);

% % add error is Rat 1 is being plotted
% if Rat(iR).ID == 1 % mistake; 2nd "change" is within-session accident
%     line([Rat(iR).ruleChange(2) Rat(iR).ruleChange(2)],[0 1],'Color',[0.8 0.8 0.8]);
%     changes(3) = []; % delete from plotting array
% end

for iC = 1:numel(changes)-1
    % line([changes(iC) changes(iC+1)],[ymax ymax],'Color',rcolors(iC,:),'LineWidth',15,'Clipping','off')
    vert = [changes(iC) ymax; changes(iC+1) ymax; changes(iC+1) yabove; changes(iC) yabove];
    patch('Faces',face,'Vertices',vert,'FaceColor',rcolors(iC,:),'EdgeColor','none','Clipping','off');   
    
    
    % label & line down
    % add "char" casting for old MATLAB versions where text() function
    % can't handle strings
    text(changes(iC)+5,ytext,char(strRules(iC)),'Color',[1 1 1],'Fontsize',9);
        % line([changes(iC) changes(iC)],[0 1],'Color',[0 0 0])
end

