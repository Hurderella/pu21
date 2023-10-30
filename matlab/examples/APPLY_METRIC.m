
hdrBasePath = "C:\\Users\\chan\\Documents\\HDR_DATASET\\CaveatsOfQA\\sihdr\\";
reconPath = "reconstructions\\LFNet\\";
referencePath = "reference\\";
clipDelim = "LFNET_output_95\\";
ext = ".hdr";
refExt = ".exr";

reconFullPath = hdrBasePath + reconPath + clipDelim + "*" + ext;
referenceFullPath = hdrBasePath + referencePath;

reconFolderInfo = dir(reconFullPath);

for idx = 1:length(reconFolderInfo)
    
    reconFileName = reconFolderInfo(idx).name;
    reconFilePath = hdrBasePath + reconPath + clipDelim + reconFileName;
    
    referenceFileName = extractBefore(reconFileName, ext) + refExt;
    referenceFilePath = hdrBasePath + referencePath + referenceFileName;


    fprintf("%s\n", reconFileName);
    fprintf("%s\n", reconFilePath);
    fprintf("<<--->> %s \n", referenceFileName);
    fprintf("%s\n", referenceFilePath);

    reconFile = hdrread(reconFilePath);
    referenceFile = hdrread(referenceFilePath);

    Lpeak = 1000;

    pu21_psnr = pu21_metric(reconFile, referenceFile, 'PSNR');
    pu21_fsim = pu21_metric(reconFile, referenceFile, 'FSIM');
    pu21_fsim_crf = pu21_metric(reconFile, referenceFile, 'FSIM', 'crf_correction', true);
    
    fprintf('PU21-PNSR : %g, PU21-FSIM : %g, PU21-FSIM-CRF : %g', ...
        pu21_psnr, pu21_fsim, pu21_fsim_crf);
    break
end