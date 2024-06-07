UNAME := $(shell uname)

CXX := clang++
CXXFLAGS := -fPIC -I. -I $(NIX_ERL_DIR)/usr/include -Wall -Wextra -O2 -std=c++17 $(NIX_CFLAGS_COMPILE)
LDFLAGS := $(NIX_LDFLAGS) -l rocksdb

ifeq ($(UNAME), Darwin)
	LDFLAGS += -flat_namespace -undefined dynamic_lookup
endif

TARGET := ../priv/liberocksdb.so

SRCDIR := .
SOURCES := $(wildcard $(SRCDIR)/*.cc)
OBJECTS := $(SOURCES:.cc=.o)

all: $(TARGET)

../priv:
	mkdir ../priv
	
$(TARGET): $(OBJECTS) | ../priv
	$(CXX) -shared $(LDFLAGS) -o $@ $^

%.o: %.cc
	$(CXX) $(CXXFLAGS) -c -o $@ $<

clean:
	rm -f $(OBJECTS) $(TARGET)

.PHONY: all clean
