% MATLAB SIMULATION OF FS-1015 LPC-10e
% COPYRIGHT (C) 1996-99 ANDREAS SPANIAS and TED PAINTER
%
% This Copyright applies only to this particular MATLAB implementation
% of the LPC-10e coder.  The MATLAB software is intended only for educational
% purposes.  No other use is intended or authorized.  This is not a public
% domain program and unauthorized distribution to individuals or networks 
% is prohibited. Be aware that use of the standard in any form is goverened
% by rules of the US DoD.  
% This program is free software. It is distributed in the hope that it will
% be useful, but WITHOUT ANY WARRANTY; without even the implied warranty of
% MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  There is no commitment 
% or even implied commitment on behalf of Andreas Spanias or Ted Painter
% for maintenance or support of this code.
%
% MATLAB is trademark of The Mathworks Inc
%
% ALL DERIVATIVE WORKS MUST INCLUDE THIS COPYRIGHT NOTICE.
% ALL DERIVATIVE WORKS MUST INCLUDE THIS COPYRIGHT NOTICE.
%
% ******************************************************************
% MLOAD
%
% PORTED TO MATLAB FROM LPC-55 C RELEASE
% 3-19-94
%
% ******************************************************************
%
% DESCRIPTION
%
% Loads the LPC matrix using an optimized algorithm for the covariance
% method.  Inversion is performed in a separate routine.
%
% DESIGN NOTES
%
% The covariance method for obtaining direct form predictor coefficients
% is described in Rabiner and Schafer, DIGITIAL PROCESSING OF SPEECH
% SIGNALS, Prentice-Hall, 1978, pp. 403-404.
%
% Note that the PHI matrix here is not a traditional covariance matrix.
% "Covariance" usually refers to the correlation of a signal with its mean
% removed.  This matrix shall be called "covariance", however, since
% it is symmetric and has the properties of a covariance matrix.
%
% The matrix loading procedure exploits redundancy in the matrix structure,
% since columns of PHI vary by only one product term.  The process of
% end-correction is used to load columns beyond 1.
%
% See Also:  Version 52 release notes.
%
% VARIABLES
%
% INPUTS
%   awinf    -   Length of analysis window
%   speech   -   Preemphasized speech data
%
% OUTPUTS
%   phi      -   Covariance matrix
%   psi      -   Covariance vector
%
% INTERNAL
%   V        -   Internal vector used to compute first column of phi
%   start    -   PHI matrix index
%   i        -   General purpose counter
%   r        -   row counter
%
% CONSTANTS
%   ORDER    -   Linear prediction order
%   MAXORD   -   Linear prediction order
%
% ******************************************************************

function [ phi, psi ] = mload( awinf, speech )

% DECLARE GLOBAL VARIABLES
global MAXORD ORDER;

% INIT INTERNAL VARIABLES
phi = zeros( MAXORD, MAXORD );
psi = zeros( MAXORD, 1 );

% LOAD FIRST COLUMN OF TRIANGULAR COVARIANCE MATRIX, PHI
start = ORDER + 1;
V = speech( start-1:awinf-1 );
for i = 1:ORDER
    phi(i,1) = sum( speech( start-i:awinf-i ) .* V );
end

% LOAD LAST ELEMENT OF VECTOR PSI
psi( ORDER ) = sum( speech(start:awinf) .* speech(start-ORDER:awinf-ORDER) );

% END CORRECT TO COMPUTE REMAINING ELEMENTS OF PHI MATRIX
for r = 2:ORDER
    phi(r,2:r) = phi(r-1,1:(r-1)) - ...
                 ( speech(awinf+1-r)*speech(awinf-1:-1:awinf+1-r) )' + ...
                 ( speech(start-r)*speech(start-2:-1:start-r) )';
end

% END CORRECT TO OBTAIN REMAINING COMPONENTS OF PSI VECTOR
psi( 1:ORDER-1 ) = phi( 2:ORDER,1 ) - ...
                   ( speech(start-1)*speech(start-2:-1:start-ORDER) ) + ...
                   ( speech(awinf)*speech(awinf-1:-1:awinf-ORDER+1) );