function stats = get_var_stats(var_data)
    stats = []
    stats.range = range(var_data);
    stats.IQR = iqr(var_data);
    stats.median = median(var_data);
    stats.mean = mean(var_data);
end