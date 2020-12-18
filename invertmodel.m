function LAP = invertmodel(data)

% function 'invertmodel' takes input 'data', which is of dimensions
% 1x(number of timepoints. E.g. if there are 200 timepoints then 'data'
% is entered as 1x200. This function returns a structure 'LAP' following
% Bayesian model inversion.

% model states
%--------------------------------------------------------------------------
x.e         = 1;                    % excitatory variable
x.i         = 1;                    % inhibitory variable

% model parameters
%--------------------------------------------------------------------------
P.A_EE        = 0;                  % self-excitatory coupling parameter
P.A_EI        = 0;                  % cross-inhibitory coupling parameter
P.A_IE        = 0;                  % cross-excitatory coupling parameter
P.A_II        = 0;              	% self-inhibitory coupling parameter
P.C         = 1/32;             	% extrinsic coupling parameter 

% observation function (to generate timeseries)
%--------------------------------------------------------------------------
g = @(x,v,P) x.e + x.i;         	% sum of excitation and inhibition

% equations of motion (coupled excitatory/inhibitory model)
%--------------------------------------------------------------------------
f = @(x,v,P) [P.A_EE*x.e + P.A_EI*x.i + P.C*v;
              P.A_IE*x.e + P.A_II*x.i + P.C*v];

% set prior variance
%--------------------------------------------------------------------------
pC.fe    	= 1;
pC.fi    	= 1;
pC.ge       = 1;
pC.gi     	= 1;
pC.C        = 1;

% populate generative model
%--------------------------------------------------------------------------
DEM.M(1).x  = x;                   	% initial states 
DEM.M(1).f  = f;                  	% equations of motion
DEM.M(1).g  = g;                    % observation mapping
DEM.M(1).pE = P;                   	% model parameters
DEM.M(1).pC = diag(spm_vec(pC))*64;	% prior variance
DEM.M(1).V  = exp(1/64);         	% precision of observation noise
DEM.M(1).W  = exp(1/64);          	% precision of state noise
DEM.M(2).v  = 0;                   	% initial causes
DEM.M(2).V  = exp(1/64);          	% precision of exogenous causes

% data and known input; first timepoint of input is airpuff stim.
%--------------------------------------------------------------------------
DEM.Y       = data;
DEM.U       = zeros(size(data));
DEM.U(1)    = 1;

% Inversion using generalised filtering 
%==========================================================================
LAP         = spm_LAP(DEM);
