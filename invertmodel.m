function LAP = invertmodel(data)
% function 'invertmodel' takes input 'data', which is of dimensions
% 1x(number of timepoints. E.g. if there are 200 timepoints then 'data'
% is entered as 1x200. This function returns a structure 'LAP' following
% Bayesian model inversion.

% model states
%--------------------------------------------------------------------------
x.e        	= 1/4;                    % excitatory dependent variable       
x.i       	= 1/4;                    % inhibitory dependent variable         

% model parameters
%--------------------------------------------------------------------------
P.A_EE    	= 0;                    % excitatory self-coupling 
P.A_EI    	= -1/4;                    % inhibitory cross-coupling         
P.A_IE  	= 1/4;                    % excitatory cross-coupling  
P.A_II  	= 0;                    % inhibitory self-coupling    
P.C       	= 1/4;                    % external coupling

% observation function (to generate timeseries)
%--------------------------------------------------------------------------
g = @(x,v,P)  x.e + x.i;         

% equations of motion
%--------------------------------------------------------------------------
f = @(x,v,P) [P.A_EE*x.e + P.A_EI*x.i + P.C*v;
              P.A_IE*x.e + P.A_II*x.i + P.C*v];

% prior variance
%--------------------------------------------------------------------------
pC.fe     	= 1;
pC.fi    	= 1;
pC.ge    	= 1;
pC.gi     	= 1;
pC.C      	= 1;

% first level state space model
%--------------------------------------------------------------------------
DEM.M(1).x 	= x;                    % initial states   
DEM.M(1).f 	= f;                    % equations of motion     
DEM.M(1).g	= g;                    % observation mapping
DEM.M(1).pE	= P;                    % model parameters
DEM.M(1).pC	= diag(spm_vec(pC))*64; % prior variance
DEM.M(1).V	= exp(1);               % precision of observation noise
DEM.M(1).W 	= exp(1);               % precision of state noise

% second level causes or exogenous forcing term
%--------------------------------------------------------------------------
DEM.M(2).v 	= 0;                    % initial causes
DEM.M(2).V 	= exp(1);               % precision of exogenous causes

% data and known input
%--------------------------------------------------------------------------
DEM.Y      	= data;
DEM.U     	= zeros(size(data));
DEM.U(1)  	= 1;

% Inversion using generalised filtering 
%==========================================================================
LAP       	= spm_LAP(DEM);
