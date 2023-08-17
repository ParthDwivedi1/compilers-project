CXX = g++-8
EXE = iplC
CXXDEBUG = -g -Wall
CXXSTD = -std=c++11


.PHONY: all
all: parser lexer symbol_gen astnode_gen
	$(CXX) $(CXXDEBUG) -o $(EXE) driver.cpp parser.o scanner.o symbol.o astnode.o

parser: parser.yy scanner.hh
	bison -d -v $<
	$(CXX) $(CXXDEBUG) $(CXXSTD) -c parser.tab.cc -o parser.o 

symbol_gen: symbol.hh 
	$(CXX) $(CXXDEBUG) $(CXXSTD) -c symbol.cpp -o symbol.o 

astnode_gen: astnode.hh
	$(CXX) $(CXXDEBUG) $(CXXSTD) -c astnode.cpp -o astnode.o

lexer: scanner.l scanner.hh parser.tab.hh parser.tab.cc	
	flex++ --outfile=scanner.yy.cc  $<
	$(CXX)  $(CXXDEBUG) $(CXXSTD) -c scanner.yy.cc -o scanner.o
clean:
	rm parser.o parser.tab.cc scanner.o scanner.yy.cc location.hh parser.tab.hh stack.hh position.hh parser.output astnode.o symbol.o $(EXE)
