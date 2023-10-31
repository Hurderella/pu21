referDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reference\\";
reconDir = "G:\\내 드라이브\\Colab Notebooks\\HDR_DATASET\\CaveatsOfQA\\reconstructions\\";
networkName_LFNet = "LFNet";
networkName_single = "singlehdr";
clipDelim = "clip_97";
LFNetDir = reconDir + networkName_LFNet + "\\";
SingleDir = reconDir + networkName_single + "\\";

hdrFilePath = LFNetDir + clipDelim + "\\001.hdr";
disp(hdrFilePath);

exrFilePath = SingleDir + clipDelim + "\\001.exr";
disp(exrFilePath);

% 1280 x 1888
hdrFile = hdrread(hdrFilePath);
imshow(hdrFile(:, :, :), [1280 1888]);
figure
exrFile = exrread(exrFilePath);
imshow(exrFile, [1280 1888]);
disp("end");
