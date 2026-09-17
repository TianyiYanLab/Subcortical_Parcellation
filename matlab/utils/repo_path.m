function value = repo_path(relativePath)
% Purpose: locate a data/ or results/ path relative to this repository.
% Input: repository-relative path. Output: native absolute path.
% Dependencies: MATLAB R2019b.
root = fileparts(fileparts(fileparts(mfilename('fullpath'))));
value = fullfile(root, strrep(relativePath,'/',filesep));
end
