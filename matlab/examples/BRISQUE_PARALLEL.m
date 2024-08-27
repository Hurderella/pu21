function score = BRISQUE_PARALLEL(data)

    ret = zeros(size(data, 1), 1);
    
    disp(size(data, 1))
    %parfor(idx = 1:size(data, 1), 8)
    for idx = 1:size(data, 1)
        img = data(idx, :, :);
        img = squeeze(img);
        ret(idx) = brisque(img(:, :));
    end
    % parfor(idx = 1:size(data, 1), 8)
    %     img = data(idx, :, :);
    %     disp(size(img));
    %     ret(idx) = brisque(img);
    % end
    score = ret;
    disp(score)
end
