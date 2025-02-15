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
 * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS" AND
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

function [delta, opt, valid_targets]= estimateDeltaBL3(opt, data, plane, delta, num_beams, num_targets, threshold)
    tic;
    valid_targets(num_beams).skip = [];
    valid_targets(num_beams).valid = [];
    valid_targets(num_beams).num_points = [];
    for ring = 1:num_beams
        valid_targets(ring) = checkRingsCrossDataset(data, plane, threshold, num_targets, ring);
        if ~valid_targets(ring).skip
            D_s = optimvar('D_s', 1, 1,'LowerBound',0,'UpperBound',2);
            D = optimvar('D', 1, 1,'LowerBound',-0.5,'UpperBound',0.5);
            A_c = optimvar('A_c', 1, 1,'LowerBound',deg2rad(-2),'UpperBound',deg2rad(2));
            S_vc = optimvar('S_vc', 1, 1,'LowerBound',-1,'UpperBound',1);
            C_vc = optimvar('C_vc', 1, 1,'LowerBound',0,'UpperBound',1);
            H_oc = optimvar('H_oc', 1, 1,'LowerBound',-0.05,'UpperBound',0.05);
            S_voc = optimvar('S_voc', 1, 1,'LowerBound',-0.05,'UpperBound',0.05);
            C_voc = optimvar('C_voc', 1, 1,'LowerBound',-0.05,'UpperBound',0.05);

            prob = optimproblem;
            f = fcn2optimexpr(@optimizeMultiIntrinsicCostBL3, data,  valid_targets(ring), plane, ring,...
                               D_s, D, A_c, S_vc, C_vc, H_oc, S_voc, C_voc);
            prob.Objective = f;
            x0.D_s = opt.D_s_init;
            x0.D = opt.D_init;
            x0.A_c = opt.A_c_init;
            x0.S_vc = opt.S_vc_init;
            x0.C_vc = opt.C_vc_init;
            x0.H_oc = opt.H_oc_init;
            x0.S_voc = opt.S_voc_init;
            x0.C_voc = opt.C_voc_init;

            % 'Display','iter'
            options = optimoptions('fmincon', 'MaxIter',5e2, 'Display','off', 'TolX', 1e-6, 'TolFun', 1e-6, 'MaxFunctionEvaluations', 3e4);
            max_trail = 5;
            num_tried = 1;
            status = 0;
            while status <=0 
                [sol, fval, status, ~] = solve(prob, x0, 'Options', options);
                if status <=0 
                    warning("optimization failed")
                end
                num_tried = num_tried + 1;
                if (num_tried + 1 > max_trail)
                    warning("tried too many time, optimization still failed, current status:")
                    disp(status)
                    break;
                end
            end
    %         R_final = rotx(sol.theta_x) * roty(sol.theta_y) * rotz(sol.theta_z);
    %         delta(ring).H = eye(4);
    %         delta(ring).H(1:3, 1:3) = R_final;
    %         delta(ring).H(1:3, 4) = sol.T;
            delta(ring).D_s = sol.D_s;
            delta(ring).D = sol.D;
            delta(ring).A_c = sol.A_c;
            delta(ring).S_vc = sol.S_vc;
            delta(ring).C_vc = sol.C_vc;
            delta(ring).H_oc = sol.H_oc;
            delta(ring).S_voc = sol.S_voc;
            delta(ring).C_voc = sol.C_voc;
            delta(ring).opt_total_cost = fval;
            opt.computation_time(ring).time = toc;
        else
            delta(ring).D_s = 1;
            delta(ring).D = 0;
            delta(ring).A_c = 0;
            delta(ring).S_vc = 0;
            delta(ring).C_vc = 0;
            delta(ring).H_oc = 0;
            delta(ring).S_voc = 0;
            delta(ring).C_voc = 0;
            delta(ring).opt_total_cost = 0;
        end
    end
end
