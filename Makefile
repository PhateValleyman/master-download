# Makefile pro správu a kompilaci souborů v různých jazycích

# Adresáře
SRC_BASH := ./src/bash
SRC_GOLANG := ./src/golang
SRC_PYTHON := ./src/python
SRC_RUBY := ./src/ruby
SRC_PERL := ./src/perl

# Cílové adresáře pro binární soubory
BIN_DIR := ./bin
BIN_GOLANG := $(BIN_DIR)/golang
BIN_PYTHON := $(BIN_DIR)/python
BIN_RUBY := $(BIN_DIR)/ruby
BIN_PERL := $(BIN_DIR)/perl

# Cílové soubory
BASH_TARGET := $(SRC_BASH)/master-download.sh
GOLANG_TARGET := $(SRC_GOLANG)/master-download.go
PYTHON_TARGET := $(SRC_PYTHON)/master-download.py
RUBY_TARGET := $(SRC_RUBY)/master-download.rb
PERL_TARGET := $(SRC_PERL)/master-download.pl

# PyInstaller cíle
PYTHON_BUILD_DIR := ./build/python
PYTHON_DIST_DIR := $(BIN_PYTHON)

# Help zpráva
.PHONY: help
help:
	@echo "Použití: make [cíl]"
	@echo ""
	@echo "Cíle:"
	@echo "  help         Zobrazí tuto nápovědu"
	@echo "  build        Zkompiluje všechny soubory (Go, Python, Ruby, Perl)"
	@echo "  build-go     Zkompiluje Go soubor do ./bin/golang/master-download"
	@echo "  build-py     Zkompiluje Python soubor do ./bin/python/master-download"
	@echo "  build-ruby   Zkopíruje Ruby skript do ./bin/ruby/master-download"
	@echo "  build-perl   Zkopíruje Perl skript do ./bin/perl/master-download"
	@echo "  run          Spustí všechny skripty (Go, Python, Ruby, Perl)"
	@echo "  run-go       Spustí Go skript (go run)"
	@echo "  run-py       Spustí Python skript"
	@echo "  run-ruby     Spustí Ruby skript"
	@echo "  run-perl     Spustí Perl skript"
	@echo "  clean        Smaže vygenerované soubory a adresáře"
	@echo ""

# Vytvoření adresářů pro binární soubory
$(BIN_DIR):
	@mkdir -p $(BIN_DIR)

$(BIN_GOLANG): $(BIN_DIR)
	@mkdir -p $(BIN_GOLANG)

$(BIN_PYTHON): $(BIN_DIR)
	@mkdir -p $(BIN_PYTHON)

$(BIN_RUBY): $(BIN_DIR)
	@mkdir -p $(BIN_RUBY)

$(BIN_PERL): $(BIN_DIR)
	@mkdir -p $(BIN_PERL)

# Kompilace všech souborů
.PHONY: build
build: build-go build-py build-ruby build-perl

# Kompilace Go souboru
.PHONY: build-go
build-go: $(BIN_GOLANG) $(GOLANG_TARGET)
	@echo "Kompilace Go souboru..."
	@cd $(SRC_GOLANG) && go build -v -x -o $(BIN_GOLANG)/master-download $(SRC_GOLANG)/master-download.go
	@echo "Go soubor zkompilován do $(BIN_GOLANG)/master-download."

# Kompilace Python souboru pomocí PyInstaller
.PHONY: build-py
build-py: $(BIN_PYTHON) $(PYTHON_TARGET)
	@echo "Kompilace Python souboru pomocí PyInstaller..."
	@mkdir -p $(PYTHON_BUILD_DIR)
	@pyinstaller --onefile --distpath $(PYTHON_DIST_DIR) --workpath $(PYTHON_BUILD_DIR) --specpath $(PYTHON_BUILD_DIR) $(PYTHON_TARGET)
	@echo "Python soubor zkompilován do $(BIN_PYTHON)/master-download."

# Kopírování Ruby skriptu
.PHONY: build-ruby
build-ruby: $(BIN_RUBY) $(RUBY_TARGET)
	@echo "Kopírování Ruby skriptu..."
	@cp $(RUBY_TARGET) $(BIN_RUBY)/master-download
	@chmod +x $(BIN_RUBY)/master-download
	@echo "Ruby skript zkopírován do $(BIN_RUBY)/master-download."

# Kopírování Perl skriptu
.PHONY: build-perl
build-perl: $(BIN_PERL) $(PERL_TARGET)
	@echo "Kopírování Perl skriptu..."
	@cp $(PERL_TARGET) $(BIN_PERL)/master-download
	@chmod +x $(BIN_PERL)/master-download
	@echo "Perl skript zkopírován do $(BIN_PERL)/master-download."

# Spuštění všech skriptů
.PHONY: run
run: run-go run-py run-ruby run-perl

# Spuštění Go skriptu
.PHONY: run-go
run-go: $(GOLANG_TARGET)
	@echo "Spouštění Go skriptu..."
	@cd $(SRC_GOLANG) && go run master-download.go

# Spuštění Python skriptu
.PHONY: run-py
run-py: $(PYTHON_TARGET)
	@echo "Spouštění Python skriptu..."
	@python3 $(PYTHON_TARGET)

# Spuštění Ruby skriptu
.PHONY: run-ruby
run-ruby: $(RUBY_TARGET)
	@echo "Spouštění Ruby skriptu..."
	@ruby $(RUBY_TARGET)

# Spuštění Perl skriptu
.PHONY: run-perl
run-perl: $(PERL_TARGET)
	@echo "Spouštění Perl skriptu..."
	@perl $(PERL_TARGET)

# Vyčištění vygenerovaných souborů
.PHONY: clean
clean:
	@echo "Čištění vygenerovaných souborů..."
	@rm -rf $(BIN_DIR) $(PYTHON_BUILD_DIR)
	@echo "Vyčištěno."
