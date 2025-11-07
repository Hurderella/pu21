function ret = PIQE_GETTER 
    %inpath = "C:\\Users\\chan\\Documents\\github\\ICIP\\TEST_RESULT\\TEST_RESULT_2024_12_22__00_50_06\\TestDumpHdr_4_.hdr";
    % ['/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내 ', ...
    %    '드라이브/Colab ', ...;
    %    'Notebooks/HDR_DATASET/CaveatsOfQA/reconstructions/LFNet/clip_97/001.hdr'];
    
    %referpath = "C:\\Users\\chan\\Documents\\github\\ICIP\\TEST_RESULT\\TEST_RESULT_2024_12_22__00_50_06\\TestDumpHdr_ref_4_.hdr";
    % ['/Users/chan/Library/CloudStorage/GoogleDrive-hcs3759@gmail.com/내 ', ...
    %    '드라이브/Colab ', ...;
    %    'Notebooks/HDR_DATASET/CaveatsOfQA/reference/001.exr'];
    % inpath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\hdrcnn\\clip_97\\001.exr";
    % referpath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\reference\\001.exr";
    %inData = hdrread(inpath);
    %refData = hdrread(referpath); 
    % exrread(referpath);
    % inData = exrread(inpath);
    % refData = exrread(referpath);
    basePath = "C:\\Users\\chan\\Documents\\github\\ICIP\\";
    load(basePath + "temp_recon.mat", "recon");
    
    inData = recon;

    batchSize = size(inData, 1);
    tryCount = size(inData, 2);
    retlist = cell(batchSize, 1);

    for k = 1:batchSize
        tryResult = zeros(1, tryCount);
        for y = 1:tryCount
            
            % result = hdrvdp3('quality', squeeze(m_inData(k, y, :, :, :)), squeeze(m_refData(k, :, :, :)), 'rgb-native', ppd, {'quiet', true}).Q;
            % aa =squeeze(inData(k, y, :, :, :));
            % ab = squeeze(inData(k, y, :, :, :));
            % disp(ab(1, 1, 1));
            % disp(ab(1, 1, 2));
            % disp(ab(1, 1, 3));
            % disp(max(ab, [], "all"));
            imgData = clip(squeeze(inData(k, y, :, :, :)), 0, 255.0);
            % imgData = squeeze(inData(k, y, :, :, :));
            % disp(max(imgData, [], "all"));
            % imgData = clip(squeeze(inData(k, y, :, :, :)), 0, 255.0);
            % disp(max(imgData, [], "all"));

            result = piqe(imgData);
            
            result = gather(result);
            % disp(result)
            tryResult(y) = result;
        end
        retlist { k } = tryResult;
    end
    ret = retlist;
    disp(ret);
end