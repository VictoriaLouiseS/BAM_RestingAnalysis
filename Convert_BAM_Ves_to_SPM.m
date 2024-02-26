% Script to convert all the fiedltrip format files from the BAM resting
% analysis virtual sensors to SPM memory-mapped files using the 
% convert_ve_to_spmlfp function in atcm toolbox.
%
% AS

files = dir('LCMV_*'); files = {files.name}';

for i = 1:length(files)
    file = files{i};

    clear ftdata;

    load(file);

    atcm.fun.convert_ve_to_spmlfp(ftdata,['SPM_' strrep(file,'.mat','')]);

    pause(1);
end