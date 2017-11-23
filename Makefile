all: result_noncompact.txt result_compact.txt

clean:
	rm -f result_noncompact.txt result_compact.txt CompactListsBenchmark ListsBenchmark *.hi *.o

CompactListsBenchmark: CompactListsBenchmark.hs
	~/ghc-8.2.1/bin/ghc $^

ListsBenchmark: ListsBenchmark.hs
	~/ghc-8.2.1/bin/ghc $^

result_compact.txt: CompactListsBenchmark
	./CompactListsBenchmark +RTS -s 2> $@

result_noncompact.txt: ListsBenchmark
	./ListsBenchmark +RTS -s 2> $@
