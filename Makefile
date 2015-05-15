.PHONY: clean

all: Makefile.coq
	$(MAKE) -f Makefile.coq

Makefile.coq: coq_args
	coq_makefile -f coq_args -o Makefile.coq

clean: Makefile.coq
	$(MAKE) -f Makefile.coq clean
