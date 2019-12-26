
all: translation.pdf depletion.pdf figureB1.pdf

%.pdf: %.jmd
	julia -e 'using Pkg; Pkg.add("Weave"); using Weave; weave("$<", out_path=:pwd, throw_errors=true, doctype="md2pdf")'

figureB1.pdf:
	julia -e 'using Pkg; Pkg.activate("."); using FcgR; FcgR.figureB1()'

coverage.cob:
	julia -e 'using Pkg; Pkg.add("Coverage"); using Coverage; coverage = process_folder(); LCOV.writefile("coverage-lcov.info", coverage)'
	pip3 install --user lcov_cobertura
	python3 ~/.local/lib/python3.7/site-packages/lcov_cobertura.py coverage-lcov.info -o coverage.cob

clean:
	rm -rf *.pdf *.aux *.log *.out
