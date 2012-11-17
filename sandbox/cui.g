algrel := function(x,d,n)
    local p, q, i;
    
    x := Rat(x); p := NumeratorRat(x); q := DenominatorRat(x);
    x := IdentityMat(n+1);
    for i in [0..n] do Add(x[i+1],p^i*q^(n-i)); od;
    return LLLReducedBasis(x).basis[1];
end;

soln := 3; # any in [1..6]
perm := [1,1,1]; # any in [[1..3],[1..3],[1..3]]
perm := [2,2,1]; # correct

#soln := 3;
#perm := [3,3,3]; # causes bug
#perm := [2,2,2]; # causes bug
#perm := [1,1,1]; # causes bug
#perm := [1,1,2]; # infinite loop

# ai are preimages of infinity, bi of 1, ci of 0. 
# a1=infty, b1=1, c1=0.
if soln=1 then
a2 := P1Point("+0.149750988166109653860411466689","-0.806809742242423799079921506905");
a3 := P1Point("0.499046641161429957841320419874","0.604078889442426705726508431979");
a4 := P1Point("0.485185122197580682846591564615","-0.288756708580057944346680022170");
a5 := P1Point("1.02735045844322366967871049207","-0.692627699569478869878285069882");
b2 := P1Point("+0.777608767128922641778045840101","-1.19817181487083654346423971979");
b3 := P1Point("0.187165984623895974976914288641","0.983907772962233247454385420743");
b4 := P1Point("-0.521982094516188118463771013047","-0.905803826258522000508937519103");
b5 := P1Point("0.330795700388161565609750941806","-0.451169735481037621170010809820");
c2 := P1Point("0.618873615669910693043298745446","-0.587255328015395889389933046733");
c3 := P1Point("0.813413480615653046025694010969","0.980861597908046008477706710065");
c4 := P1Point("-0.0569230590241632245485745470127","-1.44152930767901324517825995119");
c5 := P1Point("1.47759189609289752374789539543","-0.828772809289520118635469676643");
l := P1Point("-0.307892404507534353810254412579","-6.01529170441421636804484163487");
elif soln=2 then    
a2 := P1Point("0.149750988166109653860411466689","0.806809742242423799079921506905");
a3 := P1Point("0.485185122197580682846591564615","0.288756708580057944346680022170");
a4 := P1Point("1.02735045844322366967871049207","0.692627699569478869878285069882");
a5 := P1Point("0.499046641161429957841320419874","-0.604078889442426705726508431979");
b2 := P1Point("0.777608767128922641778045840101","1.19817181487083654346423971979");
b3 := P1Point("0.330795700388161565609750941806","0.451169735481037621170010809820");
b4 := P1Point("-0.521982094516188118463771013047","0.905803826258522000508937519103");
b5 := P1Point("0.187165984623895974976914288641","-0.983907772962233247454385420743");
c2 := P1Point("0.618873615669910693043298745446","0.587255328015395889389933046733");
c3 := P1Point("1.47759189609289752374789539543","0.828772809289520118635469676643");
c4 := P1Point("-0.0569230590241632245485745470127","1.44152930767901324517825995119");
c5 := P1Point("0.813413480615653046025694010969","-0.980861597908046008477706710065");
l  := P1Point("-0.307892404507534353810254412579","6.01529170441421636804484163487");
elif soln=3 then
a2 := P1Point("0.500000000000000000000000000000","-0.439846359796987134487167714627");
a3 := P1Point("1.61268567872451072013417667720","-0.490182463946729812334860743821");
a4 := P1Point("0.500000000000000000000000000000","-0.0415300696430258467988035191529");
a5 := P1Point("-0.612685678724510720134176677204","-0.490182463946729812334860743821");
b2 := P1Point("-0.127485151459011948734747094655","-0.991840479188802206853242764751");
b3 := P1Point("0.432359588377624320446470035702","-0.172536644477962176299255320022");
b4 := P1Point("-0.986296566330715829847015755165","-0.164982069462835473582606346591");
b5 := P1Point("1.99516470514160943250266636145","-0.796186860797306011242450678339");
c2 := P1Point("1.12748515145901194873474709466","-0.991840479188802206853242764751");
c3 := P1Point("-0.995164705141609432502666361446","-0.796186860797306011242450678339");
c4 := P1Point("1.98629656633071582984701575517","-0.164982069462835473582606346591");
c5 := P1Point("0.567640411622375679553529964298","-0.172536644477962176299255320022");
l  := P1Point("0","7.69070477812435423714369570274");
elif soln=4 then
a2 := P1Point("0.500000000000000000000000000000","0.439846359796987134487167714627");
a3 := P1Point("1.61268567872451072013417667720","0.490182463946729812334860743821");
a4 := P1Point("0.500000000000000000000000000000","0.0415300696430258467988035191529");
a5 := P1Point("-0.612685678724510720134176677204","0.490182463946729812334860743821");
b2 := P1Point("-0.127485151459011948734747094655","0.991840479188802206853242764751");
b3 := P1Point("0.432359588377624320446470035702","0.172536644477962176299255320022");
b4 := P1Point("-0.986296566330715829847015755165","0.164982069462835473582606346591");
b5 := P1Point("1.99516470514160943250266636145","0.796186860797306011242450678339");
c2 := P1Point("1.12748515145901194873474709466","0.991840479188802206853242764751");
c3 := P1Point("1.98629656633071582984701575517","0.164982069462835473582606346591");
c4 := P1Point("0.567640411622375679553529964298","0.172536644477962176299255320022");
c5 := P1Point("-0.995164705141609432502666361446","0.796186860797306011242450678339");
l  := P1Point("-7.69070477812435423714369570274","0");
elif soln=5 then
a2 := P1Point("0.850249011833890346139588533311","-0.806809742242423799079921506905");
a3 := P1Point("0.500953358838570042158679580125","0.604078889442426705726508431980");
a4 := P1Point("-0.0273504584432236696787104920724","-0.692627699569478869878285069885");
a5 := P1Point("0.514814877802419317153408435385","-0.288756708580057944346680022169");
b2 := P1Point("0.381126384330089306956701254554","-0.587255328015395889389933046733");
b3 := P1Point("0.186586519384346953974305989030","0.980861597908046008477706710065");
b4 := P1Point("-0.477591896092897523747895395425","-0.828772809289520118635469676642");
b5 := P1Point("1.05692305902416322454857454701","-1.44152930767901324517825995119");
c2 := P1Point("0.222391232871077358221954159899","-1.19817181487083654346423971979");
c3 := P1Point("0.812834015376104025023085711358","0.983907772962233247454385420741");
c4 := P1Point("0.669204299611838434390249058194","-0.451169735481037621170010809822");
c5 := P1Point("1.52198209451618811846377101305","-0.905803826258522000508937519100");
l  := P1Point("0.307892404507534353810254412579","-6.01529170441421636804484163487");
elif soln=6 then
a2 := P1Point("0.850249011833890346139588533311","0.806809742242423799079921506905");
a3 := P1Point("0.514814877802419317153408435385","0.288756708580057944346680022169");
a4 := P1Point("-0.0273504584432236696787104920724","0.692627699569478869878285069885");
a5 := P1Point("0.500953358838570042158679580125","-0.604078889442426705726508431980");
b2 := P1Point("0.381126384330089306956701254554","0.587255328015395889389933046733");
b3 := P1Point("-0.477591896092897523747895395425","0.828772809289520118635469676642");
b4 := P1Point("1.05692305902416322454857454701","1.44152930767901324517825995119");
b5 := P1Point("0.186586519384346953974305989030","-0.980861597908046008477706710065");
c2 := P1Point("0.222391232871077358221954159899","1.19817181487083654346423971979");
c3 := P1Point("0.669204299611838434390249058194","0.451169735481037621170010809822");
c4 := P1Point("1.52198209451618811846377101305","0.905803826258522000508937519100");
c5 := P1Point("0.812834015376104025023085711358","-0.983907772962233247454385420741");
l  := P1Point("0.307892404507534353810254412579","6.01529170441421636804484163487");
else
Error("Specify soln; 3 is the correct one");    
fi;
pre := MoebiusMap(ValueGlobal(Concatenation("a",String(perm[1]+2))),
               ValueGlobal(Concatenation("b",String(perm[2]+2))),
               ValueGlobal(Concatenation("c",String(perm[3]+2))),
               P1infinity,P1one,P1zero);

z := P1z;
#s := (b3-c3)*z+(a3-b3);
#t := a3*(b3-c3)*z+(a3-b3)*c3;

zeros := List([P1Point(0),c2,c3,c4,c5],x->P1Image(pre,x));
poles := List([P1infinity,a2,a3,a4,a5],x->P1Image(pre,x));

f := P1MapByZerosPoles(zeros{[1,1,1,1,2,2,2,3,3,4,4,5,5]},poles{[1,1,1,1,2,2,2,3,3,4,4,5,5]},P1one,P1one);
@FR.p1eps := 1.e-4_l;
fmap := f;
m := IMGMachine(f);
perms := List([1..3],i->PermList(Output(m,i)));
goal := [(1,3,12,4)(5,9)(6,7)(10,13,11)(2,8),
         (1,5,13,6)(7,10)(2,3)(8,11,12)(4,9),
         (1,7,11,2)(3,8)(4,5)(9,12,13)(6,10)];
change := RepresentativeAction(SymmetricGroup(13),perms,goal,OnTuples);
if change=fail then
    Print("fail\n");
else
    Print("success\n");
    newm := ChangeFRMachineBasis(m,change);
fi;