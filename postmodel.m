function [results]= postmodel(LAP)
% function 'postmodel' takes input 'LAP', which is the output produced
% by 'invertmodel.m'. It provides the output 'results', which consist
% of the posterior estimates of the E and I coupling parameters
% — see eq. 2 in the paper, together with the trace/determinant values
% — see eqs. 5 and 6 in the paper.

results.A_EE = LAP.qP.P{1,1}.A_EE;
results.A_EI = LAP.qP.P{1,1}.A_EI;
results.A_IE = LAP.qP.P{1,1}.A_IE;
results.A_II = LAP.qP.P{1,1}.A_II;

results.trace = results.A_EE + results.A_II;
results.det = results.A_EE*results.A_II - results.A_EI*results.A_IE;




