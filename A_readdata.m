clear; close all;

experiment = 2;

switch experiment
    case 1
        subjects  = {'HJK','HS','JYP','RRS','YS'};
    case 2
        subjects = {'ARS','NC','YG','ZF', 'ZW', 'ZY'};
end

for subjidx = 1:length(subjects)
    name = subjects{subjidx}
    
    [alldelay, alldelayidx, allN, allNidx, alltarget, allresp] = deal([]);
    allerror_distr = cell(0);
    
    list = dir(strcat('data_raw_exp',num2str(experiment), '/', name,'*')); % filenames of all sessions
    for sessionidx = 1:length(list)
        load(strcat('data_raw_exp',num2str(experiment), '/',list(sessionidx).name))
        
        switch experiment
            case 1
                alldelay  = [alldelay; data.delay'/1000]; % in s
            case 2
                alldelay  = [alldelay; data.delaytime'/1000];
        end
        allN      = [allN; data.N'];
        alltarget = [alltarget; data.targetval'];
        allresp   = [allresp; data.respangle'];
        for trialidx = 1:length(data.N)
            distractoridx  = setdiff(1:data.N(trialidx), data.targetidx(trialidx));
            distractors    = data.stimvec{trialidx}(distractoridx);
            differences    = pi/90 * (distractors-data.respangle(trialidx));
            error_distr    = angle(exp(i*differences));
            allerror_distr{end+1} = error_distr;
        end
    end
    
    % Conditions
    [delayvec,~,alldelayidx] = unique(alldelay);           % delay index for each trial
    [Nvec,~,allNidx]         = unique(allN);               % numbers of items and set size index for each trial
    Nvec_distr               = setdiff(Nvec-1,0);          % numbers of distractors
    ndelays                  = length(delayvec);
    nN                       = length(Nvec);
    nN_distr                 = length(Nvec_distr);
    conditions               = combvec(1:ndelays, 1:nN);
    allcondidx               = sub2ind([ndelays, nN], alldelayidx, allNidx);
    
    % Responses
    allresp                  = allresp * pi/90;                    % 0 is vertical, positive is clockwise
    alltarget                = alltarget * pi/90;                  % ditto
    allerror                 = angle(exp(i*(allresp-alltarget)));  % clockwise is positive
    
    % Saving for all subjects
    alldata{subjidx}.name        = name;
    alldata{subjidx}.ntrials     = length(alltarget);
    alldata{subjidx}.delayvec    = delayvec;
    alldata{subjidx}.Nvec        = Nvec;
    alldata{subjidx}.ndelays     = ndelays;
    alldata{subjidx}.nN          = nN;
    alldata{subjidx}.ncond       = ndelays * nN;
    alldata{subjidx}.conditions  = conditions;
    
    alldata{subjidx}.alldelayidx = alldelayidx;
    alldata{subjidx}.allNidx     = allNidx;
    alldata{subjidx}.Nvec_distr  = Nvec_distr;
    
    alldata{subjidx}.allcondidx  = allcondidx;
    
    alldata{subjidx}.alltarget   = alltarget;
    alldata{subjidx}.allresp     = allresp;
    alldata{subjidx}.allerror    = allerror;
    alldata{subjidx}.allerror_distr = allerror_distr;
end

filename = strcat('alldata_exp', num2str(experiment));
save(filename,'alldata')