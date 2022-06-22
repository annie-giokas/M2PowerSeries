--*******************************************************
--Implementation of P-ADICS
--*******************************************************


padicOrder = method() -- Works with ZZ elements and RingElements of polynomial rings
padicOrder(ZZ, Thing) := ZZ => (p, f) ->(
    if (f==0) then return -infinity;
    p = sub(p,ring f);
    i := 0;
    tempf := sub(0,ring f);
    while(tempf == 0) do (
        i = i+1;
        tempf = f % ideal (p^i);
    );
    return i-1;

);



Padics = new Type of HashTable; -- Could potentially change it to HashTable since so far have not used inheritence

toString Padics := L -> (
    myStr := net("");

    local tempStr;
    local k;
    local tempTerm;
    local stringList; 

    p := L.primeNumber;

    valueList := sort pairs L.cache.valueList; -- turns the hashtable into a list of pairs (key, value) and then sortrs by key

    scan(valueList, (key, val)->(
        if(val != 0) then (
            k = padicOrder(p, key);

            try tempTerm = toString((entries monomials(key))#0#0)
                else tempTerm = "";
            if(tempTerm == "1" ) then tempTerm = "";

            if (val < 0) then val = " - " | toString(abs(val))
            else val = " + " | toString(val);

            if (k == 0) then (
                if (tempTerm != "") then tempStr = val | "*" | tempTerm
                else tempStr = toString(val)
            )
            else if(k == 1) then (
                tempStr = val | "*" | toString(p) | tempTerm
                )
            else if(k > 1) then (
                tempStr = val | "*" |toString(p) | "^" | toString(k) | tempTerm;
                );
            myStr = myStr | tempStr
            );
        
        )
    );
    myStr = toString(myStr);
    if (myStr#1 == "+") then myStr = substring(3, myStr);
    toString(myStr | toString(" + ... "))

); 

net Padics := L -> ( net(toString L));

----------------------PADICS CONSTRUCTORS-----------------------------------------------------------------

padics = method(Options => { Degree => infinity, DisplayedDegree => 5, ComputedDegree => 5})

-- Constructs Padics over the given ring R using inputted coefficient function f 
padics(Ring, ZZ, Function) := Padics => opts -> (R, p, f) -> (

    computedPoly := constructAdicsPoly(R, p, f,  Degree => opts.ComputedDegree);
    displayedPoly := truncatePadics(p, opts.DisplayedDegree, computedPoly); -- Truncating could be different since users might want to treat degree with variables p, x_1,...,x_n

    new Padics from {
        coefficientFunction => f,
        seriesRing => R,
        primeNumber => p,

        cache => new CacheTable from { -- contains everything mutable
            DisplayedDegree => opts.DisplayedDegree,
            displayedPolynomial => displayedPoly,
            ComputedDegree => opts.ComputedDegree,
            computedPolynomial => computedPoly,
            Degree => infinity,
            valueList => toAdics(p, computedPoly)
        }
    }
);

--converts polynomials to Padics
padics(ZZ, RingElement) := Padics => opts -> (p, g) -> ( 
    R := ring g; 
    f := v -> coefficient(v, g);

    --deg:= infinity; -- default degree, it should be infinite unless the user says
    --if not (opts.DisplayedDegree === null) then deg = opts.DisplayedDegree;
      
    padics(
        p,
        f,
        g,
        DisplayedDegree => opts.DisplayedDegree,
        ComputedDegree => opts.ComputedDegree
        ) 
);

-- Making a Padics without the added computation of polynomial construction
padics(ZZ, Function, Thing) := LazySeries => opts -> (p, f, computedPoly) -> ( 
    R := ring computedPoly;
    newComputedPoly := truncatePadics(p, opts.ComputedDegree, computedPoly);

    new Padics from {
        coefficientFunction => f,
        seriesRing => R,
        primeNumber => p,

        cache => new CacheTable from { -- contains everything mutable
            DisplayedDegree => opts.DisplayedDegree,
            displayedPolynomial => truncatePadics(p, opts.DisplayedDegree, newComputedPoly),
            ComputedDegree => opts.ComputedDegree,
            computedPolynomial => computedPoly,
            Degree => infinity,
            valueList => toAdics(p, computedPoly)
        }
    }
);

-*
padics(Ring, ZZ, List) := Padics => opts -> (R, p, L) -> (
    variables := vars(gens R +1);
    f := variables -> coefficient()


    new Padics from {
        coefficientFunction => f,
        seriesRing => R,
        primeNumber => p,

        cache => new CacheTable from { -- contains everything mutable
            DisplayedDegree => opts.DisplayedDegree,
            displayedPolynomial => displayedPoly,
            ComputedDegree => opts.ComputedDegree,
            computedPolynomial => computedPoly,
            valueList => L
        }
    }

)
*-


-- Coefficient function overload for p-adics
coefficient(VisibleList, Padics) := (L, M) -> (
    R := M.seriesRing;
    p := M.primeNumber;
    variables := {sub(p, R)} | toList gens R;
    monomial := product(apply(#variables, i->(variables#i)^(L#i)));
    H := M.cache.valueList;

    H#monomial
);

minusOne = method()
minusOne(ZZ, Ring) := Padics => (p, R) ->(
    variables := gens R;
    print variables;
    padics(R, p, variables-> p-1)
);

truncate(ZZ, Padics) := Padics => opts ->(n, f) -> ( -- Idea: can generalize ZZ input to Thing

);