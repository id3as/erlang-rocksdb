MINIO_PID=/tmp/erocksdb_minio.pid

all: compile test

compile: cmake nif
	@rebar3 compile

cmake: _build/cmake/Makefile

nif: 
	(cd _build/cmake && cmake --build .)


_build/cmake/Makefile: c_src/CMakeLists.txt
	mkdir -p _build/cmake
	(cd _build/cmake && cmake ../../c_src)


test: compile
	@rm -rf /tmp/erocksdb_data
	#@rm -rf $(MINIO_PID)
	@mkdir -p /tmp/erocksdb_data
	#@MINIO_ACCESS_KEY="admin" \
	#	MINIO_SECRET_KEY="password" \
	#	minio server /tmp/erocksdb_data & \
	#	echo "$$!" > $(MINIO_PID)
	@DYLD_LIBRARY_PATH=./priv:../rocksdb-cloud/out/lib rebar3 eunit
	#@kill `cat $(MINIO_PID)`

clean:
	@rebar3 clean
