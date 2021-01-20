function LAP = invertmodel(data)
% function 'invertmodel' takes input 'data', which is of dimensions
% 1x(number of timepoints. E.g. if there are 200 timepoints then 'data'
% is entered as 1x200. This function returns a structure 'LAP' following
% Bayesian model inversion.

% model states (initial conditions)
%--------------------------------------------------------------------------
x.e        	= 2;                    % E dependent variable       
x.i       	= 2;                    % I dependent variable         

% model parameters (priors)
%--------------------------------------------------------------------------
P.A_EE    	    =  0;               % E self-coupling 
P.A_EI    	    = -2;               % I cross-coupling         
P.A_IE  	      =  2;               % E cross-coupling  
P.A_II  	      =  0;               % I self-coupling    
P.gE            =  2;               % E contribution to signal
P.gI            =  2;               % I contribution to signal
P.CE            =  2;               % external coupling to E
P.CI            =  2;               % external coupling to I

% observation function (to generate timeseries - mix of E and I)
%--------------------------------------------------------------------------
g = @(x,v,P)  P.gE*x.e + P.gI*x.i;        

% equations of motion
%--------------------------------------------------------------------------
f = @(x,v,P)      [P.A_EE*x.e + P.A_EI*x.i + P.CE*v;
                   P.A_IE*x.e + P.A_II*x.i + P.CI*v];

% prior variance
%--------------------------------------------------------------------------
pC.A_EE         = 1;              
pC.A_EI         = 1;              
pC.A_IE         = 1;            
pC.A_II         = 1;              
pC.gE           = 1;
pC.gI           = 1;
pC.CE           = 1;  
pC.CI           = 1;  

% first level state space model
%--------------------------------------------------------------------------
DEM.M(1).x 	= x;                    % initial states   
DEM.M(1).f 	= f;                    % equations of motion     
DEM.M(1).g	= g;                    % observation mapping
DEM.M(1).pE	= P;                    % model parameters
DEM.M(1).pC	= diag(spm_vec(pC))*16; % prior variance
DEM.M(1).V	= exp(2);               % precision of observation noise
DEM.M(1).W 	= exp(2);               % precision of state noise

% second level causes or exogenous forcing term
%--------------------------------------------------------------------------
DEM.M(2).v 	= 0;                    % initial causes
DEM.M(2).V 	= exp(2);               % precision of exogenous causes

% data and known input
%--------------------------------------------------------------------------
DEM.Y      	= data;
DEM.U     	= zeros(size(data));
DEM.U(1)  	= 1;                    % airpuff

% Inversion using generalised filtering 
%==========================================================================
LAP       	= spm_LAP(DEM);
