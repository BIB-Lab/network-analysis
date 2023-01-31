clc
format long

addpath(braph_path)
addpath([braph_path filesep 'utility'])
addpath([braph_path filesep 'stat'])
addpath([braph_path filesep 'graph'])
addpath([braph_path filesep 'ds'])
addpath([braph_path filesep 'init'])
addpath([braph_path filesep 'atlas'])
addpath([braph_path filesep 'mri'])
addpath([braph_path filesep 'pet'])
addpath([braph_path filesep 'fmri'])
addpath([braph_path filesep 'eeg'])

byuatlas = readmatrix(composite_atlas,'FileType','delimitedtext');
size(byuatlas)
brs = {};

[rows, ~] = size(byuatlas);
for region = 1:rows
    coord1 = byuatlas(region,1);
    coord2 = byuatlas(region,2);
    coord3 = byuatlas(region,3);

    br = BrainRegion(BrainRegion.LABEL,num2str(region), ...
    BrainRegion.NAME,num2str(region), ...
    BrainRegion.X,coord1, ...
    BrainRegion.Y,coord2, ...
    BrainRegion.Z,coord3, ...
    BrainRegion.HS,BrainRegion.HS_RIGHT, ...
    BrainRegion.NOTES,'...');

    brs{end+1} = br;
    disp('Brain Vertex Created:')
    disp(region)
end

atlas = BrainAtlas(brs,BrainAtlas.NAME,'Atlas1');

%% create subjects
groupinfo = readmatrix(network_group,'FileType','delimitedtext');
subjlist = importdata(amp_comp_path);
sub = {};

[subjects, ~] = size(subjlist);
for ampfile = 1:subjects
    path = string(subjlist(ampfile));
    deform = readmatrix(path,'FileType','text');
    [~,subjname,~] = fileparts(path);
    subject = MRISubject( ...
        MRISubject.CODE,subjname, ...
        MRISubject.AGE, ...
        MRISubject.GENDER_NA, ...
        MRISubject.DATA,deform, ...
        MRISubject.NOTES,'none');

    sub{end+1} = subject;
    disp('Subject Imported:')
    disp(subjname)

end

%% create cohort

scz_group = groupinfo;
con_group = 1 - scz_group;

cohort = MRICohort(atlas,sub,MRICohort.NAME,'Cohort Trial');
g1 = Group(Group.NAME,'scz_group',Group.DATA,scz_group,Group.NOTES,'scz_group');
g2 = Group(Group.NAME,'con_group',Group.DATA,con_group,Group.NOTES,'con_group');
cohort.addgroup(g1)
cohort.addgroup(g2)
disp('Cohort generated.')

%% Create MRI graph analysis

ga = MRIGraphAnalysisWU(cohort, Structure(), ...
    MRIGraphAnalysis.CORR, MRIGraphAnalysis.CORR_PEARSON, ...  % Choose one: CORR_PEARSON CORR_SPEARMAN CORR_KENDALL CORR_PARTIALPEARSON CORR_PARTIALSPEARMAN
    MRIGraphAnalysis.NEG, MRIGraphAnalysis.NEG_ZERO ... % Choose one: NEG_ZERO NEG_NONE NEG_ABS
    );

disp(' ')
disp('MEASURES')
for m = GraphWU.MEASURES_WU
    name = Graph.NAME{m};
    nodal = Graph.NODAL(m);
    if nodal
        disp([int2str(m) ' - ' name ' (nodal)' ])
    else
        disp([int2str(m) ' - ' name ' (global)' ])
    end
end
clear m name nodal;

disp(' ')
disp('GROUPS')
for g = 1:1:ga.getCohort.groupnumber()
    gr = cohort.getGroup(g);
    disp([int2str(g) ' - ' gr.getPropValue(Group.NAME)])
end
clear gr;
%% Calculate measure/comparison/random comparison

    while ~exist('stop')
        disp(' ')
        MCF = input('New measure (M) or comparison (C) or random comparison (R) or finish (F) ? ','S');

        switch lower(MCF)

            case 'm'

                groupnumber = input('Group number ');
                if groupnumber > cohort.groupnumber
                    disp(['Group ' int2str(groupnumber) ' is not a valid group'])
                    groupnumber = input('Group number ');
                end
                measurecode = input('Measure number ');
                bool = any(GraphWU.MEASURES_WU == measurecode);
                if ~bool
                    disp(['The entered measure is not a valid WU measure'])
                    measurecode = input('Measure number ');
                end

                ga.calculate(measurecode,groupnumber);
                m = ga.getMeasure(measurecode,groupnumber);
                gr = ga.getCohort().getGroup(groupnumber);

                if Graph.isglobal(measurecode)
                    file_name = strcat(Graph.NAME{measurecode},'_',gr.getPropValue(Group.NAME),'.txt');
                    file_path = fullfile('/Users/aaclouse/Desktop/measures/',file_name);
                    fid = fopen(file_path,'w');

                    fprintf(fid,'=== === ===\n');
                    fprintf(fid,'Group number = %d\n', groupnumber);
                    fprintf(fid,'Group name = %s\n', gr.getPropValue(Group.NAME));
                    fprintf(fid,'Measure code = %d GLOBAL MEASURE\n', measurecode);
                    fprintf(fid,'Measure name = %s\n', Graph.NAME{measurecode});
                    fprintf(fid,'Measure value = %f\n', m.getProp(MRIMeasureWU.VALUES1));
                    fprintf(fid,'=== === ===\n');
                    fclose(fid);
                end

                if Graph.isnodal(measurecode)
                    disp('=== === ===')
                    disp(['Group number = ' int2str(groupnumber)])
                    disp(['Group name = ' gr.getPropValue(Group.NAME)])
                    disp(['Measure code = ' int2str(measurecode) ' NODAL MEASURE'])
                    disp(['Measure name = ' Graph.NAME{measurecode}])

                    values = m.getProp(MRIMeasureWU.VALUES1);
                    disp(['Average (over regions) measure value = ' num2str(mean(values))])

                    file_name = strcat(Graph.NAME{measurecode},'_',gr.getPropValue(Group.NAME),'.csv');
                    file_path = fullfile('/Users/aaclouse/Desktop/measures/',file_name);
                    fid = fopen(file_path,'w');
                    fprintf(fid,'%s,vertex\n',Graph.NAME{measurecode});
                    ba = ga.getBrainAtlas();
                    for i = 1:1:ba.length()
                        br = ba.get(i);
                        fprintf(fid,'%f,%s\n', values(i), br.getPropValue(BrainRegion.NAME));
                    end
                    fclose(fid);

                    disp('=== === ===')
                end

            case 'c'

                groupnumber1 = input('1st group number ');
                if groupnumber1 > cohort.groupnumber
                    disp(['Group ' int2str(groupnumber1) ' is not a valid group'])
                    groupnumber1 = input('1st group number ');
                end
                groupnumber2 = input('2nd group number ');
                if groupnumber2 > cohort.groupnumber
                    disp(['Group ' int2str(groupnumber2) ' is not a valid group'])
                    groupnumber2 = input('2nd group number ');
                end
                measurecode = input('Measure number ');
                bool = any(GraphWU.MEASURES_WU == measurecode);
                if ~bool
                    disp(['The entered measure is not a valid WU measure'])
                    measurecode = input('Measure number ');
                end
                M = input('Permutation number (typically 1000) ');

                ga.compare(measurecode,groupnumber1,groupnumber2,'Verbose',true,'M',M)
                c = ga.getComparison(measurecode,groupnumber1,groupnumber2)
                gr1 = ga.getCohort().getGroup(groupnumber1)
                gr2 = ga.getCohort().getGroup(groupnumber2)

                if Graph.isglobal(measurecode)
                    file_name = strcat(Graph.NAME{measurecode},'_',gr1.getPropValue(Group.NAME),'_',gr2.getPropValue(Group.NAME),'.txt');
                    file_path = fullfile('/Users/aaclouse/Desktop/comparisons/',file_name);
                    fid = fopen(file_path,'w');

                    fprintf(fid,'=== === ===\n');
                    fprintf(fid,'Group numbers = %d and %d\n', groupnumber1, groupnumber2);
                    fprintf(fid,'Group names = %s and %s\n', gr1.getPropValue(Group.NAME), gr2.getPropValue(Group.NAME));                    fprintf(fid,'Measure code = %d GLOBAL MEASURE\n', measurecode);
                    fprintf(fid,'Measure name = %s\n', Graph.NAME{measurecode});
                    fprintf(fid,'Difference = %f\n', c.diff());
                    fprintf(fid,'p-value (1) = %f\n', c.getProp(MRIComparisonWU.PVALUE1));
                    fprintf(fid,'p-value (2) = %f\n', c.getProp(MRIComparisonWU.PVALUE2));
                    fprintf(fid,'confidence interval = %f\n', c.CI(5));
                    fprintf(fid,'=== === ===\n');
                    fclose(fid);

                end

                if Graph.isnodal(measurecode)
                    disp('=== === ===')
                    disp(['Group numbers = ' int2str(groupnumber1) ' and ' int2str(groupnumber2)])
                    disp(['Group names = ' gr1.getPropValue(Group.NAME) ' and ' gr2.getPropValue(Group.NAME)])
                    disp(['Measure code = ' int2str(measurecode) ' NODAL MEASURE'])
                    disp(['Measure name = ' Graph.NAME{measurecode}])

                    values = c.diff();
                    p1 = c.getProp(MRIComparisonWU.PVALUE1);
                    p2 = c.getProp(MRIComparisonWU.PVALUE2);
                    ci = c.CI(5);
                    disp(['Differences (per region) = ' num2str(values)])
                    disp(['p-value (1) (per region) = ' num2str(p1)])
                    disp(['p-value (2) (per region) = ' num2str(p2)])
                    disp(['con.int.do  (per region) = ' num2str(ci(1,:))])
                    disp(['con.int.up  (per region) = ' num2str(ci(2,:))])

                    file_name = strcat(Graph.NAME{measurecode},'_',gr1.getPropValue(Group.NAME),'_',gr2.getPropValue(Group.NAME),'.csv');
                    file_path = fullfile('/Users/aaclouse/Desktop/comparisons/',file_name);
                    fid = fopen(file_path,'w');
                    fprintf(fid,'differences,vertex,p1,p2,ci_low,ci_high\n');

                    ba = ga.getBrainAtlas();
                    for i = 1:1:ba.length()
                        br = ba.get(i);
                        fprintf(fid,'%f,%s,%f,%f,%f,%f\n',values(i), br.getPropValue(BrainRegion.NAME),p1(i),p2(i),ci(1,i),ci(2,i));
                    end
                    fclose(fid);

                    disp('=== === ===')
                end

            case 'r'

                groupnumber = input('Group number ');
                if groupnumber > cohort.groupnumber
                    disp(['Group ' int2str(groupnumber) ' is not a valid group'])
                    groupnumber = input('Group number ');
                end
                measurecode = input('Measure number ');
                bool = any(GraphWU.MEASURES_WU == measurecode);
                if ~bool
                    disp(['The entered measure is not a valid WU measure'])
                    measurecode = input('Measure number ');
                end
                M = input('random graph number (typically 1000)');

                ga.randomcompare(measurecode,groupnumber,'Verbose',true,'M',M);
                n = ga.getRandomComparison(measurecode,groupnumber);
                gr = ga.getCohort().getGroup(groupnumber);

                if Graph.isglobal(measurecode)
                    file_name = strcat(Graph.NAME{measurecode},'_rcomp_',gr.getPropValue(Group.NAME),'.txt');
                    file_path = fullfile('/Users/aaclouse/Desktop/random_comp/',file_name);
                    fid = fopen(file_path,'w');

                    fprintf(fid,'=== === ===\n');
                    fprintf(fid,'Group number = %d\n', groupnumber);
                    fprintf(fid,'Group name = %s\n', gr.getPropValue(Group.NAME));
                    fprintf(fid,'Measure code = %d GLOBAL MEASURE\n', measurecode);
                    fprintf(fid,'Measure name = %s\n', Graph.NAME{measurecode});
                    fprintf(fid,'Measure value = %f\n', n.getProp(MRIRandomComparisonWU.VALUES1));
                    fprintf(fid,'Random graph value = %f\n', n.getProp(MRIRandomComparisonWU.RANDOM_COMP_VALUES));
                    fprintf(fid,'p-value (1) = %f\n', n.getProp(MRIRandomComparisonWU.PVALUE1));
                    fprintf(fid,'p-value (2) = %f\n', n.getProp(MRIRandomComparisonWU.PVALUE2));
                    fprintf(fid,'confidence interval = %f\n', n.CI(5));
                    fprintf(fid,'=== === ===\n');
                    fclose(fid);

                end

                if Graph.isnodal(measurecode)
                    disp('=== === ===')
                    disp(['Group number = ' int2str(groupnumber)])
                    disp(['Group name = ' gr.getPropValue(Group.NAME)])
                    disp(['Measure code = ' int2str(measurecode) ' NODAL MEASURE'])
                    disp(['Measure name = ' Graph.NAME{measurecode}])

                    values = n.getProp(MRIRandomComparisonWU.VALUES1);
                    disp(['Average (over regions) measure value = ' num2str(mean(values))])

                    values = n.diff();
                    p1 = n.getProp(MRIRandomComparisonWU.PVALUE1);
                    p2 = n.getProp(MRIRandomComparisonWU.PVALUE2);
                    ci = n.CI(5);
                    disp(['Differences (per region) = ' num2str(values)])
                    disp(['p-value (1) (per region) = ' num2str(p1)])
                    disp(['p-value (2) (per region) = ' num2str(p2)])
                    disp(['con.int.do  (per region) = ' num2str(ci(1,:))])
                    disp(['con.int.up  (per region) = ' num2str(ci(2,:))])

                    file_name = strcat(Graph.NAME{measurecode},'_rcomp_',gr.getPropValue(Group.NAME),'.csv');
                    file_path = fullfile('/Users/aaclouse/Desktop/random_comp/',file_name);
                    fid = fopen(file_path,'w');
                    fprintf(fid,'differences,vertex,p1,p2,ci_low,ci_high\n');

                    ba = ga.getBrainAtlas();
                    for i = 1:1:ba.length()
                        br = ba.get(i);
                        fprintf(fid,'%f,%s,%f,%f,%f,%f\n',values(i), br.getPropValue(BrainRegion.NAME),p1(i),p2(i),ci(1,i),ci(2,i));
                    end
                    fclose(fid);

                    disp('=== === ===')
                end

            otherwise
                stop = true;
        end
    end
