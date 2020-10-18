all:
	make -C ./software/tools/compiler all 
	make -C ./software/target/builds all 
	make -C ./software/target/builds -f Makefile.kernels all 
	make -C ./examples/test all 
	make -C ./examples/blur all 
	make -C ./examples/classifier all 
	make -C ./examples/edge_detect all 
	make -C ./examples/greyscale all 
	make -C ./examples/harris_corner all 
	make -C ./examples/objdetect all 
	make -C ./examples/resize all 
clean:
	make -C ./software/tools/compiler clean 
	make -C ./software/target/builds clean 
	make -C ./software/target/builds -f Makefile.kernels clean 
	make -C ./examples/test clean 
	make -C ./examples/blur clean 
	make -C ./examples/classifier clean 
	make -C ./examples/edge_detect clean 
	make -C ./examples/greyscale clean 
	make -C ./examples/harris_corner clean 
	make -C ./examples/objdetect clean 
	make -C ./examples/resize clean 
