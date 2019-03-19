InstallMethod( TwoClosure, "for a permutation group",
               [ IsPermGroup ],
function(G)

	local op,adjacencyMatrix, # utility functions
		Omega,n, # the set G acts on and its size
		ii,jj, # loop counters
		processedOrbitals,unprocessedOrbitals, # two piles of orbitals 
		importantOrbitals, # the orbitals which have any chance of contributing to the two-closure
		Omega2WithoutProcessedOrbitals,
		Gamma, # one orbital
		E,basisOfE,algebraGens, # a subalgebra of the endomorphism algebra, a basis of E and a set of algebra generators
		partition,partitionNew, # two partitions of Omega2WithoutProcessedOrbitals
		values;
	
	Omega := MovedPoints(G);
	n:=Size(Omega);
	
	op := Gamma -> Set(Gamma, t -> [t[2],t[1]] );
	adjacencyMatrix := function(Gamma)
		local X;
		X:=NullMat(n,n,Integers);
		for ii in [1..n] do
		for jj in [1..n] do
			if( [Omega[ii],Omega[jj]] in Gamma) then
				X[ii][jj] := 1;
			fi;
		od;od;
		return X;
	end;
	
	# Step 1: Initialise
	processedOrbitals := Set([]);
	unprocessedOrbitals := Set(OrbitsDomain(G,Cartesian(Omega,Omega),OnPairs));
	importantOrbitals := Set([]);
	
	algebraGens := [];
	
	while not(IsEmpty(unprocessedOrbitals)) do
		# Step 2.i: Pick any orbital \Gamma and move it from the unprocessed pile
		# the to pile of processed orbitals.
		Gamma := unprocessedOrbitals[1];
		AddSet(processedOrbitals, Gamma);
		AddSet(processedOrbitals, op(Gamma));
		RemoveSet(unprocessedOrbitals, Gamma);
		RemoveSet(unprocessedOrbitals, op(Gamma));
		
		# 2.i.a. & 2.i.b. If \Gamma=\Gamma^{op} is the only unprocessed orbitals left, we're already done here. If \Gamma and \Gamma^{op} are the only two unprocessed orbitals left, then we are also done, but we have to remember \Gamma as important.
		if(IsEmpty(unprocessedOrbitals)) then
			if(Gamma <> op(Gamma)) then
				AddSet(importantOrbitals,Gamma);
			fi;
			break;
		# 2.i.c. If there are other orbitals left unprocessed, then we are not done, but we have to remember \Gamma as important.
		else
			AddSet(importantOrbitals,Gamma);
		fi;
		
		# Step 2.ii: Compute a new partition of \Omega^2 without the processed
		# orbitals.
		Omega2WithoutProcessedOrbitals := Union(unprocessedOrbitals);
		partition := Set([]);
		partitionNew := Set([Omega2WithoutProcessedOrbitals]);
		
		while Size(partition) < Size(partitionNew) do
			partition := partitionNew;
			
			# 2.ii.b. Compute the algebra generated by all the adjacency matrices 
			# of the important unprocessedOrbitals as well as the adjacency
			# matrices of the parts of partition
			E := AlgebraWithOne(Rationals, List(Union(processedOrbitals,partition), adjacencyMatrix));

			# 2.ii.c. Compute the coarsests partition of Omega^2 such that every
			# matrix in E is constant on its parts.
			basisOfE := Basis(E);
			
			# By necessity all elements of E are constant on the orbitals which have
			# already been processed. So we only look at the different values on the
			# unprocessed orbitals.
			values := Set(Omega2WithoutProcessedOrbitals,
				t -> List(basisOfE, X -> X[t[1]][t[2]]));
			
			partitionNew := Set(values, value -> Filtered(Omega2WithoutProcessedOrbitals, t -> value = List(basisOfE, X -> X[t[1]][t[2]] )));
		od;
		
		# Step 2.iii.: All orbitals which happen to occur in the computed
		# partition are unimportant and do not contribute new information to the 
		# 2-closure of G.
		processedOrbitals := Union(processedOrbitals, Intersection(unprocessedOrbitals, partition));
		unprocessedOrbitals := Difference(unprocessedOrbitals, partition);
	od;
	
	# Step 3: TwoClosure(G) is the intersection of Aut(Omega,Gamma) for all important orbitals Gamma.
	return Intersection(importantOrbitals, Gamma ->
		AutomorphismGroup(Digraph(adjacencyMatrix(Gamma))) );
end
);