function filenames = getFilenamesWithSameSaccadeVector(filenames)

    G = {};
    
    fprintf('\nGet neuron filenames with the same saccade vector: \n');
    tic();
    for i = 1:numel(filenames)
        filename = filenames{i};

        sv = getSV(filename);
        flag = false;

        for j = 1:numel(G)
            sv_ = getSV(G{j}{1});

            if isequalSV(sv, sv_)
                G{j}{end + 1} = filename;
                flag = true;
                break
            end
        end

        if ~flag
            G{end + 1} = {filename};
        end
    end

    imax = 0;
    nmax = -inf;
    fprintf('\n');
    for i = 1:numel(G)
        n = numel(G{i});

        if n > nmax
            nmax = n;
            imax = i;
        end

        fprintf('Index:%3d - Elements: %d\n', i, n);
    end

    fprintf('\nGroup with maximum elements\n');
    fprintf('Index:%3d - Elements: %d\n', imax, nmax);
    for j = 1:nmax
        [~, name, ~] = fileparts(G{imax}{j});
        fprintf('  %s\n', name);
    end
    
    filenames = G{imax};
    
    toc();
end

function sv = getSV(filename, N)
    % Get locations
    %
    % Parameters
    % ----------
    % - filename: string
    %   Neuron filename
    % - N: number
    %   Round to N number of digits
    %
    % Returns
    % -------
    % - sv: number[2]
    %   Saccade vector (dva)
    
    if nargin < 2
        N = 3;
    end
    
    load(filename, 'st_in_dva');
    
    sv = st_in_dva;
    sv = round(sv, N);
end

function tf = isequalSV(sv, sv_)
    tf = all(sv == sv_);
end
