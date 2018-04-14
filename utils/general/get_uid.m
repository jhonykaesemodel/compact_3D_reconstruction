function uid = get_uid(fullId)

fullId = strsplit(fullId, '.');
uid = fullId{2};
