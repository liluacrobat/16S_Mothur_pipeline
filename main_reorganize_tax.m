function main_reorganize_tax
clc;clear;close all
tbl = readtable('plate_16S.OTU.raw.txt','delimiter','\t','ReadVariableNames',1);
raw = tbl.taxonomy;
L = zeros(size(raw));
Re = cell(size(raw));
ReOTU = cell(size(raw));
OTU = tbl.x_OTUID;
fid = fopen('reformated_tax2.txt','w');
for i=1:length(raw)
    tmp = raw{i};
    s = strsplit(tmp,';');
    pp = '';
    L(i) = length(s);
    for k=1:length(s)
        [~,tax,flag] = rmHead(s{k});
        if flag==0
            if isempty(strrep(tax,'_unclassified',''))
                if ~contains(pp,'_unclassified')
                    ps=strcat(pp,'_unclassified');
                else
                    ps = pp;
                end
                s{k} = ps;
            else
                 pp = s{k};
            end
           
        end
        disp(s{k});
    end
    ks = fun_recombine(s);
    Re{i,1} = ks;
end

if length(unique(L))~=1
    keyboard
else
    for i=1:length(Re)
        ss = strsplit(Re{i},';');
        [hh,tt,flag] = rmHead(ss{end});
        if strcmpi(hh,'s')
            [hh2,tt2,flag] = rmHead(ss{end-1});
            ss{end} = strcat('s__',tt2,'_',tt);
        end
        ssotu = ss;
        if contains(ss{end},'_unclassified')
            ssotu{end}=strcat(ss{end},'_(',upper(OTU{i}),')');
        end
        ks = fun_recombine(ss);
        Re{i,1} = ks;
        ReOTU{i,1} = fun_recombine(ssotu);
            
    end
    fprintf(fid,'original\tnew\tOTU\n');
    for i=1:length(raw)
        fprintf(fid,'%s\t%s\t%s\n',raw{i},Re{i},ReOTU{i});
    end
end
counts = table2array(tbl(:,2:end-1));
fid1 = fopen('plate_16S.OTU.txt','r');
line = fgetl(fid1);
fid2 = fopen('plate_16S.OTU.reformated.txt','w');
fprintf(fid2,'%s\n',line);
for i=1:length(OTU)
    fprintf(fid2,'%s',OTU{i});
    for j=1:size(counts,2)
        fprintf(fid2,'\t%f',counts(i,j));
    end
    fprintf(fid2,'\t%s',ReOTU{i});
    fprintf(fid2,'\n');
end
end
function [head,tax,flag] = rmHead(x)
s = strsplit(x,'__');
flag = 0;
head = '';
tax = '';
if length(s)~=2
    flag=1;
    %     keyboard;
else
    head = s{1};
    tax = s{2};
end

end
function ks = fun_recombine(s)
ks = s{1};
for p=2:length(s)
    ks=strcat(ks,';',strtrim(s{p}));
end

end
