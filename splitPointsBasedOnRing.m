%{
* Copyright (C) 2013-2025, The Regents of The University of Michigan.
* All rights reserved.
* This software was developed in the Biped Lab (https://www.biped.solutions/) 
* under the direction of Jessy Grizzle, grizzle@umich.edu. This software may 
* be available under alternative licensing terms; contact the address above.
* Redistribution and use in source and binary forms, with or without
* modification, are permitted provided that the following conditions are met:
* 1. Redistributions of source code must retain the above copyright notice, this
*    list of conditions and the following disclaimer.
* 2. Redistributions in binary form must reproduce the above copyright notice,
*    this list of conditions and the following disclaimer in the documentation
*    and/or other materials provided with the distribution.
* THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS AS IS AND
* ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED
* WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
* DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE LIABLE FOR
* ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES
* (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES;
* LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND
* ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
* (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
* SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
* The views and conclusions contained in the software and documentation are those
* of the authors and should not be interpreted as representing official policies,
* either expressed or implied, of the Regents of The University of Michigan.
* 
* AUTHOR: Bruce JK Huang (bjhuang[at]umich.edu)
* WEBSITE: https://www.brucerobot.com/
%}


function data = splitPointsBasedOnRing(points, num_beams, datatype)
    data(num_beams) = struct();
    total = 0;
    if isempty(points)
        warning("No point is on this target")
        data(num_beams).points = [];
        data(num_beams).point_with_I = [];
        return
    end
    % Note: Here we assume the lidar ring in experiment is 0 indexing, so we shift it to
    % fit the matlab routine. However, I fyou use the simulator, the lidar
    % ring will be 1 indexing. Be very careful with this.
    if(datatype == 1)%Experiment
        for n = 0:num_beams-1
            if ~any(points(5,:)==n)
                continue
            end
            ring_point = points(:, points(5,:)==n);
            m = n+1;
            data(m).points = [ring_point(1:3,:); ones(1,size(ring_point,2))];
            data(m).point_with_I = ring_point;
            total= total+size(ring_point,2);
        end
    elseif datatype == 2%"Simulation"
        for n = 1:num_beams
            if ~any(points(5,:)==n)
                continue
            end
            ring_point = points(:, points(5,:)==n);
            data(n).points = [ring_point(1:3,:); ones(1,size(ring_point,2))];
            data(n).point_with_I = ring_point;
            total= total+size(ring_point,2);
        end     
    end
    if total ~= size(points,2)
        warning("inconsistent number of poins in splitPointsBasedOnRing.m");
        warning("split total: %i", total)
        warning("original total %i", size(points,2))
    end
end
