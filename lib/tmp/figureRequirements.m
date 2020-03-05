close('all');
clear();
clc();

folder = '/Users/yasin/Dropbox/Draft 10 (1)/PLOS Computational Biology/PCOMPBIOL-D-18-02030/proofreading/Figures';
listing = dir(fullfile(folder, '*.tif'));

n = numel(listing);

S = struct();

for i = 1:n
    filename = fullfile(listing(i).folder, listing(i).name);
    
    info = imfinfo(filename);
        
    [~, S(i).Filename] = fileparts(info.Filename);
    S(i).Format = info.Format;
    S(i).Compression = info.Compression;
    S(i).FileSize = B2MB(info.FileSize);
    S(i).XResolution = info.XResolution;
    S(i).YResolution = info.YResolution;
    S(i).Width = PX2CM(info.Width, info.XResolution);
    S(i).Height = PX2CM(info.Height, info.YResolution);
end

fprintf('FIGURE REQUIREMENTS\n');
fprintf(' - FileSize < 10 MB\n');
fprintf(' - Width < 19.05cm\n');
fprintf(' - Height < 22.225cm\n\n');

T = struct2table(S);

disp(T);


function MB = B2MB(B)
    MB = round(B / 10 ^ 6, 1);
end

function CM = PX2CM(PX, R)
    CM = PX / R * 2.54;
end