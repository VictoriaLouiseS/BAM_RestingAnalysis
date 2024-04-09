function p = get_parameters(Ep)
    %%% Extract parameters of interest from model output data for analysis %%%
    
    % Extrinsic AMPA and NMDA frontal-parietal connections
    %
    % (Values when exponentiating seemed like they already had been
    % somewhere? Investigate...)
    p.AMPA_FWD = Ep.A{1}(1,2); % exp(Ep.A{1}(1,2));
    p.AMPA_BKW = Ep.A{2}(2,1); % exp(Ep.A{2}(2,1));
    
    p.NMDA_FWD = Ep.AN{1}(1,2); % exp(Ep.AN{1}(1,2));
    p.NMDA_BKW = Ep.AN{2}(2,1); % exp(Ep.AN{2}(2,1));
    
    % p.A  = spm_unvec( exp(spm_vec(Ep.A )) , Ep.A  );
    % p.AN = spm_unvec( exp(spm_vec(Ep.AN)) , Ep.AN );
    % p.B  = spm_unvec(    (spm_vec(Ep.B )) , Ep.B  );
    % p.BN = spm_unvec(    (spm_vec(Ep.BN)) , Ep.BN );
    
    % Intrinsic connection matrices
    %
    % Excitatory (np x np): AMPA
    %       SS    SP     SI   DP    DI    TP    RT    RL
    GEa = [  0     0     0     0     0     2     0     2; % SS
             2     2     0     0     0     0     0     0; % SP
             0     2     0     0     0     0     0     0; % SI
             0     2     0     0     0     0     0     0; % DP
             0     0     0     2     0     0     0     0; % DI
             0     0     0     2     0     0     0     0; % TP
             0     0     0     0     0     0     0     2; % RT
             2     0     0     0     0     2     0     0];% RL
    
    % Excitatory (np x np): NMDA
    %       SS    SP     SI   DP    DI    TP    RT    RL
    GEn =   [0     0     0     0     0     2     0     2; % SS
             2     2     2     0     0     0     0     0; % SP
             0     2     2     0     0     0     0     0; % SI
             0     2     0     0     0     0     0     0; % DP
             0     0     0     2     0     0     0     0; % DI
             0     0     0     2     0     0     0     0; % TP
             0     0     0     0     0     0     0     2; % RT
             2     0     0     0     0     2     0     0];% RL
    
    % Inhibitory connections (np x np): GABA-A & GABA-B
    %    SS    SP     SI   DP    DI    TP    RT    RL
    GIa =[8     0     10    0     0     0     0     0; % SS
          0    18     10    0     0     0     0     0; % SP
          0     0     10    0     0     0     0     0; % SI
          0     0     0     8     6     0     0     0; % DP
          0     0     0     0    14     0     0     0; % DI
          0     0     0     0     6     8     0     0; % TP
          0     0     0     0     0     0     8     0; % RT
          0     0     0     0     0     0     8     8];% RL
    
    % Calculate AMPA and NMDA intrinsics
    p.H = Ep.H .* (GEa + GIa); % exp(Ep.H) .* (GEa + GIa); % AMPA and GABA
    p.Hn = Ep.Hn .* GEn;       % exp(Ep.Hn) .* GEn; % NMDA
    
    % Extract frontal and parietal instrinsics
    p.H_frontal = p.H(:,:,1)
    p.H_parietal= p.H(:,:,2)
    p.Hn_frontal = p.Hn(:,:,1)
    p.Hn_parietal= p.Hn(:,:,2)
    
    
    % Calculate time constants
    p.K_AMPA  = 1./(exp(-Ep.T(:,1))*1000/2.2);%3;       % excitatory rate constants (AMPA) % 2 to 5
    p.K_GABAA  = 1./(exp(-Ep.T(:,2))*1000/5);%6;        % inhibitory rate constants (GABAa)
    p.K_NMDA  = 1./(exp(-Ep.T(:,3))*1000/100);%40;      % excitatory rate constants (NMDA) 40-100
    p.K_GABAB  = 1./(exp(-Ep.T(:,4))*1000/300);         % excitatory rate constants (NMDA)
    p.K_M    = 1./((exp(-Ep.T(:,5))*1000/160)) ;        % m-current opening + CV
    p.K_HCN    = 1./((exp(-Ep.T(:,6))*1000/100)) ;      % h-current opening + CV
    
    p = spm_unvec( real(spm_vec(p)),p);

end
