function ret = HDRVDP_GETTER(inData, refData)
    Lpeak = 500.0;

    contrast = 1000000;
    
    gamma = 2.2;
    E_ambient = 100;
    ppd = hdrvdp_pix_per_deg( 24, [3840 2160], 0.8 );
    
    inData = inData / max(inData(:));
    refData = refData / max(refData(:));

    L_in = hdrvdp_gog_display_model(inData, Lpeak, contrast, gamma, E_ambient);
    L_ref = hdrvdp_gog_display_model(refData, Lpeak, contrast, gamma, E_ambient);

    ret = hdrvdp3('quality', L_in, L_ref, 'rgb-native', ppd).Q;
    
    ret = gather(ret);

end