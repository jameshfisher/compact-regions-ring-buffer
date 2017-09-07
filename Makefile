all: CompactListsBenchmark ListsBenchmark

CompactListsBenchmark: CompactListsBenchmark.hs
	~/ghc-8.2.1/bin/ghc CompactListsBenchmark.hs

ListsBenchmark: ListsBenchmark.hs
	~/ghc-8.2.1/bin/ghc ListsBenchmark.hs
