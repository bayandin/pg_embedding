EXTENSION = embedding
EXTVERSION = 0.3.5

MODULE_big = embedding
DATA = $(wildcard *--*.sql)
OBJS = embedding.o hnswalg.o distfunc.o clustering.o transform.o

TESTS = $(wildcard test/sql/*.sql)
REGRESS = $(patsubst test/sql/%.sql,%,$(TESTS))
REGRESS_OPTS = --inputdir=test --load-extension=embedding

# For auto-vectorization:
# - GCC&clang needs -Ofast or -O3: https://gcc.gnu.org/projects/tree-ssa/vectorization.html
PG_CFLAGS += -Ofast
ifeq ($(shell uname -s), Darwin)
    PG_CXXFLAGS += -DUSE_OMP -I/usr/local/include -Xclang -fopenmp  -std=c++11
    PG_LDFLAGS += -L/usr/local/lib -lomp -L/opt/homebrew/opt/openblas/lib -lblas -lstdc++
else
    PG_CXXFLAGS += -DUSE_OMP -fopenmp -std=c++11
    PG_LDFLAGS += -lstdc++ -fopenmp -lblas
endif


all: $(EXTENSION)--$(EXTVERSION).sql

PG_CONFIG ?= pg_config
PGXS := $(shell $(PG_CONFIG) --pgxs)
include $(PGXS)

dist:
	mkdir -p dist
	git archive --format zip --prefix=$(EXTENSION)-$(EXTVERSION)/ --output dist/$(EXTENSION)-$(EXTVERSION).zip main
