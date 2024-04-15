function id = get_id(str)
    %%% Function to return ID from filename format %%%
    expr = '_G[0-9]+_';
    id = strrep(regexp(str,expr,'match'), '_', '');
    id = string(id);
end