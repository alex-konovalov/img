function [sph, edgelength, vt, u] = layout(inobj, outobj)
%LAYOUT Flatten a 3D surface mesh discrete-conformally.
%   [f, v, vt, u] = dcflatten(inobj) reads the file named inobj in
%   alias/wavefront obj format and flattens it. Only lines beginning with
%   'v ' or 'f ' are read, all other lines are ignored. The input mesh must
%   be a triangulated surface which is a topological disc. The triangles 
%   must be consistently oriented. Edges with length 0 are not allowed.
%
%   [f, v, vt, u] = dcflatten(inobj, outobj) writes the flat mesh as
%   texture coordinates to outobj. Note that only f-lines, v-lines and
%   vt-lines are written to outobj. All other data that might be contained 
%   in inobj (such as normals) are not copied to outobj.
% 
%   The return values are:
%
%   f : an array of dimension (number of triangles) x 3. 
%       f(m,n) is the index of the nth vertex in the mth triangle.
%   v : an array of dimension (number of vertices) x 3.
%       v(m,:) are the coordinates of the mth vertex of the original mesh.
%   vt: an array of dimension (number of vertices) x 2.
%       v(m,:) are the coordinates of the mth vertex of the flattened mesh.
%   u : a vector of length (number of vertices).
%       u(m) is the log scale factor at vertex number m. If an edge between
%       vertices m and n has lenght l in the original mesh, then it has
%       length l * exp(u(m) + u(n)) in the flat mesh.

if nargin < 1
    inobj = 'triangulation';
end

fid = fopen(inobj,'r');
while true
    switch fscanf(fid,'%s',1)
        case 'VERTICES'
            numvertices = fscanf(fid,'%d',1);
            ivertex = fscanf(fid,'%d',1);
        case 'FACES'
            numfaces = fscanf(fid,'%d',1);
        loglength = zeros(numfaces,3);
	    f = zeros(numfaces,3);
        for n = 1:numfaces
            f(n,:) = fscanf(fid,'%d',3);
            loglength(n,:) = reallog(fscanf(fid,'%f',3));
        end
        case ''
            break
    end
end
fclose(fid);

if numfaces ~= 2*(numvertices-2)
    fprintf(1, 'Error: numvertices = %d, numfaces = %d\n', numvertices, numfaces);
end

numangles = 3 * numfaces;

boundaryvertices = false(numvertices,1);
for n=1:numfaces
    if ivertex==f(n,1) || ivertex==f(n,2) || ivertex==f(n,3)
        boundaryvertices(f(n,:)) = true;       
    end
end
interiorvertices = ~boundaryvertices;

fprintf('infty=%d, %u boundary vertices, %u interior vertices.\n', ivertex, nnz(boundaryvertices), nnz(interiorvertices));

%---- end of input changes (LB)

% u_per_triangle is a (3 * numfaces) by numvertices matrix which is used to
% distribute the u-values. u_per_triangles(m, n) is 1 if f(m) == n, otherwise 0. 
% (Here, f is indexed as linear vector.)
u_per_triangle = sparse(1 : numangles, f(:), ones(numangles,1), numangles, numvertices, numangles);
% Allocate numfaces by 3 matrices which are used in dcfunctional.
upt = zeros(numfaces, 3);
angles = zeros(numfaces, 3);
ct = zeros(numfaces, 3);

% The following variables are used for the statistics that outfun displays.
numbrokentriangs = uint32(0);

% The discrete conformal functional with gradient and hessian.
    function [grad, hess] = dcfunctional(u)
        % Cout broken triangs for the statistics.
        numbrokentriangs = 0;
        % upt(m,n) is the u-value of the nth vertex in triangle n.
        upt(:) = u_per_triangle * u;
        % newloglenth(m,n) is the new logarithmic length of the edge
        % opposite the nth vertex in the mth triangle.
        newloglength = loglength + upt(:, [2, 3, 1]) + upt(:, [3, 1, 2]);
        % angles(m,n) is the angle at the nth vertex of the mth triangle.
        % ct(m,n) is the corresponding cotan (or zero if triangle is
        % broken).
        [angles(:, 1), angles(:, 2), angles(:, 3), ct(:, 1), ct(:, 2), ct(:, 3)] = ...
            arrayfun(@triangle_angles, newloglength(:,1), newloglength(:,2), newloglength(:,3));
        % Calculate the gradient.
        grad = 2 * pi - (u_per_triangle' * angles(:));
        % Build the Hessian.
        ii = [f(:, 1);         f(:, 2);         f(:, 3);         f(:, 1);  f(:, 2);  f(:, 2);  f(:, 3);  f(:, 3);  f(:, 1)];
        jj = [f(:, 1);         f(:, 2);         f(:, 3);         f(:, 2);  f(:, 1);  f(:, 3);  f(:, 2);  f(:, 1);  f(:, 3)];
        hh = [ct(:,2)+ct(:,3); ct(:,3)+ct(:,1); ct(:,1)+ct(:,2); -ct(:,3); -ct(:,3); -ct(:,1); -ct(:,1); -ct(:,2); -ct(:, 2)];
        hess = sparse(ii, jj, hh, numvertices, numvertices);
    end

    function [alpha, beta, gamma, cota, cotb, cotc] = triangle_angles(loga, logb, logc)
        a = exp(loga);
        b = exp(logb);
        c = exp(logc);
        s0 =  a + b + c;
        s1 = -a + b + c;
        s2 =  a - b + c;
        s3 =  a + b - c;
        if s1 <= 0 || s2 <= 0 || s3 <= 0
            numbrokentriangs = numbrokentriangs + uint32(1);
            alpha = pi * (s1 <= 0);
            beta  = pi * (s2 <= 0);
            gamma = pi * (s3 <= 0);
            cota = 0;
            cotb = 0;
            cotc = 0;
            return;
        end
        alpha = 2 * atan(realsqrt(s2 * s3 / (s1 * s0)));
        beta  = 2 * atan(realsqrt(s3 * s1 / (s2 * s0)));
        gamma = 2 * atan(realsqrt(s1 * s2 / (s3 * s0)));
        p = 0.5 / realsqrt(s1 * s2 * s3 * s0);
        cota = p * (s1 * s0 - s2 * s3);
        cotb = p * (s2 * s0 - s3 * s1);
        cotc = p * (s3 * s0 - s1 * s2);
    end

% allocate vector u used in targetfunction.
u = zeros(numvertices,1);
for n=1:numfaces
    for m=1:3
        if f(n,m)==ivertex
            u(f(n,mod(m,3)+1)) = -loglength(n,mod(m+1,3)+1);
        end
    end
end
u(ivertex) = 0.;

    % Clip boundaryvertices out of dcfunctional.
    function [g, h] = targetfunction(x)
        u(interiorvertices) = x;
        [g, h] = dcfunctional(u);
        g(boundaryvertices) = [];
        h(:, boundaryvertices) = [];
        h(boundaryvertices, :) = [];
    end

% Prepare for the minimization.
xstart = zeros(nnz(interiorvertices), 1);

% Set optimization options.
options = optimset(...
    'Jacobian', 'on', ...
    'TolX', 0, ...
    'Display', 'iter', ...
    'Diagnostics', 'off');

% Minimize!
xsol = fsolve(@targetfunction, xstart, options); 
u(interiorvertices) = xsol;

% Don't need these anymore.
clear upt u_per_triangle angles ct

%%%%%%%%%%%%%%%%%%%%%%%
% Lay out the flat mesh.

% triangforedge(m, n) is the triang containing directed edge from vertex m
% to vertex n, or 0 if no such edge exists.
triangforedge = sparse([f(:,1), f(:,2), f(:,3)], ...
                       [f(:,2), f(:,3), f(:,1)], ...
                       [1:numfaces, 1:numfaces, 1:numfaces], numvertices, numvertices, 3 * numfaces);
% edgelength(m, n) is the length of directed edge from vertex m to n.
edgelength = sparse([f(:,1); f(:,2); f(:,3)], ...
                    [f(:,2); f(:,3); f(:,1)], ...
                    exp([loglength(:, 3) + u(f(:, 1)) + u(f(:, 2)); ...
                         loglength(:, 1) + u(f(:, 2)) + u(f(:, 3)); ...
                         loglength(:, 2) + u(f(:, 3)) + u(f(:, 1))]));
% Allocate vt for vertex coordinates of flat mesh. Third coordinate is
% zero. It is there because this facilitates displaying the flat mesh.
vt = zeros(numvertices,3);

% edgeslopte(m, n) is to hold the slope angle of directed edge from vertex
% m to n.
edgeslope = double(triangforedge | triangforedge'); % sparse matrix with given sparsity pattern.                     

traversedualspanningtree(@travroot, @travleft, @travright);

    function traversedualspanningtree(traverserootedge, traverseleftedge, traverserightedge)
        % init edge queue
        edgequeue.size = numfaces;
        edgequeue.data = zeros([2, numfaces], 'uint32');
        edgequeue.i1 = uint32(0);
        edgequeue.i2 = uint32(0);

        function pushedge(edge)
            if edgequeue.i2 - edgequeue.i1 >= edgequeue.size
                error('Edge queue is full.');
            end
            edgequeue.data(:, mod(edgequeue.i2, edgequeue.size) + 1) = edge;
            edgequeue.i2 = edgequeue.i2 + 1;
        end

        function edge = popedge()
            if edgequeue.i1 == edgequeue.i2
                error('Edge queue is empty.');
            end
            edge = edgequeue.data(:, edgequeue.i1 + 1);
            edgequeue.i1 = edgequeue.i1 + 1;
            if edgequeue.i1 >= edgequeue.size
                edgequeue.i1 = edgequeue.i1 - edgequeue.size;
                edgequeue.i2 = edgequeue.i2 - edgequeue.size;
            end
        end

        facetag = ~all(f'-ivertex);
        
        roottriang = find(~facetag,1);
        rootedge = f(roottriang, [1,2]);
        facetag(roottriang) = true;
        pushedge(rootedge);
        traverserootedge(rootedge);
        oppedge = rootedge([2,1]);
        oppface = triangforedge(oppedge(1), oppedge(2));
        if (oppface > 0 && ~facetag(oppface))
            facetag(oppface) = true;
            pushedge(oppedge);
        end

        while edgequeue.i1 ~= edgequeue.i2 % edge queue not empty
            edge = popedge();
            face = triangforedge(edge(1), edge(2));
            switch f(face, 1)
                case edge(1)
                    v3 = f(face, 3);
                case edge(2)
                    v3 = f(face, 2);
                otherwise
                    v3 = f(face, 1);
            end
            leftedge = [edge(1); v3];
            leftface = triangforedge(leftedge(1), leftedge(2));
            rightedge = [v3; edge(2)];
            rightface = triangforedge(rightedge(1), rightedge(2));
            if (leftface > 0 && ~facetag(leftface))
                facetag(leftface) = true;
                pushedge(leftedge);
            end
            traverseleftedge(leftedge, edge);
            if (rightface > 0 && ~facetag(rightface))
                facetag(rightface) = true;
                pushedge(rightedge);
            end
            traverserightedge(rightedge, edge);
        end
    end

    function travroot(edge)
        i1 = edge(1);
        i2 = edge(2);
        edgeslope(i1, i2) = 0;
        edgeslope(i2, i1) = pi;
        x = edgelength(i1, i2);
        vt(edge, :) = [0, 0, 0; 
                       x, 0, 0];
    end

    function travleft(edge2, edge1)
        i1 = edge1(1);
        i2 = edge1(2);
        i3 = edge2(2);

        c = full(edgelength(i1, i2)); % without the full, realsqrt below complains.
        a = full(edgelength(i2, i3));
        b = full(edgelength(i3, i1));
        alpha = 2 * atan(realsqrt(max((a - b + c) * (a + b - c) / ((-a + b + c) * (a + b + c)), 0)));
        slope = edgeslope(i1, i2) + alpha;
        edgeslope(i1, i3) = slope;
        edgeslope(i3, i1) = slope - pi;
        vt(i3, :) = vt(i1, :) + b * [cos(slope), sin(slope), 0];
    end

    function travright(edge2, edge1)
        i1 = edge1(1);
        i2 = edge1(2);
        i3 = edge2(1);

        c = full(edgelength(i1, i2)); % without the full, realsqrt below complains.
        a = full(edgelength(i2, i3));
        b = full(edgelength(i3, i1));
        beta = 2 * atan(realsqrt(max((-a + b + c) * (a + b - c) / ((a - b + c) * (a + b + c)), 0)));
        slope = edgeslope(i1, i2) - beta;
        edgeslope(i3, i2) = slope;
        edgeslope(i2, i3) = slope + pi;
        vt(i3, :) = vt(i2, :) - a * [cos(slope), sin(slope), 0];
    end

% center points
vt = vt - repmat(sum(vt)/numvertices,numvertices,1);
ptnorm = vt(:,1).^2 + vt(:,2).^2 + 1.;
sph = [2*vt(:,1)./ptnorm,2*vt(:,2)./ptnorm,(ptnorm-2.)./ptnorm];
sph(ivertex,:) = [0.,0.,1.];

if false % show the flat mesh.
    figure();
    patch('Vertices', vt, 'Faces', f, 'FaceColor', [0.9 0.9 0.9]);
    axis equal;
    axis off;
    axis vis3d;  
end

if false % show the sphere.
    figure();
    patch('Vertices', sph, 'Faces', f, 'FaceColor', [0.9 0.9 0.9]);
    axis equal;
    axis off;
    axis vis3d;  
end

% Write output obj file if 2nd filename was given as argument.
if (nargin == 2) 
    outfile = fopen(outobj, 'w');
    fprintf(outfile, '[', numvertices);
    for n = 1:numvertices
        fprintf(outfile, '[%.15f,%.15f,%.15f],\n', sph(n, 1), sph(n, 2), sph(n,3));
    end
    fprintf(outfile, 'fail];\n');
    fclose(outfile);
end

end % of function layout