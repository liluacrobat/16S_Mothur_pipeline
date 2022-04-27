function prepareFile4Mothur
clc;clear;close all
fid_in = fopen("plate_16S.files",'r');
fid_out = fopen("plate_16S_ready.files",'w');
n = 0;
while ~feof(fid_in)
    n = n+1;
    line = fgetl(fid_in);
    s = strsplit(line);
    pat = "_S"+digitsPattern(1,2)+"_R"+("1"|"2")+"_001.fastq";
    tail = extract(s{2},pat);
    head{n} = strrep(s{2},tail{1},'');
    fprintf(fid_out,'%s\t%s\t%s\n',head{n},s{2},s{3});
end
if length(head)~=length(unique(head))
    disp('Error!!!! Duplicate IDs are found.');
    keyboard
end
end