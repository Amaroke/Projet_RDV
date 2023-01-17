function [label] = get_label(fname)
tmp = strsplit(fname, '-');
tmp = strsplit(tmp{1}, '/');
label = tmp{end};
end