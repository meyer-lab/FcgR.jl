
all: figureB1.pdf output/depletion/manuscript.md output/translation/manuscript.md

venv: venv/bin/activate

venv/bin/activate: requirements.txt
	test -d venv || virtualenv venv
	. venv/bin/activate && pip install -Uqr requirements.txt
	touch venv/bin/activate

figureB1.pdf:
	julia -e 'using Pkg; Pkg.activate("."); using FcgR; FcgR.figureB1()'

output/%/manuscript.md: venv manuscripts/%/*.md
	mkdir -p ./output/%
	. venv/bin/activate && manubot process --content-directory=.manuscripts/%/ --output-directory=./output/% --log-level=INFO

coverage.cob:
	julia -e 'using Pkg; Pkg.add("Coverage"); using Coverage; coverage = process_folder(); LCOV.writefile("coverage-lcov.info", coverage)'
	pip3 install --user lcov_cobertura
	python3 ~/.local/lib/python3.7/site-packages/lcov_cobertura.py coverage-lcov.info -o coverage.cob

clean:
	rm -rf *.pdf venv
