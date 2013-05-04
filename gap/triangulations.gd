#############################################################################
##
#W triangulations.gd                                        Laurent Bartholdi
##
#Y Copyright (C) 2013, Laurent Bartholdi
##
#############################################################################
##
##  Declarations for triangulations
##
#############################################################################

DeclareCategory("IsSphereTriangulation", IsObject);
BindGlobal("TRIANGULATION_FAMILY",
        NewFamily("SphereTriangulations", IsSphereTriangulation));
BindGlobal("TYPE_TRIANGULATION",
        NewType(TRIANGULATION_FAMILY, IsSphereTriangulation));

DeclareRepresentation("IsTriangulationObjectRep",
        IsComponentObjectRep and IsAttributeStoringRep,[]);
DeclareCategory("IsTriangulationObject",IsTriangulationObjectRep);
DeclareCategory("IsTriangulationVertex",IsTriangulationObject);
DeclareCategory("IsTriangulationEdge",IsTriangulationObject);
DeclareCategory("IsTriangulationFace",IsTriangulationObject);
BindGlobal("TRIANGULATIONOBJECT_FAMILY",
        NewFamily("TriangulationFamily",IsTriangulationObject,CanEasilySortElements,CanEasilySortElements));
BindGlobal("TYPE_VERTEX",
        NewType(TRIANGULATIONOBJECT_FAMILY,IsTriangulationVertex));
BindGlobal("TYPE_EDGE",
        NewType(TRIANGULATIONOBJECT_FAMILY,IsTriangulationEdge));
BindGlobal("TYPE_FACE",
        NewType(TRIANGULATIONOBJECT_FAMILY,IsTriangulationFace));

#############################################################################
##
## <#GAPDoc Label="Triangulations">
## <ManSection>
##   <Oper Name="DelaunayTriangulation" Arg="points, [quality]"/>
DeclareOperation("DelaunayTriangulation", [IsList]);
DeclareOperation("DelaunayTriangulation", [IsList, IsFloat]);
##   <Returns>A Delaunay triangulation of the sphere.</Returns>
##   <Description>
##     If <A>points</A> is a list of points on the unit sphere, represented
##     by their 3D coordinates, this function creates a triangulation of
##     the sphere with these points as vertices. This triangulation is
##     such that the angles are as equilateral as possible.
##
##     <P/> This triangulation is a collection of vertices, edges and faces.
##     These are new GAP objects. The attributes for vertices are: <List>
##     <Mark><C>Neighbour</C></Mark> <Item>any edge starting at the vertex</Item>
DeclareAttribute("Neighbour", IsTriangulationVertex);
##     <Mark><C>Neighbours</C></Mark> <Item>a list of neighbours, in counterclockwise order (an optional adugument lets one specify the starting edge)</Item>
DeclareOperation("Neighbours", [IsTriangulationVertex]);
DeclareOperation("Neighbours", [IsTriangulationVertex,IsTriangulationEdge]);
##     <Mark><C>Valency</C></Mark> <Item>the number of neighbours</Item>
DeclareOperation("Valency", [IsTriangulationVertex]);
##     <Mark><C>Pos</C></Mark> <Item>The P1 point where the vertex is located</Item>
DeclareAttribute("Pos", IsTriangulationVertex);
##     <Mark><C>ClosestVertices</C></Mark> <Item>A list containing the vertex itself</Item>
##     <Mark><C>ClosestFaces</C></Mark> <Item>The faces that contain the point</Item>
DeclareOperation("ClosestFaces", [IsTriangulationObject]);
DeclareOperation("ClosestVertices", [IsTriangulationObject]);
##     <Mark><C>IsFake</C></Mark> <Item>whether the vertex was added for refinement</Item>
DeclareProperty("IsFake", IsTriangulationVertex);
##     </List>
##
##     <P/> The edges come in opposite pairs, and are thought of as having a face on their left.
##     Their possible attributes are: <List>
##     <Mark><C>Left</C>, <C>Right</C></Mark> <Item>The adjacent faces</Item>
DeclareAttribute("Left", IsTriangulationEdge);
DeclareAttribute("Right", IsTriangulationEdge);
##     <Mark><C>To</C>, <C>From</C></Mark> <Item>The vertices that the edge goes to/from</Item>
DeclareAttribute("To", IsTriangulationEdge);
DeclareAttribute("From", IsTriangulationEdge);
##     <Mark><C>Next</C></Mark> <Item>The edge after on the left face (starting where the present edge ends)</Item>
DeclareAttribute("Next", IsTriangulationEdge);
##     <Mark><C>Prevopp</C></Mark> <Item>The opposite of the edge before on the left face (starting where the present edge starts)</Item>
DeclareAttribute("Prevopp", IsTriangulationEdge);
##     <Mark><C>Opposite</C></Mark> <Item>The opposite edge (with reversed orientation)</Item>
DeclareAttribute("Opposite", IsTriangulationEdge);
##     <Mark><C>Pos</C></Mark> <Item>The position of the midpoint. <C>FromPos</C> and <C>ToPos</C> are shortcuts</Item>
DeclareAttribute("Pos", IsTriangulationEdge);
DeclareAttribute("FromPos", IsTriangulationEdge);
DeclareAttribute("ToPos", IsTriangulationEdge);
##     <Mark><C>Length</C></Mark>
DeclareAttribute("Length", IsTriangulationEdge);
##     <Mark><C>Map</C></Mark> <Item>A P1 map sending <M>[0,1]</M> to the edge</Item>
DeclareAttribute("Map", IsTriangulationEdge);
##     <Mark><C>GroupElement</C></Mark> <Item>A group element describing "crossing through the edge
##       from the left to the right"</Item>
DeclareAttribute("GroupElement", IsTriangulationEdge, "mutable");
##     <Mark><C>ClosestVertices</C></Mark> <Item>The two endpoints</Item>
##     <Mark><C>ClosestFaces</C></Mark> <Item>The two adjacent faces</Item>
##     </List>
##
##     <P/> The faces have the following possible attributes: <List>
##     <Mark><C>Neighbour</C></Mark> <Item>Some edge with this face on its left</Item>
DeclareAttribute("Neighbour", IsTriangulationFace);
##     <Mark><C>Neighbours</C></Mark> <Item>The neighbours of the face, in counterclockwise order around the face (an optional argument lets one specify the starting edge)</Item>
DeclareOperation("Neighbours", [IsTriangulationFace]);
DeclareOperation("Neighbours", [IsTriangulationFace,IsTriangulationEdge]);
##     <Mark><C>Pos</C></Mark> <Item>The position of the face's barycentre</Item>
DeclareAttribute("Pos", IsTriangulationFace);
##     <Mark><C>Radius</C>, <C>Centre</C></Mark> <Item>The circumradius and circumcentre of the face (assumed to be a triangle)</Item>
DeclareAttribute("Radius", IsTriangulationFace);
DeclareAttribute("Centre", IsTriangulationFace);
##     <Mark><C>Valency</C></Mark> <Item>The number of neighbouring edges</Item>
DeclareOperation("Valency", [IsTriangulationFace]);
##     <Mark><C>ClosestVertices</C></Mark> <Item>The vertices that the face contains</Item>
##     <Mark><C>ClosestFaces</C></Mark> <Item>A list containing the face itself</Item>
##     </List>
##
##     <P/> If all points are aligned on a great circle, or if all points
##     are in a hemisphere, some points are added so as to make the
##     triangulation simplicial with all edges of length <M>&lt;\pi</M>.
##     These vertices additionally have the <C>IsFake</C> property set to
##     <K>true</K>.
##
DeclareOperation("Draw", [IsSphereTriangulation]);
##     <P/> A triangulation may be plotted with <C>Draw</C>; this requires
##     <Package>appletviewer</Package> to be installed. The command
##     <C>Draw(t:detach)</C> detaches the subprocess after it is started.
##     The extra arguments <C>Draw(t:lower)</C> or <C>Draw(t:upper)</C>
##     stretch the triangulation to the lower, respectively upper, hemisphere.
##
##     <P/> If the second argument <A>quality</A>, which must be a floatean,
##     is present, then all triangles in the resulting triangulation are
##     guaranteed to have circumcircle ratio / minimal edge length at most
##     <A>quality</A>. Of course, additional vertices may need to be added
##     to ensure that.
## <Example><![CDATA[
## gap> octagon := Concatenation(IdentityMat(3),-IdentityMat(3))*1.0;;
## gap> dt := DelaunayTriangulation(octagon);
## <triangulation with 6 vertices, 24 edges and 8 faces>
## gap> dt!.v;
## [ <vertex 1>, <vertex 2>, <vertex 3>, <vertex 4>, <vertex 5>, <vertex 6> ]
## gap> last[1].n;
## [ <edge 17>, <edge 1>, <edge 2>, <edge 11> ]
## gap> last[1].from;
## <vertex 1>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="AddToTriangulation" Arg="t[,seed],point[,delaunay]"/>
DeclareOperation("AddToTriangulation", [IsSphereTriangulation,IsP1Point]);
DeclareOperation("AddToTriangulation", [IsSphereTriangulation,IsP1Point,IsBool]);
DeclareOperation("AddToTriangulation", [IsSphereTriangulation,IsTriangulationFace,IsP1Point]);
DeclareOperation("AddToTriangulation", [IsSphereTriangulation,IsTriangulationFace,IsP1Point,IsBool]);
##   <Description>
##     This command adds the P1 point <A>point</A> to the triangulation
##     <A>t</A>. If a face <A>seed</A> is provided, it will speed up the
##     search for the triangle in which the point is to be added. The other
##     optional boolean argument <A>delaunay</A> specifies whether the
##     Delaunay condition is to be fulfilled (by flipping diagonals of
##     some quadrilaterals made of two neighbouring triangles) after the
##     addition.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="RemoveFromTriangulation" Arg="t,vertex"/>
DeclareOperation("RemoveFromTriangulation", [IsSphereTriangulation,IsTriangulationVertex]);
##   <Description>
##     This command removes the vertex <A>vertex<A> from the triangulation <A>t</A>.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="LocateInTriangulation" Arg="t,[seed,]point"/>
DeclareOperation("LocateInTriangulation", [IsSphereTriangulation,IsP1Point]);
DeclareOperation("LocateInTriangulation", [IsSphereTriangulation,IsObject,IsP1Point]);
##   <Returns>The face in <A>t</A> containing <A>point</A>.</Returns>
##   <Description>
##     This command locates the face in <A>t</A> that contains <A>point</A>;
##     or, if <A>point</A> lies on an edge or a vertex, it returns that
##     edge or vertex.
##
##     <P/> The optional second argument specifies a starting vertex,
##     edge, face, or vertex index from which to start the search. Its only
##     effect is to speed up the algorithm.
## <Example><![CDATA[
## gap> cube := Tuples([-1,1],3)/Sqrt(3.0);;
## gap> dt := DelaunayTriangulation(cube);
## <triangulation with 8 vertices, 36 edges and 12 faces>
## gap> LocateInTriangulation(dt,dt!.v[1].pos);
## <vertex 1>
## gap> LocateInTriangulation(dt,[3/5,0,4/5]*1.0);
## <face 9>
## ]]></Example>
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Oper Name="WiggledTriangulation" Arg="t,moebiusmap"/>
##   <Oper Name="WiggledTriangulation" Arg="t,newpoints"/>
DeclareOperation("WiggledTriangulation", [IsSphereTriangulation,IsObject]);
##   <Returns>A new triangulation, with moved vertices.</Returns>
##   <Description>
##     This command creates a new triangulation, in which only the
##     P1 coordinates are changed. If the second argument <A>moebiusmap</A>
##     is a Möbius transformation, then it is applied to the vertices
##     and barycentres of faces and edges. If the second argument <A>newpoints</A>
##     is a list of P1 points, then they are taken as new coordinates of
##     the vertices.
##   </Description>
## </ManSection>
##
## <ManSection>
##   <Func Name="EquidistributedP1Points" Arg="N"/>
DeclareGlobalFunction("EquidistributedP1Points");
##   <Returns>A list of <A>N</A> P1 points that are reasonably well spaced.</Returns>
## </ManSection>
## <#/GAPDoc>
##
#############################################################################

#E triangulations.gd . . . . . . . . . . . . . . . . . . . . . . . .ends here