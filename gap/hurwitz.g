#############################################################################
##
#W hurwitz.g                                                Laurent Bartholdi
##
#Y Copyright (C) 2011-2012, Laurent Bartholdi
##
#############################################################################
##
##  Solving the Hurwitz problem
##
#############################################################################

BindGlobal("LIFTBYMONODROMY@", function(spider,monodromy,d)
    # create a new triangulation lifted by the given monodromy rep'n.
    # the positions in the triangulation are the same as in the original
    # spider; i.e., geometrically one takes deg(monodromy) copies of the
    # original sphere, cuts it along the minimal spanning tree, and glues
    # the sheets to each other along the monodromy rep'n.
    #
    # some vertices of the result acquire extra fields, "degree", which is
    # the local degree of the map, and "cover", which points to the vertex
    # of "spider" that is being covered.

    local e, f, v, i, j, edgeperm, reverse,
          edges, faces, lift;
    
    # make d copies of the faces and edges, renumber their indices
    faces := [];
    edges := List([1..d],i->StructuralCopy(spider!.cut!.e));
    for i in [1..d] do
        faces[i] := [];
        for e in edges[i] do
            e.index := e.index + (i-1)*Length(spider!.cut!.e);
            j := e.left.index;
            if j<=Length(spider!.cut!.f) and not IsBound(faces[i][j]) then
                faces[i][j] := e.left;
                e.left.index := j + (i-1)*Length(spider!.cut!.f);
            fi;
        od;
    od;
    
    # reattach the edges according to the monodromy action
    reverse := List(edges[1],e->e.reverse.index);
    edgeperm := List(edges[1],e->PreImagesRepresentative(spider!.marking,e.gpelement)^monodromy);
    for i in [1..d] do
        for j in [1..Length(edges[i])] do
            edges[i][j].reverse := edges[i^edgeperm[j]][reverse[j]];
            edges[i][j].right := edges[i][j].reverse.left;
        od;
    od;

    # create the triangulation, except for the vertices
    lift := rec(v := [],
                e := Concatenation(edges),
                f := Concatenation(faces));

    # create new vertices, attach the edges to them
    for e in lift.e do
        if e.from.type='v' then # old vertex, replace it simply
            v := rec(type := 'w',
                     n := [],
                     pos := e.from.pos, # keep old positions for a moment
                     degree := 1/Length(e.from.n),
                     #!TODO
                     # we'd like to keep track of the cycle corresponding
                     # to v, not just its length; for this, we have to
                     # consider the first edge (in the boundarytree of spider)
                     # that starts at v, and keep track of the sheets
                     # above that edge. Since we subdivided spider, we lost
                     # the relation between spider's boundarytree and what
                     # we cover.
                     cover := spider!.cut!.v[e.from.index],
                     index := Length(lift.v)+1,
                     operations := edges[1][1].operations);
            Add(lift.v,v);
            if IsBound(e.from.fake) then
                v.fake := true;
            fi;
            repeat
                e.from := v;
                Add(v.n,e);
                i := POSITIONID@(e.left.n,e)-1;
                if i=0 then i := Length(e.left.n); fi;
                e := e.left.n[i].reverse;
            until IsIdenticalObj(e,v.n[1]);
            v.degree := v.degree * Length(v.n);
        fi;
    od;

    for v in lift.v do
        v.type := 'v';
    od;
    
    # correct to pointers
    for e in lift.e do
        e.to := e.reverse.from;
    od;
    
    return Objectify(TYPE_TRIANGULATION,lift);
end);

BindGlobal("REFINETRIANGULATION@", function(triangulation,maxlen)
    # refines triangulation by adding circumcenters, until
    # the length of every edge (say connecting v to w) is at most
    # maxlen^Maximum(v.degree*w.degree)
    local idle, e, f, maxdegree, len, mult, p;

    for e in triangulation!.e do
        if e.from.degree>1 and e.to.degree>1 then
            ADDTOTRIANGULATION@(triangulation,e.left,P1Midpoint(e.from.pos,e.to.pos));
            triangulation!.v[Length(triangulation!.v)].degree := 1;
            triangulation!.v[Length(triangulation!.v)].fake := true;
        fi;
    od;
    
    maxdegree := Maximum(List(triangulation!.v,v->v.degree));
    mult := Int(Log(7./maxlen)/Log(1.5));
    repeat
        len := List([1..maxdegree],i->(maxlen*1.5^mult)^i);
        idle := true;
        for e in triangulation!.e do
            if P1Distance(e.from.pos,e.to.pos) > len[Maximum(e.from.degree,e.to.degree)] then
                idle := false;
                f := e.left;
                if not IsBound(f.radius) then
                    p := CallFuncList(P1Circumcentre,List(f.n,e->e.from.pos));
                    f.centre := p[1];
                    f.radius := p[2];
                fi;
                ADDTOTRIANGULATION@(triangulation,f,f.centre);
                triangulation!.v[Length(triangulation!.v)].degree := 1;
                triangulation!.v[Length(triangulation!.v)].fake := true;
            fi;
        od;
        if idle then mult := mult-1; fi;
    until idle and mult<0;
    
    # that's a waste of time, we won't use these values
    for e in triangulation!.e do
        if not IsBound(e.pos) then
            e.pos := P1Barycentre(e.from.pos,e.to.pos);
            e.map := EDGEMAP@(e);
        fi;
    od;
    for f in triangulation!.f do
        if not IsBound(f.pos) then
            f.pos := P1Barycentre(List(f.n,e->e.to.pos));
        fi;
    od;
end);

nodup := function(tri)
    local l;
    l := List(tri!.e,x->[x.from.index,x.to.index]);
    l := Filtered(Collected(l),x->x[2]>1);
    if l<>[] then
        Error(l);
    fi;
end;

BindGlobal("LAYOUTTRIANGULATION@", function(triangulation)
    # run C code to optimize point placement.
    # "triangulation" is topologically a triangulated sphere. Its edge
    # lengths should be adjusted, by multiplying each edge (say from v to w)
    # by u[v]*u[w] for some scaling function u defined on the vertices;
    # in such a way that the resulting metric object is a conformal sphere.
    local i, e, f, v, m, max, infty, sin, sout, stdin, stdout;

    sin := "";
    stdin := OutputTextString(sin,false);
    
    max := 0;
    for v in triangulation!.v do
        m := Length(v.n);
        if m>max then
            infty := v.index;
            max := m;
        fi;
    od;
    PrintTo(stdin,"VERTICES ",Length(triangulation!.v),"\n",infty,"\n");
    
    PrintTo(stdin,"FACES ",Length(triangulation!.f),"\n");
    for f in triangulation!.f do
        for e in f.n do
            PrintTo(stdin,e.from.index," ");
        od;
        for e in f.n{[2,3,1]} do
            PrintTo(stdin,P1Distance(e.from.pos,e.to.pos)," ");
        od;
        PrintTo(stdin,"\n");
    od;
    PrintTo(stdin,"END\n");
    CloseStream(stdin);
PrintTo("data-layout",sin);    
    stdin := InputTextString(sin);
    sout := "";
    stdout := OutputTextString(sout,false);
    Process(DirectoryCurrent(),Filename(DirectoriesPackagePrograms("img"),"layout"),stdin,stdout,[]);
    CloseStream(stdin);
    CloseStream(stdout);
PrintTo("result-layout",sout);    
    m := EvalString(sout);
    Remove(m); # there's a trailing "fail" in the file, to simplify printing
    m := 1.0*m; # make sure all entries are floats
    
    v := List(m,P1Sphere);
    m := NORMALIZINGMAP@(v,fail);
    v := List(v,v->P1Image(m,v));
    
    for i in [1..Length(v)] do
        triangulation!.v[i].pos := v[i];
    od;
    for e in triangulation!.e do
        e.pos := P1Midpoint(e.from.pos,e.to.pos);
    od;
    for f in triangulation!.f do
        f.pos := P1Barycentre(List(f.n,x->x.from.pos));
        i := CallFuncList(P1Circumcentre,List(f.n,e->e.from.pos));
        f.centre := i[1];
        f.radius := i[2];
    od;
end);

BindGlobal("OPTIMIZELAYOUT@", function(spider,lift)
    # "lift" is an approximate lift of "spider". refine its positions.
    
    # find Möbius transformation putting the most ramified c.v. at 0,infty,
    # and the next most ramified c.v. at 1;
    # and find another Möbius transformation so that 0,infty,1 are fixed,
    # all of maximal order.
    local cp, max, l0, l1, linf, pre, post, x, y, numzero, numcv,
          sin, sout, stdin, stdout, data, cv, i, printp1, scanp1;
    
    printp1 := function(stream,z)
        z := P1Coordinate(z);
        PrintTo(stream,"(", RealPart(z),",",ImaginaryPart(z),")");
    end;

    scanp1 := function(str)
        str := SplitString(str{[2..Length(str)-1]},",");
        return STRINGS2P1POINT(str[1],str[2]);
    end;
    
    sin := "";
    stdin := OutputTextString(sin,false);

    cp := Filtered(lift!.v,x->IsBound(x.degree) and IsBound(x.cover));
    max := Maximum(List(cp,x->x.degree));
    linf := First(cp,x->x.degree=max);
    max := Maximum(List(Filtered(cp,x->x.cover<>linf.cover),x->x.degree));
    l0 := First(cp,x->x.cover<>linf.cover and x.degree=max);
    max := Maximum(List(Filtered(cp,x->x.cover<>linf.cover and x.cover<>l0.cover),x->x.degree));
    l1 := First(cp,x->x.cover<>linf.cover and x.cover<>l0.cover and x.degree=max);
    
    post := InverseP1Map(MoebiusMap(List([l0,l1,linf],x->x.cover.pos)));
    pre := InverseP1Map(MoebiusMap(List([l0,l1,linf],x->x.pos)));
    
    PrintTo(stdin,"DEGREE ",(Sum(cp,x->x.degree-1)+2)/2,"\n");
    numzero := Number(cp,x->x.cover=l0.cover or x.cover=linf.cover)-2;
    PrintTo(stdin,"ZEROS/POLES ",numzero,"\n");
    for x in cp do
        if (x.cover=l0.cover or x.cover=linf.cover) and x<>l0 and x<>linf then
            if x.cover=l0.cover then
                PrintTo(stdin,x.degree); # zero
            else
                PrintTo(stdin,-x.degree); # pole
            fi;
            PrintTo(stdin," "); printp1(stdin,x.pos^pre); PrintTo(stdin,"\n");
        fi;
    od;
    PrintTo(stdin,l0.degree,"\n");
    numcv := Number(cp,x->x.cover<>l0.cover and x.cover<>linf.cover and x.degree>1)-1;
    cv := [];
    PrintTo(stdin,"CRITICAL ",numcv,"\n");
    for x in cp do
        if x.cover<>l0.cover and x.cover<>linf.cover and x.degree>1 and x<>l1 then
            PrintTo(stdin,x.degree);
            PrintTo(stdin," "); printp1(stdin,x.pos^pre);
            PrintTo(stdin," "); printp1(stdin,x.cover.pos^post);
            PrintTo(stdin,"\n");
            Add(cv,x.cover);
        fi;
    od;
    Add(cv,l1.cover);
    PrintTo(stdin,l1.degree,"\n");
    PrintTo(stdin,"END\n");
    CloseStream(stdin);
    
    stdin := InputTextString(sin);
    sout := "";
    stdout := OutputTextString(sout,false);
    
    Process(DirectoryCurrent(),Filename(DirectoriesPackagePrograms("img"),"hsolve"),stdin,stdout,[]);
    CloseStream(stdin);
    CloseStream(stdout);
    
    sout := SplitString(sout,WHITESPACE);
    Assert(0,sout[1]="DEGREE" and Int(sout[2])=(Sum(cp,x->x.degree-1)+2)/2);
    data := rec(degree := Int(sout[2]),
                zeros := [],
                poles := [],
                cp := [],
                post := post);
    Assert(0,sout[3]="ZEROS/POLES" and numzero=Int(sout[4]));
    for i in [0..numzero] do
        x := Int(sout[5+2*i]);
        if i=numzero then
            y := P1zero;
        else
            y := scanp1(sout[6+2*i]);
        fi;
        if x>0 then
            Add(data.zeros,rec(degree := x, pos := y, to := l0.cover));
        else
            Add(data.poles,rec(degree := -x, pos := y, to := linf.cover));
        fi;
    od;
    Assert(0,sout[2*numzero+6]="CRITICAL" and Int(sout[2*numzero+7])=numcv);
    for i in [0..numcv] do
        x := Int(sout[2*numzero+8+3*i]);
        if i=numcv then
            y := P1one;
        else
            y := scanp1(sout[2*numzero+9+3*i]);
        fi;
        Add(data.cp,rec(degree := x, pos := y, to := cv[i+1]));
    od;
    if numcv >= 0 then
        Assert(0,sout[2*numzero+3*numcv+9]="END");
    fi;
    Add(data.poles,rec(degree := 2*data.degree-1-Sum(Concatenation(data.cp,data.zeros,data.poles),x->x.degree-1), pos := P1infinity, to := linf.cover));
    
    return data;
end);

InstallMethod(HurwitzMap, "(FR) for a spider and a homomorphism",
        [IsMarkedSphere,IsGroupHomomorphism],
        function(spider,monodromy)
    # compute the critical points, zeros and poles of a map whose
    # critical values are vertices of "spider", with monodromy given
    # by the homomorphism "monodromy".
    local t, d;

    Assert(0,Source(spider!.marking)=Source(monodromy));
    
    d := Maximum(LargestMovedPoint(Range(monodromy)),1);
    Assert(0,IsTransitive(Image(monodromy),[1..d]));
    Assert(0,SPIDERRELATOR@(spider)^monodromy=());

    t := LIFTBYMONODROMY@(spider,monodromy,d);
    REFINETRIANGULATION@(t,0.3);
    LAYOUTTRIANGULATION@(t);
    d := OPTIMIZELAYOUT@(spider,t);
    
    d.map := P1MapByZerosPoles(Concatenation(List(d.zeros,x->ListWithIdenticalEntries(x.degree,x.pos))),
                     Concatenation(List(d.poles,x->ListWithIdenticalEntries(x.degree,x.pos))),
                     
                     P1one,P1one);

    return d;
end);

InstallMethod(DessinByPermutations, "(FR) for three permutations",
        [IsPerm,IsPerm,IsPerm],
        function(s0,s1,sinf)
    local permrep, f, g, spider, d, i, above1, p, dist, distmin;
    
    Assert(0,s0*s1*sinf=());
    f := FreeGroup(3);
    g := Group(s0,s1,sinf);
    
    spider := TRIVIALSPIDER@([P1zero,P1one,P1infinity]);
    IMGMARKING@(spider,f);
    permrep := GroupHomomorphismByImages(f,g,GeneratorsOfGroup(f),GeneratorsOfGroup(g));
    
    d := HurwitzMap(spider,permrep);
    
    for i in d.zeros do Unbind(i.to); od;
    for i in d.poles do Unbind(i.to); od;
    d.above1 := [];
    for i in d.cp do Add(d.above1,rec(degree := i.degree, pos := i.pos)); od;
    above1 := P1PreImages(d.map,P1PreImages(d.post,P1one)[1]);
    
    for p in Concatenation(List(d.cp,x->ListWithIdenticalEntries(x.degree,x.pos))) do
        dist := List(above1,q->P1Distance(p,q));
        distmin := Minimum(dist);
        i := Position(dist,distmin);
        Remove(above1,i);
    od;
    for p in above1 do
        Add(d.above1, rec(degree := 1, pos := p));
    od;
    
    Unbind(d.cp);
    
    return d;
end);

InstallMethod(DessinByPermutations, "(FR) for two permutations",
        [IsPerm,IsPerm],
        function(s0,s1)
    return DessinByPermutations(s0,s1,(s0*s1)^-1);
end);
    
#E hurwitz.g . . . . . . . . . . . . . . . . . . . . . . . . . . . .ends here
